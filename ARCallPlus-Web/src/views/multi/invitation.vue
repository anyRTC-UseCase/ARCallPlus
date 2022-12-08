<!-- 呼叫邀请页面 -->
<template>
  <div class="h-full flex justify-center items-center">
    <div
      class="border border-white rounded-3xl bg-white bg-opacity-20 px-40 py-32"
    >
      <!-- 主叫的用户信息 -->
      <div
        v-if="userListInfo.dialingInfo"
        :class="[
          'flex flex-col items-center',
          userListInfo.memberInfo.length == 0 ? 'mb-24' : '',
        ]"
      >
        <!--  -->
        <img
          class="w-28 h-28 rounded-lg"
          :src="userListInfo.dialingInfo.headerUrl"
          draggable="false"
        />
        <!--  -->
        <div class="text-lg text-arcall-gray_1 font-bold mt-6 mb-2">
          {{ userListInfo.dialingInfo.userName }}
        </div>
        <p class="text-xs text-arcall-gray_3">
          邀请你{{ callPattern == "audio" ? "音频" : "视频" }}通话
        </p>
      </div>

      <!-- 频道内其他人员信息 -->
      <div
        v-if="userListInfo.memberInfo.length > 0"
        class="border mt-12 mb-7 border-white rounded-2xl bg-arcall-gray_4 text-center p-3.5 max-w-176"
      >
        <span class="text-xs font-bold text-arcall-gray_3">他们也在</span>
        <div class="subjoin">
          <img
            v-for="(member, index) in userListInfo.memberInfo"
            :key="index + '--'"
            :src="member.headerUrl"
            alt=""
          />
        </div>
      </div>

      <!-- 主叫操作 -->
      <div class="flex justify-center">
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
</template>

<script lang="ts">
import { acceptCall, rejectCall } from "@/arcall/calling";
import { computed, defineComponent, ref } from "vue";
import { useRouter } from "vue-router";
import { useStore } from "vuex";
export default defineComponent({
  setup() {
    const router = useRouter();
    const store = useStore();
    const userListInfo = ref(
      computed(() => {
        const userInfo = store.state.multiRemoteInfoList;
        return {
          // 主叫信息
          dialingInfo: userInfo[0],
          // 成员信息
          memberInfo: userInfo.slice(1, userInfo.length),
        };
      })
    );

    /** 情景模式 */
    const callPattern = ref(
      computed(() => {
        return store.state.pattern;
      })
    );
    // 操作
    const operationFn = async (type: string) => {
      switch (type) {
        case "接听":
          // 一段时间后无响应
          store.commit("noResponseMultiRemoteInfoList", true);
          await acceptCall();

          router.replace(
            callPattern.value == "audio"
              ? "/multi/call_audio"
              : "/multi/call_video"
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
      callPattern,
      userListInfo,
      operationFn,
    };
  },
});
</script>

<style scoped>
.subjoin {
  /* @apply grid gap-1 grid-cols-4; */
  @apply flex flex-wrap space-x-1 justify-center mt-2;
}
.subjoin > img {
  @apply w-8 h-8 rounded mb-1;
}
</style>
