import axios from "axios";
import Router from "@/router";
// 接口地址
import SetConfig from "@/config";
import Message from "@/assets/untils/message";
//1. 创建新的axios实例，
const service = axios.create({
  // 公共接口 开发环境还是线上环境也可以用api
  baseURL: SetConfig.BaseUrl,
  // 超时时间 单位是ms，这里设置了5s的超时时间
  timeout: SetConfig.Timeout,
  // 请求为跨域类型时是否在请求中协带cookie
  withCredentials: true,
});

// 2.请求拦截器
service.interceptors.request.use(
  (config: any) => {
    //发请求前做的一些处理，数据转化，配置请求头，设置token,设置loading等，根据需求去添加
    config.headers = {
      "AR-Authorization": localStorage.getItem("ARCALLPLUSTOKEN") || "",
    };
    return config;
  },
  (error: any) => {
    Promise.reject(error);
  }
);

// 3.响应拦截器
service.interceptors.response.use(
  (response) => {
    if (response.headers["ar-token"]) {
      localStorage.setItem("ARCALLPLUSTOKEN", response.headers["ar-token"]);
    }
    return response;
  },
  (error: { response: any }) => {
    /***** 接收到异常响应的处理开始  *****/
    if (error.response.status === 401) {
      localStorage.setItem("ARcall_USERINFO", "");
      localStorage.setItem("ARCALLPLUSTOKEN", "");
      // 重定向至登录页
      Router.replace("/login");
      Message({ message: "登录失效，请重新登陆", type: "error" });
    }
    /***** 处理结束 *****/
    //如果不需要错误处理，以上的处理过程都可省略
    return Promise.resolve(error.response);
  }
);
//4.导出
export default service;
