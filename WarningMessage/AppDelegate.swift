//
//  AppDelegate.swift
//  WarningMessage
//
//  Created by HyeonSoo Kim on 2022/02/04.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging //Message Delegate 위함(?), FCM Token 등록위해. ^><^

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let userNotificationCenter = UNUserNotificationCenter.current()

    //didFinish에 정의해도되지만 구분을 위해 willFinish에 delegate선언.
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        userNotificationCenter.delegate = self
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self //^><^
        
        //FCM 현재 등록 토큰 확인
        Messaging.messaging().token { token, error in
            if let error = error {
                print("ERROR FCM 등록토큰 가져오기: \(error.localizedDescription)")
            } else if let token = token {
                print("FCM 등록토큰: \(token)")
            }
        }
        
        //알림 등록.
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        userNotificationCenter.requestAuthorization(options: authOptions) { _, error in
            print("ERROR: Request Notifications Authorization: \(error.debugDescription)")
        }
        //원격알림 등록마무리.
        application.registerForRemoteNotifications()
        
        return true
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


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .badge, .sound])
    }
}

extension AppDelegate: MessagingDelegate {
    //갱신된 토큰은 messageDelegate 함수를 통해 알 수 있음. 다시토큰을 받았는지를 확인.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("FCM 등록토큰 갱신: \(token)")
    }
}

//test용 Message를 보내고 등록token확인할 것임.
//보낸 Remote Notification이 잘 나타나는지 test device를 통해 확인하기위해서 위와 같이 콘솔에 토큰이 찍히도록 한 것.
//원격알림(Remote Notification)은 Simulator에서 지원하지않음. 따라서 실제 기기를 연결해서 테스트해야함.
