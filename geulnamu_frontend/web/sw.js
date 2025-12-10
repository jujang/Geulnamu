// 글나무 PWA 서비스 워커 v2.1
// ✨ 최적화된 캐싱 전략 + 안전한 에러 처리

const CACHE_VERSION = 'v1.1.0';
const CACHE_NAME = `geulnamu-${CACHE_VERSION}`;
const API_CACHE_NAME = `geulnamu-api-${CACHE_VERSION}`;

// 🎯 캐시 용량 제한 (바이트 단위)
const MAX_CACHE_SIZE = 50 * 1024 * 1024; // 50MB
const MAX_API_CACHE_SIZE = 10 * 1024 * 1024; // 10MB

// ⏰ API 캐시 만료 시간 (밀리초)
const API_CACHE_EXPIRATION = 60 * 60 * 1000; // 1시간

// 📦 필수 캐시 리소스 (앱 실행에 필요한 최소한의 파일들만)
const ESSENTIAL_RESOURCES = [
  '/',
  '/manifest.json',
  '/favicon.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
];

// 🚫 캐시하지 않을 URL 패턴
const CACHE_BLACKLIST = [
  /\/api\/login\//,        // 로그인 API
  /\/api\/logout/,         // 로그아웃 API
  /\/auth\/callback/,      // OAuth 콜백 (Vercel rewrites 필요)
  /chrome-extension/,      // 크롬 확장 프로그램
  /\.hot-update\./,        // 핫 리로드 파일
];

// 📊 캐시 통계 추적
let cacheStats = {
  hits: 0,
  misses: 0,
  size: 0,
};

// ===========================================
// 서비스 워커 설치
// ===========================================
self.addEventListener('install', (event) => {
  console.log('🚀 글나무 서비스 워커 설치 중... (v' + CACHE_VERSION + ')');
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('📦 필수 리소스 캐싱 중...');
        return cache.addAll(ESSENTIAL_RESOURCES);
      })
      .then(() => {
        console.log('✅ 글나무 서비스 워커 설치 완료');
        return self.skipWaiting(); // 즉시 활성화
      })
      .catch((error) => {
        console.error('❌ 서비스 워커 설치 실패:', error);
      })
  );
});

// ===========================================
// 서비스 워커 활성화
// ===========================================
self.addEventListener('activate', (event) => {
  console.log('🔄 글나무 서비스 워커 활성화 중...');
  
  event.waitUntil(
    Promise.all([
      // 1. 이전 버전 캐시 삭제
      cleanOldCaches(),
      // 2. 모든 클라이언트에 새 서비스 워커 적용
      self.clients.claim(),
    ]).then(() => {
      console.log('✅ 글나무 서비스 워커 활성화 완료');
    })
  );
});

// ===========================================
// 네트워크 요청 가로채기
// ===========================================
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  
  // 🚫 GET 요청이 아니면 Service Worker 개입 없이 바로 네트워크로 전달
  if (event.request.method !== 'GET') {
    return;
  }
  
  // 캐시 블랙리스트 체크
  if (shouldSkipCache(url)) {
    return; // 🎯 수정: fetch 호출 없이 바로 return (브라우저 기본 동작)
  }
  
  // API 요청 처리 (네트워크 우선 + 만료 체크)
  if (url.pathname.startsWith('/api/')) {
    event.respondWith(handleApiRequest(event.request));
    return;
  }
  
  // 정적 리소스 처리 (캐시 우선)
  event.respondWith(handleStaticRequest(event.request));
});

// ===========================================
// 메시지 처리 (앱과 통신)
// ===========================================
self.addEventListener('message', async (event) => {
  const { type, data } = event.data || {};
  
  switch (type) {
    case 'SKIP_WAITING':
      self.skipWaiting();
      break;
      
    case 'GET_VERSION':
      event.ports[0].postMessage({ version: CACHE_VERSION });
      break;
      
    case 'CLEAR_USER_CACHE':
      console.log('🧹 [로그아웃] 사용자 데이터 캐시 정리 시작...');
      await clearUserCache();
      event.ports[0]?.postMessage({ success: true });
      break;
      
    case 'GET_CACHE_STATS':
      event.ports[0].postMessage(cacheStats);
      break;
      
    case 'CLEAR_ALL_CACHE':
      await clearAllCaches();
      event.ports[0]?.postMessage({ success: true });
      break;
  }
});

// ===========================================
// API 요청 처리 (네트워크 우선 + 만료 체크)
// ===========================================
async function handleApiRequest(request) {
  const cacheKey = request.url;
  
  try {
    // 1️⃣ 네트워크 요청 시도 (타임아웃 10초)
    const networkResponse = await fetchWithTimeout(request, 10000);
    
    // 2️⃣ 성공 시 캐시에 저장 (GET 요청만)
    if (networkResponse.ok && request.method === 'GET') {
      cacheApiResponse(request, networkResponse.clone());
    }
    
    cacheStats.misses++;
    return networkResponse;
  } catch (error) {
    console.log('⚠️ API 네트워크 오류, 캐시 확인:', request.url);
    
    // 3️⃣ 네트워크 실패 시 캐시 확인
    try {
      const cache = await caches.open(API_CACHE_NAME);
      const cachedResponse = await cache.match(cacheKey);
      
      if (cachedResponse) {
        // 4️⃣ 캐시 만료 확인
        const cacheTime = await getCacheTime(cacheKey);
        const isExpired = Date.now() - cacheTime > API_CACHE_EXPIRATION;
        
        if (!isExpired) {
          console.log('✅ 유효한 캐시 반환:', request.url);
          cacheStats.hits++;
          return cachedResponse;
        } else {
          console.log('⏰ 만료된 캐시 삭제:', request.url);
          await cache.delete(cacheKey);
        }
      }
    } catch (cacheError) {
      console.log('⚠️ 캐시 접근 실패:', cacheError.message);
    }
    
    // 5️⃣ 캐시도 없거나 만료됨 → 오류 응답
    return new Response(
      JSON.stringify({
        error: '오프라인 상태입니다',
        message: '네트워크 연결을 확인해주세요',
      }),
      {
        status: 503,
        statusText: 'Service Unavailable',
        headers: { 'Content-Type': 'application/json' },
      }
    );
  }
}

// ===========================================
// 정적 리소스 처리 (캐시 우선) - 🎯 안전하게 수정됨
// ===========================================
async function handleStaticRequest(request) {
  // 🌐 HTML 요청 (SPA 라우팅) - 네트워크 우선
  if (request.destination === 'document') {
    try {
      const networkResponse = await fetchWithTimeout(request, 5000);
      
      if (networkResponse && networkResponse.ok) {
        // 성공 시 캐시하고 반환
        cacheStaticResource(request, networkResponse.clone()).catch(() => {});
        cacheStats.misses++;
        return networkResponse;
      }
      
      // 🎯 네트워크 응답이 ok가 아닌 경우 → 캐시 시도
      console.log('⚠️ HTML 응답 실패, 캐시된 index.html 시도');
      const cachedIndex = await caches.match('/');
      if (cachedIndex) {
        cacheStats.hits++;
        return cachedIndex;
      }
      
      // 캐시도 없고 networkResponse가 있으면 그거라도 반환
      if (networkResponse) {
        return networkResponse;
      }
      
      // 🎯 최후의 수단: 네트워크 직접 재시도
      return fetch(request);
    } catch (error) {
      console.log('⚠️ HTML 네트워크 실패:', error.message);
      
      // 네트워크 실패 시 캐시된 index.html 반환
      try {
        const cachedIndex = await caches.match('/');
        if (cachedIndex) {
          console.log('✅ 캐시된 index.html 반환');
          cacheStats.hits++;
          return cachedIndex;
        }
      } catch (cacheError) {
        console.log('⚠️ 캐시 접근 실패:', cacheError.message);
      }
      
      // 🎯 수정: 404 대신 네트워크 직접 재시도 (브라우저에게 맡김)
      console.log('🔄 네트워크 직접 재시도...');
      try {
        return await fetch(request);
      } catch (e) {
        // 정말 아무것도 안 되면 기본 오프라인 페이지
        return new Response(
          '<!DOCTYPE html><html><head><meta charset="utf-8"><title>글나무</title></head><body style="display:flex;justify-content:center;align-items:center;height:100vh;font-family:sans-serif;"><div style="text-align:center;"><h1>오프라인</h1><p>네트워크 연결을 확인해주세요.</p></div></body></html>',
          { status: 503, headers: { 'Content-Type': 'text/html; charset=utf-8' } }
        );
      }
    }
  }
  
  // 📷 정적 리소스 (이미지, CSS, JS 등) - 캐시 우선
  try {
    // 1️⃣ 캐시에서 먼저 찾기
    const cachedResponse = await caches.match(request);
    if (cachedResponse) {
      cacheStats.hits++;
      return cachedResponse;
    }
    
    // 2️⃣ 캐시에 없으면 네트워크에서 가져오기
    const response = await fetch(request);
    
    // 3️⃣ 성공 시 캐시에 저장
    if (response.ok) {
      cacheStaticResource(request, response.clone()).catch(() => {});
    }
    
    cacheStats.misses++;
    return response;
  } catch (error) {
    console.log('⚠️ 리소스 로드 실패:', request.url);
    
    // 🎯 수정: 정적 리소스 실패 시에만 404 반환 (HTML 아님)
    return new Response('리소스를 찾을 수 없습니다', {
      status: 404,
      statusText: 'Not Found',
    });
  }
}

// ===========================================
// 헬퍼 함수들
// ===========================================

// 🚫 캐시 스킵 여부 확인
function shouldSkipCache(url) {
  return CACHE_BLACKLIST.some(pattern => pattern.test(url.href));
}

// ⏱️ 타임아웃이 있는 fetch - 🎯 안전하게 수정됨
function fetchWithTimeout(request, timeout) {
  return new Promise((resolve, reject) => {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => {
      controller.abort();
      reject(new Error('Timeout'));
    }, timeout);
    
    fetch(request, { signal: controller.signal })
      .then(response => {
        clearTimeout(timeoutId);
        resolve(response);
      })
      .catch(error => {
        clearTimeout(timeoutId);
        reject(error);
      });
  });
}

// 💾 API 응답 캐시 (용량 체크 + 메타데이터 저장)
async function cacheApiResponse(request, response) {
  try {
    const cache = await caches.open(API_CACHE_NAME);
    
    // 캐시 용량 체크
    const cacheSize = await getCacheSize(API_CACHE_NAME);
    if (cacheSize > MAX_API_CACHE_SIZE) {
      console.log('⚠️ API 캐시 용량 초과, 오래된 항목 삭제');
      await pruneCache(API_CACHE_NAME, MAX_API_CACHE_SIZE * 0.7);
    }
    
    // 캐시 저장 + 타임스탬프 기록
    await cache.put(request, response);
    await setCacheTime(request.url, Date.now());
    
    cacheStats.size = await getCacheSize(API_CACHE_NAME);
  } catch (error) {
    console.error('캐시 저장 실패:', error);
  }
}

// 💾 정적 리소스 캐시 (용량 체크)
async function cacheStaticResource(request, response) {
  try {
    const cache = await caches.open(CACHE_NAME);
    
    // 캐시 용량 체크
    const cacheSize = await getCacheSize(CACHE_NAME);
    if (cacheSize > MAX_CACHE_SIZE) {
      console.log('⚠️ 정적 캐시 용량 초과, 오래된 항목 삭제');
      await pruneCache(CACHE_NAME, MAX_CACHE_SIZE * 0.7);
    }
    
    await cache.put(request, response);
  } catch (error) {
    console.error('캐시 저장 실패:', error);
  }
}

// 📊 캐시 용량 계산
async function getCacheSize(cacheName) {
  try {
    const cache = await caches.open(cacheName);
    const requests = await cache.keys();
    let totalSize = 0;
    
    for (const request of requests) {
      const response = await cache.match(request);
      if (response) {
        const blob = await response.blob();
        totalSize += blob.size;
      }
    }
    
    return totalSize;
  } catch (error) {
    return 0;
  }
}

// 🧹 캐시 정리 (오래된 항목 삭제)
async function pruneCache(cacheName, targetSize) {
  try {
    const cache = await caches.open(cacheName);
    const requests = await cache.keys();
    
    // LRU 방식으로 오래된 것부터 삭제
    let currentSize = await getCacheSize(cacheName);
    
    for (const request of requests) {
      if (currentSize <= targetSize) break;
      
      const response = await cache.match(request);
      if (response) {
        const blob = await response.blob();
        await cache.delete(request);
        currentSize -= blob.size;
        console.log('🗑️ 캐시 항목 삭제:', request.url);
      }
    }
  } catch (error) {
    console.error('캐시 정리 실패:', error);
  }
}

// 🧹 이전 버전 캐시 삭제
async function cleanOldCaches() {
  const cacheNames = await caches.keys();
  const currentCaches = [CACHE_NAME, API_CACHE_NAME];
  
  return Promise.all(
    cacheNames.map((cacheName) => {
      if (!currentCaches.includes(cacheName)) {
        console.log('🗑️ 이전 버전 캐시 삭제:', cacheName);
        return caches.delete(cacheName);
      }
    })
  );
}

// 🧹 사용자 데이터 캐시만 삭제 (로그아웃 시)
async function clearUserCache() {
  try {
    const apiCacheDeleted = await caches.delete(API_CACHE_NAME);
    await caches.open(API_CACHE_NAME);
    
    console.log(
      apiCacheDeleted 
        ? '✅ 사용자 API 캐시 삭제 완료' 
        : '⚠️ API 캐시가 존재하지 않음'
    );
    
    cacheStats.size = 0;
  } catch (error) {
    console.error('❌ 사용자 캐시 삭제 실패:', error);
  }
}

// 🧹 모든 캐시 삭제 (설정 화면 등에서)
async function clearAllCaches() {
  try {
    const cacheNames = await caches.keys();
    await Promise.all(cacheNames.map(name => caches.delete(name)));
    
    const cache = await caches.open(CACHE_NAME);
    await cache.addAll(ESSENTIAL_RESOURCES);
    
    console.log('✅ 모든 캐시 삭제 및 재생성 완료');
  } catch (error) {
    console.error('❌ 캐시 삭제 실패:', error);
  }
}

// ⏰ 캐시 타임스탬프 저장/조회
const CACHE_METADATA_KEY = 'cache_metadata';

async function setCacheTime(url, time) {
  try {
    const metadata = await getCacheMetadata();
    metadata[url] = time;
    await saveCacheMetadata(metadata);
  } catch (error) {
    // 메타데이터 저장 실패는 무시
  }
}

async function getCacheTime(url) {
  try {
    const metadata = await getCacheMetadata();
    return metadata[url] || 0;
  } catch (error) {
    return 0;
  }
}

async function getCacheMetadata() {
  try {
    const cache = await caches.open(CACHE_NAME);
    const response = await cache.match(CACHE_METADATA_KEY);
    if (response) {
      return await response.json();
    }
  } catch (error) {}
  return {};
}

async function saveCacheMetadata(metadata) {
  try {
    const cache = await caches.open(CACHE_NAME);
    const response = new Response(JSON.stringify(metadata), {
      headers: { 'Content-Type': 'application/json' },
    });
    await cache.put(CACHE_METADATA_KEY, response);
  } catch (error) {}
}

// ===========================================
// 주기적 캐시 정리 (1시간마다)
// ===========================================
setInterval(async () => {
  console.log('🔄 주기적 캐시 정리 실행...');
  
  try {
    const cache = await caches.open(API_CACHE_NAME);
    const requests = await cache.keys();
    
    for (const request of requests) {
      const cacheTime = await getCacheTime(request.url);
      const isExpired = Date.now() - cacheTime > API_CACHE_EXPIRATION;
      
      if (isExpired) {
        await cache.delete(request);
        console.log('🗑️ 만료된 캐시 삭제:', request.url);
      }
    }
  } catch (error) {
    console.log('⚠️ 주기적 캐시 정리 실패:', error.message);
  }
}, 60 * 60 * 1000); // 1시간

// ===========================================
// 🔔 푸시 알림 클릭 처리 (FCM 연동)
// ===========================================

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
function selectBestClient(windowClients) {
  if (!windowClients || windowClients.length === 0) return null;

  let pwaClient = null;
  let browserClient = null;

  for (const client of windowClients) {
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

// 알림 클릭 처리
self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  // 🔍 디버그 로그
  console.log('[글나무 SW-PWA] 알림 클릭!');
  console.log('[글나무 SW-PWA] notification.data:', event.notification.data);

  const urlToOpen = getNotificationUrl(event.notification.data);
  const fullUrl = new URL(urlToOpen, self.location.origin).href;
  
  console.log('[글나무 SW-PWA] 이동할 URL:', urlToOpen);
  console.log('[글나무 SW-PWA] 전체 URL:', fullUrl);

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true })
      .then((windowClients) => {
        console.log('[글나무 SW-PWA] 열린 창 수:', windowClients.length);
        
        const targetClient = selectBestClient(windowClients);
        console.log('[글나무 SW-PWA] 대상 클라이언트:', targetClient ? '찾음' : '없음');

        if (targetClient) {
          // 기존 창으로 이동
          console.log('[글나무 SW-PWA] 기존 창에 postMessage 전송...');
          targetClient.postMessage({
            type: 'NOTIFICATION_CLICK',
            url: urlToOpen,
            data: event.notification.data
          });
          console.log('[글나무 SW-PWA] postMessage 전송 완료!');

          targetClient.focus().catch(() => {});
          return;
        } else {
          // 🆕 새 창 열기: /splash?pending=... 형식으로 리다이렉트
          const splashUrl = `/splash?pending=${encodeURIComponent(urlToOpen)}`;
          const splashFullUrl = new URL(splashUrl, self.location.origin).href;
          console.log('[글나무 SW-PWA] 새 창 열기 (splash 경유):', splashFullUrl);
          return clients.openWindow(splashFullUrl);
        }
      })
      .catch((error) => {
        console.error('[글나무 SW-PWA] 알림 처리 실패:', error);
        // 🆕 에러 시에도 splash 경유
        const splashUrl = `/splash?pending=${encodeURIComponent(urlToOpen)}`;
        return clients.openWindow(new URL(splashUrl, self.location.origin).href);
      })
  );
});

// ===========================================
// 초기화 완료
// ===========================================
console.log('✅ 글나무 서비스 워커 ' + CACHE_VERSION + ' 로드 완료');
console.log('📦 캐시 전략: 정적 리소스 우선, API 네트워크 우선');
console.log('💾 최대 캐시: 정적 50MB, API 10MB');
console.log('⏰ API 캐시 만료: 1시간');
console.log('🔔 푸시 알림 클릭 핸들러 등록됨');
