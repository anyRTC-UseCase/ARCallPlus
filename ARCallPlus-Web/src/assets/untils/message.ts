// 警告图片
import WarningImg from "@/assets/img/warning.png";
// 错误图片
import ErroeImg from "@/assets/img/error.png";
// 成功图片
import SuccessImg from "@/assets/img/success1.png";
// 接口信息参数声明
interface options {
  message: string;
  type?: string;
  duration?: number;
}

// 接口信息存储声明
interface MessageInterFace {
  // 消息序列
  order: number;
  // 消息队列
  messageQueue: any;
  // 定时器(一定时间后清除),默认 3000 ms
  duration: number;
  // 父级元素
  body: HTMLBodyElement;
}

const MessageStore: MessageInterFace = {
  // 消息序列
  order: 0,
  // 消息队列
  messageQueue: [],
  // 定时器(一定时间后清除),默认 3000 ms
  duration: 3000,
  // 父级元素
  body: document.getElementsByTagName("body")[0],
};

export default async ({ message, type, duration }: options) => {
  // 定时器时间
  MessageStore.duration = duration ? duration : MessageStore.duration;

  const targetOrder = "message_200" + MessageStore.order++;

  // 层叠间距
  let topTier = 24;
  if (MessageStore.messageQueue.length > 0) {
    MessageStore.messageQueue.map((item: { height: number }, index: number) => {
      topTier = topTier + item.height;
    });
  }

  /**
   * 类型 type
   * * success 成功
   * * warning 警告
   * * error 失败
   *  */

  const typeClass = type ? type : "success";
  const classLibrary: any = {
    success: SuccessImg,
    warning: WarningImg,
    error: ErroeImg,
  };
  // 容器
  const messageDom = document.createElement("div");
  messageDom.id = targetOrder;
  // min-w-380
  messageDom.className =
    "fixed left-1/2 transform -translate-x-2/4  rounded z-50 flex items-center px-14 py-3.5 bg-arcall-gray_3 text-xs font-extrabold text-arcall-gray_4 justify-center";
  messageDom.style.top = topTier + MessageStore.messageQueue.length * 20 + "px";

  // 图标
  const messageDom_i = document.createElement("img");
  messageDom_i.src = classLibrary[typeClass];
  messageDom_i.className = "mr-2 h-5 w-5";
  // messageDom_i.innerText = "6";
  messageDom.appendChild(messageDom_i);
  // 信息提示
  const messageDom_sapn = document.createElement("span");
  messageDom_sapn.className = "text-sm";
  messageDom_sapn.innerText = message;
  messageDom.appendChild(messageDom_sapn);

  MessageStore.body.appendChild(messageDom);

  // 记录对应信息
  MessageStore.messageQueue.push({
    order: targetOrder,
    dom: messageDom,
    height: messageDom.offsetHeight,
    top: messageDom.offsetTop,
  });

  // 定时销毁
  if (MessageStore.duration > 0) {
    setTimeout(() => {
      // 移除相关记录
      const startIndex = MessageStore.messageQueue.findIndex(
        (message: { order: string }) => message.order === targetOrder
      );
      MessageStore.messageQueue.splice(startIndex, 1);
      MessageStore.body.removeChild(messageDom);
    }, MessageStore.duration);
  }
};
