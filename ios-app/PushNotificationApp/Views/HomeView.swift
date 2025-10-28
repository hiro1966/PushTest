//
//  HomeView.swift
//  PushNotificationApp
//
//  ホーム画面
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var registrationVM: RegistrationViewModel
    @ObservedObject var messageVM: MessageViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // ヘッダー
                    VStack(spacing: 10) {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("プッシュ通知アプリ")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("メッセージを受信して確認できます")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // 登録状態カード
                    if registrationVM.isRegistered {
                        RegisteredStatusCard(
                            userId: registrationVM.userId,
                            phoneNumber: registrationVM.phoneNumber,
                            notificationEnabled: notificationManager.notificationPermissionGranted
                        )
                    } else {
                        UnregisteredCard()
                    }
                    
                    // メッセージサマリーカード
                    MessageSummaryCard(
                        totalCount: messageVM.messages.count,
                        unreadCount: messageVM.unreadCount
                    )
                    
                    // クイックアクション
                    VStack(spacing: 15) {
                        if !registrationVM.isRegistered {
                            NavigationLink(destination: RegistrationView(viewModel: registrationVM)) {
                                QuickActionButton(
                                    icon: "person.badge.plus",
                                    title: "ユーザー登録",
                                    color: .blue
                                )
                            }
                        }
                        
                        Button(action: {
                            Task {
                                await messageVM.fetchMessages()
                            }
                        }) {
                            QuickActionButton(
                                icon: "arrow.clockwise",
                                title: "メッセージを更新",
                                color: .green
                            )
                        }
                        .disabled(!registrationVM.isRegistered || messageVM.isLoading)
                        
                        if !notificationManager.notificationPermissionGranted {
                            Button(action: {
                                Task {
                                    await notificationManager.requestNotificationPermission()
                                }
                            }) {
                                QuickActionButton(
                                    icon: "bell.badge",
                                    title: "通知を有効にする",
                                    color: .orange
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .refreshable {
                if registrationVM.isRegistered {
                    await messageVM.fetchMessages()
                }
            }
        }
    }
}

// 登録済みステータスカード
struct RegisteredStatusCard: View {
    let userId: String
    let phoneNumber: String
    let notificationEnabled: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                Text("登録済み")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                InfoRow(label: "ユーザーID", value: userId)
                InfoRow(label: "電話番号", value: phoneNumber)
                
                HStack {
                    Text("通知状態:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    HStack(spacing: 5) {
                        Circle()
                            .fill(notificationEnabled ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        Text(notificationEnabled ? "有効" : "無効")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(notificationEnabled ? .green : .red)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// 未登録カード
struct UnregisteredCard: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("未登録")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("プッシュ通知を受信するには\nユーザー登録が必要です")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// メッセージサマリーカード
struct MessageSummaryCard: View {
    let totalCount: Int
    let unreadCount: Int
    
    var body: some View {
        HStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("\(totalCount)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.blue)
                Text("総メッセージ数")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 60)
            
            VStack(spacing: 8) {
                Text("\(unreadCount)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.red)
                Text("未読")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// 情報行
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text("\(label):")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// クイックアクションボタン
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
        }
        .foregroundColor(.white)
        .padding()
        .background(color)
        .cornerRadius(12)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            registrationVM: RegistrationViewModel(),
            messageVM: MessageViewModel()
        )
        .environmentObject(NotificationManager.shared)
    }
}
