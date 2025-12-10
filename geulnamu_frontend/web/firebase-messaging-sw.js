// Firebase Messaging Service Worker for PWA Push Notifications
// 글나무 앱 - 푸시 알림 서비스 워커 v2.3
// 🎯 핵심: push 이벤트에서 직접 알림 표시 (포그라운드/백그라운드 모두 지원)

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

console.log('🔔 [FCM-SW] Firebase Messaging Service Worker v2.3 로드됨');

// ===========================================
// 알림 타입별 URL 생성
// ===========================================
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

// ===========================================
// 🎯 Push 이벤트에서 직접 알림 표시 (핵심!)
// ===========================================
self.addEventListener('push', (event) => {
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('📥 [FCM-SW] Push 이벤트 수신!', new Date().toISOString());
  
  if (!event.data) {
    console.log('⚠️ [FCM-SW] Push 데이터 없음');
    return;
  }
  
  let payload;
  try {
    payload = event.data.json();
    console.log('📥 [FCM-SW] Payload:', JSON.stringify(payload));
  } catch (e) {
    console.error('❌ [FCM-SW] Payload 파싱 실패:', e);
    return;
  }
  
  // 🎯 data 필드에서 알림 정보 추출
  const data = payload.data || {};
  
  const notificationTitle = data.title || payload.notification?.title || '글나무 알림';
  const notificationBody = data.body || payload.notification?.body || '새로운 알림이 있습니다.';
  
  console.log('📥 [FCM-SW] 알림 제목:', notificationTitle);
  console.log('📥 [FCM-SW] 알림 내용:', notificationBody);
  console.log('📥 [FCM-SW] 알림 데이터:', JSON.stringify(data));
  
  const notificationOptions = {
    body: notificationBody,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: data.tag || 'geulnamu-notification-' + Date.now(),
    data: data,  // 🎯 클릭 시 사용할 데이터
    vibrate: [100, 50, 100],
    requireInteraction: false,
    // 🎯 알림 클릭 시 자동으로 닫히도록
    renotify: true
  };
  
  console.log('📥 [FCM-SW] 알림 표시 중...');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  
  // 🎯 알림 표시
  event.waitUntil(
    self.registration.showNotification(notificationTitle, notificationOptions)
      .then(() => {
        console.log('✅ [FCM-SW] 알림 표시 완료!');
      })
      .catch((error) => {
        console.error('❌ [FCM-SW] 알림 표시 실패:', error);
      })
  );
});

// ===========================================
// 🎯 알림 클릭 처리 (핵심!)
// ===========================================
self.addEventListener('notificationclick', (event) => {
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('🔔 [FCM-SW] 알림 클릭!', new Date().toISOString());
  
  // 1️⃣ 알림 닫기
  event.notification.close();
  
  // 2️⃣ 목적지 URL 생성
  const notificationData = event.notification.data;
  const targetUrl = getNotificationUrl(notificationData);
  
  console.log('🔔 [FCM-SW] notification.data:', JSON.stringify(notificationData));
  console.log('🔔 [FCM-SW] 목적지 URL:', targetUrl);
  
  // 3️⃣ 스플래시 경유 URL (새 창용)
  const splashUrl = '/splash?pending=' + encodeURIComponent(targetUrl);
  const fullUrl = new URL(splashUrl, self.location.origin).href;
  
  console.log('🔔 [FCM-SW] 새 창용 URL:', fullUrl);
  
  // 4️⃣ 🎯 핵심: 기존 창 확인 → postMessage 또는 openWindow
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true })
      .then((windowClients) => {
        console.log('🔍 [FCM-SW] 열린 창 수:', windowClients.length);
        
        // 🎯 글나무 앱 창 찾기
        let targetClient = null;
        for (const client of windowClients) {
          console.log('  - 창 URL:', client.url);
          if (client.url.includes(self.location.origin)) {
            targetClient = client;
            break;  // 첫 번째 매칭되는 창 사용
          }
        }
        
        if (targetClient) {
          // ✅ 기존 창 있음 → postMessage로 이동 요청
          console.log('✅ [FCM-SW] 기존 창 발견! postMessage 전송...');
          
          targetClient.postMessage({
            type: 'NOTIFICATION_CLICK',
            url: targetUrl,
            data: notificationData
          });
          
          console.log('✅ [FCM-SW] postMessage 전송 완료!');
          
          // 창 포커스
          return targetClient.focus()
            .then(() => console.log('✅ [FCM-SW] 창 포커스 성공!'))
            .catch((e) => console.log('⚠️ [FCM-SW] 창 포커스 실패:', e.message));
        } else {
          // ❌ 기존 창 없음 → 새 창 열기
          console.log('📭 [FCM-SW] 기존 창 없음, 새 창 열기...');
          console.log('📭 [FCM-SW] URL:', fullUrl);
          
          return clients.openWindow(fullUrl)
            .then((windowClient) => {
              if (windowClient) {
                console.log('✅ [FCM-SW] 새 창 열기 성공!');
              } else {
                console.log('⚠️ [FCM-SW] 새 창 열렸지만 windowClient null');
              }
            })
            .catch((error) => {
              console.error('❌ [FCM-SW] openWindow 실패:', error);
              // Fallback: 루트 URL로 시도
              return clients.openWindow(new URL('/', self.location.origin).href);
            });
        }
      })
      .catch((error) => {
        console.error('❌ [FCM-SW] clients.matchAll 실패:', error);
        // Fallback: 새 창 열기 시도
        return clients.openWindow(fullUrl);
      })
  );
  
  console.log('🔔 [FCM-SW] waitUntil 등록 완료');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
});

// ===========================================
// 기타 이벤트
// ===========================================
self.addEventListener('notificationclose', (event) => {
  console.log('🔕 [FCM-SW] 알림 닫힘 (사용자가 무시)');
});

// 🎯 onBackgroundMessage는 제거 (push 이벤트에서 직접 처리)
// messaging.onBackgroundMessage는 백그라운드에서만 작동하므로
// 포그라운드/백그라운드 모두 지원하려면 push 이벤트 사용

console.log('✅ [FCM-SW] 초기화 완료');
