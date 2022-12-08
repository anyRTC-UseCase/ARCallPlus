/**
 * 随机名称
 */

const nameLits = [
  "Rose",
  "Lily",
  "Daisy",
  "Jasmine",
  "Poppy",
  "Violet",
  "Camellia",
  "Rosemary",
  "Daffodil",
  "Gardenia",
  "Jackson",
  "Aiden",
  "Liam",
  "Lucas",
  "Noah",
  "Mason",
  "Ethan",
  "Caden",
  "Logan",
  "Jacob",
];
// 随机库存记录量
const history: string[] = [];

// 生成随机头像
const createRandomName = (): string => {
  // 随机数字
  const arrIndex = Math.floor(Math.random() * nameLits.length);
  if (history.length > 0) {
    if (history.length === nameLits.length) {
      // 若随机库存记录量与库存数量一致，清空记录
      history.splice(0, history.length);
      return createRandomName();
    } else {
      // 随机重复，如果存在，重新递归随机
      const oM = history.filter((item) => {
        return item === nameLits[arrIndex];
      });
      if (oM.length > 0) {
        return createRandomName();
      } else {
        history.push(nameLits[arrIndex]);
        return nameLits[arrIndex];
      }
    }
  } else {
    // 直接添加
    history.push(nameLits[arrIndex]);
    return nameLits[arrIndex];
  }
};

export default createRandomName;
