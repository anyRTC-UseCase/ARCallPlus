<!-- 多人音频通话页面 -->
<template>
  <div class="h-full flex justify-center items-center">
    <div class="border border-white p-10 rounded-3xl bg-white bg-opacity-20">
      <div
        :class="[
          'grid gap-0.5',
          remoteInfo.length >= 2 ? 'grid-cols-3' : 'grid-cols-2',
        ]"
      >
        <!-- 自身信息 -->
        <div class="w-32 h-32 relative">
          <img
            class="w-full h-full"
            :src="userInfo.headerUrl"
            draggable="false"
            alt=""
          />
          <!-- 用户信息 -->
          <div class="absolute bottom-2 left-0 px-2 z-50 flex items-end">
            <img v-show="!localControl" class="w-5 h-5 mr-1" src="@/assets/img/hasAudio.png" alt="" draggable="false"/>
            <span class="text-xs font-bold text-arcall-gray_1">
              {{ userInfo.userName }}
            </span>
          </div>
          <!-- 音量展示 -->
          <Volume :level="userInfo.level" />
        </div>
        <!-- 远端信息 -->
        <div
          v-for="remote in remoteInfo"
          :key="remote.userId + '+++'"
          class="w-32 h-32 relative"
        >
          <img
            class="w-full h-full"
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
            <img v-show="!remote.hasAudio" class="w-5 h-5 mr-1" src="@/assets/img/hasAudio.png" alt="" draggable="false"/>
            <span class="text-xs font-bold text-arcall-gray_1">
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
            v-if="localControl"
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
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { hangup, setMicMute } from "@/arcall/calling";
import { computed, defineComponent, onMounted, ref } from "vue";
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
    // 开启计时
    onMounted(() => {
      // 开始计时
      // store.commit("controlCallTime", true);
    });
    /** 操作 */
    const localControl = ref(true);
    const operationFn = (type: string) => {
      switch (type) {
        case "音频":
          localControl.value = !localControl.value;
          setMicMute(localControl.value);
          break;
        case "挂断":
          hangup();
          break;
        default:
          break;
      }
    };
    return {
      userInfo,
      remoteInfo,
      callTime,
      // 操作
      localControl,
      operationFn,
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
