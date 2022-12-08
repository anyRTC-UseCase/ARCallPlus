import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import * as path from "path";
// https://vitejs.dev/config/
export default defineConfig({
  base: "/arcall-plus/",
  // 配置@解析地址
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
    // extensions: [".js", ".json", ".ts"], // 使用路径别名时想要省略的后缀名，可以自己 增减
  },
  plugins: [vue()],
  server: {
    // open: false, //自动打开
    base: "./ ", //生产环境路径
    proxy: {
      // 本地开发环境通过代理实现跨域，生产环境使用 nginx 转发
      // 正则表达式写法
      "^/api": {
        target: "https://pro.gateway.agrtc.cn", // 后端服务实际地址
        changeOrigin: true, //开启代理
        rewrite: (path) => path.replace(/^\/api/, ""),
      },
    },
    cors: true,
  },
});
