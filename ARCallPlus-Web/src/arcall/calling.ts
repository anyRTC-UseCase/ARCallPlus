import ARTCCalling, { CallEvents, CallMode, CallType } from "ar-call-sdk";

// 配置信息
import Config from "../config";
// 信息提示
import Message from "@/assets/untils/message";
// 路由跳转
import Router from "@/router";
import store from "@/store";

/** 推送接口 */
import { jpushProcessPush } from "@/api/index";

// 实例
let callClient: ARTCCalling | null = null;

/**
 * 页面刷新后返回首页
 * @returns
 */
export const refreshBash = () => {
  return callClient;
};

/**
 * 初始化
 */
export const initCallClient = () => {
  console.log("初始化");

  if (callClient) return;
  // 初始化实例
  callClient = new ARTCCalling({ appId: Config.CONFIG_APPID });

  // 开启音频检测(发起呼叫时或接收到呼叫时调用)
  callClient.enableAudioVolumeIndicator();

  //  SDK 版本
  console.log("SDK 版本", callClient.getSdkVersion());

  // 初始化回调 onVolumeIndicator
  // 音频检测(频道内说活人员)
  callClient.on(ARTCCalling.EVENT.USER_VOLUME, (result) => {
    // console.log("音频检测(频道内说活人员)", result)
    store.commit("addVolumePrompt", result);
    result.forEach((volume, index) => {
      console.log(`${index} UID ${volume.uid} Level ${volume.level}`);
    });
  });
  // 网络状态
  callClient.on(
    ARTCCalling.EVENT.CONNECTION_STATE_CHANGED,
    (status, reason) => {
      console.log("网络状态", status, reason);
    }
  );
  // 用户加入
  callClient.on(ARTCCalling.EVENT.USER_ENTER, async (userInfo: any) => {
    store.commit("joinMultiRemoteInfoList", userInfo.peer);
    console.log("用户加入", userInfo);
    // 远端视图渲染
    await startView(
      {
        userId: userInfo.peer.userId,
        viewDomId: "view_remote" + userInfo.peer.userId,
      },
      "远端视图"
    );
  });
  // 用户离开
  callClient.on(ARTCCalling.EVENT.USER_LEFT, (userInfo) => {
    console.log("用户离开 USER_LEFT", userInfo);
    Message({ message: "用户" + userInfo.peer.userId + "离开", type: "error" });
    // 多人场景下使用
    store.commit("deleteMultiRemoteInfo", userInfo.peer);
  });
  // 重复登录
  callClient.on(ARTCCalling.EVENT.KICK_OUT, () => {
    console.log("重复登录 EVENT.KICK_OUT");
    Message({ message: "账号异地登录", type: "error" });
    localStorage.setItem("ARcall_USERINFO", "");
    localStorage.setItem("ARCALLPLUSTOKEN", "");
    // 更改登录状态
    store.commit("updataIsLoginStatus", false);
    Router.replace("/login");
    alert("账号异地登录");
  });
  // 用户发布
  callClient.on(
    ARTCCalling.EVENT.USER_PUBLISH,
    async (callDetail, user, mediaType) => {
      if (mediaType === "video") {
        Message({ message: "用户：" + user.uid + "视频开启" });
      }
      if (mediaType === "audio") {
        Message({ message: "用户：" + user.uid + "音频开启" });
      }
      store.commit("optionMultiRemoteInfoList", {
        userId: user.uid,
        hasAudio: user.hasAudio,
        hasVideo: user.hasVideo,
        loading: false, // 关闭加载
      });
    }
  );
  // 用户取消发布
  callClient.on(
    ARTCCalling.EVENT.USER_UNPUBLISH,
    (callDetail, user, mediaType) => {
      if (mediaType === "video") {
        Message({ message: "用户：" + user.uid + "视频关闭" });
      }
      if (mediaType === "audio") {
        Message({ message: "用户：" + user.uid + "音频关闭" });
      }
      store.commit("optionMultiRemoteInfoList", {
        userId: user.uid,
        hasAudio: user.hasAudio,
        hasVideo: user.hasVideo,
        loading: false, // 关闭加载
      });
    }
  );
  // 视频通话转音频通话(p2p使用)
  callClient.on(ARTCCalling.EVENT.SWITCH_TO_AUDIO_CALL, () => {
    console.log("视频通话转音频通话 EVENT.SWITCH_TO_AUDIO_CALL");

    // 停止本地预览
    callClient?.stopLocalView();
    // 返回
    Router.replace("/p2p/call_audio");
  });
  // 通话结束
  callClient.on(ARTCCalling.EVENT.END_CALL, (reason) => {
    console.log("通话结束 EVENT.END_CALL", reason);
    Message({ message: "通话结束" });
    // 停止本地预览
    callClient?.stopLocalView();
    // 清空状态
    store.commit("statusClearAll", true);
    // 返回
    Router.replace("/");
  });

  // 通话结束(主叫有用,远端用户不在线)
  callClient.on(
    ARTCCalling.EVENT.PUSH_OFFLINE_MESSAGE,
    async (offlineUsers) => {
      // 用户信息
      console.log("通话结束(远端用户不在线)", offlineUsers);
      // 不在线用户组合
      const offUser = offlineUsers.peers.map((item) => {
        return item.userId;
      });
      // vuex 存储信息
      const oStore = store.state;

      // 远端用户不在线，发起推送
      const { code } = await jpushProcessPush({
        caller: oStore.userInfo.userId, // 主叫 uid
        callee: offUser, // 被叫者Id数组
        callType:
          oStore.model == 0
            ? oStore.pattern == "audio"
              ? 2
              : 3
            : oStore.pattern == "audio"
            ? 0
            : 1, // 呼叫类型
        pushType: 0, // 推送类型
        title: "", // 推送通知栏的标题
      });
      if (code == 403) {
        Message({ message: "点对点模式下不支持推送", type: "error" });
      }

      if (oStore.model == 1) {
        // 点对点模式下挂断
        await hangup();
        Message({
          message: "远端用户不在线",
          type: "error",
        });
        // 清空状态
        store.commit("statusClearAll", true);
        // 返回
        Router.replace("/");
      }
    }
  );

  // 收到远程发起的呼叫邀请
  callClient.on(
    ARTCCalling.EVENT.INVITED,
    async (calleeUserInfo, calleeUserList) => {
      // 发起者相关信息
      console.log("发起者相关信息", calleeUserInfo, calleeUserList);
      // 收到的情景类型
      store.commit(
        "updataPattern",
        calleeUserInfo.mode == 1 ? "audio" : "video"
      );
      // 情景模式
      store.commit("updataModel", calleeUserInfo.multi ? 0 : 1);

      if (calleeUserInfo.multi) {
        // 远端主叫信息 + 主叫呼叫其他用户信息列表(包含本身)
        store.commit("addMultiRemoteInfoList", [
          calleeUserInfo.peer,
          ...calleeUserList,
        ]);
        Router.replace("/multi/remote");
      } else {
        // p2p
        // 存入远端用户信息
        store.commit("addP2PRemoteInfo", calleeUserInfo.peer);
        Router.replace("/p2p/remote");
      }
    }
  );
  // 远程接收呼叫邀请
  callClient.on(ARTCCalling.EVENT.ACCEPT_CALL, (calleeUserInfo) => {
    console.log("远程接收呼叫邀请 EVENT.ACCEPT_CALL", calleeUserInfo);
    // 判断 p2p 相关逻辑
    if (!calleeUserInfo.multi) {
      // 存入远端用户信息
      store.commit("addP2PRemoteInfo", calleeUserInfo.peer);
      // 通话模式
      store.commit(
        "updataPattern",
        calleeUserInfo.mode == 1 ? "aduio" : "video"
      );
      Router.replace(
        calleeUserInfo.mode == 1 ? "/p2p/call_audio" : "/p2p/call_video"
      );
    }
    // 开始计时
    store.commit("controlCallTime", true);
  });
  // 远程拒绝呼叫邀请
  callClient.on(
    ARTCCalling.EVENT.REJECT_CALL,
    (calleeUserInfo, refuseReason) => {
      console.log(
        "远程拒绝呼叫邀请 EVENT.REJECT_CALL",
        calleeUserInfo,
        refuseReason
      );
      if (calleeUserInfo.multi) {
        // 多人通话模式下
        store.commit("deleteMultiRemoteInfo", calleeUserInfo.peer);
      } else {
        // 点对点通话模式下返回首页
        Router.replace("/");
        // 清空状态
        store.commit("statusClearAll", true);
      }
      Message({
        message: "用户:" + calleeUserInfo.peer.userId + "拒绝呼叫邀请",
        type: "error",
      });
    }
  );
  // 远程无应答（呼叫邀请）
  callClient.on(ARTCCalling.EVENT.NO_RESPONSE, (calleeUserInfo) => {
    console.log("远程无应答（呼叫邀请） EVENT.NO_RESPONSE", calleeUserInfo);
    if (calleeUserInfo.multi) {
      // 多人通话模式下
      store.commit("deleteMultiRemoteInfo", calleeUserInfo.peer);
    } else {
      // 点对点通话模式下返回上一级
      // 清空状态
      store.commit("statusClearAll", true);
      Router.replace("/");
    }
    Message({
      message: "用户:" + calleeUserInfo.peer.userId + "无应答",
      type: "error",
    });
  });
  // 远程正在通话中，忙线中（拒绝呼叫邀请）
  callClient.on(ARTCCalling.EVENT.LINE_BUSY, (calleeUserInfo) => {
    console.log("远程正在通话中，忙线中 EVENT.LINE_BUSY", calleeUserInfo);
    Message({
      message: `用户：${calleeUserInfo.peer.userId}正在通话中，忙线中`,
      type: "error",
    });
    // 获取情景模式
    const oModel = store.getters.getModel;
    if (oModel == 0) {
      // 多人通话模式下
      store.commit("deleteMultiRemoteInfo", calleeUserInfo.peer);
    } else {
      store.commit("statusClearAll", true);

      // 返回首页
      Router.replace("/");
    }
  });

  // 主叫取消呼叫邀请
  callClient.on(ARTCCalling.EVENT.CANCEL_CALL, (callerUserInfo) => {
    Message({ message: "主叫取消呼叫邀请" });
    store.commit("statusClearAll", true);
    console.log("主叫取消呼叫邀请 EVENT.CANCEL_CALL", callerUserInfo);
    // 返回首页
    Router.replace("/");
  });
  // 呼叫邀请已过期，未及时应答（呼叫邀请）
  callClient.on(ARTCCalling.EVENT.CALLING_TIMEOUT, (callerUserInfo) => {
    Message({ message: "邀请已过期，未及时应答", type: "error" });
    store.commit("statusClearAll", true);
    // 作为被邀请方会收到，收到该回调说明本次通话超时未应答
    console.log(
      "呼叫邀请已过期，未及时应答（呼叫邀请） EVENT.CALLING_TIMEOUT",
      callerUserInfo
    );
    // 返回首页
    Router.replace("/");
  });
};

/**
 * 登录 arcall-plus 系统
 * @param userInfo 登录用户信息
 */
export const loginArcallPlus = (userInfo: {
  userId: string;
  headerUrl: string;
  userName: string;
}) => {
  return callClient!.login(userInfo);
};

/**
 * 发起 p2p 呼叫
 * @param userInfo 呼叫用户信息
 * @param callType 呼叫用户类型 0:视频童虎 1:语音通话
 */
export const makeP2PCall = (
  userInfo: {
    userId: string;
    headerUrl: string;
    userName: string;
    customData: string;
  },
  callType: number
) => {
  // 发起呼叫
  return callClient!.call({
    user: userInfo,
    // 通话类型
    mode: callType,
  });
};

/**
 * 发起多人呼叫
 */
export const makeMultiCall = (
  userInfo: {
    userId: string;
    headerUrl?: string;
    userName?: string;
    customData?: string;
  }[],
  callMode: CallMode
) => {
  console.log("发起多人呼叫", userInfo, callMode);

  // 发起呼叫
  return callClient!.groupCall({
    type: CallType.Normal,
    users: userInfo,
    // 通话类型
    mode: callMode,
    // // 自定义离线消息推送
    // offlinePushInfo: CallOfflinePushInfo
  });
};

/**
 * 取消邀请/取消通话(通用)
 */
export const hangup = () => {
  callClient!.hangup();
  // 清空状态
  store.commit("statusClearAll", true);
  // 返回原页面
  Router.replace("/");
};

/**
 * 接受通话邀请(通用)
 */
export const acceptCall = async () => {
  await callClient!.accept();
  // 开始计时
  store.commit("controlCallTime", true);
};

/**
 * 拒绝通话邀请(通用)
 */
export const rejectCall = () => {
  callClient!.reject();
  // 返回原页面
  Router.replace("/");
};

/**
 * 将视频通话切换语音通话
 * 仅支持1v1通话过程中使用
 */
export const switchToAudioCall = () => {
  return callClient!.switchToAudioCall();
};

/**
 * 显示视图(通用)
 */
export const startView = async (
  viewInfo: {
    userId: string;
    viewDomId: string;
  },
  type: string = "本地视图"
) => {
  if (type === "本地视图") {
    await callClient!.startLocalView({
      viewDomId: viewInfo.viewDomId,
    });
  }
  if (type === "远端视图") {
    await callClient!.startRemoteView({
      userId: viewInfo.userId,
      viewDomId: viewInfo.viewDomId,
      fit: "contain",
    });
  }
};
/**
 * 停止预览
 */
export const stopView = (type: string = "本地视图", userId?: string) => {
  if (type === "本地视图") {
    return callClient!.stopLocalView();
  }
  if (type === "远端视图") {
    return callClient!.stopRemoteView({ userId: userId || "" });
  }
};
/**
 * 设置麦克风禁音(通用)
 * setMicMute
 */
export const setMicMute = (control: boolean) => {
  return callClient!.setMicMute(!control);
};

/**
 * 打开/关闭摄像头
 * setCameraMute (通用)
 */
export const setCameraEnable = (control: boolean) => {
  return callClient!.setCameraMute(!control);
};
