// Firebase Messaging Service Worker for PWA Push Notifications
// 글나무 앱 - 푸시 알림 서비스 워커
// v5 - PWA 우선 이동 + 토론 조 페이지 + 지연 개선

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

// 🎯 알림 타입별 URL 생성
function getNotificationUrl(data) {
  if (!data) return '/home';

  const type = data.type;
  const meetingId = data.meetingId;

  console.log('🎯 [글나무 SW] 알림 데이터 파싱 - type:', type, 'meetingId:', meetingId);

  // 타입별 URL 분기
  switch (type) {
    case 'DISCUSSION_GROUP':
      // 토론 조 알림 → 토론 조 화면
      if (meetingId) {
        return `/discussion-group?meetingId=${meetingId}`;
      }
      return '/home';

    case 'ATTENDANCE':
      // 출석 알림 → 출석 현황 화면
      if (meetingId) {
        return `/attendance/status?meetingId=${meetingId}`;
      }
      return '/home';

    case 'NEW_MEETING':
      // 새 모임 알림 → 모임 상세 화면
      if (meetingId) {
        return `/meeting/${meetingId}`;
      }
      return '/meeting-list';

    case 'ANNOUNCEMENT':
      // 공지사항 → 홈
      return '/home';

    default:
      // 기본: meetingId가 있으면 토론 조 화면으로
      if (meetingId) {
        return `/discussion-group?meetingId=${meetingId}`;
      }
      // route가 지정되어 있으면 해당 경로로
      if (data.route) {
        return data.route;
      }
      // url이 지정되어 있으면 해당 URL로
      if (data.url) {
        return data.url;
      }
      return '/home';
  }
}

// 🎯 PWA 창인지 확인 (manifest.json의 start_url에 ?source=pwa 포함)
function isPwaClient(client) {
  return client.url.includes('source=pwa');
}

// 🎯 열린 창들 중에서 최적의 창 선택 (PWA 우선)
function selectBestClient(clients) {
  if (!clients || clients.length === 0) {
    return null;
  }

  let pwaClient = null;
  let browserClient = null;

  for (const client of clients) {
    // 우리 앱 origin인지 확인
    if (client.url.includes(self.location.origin)) {
      if (isPwaClient(client)) {
        // PWA 창 발견
        if (!pwaClient) {
          pwaClient = client;
          console.log('📱 [글나무 SW] PWA 창 발견:', client.url);
        }
      } else {
        // 일반 브라우저 창 발견
        if (!browserClient) {
          browserClient = client;
          console.log('🌐 [글나무 SW] 브라우저 창 발견:', client.url);
        }
      }
    }
  }

  // PWA 우선, 없으면 브라우저
  if (pwaClient) {
    console.log('✅ [글나무 SW] PWA 창 선택 (우선순위 높음)');
    return pwaClient;
  }
  
  if (browserClient) {
    console.log('✅ [글나무 SW] 브라우저 창 선택 (PWA 없음)');
    return browserClient;
  }

  return null;
}

// 백그라운드 메시지 처리
messaging.onBackgroundMessage((payload) => {
  console.log('📬 [글나무 SW] 백그라운드 메시지 수신:', payload);

  const notificationTitle = payload.notification?.title || '글나무 알림';
  const notificationOptions = {
    body: payload.notification?.body || '새로운 알림이 있습니다.',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: payload.data?.tag || 'geulnamu-notification-' + Date.now(),
    data: payload.data, // 🎯 중요: 데이터를 알림에 저장
    // 진동 패턴 (모바일)
    vibrate: [100, 50, 100],
    // 🎯 알림 클릭 시 자동으로 닫히도록
    requireInteraction: false
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// 🔔 알림 클릭 처리 (v5 - PWA 우선 + 지연 개선)
self.addEventListener('notificationclick', (event) => {
  console.log('🔔 [글나무 SW] 알림 클릭!');
  console.log('  notification:', event.notification);
  console.log('  data:', event.notification.data);

  // 알림 닫기
  event.notification.close();

  // 🎯 알림 데이터에서 URL 생성
  const urlToOpen = getNotificationUrl(event.notification.data);
  const fullUrl = new URL(urlToOpen, self.location.origin).href;
  console.log('🎯 [글나무 SW] 이동할 URL:', urlToOpen);

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true })
      .then((windowClients) => {
        console.log('🔍 [글나무 SW] 열린 창 수:', windowClients.length);

        // 🎯 v5: PWA 우선으로 최적의 창 선택
        const targetClient = selectBestClient(windowClients);

        if (targetClient) {
          console.log('✅ [글나무 SW] 대상 창 선택 완료, 즉시 postMessage 전송');
          
          // 🔥 postMessage를 먼저 전송 (지연 제거!)
          targetClient.postMessage({
            type: 'NOTIFICATION_CLICK',
            url: urlToOpen,
            data: event.notification.data
          });
          console.log('✅ [글나무 SW] postMessage 전송 완료');

          // focus는 별도로 실행 (실패해도 무시)
          targetClient.focus().catch((err) => {
            console.log('⚠️ [글나무 SW] focus 실패 (무시):', err.message);
          });

          return; // 처리 완료
        } else {
          // 열린 창이 없으면 새 창 열기
          console.log('🆕 [글나무 SW] 열린 창 없음, 새 창 열기:', fullUrl);
          return clients.openWindow(fullUrl);
        }
      })
      .catch((error) => {
        console.error('❌ [글나무 SW] 처리 실패:', error);
        // 실패 시 새 창으로 시도
        return clients.openWindow(fullUrl);
      })
  );
});

// 알림 닫기 이벤트
self.addEventListener('notificationclose', (event) => {
  console.log('🔕 [글나무 SW] 알림 닫힘:', event.notification);
});

// 🔥 푸시 이벤트 (포그라운드에서도 알림 표시를 위해)
self.addEventListener('push', (event) => {
  console.log('📨 [글나무 SW] Push 이벤트 수신');
  
  if (event.data) {
    try {
      const payload = event.data.json();
      console.log('📨 [글나무 SW] Push 데이터:', payload);
    } catch (e) {
      console.log('📨 [글나무 SW] Push 텍스트:', event.data.text());
    }
  }
});

console.log('🔥 [글나무 SW] Firebase Messaging Service Worker 로드 완료 (v5 - PWA 우선)');
