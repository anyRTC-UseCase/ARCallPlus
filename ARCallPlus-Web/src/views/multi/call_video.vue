<!-- 多人视频通话页面 -->
<template>
  <div class="h-full flex justify-center items-center">
    <!-- 生成页面 -->
    <div class="border border-white p-10 rounded-3xl bg-white bg-opacity-20">
      <div
        :class="[
          'grid gap-2',
          remoteInfo.length >= 2 ? 'grid-cols-3' : 'grid-cols-2',
        ]"
      >
        <!-- 本地自身 -->
        <div
          :id="'view_local' + userInfo.userId"
          class="w-40 h-32 lg:w-64 lg:h-48 xl:w-80 xl:h-60 relative border border-white"
        >
          <!-- 加载中 -->
          <div class="absolute inset-0 flex justify-center items-center">
            <img
              class="w-24 h-24 rounded"
              :src="userInfo.headerUrl"
              draggable="false"
              alt=""
            />

            <!-- <div
              class="absolute inset-0 bg-arcall-gray_4 bg-opacity-60 flex justify-center items-center"
            >
              <img
                class="w-10 h-10 animate-spin"
                src="@/assets/img/loading.png"
                draggable="false"
                alt=""
              />
            </div> -->
          </div>
          <!-- 用户信息 -->
          <div class="absolute bottom-2 left-0 px-2 z-50 flex items-end">
            <img
              v-show="!localControl.controlaudio"
              class="w-5 h-5 mr-1"
              src="@/assets/img/hasAudio.png"
              alt=""
            />

            <span
              :class="[
                'text-xs font-bold ',
                localControl.controlvideo ? 'text-white' : 'text-arcall-gray_1',
              ]"
            >
              {{ userInfo.userName }}
            </span>
          </div>
          <!-- 音量展示 -->
          <Volume :level="userInfo.level" />
        </div>
        <!-- 远端用户 -->
        <div
          v-for="remote in remoteInfo"
          :key="remote.userId + '+++'"
          :id="'view_remote' + remote.userId"
          class="relative w-40 h-32 lg:w-64 lg:h-48 xl:w-80 xl:h-60 border border-white flex justify-center items-center"
        >
          <!-- h-60 w-80 -->
          <img
            class="absolute w-24 h-24 rounded"
            :src="remote.headerUrl"
            draggable="false"
            alt=""
          />
          <!-- 加载中 -->
          <div
            v-if="remote.loading"
            class="absolute inset-0 bg-arcall-gray_4 bg-opacity-60 flex justify-center items-center"
          >
            <img
              class="w-10 h-10 animate-spin"
              src="@/assets/img/loading.png"
              draggable="false"
              alt=""
            />
          </div>
          <!-- 用户信息 -->
          <div class="absolute bottom-2 left-0 px-2 z-50 flex items-end">
            <img
              v-show="!remote.hasAudio"
              class="w-5 h-5 mr-1"
              src="@/assets/img/hasAudio.png"
              alt=""
              draggable="false"
            />
            <span
              :class="[
                'text-xs font-bold ',
                remote.hasVideo ? ' text-white' : 'text-arcall-gray_1',
              ]"
            >
              {{ remote.userName }}
            </span>
          </div>
          <!-- 音量展示 -->
          <Volume :level="remote.level" />
        </div>
      </div>
      <!-- 操作 -->
      <div class="mt-8 flex flex-col items-center">
        <div class="text-arcall-gray_5 text-lg font-bold mb-4">
          {{ callTime }}
        </div>
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

          <!-- <img
            @click="operationFn('转换')"
            src="@/assets/img/switch.png"
            draggable="false"
            alt="切换为语音通话"
            title="切换为语音通话"
          /> -->
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import {
  hangup,
  setCameraEnable,
  setMicMute,
  startView,
  // switchToAudioCall,
} from "@/arcall/calling";
import { defineComponent, reactive, ref, computed, onMounted } from "vue";
import { useStore } from "vuex";
import Volume from "@/components/volume.vue";
export default defineComponent({
  setup() {
    const store = useStore();
    // 本地用户信息
    const userInfo = ref(
      computed(() => {
        return store.state.userInfo;
      })
    );
    // 远端用户信息列表
    const remoteInfo = ref(
      computed(() => {
        return store.state.multiRemoteInfoList;
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
     * 本地视频渲染
     */
    onMounted(async () => {
      console.log("多人本地视频渲染");
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
        // 暂不支持
        // case "转换":
        //   switchToAudioCall();
        //   router.replace("/multi/call_audio");
        //   break;
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
    return {
      userInfo,
      remoteInfo,
      // 操作
      localControl,
      operationFn,
      callTime,
    };
  },
  components: { Volume },
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
