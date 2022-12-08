<!-- 说话音量效果 -->
<script lang="ts">
import { defineComponent } from "vue";
export default defineComponent({
  props: {
    level: {
      type: Number,
      default: 0,
    },
  },
});
</script>
<template>
  <div class="h-1 bg-transparent absolute bottom-0 w-full z-50">
    <!-- 音量展示 -->
    <div
      class="absolute h-1 bg-arcall-green_1"
      :style="{ width: level + '%' }"
    ></div>
  </div>
</template>

