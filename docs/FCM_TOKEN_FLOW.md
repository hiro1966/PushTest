# FCMトークン取得フロー

このドキュメントでは、iPhoneアプリでFCM（Firebase Cloud Messaging）トークンがどのように取得・登録されるかを説明します。

## 📋 目次

1. [FCMトークンとは](#fcmトークンとは)
2. [トークン取得フロー](#トークン取得フロー)
3. [実装詳細](#実装詳細)
4. [トークン更新のタイミング](#トークン更新のタイミング)
5. [トラブルシューティング](#トラブルシューティング)

---

## FCMトークンとは

**FCMトークン（Firebase Cloud Messaging Token）**は、Firebase Cloud Messagingがプッシュ通知を送信するために使用する、デバイス固有の識別子です。

### APNSトークン vs FCMトークン

| トークン | 説明 | 用途 |
|---------|------|------|
| **APNSトークン** | Apple Push Notification serviceが発行 | Appleのプッシュ通知サービスとの通信 |
| **FCMトークン** | Firebase Messagingが発行（APNSトークンを内部で使用） | Firebaseを経由したプッシュ通知 |

> ⚠️ **重要**: このアプリでは**FCMトークン**を使用します。APNSトークンをそのまま使うわけではありません。

---

## トークン取得フロー

```
1. アプリ起動
   ↓
2. Firebase初期化
   ↓
3. 通知許可をリクエスト
   ↓
4. ユーザーが「許可」をタップ
   ↓
5. APNSトークンをリクエスト
   ↓
6. APNSトークン取得
   ↓
7. APNSトークンをFirebase Messagingに渡す
   ↓
8. Firebase MessagingがFCMトークンを生成
   ↓
9. MessagingDelegate.messaging(_:didReceiveRegistrationToken:) が呼ばれる
   ↓
10. FCMトークンを保存（UserDefaults + NotificationManager）
   ↓
11. ユーザー登録時にFCMトークンをサーバーに送信
```

---

## 実装詳細

### 1. Firebase初期化と設定

**ファイル**: `PushNotificationAppApp.swift`

```swift
import FirebaseCore
import FirebaseMessaging

@main
struct PushNotificationAppApp: App {
    init() {
        // Firebase初期化
        FirebaseApp.configure()
    }
    // ...
}
```

### 2. デリゲートの設定

**ファイル**: `PushNotificationAppApp.swift` - `AppDelegate`

```swift
class AppDelegate: NSObject, UIApplicationDelegate, 
                   UNUserNotificationCenterDelegate, 
                   MessagingDelegate {  // ← MessagingDelegate を追加
    
    func application(_ application: UIApplication, 
                    didFinishLaunchingWithOptions launchOptions: [...]) -> Bool {
        
        // Firebase Messaging デリゲートを設定
        Messaging.messaging().delegate = self
        
        // 通知許可をリクエスト
        UNUserNotificationCenter.current().requestAuthorization(...) { granted, error in
            if granted {
                // APNSトークンをリクエスト
                application.registerForRemoteNotifications()
            }
        }
        
        return true
    }
}
```

### 3. APNSトークン取得

**ファイル**: `PushNotificationAppApp.swift` - `AppDelegate`

```swift
// APNSトークン取得成功時
func application(_ application: UIApplication, 
                didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
    print("📱 APNSトークン取得")
    
    // ★ 重要: APNSトークンをFirebase Messagingに渡す
    Messaging.messaging().apnsToken = deviceToken
}
```

このステップで、Firebase Messagingが内部的にFCMトークンを生成します。

### 4. FCMトークン取得（最重要）

**ファイル**: `PushNotificationAppApp.swift` - `AppDelegate`

```swift
// MARK: - MessagingDelegate

// ★ このメソッドが呼ばれた時にFCMトークンが取得できる
func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    guard let fcmToken = fcmToken else {
        print("❌ FCMトークンが取得できませんでした")
        return
    }
    
    print("🔥 FCMトークン取得成功: \(fcmToken)")
    
    // 1. NotificationManagerに保存（メモリ + UserDefaults）
    NotificationManager.shared.saveFCMToken(fcmToken)
    
    // 2. ユーザーが既に登録済みの場合、サーバーに送信
    if let userId = UserDefaults.standard.string(forKey: "userId"),
       let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber") {
        Task {
            // サーバーのユーザー情報を更新
            try await APIService.shared.registerUser(
                userId: userId,
                phoneNumber: phoneNumber,
                fcmToken: fcmToken
            )
        }
    }
}
```

### 5. FCMトークンの保存

**ファイル**: `NotificationManager.swift`

```swift
class NotificationManager: ObservableObject {
    @Published var fcmToken: String? = nil
    
    // FCMトークンを保存
    func saveFCMToken(_ token: String) {
        // メモリに保存
        self.fcmToken = token
        
        // 永続化（UserDefaults）
        UserDefaults.standard.set(token, forKey: "fcmToken")
        
        print("FCMトークン保存: \(token)")
    }
    
    // アプリ起動時に読み込み
    private func loadFCMToken() {
        if let token = UserDefaults.standard.string(forKey: "fcmToken") {
            self.fcmToken = token
        }
    }
}
```

### 6. ユーザー登録時にサーバーに送信

**ファイル**: `RegistrationViewModel.swift`

```swift
func registerUser() async {
    // FCMトークンを取得
    let fcmToken = NotificationManager.shared.fcmToken
    
    // API呼び出し
    let response = try await APIService.shared.registerUser(
        userId: userId,
        phoneNumber: phoneNumber,
        fcmToken: fcmToken  // ← サーバーに送信
    )
}
```

---

## トークン更新のタイミング

FCMトークンは以下のタイミングで更新されることがあります：

### 1. アプリの初回起動時
- ユーザーが通知を許可
- APNSトークン取得
- FCMトークン生成

### 2. アプリの再インストール時
- 新しいFCMトークンが生成される
- `messaging(_:didReceiveRegistrationToken:)` が呼ばれる

### 3. アプリのアップデート時
- FCMトークンが変更される可能性がある

### 4. トークンの有効期限切れ時
- Firebase Messagingが自動的に更新
- `messaging(_:didReceiveRegistrationToken:)` が呼ばれる

### 5. アプリデータの削除時
- UserDefaultsがクリアされる
- 次回起動時に新しいトークンが生成される

### 自動更新の仕組み

```swift
// AppDelegateのmessaging(_:didReceiveRegistrationToken:)内で
// ユーザーが既に登録済みの場合、自動的にサーバーに送信
if let userId = UserDefaults.standard.string(forKey: "userId") {
    // サーバーのFCMトークンを更新
    APIService.shared.registerUser(userId: userId, ..., fcmToken: fcmToken)
}
```

---

## デバッグ方法

### 1. Xcodeコンソールでログを確認

アプリを実行すると、以下のログが表示されるはずです：

```
✅ 通知の許可が得られました
📱 APNSトークン取得: abc123def456...
🔥 FCMトークン取得成功: fNGh8Yfq...
FCMトークン保存: fNGh8Yfq...
```

### 2. 設定画面でFCMトークンを確認

アプリの「設定」タブで、FCMトークンが表示されます：

```
FCMトークン: fNGh8Yfq...Xt2k (最初の20文字)
```

### 3. トークンが取得できない場合

#### ログに「FCMトークンが取得できませんでした」と表示される

**原因**:
- APNSトークンが取得できていない
- GoogleService-Info.plistが正しく配置されていない
- Push Notifications Capabilityが追加されていない

**解決方法**:
```swift
// 1. GoogleService-Info.plistを確認
// PushNotificationApp/GoogleService-Info.plist が存在するか

// 2. Capabilitiesを確認
// Xcode → Signing & Capabilities
// - Push Notifications が追加されているか
// - Background Modes → Remote notifications にチェック

// 3. 通知許可を確認
// iPhone設定 → Push通知アプリ → 通知が「オン」
```

#### FCMトークンは取得できるが、通知が届かない

**原因**:
- APNs証明書/キーがFirebaseに設定されていない
- バンドルIDが一致していない

**解決方法**:
```
1. Firebaseコンソール → プロジェクト設定 → Cloud Messaging
2. APNs認証キー (.p8ファイル) をアップロード
3. Key IDとTeam IDを入力
4. バンドルIDがXcodeとFirebaseで一致しているか確認
```

---

## トラブルシューティング

### Q1: FCMトークンが表示されない

**確認項目**:
1. ✅ Firebase初期化が完了しているか
   ```swift
   FirebaseApp.configure()
   ```

2. ✅ MessagingDelegateが設定されているか
   ```swift
   Messaging.messaging().delegate = self
   ```

3. ✅ 通知許可が得られているか
   ```
   iPhone設定 → Push通知アプリ → 通知
   ```

4. ✅ GoogleService-Info.plistが正しいか
   ```
   PushNotificationApp/GoogleService-Info.plist
   ```

### Q2: アプリ再起動後にFCMトークンが消える

**原因**: UserDefaultsに保存されていない

**解決方法**:
```swift
// NotificationManager.swiftを確認
func saveFCMToken(_ token: String) {
    self.fcmToken = token
    UserDefaults.standard.set(token, forKey: "fcmToken")  // ← これが必要
}
```

### Q3: サーバーに古いFCMトークンが登録されている

**原因**: トークン更新時にサーバーに送信していない

**解決方法**:
```swift
// AppDelegateのmessaging(_:didReceiveRegistrationToken:)内で
// 既存ユーザーの場合、自動的にサーバーに送信する処理が必要

if let userId = UserDefaults.standard.string(forKey: "userId") {
    // サーバーに最新のFCMトークンを送信
    APIService.shared.registerUser(userId: userId, ..., fcmToken: fcmToken)
}
```

---

## まとめ

### FCMトークンの取得フロー（簡易版）

```
1. アプリ起動
2. Firebase初期化
3. 通知許可
4. APNSトークン → Firebase Messaging
5. FCMトークン生成
6. messaging(_:didReceiveRegistrationToken:) 呼び出し ← ★ここでFCMトークン取得
7. NotificationManagerに保存
8. ユーザー登録時/更新時にサーバーに送信
```

### 重要なポイント

1. **FCMトークンはAPNSトークンとは異なる**
   - Firebase Messagingが内部的にAPNSトークンを使ってFCMトークンを生成

2. **FCMトークンの取得は`MessagingDelegate`で行う**
   - `messaging(_:didReceiveRegistrationToken:)` が呼ばれた時に取得

3. **FCMトークンは自動的に更新される**
   - アプリの再インストール、更新、有効期限切れ時など

4. **サーバーには常に最新のFCMトークンを送信する**
   - ユーザー登録時
   - トークン更新時（自動）

---

## 参考リンク

- [Firebase Cloud Messaging - iOS](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [APNs - Apple Developer](https://developer.apple.com/documentation/usernotifications)
- [Firebase Messaging SDK](https://firebase.google.com/docs/reference/swift/firebasemessaging/api/reference/Classes/Messaging)

---

**これでFCMトークンの取得フローが理解できたはずです！**

質問があれば、[SETUP.md](./SETUP.md)のトラブルシューティングも参照してください。
