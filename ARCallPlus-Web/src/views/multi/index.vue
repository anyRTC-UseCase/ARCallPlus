<!--  -->
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
          多人{{ callPattern === "audio" ? "音频" : "视频" }}呼叫
        </h2>
      </div>
      <!-- 标签 -->
      <recent-list
        recent-pattern="checkbox"
        :sequence-changes="sequenceChanges"
        @change="recentlyContactFn"
      />

      <!-- 发起呼叫 -->
      <div class="text-center mt-6">
        <button
          @click="sendCallFn"
          :class="[
            'basics_button w-40 ',
            sendCallInfo.length > 0
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
import { useRouter } from "vue-router";
import { makeMultiCall } from "@/arcall/calling";
import { getInformationLimits } from "@/assets/untils/until";
import { useStore } from "vuex";
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

    // 最近联系人
    const recentlyContactFn = (data: string[]) => {
      if (data.length > 0) {
        sendCallInfo.value = data;
      }
      sequenceChanges.value = "";
    };

    // 呼叫人员信息
    const sendCallInfo = ref<Array<string>>([]);
    // 序列变更
    const sequenceChanges = ref<any>([]);
    const sendCallFn = async () => {
      if (sendCallInfo.value.length == 0)
        return Message({ message: "请选择呼叫用户", type: "error" });
      if (sendCallInfo.value.length > 8)
        return Message({ message: "最大选择8人", type: "error" });

      // 获取呼叫的用户信息
      const oInfo = await getInformationLimits(sendCallInfo.value);
      if (oInfo) {
        // 设置远端用户信息列表
        store.commit("addMultiRemoteInfoList", oInfo);

        await makeMultiCall(oInfo, callPattern.value === "audio" ? 1 : 0);
      }
      // 跳转至通话页面
      router.replace(
        callPattern.value === "audio"
          ? "/multi/call_audio"
          : "/multi/call_video"
      );
      // 引发序列变更
      sequenceChanges.value = sendCallInfo.value;
    };
    return {
      // 通话模式
      callPattern,

      recentlyContactFn,

      // 发起呼叫
      sendCallInfo,
      sequenceChanges,
      sendCallFn,
    };
  },
});
</script>
