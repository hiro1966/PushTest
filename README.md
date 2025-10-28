# Push通知システム - iPhone App & Google Cloud API

このプロジェクトは、iPhoneアプリとGoogle Cloud Functions（Firebase連携）を使用した、フルスタックのプッシュ通知システムです。

## 🚀 クイックスタート

5分で始めたい方は **[QUICKSTART.md](./QUICKSTART.md)** をご覧ください！

詳細なセットアップは **[docs/SETUP.md](./docs/SETUP.md)** を参照してください。

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

## 📖 ドキュメント

| ドキュメント | 説明 |
|------------|------|
| [QUICKSTART.md](./QUICKSTART.md) | 5分で動かすクイックガイド ⚡ |
| [docs/SETUP.md](./docs/SETUP.md) | 詳細なセットアップ手順 📖 |
| [docs/API.md](./docs/API.md) | API仕様書（エンドポイント詳細） 📡 |
| [PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md) | プロジェクト全体のサマリー 📋 |
| [google-cloud-api/README.md](./google-cloud-api/README.md) | Cloud Functions詳細 ☁️ |
| [ios-app/README.md](./ios-app/README.md) | iOSアプリ詳細 📱 |

## ⚠️ 注意事項

- Firebase プロジェクトの作成が必要です
- Apple Developer アカウントが必要です（プッシュ通知用）
- Google Cloud のアカウントとプロジェクトが必要です

## 📄 ライセンス

MIT License
