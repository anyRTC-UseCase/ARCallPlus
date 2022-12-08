<!-- 最近联系人列表 -->
<template>
  <!-- 标签 -->
  <div class="flex px-16 mb-6">
    <div class="relative">
      <input
        v-model="tel"
        class="h-10 rounded placeholder-arcall-gray_2 bg-white outline-none border border-transparent focus:border-blue-500 text-sm w-60 px-8"
        placeholder="添加呼叫人电话"
        type="text"
      />
      <img
        class="absolute left-3 top-1/2 -mt-1.5 w-3 h-3"
        src="@/assets/img/search.png"
        draggable="false"
        alt=""
      />
    </div>

    <button
      @click="searchTelFn"
      class="ml-4 py-2.5 px-7 rounded bg-arcall-blue_1 text-white text-sm"
    >
      添加
    </button>
  </div>
  <div class="px-16">
    <div class="flex justify-between items-center mb-4">
      <h3
        class="border-l-4 border-arcall-blue_1 pl-2 text-sm font-bold text-arcall-gray_5"
      >
        最近联系人
      </h3>
      <div class="text-xs text-arcall-gray_7">
        已选择
        <span v-if="recentPattern === 'radio'">
          {{ recentInfo.radioValue ? 1 : 0 }}
        </span>
        <span v-else> {{ recentInfo.checkedValue.length }} </span>
        /
        {{ recentInfo.infoList.length }}
      </div>
    </div>

    <!-- p2p 单选 -->
    <ul
      v-if="recentInfo.infoList.length > 0"
      ref="contactListRef"
      class="basics_scrollbar page_list"
    >
      <li v-for="info in recentInfo.infoList" :key="info.userId + '++'">
        <label class="flex flex-1 items-center" :for="'id' + info.userId">
          <img
            class="w-10 h-10 rounded border border-arcall-gray_4"
            :src="info.headerUrl"
            draggable="false"
            alt=""
          />
          <div class="flex h-full flex-col ml-2 text-xs text-arcall-gray_3">
            <span class="font-bold mb-0.5">{{ info.userName }}</span>
            <span>{{ info.userId }}</span>
          </div>
        </label>
        <!-- 单选 -->
        <input
          v-if="recentPattern === 'radio'"
          type="radio"
          v-model="recentInfo.radioValue"
          :value="info.userId"
          :id="'id' + info.userId"
        />
        <!-- 多选 -->
        <input
          v-else
          type="checkbox"
          v-model="recentInfo.checkedValue"
          checked
          :value="info.userId"
          :id="'id' + info.userId"
        />
      </li>
    </ul>

    <!-- 暂无联系人 -->
    <div v-else class="text-center p-7 text-arcall-gray_7">
      <span>暂无联系人,请添加联系人</span>
    </div>
  </div>
</template>

<script lang="ts">
// 接口
import { jpushGetUserInfo } from "@/api/index";
import {
  defineComponent,
  reactive,
  ref,
  onMounted,
  watchSyncEffect,
  nextTick,
} from "vue";
import { getInformationLimits, getUserInfo } from "@/assets/untils/until";
import Message from "@/assets/untils/message";
export default defineComponent({
  props: {
    // 类型选择
    recentPattern: {
      type: String,
      default: "",
    },
    // 序列变更
    sequenceChanges: {
      type: null,
      default: () => {
        return "";
      },
    },
  },
  // 声明传递父组件
  emits: ["change"],
  setup(props, { emit }) {
    /**
     * 搜索相关
     */
    const tel = ref("");
    const contactListRef = ref<any>(null);
    const searchTelFn = async () => {
      if (tel.value == "")
        return Message({ message: "请输入电话号码", type: "error" });
      // 电话校验
      const phone = /^[1][3,4,5,7,8][0-9]{9}$/;
      if (!phone.test(tel.value))
        return Message({ message: "手机号码不合法", type: "error" });

      // 禁止呼叫自己
      const userInfo = await getUserInfo();
      if (userInfo) {
        if (tel.value == userInfo.userId)
          return Message({ message: "不能填写自己的手机", type: "error" });
      }

      // 获取用户信息
      const { code, data } = await jpushGetUserInfo({ uId: tel.value });
      if (code == 200) {
        if (contactListRef.value) {
          contactListRef.value.scrollTop = 0;
        }
        // 修改联系人列表
        await getLocalInfo({
          headerUrl: data.headerImg,
          userId: data.uId,
          userName: data.nickName,
          customData: "",
        });

        // 选中
        nextTick(() => {
          if (props.recentPattern == "radio") {
            if (recentInfo.radioValue != data.uId) {
              recentInfo.radioValue = data.uId;
            }
          } else {
            const oIs = recentInfo.checkedValue.some((item: string) => {
              return item == data.uId;
            });
            !oIs && recentInfo.checkedValue.push(data.uId);
          }
        });
      } else if (code != 401) {
        return Message({ message: "搜索出错", type: "error" });
      }
    };

    /**
     * 最近联系人相关
     */
    const recentInfo: any = reactive({
      // 选中的单选信息
      radioValue: "",
      // 选中的多选信息
      checkedValue: [],
      // 信息列表
      infoList: [],
    });

    // 本地存储信息变更
    const getLocalInfo = async (remoteInfo: {
      headerUrl?: string;
      userId: string;
      userName?: string;
      customData?: string;
    }) => {
      const oInfo = localStorage.getItem("AECALL_LOCALSTORAGEINFORMATION");

      if (oInfo) {
        const oList = JSON.parse(oInfo);

        const oM = oList.filter((item: { userId: string }) => {
          return item.userId !== remoteInfo.userId;
        });
        // 对应的用户信息
        const userInfo = await getInformationLimits(remoteInfo.userId);
        // 添加到第一个位置
        oM.unshift(userInfo ? userInfo[0] : remoteInfo);

        recentInfo.infoList = oM;

        // 本地记录更新
        localStorage.setItem(
          "AECALL_LOCALSTORAGEINFORMATION",
          oM.length > 0 ? JSON.stringify(oM) : ""
        );
      } else {
        recentInfo.infoList.push(remoteInfo);
        // 本地存储
        localStorage.setItem(
          "AECALL_LOCALSTORAGEINFORMATION",
          JSON.stringify([remoteInfo])
        );
      }
      return;
    };

    // 存储信息变更
    watchSyncEffect(() => {
      tel.value = "";
      // 单选变更
      if (recentInfo.radioValue && props.recentPattern == "radio") {
        if (props.sequenceChanges && typeof props.sequenceChanges == "string") {
          // 序列发生变更(添加至第一个)
          recentInfo.radioValue = "";
          getLocalInfo({ userId: props.sequenceChanges });
        }
        emit("change", recentInfo.radioValue);
      }
      // 多选变更
      if (recentInfo.checkedValue && props.recentPattern == "checkbox") {
        if (
          typeof props.sequenceChanges == "object" &&
          props.sequenceChanges.length > 0
        ) {
          props.sequenceChanges.forEach((item: string) => {
            recentInfo.checkedValue = [];
            // 序列发生变更(添加至第一个)
            getLocalInfo({ userId: item });
          });
        }
        if (recentInfo.checkedValue.length > 8) {
          Message({ message: "最大选择 8 人", type: "error" });
          recentInfo.checkedValue = recentInfo.checkedValue.slice(0, 8);
        }

        emit("change", recentInfo.checkedValue);
      }
    });

    onMounted(async () => {
      const oInfo = localStorage.getItem("AECALL_LOCALSTORAGEINFORMATION");
      if (oInfo) {
        const oM = JSON.parse(oInfo);
        // 当前登录用户
        const userInfo = await getUserInfo();
        // 在当前记录的信息中去除当前登录信息
        recentInfo.infoList = oM.filter((item: { userId: string }) => {
          return item.userId !== userInfo.userId;
        });
      }
    });

    return {
      // 搜索
      tel,
      contactListRef,
      searchTelFn,
      // 最近联系人相关
      recentInfo,
    };
  },
});
</script>

<style scoped>
.page_list {
  @apply border rounded-xl border-white divide-y divide-arcall-gray_6 overflow-y-auto bg-arcall-gray_4 max-h-80;
}
.page_list > li {
  @apply flex items-center justify-between p-4;
}
</style>
