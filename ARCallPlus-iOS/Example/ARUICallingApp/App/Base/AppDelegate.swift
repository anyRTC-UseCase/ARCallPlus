//
//  AppDelegate.swift
//  ARUICallingApp
//
//  Created by 余生丶 on 2022/2/15.
//

import UIKit

let jpushAppKey = <#T##String#>
let channel = "Publish channel"
let isProduction = false

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        ///【注册通知】通知回调代理
        let entity: JPUSHRegisterEntity = JPUSHRegisterEntity()
        entity.types = NSInteger(UNAuthorizationOptions.alert.rawValue) |
          NSInteger(UNAuthorizationOptions.sound.rawValue) |
          NSInteger(UNAuthorizationOptions.badge.rawValue)
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        
        ///【初始化sdk】
        JPUSHService.setup(withOption: launchOptions, appKey: jpushAppKey, channel: channel, apsForProduction: isProduction)
        
        changeBadgeNumber()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        /// sdk注册DeviceToken
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("did fail to register for remote notification with error ", error)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    func showMainViewController() {
        if let keyWindow = SceneDelegate.getCurrentWindow() {
            let attribute = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#B4B3CE") as Any, NSAttributedString.Key.font: UIFont(name: PingFangBold, size: 16) as Any]
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#2317FF") as Any, NSAttributedString.Key.font: UIFont(name: PingFangBold, size: 16) as Any]
            
            let mainVc = MainViewController.init()
            let mainNav = ARBaseNavigationController.init(rootViewController: mainVc)
            mainNav.tabBarItem.title = "通信"
            mainNav.tabBarItem.setTitleTextAttributes(attribute, for: .normal)
            mainNav.tabBarItem.setTitleTextAttributes(attributes, for: .selected)
            
            let mineVc = MineViewController.init()
            let mineNav = ARBaseNavigationController.init(rootViewController: mineVc)
            mineNav.tabBarItem.title = "我的"
            mineNav.tabBarItem.setTitleTextAttributes(attribute, for: .normal)
            mineNav.tabBarItem.setTitleTextAttributes(attributes, for: .selected)
            
            let tabBarC = UITabBarController()
            tabBarC.viewControllers = [mainNav, mineNav]
            tabBarC.tabBar.shadowImage = UIImage()
            tabBarC.tabBar.backgroundImage = UIImage()
            
            if !kDeviceIsIphoneX {
                for item in tabBarC.tabBar.items! {
                    item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -24)
                }
            }
            keyWindow.rootViewController = tabBarC
            keyWindow.makeKeyAndVisible()
        } else {
            debugPrint("window show MainViewController error")
        }
    }
    
    func showLoginViewController() {
        /// 异地登录
        if let keyWindow = SceneDelegate.getCurrentWindow() {
            keyWindow.rootViewController = LoginViewController()
            keyWindow.makeKeyAndVisible()
        } else {
            debugPrint("window show LoginViewController error")
        }
    }
}

extension AppDelegate: JPUSHRegisterDelegate {
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let userInfo = notification.request.content.userInfo
    
        let request = notification.request // 收到推送的请求
        let content = request.content // 收到推送的消息内容
    
//        let badge = content.badge // 推送消息的角标
//        let body = content.body   // 推送消息体
//        let sound = content.sound // 推送消息的声音
//        let subtitle = content.subtitle // 推送消息的副标题
//        let title = content.title // 推送消息的标题
        print("jpushNotificationCenter willPresent \(userInfo) \(content)")
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userInfo = response.notification.request.content.userInfo
        let request = response.notification.request // 收到推送的请求
        let content = request.content // 收到推送的消息内容
    
//        let badge = content.badge // 推送消息的角标
//        let body = content.body   // 推送消息体
//        let sound = content.sound // 推送消息的声音
//        let subtitle = content.subtitle // 推送消息的副标题
//        let title = content.title // 推送消息的标题
        print("jpushNotificationCenter didReceive \(userInfo) \(content)")
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification!) {
        
    }
    
    func jpushNotificationAuthorization(_ status: JPAuthorizationStatus, withInfo info: [AnyHashable : Any]!) {
        
    }
}

extension AppDelegate {
    func checkPushNotification(checkNotificationStatus isEnable : ((Bool)->())? = nil) {
        ///  检查推送是否打开
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings(){ (setttings) in
                switch setttings.authorizationStatus{
                case .authorized:
                    print("enabled notification setting")
                    isEnable?(true)
                case .denied:
                    print("setting has been disabled")
                    isEnable?(false)
                case .notDetermined:
                    print("something vital went wrong here")
                    isEnable?(false)
                case .provisional: break
                case .ephemeral: break
                @unknown default: break
                }
            }
        } else {
            let isNotificationEnabled = UIApplication.shared.currentUserNotificationSettings?.types.contains(UIUserNotificationType.alert)
            if isNotificationEnabled == true {
                print("enabled notification setting")
                isEnable?(true)
            } else {
                print("setting has been disabled")
                isEnable?(false)
            }
        }
    }
    
    func changeBadgeNumber() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        JPUSHService.setBadge(0)
    }
}

