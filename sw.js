/* Sudoku PWA - offline cache + update */
const CACHE = "sudoku-pwa-2.1";
const ASSETS = ["./","./index.html","./manifest.webmanifest","./version.json","./icon-192.png","./icon-512.png"];

self.addEventListener("install",(e)=>{
  e.waitUntil((async()=>{
    const c=await caches.open(CACHE);
    await c.addAll(ASSETS);
    self.skipWaiting();
  })());
});

self.addEventListener("activate",(e)=>{
  e.waitUntil((async()=>{
    const keys=await caches.keys();
    await Promise.all(keys.map(k=>k!==CACHE?caches.delete(k):null));
    self.clients.claim();
  })());
});

self.addEventListener("message",(e)=>{
  if(e.data && e.data.type==="SKIP_WAITING") self.skipWaiting();
});

self.addEventListener("fetch",(e)=>{
  e.respondWith((async()=>{
    const req=e.request;
    try{
      const net=await fetch(req);
      if(req.method==="GET" && new URL(req.url).origin===location.origin){
        const c=await caches.open(CACHE);
        c.put(req, net.clone());
      }
      return net;
    }catch{
      const cached=await caches.match(req, {ignoreSearch:true});
      return cached || caches.match("./index.html");
    }
  })());
});
