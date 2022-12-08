<!-- 通信首页 -->
<script lang="ts">
import { defineComponent } from "vue";
import { useRouter } from "vue-router";
import { useStore } from "vuex";
export default defineComponent({
  setup() {
    const router = useRouter();
    const store = useStore();
    
    // 跳转
    const goBackFn = (type: string, pattern: string) => {
      // 情景类型
      store.commit("updataPattern", pattern);
      // 情景模式
      store.commit("updataModel", type === "p2p" ? 1 : 0);
      router.replace(type === "p2p" ? "/p2p/send" : "/multi/send");
    };
    
    return {
      goBackFn,
    };
  },
});
</script>

<template>
  <div class="flex h-full justify-center items-center">
    <ul class="page">
      <li @click="goBackFn('p2p', 'audio')">
        <img src="@/assets/img/p2p_audio.png" draggable="false" alt="" />
        <div class="text-left">
          <h3 class="text-arcall-gray_1 text-sm font-bold mb-2">
            点对点音频呼叫
          </h3>
          <p class="text-xs text-arcall-gray_3">
            全频带音质，打造 CD 级音频通话盛宴
          </p>
        </div>
      </li>
      <li @click="goBackFn('p2p', 'video')">
        <img src="@/assets/img/p2p_video.png" draggable="false" alt="" />
        <div class="text-left">
          <h3 class="text-arcall-gray_1 text-sm font-bold mb-2">
            点对点视频呼叫
          </h3>
          <p class="text-xs text-arcall-gray_3">
            简单 3 步即可拥有音视频呼叫通话功能
          </p>
        </div>
      </li>
      <li @click="goBackFn('multi', 'audio')">
        <img src="@/assets/img/multi_audio.png" draggable="false" alt="" />
        <div class="text-left">
          <h3 class="text-arcall-gray_1 text-sm font-bold mb-2">
            多人音频呼叫
          </h3>
          <p class="text-xs text-arcall-gray_3">
            全频带音质，打造 CD 级音频通话盛宴
          </p>
        </div>
      </li>
      <li @click="goBackFn('multi', 'video')">
        <img src="@/assets/img/multi_video.png" draggable="false" alt="" />
        <div class="text-left">
          <h3 class="text-arcall-gray_1 text-sm font-bold mb-2">
            多人视频呼叫
          </h3>
          <p class="text-xs text-arcall-gray_3">
            简单 3 步即可拥有音视频呼叫通话功能
          </p>
        </div>
      </li>
    </ul>
  </div>
</template>
<style scoped>
.page {
  @apply border border-white rounded-2xl bg-white bg-opacity-20 px-28 py-16 flex flex-col  text-center space-y-6;
}
.page > li {
  @apply border border-arcall-gray_4 rounded-lg bg-arcall-gray_4 bg-opacity-50 p-6 flex items-center;
}
.page > li:hover {
  @apply border-arcall-blue_1 cursor-pointer shadow-arcall_1;
}
.page > li > img {
  @apply w-16 mr-4;
}
</style>
