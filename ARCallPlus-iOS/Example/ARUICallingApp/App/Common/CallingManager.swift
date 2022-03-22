//
//  CallingManager.swift
//  ARUICallingApp
//
//  Created by 余生 on 2022/3/3.
//

import UIKit
import ARUICalling

enum CallingType: Int {
    case audio, video, audios, videos
    
    func description() -> String {
        switch self {
        case .audio: return "点对点音频通话"
        case .video: return "点对点视频通话"
        case .audios: return "多人语音通话"
        case .videos: return "多人视频通话"
        }
    }
}

class CallingManager: NSObject {
    @objc public static let shared = CallingManager()
    
    private var callingVC = UIViewController()
    public var callingType: CallingType = .audio
    
    func addListener() {
        ARUICalling.shareInstance().setCallingListener(listener: self)
        ARUICalling.shareInstance().enableCustomViewRoute(enable: true)
    }
}

extension CallingManager: ARUICallingListerner {
    func shouldShowOnCallView() -> Bool {
        /// 作为被叫是否拉起呼叫页面，若为 false 直接 reject 通话
        return true
    }
    
    func callStart(userIDs: [String], type: ARUICallingType, role: ARUICallingRole, viewController: UIViewController?) {
        print("Calling - callStart")
        if let vc = viewController {
            callingVC = vc;
            vc.modalPresentationStyle = .fullScreen
            let topVc = topViewController()
            topVc.present(vc, animated: false, completion: nil)
        }
    }
    
    func callEnd(userIDs: [String], type: ARUICallingType, role: ARUICallingRole, totalTime: Float) {
        print("Calling - callEnd")
        callingVC.dismiss(animated: true) {}
    }
    
    func onCallEvent(event: ARUICallingEvent, type: ARUICallingType, role: ARUICallingRole, message: String) {
        print("Calling - onCallEvent event = \(event.rawValue) type = \(type.rawValue)")
        if event == .callRemoteLogin {
            ProfileManager.shared.removeAllData()
            ARAlertActionSheet.showAlert(titleStr: "账号异地登录", msgStr: nil, style: .alert, currentVC: topViewController(), cancelBtn: "确定", cancelHandler: { action in
                ARUILogin.logout()
                AppUtils.shared.showLoginController()
            }, otherBtns: nil, otherHandler: nil)
        }
    }
    
    func onPush(toOfflineUser userIDs: [String], type: ARUICallingType) {
        print("Calling - toOfflineUser \(userIDs)")
        ProfileManager.shared.processPush(userIDs: userIDs, type: callingType)
    }
}
