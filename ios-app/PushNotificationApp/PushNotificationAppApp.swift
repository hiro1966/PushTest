//
//  PushNotificationAppApp.swift
//  PushNotificationApp
//
//  Created by AI Assistant
//

import SwiftUI
import FirebaseCore
import UserNotifications

@main
struct PushNotificationAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var notificationManager = NotificationManager.shared
    
    init() {
        // Firebase初期化
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
        }
    }
}

// AppDelegate for handling push notifications
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, 
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // 通知センターのデリゲートを設定
        UNUserNotificationCenter.current().delegate = self
        
        // 通知の許可をリクエスト
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知の許可が得られました")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("通知許可エラー: \(error.localizedDescription)")
            }
        }
        
        return true
    }
    
    // APNSトークン取得成功時
    func application(_ application: UIApplication, 
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("APNSトークン: \(token)")
        
        // FCMトークンを取得してサーバーに送信
        NotificationManager.shared.saveFCMToken(token)
    }
    
    // APNSトークン取得失敗時
    func application(_ application: UIApplication, 
                    didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNSトークン取得失敗: \(error.localizedDescription)")
    }
    
    // アプリがフォアグラウンドの時に通知を受信
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        print("フォアグラウンドで通知を受信: \(userInfo)")
        
        // 通知データを処理
        if let userId = userInfo["userId"] as? String,
           let text = userInfo["text"] as? String {
            NotificationManager.shared.addNotification(userId: userId, text: text)
        }
        
        // フォアグラウンドでも通知を表示
        completionHandler([.banner, .sound, .badge])
    }
    
    // 通知をタップした時
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        print("通知をタップ: \(userInfo)")
        
        // 通知データを処理
        if let userId = userInfo["userId"] as? String,
           let text = userInfo["text"] as? String {
            NotificationManager.shared.addNotification(userId: userId, text: text)
            NotificationManager.shared.shouldShowMessages = true
        }
        
        completionHandler()
    }
}
