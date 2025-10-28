# API仕様書

このドキュメントでは、Push通知システムのAPI仕様を詳しく説明します。

## 🌐 ベースURL

```
https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net
```

例:
```
https://us-central1-push-notification-12345.cloudfunctions.net
```

## 🔐 認証

現在のバージョンでは認証は実装されていませんが、本番環境では以下の認証方式を推奨します：

- Firebase Authentication トークン
- APIキー
- OAuth 2.0

## 📡 API一覧

### 1. ユーザー登録 API

ユーザーのID、電話番号、FCMトークンをFirestoreに登録します。

#### エンドポイント
```
POST /registerUser
```

#### リクエストヘッダー
```
Content-Type: application/json
```

#### リクエストボディ
```json
{
  "userId": "string (required)",
  "phoneNumber": "string (required)",
  "fcmToken": "string (optional)"
}
```

**フィールド説明:**
- `userId`: ユーザーを識別する一意のID（英数字）
- `phoneNumber`: 国際形式の電話番号（例: `+819012345678`）
- `fcmToken`: Firebase Cloud Messaging トークン（オプション）

#### レスポンス

**成功時 (200 OK)**
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

**エラー時 (400 Bad Request)**
```json
{
  "error": "Missing required fields: userId and phoneNumber are required"
}
```

**エラー時 (500 Internal Server Error)**
```json
{
  "error": "Internal server error",
  "message": "詳細なエラーメッセージ"
}
```

#### curlコマンド例
```bash
curl -X POST https://YOUR_URL/registerUser \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user123",
    "phoneNumber": "+819012345678",
    "fcmToken": "fcm_token_here"
  }'
```

---

### 2. プッシュ通知送信 API

指定されたユーザーにメッセージを送信し、プッシュ通知を配信します。

#### エンドポイント
```
POST /sendPushNotification
```

#### リクエストヘッダー
```
Content-Type: application/json
```

#### リクエストボディ
```json
{
  "userId": "string (required)",
  "text": "string (required)"
}
```

**フィールド説明:**
- `userId`: 送信先ユーザーのID
- `text`: 送信するメッセージ本文

#### レスポンス

**成功時 (200 OK) - 通知送信成功**
```json
{
  "success": true,
  "message": "Push notification sent successfully",
  "data": {
    "userId": "user123",
    "phoneNumber": "+819012345678",
    "messageId": "msg_doc_id_12345",
    "notificationSent": true,
    "fcmResponse": "projects/xxx/messages/xxx"
  }
}
```

**成功時 (200 OK) - メッセージ保存済みだが通知送信失敗**
```json
{
  "success": true,
  "message": "Message saved but push notification failed",
  "data": {
    "userId": "user123",
    "phoneNumber": "+819012345678",
    "messageId": "msg_doc_id_12345",
    "notificationSent": false,
    "error": "FCMトークンが無効です"
  }
}
```

**エラー時 (404 Not Found)**
```json
{
  "error": "User not found",
  "message": "The specified userId does not exist in the database"
}
```

**エラー時 (400 Bad Request)**
```json
{
  "error": "Missing required fields: userId and text are required"
}
```

#### curlコマンド例
```bash
curl -X POST https://YOUR_URL/sendPushNotification \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user123",
    "text": "これはテストメッセージです"
  }'
```

---

### 3. メッセージ取得 API

指定されたユーザーの未読メッセージを取得します。取得後、メッセージはFirestoreから削除されます。

#### エンドポイント
```
GET /getMessages
```

#### クエリパラメータ
```
userId=string (required)
```

**パラメータ説明:**
- `userId`: メッセージを取得するユーザーのID

#### レスポンス

**成功時 (200 OK) - メッセージあり**
```json
{
  "success": true,
  "message": "Messages retrieved successfully",
  "data": {
    "userId": "user123",
    "messages": [
      {
        "messageId": "msg_id_1",
        "text": "メッセージ1の内容",
        "createdAt": "2024-01-01T00:00:00.000Z"
      },
      {
        "messageId": "msg_id_2",
        "text": "メッセージ2の内容",
        "createdAt": "2024-01-01T00:01:00.000Z"
      }
    ],
    "count": 2
  }
}
```

**成功時 (200 OK) - メッセージなし**
```json
{
  "success": true,
  "message": "No messages found",
  "data": {
    "userId": "user123",
    "messages": [],
    "count": 0
  }
}
```

**エラー時 (400 Bad Request)**
```json
{
  "error": "Missing required parameter: userId"
}
```

#### curlコマンド例
```bash
curl -X GET "https://YOUR_URL/getMessages?userId=user123"
```

---

### 4. ヘルスチェック API

APIの稼働状況を確認します。

#### エンドポイント
```
GET /healthCheck
```

#### レスポンス

**成功時 (200 OK)**
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "service": "push-notification-api"
}
```

#### curlコマンド例
```bash
curl -X GET https://YOUR_URL/healthCheck
```

---

## 📊 Firestoreデータ構造

### usersコレクション

```typescript
{
  userId: string;           // ユーザーID
  phoneNumber: string;      // 電話番号（国際形式）
  fcmToken: string;         // Firebase Cloud Messaging トークン
  createdAt: Timestamp;     // 作成日時
  updatedAt: Timestamp;     // 更新日時
}
```

**インデックス:**
- `userId` (自動)

**例:**
```json
{
  "userId": "user123",
  "phoneNumber": "+819012345678",
  "fcmToken": "dXJ3Y2x...lmZGJr",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

### messagesコレクション

```typescript
{
  userId: string;           // ユーザーID
  text: string;             // メッセージ本文
  createdAt: Timestamp;     // 作成日時
  read: boolean;            // 既読フラグ
}
```

**インデックス（必要）:**
- 複合インデックス: `userId` (Ascending) + `read` (Ascending) + `createdAt` (Descending)

**例:**
```json
{
  "userId": "user123",
  "text": "これはテストメッセージです",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "read": false
}
```

---

## 🔄 ワークフロー

### ユーザー登録からメッセージ受信までの流れ

```
1. [iPhoneアプリ] ユーザーがユーザーIDと電話番号を入力
   ↓
2. [iPhoneアプリ] FCMトークンを取得
   ↓
3. [iPhoneアプリ] POST /registerUser でユーザー登録
   ↓
4. [Cloud Functions] Firestoreにユーザー情報を保存
   ↓
5. [外部システム] POST /sendPushNotification でメッセージ送信
   ↓
6. [Cloud Functions] Firestoreにメッセージを保存
   ↓
7. [Cloud Functions] FCMでプッシュ通知を送信
   ↓
8. [iPhoneアプリ] プッシュ通知を受信して表示
   ↓
9. [iPhoneアプリ] GET /getMessages でメッセージを取得
   ↓
10. [Cloud Functions] Firestoreからメッセージを削除
```

---

## ⚠️ エラーコード

| HTTPステータス | エラーコード | 説明 |
|--------------|------------|------|
| 200 | - | 成功 |
| 204 | - | OPTIONSリクエスト成功 |
| 400 | Bad Request | リクエストパラメータが不正 |
| 404 | Not Found | ユーザーが見つからない |
| 405 | Method Not Allowed | HTTPメソッドが不正 |
| 500 | Internal Server Error | サーバー内部エラー |

---

## 🧪 テストシナリオ

### シナリオ1: 正常なユーザー登録とメッセージ受信

```bash
# 1. ユーザー登録
curl -X POST https://YOUR_URL/registerUser \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test_user_001",
    "phoneNumber": "+819012345678",
    "fcmToken": "test_fcm_token"
  }'

# 2. メッセージ送信
curl -X POST https://YOUR_URL/sendPushNotification \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test_user_001",
    "text": "テストメッセージ"
  }'

# 3. メッセージ取得
curl -X GET "https://YOUR_URL/getMessages?userId=test_user_001"

# 4. 再度取得（空になっているはず）
curl -X GET "https://YOUR_URL/getMessages?userId=test_user_001"
```

### シナリオ2: エラーハンドリング

```bash
# 1. 必須パラメータ不足
curl -X POST https://YOUR_URL/registerUser \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test_user"
  }'
# → 400 Bad Request

# 2. 存在しないユーザーにメッセージ送信
curl -X POST https://YOUR_URL/sendPushNotification \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "nonexistent_user",
    "text": "テスト"
  }'
# → 404 Not Found

# 3. 不正なHTTPメソッド
curl -X DELETE https://YOUR_URL/registerUser
# → 405 Method Not Allowed
```

---

## 📈 パフォーマンス

### レスポンスタイム目安

| API | 平均レスポンスタイム |
|-----|------------------|
| registerUser | 100-300ms |
| sendPushNotification | 200-500ms |
| getMessages | 100-200ms |
| healthCheck | 50-100ms |

### レート制限

Cloud Functionsのデフォルト制限：
- 同時実行数: 1000（プロジェクトごと）
- タイムアウト: 60秒
- メモリ: 256MB

本番環境では適切なレート制限を実装してください。

---

## 🔒 セキュリティ考慮事項

### 推奨される実装

1. **認証**
   ```typescript
   // Firebase Authenticationの検証
   const decodedToken = await admin.auth().verifyIdToken(idToken);
   const uid = decodedToken.uid;
   ```

2. **入力検証**
   ```typescript
   // 電話番号の厳格な検証
   import { parsePhoneNumber } from 'libphonenumber-js';
   const phone = parsePhoneNumber(phoneNumber);
   if (!phone.isValid()) throw new Error('Invalid phone number');
   ```

3. **レート制限**
   ```typescript
   // Cloud Functions用のレート制限ミドルウェア
   import rateLimit from 'express-rate-limit';
   const limiter = rateLimit({
     windowMs: 15 * 60 * 1000,
     max: 100
   });
   ```

4. **CORS設定**
   ```typescript
   // 特定のオリジンのみ許可
   res.set('Access-Control-Allow-Origin', 'https://your-app.com');
   ```

---

## 📚 関連リンク

- [Firebase Cloud Functions ドキュメント](https://firebase.google.com/docs/functions)
- [Firebase Cloud Messaging ドキュメント](https://firebase.google.com/docs/cloud-messaging)
- [Firestore ドキュメント](https://firebase.google.com/docs/firestore)
- [REST API ベストプラクティス](https://restfulapi.net/)
