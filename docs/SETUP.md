# セットアップガイド

このガイドでは、Push通知システム全体のセットアップ手順を説明します。

## 📋 目次

1. [前提条件](#前提条件)
2. [Firebaseプロジェクトのセットアップ](#firebaseプロジェクトのセットアップ)
3. [Google Cloud Functions のデプロイ](#google-cloud-functions-のデプロイ)
4. [iOSアプリのセットアップ](#iOSアプリのセットアップ)
5. [動作確認](#動作確認)
6. [トラブルシューティング](#トラブルシューティング)

---

## 前提条件

### 必要なアカウント
- [ ] Googleアカウント（Firebase/Google Cloud用）
- [ ] Apple Developerアカウント（iOSアプリ用）

### 必要なツール

#### バックエンド開発
- [ ] Node.js 18以上
- [ ] npm または yarn
- [ ] Firebase CLI

#### iOSアプリ開発
- [ ] macOS (Catalina以上)
- [ ] Xcode 14.0以上
- [ ] CocoaPods または Swift Package Manager

### インストール手順

#### Node.jsのインストール
```bash
# Homebrewを使用（macOS）
brew install node@18

# バージョン確認
node --version  # v18.x.x 以上
npm --version   # 9.x.x 以上
```

#### Firebase CLIのインストール
```bash
# グローバルインストール
npm install -g firebase-tools

# バージョン確認
firebase --version

# Firebaseにログイン
firebase login
```

#### CocoaPodsのインストール（iOSアプリ用）
```bash
# Ruby gemでインストール
sudo gem install cocoapods

# バージョン確認
pod --version
```

---

## Firebaseプロジェクトのセットアップ

### 1. Firebaseプロジェクトの作成

1. [Firebase Console](https://console.firebase.google.com/)にアクセス
2. 「プロジェクトを追加」をクリック
3. プロジェクト名を入力（例: `push-notification-app`）
4. Google アナリティクスの設定（オプション）
5. 「プロジェクトを作成」をクリック

### 2. Firestoreデータベースのセットアップ

#### データベースの作成
1. Firebaseコンソールで「Firestore Database」を選択
2. 「データベースを作成」をクリック
3. ロケーションを選択（例: `asia-northeast1` - 東京）
4. セキュリティルールを選択:
   - 開発環境: 「テストモードで開始」
   - 本番環境: 「ロックモードで開始」

#### セキュリティルールの設定

開発環境用（テスト用）:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

本番環境用（推奨）:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // usersコレクション
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null; // Cloud Functionsからの読み取り
    }
    
    // messagesコレクション
    match /messages/{messageId} {
      allow read: if request.auth != null && 
                    request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
      allow delete: if request.auth != null && 
                      request.auth.uid == resource.data.userId;
    }
  }
}
```

#### インデックスの作成

1. Firestoreコンソールで「インデックス」タブを選択
2. 「複合インデックスを作成」をクリック
3. 以下の設定で作成:
   - コレクションID: `messages`
   - フィールド1: `userId` (昇順)
   - フィールド2: `read` (昇順)
   - フィールド3: `createdAt` (降順)

または、`firestore.indexes.json`を使用:
```json
{
  "indexes": [
    {
      "collectionGroup": "messages",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "read", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```

デプロイ:
```bash
firebase deploy --only firestore:indexes
```

### 3. Firebase Cloud Messaging (FCM) のセットアップ

#### APNs証明書の取得と設定

##### Step 1: Apple Developer Centerで証明書を作成

1. [Apple Developer Center](https://developer.apple.com/)にログイン
2. 「Certificates, Identifiers & Profiles」を選択
3. 「Keys」→「+」をクリック
4. キー名を入力（例: `Push Notification Key`）
5. 「Apple Push Notifications service (APNs)」を選択
6. 「Continue」→「Register」をクリック
7. `.p8`ファイルをダウンロード
8. Key IDをメモ

##### Step 2: FirebaseにAPNsキーを登録

1. Firebaseコンソールで「プロジェクトの設定」を開く
2. 「Cloud Messaging」タブを選択
3. 「APNs認証キー」セクションで「アップロード」をクリック
4. ダウンロードした`.p8`ファイルを選択
5. Key IDとTeam IDを入力
6. 「アップロード」をクリック

### 4. iOSアプリの追加

1. Firebaseコンソールのプロジェクト概要ページ
2. 「アプリを追加」→「iOS」を選択
3. 以下の情報を入力:
   - **iOSバンドルID**: `com.example.PushNotificationApp`
     （変更する場合は、Xcodeプロジェクトと一致させる）
   - **アプリのニックネーム**: `Push通知アプリ`
   - **App Store ID**: （オプション）
4. 「アプリを登録」をクリック
5. **GoogleService-Info.plist**をダウンロード
   - ⚠️ このファイルは後でiOSプロジェクトに追加します

---

## Google Cloud Functions のデプロイ

### 1. プロジェクトのクローン

```bash
# リポジトリをクローン
git clone <repository-url>
cd webapp/google-cloud-api
```

### 2. Firebaseプロジェクトの初期化

```bash
# Firebaseプロジェクトを選択
firebase use --add

# プロジェクトIDを入力
# エイリアスを入力（例: production）
```

または、`.firebaserc`を手動で編集:
```json
{
  "projects": {
    "default": "your-firebase-project-id"
  }
}
```

### 3. 依存関係のインストール

```bash
# npm依存関係をインストール
npm install
```

### 4. TypeScriptのビルド

```bash
# TypeScriptをJavaScriptにコンパイル
npm run build
```

エラーがないことを確認してください。

### 5. ローカルでテスト（オプション）

```bash
# Firebase Emulatorで動作確認
npm run serve

# 別のターミナルでテスト
curl http://localhost:5001/YOUR_PROJECT_ID/us-central1/healthCheck
```

### 6. Cloud Functions のデプロイ

```bash
# すべての関数をデプロイ
firebase deploy --only functions

# 特定の関数のみデプロイ
firebase deploy --only functions:registerUser
firebase deploy --only functions:sendPushNotification
firebase deploy --only functions:getMessages
```

デプロイが完成すると、URLが表示されます:
```
✔  functions[registerUser(us-central1)]: Successful create operation.
Function URL (registerUser): https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/registerUser
```

### 7. デプロイ確認

```bash
# ヘルスチェック
curl https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/healthCheck

# レスポンス例:
# {"status":"ok","timestamp":"2024-01-01T00:00:00.000Z","service":"push-notification-api"}
```

---

## iOSアプリのセットアップ

### 1. プロジェクトを開く

```bash
cd ../ios-app
```

### 2. GoogleService-Info.plist の配置

Firebaseコンソールからダウンロードした`GoogleService-Info.plist`を配置します。

```bash
# ダウンロードフォルダから配置
cp ~/Downloads/GoogleService-Info.plist PushNotificationApp/

# ファイルが存在することを確認
ls -l PushNotificationApp/GoogleService-Info.plist
```

### 3. 依存関係のインストール

#### 方法A: Swift Package Manager（推奨）

1. Xcodeでプロジェクトを開く
   ```bash
   open PushNotificationApp.xcodeproj
   ```

2. Xcode内で:
   - File → Add Packages...
   - 検索バーに `https://github.com/firebase/firebase-ios-sdk` を入力
   - バージョンを選択（最新版推奨）
   - 以下のパッケージを追加:
     - `FirebaseCore`
     - `FirebaseMessaging`

#### 方法B: CocoaPods

```bash
# 依存関係をインストール
pod install

# Workspaceを開く
open PushNotificationApp.xcworkspace
```

### 4. API URLの設定

`PushNotificationApp/Services/APIService.swift`を開き、`baseURL`を更新します。

```swift
// 変更前
private let baseURL = "https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net"

// 変更後（実際のURLに置き換え）
private let baseURL = "https://us-central1-push-notification-12345.cloudfunctions.net"
```

### 5. バンドルIDの設定

1. Xcodeでプロジェクトを選択
2. `TARGETS` → `PushNotificationApp`
3. `Signing & Capabilities`タブ
4. `Bundle Identifier`を確認または変更
   - Firebaseで登録したバンドルIDと一致させる
   - 例: `com.example.PushNotificationApp`
5. `Team`を選択

### 6. Capabilitiesの追加

`Signing & Capabilities`タブで:

1. `+ Capability`をクリック
2. **Push Notifications**を追加
3. **Background Modes**を追加
   - `Remote notifications`にチェック

### 7. ビルドと実行

⚠️ **重要**: プッシュ通知は実機でのみ動作します

1. iPhoneを接続
2. Xcodeで実機を選択
3. Command + R でビルド・実行

---

## 動作確認

### 1. アプリの初回起動

1. アプリを起動
2. 通知の許可を求められる → **許可**をタップ
3. ホーム画面が表示される

### 2. ユーザー登録

1. 「ユーザー登録」をタップ
2. ユーザーID: `test_user_001`
3. 電話番号: `+819012345678`
4. 「登録する」をタップ
5. 「登録が完了しました！」と表示される

### 3. プッシュ通知のテスト

#### 方法A: アプリ内から送信

1. 「設定」タブを開く
2. 「テスト通知を送信」をタップ
3. メッセージを入力: `テストメッセージ`
4. 「送信」をタップ
5. 通知が表示されることを確認

#### 方法B: curlコマンドで送信

```bash
# プッシュ通知を送信
curl -X POST https://YOUR_URL/sendPushNotification \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test_user_001",
    "text": "curlからのテストメッセージ"
  }'
```

### 4. メッセージの確認

1. 通知をタップ → メッセージ画面が開く
2. または「メッセージ」タブを直接タップ
3. メッセージが表示されることを確認

### 5. メッセージ取得APIのテスト

```bash
# メッセージを取得
curl -X GET "https://YOUR_URL/getMessages?userId=test_user_001"

# レスポンスにメッセージが含まれることを確認

# 再度取得（空になっているはず）
curl -X GET "https://YOUR_URL/getMessages?userId=test_user_001"
```

---

## トラブルシューティング

### Firebaseデプロイエラー

#### エラー: "Firebase CLI is not authenticated"
```bash
# 再ログイン
firebase logout
firebase login
```

#### エラー: "Permission denied"
```bash
# IAM権限を確認
# Firebaseコンソール → プロジェクト設定 → ユーザーと権限
# 必要な権限: 編集者またはオーナー
```

#### エラー: "Function deployment failed"
```bash
# ログを確認
firebase functions:log

# ビルドエラーを確認
npm run build
```

### iOSアプリのビルドエラー

#### エラー: "No such module 'Firebase'"
```bash
# CocoaPodsの場合
pod deintegrate
pod install

# SPMの場合
# Xcode: File → Packages → Reset Package Caches
```

#### エラー: "GoogleService-Info.plist not found"
```bash
# ファイルを正しい場所に配置
cp ~/Downloads/GoogleService-Info.plist PushNotificationApp/

# Xcodeでプロジェクトに追加
# プロジェクトナビゲーター → 右クリック → Add Files to "PushNotificationApp"
```

#### エラー: "Provisioning profile doesn't include the aps-environment entitlement"
```
解決方法:
1. Xcode: Signing & Capabilities
2. Push Notificationsが追加されているか確認
3. 追加されていない場合: + Capability → Push Notifications
4. クリーンビルド: Product → Clean Build Folder
```

### プッシュ通知が届かない

#### 1. 通知権限を確認
```
iPhoneの設定アプリ → Push通知アプリ → 通知
→ 通知を許可がオンになっているか確認
```

#### 2. FCMトークンを確認
```
アプリの設定タブ → FCMトークンが表示されているか
→ "未取得"の場合はアプリを再起動
```

#### 3. APNs証明書を確認
```
Firebaseコンソール → プロジェクトの設定 → Cloud Messaging
→ APNs認証キーが正しく設定されているか確認
```

#### 4. デバッグログを確認
```
Xcode: View → Debug Area → Show Debug Area
→ コンソールで "APNSトークン" や "FCMトークン" が出力されているか
```

#### 5. Firestoreデータを確認
```
Firebaseコンソール → Firestore Database
→ usersコレクションにユーザーが登録されているか
→ fcmTokenフィールドが空でないか
```

### APIエラー

#### エラー: "CORS policy"
```typescript
// Cloud Functionsのコードを確認
res.set('Access-Control-Allow-Origin', '*');
res.set('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
res.set('Access-Control-Allow-Headers', 'Content-Type');
```

#### エラー: "User not found"
```bash
# ユーザーが登録されているか確認
curl -X POST https://YOUR_URL/registerUser \
  -H "Content-Type: application/json" \
  -d '{"userId":"test_user","phoneNumber":"+819012345678"}'
```

---

## 次のステップ

✅ セットアップが完了したら:

1. [API仕様書](./API.md)を確認
2. セキュリティルールを本番環境用に更新
3. 認証機能の実装を検討
4. モニタリング・ログの設定
5. 本番環境へのデプロイ

---

## 参考リンク

- [Firebase ドキュメント](https://firebase.google.com/docs)
- [Cloud Functions ドキュメント](https://firebase.google.com/docs/functions)
- [FCM iOS クライアント](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [Firestore セキュリティルール](https://firebase.google.com/docs/firestore/security/get-started)
- [Apple Push Notifications](https://developer.apple.com/notifications/)

---

## サポート

問題が発生した場合:
1. このガイドのトラブルシューティングを確認
2. Cloud Functionsのログを確認: `firebase functions:log`
3. Xcodeのコンソールログを確認
4. GitHubのIssuesで質問

---

**おめでとうございます！🎉**
Push通知システムのセットアップが完了しました。
