# Deploy Reverse Proxy pe Railway

## Arhitectură cu 2 Servicii

```
┌─────────────────────────────────────────────────────────┐
│ Railway Cloud Platform                                  │
│                                                          │
│  ┌──────────────────────┐    ┌──────────────────────┐  │
│  │ Service 1            │    │ Service 2            │  │
│  │ Data Warehouse       │◄───┤ Reverse Proxy        │  │
│  │                      │    │                      │  │
│  │ Port: 3000 (intern)  │    │ Port: $PORT (public) │  │
│  │ URL: warehouse.rail  │    │ URL: proxy.railway   │  │
│  └──────────────────────┘    └──────────────────────┘  │
│           ▲                            ▲                │
│           │                            │                │
│           │                   ┌────────┴──────────┐    │
│           │                   │ Public Access     │    │
│           │                   │ (Users hit this)  │    │
│           │                   └───────────────────┘    │
│           │                                             │
│  ┌────────┴──────────────────────────────────────────┐ │
│  │ Internal Network (Railway Private Network)       │ │
│  │ Warehouse accessible via internal URL            │ │
│  └──────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## Pași de Deployment

### Service 1: Data Warehouse (DEJA DEPLOYED ✅)

**URL:** https://web-production-190d4.up.railway.app  
**Status:** ✅ RUNNING

---

### Service 2: Reverse Proxy (NOU)

#### Opțiunea 1: Deploy prin Railway Dashboard (RECOMANDAT)

**Pas 1: Creează Service Nou**

1. Login pe https://railway.app
2. Deschide proiectul tău existent
3. Click **"New Service"** (butonul + din dreapta sus)
4. Selectează **"GitHub Repo"**
5. Alege același repository: `gheorghe133/cloud-setup`
6. Railway va crea un al doilea service

**Pas 2: Configurează Service-ul**

1. Click pe noul service
2. Mergi la **Settings** → **General**
3. Schimbă **Service Name** la: `reverse-proxy`

**Pas 3: Setează Start Command**

1. În Settings → **Deploy**
2. La **Start Command** pune:
   ```
   node src/proxy/server.js
   ```

**Pas 4: Setează Environment Variables**

1. Mergi la **Variables**
2. Adaugă următoarele variabile:

```bash
NODE_ENV=production
PROXY_PORT=$PORT
PROXY_HOST=0.0.0.0
DW_SERVERS=web-production-190d4.up.railway.app:443
```

**IMPORTANT:** Pentru `DW_SERVERS`, folosește URL-ul PUBLIC al warehouse-ului (cu HTTPS):
- Dacă warehouse are URL: `https://web-production-190d4.up.railway.app`
- Atunci: `DW_SERVERS=web-production-190d4.up.railway.app:443`

SAU folosește internal URL (mai rapid):
- În Railway, warehouse-ul are și un internal URL
- Format: `web-production-190d4.railway.internal:3000`
- Setează: `DW_SERVERS=web-production-190d4.railway.internal:3000`

**Pas 5: Deploy**

1. Click **"Deploy"** sau push un commit nou
2. Railway va builda și deploya proxy-ul
3. Așteaptă ~2-3 minute

**Pas 6: Generează Public URL**

1. Click pe service-ul proxy
2. Mergi la **Settings** → **Networking**
3. Click **"Generate Domain"**
4. Vei primi URL: `https://reverse-proxy-production.up.railway.app`

---

#### Opțiunea 2: Deploy prin Railway CLI

```bash
# Instalează Railway CLI
npm install -g @railway/cli

# Login
railway login

# Link la proiect
railway link

# Creează service nou pentru proxy
railway service create reverse-proxy

# Setează environment variables
railway variables set NODE_ENV=production
railway variables set PROXY_HOST=0.0.0.0
railway variables set DW_SERVERS=web-production-190d4.up.railway.app:443

# Deploy
railway up --service reverse-proxy
```

---

## Configurare Avansată

### Obține Internal URL al Warehouse

Railway oferă un internal network pentru comunicare între servicii:

1. Click pe service-ul **Data Warehouse**
2. Mergi la **Settings** → **Networking**
3. Caută **Private Networking**
4. Vei vedea ceva gen: `web-production-190d4.railway.internal`

Folosește acest URL în `DW_SERVERS`:
```bash
DW_SERVERS=web-production-190d4.railway.internal:3000
```

**Avantaje:**
- ✅ Mai rapid (nu trece prin internet)
- ✅ Mai sigur (rămâne în rețeaua Railway)
- ✅ Fără costuri de bandwidth

---

## Testare

### Test 1: Verifică Warehouse (direct)

```bash
curl https://web-production-190d4.up.railway.app/health
```

**Expected:**
```json
{"status":"healthy","uptime":123.45,"version":"1.0.0"}
```

### Test 2: Verifică Proxy Health

```bash
curl https://reverse-proxy-production.up.railway.app/proxy/health
```

**Expected:**
```json
{
  "proxy": {
    "status": "healthy",
    "uptime": 45.67,
    "connections": 0
  },
  "cache": {...},
  "loadBalancer": {...}
}
```

### Test 3: Request prin Proxy

```bash
curl https://reverse-proxy-production.up.railway.app/employees
```

**Expected:**
- JSON cu employees
- Header: `X-Proxy-Cache: MISS` (prima dată)
- Header: `X-Load-Balancer-Server: ...`

### Test 4: Verifică Cache

```bash
# Request 1 (MISS)
curl -v https://reverse-proxy-production.up.railway.app/employees 2>&1 | grep X-Proxy-Cache

# Request 2 (HIT - din cache)
curl -v https://reverse-proxy-production.up.railway.app/employees 2>&1 | grep X-Proxy-Cache
```

---

## Arhitectura Finală

După deployment, vei avea:

```
┌─────────────────────────────────────────────────────────────┐
│ Railway Cloud Platform                                      │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Service 1: Data Warehouse                              │ │
│  │ URL: https://web-production-190d4.up.railway.app       │ │
│  │ Internal: web-production-190d4.railway.internal:3000   │ │
│  │ Status: ✅ RUNNING                                     │ │
│  └────────────────────────────────────────────────────────┘ │
│                              ▲                               │
│                              │ (internal network)            │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Service 2: Reverse Proxy                               │ │
│  │ URL: https://reverse-proxy-production.up.railway.app   │ │
│  │ Features:                                              │ │
│  │ ├─ Load Balancing (Round-Robin)                       │ │
│  │ ├─ Response Caching (TTL-based)                       │ │
│  │ ├─ Connection Pooling                                 │ │
│  │ └─ Health Monitoring                                  │ │
│  │ Status: ✅ RUNNING                                     │ │
│  └────────────────────────────────────────────────────────┘ │
│                              ▲                               │
│                              │                               │
│                    ┌─────────┴────────┐                     │
│                    │ Public Access    │                     │
│                    │ (Users)          │                     │
│                    └──────────────────┘                     │
└─────────────────────────────────────────────────────────────┘
```

**Flow:**
1. User → `https://reverse-proxy-production.up.railway.app/employees`
2. Proxy checks cache → MISS
3. Proxy forwards to warehouse (internal network)
4. Warehouse responds with data
5. Proxy caches response
6. Proxy returns to user
7. Next request → Cache HIT (faster!)

---

## Troubleshooting

### Proxy nu se conectează la Warehouse

**Problema:** `ECONNREFUSED` sau timeout

**Soluție:**
1. Verifică că `DW_SERVERS` e setat corect
2. Folosește internal URL: `web-production-190d4.railway.internal:3000`
3. SAU folosește public URL cu HTTPS: `web-production-190d4.up.railway.app:443`

### Proxy returnează 502 Bad Gateway

**Problema:** Warehouse nu răspunde

**Soluție:**
1. Verifică că warehouse service e RUNNING
2. Testează warehouse direct: `curl https://web-production-190d4.up.railway.app/health`
3. Verifică logs în Railway Dashboard

### Cache nu funcționează

**Problema:** Mereu `X-Proxy-Cache: MISS`

**Soluție:**
1. Verifică că Redis e configurat (opțional)
2. Proxy folosește in-memory cache by default
3. Verifică TTL în config: `CACHE_TTL=300` (5 minute)

---

## Costuri

**Railway Free Tier:**
- $5 credit/lună
- 500 ore execution

**Cu 2 servicii:**
- Warehouse: ~$2.50/lună
- Proxy: ~$2.50/lună
- **Total: ~$5/lună** (GRATUIT cu credit)

---

## Next Steps

După deployment:

1. ✅ Testează ambele servicii
2. ✅ Verifică că proxy face forward corect
3. ✅ Testează caching (request de 2 ori)
4. ✅ Verifică load balancing stats
5. ✅ Update documentația cu URL-urile noi
6. ✅ Fă screenshot-uri pentru raport

---

**Succes! 🚀**

