/**
 * 获取本地用户信息
 */
export const getUserInfo = () => {
  const oUser = localStorage.getItem("ARcall_USERINFO");
  if (oUser) {
    return JSON.parse(oUser);
  }
  return;
};

/**
 * 获取符合条件的联系人信息
 * @param data 条件
 */
export const getInformationLimits = (data: string | string[]) => {
  // 本地存储的信息
  const oInfo = localStorage.getItem("AECALL_LOCALSTORAGEINFORMATION");
  if (oInfo) {
    const oList = JSON.parse(oInfo);
    if (typeof data === "string") {
      const oM = oList.filter((item: { userId: string }) => {
        return data == item.userId;
      });
      if (oM.length > 0) {
        return oM;
      }
    }

    if (typeof data === "object") {
      const oM: {
        userId: string;
        headerUrl: string;
        userName: string;
        customData: string;
      }[] = [];
      data.forEach((item) => {
        oList.forEach(
          (list: {
            userId: string;
            headerUrl: string;
            userName: string;
            customData: string;
          }) => {
            if (item === list.userId) {
              oM.push(list);
            }
          }
        );
      });

      return oM;
    }
  }
  return;
};

/**
 * 获取用户设备类型
 * 设备类型
 * unknown/android/ios/winphone/quickapp/ipad/web/windows/linux/macOS/others
 * 0/1/2/3/4/5/6/7/8/9/10
 */
export const getDevice = () => {
  const agent = navigator.userAgent.toLowerCase();
  const result = (function () {
    if (/windows/.test(agent)) {
      // return 'windows pc';
      return 7;
    } else if (/iphone|ipod/.test(agent) && /mobile/.test(agent)) {
      // return 'iphone';
      return 2;
    } else if (/ipad/.test(agent) && /mobile/.test(agent)) {
      // return 'ipad';
      return 5;
    } else if (/android/.test(agent) && /mobile/.test(agent)) {
      // return 'android';
      return 1;
    } else if (/linux/.test(agent)) {
      // return 'linux pc';
      return 8;
    } else if (/mac/.test(agent)) {
      // return 'mac';
      return 9;
    } else {
      // return 'other';
      return 10;
    }
  })();

  return result;
};
