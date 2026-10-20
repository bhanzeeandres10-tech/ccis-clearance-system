/* CCIS CLEARANCE PWA worker. Flutter's deprecated cache worker is not used. */
// Increment this identifier for each public release so installed copies fetch
// the current dashboard instead of holding on to a previous app bundle.
const CACHE_VERSION = 'ccis-clearance-v3';
const APP_SHELL = [
  './',
  './index.html',
  './manifest.json',
  './icons/ccis-clearance-icon.svg',
  './icons/ccis-clearance-maskable.svg'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_VERSION)
      .then((cache) => cache.addAll(APP_SHELL))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys
          .filter((key) => key.startsWith('ccis-clearance-') && key !== CACHE_VERSION)
          .map((key) => caches.delete(key))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('message', (event) => {
  if (event.data === 'skipWaiting') self.skipWaiting();
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  // A fresh app shell is preferred for navigation, with the cached shell as
  // the offline fallback. Other successful same-origin assets are cached on
  // first use so a launched PWA can start again without a network connection.
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then((response) => {
          const copy = response.clone();
          caches.open(CACHE_VERSION).then((cache) => cache.put('./index.html', copy));
          return response;
        })
        .catch(() => caches.match('./index.html'))
    );
    return;
  }

  // Always ask the server for Flutter's application bundle. This prevents a
  // previously installed demo from keeping an older dashboard after a new
  // release is copied into build/web; cache remains the offline fallback.
  if (/(?:main\.dart\.js|flutter_bootstrap\.js|flutter\.js|version\.json)$/.test(url.pathname)) {
    event.respondWith(
      fetch(request)
        .then((response) => {
          if (response.ok && response.type === 'basic') {
            const copy = response.clone();
            caches.open(CACHE_VERSION).then((cache) => cache.put(request, copy));
          }
          return response;
        })
        .catch(() => caches.match(request))
    );
    return;
  }

  event.respondWith(
    caches.match(request).then((cached) => {
      if (cached) return cached;
      return fetch(request).then((response) => {
        if (response.ok && response.type === 'basic') {
          const copy = response.clone();
          caches.open(CACHE_VERSION).then((cache) => cache.put(request, copy));
        }
        return response;
      });
    })
  );
});
