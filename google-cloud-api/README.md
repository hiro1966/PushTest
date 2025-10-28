# Push通知システム - Google Cloud Functions API

Firebase Cloud Functionsを使用したプッシュ通知システムのバックエンドAPIです。

## 📋 API一覧

### 1. ユーザー登録 API
**エンドポイント**: `POST /registerUser`

ユーザーのID、電話番号、FCMトークンをFirebaseに登録します。

**リクエスト**:
```json
{
  "userId": "user123",
  "phoneNumber": "+819012345678",
  "fcmToken": "fcm_token_here"
}
```

**レスポンス**:
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "userId": "user123",
    "phoneNumber": "+819012345678",
    "registeredAt": "2024-01-01T00:00:00.000Z"
  }
}
```

### 2. プッシュ通知送信 API
**エンドポイント**: `POST /sendPushNotification`

指定されたユーザーにメッセージを送信し、プッシュ通知を送ります。

**リクエスト**:
```json
{
  "userId": "user123",
  "text": "これはテストメッセージです"
}
```

**レスポンス**:
```json
{
  "success": true,
  "message": "Push notification sent successfully",
  "data": {
    "userId": "user123",
    "phoneNumber": "+819012345678",
    "messageId": "message_doc_id",
    "notificationSent": true
  }
}
```

### 3. メッセージ取得 API
**エンドポイント**: `GET /getMessages?userId=user123`

指定されたユーザーの未読メッセージを取得します。取得後、メッセージは削除されます。

**レスポンス**:
```json
{
  "success": true,
  "message": "Messages retrieved successfully",
  "data": {
    "userId": "user123",
    "messages": [
      {
        "messageId": "msg_id_1",
        "text": "メッセージ1",
        "createdAt": "2024-01-01T00:00:00.000Z"
      },
      {
        "messageId": "msg_id_2",
        "text": "メッセージ2",
        "createdAt": "2024-01-01T00:01:00.000Z"
      }
    ],
    "count": 2
  }
}
```

### 4. ヘルスチェック API
**エンドポイント**: `GET /healthCheck`

APIの稼働状況を確認します。

**レスポンス**:
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "service": "push-notification-api"
}
```

## 🚀 セットアップ手順

### 1. 前提条件
- Node.js 18以上
- Firebase CLI
- Google Cloud アカウント
- Firebaseプロジェクト

### 2. Firebase CLIのインストール
```bash
npm install -g firebase-tools
```

### 3. Firebaseにログイン
```bash
firebase login
```

### 4. 依存関係のインストール
```bash
npm install
```

### 5. Firebaseプロジェクトの設定
`.firebaserc`ファイルを編集して、あなたのFirebaseプロジェクトIDを設定してください：

```json
{
  "projects": {
    "default": "your-firebase-project-id"
  }
}
```

### 6. Firestoreのセットアップ

Firebaseコンソールで以下のコレクションを作成してください：

- `users` - ユーザー情報
  - フィールド: `userId`, `phoneNumber`, `fcmToken`, `createdAt`, `updatedAt`
  
- `messages` - メッセージデータ
  - フィールド: `userId`, `text`, `createdAt`, `read`

#### インデックスの作成（必要に応じて）

Firestoreコンソールで以下の複合インデックスを作成：
- Collection: `messages`
- Fields: `userId` (Ascending), `read` (Ascending), `createdAt` (Descending)

### 7. ビルド
```bash
npm run build
```

### 8. ローカルテスト（エミュレータ）
```bash
npm run serve
```

### 9. デプロイ
```bash
firebase deploy --only functions
```

## 🔒 セキュリティ

本番環境では以下のセキュリティ対策を実装してください：

1. **認証**: Firebase Authentication を使用した認証
2. **レート制限**: Cloud Functionsのレート制限設定
3. **入力検証**: より厳密な入力検証
4. **セキュリティルール**: Firestoreセキュリティルールの設定
5. **APIキー**: 環境変数での機密情報管理

### Firestoreセキュリティルール例

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ユーザーコレクション
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // メッセージコレクション
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

## 🧪 テスト

### curlでのテスト例

#### ユーザー登録
```bash
curl -X POST https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/registerUser \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test_user",
    "phoneNumber": "+819012345678",
    "fcmToken": "test_fcm_token"
  }'
```

#### プッシュ通知送信
```bash
curl -X POST https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/sendPushNotification \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test_user",
    "text": "テストメッセージ"
  }'
```

#### メッセージ取得
```bash
curl -X GET "https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/getMessages?userId=test_user"
```

## 📊 Firestoreデータ構造

### usersコレクション
```typescript
{
  userId: string;           // ユーザーID
  phoneNumber: string;      // 電話番号
  fcmToken: string;         // FCMトークン
  createdAt: Timestamp;     // 作成日時
  updatedAt: Timestamp;     // 更新日時
}
```

### messagesコレクション
```typescript
{
  userId: string;           // ユーザーID
  text: string;             // メッセージテキスト
  createdAt: Timestamp;     // 作成日時
  read: boolean;            // 既読フラグ
}
```

## 🔧 トラブルシューティング

### デプロイエラー
- Firebase CLIが最新版か確認: `firebase --version`
- ログイン状態を確認: `firebase login --reauth`
- プロジェクトIDが正しいか確認: `firebase use --add`

### FCM送信エラー
- FCMトークンが有効か確認
- Firebaseプロジェクトの設定を確認
- デバイスがネットワークに接続されているか確認

## 📝 ログの確認

```bash
# リアルタイムログ
firebase functions:log

# 特定の関数のログ
firebase functions:log --only registerUser
```

## 💰 コストの目安

Firebase Cloud Functionsの無料枠：
- 呼び出し: 200万回/月
- GB秒: 40万GB秒/月
- CPU秒: 20万CPU秒/月
- アウトバウンド: 5GB/月

詳細は[Firebase料金ページ](https://firebase.google.com/pricing)を参照してください。

## 🆘 サポート

問題が発生した場合は、以下を確認してください：
- [Firebase Documentation](https://firebase.google.com/docs)
- [Cloud Functions Documentation](https://firebase.google.com/docs/functions)
- [FCM Documentation](https://firebase.google.com/docs/cloud-messaging)
