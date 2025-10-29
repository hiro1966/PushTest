# Firebase Blazeプラン - 料金ガイド

## 💳 Blazeプランとは

Blazeプラン（従量課金プラン）は、Firebaseの有料プランですが、**大規模な無料枠が含まれています**。

小規模〜中規模のアプリであれば、実質無料で利用できます。

---

## 🆓 無料枠（月間）

| サービス | 無料枠 |
|---------|-------|
| **Cloud Functions** | |
| - 呼び出し回数 | 200万回 |
| - GB秒 | 40万GB秒 |
| - CPU秒 | 20万CPU秒 |
| - ネットワーク（送信） | 5GB |
| | |
| **Cloud Firestore** | |
| - ドキュメント読み取り | 5万回 |
| - ドキュメント書き込み | 2万回 |
| - ドキュメント削除 | 2万回 |
| - ストレージ | 1GB |
| | |
| **Firebase Cloud Messaging** | |
| - 通知送信 | **無制限（無料）** |

---

## 💰 料金（無料枠を超えた場合）

### Cloud Functions

| 項目 | 料金 |
|------|------|
| 呼び出し（200万回超） | $0.40 / 100万回 |
| GB秒（40万超） | $0.0000025 / GB秒 |
| CPU秒（20万超） | $0.0000100 / CPU秒 |
| ネットワーク（5GB超） | $0.12 / GB |

### Cloud Firestore

| 項目 | 料金 |
|------|------|
| ドキュメント読み取り | $0.06 / 10万回 |
| ドキュメント書き込み | $0.18 / 10万回 |
| ドキュメント削除 | $0.02 / 10万回 |
| ストレージ | $0.18 / GB |

---

## 📊 実際のコスト試算

### シナリオ1: 個人開発・テスト（完全無料）

**想定利用**:
- API呼び出し: 1,000回/月
- Firestore読み取り: 500回/月
- Firestore書き込み: 200回/月
- プッシュ通知: 100回/月

**コスト**: **$0.00**（すべて無料枠内）

---

### シナリオ2: 小規模アプリ（ほぼ無料）

**想定利用**:
- ユーザー数: 100人
- 1人あたり月間10回のプッシュ通知
- API呼び出し: 10,000回/月
- Firestore読み取り: 5,000回/月
- Firestore書き込み: 2,000回/月

**コスト**: **$0.00**（すべて無料枠内）

---

### シナリオ3: 中規模アプリ（少額）

**想定利用**:
- ユーザー数: 1,000人
- 1人あたり月間50回のプッシュ通知
- API呼び出し: 500,000回/月
- Firestore読み取り: 100,000回/月
- Firestore書き込み: 50,000回/月

**コスト内訳**:
- Cloud Functions: $0.00（無料枠内）
- Firestore読み取り: $0.30（5万回超過分）
- Firestore書き込み: $0.54（2万回超過分）
- FCM通知: $0.00（無料）

**合計**: **約$0.84/月**

---

### シナリオ4: 大規模アプリ

**想定利用**:
- ユーザー数: 10,000人
- 1人あたり月間100回のプッシュ通知
- API呼び出し: 5,000,000回/月
- Firestore読み取り: 1,000,000回/月
- Firestore書き込み: 500,000回/月

**コスト内訳**:
- Cloud Functions 呼び出し: $1.20（300万回超過分）
- Cloud Functions 実行時間: 約$2.00
- Firestore読み取り: $5.70（95万回超過分）
- Firestore書き込み: $8.64（48万回超過分）
- FCM通知: $0.00（無料）

**合計**: **約$17.54/月**

---

## 🎯 このプロジェクトでの推定コスト

### 開発・テスト段階

- **月間コスト**: **$0.00**
- APIのテスト呼び出しや開発作業は無料枠で十分

### 本番環境（小規模）

- **ユーザー数**: 10〜100人
- **月間コスト**: **$0.00〜$0.50**
- ほとんどのケースで無料枠内

### 本番環境（中規模）

- **ユーザー数**: 100〜1,000人
- **月間コスト**: **$0.50〜$5.00**
- 無料枠を少し超える程度

---

## 💡 コスト削減のヒント

### 1. 不要なログを削除

```typescript
// 本番環境では console.log を削除
if (process.env.NODE_ENV !== 'production') {
  console.log('Debug info');
}
```

### 2. Firestoreクエリを最適化

```typescript
// ❌ 非効率（全ドキュメントを読み取り）
const allUsers = await db.collection('users').get();

// ✅ 効率的（必要なドキュメントのみ）
const user = await db.collection('users').doc(userId).get();
```

### 3. キャッシュを活用

```typescript
// メモリキャッシュで同じデータの再取得を避ける
let cachedData = null;
if (!cachedData) {
  cachedData = await db.collection('data').doc('id').get();
}
```

### 4. バッチ処理を使用

```typescript
// 複数の書き込みをバッチで実行
const batch = db.batch();
batch.set(ref1, data1);
batch.set(ref2, data2);
await batch.commit(); // 1回の書き込みとしてカウント
```

### 5. 不要な関数を削除

```bash
# 使っていない関数を削除してコストを削減
firebase functions:delete unusedFunction
```

---

## 📈 使用量の監視

### Firebase コンソールで確認

1. https://console.firebase.google.com/ にアクセス
2. プロジェクトを選択
3. 左メニュー「使用状況と請求」をクリック

### アラートの設定

予算アラートを設定して、想定外の課金を防ぎましょう：

1. Firebase コンソール → 使用状況と請求
2. 「予算アラートを作成」
3. アラート金額を設定（例: $5/月）
4. メール通知を有効化

---

## ⚠️ 注意事項

### 無限ループに注意

```typescript
// ❌ 危険: 無限ループで課金が増大
export const badFunction = functions.firestore
  .document('data/{id}')
  .onWrite(async (change, context) => {
    // この関数が自分自身を再トリガーしてしまう
    await change.after.ref.set({ updated: true });
  });

// ✅ 安全: 条件をチェック
export const goodFunction = functions.firestore
  .document('data/{id}')
  .onWrite(async (change, context) => {
    if (change.after.data()?.updated) return; // 既に更新済みならスキップ
    await change.after.ref.set({ updated: true });
  });
```

### 意図しない公開に注意

```javascript
// Firestoreセキュリティルールを必ず設定
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ❌ 危険: 誰でも読み書き可能
    // match /{document=**} {
    //   allow read, write: if true;
    // }
    
    // ✅ 安全: 認証が必要
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🔄 Blazeプランへのアップグレード手順

### ステップ1: アップグレードページにアクセス

```
https://console.firebase.google.com/project/YOUR_PROJECT_ID/usage/details
```

### ステップ2: プランを選択

1. 「Blazeプランにアップグレード」をクリック
2. 利用規約を確認

### ステップ3: 支払い情報を入力

1. クレジットカード情報を入力
2. 請求先住所を入力
3. 「確認」をクリック

### ステップ4: 完了

アップグレードが完了すると、すぐにCloud Functionsをデプロイできるようになります。

---

## 📞 よくある質問

### Q1: 無料枠を超えたら自動で課金される？

**A**: はい。ただし、予算アラートを設定すれば通知が届きます。

### Q2: いつでも無料プランに戻せる？

**A**: いいえ。一度Blazeプランにすると、無料プランには戻せません。ただし、使用を停止すれば課金は発生しません。

### Q3: 開発環境でも課金される？

**A**: はい。本番環境も開発環境も同じプロジェクトなら課金対象です。開発用には別のプロジェクトを作成することをお勧めします。

### Q4: 予算を設定できる？

**A**: 予算アラートは設定できますが、自動で使用を停止する機能はありません。

### Q5: 請求はいつ？

**A**: 月末締めで、翌月初めに請求されます。

---

## 🔗 参考リンク

- [Firebase 料金ページ](https://firebase.google.com/pricing)
- [Cloud Functions 料金計算ツール](https://cloud.google.com/products/calculator)
- [Firestore 料金ガイド](https://firebase.google.com/docs/firestore/quotas)
- [予算アラートの設定](https://cloud.google.com/billing/docs/how-to/budgets)

---

## 📝 まとめ

- ✅ Blazeプランは**大規模な無料枠**がある
- ✅ 小規模アプリなら**実質無料**で使える
- ✅ 予算アラートで**課金を監視**できる
- ✅ コスト削減の**ベストプラクティス**を実践しよう

**安心してBlazeプランにアップグレードして開発を進めましょう！** 🚀
