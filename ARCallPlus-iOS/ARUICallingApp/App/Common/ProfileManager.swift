//
//  ProfileManager.swift
//  ARUICallingApp
//
//  Created by 余生丶 on 2022/3/3.
//

import UIKit
import ARUICalling
import SwiftyJSON

@objc class LoginModel: ARCallUser, Codable {
    @objc var device: NSInteger
    
    override init() {
        self.device = 2
        super.init()
        self.userId = ""
        self.userName = ""
        self.headerUrl = ""
    }
    
    init(jsonData: JSON) {
        self.device = jsonData["device"].intValue
        super.init()
        self.userId = jsonData["uId"].stringValue
        self.headerUrl = jsonData["headerImg"].stringValue
        self.userName = jsonData["nickName"].stringValue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(userName, forKey: .userName)
        try container.encode(headerUrl, forKey: .headerUrl)
        try container.encode(device, forKey: .device)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        device = try container.decode(NSInteger.self, forKey: .device)
        super.init()
        userId = try container.decode(String.self, forKey: .userId)
        userName = try container.decode(String.self, forKey: .userName)
        headerUrl = try container.decode(String.self, forKey: .headerUrl)
    }
    
    enum CodingKeys : String, CodingKey {
      case userId = "uId"
      case headerUrl = "headerImg"
      case userName = "nickName"
      case device
    }
}

let localUserDataKey = "LocalUserDataKey"
let remoteUserDataKey = "RemoteUserDataKey"

class ProfileManager: NSObject {
    @objc public static let shared = ProfileManager()
    
    @objc var localUid: String?
    @objc var localUserModel: LoginModel? = nil
    
    /// 检查是否登录
    /// - Returns: 是否存在
    func existLocalUserData() -> Bool {
        if let cacheData = UserDefaults.standard.object(forKey: localUserDataKey) as? Data {
            if let cacheUser = try? JSONDecoder().decode(LoginModel.self, from: cacheData) {
                localUserModel = cacheUser
                localUid = cacheUser.userId
                
                /// 获取 Authorization
                exists(uid: localUid!) {
                    
                } failed: { error in
                    
                }
                return true
            }
        }
        return false
    }
    
    /// 查询设备信息是否存在
    /// - Parameters:
    ///   - uid: 用户id
    ///   - success: 成功回调
    ///   - failed: 失败回调
    func exists(uid: String, success: @escaping ()->Void,
                failed: @escaping (_ error: Int)->Void) {
        ARNetWorkHepler.getResponseData("jpush/exists", parameters: ["uId": uid, "appId": AppID] as [String : AnyObject], headers: false) { [weak self] result in
            let code = result["code"].rawValue as! Int
            if code == 200 {
                let model = LoginModel(jsonData: result["data"])
                if model.device != 2 {
                    /// 兼容异常问题
                    self?.register(uid: model.userId, nickName: model.userName, headUrl: model.headerUrl, success: {
                        success()
                    }, failed: { error in
                        failed(error)
                    })
                } else {
                    self?.localUserModel = model
                    do {
                        let cacheData = try JSONEncoder().encode(model)
                        UserDefaults.standard.set(cacheData, forKey: localUserDataKey)
                    } catch {
                        print("Calling - Save Failed")
                    }
                    success()
                }
            } else {
                failed(code)
            }
        } error: { error in
            print("Calling - Exists Error")
            self.receiveError(code: error)
        }
    }
    
    
    /// 初始化设备信息
    /// - Parameters:
    ///   - uid: 用户id
    ///   - nickName: 用户昵称
    ///   - headUrl: 用户头像
    ///   - success: 成功回调
    ///   - failed: 失败回调
    func register(uid: String, nickName: String, headUrl: String,
                    success: @escaping ()->Void,
                    failed: @escaping (_ error: Int)->Void) {
        ARNetWorkHepler.getResponseData("jpush/init", parameters: ["appId": AppID, "uId": uid, "device": 2, "headerImg": headUrl, "nickName": nickName] as [String : AnyObject], headers: false) { [weak self]result in
            print("Calling - Server init Sucess")
            let code = result["code"].rawValue as! Int
            if code == 200 {
                let model = LoginModel(jsonData: result["data"])
                self?.localUserModel = model
                do {
                    let cacheData = try JSONEncoder().encode(model)
                    UserDefaults.standard.set(cacheData, forKey: localUserDataKey)
                } catch {
                    print("Calling - Save Failed")
                }
                success()
            } else {
                failed(code)
            }
            success()
        } error: { error in
            print("Calling - Server init Error")
            self.receiveError(code: error)
        }
    }
    
    
    /// 当前用户登录
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failed: 失败回调
    @objc func loginRTM(success: @escaping ()->Void, failed: @escaping (_ error: NSInteger)->Void) {
        ARUILogin.initWithSdkAppID(AppID)
        
        ARUILogin.login(localUserModel!) {
            success()
            print("Calling - login sucess")
        } fail: { code in
            failed(code.rawValue)
            print("Calling - login fail")
        }
        
        /// 配置极光别名
        JPUSHService.setAlias(localUid, completion: { iResCode, iAlias, seq in
            
        }, seq: 0)
    }
    
    /// 推送接口
    /// - Parameters:
    ///   - userIDs: 离线人员id
    ///   - type: 呼叫类型（ 0/1/2/3：p2p音频呼叫/p2p视频呼叫/群组音频呼叫/群组视频呼叫）
    func processPush(userIDs: [String], type: CallingType) {
        ARNetWorkHepler.getResponseData("jpush/processPush", parameters: ["caller": localUid as Any, "callee": userIDs, "callType": type.rawValue, "pushType": 0, "title": "ARCallPlus"] as [String : AnyObject], headers: true) { result in
            print("Calling - Offline Push Sucess == \(result)")
        } error: { error in
            print("Calling - Offline Push Error")
            self.receiveError(code: error)
        }
    }
    
    /// 获取用户信息
    /// - Parameters:
    ///   - uid: 用户UId
    ///   - success: 成功回调
    ///   - failed: 失败回调
    func getUserInfo(uid: String, success: @escaping (LoginModel)->Void,
                     failed: @escaping (_ error: String)->Void) {
        ARNetWorkHepler.getResponseData("users/getUserInfo", parameters: ["uId": uid] as [String : AnyObject], headers: true) { result in
            let code = result["code"].rawValue as! Int
            if code == 200 {
                print("Calling - getUserInfo Sucess")
                success(LoginModel(jsonData: JSON(result["data"])))
            } else {
                failed("\(code)")
            }
        } error: { error in
            print("Calling - getUserInfo Error")
            self.receiveError(code: error)
        }
    }
    
    
    /// 错误信息
    /// - Parameter code: 错误码
    private func receiveError(code: NSInteger) {
        if code < 0 || code == 401 {
            topViewController().view.makeToast("请检查当前网络环境")
            if code == 401 {
                if localUid != nil {
                    exists(uid: localUid!) {
                        
                    } failed: { error in
                        
                    }
                }
            }
        } else {
            print("Calling - Network request code：\(code)")
        }
    }
    
    /// 存储最近联系人
    /// - Parameter parameter: 联系人
    func saveContacts(parameter: [LoginModel]) -> Bool {
        if parameter.first?.userId != localUid {
            let remoteData = getContacts()
            var users = parameter
            
            if remoteData != nil {
                for user in remoteData! {
                    if user.userId == parameter.first?.userId {
                        return false
                    }
                }
                
                users += remoteData!
            }
            
            do {
                let cacheData = try JSONEncoder().encode(users)
                UserDefaults.standard.set(cacheData, forKey: remoteUserDataKey)
                return true
            } catch {
                print("Calling - Save Contacts Failed")
            }
        }
        return false
    }
    
    
    /// 获取最新联系人
    /// - Parameter handle: 回调结果
    func getContacts()-> [LoginModel]? {
        if let remoteData = UserDefaults.standard.object(forKey: remoteUserDataKey) as? Data {
            if let remoteUsers = try? JSONDecoder().decode([LoginModel].self, from: remoteData) {
                return remoteUsers
            }
        }
        return nil
    }
    
    
    /// 清除所有本地信息
    func removeAllData() {
        UserDefaults.standard.removeObject(forKey: localUserDataKey)
        UserDefaults.standard.removeObject(forKey: remoteUserDataKey)
    }
}
