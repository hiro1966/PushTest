//
//  APIService.swift
//  PushNotificationApp
//
//  API通信サービス
//

import Foundation

/// APIエラー
enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .networkError(let error):
            return "ネットワークエラー: \(error.localizedDescription)"
        case .invalidResponse:
            return "無効なレスポンスです"
        case .decodingError(let error):
            return "データ解析エラー: \(error.localizedDescription)"
        case .serverError(let message):
            return "サーバーエラー: \(message)"
        case .unknownError:
            return "不明なエラーが発生しました"
        }
    }
}

/// APIサービスクラス
class APIService {
    static let shared = APIService()
    
    // TODO: 実際のCloud Functions URLに置き換えてください
    private let baseURL = "https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net"
    
    private init() {}
    
    /// ユーザー登録API
    func registerUser(userId: String, phoneNumber: String, fcmToken: String?) async throws -> UserRegistrationResponse {
        let endpoint = "\(baseURL)/registerUser"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = UserRegistrationRequest(
            userId: userId,
            phoneNumber: phoneNumber,
            fcmToken: fcmToken
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                return try decoder.decode(UserRegistrationResponse.self, from: data)
            } else {
                // エラーレスポンスを解析
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.error)
                } else {
                    throw APIError.serverError("ステータスコード: \(httpResponse.statusCode)")
                }
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    /// メッセージ取得API
    func getMessages(userId: String) async throws -> MessagesResponse {
        let endpoint = "\(baseURL)/getMessages?userId=\(userId)"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                return try decoder.decode(MessagesResponse.self, from: data)
            } else {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.error)
                } else {
                    throw APIError.serverError("ステータスコード: \(httpResponse.statusCode)")
                }
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    /// プッシュ通知送信API（テスト用）
    func sendPushNotification(userId: String, text: String) async throws -> PushNotificationResponse {
        let endpoint = "\(baseURL)/sendPushNotification"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = PushNotificationRequest(userId: userId, text: text)
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                return try decoder.decode(PushNotificationResponse.self, from: data)
            } else {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.error)
                } else {
                    throw APIError.serverError("ステータスコード: \(httpResponse.statusCode)")
                }
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

/// エラーレスポンス
struct ErrorResponse: Codable {
    let error: String
    let message: String?
}
