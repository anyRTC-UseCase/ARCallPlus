<!-- 视频通话 -->
<template>
  <div class="h-full flex justify-center items-center p-7">
    <div class="relative w-10/12 h-full">
      <!-- 远端视频 -->
      <div class="flex-1 h-full bg-black bg-opacity-50">
        <!-- 视频容器 -->
        <div :id="'view_remote' + remoteInfo.userId" class="h-full"></div>
      </div>
      <!-- 本地视频 4:3-->
      <div
        class="absolute top-6 left-6 bg-black bg-opacity-50 rounded w-1/4 h-1/3 cursor-pointer"
        @click="CapsLockFn"
      >
        <!-- 视频容器 -->
        <div
          :id="'view_local' + userInfo.userId"
          class="h-full rounded-3xl"
        ></div>
      </div>

      <!-- 相关操作 -->
      <div class="absolute bottom-12 w-full flex flex-col items-center">
        <!-- 通话计时器 -->
        <p class="text-center mb-5 text-white text-lg font-extrabold">
          {{ callTime }}
        </p>
        <div class="operation">
          <img
            v-if="localControl.controlaudio"
            @click="operationFn('音频')"
            src="@/assets/img/audio_open.png"
            draggable="false"
            alt="音频"
            title="音频"
          />
          <img
            v-else
            @click="operationFn('音频')"
            src="@/assets/img/audio_close.png"
            draggable="false"
            alt="音频"
            title="音频"
          />

          <img
            @click="operationFn('挂断')"
            src="@/assets/img/gua.png"
            draggable="false"
            alt="挂断"
            title="挂断"
          />
          <img
            v-if="localControl.controlvideo"
            @click="operationFn('视频')"
            src="@/assets/img/video_open.png"
            draggable="false"
            alt="视频"
            title="视频"
          />
          <img
            v-else
            @click="operationFn('视频')"
            src="@/assets/img/video_close.png"
            draggable="false"
            alt="视频"
            title="视频"
          />

          <img
            @click="operationFn('转换')"
            src="@/assets/img/switch.png"
            draggable="false"
            alt="切换为语音通话"
            title="切换为语音通话"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import {
  startView,
  stopView,
  hangup,
  switchToAudioCall,
  setMicMute,
  setCameraEnable,
} from "@/arcall/calling";
import { defineComponent, onMounted, reactive, ref, computed } from "vue";
import { useRouter } from "vue-router";
import { useStore } from "vuex";
export default defineComponent({
  setup() {
    const router = useRouter();
    const store = useStore();
    /**
     * 远端用户信息
     */
    const remoteInfo = ref(
      computed(() => {
        return store.state.p2pRemoteInfo;
      })
    );

    /**
     * 本地用户信息
     */
    const userInfo = ref(
      computed(() => {
        return store.state.userInfo;
      })
    );

    /**
     * 通话计时
     */
    const callTime = ref(
      computed(() => {
        return store.state.callTime;
      })
    );
    /**
     * 视频渲染
     */
    onMounted(async () => {
      console.log("p2p视频渲染");

      // 本地
      await startView(
        {
          userId: userInfo.value.userId,
          viewDomId: "view_local" + userInfo.value.userId,
        },
        "本地视图"
      );
      // 开始计时
      // store.commit("controlCallTime", true);
    });

    /**
     * 相关操作
     */
    const localControl = reactive({
      // 音频开关
      controlvideo: true,
      // 视频开关
      controlaudio: true,
    });
    const operationFn = (type: string) => {
      switch (type) {
        case "转换":
          switchToAudioCall();
          router.replace("/p2p/call_audio");
          break;
        case "音频":
          localControl.controlaudio = !localControl.controlaudio;
          setMicMute(localControl.controlaudio);
          break;
        case "挂断":
          hangup();
          break;
        case "视频":
          localControl.controlvideo = !localControl.controlvideo;
          setCameraEnable(localControl.controlvideo);
          if (localControl.controlvideo) {
            // 本地
            startView(
              {
                userId: userInfo.value.userId,
                viewDomId: "view_local" + userInfo.value.userId,
              },
              "本地视图"
            );
          }
          break;
        default:
          break;
      }
    };

    /**
     * 大小屏切换
     * 默认本地小屏远端大屏
     */
    const cut = ref(false);
    const CapsLockFn = async () => {
      cut.value = !cut.value;
      // 停止所有预览
      await stopView("本地视图");
      await stopView("远端视图", remoteInfo.value.userId);
      // 本地用户预览
      await startView(
        {
          userId: userInfo.value.userId,
          viewDomId: cut.value
            ? "view_remote" + remoteInfo.value.userId
            : "view_local" + userInfo.value.userId,
        },
        "本地视图"
      );
      // 远端用户预览
      await startView(
        {
          userId: remoteInfo.value.userId,
          viewDomId: cut.value
            ? "view_local" + userInfo.value.userId
            : "view_remote" + remoteInfo.value.userId,
          // lowStream: cut.value,
        },
        "远端视图"
      );
    };
    return {
      userInfo,
      remoteInfo,

      localControl,
      operationFn,

      // 通话计时
      callTime,

      // 大小屏切换
      CapsLockFn,
    };
  },
});
</script>
<style scoped>
.operation {
  @apply flex items-center space-x-6;
}
.operation > img {
  @apply w-16 h-16 cursor-pointer;
}
</style>
