//
//  MessageListView.swift
//  PushNotificationApp
//
//  メッセージ一覧画面
//

import SwiftUI

struct MessageListView: View {
    @ObservedObject var viewModel: MessageViewModel
    @State private var selectedMessage: Message?
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.messages.isEmpty {
                    // 空の状態
                    EmptyMessageView()
                } else {
                    // メッセージリスト
                    List {
                        ForEach(viewModel.messages) { message in
                            MessageRow(message: message)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedMessage = message
                                    viewModel.markAsRead(message.id)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteMessage(message.id)
                                    } label: {
                                        Label("削除", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    if !message.isRead {
                                        Button {
                                            viewModel.markAsRead(message.id)
                                        } label: {
                                            Label("既読", systemImage: "checkmark")
                                        }
                                        .tint(.blue)
                                    }
                                }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
                
                // ローディング表示
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
            .navigationTitle("メッセージ")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !viewModel.messages.isEmpty {
                        Menu {
                            Button(action: {
                                viewModel.markAllAsRead()
                            }) {
                                Label("すべて既読にする", systemImage: "checkmark.circle")
                            }
                            
                            Button(role: .destructive, action: {
                                showDeleteAlert = true
                            }) {
                                Label("すべて削除", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.fetchMessages()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .refreshable {
                await viewModel.fetchMessages()
            }
            .sheet(item: $selectedMessage) { message in
                MessageDetailView(message: message)
            }
            .alert("すべて削除", isPresented: $showDeleteAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("削除", role: .destructive) {
                    viewModel.clearAllMessages()
                }
            } message: {
                Text("すべてのメッセージを削除しますか？")
            }
        }
    }
}

// メッセージ行
struct MessageRow: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // 未読インジケーター
            Circle()
                .fill(message.isRead ? Color.clear : Color.blue)
                .frame(width: 10, height: 10)
                .padding(.top, 5)
            
            // メッセージ内容
            VStack(alignment: .leading, spacing: 8) {
                Text(message.text)
                    .font(.body)
                    .fontWeight(message.isRead ? .regular : .semibold)
                    .lineLimit(2)
                    .foregroundColor(message.isRead ? .secondary : .primary)
                
                Text(formatDate(message.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 既読/未読アイコン
            if !message.isRead {
                Image(systemName: "circle.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// 空のメッセージビュー
struct EmptyMessageView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("メッセージがありません")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("プッシュ通知が届くとここに表示されます")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// メッセージ詳細ビュー
struct MessageDetailView: View {
    let message: Message
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 日時
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text(formatFullDate(message.createdAt))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // メッセージ本文
                    Text(message.text)
                        .font(.body)
                        .lineSpacing(8)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("メッセージ詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

struct MessageListView_Previews: PreviewProvider {
    static var previews: some View {
        MessageListView(viewModel: MessageViewModel())
    }
}
