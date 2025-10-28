//
//  ContentView.swift
//  PushNotificationApp
//
//  メイン画面
//

import SwiftUI

struct ContentView: View {
    @StateObject private var registrationVM = RegistrationViewModel()
    @StateObject private var messageVM = MessageViewModel()
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // ホーム画面
            HomeView(registrationVM: registrationVM, messageVM: messageVM)
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }
                .tag(0)
            
            // メッセージ一覧
            MessageListView(viewModel: messageVM)
                .tabItem {
                    Label("メッセージ", systemImage: "message.fill")
                }
                .badge(messageVM.unreadCount > 0 ? messageVM.unreadCount : nil)
                .tag(1)
            
            // 設定画面
            SettingsView(registrationVM: registrationVM)
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .onChange(of: notificationManager.shouldShowMessages) { shouldShow in
            if shouldShow {
                selectedTab = 1
                notificationManager.shouldShowMessages = false
            }
        }
        .onAppear {
            // アプリ起動時にメッセージを取得
            if registrationVM.isRegistered {
                Task {
                    await messageVM.fetchMessages()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(NotificationManager.shared)
    }
}
