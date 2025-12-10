// Firebase Messaging Service Worker for PWA Push Notifications
// 글나무 앱 - 푸시 알림 서비스 워커 v2.0
// 🎯 개선: 안전한 창 열기 + 상세 로깅

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

console.log('🔔 [FCM-SW] Firebase Messaging Service Worker 로드됨');

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

// 백그라운드 메시지 처리 (data-only 메시지 방식)
messaging.onBackgroundMessage((payload) => {
  console.log('📨 [FCM-SW] 백그라운드 메시지 수신:', payload);
  
  // 🎯 data-only 메시지: title/body를 payload.data에서 가져옴
  const notificationTitle = payload.data?.title || '글나무 알림';
  const notificationOptions = {
    body: payload.data?.body || '새로운 알림이 있습니다.',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: payload.data?.tag || 'geulnamu-notification-' + Date.now(),
    data: payload.data,
    vibrate: [100, 50, 100],
    requireInteraction: false
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// ===========================================
// 🎯 알림 클릭 처리 (핵심 로직)
// ===========================================
self.addEventListener('notificationclick', (event) => {
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('🔔 [FCM-SW] 알림 클릭 이벤트 시작!');
  console.log('🔔 [FCM-SW] 시간:', new Date().toISOString());
  
  event.notification.close();

  const notificationData = event.notification.data;
  console.log('🔔 [FCM-SW] notification.data:', JSON.stringify(notificationData));

  const urlToOpen = getNotificationUrl(notificationData);
  console.log('🔔 [FCM-SW] 이동할 URL:', urlToOpen);

  // 🎯 핵심: waitUntil로 Promise 완료까지 Service Worker 유지
  event.waitUntil(
    handleNotificationClick(urlToOpen, notificationData)
  );
});

// 🎯 알림 클릭 처리 로직 (분리)
async function handleNotificationClick(urlToOpen, notificationData) {
  try {
    console.log('🔍 [FCM-SW] 열린 창 검색 중...');
    
    // 1️⃣ 열린 창 확인
    const windowClients = await clients.matchAll({ 
      type: 'window', 
      includeUncontrolled: true 
    });
    
    console.log('🔍 [FCM-SW] 열린 창 수:', windowClients.length);
    windowClients.forEach((client, index) => {
      console.log(`  [${index}] URL: ${client.url}, focused: ${client.focused}`);
    });

    const targetClient = selectBestClient(windowClients);

    // 2️⃣ 기존 창이 있으면 postMessage
    if (targetClient) {
      console.log('✅ [FCM-SW] 기존 창 발견! postMessage 전송...');
      
      targetClient.postMessage({
        type: 'NOTIFICATION_CLICK',
        url: urlToOpen,
        data: notificationData
      });
      
      try {
        await targetClient.focus();
        console.log('✅ [FCM-SW] 창 포커스 성공!');
      } catch (focusError) {
        console.log('⚠️ [FCM-SW] 창 포커스 실패 (무시):', focusError.message);
      }
      
      return;
    }

    // 3️⃣ 기존 창 없음 → 새 창 열기
    console.log('📭 [FCM-SW] 기존 창 없음, 새 창 열기 시도...');
    
    // 🎯 splash 경유 URL
    const splashUrl = `/splash?pending=${encodeURIComponent(urlToOpen)}`;
    const fullUrl = new URL(splashUrl, self.location.origin).href;
    
    console.log('🔗 [FCM-SW] 새 창 URL:', fullUrl);
    
    // 🎯 openWindow 시도 (타임아웃 5초)
    const newWindow = await openWindowWithTimeout(fullUrl, 5000);
    
    if (newWindow) {
      console.log('✅ [FCM-SW] 새 창 열기 성공!');
      console.log('✅ [FCM-SW] 새 창 URL:', newWindow.url);
    } else {
      console.log('⚠️ [FCM-SW] 새 창 열기 실패, fallback 시도...');
      
      // Fallback: 기본 URL로 시도
      await openWindowFallback();
    }
    
  } catch (error) {
    console.error('❌ [FCM-SW] 알림 처리 실패:', error);
    console.error('❌ [FCM-SW] 에러 스택:', error.stack);
    
    // 최후의 수단: 기본 URL 열기
    await openWindowFallback();
  }
  
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}

// 🎯 타임아웃이 있는 openWindow
async function openWindowWithTimeout(url, timeout) {
  return new Promise((resolve) => {
    const timeoutId = setTimeout(() => {
      console.log('⏰ [FCM-SW] openWindow 타임아웃!');
      resolve(null);
    }, timeout);
    
    clients.openWindow(url)
      .then((windowClient) => {
        clearTimeout(timeoutId);
        resolve(windowClient);
      })
      .catch((error) => {
        clearTimeout(timeoutId);
        console.error('❌ [FCM-SW] openWindow 에러:', error);
        resolve(null);
      });
  });
}

// 🎯 Fallback: 기본 URL로 창 열기
async function openWindowFallback() {
  console.log('🔄 [FCM-SW] Fallback: 기본 URL로 시도...');
  
  try {
    // 방법 1: /home으로 직접 시도
    const homeUrl = new URL('/home', self.location.origin).href;
    const window1 = await clients.openWindow(homeUrl);
    
    if (window1) {
      console.log('✅ [FCM-SW] Fallback 성공 (/home)');
      return;
    }
  } catch (e) {
    console.log('⚠️ [FCM-SW] Fallback /home 실패:', e.message);
  }
  
  try {
    // 방법 2: 루트 URL로 시도
    const rootUrl = new URL('/', self.location.origin).href;
    const window2 = await clients.openWindow(rootUrl);
    
    if (window2) {
      console.log('✅ [FCM-SW] Fallback 성공 (/)');
      return;
    }
  } catch (e) {
    console.log('⚠️ [FCM-SW] Fallback / 실패:', e.message);
  }
  
  console.log('❌ [FCM-SW] 모든 Fallback 실패!');
}

// 알림 닫기 이벤트
self.addEventListener('notificationclose', (event) => {
  console.log('🔕 [FCM-SW] 알림 닫힘');
});

// 푸시 이벤트
self.addEventListener('push', (event) => {
  console.log('📥 [FCM-SW] Push 이벤트 수신');
});

console.log('✅ [FCM-SW] Firebase Messaging Service Worker 초기화 완료');
