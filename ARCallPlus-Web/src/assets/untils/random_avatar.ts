/**
 * 随机头像
 * 库存使用完之前无重复
 */

//男
// ManAvatarUrl1 = "https://oss.agrtc.cn/oss/fdfs/6cd71dca89be027ec4b0f0f513018d75.jpg"
// ManAvatarUrl2 = "https://oss.agrtc.cn/oss/fdfs/48d78cc71af530b837e3b35e4df9cd03.jpeg"
// ManAvatarUrl3 = "https://oss.agrtc.cn/oss/fdfs/0e7c17db1b345977ec54525ae75e9189.jpeg"
// ManAvatarUrl4 = "https://oss.agrtc.cn/oss/fdfs/36fc7b27ec0cc00abdbae8825e4f03fb.jpg"
// ManAvatarUrl5 = "https://oss.agrtc.cn/oss/fdfs/40b42ff56816707ba22dbd755d421e66.jpg"
// //女
// WomanAvatarUrl1 = "https://oss.agrtc.cn/oss/fdfs/2cf7a624751e4abd19aa44f66348bed4.jpeg"
// WomanAvatarUrl2 = "https://oss.agrtc.cn/oss/fdfs/245f40c6e5d6bc8d16f01b5bb9f4374f.jpg"
// WomanAvatarUrl3 = "https://oss.agrtc.cn/oss/fdfs/749e306361361109b194dd07c8dfaf9a.jpeg"
// WomanAvatarUrl4 = "https://oss.agrtc.cn/oss/fdfs/4ffc9f578d2f82ba2bf9ff418ba404b6.jpeg"
// WomanAvatarUrl5 = "https://oss.agrtc.cn/oss/fdfs/7dd9f46656935545a241c9722ec83976.jpeg"

// url1  = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/1be8f37f883172e2627d130b22f03658.jpg"
// url2  = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/471525db8a6ee469036989bb2d9458cc.jpg"
// url3  = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/61e7fad153a7c82109de496e5a5a1aeb.jpg"
// url4  = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/4a1802f74394e4a957b26dc121aae99e.jpg"
// url5  = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/2b09c26bcf7dc36259558e974c4b84db.jpg"
// url6  = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/46781d0c51c577f8aca7e30d1c84c906.jpg"
// url7  = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/938009652658253930a0897a69a21601.jpg"
// url8  = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/439f9305715ba98e8ad5b9f6a1632d21.jpg"
// url9  = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/5708fca0acb456a858ec09f326eb71f8.jpg"
// url10 = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/b78196cf6b67815ab50b26433eebf4e6.jpg"
// url11 = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/f971d600f491aa7f5a3033349c706868.jpg"
// url12 = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/0c768308bd376e1254fd66b5c24d0db6.jpg"
// url13 = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/2d1a53a1cb9888294f33904fec86a73a.jpg"
// url14 = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/6f33e3577cf740c505fbc54af0966605.jpg"
// url15 = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/72edb9881cae6721ebb49d43eb0312e8.jpg"
// url16 = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/b195f5854851a7dd4a55deee2db7c271.jpg"
// url17 = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/1a05d5741cb4d2802190ef9a73624bbc.jpg"
// url18 = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/6d80cdd0c7f0cf9876a9e59fda6aa439.jpg"
// url19 = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/8bd23da352df7daffffe06f69dec4ba8.jpg"
// url20 = "https://anyrtc.oss-cn-shanghai.aliyuncs.com/d00c5df0ab369290b0ea87f7ce5acad9.jpg"
// url21 = "https://oss.agrtc.cn/oss/fdfs/6cd71dca89be027ec4b0f0f513018d75.jpg"
// url22 = "https://oss.agrtc.cn/oss/fdfs/48d78cc71af530b837e3b35e4df9cd03.jpeg"
// url23 = "https://oss.agrtc.cn/oss/fdfs/0e7c17db1b345977ec54525ae75e9189.jpeg"
// url24 = "https://oss.agrtc.cn/oss/fdfs/36fc7b27ec0cc00abdbae8825e4f03fb.jpg"
// url25= "https://oss.agrtc.cn/oss/fdfs/40b42ff56816707ba22dbd755d421e66.jpg"
// url26 = "https://oss.agrtc.cn/oss/fdfs/2cf7a624751e4abd19aa44f66348bed4.jpeg"
// url27 = "https://oss.agrtc.cn/oss/fdfs/245f40c6e5d6bc8d16f01b5bb9f4374f.jpg"
// url28 = "https://oss.agrtc.cn/oss/fdfs/749e306361361109b194dd07c8dfaf9a.jpeg"
// url29 = "https://oss.agrtc.cn/oss/fdfs/4ffc9f578d2f82ba2bf9ff418ba404b6.jpeg"
// url30 = "https://oss.agrtc.cn/oss/fdfs/7dd9f46656935545a241c9722ec83976.jpeg"

const avatarLits = [
  // "https://oss.agrtc.cn/oss/fdfs/6cd71dca89be027ec4b0f0f513018d75.jpg",
  // "https://oss.agrtc.cn/oss/fdfs/48d78cc71af530b837e3b35e4df9cd03.jpeg",
  // "https://oss.agrtc.cn/oss/fdfs/0e7c17db1b345977ec54525ae75e9189.jpeg",
  // "https://oss.agrtc.cn/oss/fdfs/36fc7b27ec0cc00abdbae8825e4f03fb.jpg",
  // "https://oss.agrtc.cn/oss/fdfs/40b42ff56816707ba22dbd755d421e66.jpg",

  // "https://oss.agrtc.cn/oss/fdfs/2cf7a624751e4abd19aa44f66348bed4.jpeg",
  // "https://oss.agrtc.cn/oss/fdfs/245f40c6e5d6bc8d16f01b5bb9f4374f.jpg",
  // "https://oss.agrtc.cn/oss/fdfs/749e306361361109b194dd07c8dfaf9a.jpeg",
  // "https://oss.agrtc.cn/oss/fdfs/4ffc9f578d2f82ba2bf9ff418ba404b6.jpeg",
  // "https://oss.agrtc.cn/oss/fdfs/7dd9f46656935545a241c9722ec83976.jpeg",

  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/1be8f37f883172e2627d130b22f03658.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/471525db8a6ee469036989bb2d9458cc.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/61e7fad153a7c82109de496e5a5a1aeb.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/4a1802f74394e4a957b26dc121aae99e.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/2b09c26bcf7dc36259558e974c4b84db.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/46781d0c51c577f8aca7e30d1c84c906.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/938009652658253930a0897a69a21601.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/439f9305715ba98e8ad5b9f6a1632d21.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/5708fca0acb456a858ec09f326eb71f8.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/b78196cf6b67815ab50b26433eebf4e6.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/f971d600f491aa7f5a3033349c706868.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/0c768308bd376e1254fd66b5c24d0db6.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/2d1a53a1cb9888294f33904fec86a73a.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/6f33e3577cf740c505fbc54af0966605.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/72edb9881cae6721ebb49d43eb0312e8.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/b195f5854851a7dd4a55deee2db7c271.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/1a05d5741cb4d2802190ef9a73624bbc.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/6d80cdd0c7f0cf9876a9e59fda6aa439.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/8bd23da352df7daffffe06f69dec4ba8.jpg",
  // "https://anyrtc.oss-cn-shanghai.aliyuncs.com/d00c5df0ab369290b0ea87f7ce5acad9.jpg",
  // "https://oss.agrtc.cn/oss/fdfs/6cd71dca89be027ec4b0f0f513018d75.jpg",
  // "https://oss.agrtc.cn/oss/fdfs/48d78cc71af530b837e3b35e4df9cd03.jpeg",
  // "https://oss.agrtc.cn/oss/fdfs/0e7c17db1b345977ec54525ae75e9189.jpeg",
  // "https://oss.agrtc.cn/oss/fdfs/36fc7b27ec0cc00abdbae8825e4f03fb.jpg",
  // "https://oss.agrtc.cn/oss/fdfs/40b42ff56816707ba22dbd755d421e66.jpg",
  // "https://oss.agrtc.cn/oss/fdfs/2cf7a624751e4abd19aa44f66348bed4.jpeg",
  // "https://oss.agrtc.cn/oss/fdfs/245f40c6e5d6bc8d16f01b5bb9f4374f.jpg",
  // "https://oss.agrtc.cn/oss/fdfs/749e306361361109b194dd07c8dfaf9a.jpeg",
  // "https://oss.agrtc.cn/oss/fdfs/4ffc9f578d2f82ba2bf9ff418ba404b6.jpeg",
  // "https://oss.agrtc.cn/oss/fdfs/7dd9f46656935545a241c9722ec83976.jpeg",

  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/1be8f37f883172e2627d130b22f03658.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/471525db8a6ee469036989bb2d9458cc.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/61e7fad153a7c82109de496e5a5a1aeb.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/4a1802f74394e4a957b26dc121aae99e.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/2b09c26bcf7dc36259558e974c4b84db.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/46781d0c51c577f8aca7e30d1c84c906.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/938009652658253930a0897a69a21601.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/439f9305715ba98e8ad5b9f6a1632d21.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/5708fca0acb456a858ec09f326eb71f8.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/b78196cf6b67815ab50b26433eebf4e6.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/f971d600f491aa7f5a3033349c706868.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/0c768308bd376e1254fd66b5c24d0db6.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/2d1a53a1cb9888294f33904fec86a73a.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/6f33e3577cf740c505fbc54af0966605.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/72edb9881cae6721ebb49d43eb0312e8.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/b195f5854851a7dd4a55deee2db7c271.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/1a05d5741cb4d2802190ef9a73624bbc.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/6d80cdd0c7f0cf9876a9e59fda6aa439.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/8bd23da352df7daffffe06f69dec4ba8.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/d00c5df0ab369290b0ea87f7ce5acad9.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/7e18965e9903fb1212c1c04546d4abcc.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/0f61ca1a4423ce46caa2ad16d8e43342.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/761cdd252d67afd69eaece9b5901edfc.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/9c4dca89e0aeb2fdfce04443fc9a935a.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/5aed7263e2effdd365e815a7f6f91417.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/f5f3ff9c1c81e8e25afea070b69bac93.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/0f8518bf057ae4ab7c269847aae86811.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/67ab3f38ea4c685381f13ca597692db6.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/0a97a0a19de5214b42c7478134d35607.jpg",
  "https://anyrtc.oss-cn-shanghai.aliyuncs.com/fbbb28b56158f3d77732d3a2c3a1d1b5.jpg",
];
// 随机库存记录量
const history: string[] = [];

// 生成随机头像
const createRandomAvatar = (): string => {
  // 随机数字
  const arrIndex = Math.floor(Math.random() * avatarLits.length);
  if (history.length > 0) {
    if (history.length === avatarLits.length) {
      // 若随机库存记录量与库存数量一致，清空记录
      history.splice(0, history.length);
      return createRandomAvatar();
    } else {
      // 随机重复，如果存在，重新递归随机
      const oM = history.filter((item) => {
        return item === avatarLits[arrIndex];
      });
      if (oM.length > 0) {
        return createRandomAvatar();
      } else {
        history.push(avatarLits[arrIndex]);
        return avatarLits[arrIndex];
      }
    }
  } else {
    // 直接添加
    history.push(avatarLits[arrIndex]);
    return avatarLits[arrIndex];
  }
};

export default createRandomAvatar;
