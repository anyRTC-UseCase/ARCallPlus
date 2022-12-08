import { createStore } from "vuex";

const store = createStore({
  state: () => ({
    // 情景模式 0:多人模式 1:p2p模式
    model: 0,
    // 情景类型 video/audio
    pattern: "",
    // 是否登录
    isLogin: false,
    // 用户信息
    userInfo: { userId: "", level: 0 },

    // p2p 远端用户信息
    p2pRemoteInfo: {},

    /** 多人呼叫相关 */
    // 多人远端用户信息列表
    multiRemoteInfoList: [] as any,

    // 多人-加入频道的用户信息
    multiRemoteJoinInfoList: [] as any,
    // -被叫(60s无响应，去除信息)  信息去除(定时器)
    deleteTime: 60 * 1000,
    deleteTimer: 0,

    /** 通话计时 */
    callNum: 0,
    callTime: "00:00:00",
    callTimer: 0,
  }),
  getters: {
    // 获取情景模式
    getModel: (state) => {
      return state.model;
    },
  },
  mutations: {
    // 类型模式更换
    updataModel(state, model: number) {
      state.model = model;
    },
    // 情景模式更换
    updataPattern(state, pattern: string) {
      state.pattern = pattern;
    },
    // 登录状态更新
    updataIsLoginStatus(state, status: boolean) {
      state.isLogin = status;
    },
    // 添加用户信息
    addUserInfo(state, info) {
      state.userInfo = Object.assign(state.userInfo, info);
    },
    // 添加远端用户信息
    addP2PRemoteInfo(state, info) {
      state.p2pRemoteInfo = info;
    },
    // 多人远端用户信息列表(去除本身信息)
    addMultiRemoteInfoList(state, info) {
      state.multiRemoteInfoList = info.filter(
        (item: { userId: string; loading?: boolean }) => {
          // 默认打开loading
          item.loading = true;
          return item.userId != state.userInfo.userId;
        }
      );
    },
    // 多人远端用户音视频相关操作(远端用户静音/取消静音，远端用户关闭/打开视频)
    optionMultiRemoteInfoList(state, userInfo) {
      state.multiRemoteInfoList.forEach((item: any) => {
        if (item.userId == userInfo.userId) {
          item.hasAudio = userInfo.hasAudio;
          item.hasVideo = userInfo.hasVideo;
          // 响应后关闭加载中
          item.loading = userInfo.loading;
        }
      });
    },
    // 多人用户信息列表删除指定远端用户
    deleteMultiRemoteInfo(state, user) {
      if (state.model == 0) {
        state.multiRemoteInfoList = state.multiRemoteInfoList.filter(
          (item: { userId: string; loading?: boolean }) => {
            return item.userId != user.userId;
          }
        );
      }
    },
    // 多人-加入频道的用户信息
    joinMultiRemoteInfoList(state, user) {
      // 多人模式下执行
      if (state.model == 0) {
        // 默认打开 loading
        user.loading = true;
        if (state.multiRemoteJoinInfoList.length > 0) {
          const oM = state.multiRemoteJoinInfoList.filter(
            (item: { userId: string }) => {
              return item.userId === user.userId;
            }
          );
          if (oM.length == 0) {
            state.multiRemoteJoinInfoList.push(user);
          }
        } else {
          state.multiRemoteJoinInfoList.push(user);
        }
      }
      console.log("multiRemoteJoinInfoList", state.multiRemoteJoinInfoList);
    },
    // 多人呼叫-被叫(60s无响应，去除无响应用户)
    noResponseMultiRemoteInfoList(state, status: boolean) {
      state.deleteTimer && clearTimeout(state.deleteTimer);
      if (status) {
        state.deleteTimer = window.setTimeout(() => {
          console.log(
            "60s无响应，去除无响应用户",
            state.multiRemoteInfoList,
            state.multiRemoteJoinInfoList
          );
          const oM: any[] = [];
          state.multiRemoteInfoList.forEach((item: any) => {
            state.multiRemoteJoinInfoList.forEach((item2: any) => {
              if (item.userId == item2.userId) {
                oM.push(item);
              }
            });
          });
          state.multiRemoteInfoList = oM;
        }, state.deleteTime);
      }
    },

    // 添加音量提示(多人)
    addVolumePrompt(state, result) {
      result.forEach((item: { uid: string; level: number }) => {
        if (item.uid) {
          // 判断是否存在本人
          if (item.uid === state.userInfo.userId) {
            state.userInfo.level = item.level;
          } else {
            state.multiRemoteInfoList.forEach(
              (remote: { userId: string; level: number }) => {
                if (item.uid === remote.userId) {
                  remote.level = item.level;
                }
              }
            );
          }
        }
      });
    },

    // 通话计时
    controlCallTime(state, control: boolean) {
      state.callTimer && clearInterval(state.callTimer);
      if (control) {
        // 开启计时
        state.callTimer = window.setInterval(() => {
          state.callNum++;

          const oS = state.callNum % 60;
          const oM = parseInt((state.callNum / 60) as any) % 60;
          const oH = parseInt((state.callNum / 60 / 60) as any);

          state.callTime =
            (oH < 10 ? oH.toString().padStart(2, "0") : oH) +
            ":" +
            (oM < 10 ? oM.toString().padStart(2, "0") : oM) +
            ":" +
            (oS < 10 ? oS.toString().padStart(2, "0") : oS);
        }, 1000);
      } else {
        // 清空计时
        state.callTime = "00:00:00";
      }
    },

    // 状态清空
    statusClearAll(state, type: boolean) {
      if (type) {
        state.deleteTimer && clearTimeout(state.deleteTimer);
        state.callTimer && clearInterval(state.callTimer);
        state.callNum = 0;
        state.userInfo.level = 0;
        // p2p 远端用户信息
        state.p2pRemoteInfo = {};
        // 多人远端用户信息列表
        state.multiRemoteInfoList = [];
        /** 多人呼叫-被叫(30s无响应，去除信息) */
        // 多人-加入频道的用户信息
        state.multiRemoteJoinInfoList = [];
        state.deleteTimer = 0;
        /** 通话计时 */
        state.callNum = 0;
        state.callTime = "00:00:00";
        state.callTimer = 0;
      }
    },
  },
});

export default store;
