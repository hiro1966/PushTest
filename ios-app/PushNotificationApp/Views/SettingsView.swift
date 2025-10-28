//
//  SettingsView.swift
//  PushNotificationApp
//
//  設定画面
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var registrationVM: RegistrationViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showLogoutAlert = false
    @State private var showTestNotification = false
    @State private var testMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                // ユーザー情報セクション
                if registrationVM.isRegistered {
                    Section("ユーザー情報") {
                        HStack {
                            Text("ユーザーID")
                            Spacer()
                            Text(registrationVM.userId)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("電話番号")
                            Spacer()
                            Text(registrationVM.phoneNumber)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("FCMトークン")
                            Spacer()
                            if let token = notificationManager.fcmToken {
                                Text(String(token.prefix(20)) + "...")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            } else {
                                Text("未取得")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                } else {
                    Section {
                        NavigationLink(destination: RegistrationView(viewModel: registrationVM)) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                    .foregroundColor(.blue)
                                Text("ユーザー登録")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                // 通知設定セクション
                Section("通知設定") {
                    HStack {
                        Text("通知の状態")
                        Spacer()
                        HStack(spacing: 5) {
                            Circle()
                                .fill(notificationManager.notificationPermissionGranted ? Color.green : Color.red)
                                .frame(width: 10, height: 10)
                            Text(notificationManager.notificationPermissionGranted ? "有効" : "無効")
                                .foregroundColor(notificationManager.notificationPermissionGranted ? .green : .red)
                        }
                    }
                    
                    if !notificationManager.notificationPermissionGranted {
                        Button(action: {
                            Task {
                                await notificationManager.requestNotificationPermission()
                            }
                        }) {
                            HStack {
                                Image(systemName: "bell.badge")
                                Text("通知を有効にする")
                            }
                        }
                        
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "gearshape")
                                Text("設定アプリを開く")
                            }
                        }
                    }
                }
                
                // テスト機能セクション（デバッグ用）
                if registrationVM.isRegistered {
                    Section("テスト機能") {
                        Button(action: {
                            showTestNotification = true
                        }) {
                            HStack {
                                Image(systemName: "paperplane")
                                Text("テスト通知を送信")
                            }
                        }
                        
                        Button(action: {
                            Task {
                                do {
                                    try await notificationManager.fetchMessagesFromServer(userId: registrationVM.userId)
                                } catch {
                                    print("メッセージ取得エラー: \(error)")
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.down.circle")
                                Text("サーバーからメッセージ取得")
                            }
                        }
                    }
                }
                
                // アプリ情報セクション
                Section("アプリ情報") {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("ビルド")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
                
                // ログアウトセクション
                if registrationVM.isRegistered {
                    Section {
                        Button(role: .destructive, action: {
                            showLogoutAlert = true
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "arrow.right.square")
                                Text("ログアウト")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("設定")
            .alert("ログアウト", isPresented: $showLogoutAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("ログアウト", role: .destructive) {
                    registrationVM.clearUserInfo()
                    notificationManager.clearAllNotifications()
                }
            } message: {
                Text("登録情報を削除してログアウトしますか？")
            }
            .sheet(isPresented: $showTestNotification) {
                TestNotificationView(
                    userId: registrationVM.userId,
                    isPresented: $showTestNotification
                )
            }
        }
    }
}

// テスト通知送信ビュー
struct TestNotificationView: View {
    let userId: String
    @Binding var isPresented: Bool
    @State private var message = ""
    @State private var isLoading = false
    @State private var resultMessage: String?
    @State private var isError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("テスト通知を送信")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("メッセージ")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    TextEditor(text: $message)
                        .frame(height: 150)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                if let resultMessage = resultMessage {
                    Text(resultMessage)
                        .font(.caption)
                        .foregroundColor(isError ? .red : .green)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: {
                    Task {
                        await sendTestNotification()
                    }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "paperplane.fill")
                            Text("送信")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(message.isEmpty || isLoading ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(message.isEmpty || isLoading)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func sendTestNotification() async {
        isLoading = true
        resultMessage = nil
        
        do {
            let response = try await APIService.shared.sendPushNotification(
                userId: userId,
                text: message
            )
            
            if response.success {
                resultMessage = "✅ 送信成功！"
                isError = false
                
                // 成功後、少し待ってから閉じる
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                isPresented = false
            } else {
                resultMessage = "❌ 送信失敗: \(response.message)"
                isError = true
            }
        } catch {
            resultMessage = "❌ エラー: \(error.localizedDescription)"
            isError = true
        }
        
        isLoading = false
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(registrationVM: RegistrationViewModel())
            .environmentObject(NotificationManager.shared)
    }
}
