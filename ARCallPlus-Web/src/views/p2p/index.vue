<!-- 点对点语音-发起呼叫 -->
<template>
  <div class="flex h-full justify-center items-center">
    <div
      class="border border-white bg-white bg-opacity-20 rounded-3xl p-10 flex flex-col"
    >
      <div class="flex items-center mb-6">
        <router-link to="/">
          <img
            class="w-6"
            src="@/assets/img/go_back.png"
            draggable="false"
            alt=""
          />
        </router-link>

        <h2 class="text-lg font-extrabold text-arcall-gray_1 ml-2">
          点对点{{ callPattern === "audio" ? "音频" : "视频" }}呼叫
        </h2>
      </div>

      <recent-list
        recent-pattern="radio"
        :sequence-changes="sequenceChanges"
        @change="recentlyContactFn"
      />
      <!-- 发起呼叫 -->
      <div class="text-center mt-6">
        <button
          @click="sendCallFn"
          :class="[
            'basics_button w-40 ',
            sendCallInfo
              ? 'shadow-arcall_2'
              : 'basics_button_disabled shadow-arcall_3',
          ]"
        >
          发起呼叫
        </button>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref, computed } from "vue";
import RecentList from "@/components/recent-list.vue";
import {useRouter } from "vue-router";
import { useStore } from "vuex";
// 获取呼叫用户信息
import { getInformationLimits } from "@/assets/untils/until";
// ar-call
import { makeP2PCall } from "@/arcall/calling";
import Message from "@/assets/untils/message";
export default defineComponent({
  components: { RecentList },
  setup() {
    const router = useRouter();
    const store = useStore();
    // 当前通话模式
    const callPattern = ref(
      computed(() => {
        return store.state.pattern;
      })
    );

    /**
     * 最近联系人相关
     */
    // 最近联系人返回值
    const recentlyContactFn = (data: string) => {
      if (sendCallInfo.value != data) {
        sendCallInfo.value = data;
        sequenceChanges.value = "";
      }
    };

    /**
     * 发起呼叫
     */
    // 呼叫人员信息
    const sendCallInfo = ref<string | Array<string>>("");
    // 序列变更
    const sequenceChanges = ref<string | Array<string>>("");
    const sendCallFn = async () => {
      if (!sendCallInfo.value) {
        return Message({ message: "请选择呼叫用户", type: "error" });
      }
      // 获取呼叫的用户信息
      const oInfo = await getInformationLimits(sendCallInfo.value);
     
      if (oInfo) {
        store.commit("addP2PRemoteInfo", oInfo[0]);

        await makeP2PCall(oInfo[0], callPattern.value === "audio" ? 1 : 0);
      }
      // 跳转至主叫呼叫页面
      router.replace({
        path: "/p2p/local",
      });
      // 引发序列变更
      sequenceChanges.value = sendCallInfo.value;
    };

    return {
      // 通话模式
      callPattern,

      // 最近联系人
      recentlyContactFn,

      // 发起呼叫
      sendCallInfo,
      sequenceChanges,
      sendCallFn,
    };
  },
});
</script>
