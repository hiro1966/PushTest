# クイックスタートガイド

このガイドでは、最短でPush通知システムを動かす手順を説明します。

## ⚡ 5分でスタート

### 前提条件
- ✅ Googleアカウント（Firebase用）
- ✅ Apple Developerアカウント
- ✅ Mac（Xcode 14以上）
- ✅ iPhone実機

---

## 📱 STEP 1: Firebaseプロジェクトのセットアップ（3分）

### 1-1. プロジェクト作成
1. https://console.firebase.google.com/ にアクセス
2. 「プロジェクトを追加」→ プロジェクト名を入力
3. Googleアナリティクス不要 → 「プロジェクトを作成」

### 1-2. Firestoreを有効化
1. 左メニュー「Firestore Database」→ 「データベースを作成」
2. ロケーション: `asia-northeast1` (東京)
3. 「テストモードで開始」→ 「有効にする」

### 1-3. iOSアプリを追加
1. プロジェクト概要 → 「アプリを追加」→ iOS
2. バンドルID: `com.example.PushNotificationApp`
3. 「アプリを登録」
4. **GoogleService-Info.plist をダウンロード** ⬇️

### 1-4. APNs設定
1. プロジェクト設定 → Cloud Messaging タブ
2. Apple Developer Centerで APNs Key (.p8) を作成
3. Firebaseにアップロード

---

## 🚀 STEP 2: Cloud Functionsをデプロイ（2分）

```bash
# 1. プロジェクトに移動
cd webapp/google-cloud-api

# 2. Firebase CLI インストール（未インストールの場合）
npm install -g firebase-tools

# 3. Firebase ログイン
firebase login

# 4. プロジェクトを選択
firebase use --add
# → プロジェクトIDを入力

# 5. 依存関係インストール
npm install

# 6. デプロイ
firebase deploy --only functions
```

デプロイ完了後、表示されるURLをメモ：
```
https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net
```

---

## 📲 STEP 3: iOSアプリをビルド（2分）

```bash
# 1. iOSプロジェクトに移動
cd ../ios-app

# 2. GoogleService-Info.plist を配置
cp ~/Downloads/GoogleService-Info.plist PushNotificationApp/

# 3. Xcodeで開く
open PushNotificationApp.xcodeproj
```

### Xcodeでの設定

#### 3-1. API URLを更新
`PushNotificationApp/Services/APIService.swift` を開く:
```swift
// 27行目あたり
private let baseURL = "https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net"
// ↓ STEP 2でメモしたURLに変更
private let baseURL = "https://us-central1-your-project.cloudfunctions.net"
```

#### 3-2. Firebase SDKを追加
1. File → Add Packages...
2. `https://github.com/firebase/firebase-ios-sdk` を検索
3. `FirebaseMessaging` を選択して追加

#### 3-3. Signing設定
1. プロジェクトを選択 → TARGETS → PushNotificationApp
2. Signing & Capabilities
3. Team を選択
4. + Capability → **Push Notifications** を追加
5. + Capability → **Background Modes** → `Remote notifications` にチェック

#### 3-4. ビルド・実行
1. iPhone実機を接続
2. デバイスを選択
3. Command + R で実行

---

## ✅ STEP 4: 動作確認（1分）

### アプリで確認

1. **通知許可**: アプリ起動時に「許可」をタップ
2. **ユーザー登録**:
   - ホーム → 「ユーザー登録」
   - ユーザーID: `test001`
   - 電話番号: `+819012345678`
   - 「登録する」
3. **テスト通知送信**:
   - 設定タブ → 「テスト通知を送信」
   - メッセージ入力 → 「送信」
4. **通知確認**: プッシュ通知が届く！🎉

### curlで確認（オプション）

```bash
# プッシュ通知を送信
curl -X POST https://YOUR_URL/sendPushNotification \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test001",
    "text": "Hello from curl!"
  }'
```

---

## 🎯 完了！

おめでとうございます！Push通知システムが動作しています。

### 次のステップ

- 📖 [詳細セットアップガイド](./docs/SETUP.md)
- 📡 [API仕様書](./docs/API.md)
- 🔒 セキュリティルールの設定（本番環境用）

---

## ⚠️ トラブルシューティング

### 通知が届かない場合

#### 1. FCMトークンを確認
```
アプリ → 設定タブ → FCMトークンが表示されているか
```

#### 2. 通知権限を確認
```
iPhone設定 → Push通知アプリ → 通知がオン
```

#### 3. APNs証明書を確認
```
Firebaseコンソール → プロジェクト設定 → Cloud Messaging
→ APNs認証キーが設定されているか
```

#### 4. Xcodeログを確認
```
Xcodeコンソールで以下を確認:
- "APNSトークン: ..."
- "FCMトークン保存: ..."
```

### ビルドエラー

#### "No such module 'Firebase'"
```bash
# SPMの場合
Xcode → File → Packages → Reset Package Caches

# CocoaPodsの場合
pod install
open PushNotificationApp.xcworkspace
```

#### "GoogleService-Info.plist not found"
```bash
# 正しい場所に配置
cp ~/Downloads/GoogleService-Info.plist PushNotificationApp/

# Xcodeでプロジェクトに追加
右クリック → Add Files to "PushNotificationApp"
```

---

## 📞 サポート

問題が発生した場合:
1. [詳細セットアップガイド](./docs/SETUP.md)を確認
2. Xcodeコンソールログを確認
3. `firebase functions:log` でサーバーログを確認
4. GitHubでIssueを作成

---

## 🎓 学習リソース

- [Firebase ドキュメント](https://firebase.google.com/docs)
- [FCM iOS クライアント](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [SwiftUI チュートリアル](https://developer.apple.com/tutorials/swiftui)

---

**Have fun building! 🚀**
