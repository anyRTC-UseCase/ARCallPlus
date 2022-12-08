// 从 VueRouter 中导入需要的函数模块
import { createRouter, createWebHistory, RouteRecordRaw } from "vue-router";
// 头部模板
import Header from "@/components/header.vue";
// 导入 HelloWorld.vue 组件
const routes: Array<RouteRecordRaw> = [
  // 登录页面
  {
    path: "/login",
    component: () => import("@/views/login.vue"),
  },
  // 首页
  {
    path: "/",
    // 引入外部模板
    component: Header,
    children: [
      {
        path: "",
        component: () => import("@/views/index.vue"),
      },
    ],
  },
  // 点对点
  {
    path: "/p2p",
    // 引入外部模板
    component: Header,
    children: [
      // 发起呼叫页面
      {
        path: "send",
        component: () => import("@/views/p2p/index.vue"),
      },
      // 主叫-呼叫邀请页面
      {
        path: "local",
        name: "p2pLocal",
        component: () => import("@/views/p2p/invitation_local.vue"),
      },
      // 被叫-呼叫邀请页面
      {
        path: "remote",
        name: "p2pRemote",
        component: () => import("@/views/p2p/invitation_remote.vue"),
      },
      // 语音通话
      {
        path: "call_audio",
        name: "p2pCallAudio",
        component: () => import("@/views/p2p/call_audio.vue"),
      },
      // 视频通话
      {
        path: "call_video",
        name: "p2pCallVidio",
        component: () => import("@/views/p2p/call_video.vue"),
      },
    ],
  },
  // 多对多
  {
    path: "/multi",
    // 引入外部模板
    component: Header,
    children: [
      // 发起呼叫页面
      {
        path: "send",
        component: () => import("@/views/multi/index.vue"),
      },
      // 被叫-呼叫邀请页面
      {
        path: "remote",
        name: "multiRemote",
        component: () => import("@/views/multi/invitation.vue"),
      },
      // 多人音频通话
      {
        path: "call_audio",
        component: () => import("@/views/multi/call_audio.vue"),
      },
      // 多人音频通话
      {
        path: "call_video",
        component: () => import("@/views/multi/call_video.vue"),
      },
    ],
  },
];

// 3. 创建路由实例并传递 `routes` 配置
// 你可以在这里输入更多的配置，但我们在这里
// 暂时保持简单
const router = createRouter({
  // mode: 'hash',
  // 4. 内部提供了 history 模式的实现。为了简单起见，我们在这里使用 hash 模式。
  history: createWebHistory("/arcall-plus/"),
  // history: createWebHistory(),
  routes, // `routes: routes` 的缩写
  // scrollBehavior(to, from, savedPosition) {
  //   // 始终滚动到顶部
  //   return { top: 0, left: 0 };
  // },
});

/**
 * 路由守卫设置
 * to表示将要访问的路径
 * form表示从那个页面跳转而来
 * next表示允许跳转到指定位置
 *  */
router.beforeEach(async (to, from, next) => {
  if (to.path == "/login") return next();
  if (localStorage.getItem("ARcall_USERINFO") && localStorage.getItem("ARCALLPLUSTOKEN")) {
    next();
  } else {
    return next("/login");
  }
});

//导出router
export default router;
