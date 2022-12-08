import { post } from "@/api/http/http";

// 查询设备是否存在
export const jpushExists = (data: {} | undefined) =>
  post("/api/v1/jpush/exists", data);

// 初始化
export const jpushInit = (data: {} | undefined) =>
  post("/api/v1/jpush/init", data);

// 推送接口
export const jpushProcessPush = (data: {} | undefined) =>
  post("/api/v1/jpush/processPush", data);

// 获取用户信息
export const jpushGetUserInfo = (data: {} | undefined) =>
  post("/api/v1/users/getUserInfo", data);
