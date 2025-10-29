# デプロイメントノート

## 🚀 デプロイ前の確認事項

### 1. Node.jsバージョン

現在の対応バージョン:
- **推奨**: Node.js 18.x または 20.x
- **サポート**: Node.js 18以上

お使いの環境がNode.js 24の場合でも問題なく動作します。

```bash
node --version
# v24.3.0 でも動作します
```

### 2. 依存関係のインストール

初回デプロイ時、または`package.json`を変更した後：

```bash
cd google-cloud-api

# 依存関係をインストール
npm install

# ビルド
npm run build
```

### 3. 警告について

以下の警告は**無視して問題ありません**：

#### ✅ npm warn EBADENGINE
```
npm warn EBADENGINE Unsupported engine {
npm warn EBADENGINE   package: 'push-notification-api@1.0.0',
npm warn EBADENGINE   required: { node: '>=18' },
npm warn EBADENGINE   current: { node: 'v24.3.0', npm: '11.5.2' }
npm warn EBADENGINE }
```

**理由**: Node.js 24でも下位互換性があり、正常に動作します。

#### ✅ 非推奨パッケージ警告
```
npm warn deprecated inflight@1.0.6
npm warn deprecated glob@7.2.3
npm warn deprecated glob@8.1.0
npm warn deprecated google-p12-pem@4.0.1
```

**理由**: これらはFirebase SDKの依存関係であり、直接使用していません。Firebase SDKのアップデートで解決されます。

### 4. セキュリティ監査

✅ **現在の状態**: 脆弱性 0件

```bash
npm audit
# found 0 vulnerabilities
```

以前のバージョン（firebase-admin 11.x）では4つの脆弱性がありましたが、最新版（12.x）で解決されています。

---

## 📦 デプロイ手順

### 標準的なデプロイ

```bash
cd google-cloud-api

# 1. ビルド
npm run build

# 2. デプロイ
firebase deploy --only functions

# または、すべてをデプロイ
firebase deploy
```

### 特定の関数のみデプロイ

```bash
# 単一の関数をデプロイ
firebase deploy --only functions:registerUser

# 複数の関数をデプロイ
firebase deploy --only functions:registerUser,functions:sendPushNotification
```

### 初回デプロイ時

```bash
# 1. Firebaseプロジェクトを選択
firebase use --add
# プロジェクトIDを入力: your-project-id
# エイリアスを入力: production

# 2. または、既存のプロジェクトを使用
firebase use your-project-id

# 3. デプロイ
firebase deploy --only functions
```

---

## ⚠️ よくある問題と解決方法

### 問題1: "EBADENGINE" 警告が出る

**症状**:
```
npm warn EBADENGINE Unsupported engine
```

**解決方法**:
これは警告であり、エラーではありません。無視して続行してください。

### 問題2: デプロイ時に "Permission denied" エラー

**症状**:
```
Error: HTTP Error: 403, The caller does not have permission
```

**解決方法**:
```bash
# 1. 再ログイン
firebase logout
firebase login

# 2. プロジェクトの権限を確認
# Firebaseコンソール → プロジェクト設定 → ユーザーと権限
# あなたのアカウントが「編集者」または「オーナー」であることを確認
```

### 問題3: ビルドエラー

**症状**:
```
error TS2304: Cannot find name 'XXX'
```

**解決方法**:
```bash
# node_modulesを削除して再インストール
rm -rf node_modules package-lock.json
npm install
npm run build
```

### 問題4: Functions のタイムアウト

**症状**:
```
Function execution took 60000 ms, finished with status: 'timeout'
```

**解決方法**:

`firebase.json`に追加:
```json
{
  "functions": {
    "source": ".",
    "predeploy": ["npm run build"],
    "runtime": "nodejs20",
    "timeoutSeconds": 120,
    "memory": "512MB"
  }
}
```

---

## 🔧 環境別の設定

### 開発環境

```bash
# ローカルエミュレータで実行
npm run serve

# 別のターミナルでテスト
curl http://localhost:5001/YOUR_PROJECT_ID/us-central1/healthCheck
```

### ステージング環境

```bash
# ステージング環境を設定
firebase use staging

# デプロイ
firebase deploy --only functions
```

### 本番環境

```bash
# 本番環境を設定
firebase use production

# 本番環境変数を設定（必要に応じて）
firebase functions:config:set someservice.key="THE API KEY"

# デプロイ
firebase deploy --only functions
```

---

## 📊 デプロイ後の確認

### 1. 関数が正常にデプロイされたか確認

```bash
# デプロイされた関数のリスト
firebase functions:list

# 出力例:
# ┌────────────────────────┬────────────┬─────────────────┐
# │ Function               │ Region     │ Trigger         │
# ├────────────────────────┼────────────┼─────────────────┤
# │ registerUser           │ us-central1│ HTTPS           │
# │ sendPushNotification   │ us-central1│ HTTPS           │
# │ getMessages            │ us-central1│ HTTPS           │
# │ healthCheck            │ us-central1│ HTTPS           │
# └────────────────────────┴────────────┴─────────────────┘
```

### 2. ヘルスチェック

```bash
# ヘルスチェックAPIを呼び出し
curl https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/healthCheck

# 期待される出力:
# {"status":"ok","timestamp":"2024-10-29T...","service":"push-notification-api"}
```

### 3. ログの確認

```bash
# リアルタイムログ
firebase functions:log

# 特定の関数のログ
firebase functions:log --only registerUser

# 最近のログ（最新20件）
firebase functions:log --lines 20
```

---

## 💰 コストの管理

### 無料枠（Spark プラン）

- **呼び出し**: 200万回/月
- **GB秒**: 40万GB秒/月
- **CPU秒**: 20万CPU秒/月
- **アウトバウンド**: 5GB/月

### 有料プラン（Blaze プラン）

従量課金制。詳細は[Firebase料金ページ](https://firebase.google.com/pricing)を参照。

### コスト削減のヒント

1. **関数のメモリを最適化**
   ```json
   {
     "functions": {
       "memory": "256MB"  // デフォルトは256MB
     }
   }
   ```

2. **不要な関数を削除**
   ```bash
   firebase functions:delete FUNCTION_NAME
   ```

3. **ログを適切に管理**
   - 本番環境では不要な`console.log`を削除
   - エラーログのみを出力

---

## 🔄 更新手順

### コードを更新した場合

```bash
# 1. コードを編集
# 2. ビルド
npm run build

# 3. デプロイ
firebase deploy --only functions
```

### 依存関係を更新した場合

```bash
# 1. package.jsonを更新
# 2. 依存関係を再インストール
npm install

# 3. セキュリティ監査
npm audit

# 4. ビルド
npm run build

# 5. デプロイ
firebase deploy --only functions
```

---

## 📝 チェックリスト

デプロイ前に確認:

- [ ] `npm install` を実行した
- [ ] `npm run build` でビルドが成功した
- [ ] `npm audit` でセキュリティ問題がない（または許容範囲内）
- [ ] `.firebaserc` で正しいプロジェクトが選択されている
- [ ] `firebase.json` の設定が正しい
- [ ] 環境変数が設定されている（必要な場合）
- [ ] Firestoreのインデックスが作成されている
- [ ] Firestoreのセキュリティルールが設定されている

デプロイ後に確認:

- [ ] `firebase functions:list` で関数が表示される
- [ ] ヘルスチェックAPIが正常に応答する
- [ ] ログにエラーがない
- [ ] テストAPIで動作確認

---

## 🆘 サポート

問題が解決しない場合:

1. **ログを確認**
   ```bash
   firebase functions:log
   ```

2. **Firebase ステータスページを確認**
   https://status.firebase.google.com/

3. **ドキュメントを参照**
   - [Firebase Cloud Functions ドキュメント](https://firebase.google.com/docs/functions)
   - [このプロジェクトのSETUP.md](../docs/SETUP.md)

4. **GitHub Issuesで報告**
   https://github.com/hiro1966/PushTest/issues

---

**デプロイ成功を祈ります！🚀**
