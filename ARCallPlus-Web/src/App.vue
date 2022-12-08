<script lang="ts">
// 获取登录用户信息
import { getUserInfo } from "@/assets/untils/until";
import { initCallClient, loginArcallPlus, refreshBash } from "@/arcall/calling";

import { defineComponent, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useStore } from "vuex";
export default defineComponent({
  setup() {
    const route = useRoute();
    const router = useRouter();
    const store = useStore();

    const initFn = async () => {
      // 登录 arcall
      const userInfo = await getUserInfo();
      if (userInfo) {
        // 用户消息
        store.commit("addUserInfo", userInfo);
        // 初始化
        await initCallClient();
        if (!store.state.isLogin) {
          // 登录 arcall 系统
          store.commit("updataIsLoginStatus", true);
          await loginArcallPlus(userInfo);
        }
      }
    };
    watch(
      () => route.path,
      async (newRoute) => {
        if (!refreshBash()) {
          await initFn();
          // 跳转至 首页
          router.replace("/");
        } else {
          // 通过本地状态判断是否需要继续登录(同一时间仅能登录一端)
          if (!store.state.isLogin && newRoute != "/login") {
            store.commit("updataIsLoginStatus", true);
            // 登录 arcall 系统
            await loginArcallPlus(store.state.userInfo);
          }
        }
      },
      {
        immediate: true,
      }
    );
  },
});
</script>

<template>
  <router-view></router-view>
</template>

<style>
html,
body,
#app {
  background-image: url("@/assets/img/bg.png");
  @apply h-full bg-cover bg-no-repeat;
}
</style>
