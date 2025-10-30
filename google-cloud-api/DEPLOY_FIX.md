# デプロイエラーの修正ガイド

## 🔴 発生したエラー

```
Error: There was an error reading /package.json:
functions/index.js does not exist, can't deploy Cloud Functions
```

## 🔧 修正内容

### 問題の原因

Firebase Functionsは以下の構造を期待していました：

```
google-cloud-api/
├── functions/
│   └── index.js      ← ここを探していた
└── package.json
```

しかし、実際のビルド出力は：

```
google-cloud-api/
├── lib/
│   └── index.js      ← ここに生成されていた
├── functions/
│   └── index.ts      ← TypeScriptソース
└── package.json
```

### 解決方法

`firebase.json`を修正して、`lib`ディレクトリを正しく参照するようにしました。

---

## ✅ 修正後のデプロイ手順

### 1. ビルド

```bash
cd google-cloud-api
npm run build
```

これにより、`lib/index.js`が生成されます。

### 2. デプロイ

```bash
firebase deploy --only functions
```

または

```bash
npm run deploy
```

---

## 📁 修正されたファイル

### `firebase.json`

**修正前**:
```json
{
  "functions": {
    "source": ".",
    "predeploy": ["npm run build"],
    "runtime": "nodejs20"
  }
}
```

**修正後**:
```json
{
  "functions": {
    "source": "lib",
    "runtime": "nodejs20",
    "ignore": [
      ".git",
      "firebase-debug.log",
      "firebase-debug.*.log",
      "*.local"
    ]
  }
}
```

### `package.json`

**修正前**:
```json
{
  "main": "functions/index.js",
  "scripts": {
    "build": "tsc",
    "deploy": "npm run build && gcloud functions deploy"
  }
}
```

**修正後**:
```json
{
  "main": "lib/index.js",
  "scripts": {
    "build": "tsc",
    "deploy": "npm run build && firebase deploy --only functions"
  }
}
```

### `lib/package.json`（新規作成）

```json
{
  "name": "push-notification-api",
  "version": "1.0.0",
  "main": "index.js",
  "engines": {
    "node": ">=18"
  },
  "dependencies": {
    "firebase-admin": "^13.0.0",
    "firebase-functions": "^6.0.0",
    "express": "^4.18.2"
  }
}
```

---

## 🧪 動作確認

### ローカルビルドのテスト

```bash
cd google-cloud-api

# ビルド
npm run build

# lib/index.jsが生成されたか確認
ls -la lib/

# 期待される出力:
# -rw-r--r-- 1 user user 11526 index.js
# -rw-r--r-- 1 user user  8378 index.js.map
# -rw-r--r-- 1 user user   331 package.json
```

### ローカルエミュレータでテスト

```bash
npm run serve
```

別のターミナルで：
```bash
curl http://localhost:5001/YOUR_PROJECT_ID/us-central1/healthCheck
```

期待される出力：
```json
{
  "status": "ok",
  "timestamp": "2024-10-30T...",
  "service": "push-notification-api"
}
```

---

## 📋 デプロイチェックリスト

デプロイ前に確認：

- [ ] `npm install` を実行した
- [ ] `npm run build` でエラーなくビルドできた
- [ ] `lib/index.js` が存在する
- [ ] `lib/package.json` が存在する
- [ ] Blazeプランにアップグレード済み
- [ ] `firebase use --add` でプロジェクトを選択済み

デプロイ実行：

```bash
firebase deploy --only functions
```

デプロイ後に確認：

- [ ] `firebase functions:list` で関数が表示される
- [ ] ヘルスチェックAPIが応答する
- [ ] ログにエラーがない

---

## 🔄 今後のワークフロー

### 開発時

1. TypeScriptファイル（`functions/index.ts`）を編集
2. `npm run build` でビルド
3. `npm run serve` でローカルテスト
4. 問題なければコミット

### デプロイ時

1. `npm run build` でビルド
2. `firebase deploy --only functions`
3. デプロイ成功を確認

---

## ⚠️ 注意事項

### `lib/`ディレクトリについて

- ✅ `lib/index.js` と `lib/index.js.map` は `.gitignore` で除外
- ✅ `lib/package.json` のみGitに含める
- ✅ デプロイ前に必ず `npm run build` を実行

### ビルドを忘れた場合

```bash
# このエラーが出る
Error: functions/index.js does not exist

# 解決方法
npm run build
firebase deploy --only functions
```

---

## 🆘 トラブルシューティング

### Q: デプロイ時に "package.json not found" エラー

**A**: `lib/package.json` が存在するか確認してください。

```bash
ls -la lib/package.json
```

存在しない場合：
```bash
# このガイドの手順に従って lib/package.json を作成
```

### Q: ビルド後も index.js が生成されない

**A**: `tsconfig.json` の `outDir` を確認してください。

```json
{
  "compilerOptions": {
    "outDir": "lib"  // ← これが正しいか確認
  }
}
```

### Q: デプロイは成功するが関数が動かない

**A**: ログを確認してください。

```bash
firebase functions:log

# または特定の関数のログ
firebase functions:log --only registerUser
```

---

## 📚 参考情報

- [Firebase Functions: TypeScript の使用](https://firebase.google.com/docs/functions/typescript)
- [Firebase CLI リファレンス](https://firebase.google.com/docs/cli)

---

**これでデプロイエラーが解決し、正常にデプロイできるようになりました！** 🎉
