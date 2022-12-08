<!-- 音频通话 -->
<template>
  <div class="flex h-full justify-center items-center">
    <div
      class="border border-white rounded-3xl bg-white bg-opacity-20 px-40 py-32"
    >
      <!-- 远端用户信息 -->
      <!-- 呼叫的用户信息 -->
      <div class="flex flex-col items-center mb-24">
        <!--  -->
        <img
          class="w-24 h-24 rounded-lg"
          :src="remoteInfo.headerUrl"
          draggable="false"
        />
        <!--  -->
        <div class="text-lg text-arcall-gray_1 font-bold mt-9 mb-2">
          {{ remoteInfo.userName }}
        </div>
      </div>

      <!-- 通话计时器 -->
      <div class="text-center mb-5 text-arcall-gray_3 text-xs font-extrabold">
        {{ callTime }}
      </div>

      <!-- 页面操作 -->
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
</template>

<script lang="ts">
import { hangup, setMicMute } from "@/arcall/calling";
import { defineComponent, ref, computed, onMounted } from "vue";
import { useStore } from "vuex";
export default defineComponent({
  setup() {
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
    /** 音频控制 */
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
      remoteInfo,
      callTime,
      localControl,
      operationFn,
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
