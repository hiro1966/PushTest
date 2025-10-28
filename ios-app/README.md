# Push通知アプリ - iOS

SwiftUIで構築されたプッシュ通知受信アプリです。Firebase Cloud Messaging (FCM)を使用してプッシュ通知を受信します。

## 📱 機能

### 1. ユーザー登録
- ユーザーIDと電話番号をAPIに送信して登録
- FCMトークンの自動取得と送信
- 登録情報の端末内保存

### 2. プッシュ通知受信
- リアルタイムでプッシュ通知を受信
- アプリがフォアグラウンド・バックグラウンドの両方で通知を表示
- 通知タップでメッセージ一覧画面へ遷移

### 3. メッセージ管理
- 受信したメッセージの一覧表示
- 未読/既読の管理
- メッセージの削除
- サーバーからのメッセージ取得

### 4. 設定画面
- ユーザー情報の表示
- 通知権限の管理
- テスト通知の送信
- ログアウト機能

## 🎨 画面構成

### タブ構成
1. **ホームタブ** - 登録状態とメッセージサマリー
2. **メッセージタブ** - メッセージ一覧と詳細
3. **設定タブ** - ユーザー設定とアプリ情報

## 🚀 セットアップ手順

### 前提条件
- macOS (Xcode 14.0以上)
- iOS 15.0以上のデバイスまたはシミュレーター
- CocoaPods または Swift Package Manager
- Apple Developer アカウント（プッシュ通知用）
- Firebaseプロジェクト

### 1. Firebaseプロジェクトのセットアップ

#### Firebaseコンソールでの設定
1. [Firebase Console](https://console.firebase.google.com/)にアクセス
2. プロジェクトを作成または既存のプロジェクトを選択
3. iOSアプリを追加
   - バンドルID: `com.example.PushNotificationApp` （変更可能）
   - アプリのニックネーム: `Push通知アプリ`
4. `GoogleService-Info.plist`をダウンロード

#### APNs証明書の設定
1. Apple Developer Centerで Push Notification証明書を作成
2. Firebaseコンソールの「プロジェクトの設定」→「Cloud Messaging」タブ
3. APNs証明書または認証キーをアップロード

### 2. プロジェクトのセットアップ

#### リポジトリのクローン
```bash
git clone <repository-url>
cd ios-app
```

#### GoogleService-Info.plistの配置
ダウンロードした`GoogleService-Info.plist`を`PushNotificationApp/`ディレクトリに配置します。

```bash
# GoogleService-Info.plistを配置
cp ~/Downloads/GoogleService-Info.plist PushNotificationApp/
```

#### 依存関係のインストール

**方法1: Swift Package Manager（推奨）**
```bash
# Xcodeでプロジェクトを開く
open PushNotificationApp.xcodeproj

# Xcode内で:
# File > Add Packages...
# https://github.com/firebase/firebase-ios-sdk を追加
# FirebaseMessaging パッケージを選択
```

**方法2: CocoaPods**
```bash
# CocoaPodsのインストール（未インストールの場合）
sudo gem install cocoapods

# 依存関係のインストール
pod install

# Workspaceを開く
open PushNotificationApp.xcworkspace
```

### 3. API URLの設定

`PushNotificationApp/Services/APIService.swift`を開き、`baseURL`を実際のCloud Functions URLに変更します。

```swift
private let baseURL = "https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net"
```

例:
```swift
private let baseURL = "https://us-central1-my-project.cloudfunctions.net"
```

### 4. バンドルIDの設定

Xcodeでプロジェクトを開き、以下を設定します：

1. プロジェクトナビゲーターで`PushNotificationApp`プロジェクトを選択
2. `TARGETS` → `PushNotificationApp`を選択
3. `Signing & Capabilities`タブ
4. `Bundle Identifier`を変更（例: `com.yourcompany.PushNotificationApp`）
5. `Team`を選択

### 5. Capabilitiesの追加

1. `Signing & Capabilities`タブで`+ Capability`をクリック
2. 以下を追加:
   - **Push Notifications**
   - **Background Modes** → `Remote notifications`にチェック

### 6. ビルドと実行

```bash
# Xcodeでビルド
# Command + R または Product > Run
```

⚠️ **重要**: プッシュ通知は実機でのみ動作します。シミュレーターでは受信できません。

## 📝 使い方

### 初回起動時

1. アプリを起動
2. 通知の許可を求められたら「許可」をタップ
3. ホーム画面の「ユーザー登録」をタップ
4. ユーザーIDと電話番号を入力
   - ユーザーID: 半角英数字（例: `user123`）
   - 電話番号: 国際形式（例: `+819012345678`）
5. 「登録する」をタップ

### プッシュ通知の受信

#### 外部からテスト送信
```bash
curl -X POST https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/sendPushNotification \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user123",
    "text": "テストメッセージです"
  }'
```

#### アプリ内からテスト送信
1. 設定タブを開く
2. 「テスト通知を送信」をタップ
3. メッセージを入力して送信

### メッセージの確認

1. 通知をタップ → メッセージタブが開く
2. または、メッセージタブを直接タップ
3. メッセージをタップして詳細を表示
4. スワイプで削除または既読にする

## 🏗️ プロジェクト構成

```
PushNotificationApp/
├── PushNotificationAppApp.swift    # アプリエントリーポイント
├── Models/                          # データモデル
│   ├── User.swift                   # ユーザーモデル
│   └── Message.swift                # メッセージモデル
├── Views/                           # UI画面
│   ├── ContentView.swift            # メインタブビュー
│   ├── HomeView.swift               # ホーム画面
│   ├── RegistrationView.swift      # 登録画面
│   ├── MessageListView.swift       # メッセージ一覧
│   └── SettingsView.swift           # 設定画面
├── ViewModels/                      # ビジネスロジック
│   ├── RegistrationViewModel.swift # 登録画面VM
│   └── MessageViewModel.swift      # メッセージVM
├── Services/                        # サービス層
│   ├── APIService.swift             # API通信
│   └── NotificationManager.swift    # 通知管理
├── Info.plist                       # アプリ設定
└── GoogleService-Info.plist         # Firebase設定
```

## 🔧 設定ファイル

### Info.plist の重要な設定

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>

<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

### APIService.swift

```swift
// Cloud Functions のベースURL
private let baseURL = "https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net"
```

## 🧪 デバッグ

### ログの確認

```swift
// Xcodeコンソールで以下のログを確認
// - "APNSトークン: ..."
// - "FCMトークン保存: ..."
// - "通知追加: ..."
```

### 通知が届かない場合

1. **通知権限を確認**
   - 設定アプリ → Push通知アプリ → 通知
   - 通知が「オン」になっているか確認

2. **FCMトークンを確認**
   - 設定タブでFCMトークンが表示されているか
   - "未取得"の場合は、アプリを再起動

3. **APNs証明書を確認**
   - Firebaseコンソールで証明書が正しく設定されているか

4. **ネットワーク接続を確認**
   - デバイスがインターネットに接続されているか

5. **ユーザー登録を確認**
   - ホーム画面で「登録済み」と表示されているか

### テストコマンド

```bash
# ユーザー登録の確認
curl -X POST https://YOUR_URL/registerUser \
  -H "Content-Type: application/json" \
  -d '{"userId":"test","phoneNumber":"+819012345678","fcmToken":"test_token"}'

# メッセージ取得の確認
curl -X GET "https://YOUR_URL/getMessages?userId=test"
```

## 📱 対応環境

- **iOS**: 15.0以上
- **Xcode**: 14.0以上
- **Swift**: 5.7以上
- **デバイス**: iPhone, iPad（実機のみ）

## 🔒 セキュリティ

### 本番環境での推奨事項

1. **認証の実装**
   - Firebase Authenticationの統合
   - JWTトークンによるAPI認証

2. **通信の暗号化**
   - HTTPSの強制
   -証明書ピン止め（Certificate Pinning）

3. **データの保護**
   - KeychainによるFCMトークンの保存
   - 機密データの暗号化

4. **入力検証**
   - ユーザー入力のサニタイズ
   - SQL/XSS攻撃の防止

## 🐛 トラブルシューティング

### ビルドエラー

**エラー**: `No such module 'Firebase'`
```bash
# 解決方法: 依存関係を再インストール
pod deintegrate
pod install
```

**エラー**: `GoogleService-Info.plist not found`
```bash
# 解決方法: plistファイルを正しい場所に配置
cp GoogleService-Info.plist PushNotificationApp/
```

### 実行時エラー

**エラー**: `User notification permission denied`
- 設定アプリから通知権限を確認
- アプリを削除して再インストール

**エラー**: `API request failed`
- APIService.swiftのbaseURLを確認
- Cloud Functionsがデプロイされているか確認

## 📚 参考資料

- [Firebase iOS SDK](https://firebase.google.com/docs/ios/setup)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications)

## 🆘 サポート

問題が発生した場合：
1. このREADMEのトラブルシューティングを確認
2. Xcodeコンソールでログを確認
3. Firebaseコンソールでログを確認
4. GitHubのIssuesで報告

## 📄 ライセンス

MIT License
