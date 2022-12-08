<!-- 主叫-呼叫邀请 -->
<template>
  <div class="h-full flex justify-center items-center">
    <div
      class="border border-white rounded-3xl bg-white bg-opacity-20 px-40 py-32"
    >
      <!-- 呼叫的用户信息 -->
      <div class="text-center mb-24">
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
        <p class="text-xs text-arcall-gray_3">等待对方接受</p>
      </div>

      <!-- 主叫操作 -->
      <div class="flex justify-center">
        <img
          @click="cancelCallFn"
          class="w-16 h-16 cursor-pointer"
          src="@/assets/img/gua.png"
          draggable="false"
          alt="取消呼叫"
          title="取消呼叫"
        />
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { hangup } from "@/arcall/calling";
import { defineComponent, ref, computed } from "vue";
import { useStore } from "vuex";
export default defineComponent({
  setup() {

    const store = useStore();
    /**
     * 获取呼叫用户信息
     */
    const callUserInfo = ref(
      computed(() => {
        return store.state.p2pRemoteInfo;
      })
    );

    /**
     * 取消呼叫
     */
    const cancelCallFn = () => {
      hangup();
    };

    return {
      callUserInfo,
      cancelCallFn,
    };
  },
});
</script>
