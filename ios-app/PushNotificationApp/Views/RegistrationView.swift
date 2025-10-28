//
//  RegistrationView.swift
//  PushNotificationApp
//
//  ユーザー登録画面
//

import SwiftUI

struct RegistrationView: View {
    @ObservedObject var viewModel: RegistrationViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Field?
    
    enum Field {
        case userId, phoneNumber
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // ヘッダー
                VStack(spacing: 10) {
                    Image(systemName: "person.badge.plus.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("ユーザー登録")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("IDと電話番号を入力してください")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 30)
                
                // 入力フォーム
                VStack(spacing: 20) {
                    // ユーザーID
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ユーザーID")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        TextField("例: user123", text: $viewModel.userId)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.username)
                            .autocapitalization(.none)
                            .focused($focusedField, equals: .userId)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .phoneNumber
                            }
                    }
                    
                    // 電話番号
                    VStack(alignment: .leading, spacing: 8) {
                        Text("電話番号")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        TextField("例: +819012345678", text: $viewModel.phoneNumber)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                            .focused($focusedField, equals: .phoneNumber)
                        
                        Text("国際形式（+81から始まる）で入力してください")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // エラーメッセージ
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
                
                // 成功メッセージ
                if let successMessage = viewModel.successMessage {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(successMessage)
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // 登録ボタン
                Button(action: {
                    focusedField = nil
                    Task {
                        await viewModel.registerUser()
                        if viewModel.isRegistered {
                            // 登録成功後、少し待ってから画面を閉じる
                            try? await Task.sleep(nanoseconds: 1_500_000_000)
                            dismiss()
                        }
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                            Text("登録する")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isValidInput && !viewModel.isLoading ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!viewModel.isValidInput || viewModel.isLoading)
                .padding(.horizontal)
                
                // 注意事項
                VStack(alignment: .leading, spacing: 10) {
                    Text("注意事項")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        BulletPoint(text: "ユーザーIDは半角英数字で入力してください")
                        BulletPoint(text: "電話番号は国際形式（+81...）で入力してください")
                        BulletPoint(text: "プッシュ通知を受信するには通知許可が必要です")
                        BulletPoint(text: "登録情報は端末内に保存されます")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer(minLength: 30)
            }
            .padding()
        }
        .navigationTitle("ユーザー登録")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完了") {
                    focusedField = nil
                }
            }
        }
    }
}

// 箇条書きポイント
struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .font(.caption)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegistrationView(viewModel: RegistrationViewModel())
        }
    }
}
