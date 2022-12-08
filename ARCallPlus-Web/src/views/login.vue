<!-- 登录 -->
<template>
  <!-- 首次登录 -->
  <div class="h-full flex flex-col justify-center items-center">
    <div
      class="py-14 px-28 border border-white bg-white bg-opacity-20 rounded-3xl"
    >
      <div v-show="!loginInfo.fulfill">
        <h2 class="text-arcall-gray_1 font-bold text-lg mb-12">
          anyRTC 实时音视频
        </h2>
        <input
          v-model="loginInfo.tel"
          class="basics_input"
          maxlength="11"
          type="tel"
          placeholder="请输入电话号码"
        />
        <div class="mt-6">
          <button @click="submitTelFn" class="basics_button w-full">
            登录
          </button>
        </div>
      </div>
      <!-- 完善信息 -->
      <div v-show="loginInfo.fulfill">
        <h1 class="font-bold txt-call-gray_1 text-lg mb-8">
          anyRTC 实时音视频
        </h1>
        <!-- 更换头像 -->
        <div class="flex justify-center mb-6 relative">
          <img
            class="w-24 h-24 rounded-lg"
            :src="avatar"
            draggable="false"
            alt=""
          />
          <button
            class="absolute bottom-0 w-24 bg-arcall-blue_1 text-xs text-white py-1.5 rounded-b-lg"
            @click="avatarFn"
          >
            更换头像
          </button>
        </div>
        <!-- 随机名称 -->
        <div class="relative">
          <input
            v-model.trim="name"
            maxlength="24"
            class="basics_input"
            type="text"
            placeholder="请填写名称"
          />
          <div
            @click="nameFn"
            class="absolute right-3 top-0 bottom-0 cursor-pointer flex items-center justify-center transform hover:rotate-45"
          >
            <img
              class="w-7"
              src="@/assets/img/sifter.png"
              draggable="false"
              alt=""
            />
          </div>
        </div>
        <!-- 完成 -->
        <button @click="submitInfoFn" class="basics_button w-full mt-6">
          完成
        </button>
      </div>

      <!-- 更多 -->
      <div class="mt-6 text-center">
        <a
          class="text-xs text-arcall-blue_1 font-bold"
          href="https://docs.anyrtc.io/"
          target="_blank"
          rel="noopener noreferrer"
        >
          了解更多
        </a>
      </div>
    </div>
    <p class="text-arcall-gray_2 text-xs font-extrabold fixed bottom-20">
      Powered by anyRTC
    </p>
  </div>
</template>

<script lang="ts">
// 接口
import { jpushExists, jpushInit } from "@/api/index";
// 信息提示
import Message from "@/assets/untils/message";
// 随机头像
import RandomAvatar from "@/assets/untils/random_avatar";
// 随机名称
import RandomName from "@/assets/untils/random_name";
import Config from "@/config";
// 获取设备信息
import { getDevice } from "@/assets/untils/until";
import { defineComponent, reactive, ref } from "vue";
import { useRouter } from "vue-router";
import { useStore } from "vuex";
export default defineComponent({
  setup() {
    const router = useRouter();
    const store = useStore();
    /**
     * 电话登录
     */
    const loginInfo = reactive({
      tel: "",
      fulfill: false,
    });
    const submitTelFn = async () => {
      if (loginInfo.tel == "")
        return Message({ message: "请输入电话号码", type: "error" });

      // 电话校验
      const phone = /^[1][3,4,5,7,8][0-9]{9}$/;
      if (!phone.test(loginInfo.tel))
        return Message({ message: "手机号码不合法", type: "error" });
      if (!Config.CONFIG_APPID) {
        return Message({
          message: "请前往 config 文件中配置 CONFIG_APPID",
          type: "error",
        });
      }
      const { code, data } = await jpushExists({
        appId: Config.CONFIG_APPID,
        uId: loginInfo.tel,
      });
      if (code == 200) {
        // 用户信息本地永久保存
        localStorage.setItem(
          "ARcall_USERINFO",
          JSON.stringify({
            userId: data.uId,
            headerUrl: data.headerImg,
            userName: data.nickName,
          })
        );
        // 用户消息
        store.commit("addUserInfo", {
          userId: data.uId,
          headerUrl: data.headerImg,
          userName: data.nickName,
        });
        //  跳转至首页
        router.replace("/");
      } else {
        // 填写信息
        loginInfo.fulfill = true;
      }
    };

    /**
     * 信息完善
     */

    // 头像
    const avatar = ref("");
    const avatarFn = () => {
      avatar.value = RandomAvatar();
    };
    avatarFn();

    // 名称
    const name = ref("");
    const nameFn = () => {
      name.value = RandomName();
    };
    nameFn();

    // 完成
    const submitInfoFn = async () => {
      if (name.value == "")
        return Message({
          message: "请填写名称或随机生成一个名称",
          type: "error",
        });

      // 保存信息
      const { code, data } = await jpushInit({
        appId: Config.CONFIG_APPID,
        uId: loginInfo.tel,
        headerImg: avatar.value,
        nickName: name.value,
        device: getDevice(),
      });
      if (code == 200) {
        // 用户信息本地永久保存
        localStorage.setItem(
          "ARcall_USERINFO",
          JSON.stringify({
            userId: data.uId,
            headerUrl: data.headerImg,
            userName: data.nickName,
          })
        );
        //  跳转至首页
        router.replace("/");
      }
    };

    return {
      /** 电话登录 */
      loginInfo,
      submitTelFn,
      /** 完善信息 */

      // 头像
      avatar,
      avatarFn,
      // 名称
      name,
      nameFn,
      // 完成
      submitInfoFn,
    };
  },
});
</script>
