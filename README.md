# Push通知システム - iPhone App & Google Cloud API

このプロジェクトは、iPhoneアプリとGoogle Cloud Functions（Firebase連携）を使用したプッシュ通知システムです。

## 📁 プロジェクト構成

```
.
├── google-cloud-api/          # Google Cloud Functions API
│   ├── functions/             # Cloud Functions実装
│   ├── package.json
│   └── README.md
├── ios-app/                   # iPhoneアプリケーション
│   ├── PushNotificationApp/   # Swiftソースコード
│   └── README.md
└── docs/                      # ドキュメント
    ├── SETUP.md              # セットアップガイド
    └── API.md                # API仕様書
```

## 🚀 主な機能

### Google Cloud API
1. **ユーザー登録API** - ID・電話番号をFirebaseに登録
2. **プッシュ通知送信API** - ID・テキストを受け取り、PUSH通知を送信
3. **メッセージ取得API** - IDに紐づくテキストを取得（取得後削除）

### iPhoneアプリ
1. **ユーザー登録** - ID・電話番号をAPIに送信
2. **プッシュ通知受信** - 通知の受信・表示
3. **メッセージ表示** - 受信したメッセージの確認

## 🔧 技術スタック

- **Backend**: Google Cloud Functions (Node.js)
- **Database**: Firebase Firestore
- **Push Notification**: Firebase Cloud Messaging (FCM)
- **iOS App**: SwiftUI, iOS 15.0+
- **言語**: TypeScript (Backend), Swift (iOS)

## 📖 セットアップ手順

詳細は各ディレクトリのREADMEを参照してください：

1. [Google Cloud API Setup](./google-cloud-api/README.md)
2. [iOS App Setup](./ios-app/README.md)
3. [詳細セットアップガイド](./docs/SETUP.md)

## 📝 API仕様

詳細は [API仕様書](./docs/API.md) を参照してください。

## ⚠️ 注意事項

- Firebase プロジェクトの作成が必要です
- Apple Developer アカウントが必要です（プッシュ通知用）
- Google Cloud のアカウントとプロジェクトが必要です

## 📄 ライセンス

MIT License
