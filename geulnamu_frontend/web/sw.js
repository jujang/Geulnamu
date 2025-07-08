// 글나무 PWA 서비스 워커
// 기본 캐싱 및 오프라인 지원 기능 제공

const CACHE_NAME = 'geulnamu-v1.0.0';
const API_CACHE_NAME = 'geulnamu-api-v1';

// 캐시할 리소스 목록 (중요한 파일들만)
const urlsToCache = [
  '/',
  '/manifest.json',
  '/favicon.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png',
  // Flutter 관련 파일들은 동적으로 추가됨
];

// 서비스 워커 설치 이벤트
self.addEventListener('install', (event) => {
  console.log('글나무 서비스 워커 설치 중...');
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('기본 리소스 캐싱 중...');
        return cache.addAll(urlsToCache);
      })
      .then(() => {
        console.log('글나무 서비스 워커 설치 완료');
        // 새 서비스 워커를 즉시 활성화
        return self.skipWaiting();
      })
      .catch((error) => {
        console.error('서비스 워커 설치 실패:', error);
      })
  );
});

// 서비스 워커 활성화 이벤트
self.addEventListener('activate', (event) => {
  console.log('글나무 서비스 워커 활성화 중...');
  
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          // 현재 버전이 아닌 이전 캐시들을 삭제
          if (cacheName !== CACHE_NAME && cacheName !== API_CACHE_NAME) {
            console.log('이전 캐시 삭제:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      console.log('글나무 서비스 워커 활성화 완료');
      // 모든 클라이언트에 새 서비스 워커 적용
      return self.clients.claim();
    })
  );
});

// 네트워크 요청 가로채기 (fetch 이벤트)
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  
  // API 요청 처리 (네트워크 우선, 실패시 캐시)
  if (url.pathname.startsWith('/api/')) {
    event.respondWith(handleApiRequest(event.request));
    return;
  }
  
  // 정적 리소스 처리 (캐시 우선, 없으면 네트워크)
  event.respondWith(handleStaticRequest(event.request));
});

// API 요청 처리 함수 (네트워크 우선 전략)
async function handleApiRequest(request) {
  try {
    // 네트워크 요청 시도
    const response = await fetch(request);
    
    // 성공시 캐시에 저장 (GET 요청만)
    if (response.ok && request.method === 'GET') {
      const responseClone = response.clone();
      const cache = await caches.open(API_CACHE_NAME);
      cache.put(request, responseClone);
    }
    
    return response;
  } catch (error) {
    console.log('네트워크 오류, 캐시에서 조회:', request.url);
    
    // 네트워크 실패시 캐시에서 반환
    const cachedResponse = await caches.match(request);
    if (cachedResponse) {
      return cachedResponse;
    }
    
    // 캐시도 없으면 오프라인 페이지 반환
    return new Response(
      JSON.stringify({
        error: '오프라인 상태입니다',
        message: '네트워크 연결을 확인해주세요'
      }),
      {
        status: 503,
        statusText: 'Service Unavailable',
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );
  }
}

// 정적 리소스 처리 함수 (캐시 우선 전략)
async function handleStaticRequest(request) {
  try {
    // 캐시에서 먼저 찾기
    const cachedResponse = await caches.match(request);
    if (cachedResponse) {
      return cachedResponse;
    }
    
    // 캐시에 없으면 네트워크에서 가져오기
    const response = await fetch(request);
    
    // 성공시 캐시에 저장
    if (response.ok) {
      const responseClone = response.clone();
      const cache = await caches.open(CACHE_NAME);
      cache.put(request, responseClone);
    }
    
    return response;
  } catch (error) {
    console.log('리소스 로드 실패:', request.url, error);
    
    // HTML 요청이고 실패했으면 메인 페이지 반환 (SPA 라우팅)
    if (request.destination === 'document') {
      const cachedIndexResponse = await caches.match('/');
      if (cachedIndexResponse) {
        return cachedIndexResponse;
      }
    }
    
    // 기본 오류 응답
    return new Response('리소스를 찾을 수 없습니다', {
      status: 404,
      statusText: 'Not Found'
    });
  }
}

// 백그라운드 동기화 이벤트 (추후 구현 예정)
self.addEventListener('sync', (event) => {
  console.log('백그라운드 동기화:', event.tag);
  
  if (event.tag === 'attendance-sync') {
    // 출석 데이터 동기화 로직
    event.waitUntil(syncAttendanceData());
  }
});

// 푸시 알림 이벤트 (추후 구현 예정)
self.addEventListener('push', (event) => {
  console.log('푸시 알림 수신:', event);
  
  if (event.data) {
    const data = event.data.json();
    const options = {
      body: data.body || '글나무에서 알림이 도착했습니다',
      icon: '/icons/Icon-192.png',
      badge: '/icons/Icon-192.png',
      tag: data.tag || 'geulnamu-notification',
      data: data,
    };
    
    event.waitUntil(
      self.registration.showNotification(data.title || '글나무', options)
    );
  }
});

// 알림 클릭 이벤트
self.addEventListener('notificationclick', (event) => {
  console.log('알림 클릭:', event.notification);
  
  event.notification.close();
  
  // 앱 창으로 포커스 이동
  event.waitUntil(
    clients.matchAll({ type: 'window' }).then((clientList) => {
      for (const client of clientList) {
        if (client.url === '/' && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
});

// 출석 데이터 동기화 함수 (추후 구현)
async function syncAttendanceData() {
  try {
    console.log('출석 데이터 동기화 시작');
    // TODO: 오프라인 상태에서 저장된 출석 데이터를 서버로 전송
    console.log('출석 데이터 동기화 완료');
  } catch (error) {
    console.error('출석 데이터 동기화 실패:', error);
  }
}

// 버전 확인 및 업데이트 알림
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
  
  if (event.data && event.data.type === 'GET_VERSION') {
    event.ports[0].postMessage({ version: CACHE_NAME });
  }
});

console.log('글나무 서비스 워커 로드 완료 - 버전:', CACHE_NAME);
