//
//  NotificationManager.swift
//  PushNotificationApp
//
//  プッシュ通知管理サービス
//

import Foundation
import UserNotifications
import Combine

/// プッシュ通知管理クラス
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var fcmToken: String? = nil
    @Published var notifications: [Message] = []
    @Published var shouldShowMessages: Bool = false
    @Published var notificationPermissionGranted: Bool = false
    
    private init() {
        loadFCMToken()
        checkNotificationPermission()
    }
    
    /// 通知許可状態をチェック
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    /// 通知許可をリクエスト
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.notificationPermissionGranted = granted
            }
            
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            
            return granted
        } catch {
            print("通知許可リクエストエラー: \(error)")
            return false
        }
    }
    
    /// FCMトークンを保存
    func saveFCMToken(_ token: String) {
        self.fcmToken = token
        UserDefaults.standard.set(token, forKey: "fcmToken")
        print("FCMトークン保存: \(token)")
    }
    
    /// FCMトークンを読み込み
    private func loadFCMToken() {
        if let token = UserDefaults.standard.string(forKey: "fcmToken") {
            self.fcmToken = token
            print("FCMトークン読み込み: \(token)")
        }
    }
    
    /// 通知を追加
    func addNotification(userId: String, text: String) {
        let message = Message(
            messageId: UUID().uuidString,
            text: text,
            createdAt: Date(),
            isRead: false
        )
        
        DispatchQueue.main.async {
            self.notifications.insert(message, at: 0)
            print("通知追加: \(text)")
        }
    }
    
    /// 通知を既読にする
    func markAsRead(messageId: String) {
        if let index = notifications.firstIndex(where: { $0.id == messageId }) {
            notifications[index].isRead = true
        }
    }
    
    /// すべての通知を既読にする
    func markAllAsRead() {
        for i in 0..<notifications.count {
            notifications[i].isRead = true
        }
    }
    
    /// 通知を削除
    func deleteNotification(messageId: String) {
        notifications.removeAll { $0.id == messageId }
    }
    
    /// すべての通知を削除
    func clearAllNotifications() {
        notifications.removeAll()
    }
    
    /// サーバーからメッセージを取得
    func fetchMessagesFromServer(userId: String) async throws {
        let response = try await APIService.shared.getMessages(userId: userId)
        
        if response.success, let data = response.data {
            await MainActor.run {
                // 取得したメッセージを追加
                for messageItem in data.messages {
                    let message = Message(
                        messageId: messageItem.messageId,
                        text: messageItem.text,
                        createdAtString: messageItem.createdAt,
                        isRead: false
                    )
                    
                    // 重複チェック
                    if !self.notifications.contains(where: { $0.messageId == message.messageId }) {
                        self.notifications.append(message)
                    }
                }
                
                // 日付順にソート
                self.notifications.sort { $0.createdAt > $1.createdAt }
            }
        }
    }
}
