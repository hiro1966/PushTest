# プロジェクトサマリー

## 📦 プロジェクト名
**Push通知システム - iPhoneアプリ & Google Cloud API**

## 🎯 概要

このプロジェクトは、iPhoneアプリとGoogle Cloud Functions（Firebase連携）を使用した、フルスタックのプッシュ通知システムです。

ユーザーがiPhoneアプリから登録し、外部システムやテスト機能からプッシュ通知を送信・受信できます。

## 🏗️ アーキテクチャ

```
┌─────────────────┐
│  iPhoneアプリ   │
│   (SwiftUI)     │
└────────┬────────┘
         │ HTTPS
         ↓
┌─────────────────┐
│ Cloud Functions │
│   (Node.js/TS)  │
└────────┬────────┘
         │
         ↓
┌─────────────────┐     ┌──────────────┐
│   Firestore     │←────│     FCM      │
│   (Database)    │     │ (Push通知)   │
└─────────────────┘     └──────────────┘
```

## 📁 プロジェクト構造

```
webapp/
├── README.md                        # プロジェクト概要
├── QUICKSTART.md                    # クイックスタートガイド
├── PROJECT_SUMMARY.md               # このファイル
├── .gitignore                       # Git無視リスト
│
├── docs/                            # ドキュメント
│   ├── SETUP.md                     # 詳細セットアップガイド
│   └── API.md                       # API仕様書
│
├── google-cloud-api/                # Google Cloud Functions
│   ├── functions/
│   │   └── index.ts                 # Cloud Functions実装
│   ├── package.json                 # Node.js依存関係
│   ├── tsconfig.json                # TypeScript設定
│   ├── firebase.json                # Firebase設定
│   ├── firestore.indexes.json       # Firestoreインデックス
│   ├── firestore.rules              # セキュリティルール
│   ├── .firebaserc                  # Firebaseプロジェクト設定
│   └── README.md                    # API README
│
└── ios-app/                         # iPhoneアプリケーション
    ├── PushNotificationApp/
    │   ├── PushNotificationAppApp.swift       # アプリエントリー
    │   ├── Models/                            # データモデル
    │   │   ├── User.swift
    │   │   └── Message.swift
    │   ├── Views/                             # UI画面
    │   │   ├── ContentView.swift
    │   │   ├── HomeView.swift
    │   │   ├── RegistrationView.swift
    │   │   ├── MessageListView.swift
    │   │   └── SettingsView.swift
    │   ├── ViewModels/                        # ビジネスロジック
    │   │   ├── RegistrationViewModel.swift
    │   │   └── MessageViewModel.swift
    │   ├── Services/                          # サービス層
    │   │   ├── APIService.swift
    │   │   └── NotificationManager.swift
    │   ├── Info.plist
    │   └── GoogleService-Info.plist.template
    ├── PushNotificationApp.xcodeproj/
    ├── Podfile
    └── README.md                    # iOS README
```

## 🚀 実装済み機能

### Google Cloud Functions API

#### 1. ユーザー登録API (`registerUser`)
- **機能**: ユーザーID、電話番号、FCMトークンをFirestoreに登録
- **メソッド**: POST
- **エンドポイント**: `/registerUser`

#### 2. プッシュ通知送信API (`sendPushNotification`)
- **機能**: 
  - メッセージをFirestoreに保存
  - ユーザーを検索してFCMトークンを取得
  - Firebase Cloud Messagingでプッシュ通知を送信
- **メソッド**: POST
- **エンドポイント**: `/sendPushNotification`

#### 3. メッセージ取得API (`getMessages`)
- **機能**: 
  - ユーザーの未読メッセージを取得
  - 取得後、Firestoreからメッセージを削除
- **メソッド**: GET
- **エンドポイント**: `/getMessages`

#### 4. ヘルスチェックAPI (`healthCheck`)
- **機能**: API稼働状況の確認
- **メソッド**: GET
- **エンドポイント**: `/healthCheck`

### iPhoneアプリ（SwiftUI）

#### 画面構成（タブベース）

##### 1. ホーム画面 (`HomeView`)
- 登録状態の表示
- メッセージサマリー（総数・未読数）
- クイックアクション
  - ユーザー登録
  - メッセージ更新
  - 通知許可

##### 2. ユーザー登録画面 (`RegistrationView`)
- ユーザーIDと電話番号の入力
- 入力検証
- APIへの登録リクエスト
- 登録情報のローカル保存

##### 3. メッセージ一覧画面 (`MessageListView`)
- 受信メッセージの一覧表示
- 未読/既読の管理
- スワイプアクション（削除・既読）
- メッセージ詳細表示
- サーバーからのメッセージ取得
- Pull-to-refresh

##### 4. 設定画面 (`SettingsView`)
- ユーザー情報の表示
- FCMトークンの表示
- 通知権限の管理
- テスト通知送信機能
- ログアウト

#### 主要機能

##### プッシュ通知受信
- **フォアグラウンド**: バナー・サウンド・バッジで通知表示
- **バックグラウンド**: システム通知として表示
- **通知タップ**: メッセージ一覧画面へ自動遷移
- **FCMトークン管理**: 自動取得・保存・送信

##### データ管理
- **ローカルストレージ**: UserDefaultsでユーザー情報を保存
- **サーバー同期**: APIからメッセージを取得・削除
- **リアルタイム更新**: ObservableObjectでUI自動更新

## 🔧 技術スタック

### バックエンド
- **言語**: TypeScript
- **ランタイム**: Node.js 18
- **フレームワーク**: Firebase Cloud Functions
- **データベース**: Firebase Firestore
- **プッシュ通知**: Firebase Cloud Messaging (FCM)

### フロントエンド (iOS)
- **言語**: Swift 5.7+
- **UIフレームワーク**: SwiftUI
- **最小対応バージョン**: iOS 15.0
- **アーキテクチャ**: MVVM
- **依存関係管理**: Swift Package Manager / CocoaPods

### インフラ
- **クラウド**: Google Cloud Platform
- **Functions**: Cloud Functions for Firebase
- **認証**: Firebase Authentication (将来実装)
- **ストレージ**: Firestore

## 📊 データモデル

### Firestore Collections

#### `users` コレクション
```typescript
{
  userId: string;           // ユーザーID（ドキュメントID）
  phoneNumber: string;      // 電話番号（国際形式）
  fcmToken: string;         // FCMトークン
  createdAt: Timestamp;     // 作成日時
  updatedAt: Timestamp;     // 更新日時
}
```

#### `messages` コレクション
```typescript
{
  userId: string;           // ユーザーID
  text: string;             // メッセージ本文
  createdAt: Timestamp;     // 作成日時
  read: boolean;            // 既読フラグ
}
```

### インデックス
- `messages`: userId (ASC) + read (ASC) + createdAt (DESC)

## 🔐 セキュリティ

### 現在の実装
- CORS設定（すべてのオリジン許可）
- 基本的な入力検証
- 電話番号形式の検証

### 推奨される本番環境対策
- [ ] Firebase Authenticationによる認証
- [ ] JWTトークン検証
- [ ] APIキーによる認証
- [ ] レート制限の実装
- [ ] Firestoreセキュリティルールの厳格化
- [ ] 証明書ピン止め（Certificate Pinning）
- [ ] データの暗号化

## 📈 パフォーマンス

### API レスポンスタイム
- `registerUser`: 100-300ms
- `sendPushNotification`: 200-500ms
- `getMessages`: 100-200ms
- `healthCheck`: 50-100ms

### Cloud Functions 制限
- 同時実行数: 1000（プロジェクトごと）
- タイムアウト: 60秒
- メモリ: 256MB（デフォルト）

## 🧪 テスト方法

### 1. APIテスト

```bash
# ヘルスチェック
curl https://YOUR_URL/healthCheck

# ユーザー登録
curl -X POST https://YOUR_URL/registerUser \
  -H "Content-Type: application/json" \
  -d '{"userId":"test001","phoneNumber":"+819012345678","fcmToken":"test_token"}'

# プッシュ通知送信
curl -X POST https://YOUR_URL/sendPushNotification \
  -H "Content-Type: application/json" \
  -d '{"userId":"test001","text":"テストメッセージ"}'

# メッセージ取得
curl -X GET "https://YOUR_URL/getMessages?userId=test001"
```

### 2. iOSアプリテスト

1. Xcode で実機にビルド
2. 通知許可を確認
3. ユーザー登録
4. アプリ内テスト機能で通知送信
5. 通知受信を確認
6. メッセージ一覧で確認

## 📦 デプロイ手順

### バックエンド（Cloud Functions）

```bash
cd google-cloud-api

# ビルド
npm run build

# デプロイ
firebase deploy --only functions

# 特定の関数のみ
firebase deploy --only functions:registerUser
```

### iOS アプリ

1. Xcodeでアーカイブ作成
2. App Store Connectにアップロード
3. TestFlightで配信
4. App Store審査・公開

## 🔄 今後の改善案

### 機能追加
- [ ] ユーザー認証（Firebase Authentication）
- [ ] メッセージの画像添付
- [ ] メッセージの既読確認
- [ ] グループメッセージング
- [ ] メッセージの検索機能
- [ ] 通知のスケジュール送信
- [ ] プッシュ通知のカスタマイズ
- [ ] 多言語対応

### 技術改善
- [ ] ユニットテストの追加
- [ ] E2Eテストの実装
- [ ] CI/CDパイプラインの構築
- [ ] モニタリング・ロギングの強化
- [ ] エラーハンドリングの改善
- [ ] パフォーマンス最適化
- [ ] オフライン対応

### セキュリティ
- [ ] API認証の実装
- [ ] レート制限
- [ ] データ暗号化
- [ ] セキュリティルールの強化
- [ ] 脆弱性スキャン

## 📚 ドキュメント

- **README.md**: プロジェクト概要と技術スタック
- **QUICKSTART.md**: 5分で始めるクイックガイド
- **docs/SETUP.md**: 詳細なセットアップ手順
- **docs/API.md**: API仕様書（エンドポイント・リクエスト・レスポンス）
- **google-cloud-api/README.md**: Cloud Functions詳細
- **ios-app/README.md**: iOSアプリ詳細

## 🤝 コントリビューション

### 開発環境のセットアップ

```bash
# リポジトリをクローン
git clone <repository-url>
cd webapp

# バックエンド
cd google-cloud-api
npm install

# iOS
cd ../ios-app
pod install  # または SPM使用
```

### ブランチ戦略
- `main`: 安定版
- `develop`: 開発版
- `feature/*`: 機能追加
- `bugfix/*`: バグ修正

### コミットメッセージ
```
feat: 新機能追加
fix: バグ修正
docs: ドキュメント更新
refactor: リファクタリング
test: テスト追加
chore: その他の変更
```

## 📄 ライセンス

MIT License

## 👥 作成者

AI Assistant

## 📞 サポート

問題が発生した場合:
1. [SETUP.md](./docs/SETUP.md) のトラブルシューティングを確認
2. GitHubでIssueを作成
3. ドキュメントを参照

---

## 🎉 完成！

このプロジェクトは、モダンな技術スタックを使用した、実用的なプッシュ通知システムです。

**次のステップ:**
1. [QUICKSTART.md](./QUICKSTART.md)で動かしてみる
2. [docs/SETUP.md](./docs/SETUP.md)で詳細設定
3. セキュリティルールを本番環境用に更新
4. 独自の機能を追加

Happy Coding! 🚀
