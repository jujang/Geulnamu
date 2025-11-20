// 글나무 PWA 서비스 워커 v2.0
// ✨ 최적화된 캐싱 전략 + 선택적 캐시 정리 지원

const CACHE_VERSION = 'v1.0.0';
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
  
  // 캐시 블랙리스트 체크
  if (shouldSkipCache(url)) {
    event.respondWith(fetch(event.request));
    return;
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
      // 새 버전 즉시 활성화
      self.skipWaiting();
      break;
      
    case 'GET_VERSION':
      // 현재 버전 반환
      event.ports[0].postMessage({ version: CACHE_VERSION });
      break;
      
    case 'CLEAR_USER_CACHE':
      // 🧹 사용자 데이터 캐시만 삭제 (로그아웃 시 호출)
      console.log('🧹 [로그아웃] 사용자 데이터 캐시 정리 시작...');
      await clearUserCache();
      event.ports[0]?.postMessage({ success: true });
      break;
      
    case 'GET_CACHE_STATS':
      // 캐시 통계 반환
      event.ports[0].postMessage(cacheStats);
      break;
      
    case 'CLEAR_ALL_CACHE':
      // 모든 캐시 삭제 (설정 화면 등에서 호출)
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
// 정적 리소스 처리 (캐시 우선)
// ===========================================
async function handleStaticRequest(request) {
  try {
    // 🌐 HTML 요청 (SPA 라우팅)
    if (request.destination === 'document') {
      // HTML 요청은 항상 네트워크에서 가져와서 Vercel rewrites 가 작동하도록 함
      try {
        const networkResponse = await fetch(request);
        if (networkResponse.ok) {
          await cacheStaticResource(request, networkResponse.clone());
          cacheStats.misses++;
          return networkResponse;
        }
      } catch (networkError) {
        // 네트워크 실패 시 캐시된 index.html 반환 (오프라인 지원)
        console.log('⚠️ 네트워크 실패, 캐시된 index.html 반환');
        const cachedIndex = await caches.match('/');
        if (cachedIndex) {
          cacheStats.hits++;
          return cachedIndex;
        }
        throw networkError;
      }
    }
    
    // 📷 정적 리소스 (이미지, CSS, JS 등) - 캐시 우선
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
      await cacheStaticResource(request, response.clone());
    }
    
    cacheStats.misses++;
    return response;
  } catch (error) {
    console.log('❌ 리소스 로드 실패:', request.url);
    
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

// ⏱️ 타임아웃이 있는 fetch
function fetchWithTimeout(request, timeout) {
  return Promise.race([
    fetch(request),
    new Promise((_, reject) =>
      setTimeout(() => reject(new Error('Timeout')), timeout)
    ),
  ]);
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
    // API 캐시만 삭제 (사용자 데이터 포함)
    const apiCacheDeleted = await caches.delete(API_CACHE_NAME);
    
    // 새 API 캐시 생성
    await caches.open(API_CACHE_NAME);
    
    console.log(
      apiCacheDeleted 
        ? '✅ 사용자 API 캐시 삭제 완료' 
        : '⚠️ API 캐시가 존재하지 않음'
    );
    
    // 통계 초기화
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
    
    // 필수 캐시 재생성
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
  
  // API 캐시 만료 항목 정리
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
}, 60 * 60 * 1000); // 1시간

// ===========================================
// 초기화 완료
// ===========================================
console.log('✅ 글나무 서비스 워커 v' + CACHE_VERSION + ' 로드 완료');
console.log('📦 캐시 전략: 정적 리소스 우선, API 네트워크 우선');
console.log('💾 최대 캐시: 정적 50MB, API 10MB');
console.log('⏰ API 캐시 만료: 1시간');
