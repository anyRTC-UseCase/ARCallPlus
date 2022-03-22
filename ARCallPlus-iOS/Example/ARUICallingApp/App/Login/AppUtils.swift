//
//  AppUtils.swift
//  ARUICallingApp
//
//  Created by 余生丶 on 2022/3/3.
//

import UIKit
import ARUICalling

class AppUtils: NSObject {
    @objc public static let shared = AppUtils()
    private override init() {}
    
    @objc var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    @objc var curUserId: String {
        get {
#if NOT_LOGIN
            return ""
#else
            return ARUILogin.getUserID()
#endif
        }
    }
    
    // MARK: - UI
    @objc func showMainController() {
        appDelegate.showMainViewController()
    }
    
    @objc func showLoginController() {
        appDelegate.showLoginViewController()
    }
}
