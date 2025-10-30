# Raport Lab 3 - Cloud Deployment

**Student:** Gheorghe Dandiș
**Repository:** https://github.com/gheorghe133/cloud-setup
**Data:** 30 Octombrie 2025

---

## 1. Servicii Deployed

### Data Warehouse API

- **URL:** https://data-warehouse.up.railway.app
- **Status:** ✅ RUNNING
- **Features:** CRUD operations, JSON/XML support, Health monitoring

### Reverse Proxy Server

- **URL:** https://reverse-proxy-server.up.railway.app
- **Status:** ✅ RUNNING
- **Features:** Load balancing, Response caching, Health checks

---

## 2. Cloud Provider: Railway.app

**Avantaje:**

- ✅ Free tier ($5 credit/lună)
- ✅ GitHub integration (auto-deploy)
- ✅ HTTPS by default
- ✅ Private networking între servicii

---

## 3. Arhitectură

```
Internet
   ↓
Reverse Proxy (reverse-proxy-server.up.railway.app:8080)
   ↓ Private Network (web:8080)
Data Warehouse (data-warehouse.up.railway.app:8080)
```

**Private Networking:**

- Proxy → Warehouse: `web:8080` (internal)
- Load balancing: Round-Robin
- Caching: TTL-based (in-memory)

---

## 4. Deployment

### Fișiere Necesare

**Procfile:**

```
web: node src/warehouse/server.js
```

**railway.json:**

```json
{
  "build": { "builder": "NIXPACKS" },
  "deploy": {
    "numReplicas": 1,
    "restartPolicyType": "ON_FAILURE"
  }
}
```

### Environment Variables

**Data Warehouse:**

```
NODE_ENV=production
```

**Reverse Proxy:**

```
NODE_ENV=production
PORT=8080
PROXY_HOST=0.0.0.0
DW_SERVERS=web:8080
```

---

## 5. Testing

### Health Checks

```bash
# Warehouse
curl https://data-warehouse.up.railway.app/health

# Proxy
curl https://reverse-proxy-server.up.railway.app/proxy/health
```

### Functional Tests

```bash
# Get employees prin proxy
curl https://reverse-proxy-server.up.railway.app/employees

# Verifică cache
curl -v https://reverse-proxy-server.up.railway.app/employees 2>&1 | grep x-proxy-cache
```

---

## 6. CI/CD

**GitHub Integration:**

- Repository: gheorghe133/cloud-setup
- Branch: main
- Auto-deploy: ✅ Enabled

**Workflow:**

1. Push to main
2. Railway detects change
3. Auto build & deploy
4. Health check

---

## 7. Rezultate

✅ **Data Warehouse** - Deployed & Running
✅ **Reverse Proxy** - Deployed & Running
✅ **Private Networking** - Functional
✅ **Load Balancing** - Working
✅ **Caching** - Working
✅ **HTTPS/SSL** - Active
✅ **CI/CD** - Automated
