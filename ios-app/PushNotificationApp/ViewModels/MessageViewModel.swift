//
//  MessageViewModel.swift
//  PushNotificationApp
//
//  メッセージ一覧画面のViewModel
//

import Foundation
import Combine

@MainActor
class MessageViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let notificationManager = NotificationManager.shared
    
    init() {
        // NotificationManagerの通知を監視
        notificationManager.$notifications
            .assign(to: &$messages)
    }
    
    /// サーバーからメッセージを取得
    func fetchMessages() async {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            errorMessage = "ユーザーIDが見つかりません"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await notificationManager.fetchMessagesFromServer(userId: userId)
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            print("メッセージ取得エラー: \(error)")
        } catch {
            errorMessage = "メッセージの取得に失敗しました"
            print("予期しないエラー: \(error)")
        }
        
        isLoading = false
    }
    
    /// メッセージを既読にする
    func markAsRead(_ messageId: String) {
        notificationManager.markAsRead(messageId: messageId)
    }
    
    /// すべてのメッセージを既読にする
    func markAllAsRead() {
        notificationManager.markAllAsRead()
    }
    
    /// メッセージを削除
    func deleteMessage(_ messageId: String) {
        notificationManager.deleteNotification(messageId: messageId)
    }
    
    /// すべてのメッセージを削除
    func clearAllMessages() {
        notificationManager.clearAllNotifications()
    }
    
    /// 未読メッセージ数を取得
    var unreadCount: Int {
        messages.filter { !$0.isRead }.count
    }
}
