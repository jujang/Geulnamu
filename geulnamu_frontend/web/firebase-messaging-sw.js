// Firebase Messaging Service Worker for PWA Push Notifications
// 글나무 앱 - 푸시 알림 서비스 워커

importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// Firebase 구성
firebase.initializeApp({
  apiKey: "AIzaSyDqZl2WCbE8GdzPaXY6DHgfV-f2qNpEvPw",
  authDomain: "geulnamu-app.firebaseapp.com",
  projectId: "geulnamu-app",
  storageBucket: "geulnamu-app.firebasestorage.app",
  messagingSenderId: "576790553336",
  appId: "1:576790553336:web:332b81d5870d4a4d04910d",
  measurementId: "G-DD1ESVQNED"
});

const messaging = firebase.messaging();

// 알림 타입별 URL 생성
function getNotificationUrl(data) {
  if (!data) return '/home';

  const type = data.type;
  const meetingId = data.meetingId;

  switch (type) {
    case 'DISCUSSION_GROUP':
      return meetingId ? `/discussion-group?meetingId=${meetingId}` : '/home';

    case 'ATTENDANCE':
      return meetingId ? `/attendance/status?meetingId=${meetingId}` : '/home';

    case 'NEW_MEETING':
      return meetingId ? `/meeting/${meetingId}` : '/meeting-list';

    case 'ANNOUNCEMENT':
      return '/home';

    default:
      if (meetingId) return `/discussion-group?meetingId=${meetingId}`;
      if (data.route) return data.route;
      if (data.url) return data.url;
      return '/home';
  }
}

// PWA 창인지 확인
function isPwaClient(client) {
  return client.url.includes('source=pwa');
}

// 열린 창들 중에서 최적의 창 선택 (PWA 우선)
function selectBestClient(clients) {
  if (!clients || clients.length === 0) return null;

  let pwaClient = null;
  let browserClient = null;

  for (const client of clients) {
    if (client.url.includes(self.location.origin)) {
      if (isPwaClient(client)) {
        if (!pwaClient) pwaClient = client;
      } else {
        if (!browserClient) browserClient = client;
      }
    }
  }

  return pwaClient || browserClient || null;
}

// 백그라운드 메시지 처리
messaging.onBackgroundMessage((payload) => {
  const notificationTitle = payload.notification?.title || '글나무 알림';
  const notificationOptions = {
    body: payload.notification?.body || '새로운 알림이 있습니다.',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: payload.data?.tag || 'geulnamu-notification-' + Date.now(),
    data: payload.data,
    vibrate: [100, 50, 100],
    requireInteraction: false
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// 알림 클릭 처리
self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  const urlToOpen = getNotificationUrl(event.notification.data);
  const fullUrl = new URL(urlToOpen, self.location.origin).href;

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true })
      .then((windowClients) => {
        const targetClient = selectBestClient(windowClients);

        if (targetClient) {
          // 기존 창으로 이동
          targetClient.postMessage({
            type: 'NOTIFICATION_CLICK',
            url: urlToOpen,
            data: event.notification.data
          });

          targetClient.focus().catch(() => {});
          return;
        } else {
          // 새 창 열기
          return clients.openWindow(fullUrl);
        }
      })
      .catch((error) => {
        console.error('[글나무 SW] 알림 처리 실패:', error);
        return clients.openWindow(fullUrl);
      })
  );
});

// 알림 닫기 이벤트
self.addEventListener('notificationclose', (event) => {
  // 필요시 분석용 로깅 추가
});

// 푸시 이벤트
self.addEventListener('push', (event) => {
  // 필요시 분석용 로깅 추가
});
