import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Firebase Admin初期化
admin.initializeApp();

const db = admin.firestore();

/**
 * ユーザー登録データの型定義
 */
interface UserRegistration {
  userId: string;
  phoneNumber: string;
  fcmToken?: string;
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
}

/**
 * メッセージデータの型定義
 */
interface MessageData {
  userId: string;
  text: string;
  createdAt: admin.firestore.Timestamp;
  read: boolean;
}

/**
 * API 1: ユーザー登録
 * スマホからID、電話番号を受け取りFirebaseに登録する
 */
export const registerUser = functions.https.onRequest(async (req, res) => {
  // CORSヘッダーを設定
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed. Use POST.' });
    return;
  }

  try {
    const { userId, phoneNumber, fcmToken } = req.body;

    // 入力検証
    if (!userId || !phoneNumber) {
      res.status(400).json({ 
        error: 'Missing required fields: userId and phoneNumber are required' 
      });
      return;
    }

    // 電話番号の形式チェック（簡易版）
    const phoneRegex = /^\+?[1-9]\d{1,14}$/;
    if (!phoneRegex.test(phoneNumber.replace(/[-\s]/g, ''))) {
      res.status(400).json({ 
        error: 'Invalid phone number format' 
      });
      return;
    }

    const now = admin.firestore.Timestamp.now();

    // Firestoreにユーザーデータを保存
    const userRef = db.collection('users').doc(userId);
    const userData: UserRegistration = {
      userId,
      phoneNumber,
      fcmToken: fcmToken || '',
      createdAt: now,
      updatedAt: now,
    };

    await userRef.set(userData, { merge: true });

    functions.logger.info(`User registered: ${userId}`, { userId, phoneNumber });

    res.status(200).json({
      success: true,
      message: 'User registered successfully',
      data: {
        userId,
        phoneNumber,
        registeredAt: now.toDate().toISOString(),
      },
    });
  } catch (error) {
    functions.logger.error('Error registering user:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * API 2: プッシュ通知送信
 * IDとテキストを受け取り、Firebaseに登録してPUSH通知を送る
 */
export const sendPushNotification = functions.https.onRequest(async (req, res) => {
  // CORSヘッダーを設定
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed. Use POST.' });
    return;
  }

  try {
    const { userId, text } = req.body;

    // 入力検証
    if (!userId || !text) {
      res.status(400).json({ 
        error: 'Missing required fields: userId and text are required' 
      });
      return;
    }

    const now = admin.firestore.Timestamp.now();

    // 1. メッセージをFirestoreに保存
    const messageRef = db.collection('messages').doc();
    const messageData: MessageData = {
      userId,
      text,
      createdAt: now,
      read: false,
    };

    await messageRef.set(messageData);

    // 2. ユーザー情報を検索
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      functions.logger.warn(`User not found: ${userId}`);
      res.status(404).json({ 
        error: 'User not found',
        message: 'The specified userId does not exist in the database',
      });
      return;
    }

    const userData = userDoc.data() as UserRegistration;
    const { fcmToken, phoneNumber } = userData;

    // 3. FCMトークンが登録されている場合、プッシュ通知を送信
    if (fcmToken && fcmToken.trim() !== '') {
      try {
        const message = {
          notification: {
            title: '新しいメッセージ',
            body: text.length > 100 ? text.substring(0, 100) + '...' : text,
          },
          data: {
            userId,
            messageId: messageRef.id,
            text,
            timestamp: now.toDate().toISOString(),
          },
          token: fcmToken,
        };

        const response = await admin.messaging().send(message);
        functions.logger.info(`Push notification sent: ${response}`, { userId, messageId: messageRef.id });

        res.status(200).json({
          success: true,
          message: 'Push notification sent successfully',
          data: {
            userId,
            phoneNumber,
            messageId: messageRef.id,
            notificationSent: true,
            fcmResponse: response,
          },
        });
      } catch (fcmError) {
        functions.logger.error('Error sending FCM:', fcmError);
        // FCM送信失敗でもメッセージは保存されているのでエラーを返さない
        res.status(200).json({
          success: true,
          message: 'Message saved but push notification failed',
          data: {
            userId,
            phoneNumber,
            messageId: messageRef.id,
            notificationSent: false,
            error: fcmError instanceof Error ? fcmError.message : 'FCM error',
          },
        });
      }
    } else {
      // FCMトークンが未登録の場合
      functions.logger.warn(`FCM token not registered for user: ${userId}`);
      res.status(200).json({
        success: true,
        message: 'Message saved but FCM token not registered',
        data: {
          userId,
          phoneNumber,
          messageId: messageRef.id,
          notificationSent: false,
        },
      });
    }
  } catch (error) {
    functions.logger.error('Error in sendPushNotification:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * API 3: メッセージ取得
 * IDを受け取り、Firebaseからテキストを取得して返す（取得後削除）
 */
export const getMessages = functions.https.onRequest(async (req, res) => {
  // CORSヘッダーを設定
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed. Use GET.' });
    return;
  }

  try {
    const userId = req.query.userId as string;

    // 入力検証
    if (!userId) {
      res.status(400).json({ 
        error: 'Missing required parameter: userId' 
      });
      return;
    }

    // ユーザーのメッセージを検索（未読のみ）
    const messagesRef = db.collection('messages')
      .where('userId', '==', userId)
      .where('read', '==', false)
      .orderBy('createdAt', 'desc');

    const messagesSnapshot = await messagesRef.get();

    if (messagesSnapshot.empty) {
      res.status(200).json({
        success: true,
        message: 'No messages found',
        data: {
          userId,
          messages: [],
        },
      });
      return;
    }

    // メッセージを取得
    const messages = messagesSnapshot.docs.map(doc => {
      const data = doc.data() as MessageData;
      return {
        messageId: doc.id,
        text: data.text,
        createdAt: data.createdAt.toDate().toISOString(),
      };
    });

    // バッチでメッセージを削除
    const batch = db.batch();
    messagesSnapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });
    await batch.commit();

    functions.logger.info(`Messages retrieved and deleted: ${messages.length}`, { userId });

    res.status(200).json({
      success: true,
      message: 'Messages retrieved successfully',
      data: {
        userId,
        messages,
        count: messages.length,
      },
    });
  } catch (error) {
    functions.logger.error('Error in getMessages:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * ヘルスチェック用エンドポイント
 */
export const healthCheck = functions.https.onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'push-notification-api',
  });
});
