<!-- 头部组件 -->
<template>
  <div class="flex h-full flex-col min-w-752 basics_scrollbar">
    <div class="flex mt-10 justify-center">
      <div
        class="flex items-center border border-white bg-arcall-gray_4 bg-opacity-30 rounded-2xl px-5 py-3"
      >
        <!-- anyRTC图标 -->
        <div
          class="flex items-center text-lg font-extrabold bg-white bg-opacity-50 rounded-lg py-2 pl-2 pr-4"
        >
          <img
            class="w-8 h-8"
            src="@/assets/img/logo.png"
            draggable="false"
            alt=""
          />
          <h1 class="text-arcall-gray_5 ml-4">ARCall Plus 互动体验</h1>
        </div>

        <!-- 用户信息 -->
        <div class="flex items-center ml-64">
          <div class="flex flex-col text-right font-bold text-arcall-gray_3">
            <span class=" text-lg">{{ userInfo.userName }}</span>
            <span class=" text-xs">{{ userInfo.userId }}</span>
          </div>
          <img
            class="w-16 h-16 ml-3 rounded-lg border border-white"
            :src="userInfo.headerUrl"
            draggable="false"
            alt=""
          />
        </div>
      </div>
    </div>

    <div class="flex-1">
      <router-view></router-view>
    </div>
  </div>
</template>

<script lang="ts">
import { useStore } from "vuex";
import { defineComponent, reactive, ref, computed } from "vue";
export default defineComponent({
  setup() {
    const store = useStore();
    // 用户信息
    const userInfo = ref(
      computed(() => {
        return store.state.userInfo;
      })
    );
    // const userInfo = ref({
    //   tel: "",
    //   name: "",
    //   avatarImg: "",
    // });
    // const localInfo = localStorage.getItem("ARcall_USERINFO");
    // if (localInfo) {
    //   userInfo.value = JSON.parse(localInfo);
    // }
    return {
      userInfo,
    };
  },
});
</script>
