//
//  Message.swift
//  PushNotificationApp
//
//  Models
//

import Foundation

/// メッセージモデル
struct Message: Codable, Identifiable {
    let id: String
    let messageId: String
    let text: String
    let createdAt: Date
    var isRead: Bool
    
    init(messageId: String, text: String, createdAt: Date, isRead: Bool = false) {
        self.id = messageId
        self.messageId = messageId
        self.text = text
        self.createdAt = createdAt
        self.isRead = isRead
    }
    
    init(messageId: String, text: String, createdAtString: String, isRead: Bool = false) {
        self.id = messageId
        self.messageId = messageId
        self.text = text
        
        let formatter = ISO8601DateFormatter()
        self.createdAt = formatter.date(from: createdAtString) ?? Date()
        self.isRead = isRead
    }
}

/// メッセージ取得レスポンス
struct MessagesResponse: Codable {
    let success: Bool
    let message: String
    let data: MessageData?
    
    struct MessageData: Codable {
        let userId: String
        let messages: [MessageItem]
        let count: Int
    }
    
    struct MessageItem: Codable {
        let messageId: String
        let text: String
        let createdAt: String
    }
}

/// プッシュ通知送信リクエスト
struct PushNotificationRequest: Codable {
    let userId: String
    let text: String
}

/// プッシュ通知送信レスポンス
struct PushNotificationResponse: Codable {
    let success: Bool
    let message: String
    let data: NotificationData?
    
    struct NotificationData: Codable {
        let userId: String
        let phoneNumber: String
        let messageId: String
        let notificationSent: Bool
    }
}
