// Firebase Messaging Service Worker for PWA Push Notifications
// 글나무 앱 - 푸시 알림 서비스 워커

importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// Firebase 구성 (firebase_options.dart의 web 값과 동일)
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

// 백그라운드 메시지 처리
messaging.onBackgroundMessage((payload) => {
  console.log('📬 [글나무 SW] 백그라운드 메시지 수신:', payload);

  const notificationTitle = payload.notification?.title || '글나무 알림';
  const notificationOptions = {
    body: payload.notification?.body || '새로운 알림이 있습니다.',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: payload.data?.tag || 'geulnamu-notification',
    data: payload.data,
    // 진동 패턴 (모바일)
    vibrate: [100, 50, 100],
    // 클릭 시 액션
    actions: [
      { action: 'open', title: '열기' },
      { action: 'close', title: '닫기' }
    ]
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// 알림 클릭 처리
self.addEventListener('notificationclick', (event) => {
  console.log('🔔 [글나무 SW] 알림 클릭:', event.notification);
  event.notification.close();

  // 액션 처리
  if (event.action === 'close') {
    return; // 닫기만 하고 종료
  }

  // 앱으로 이동 (기본 또는 'open' 액션)
  const urlToOpen = event.notification.data?.url || '/home';

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true })
      .then((windowClients) => {
        // 이미 열린 창이 있으면 포커스
        for (const client of windowClients) {
          if (client.url.includes(self.location.origin)) {
            client.focus();
            return client.navigate(urlToOpen);
          }
        }
        // 없으면 새 창 열기
        return clients.openWindow(urlToOpen);
      })
  );
});

// 알림 닫기 이벤트
self.addEventListener('notificationclose', (event) => {
  console.log('🔕 [글나무 SW] 알림 닫힘:', event.notification);
});

console.log('🔥 [글나무 SW] Firebase Messaging Service Worker 로드 완료');
