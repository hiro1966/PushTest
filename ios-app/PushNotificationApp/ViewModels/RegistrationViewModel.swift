//
//  RegistrationViewModel.swift
//  PushNotificationApp
//
//  ユーザー登録画面のViewModel
//

import Foundation
import Combine

@MainActor
class RegistrationViewModel: ObservableObject {
    @Published var userId: String = ""
    @Published var phoneNumber: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isRegistered: Bool = false
    @Published var successMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSavedUser()
    }
    
    /// 保存されたユーザー情報を読み込み
    private func loadSavedUser() {
        if let savedUserId = UserDefaults.standard.string(forKey: "userId"),
           let savedPhoneNumber = UserDefaults.standard.string(forKey: "phoneNumber") {
            self.userId = savedUserId
            self.phoneNumber = savedPhoneNumber
            self.isRegistered = true
        }
    }
    
    /// 入力検証
    var isValidInput: Bool {
        !userId.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        isValidPhoneNumber(phoneNumber)
    }
    
    /// 電話番号の簡易検証
    private func isValidPhoneNumber(_ number: String) -> Bool {
        let cleaned = number.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        return cleaned.count >= 10 && cleaned.count <= 15
    }
    
    /// ユーザー登録
    func registerUser() async {
        guard isValidInput else {
            errorMessage = "ユーザーIDと有効な電話番号を入力してください"
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            // FCMトークンを取得
            let fcmToken = NotificationManager.shared.fcmToken
            
            // API呼び出し
            let response = try await APIService.shared.registerUser(
                userId: userId.trimmingCharacters(in: .whitespaces),
                phoneNumber: phoneNumber.trimmingCharacters(in: .whitespaces),
                fcmToken: fcmToken
            )
            
            if response.success {
                // 登録成功
                saveUserInfo()
                isRegistered = true
                successMessage = "登録が完了しました！"
                print("登録成功: \(response.message)")
            } else {
                errorMessage = response.message
            }
            
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            print("登録エラー: \(error)")
        } catch {
            errorMessage = "登録に失敗しました: \(error.localizedDescription)"
            print("予期しないエラー: \(error)")
        }
        
        isLoading = false
    }
    
    /// ユーザー情報を保存
    private func saveUserInfo() {
        UserDefaults.standard.set(userId, forKey: "userId")
        UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
        UserDefaults.standard.set(true, forKey: "isRegistered")
    }
    
    /// ユーザー情報をクリア
    func clearUserInfo() {
        userId = ""
        phoneNumber = ""
        isRegistered = false
        
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "phoneNumber")
        UserDefaults.standard.removeObject(forKey: "isRegistered")
    }
    
    /// 電話番号のフォーマット
    func formatPhoneNumber(_ number: String) -> String {
        let cleaned = number.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        
        if cleaned.hasPrefix("+81") {
            // 日本の電話番号
            let withoutPrefix = String(cleaned.dropFirst(3))
            if withoutPrefix.count >= 10 {
                let index1 = withoutPrefix.index(withoutPrefix.startIndex, offsetBy: 2)
                let index2 = withoutPrefix.index(withoutPrefix.startIndex, offsetBy: 6)
                return "+81-\(withoutPrefix[..<index1])-\(withoutPrefix[index1..<index2])-\(withoutPrefix[index2...])"
            }
        }
        
        return cleaned
    }
}
