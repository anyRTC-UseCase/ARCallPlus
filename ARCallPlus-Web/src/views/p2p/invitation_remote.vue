<!-- 被叫-呼叫邀请 -->
<template>
  <div class="h-full flex justify-center items-center">
    <div
      class="border border-white rounded-3xl bg-white bg-opacity-20 px-40 py-32"
    >
      <!-- 主叫的用户信息 -->
      <div class="flex flex-col items-center mb-24">
        <!--  -->
        <img
          class="w-24 h-24 rounded-lg"
          :src="callUserInfo.headerUrl"
          draggable="false"
        />
        <!--  -->
        <div class="text-lg text-arcall-gray_1 font-bold mt-9 mb-2">
          {{ callUserInfo.userName }}
        </div>
        <p class="text-xs text-arcall-gray_3">
          邀请你 {{ callPattern == "audio" ? "音频" : "视频" }}通话
        </p>
      </div>

      <!-- 主叫操作 -->
      <div class="flex flex-col justify-center items-center">
        <!-- 视频呼叫情况下显示 -->
        <div class="mb-6" v-show="callPattern === 'video'">
          <img
            @click="operationFn('切换')"
            class="w-16 h-16 cursor-pointer"
            src="@/assets/img/switch.png"
            draggable="false"
            alt="切换为语音通话"
            title="切换为语音通话"
          />
        </div>
        <div class="flex">
          <img
            @click="operationFn('接听')"
            class="w-16 h-16 cursor-pointer mr-8"
            src="@/assets/img/accept.png"
            draggable="false"
            alt="接听"
            title="接听"
          />
          <img
            @click="operationFn('挂断')"
            class="w-16 h-16 cursor-pointer"
            src="@/assets/img/gua.png"
            draggable="false"
            alt="挂断"
            title="挂断"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { acceptCall, rejectCall, switchToAudioCall } from "@/arcall/calling";
import { useRouter } from "vue-router";
import { useStore } from "vuex";
import { defineComponent, ref, computed } from "vue";
export default defineComponent({
  setup() {
    const router = useRouter();
    const store = useStore();

    /** 获取主叫用户信息 */
    const callUserInfo = ref(
      computed(() => {
        return store.state.p2pRemoteInfo;
      })
    );

    /** 情景模式 */
    const callPattern = ref(
      computed(() => {
        return store.state.pattern;
      })
    );

    // 被叫操作
    const operationFn = async (type: string) => {
      switch (type) {
        case "切换":
          await switchToAudioCall();
          await acceptCall();
          // 进入语音通话页面
          router.replace("/p2p/call_audio");
          break;
        case "接听":
          // 进入对应的通话页面

          await acceptCall();
          router.replace(
            "/p2p/" +
              (callPattern.value === "video" ? "call_video" : "call_audio")
          );
          break;
        case "挂断":
          rejectCall();
          break;
        default:
          break;
      }
    };

    return {
      // 通话模式
      callPattern,
      callUserInfo,
      operationFn,
    };
  },
});
</script>

<style scoped></style>
