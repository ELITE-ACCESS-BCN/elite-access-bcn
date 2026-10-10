const CACHE='elite-access-bcn-v4';
const FILES=['./','./index.html','./manifest.webmanifest','./config.js'];
self.addEventListener('install',event=>{
  self.skipWaiting();
  event.waitUntil(caches.open(CACHE).then(cache=>cache.addAll(FILES)));
});
self.addEventListener('activate',event=>{
  event.waitUntil((async()=>{
    const keys=await caches.keys();
    await Promise.all(keys.filter(key=>key!==CACHE).map(key=>caches.delete(key)));
    await self.clients.claim();
  })());
});
self.addEventListener('fetch',event=>{
  if(event.request.method!=='GET') return;
  const url=new URL(event.request.url);
  if(url.origin!==self.location.origin) return;
  event.respondWith((async()=>{
    try{
      const response=await fetch(event.request,{cache:'no-store'});
      if(response&&response.ok){
        const copy=response.clone();
        caches.open(CACHE).then(cache=>cache.put(event.request,copy));
        return response;
      }
    }catch(error){}
    const cached=await caches.match(event.request);
    if(cached) return cached;
    if(event.request.mode==='navigate'){
      const page=await caches.match('./index.html');
      if(page) return page;
    }
    return new Response('No disponible sin conexión',{status:503,headers:{'Content-Type':'text/plain; charset=utf-8'}});
  })());
});
