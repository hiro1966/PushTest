//
//  User.swift
//  PushNotificationApp
//
//  Models
//

import Foundation

/// ユーザー情報モデル
struct User: Codable, Identifiable {
    let id: String
    let userId: String
    let phoneNumber: String
    var fcmToken: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    init(userId: String, phoneNumber: String, fcmToken: String? = nil) {
        self.id = userId
        self.userId = userId
        self.phoneNumber = phoneNumber
        self.fcmToken = fcmToken
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

/// ユーザー登録リクエスト
struct UserRegistrationRequest: Codable {
    let userId: String
    let phoneNumber: String
    let fcmToken: String?
}

/// ユーザー登録レスポンス
struct UserRegistrationResponse: Codable {
    let success: Bool
    let message: String
    let data: UserData?
    
    struct UserData: Codable {
        let userId: String
        let phoneNumber: String
        let registeredAt: String
    }
}
