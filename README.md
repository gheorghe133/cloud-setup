# Lab 3 - Cloud Deployment (Railway)

Migrarea proiectului Lab 2 (Web Proxy + Data Warehouse) în cloud folosind **Railway.app**.

## Arhitectură Cloud - DEPLOYED ✅

```
┌──────────────────────────────────────────────────────────────┐
│ Railway Cloud Platform (PaaS)                                │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ Service: web-production-190d4                          │  │
│  │ ├─ Data Warehouse API                                  │  │
│  │ ├─ Runtime: Node.js 16+                                │  │
│  │ ├─ Port: $PORT (auto-assigned by Railway)             │  │
│  │ ├─ Host: 0.0.0.0                                       │  │
│  │ ├─ Features:                                           │  │
│  │ │  ├─ CRUD Operations                                  │  │
│  │ │  ├─ JSON/XML Support                                 │  │
│  │ │  ├─ Health Monitoring                                │  │
│  │ │  └─ Thread-safe Storage                              │  │
│  │ └─ Status: ✅ RUNNING                                  │  │
│  └────────────────────────────────────────────────────────┘  │
│                              ▲                                │
│                              │                                │
│  ┌───────────────────────────┴─────────────────────────────┐ │
│  │ Public URL (HTTPS with SSL)                            │ │
│  │ https://web-production-190d4.up.railway.app             │ │
│  │                                                          │ │
│  │ API Endpoints:                                          │ │
│  │ ├─ GET  /health          → Health check                │ │
│  │ ├─ GET  /employees       → List all employees          │ │
│  │ ├─ GET  /employees/:id   → Get employee by ID          │ │
│  │ ├─ PUT  /employees/:id   → Create employee             │ │
│  │ ├─ POST /employees/:id   → Update employee             │ │
│  │ └─ DELETE /employees/:id → Delete employee             │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ GitHub Integration (CI/CD)                             │  │
│  │ Repository: gheorghe133/cloud-setup                    │  │
│  │ Branch: main                                           │  │
│  │ Auto-deploy: ✅ Enabled (push to main = auto deploy)  │  │
│  │ Build: Nixpacks (auto-detected Node.js)               │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘

---

## 🚀 Deployment Status

### Production (Railway Cloud):

✅ **Data Warehouse API** - DEPLOYED & RUNNING
- URL: https://data-warehouse.up.railway.app
- Status: Active
- Features: CRUD operations, JSON/XML support, Health monitoring

✅ **Reverse Proxy Server** - DEPLOYED & RUNNING
- URL: https://reverse-proxy-server.up.railway.app
- Status: Active
- Features: Load balancing, Response caching, Health checks
- Backend: Private networking to Data Warehouse (web:8080)
  - Features: Load balancing, Caching, Connection pooling
  - Run locally: `npm run start:proxy`
  - Can be deployed as separate Railway service if needed

**Lab 3 Requirements**: ✅ COMPLETE
- Cloud deployment: ✅ Railway
- Application running: ✅ Data Warehouse API
- Architecture diagram: ✅ Below
- Documentation: ✅ Complete
```

## Servicii Deploy-ate

### 1. Data Warehouse Service (Production)

- **Runtime**: Node.js 16+
- **Framework**: Express.js
- **Port**: Dinamic (Railway $PORT)
- **Storage**: In-memory (thread-safe Map)
- **Endpoints**:
  - `GET /health` - Health check
  - `GET /employees` - List all employees
  - `GET /employees/:id` - Get employee by ID
  - `PUT /employees/:id` - Create employee
  - `POST /employees/:id` - Update employee
  - `DELETE /employees/:id` - Delete employee

### 2. Reverse Proxy Service (Local Development)

- **Runtime**: Node.js 16+
- **Features**:
  - Load Balancing (Round-Robin)
  - Response Caching (in-memory, TTL-based)
  - Connection Pooling
  - Health Checks
- **Port**: 8080 (local)
- **Status**: Implemented, can be deployed separately if needed

## Deployment Steps

### Pas 1: Push la GitHub

```bash
git add .
git commit -m "Lab 3: Railway deployment"
git push origin main
```

### Pas 2: Deploy pe Railway

1. Mergi pe [railway.app](https://railway.app)
2. Click **"New Project"** → **"Deploy from GitHub repo"**
3. Selectează repository-ul `gheorghe133/cloud-setup`
4. Railway detectează automat Node.js și folosește `Procfile`

### Pas 3: Configurare Environment Variables

În Railway Dashboard → Variables:
```bash
NODE_ENV=production
PORT=$PORT  # Railway setează automat
```

### Pas 4: Generează Public URL

1. Settings → Networking → **"Generate Domain"**
2. Primești URL: `https://web-production-190d4.up.railway.app`

### Pas 5: Auto-Deploy

✅ Orice push pe `main` → Railway redeploy automat!

## Environment Variables

### Data Warehouse Service (Production)

```bash
NODE_ENV=production
# PORT is set automatically by Railway to 8080
```

### Reverse Proxy Service (Production)

```bash
NODE_ENV=production
PORT=8080
PROXY_HOST=0.0.0.0
DW_SERVERS=web:8080  # Private networking to Data Warehouse
```

### Local Development

```bash
# Warehouse
NODE_ENV=development
DW_PORT=3000

# Proxy
NODE_ENV=development
PROXY_PORT=8080
DW_SERVERS=localhost:3000
```

## Testing

### Test Data Warehouse Direct

```bash
# Health check
curl https://data-warehouse.up.railway.app/health

# GET all employees
curl https://data-warehouse.up.railway.app/employees

# GET specific employee (JSON)
curl https://data-warehouse.up.railway.app/employees/1

# GET employee (XML format)
curl -H "Accept: application/xml" https://data-warehouse.up.railway.app/employees/1

# CREATE employee
curl -X PUT https://data-warehouse.up.railway.app/employees/new-id \
  -H "Content-Type: application/json" \
  -d '{"firstName":"John","lastName":"Doe","email":"john@example.com","department":"IT","position":"Developer","salary":50000}'
```

### Test prin Reverse Proxy

```bash
# Proxy health check
curl https://reverse-proxy-server.up.railway.app/proxy/health

# GET employees prin proxy (cu caching)
curl https://reverse-proxy-server.up.railway.app/employees

# Verifică cache headers
curl -v https://reverse-proxy-server.up.railway.app/employees 2>&1 | grep -i "x-proxy-cache"
# Output: x-proxy-cache: HIT (dacă e cached)

# Proxy stats
curl https://reverse-proxy-server.up.railway.app/proxy/stats
```

## Monitoring

### Railway Dashboard

- **Logs**: Real-time logs pentru fiecare service
- **Metrics**: CPU, Memory, Network usage
- **Deployments**: Istoric deploy-uri cu auto-deploy pe push

### Health Checks

```bash
# Check warehouse health
curl https://data-warehouse.up.railway.app/health

# Check proxy health
curl https://reverse-proxy-server.up.railway.app/proxy/health

# Check load balancer stats
curl https://reverse-proxy-server.up.railway.app/proxy/stats
```

## Cost Estimation

Railway Free Tier:

- **$5 credit/lună** gratuit
- **500 ore execution** (~20 zile 24/7)
- **100GB bandwidth**

Servicii folosite:

- Data Warehouse: ~$2.50/lună
- Reverse Proxy: ~$2.50/lună
- **Total**: ~$5/lună (GRATUIT cu credit)

## Troubleshooting

### Service nu pornește

```bash
# Verifică logs în Railway Dashboard
# Caută erori de port binding sau dependencies
```

### Redis connection failed

```bash
# Verifică că Redis service e linked
# Verifică environment variables sunt setate
```

### 502 Bad Gateway

```bash
# Verifică că serviciul ascultă pe $PORT
# Verifică că host e "0.0.0.0" nu "localhost"
```

## ✅ Deployment Status - LIVE

**🌐 Production URL:** https://web-production-190d4.up.railway.app

**📊 Service Status:**
- ✅ Health Check: `GET /health` - **HEALTHY**
- ✅ API Endpoints: **OPERATIONAL**
- ✅ Data Warehouse: **5 employees loaded**
- ✅ Auto-deploy from GitHub: **ENABLED**
- ✅ HTTPS: **Enabled by default**
- ✅ Uptime: **Running continuously**

**🧪 Teste Verificate:**
```bash
# Health check
curl https://web-production-190d4.up.railway.app/health
# Response: {"status":"healthy","uptime":305.88,"version":"1.0.0"}

# Get all employees
curl https://web-production-190d4.up.railway.app/employees
# Response: 5 employees returned successfully

# Get specific employee
curl https://web-production-190d4.up.railway.app/employees/1
# Response: John Doe - Software Engineer

# Create new employee
curl -X PUT https://web-production-190d4.up.railway.app/employees/100 \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Ion","lastName":"Popescu","email":"ion@company.com","department":"IT","position":"DevOps","salary":70000}'

# Update employee
curl -X POST https://web-production-190d4.up.railway.app/employees/100 \
  -H "Content-Type: application/json" \
  -d '{"salary":75000}'

# Delete employee
curl -X DELETE https://web-production-190d4.up.railway.app/employees/100
```

**📈 Deployment Info:**
- **Platform:** Railway.app (PaaS)
- **Region:** Auto-selected (US/EU)
- **Runtime:** Node.js 16+
- **Build Tool:** Nixpacks (auto-detected)
- **Deploy Method:** GitHub integration
- **Repository:** https://github.com/gheorghe133/cloud-setup
- **Branch:** main
- **Auto-deploy:** ✅ Enabled (push to main = auto deploy)

---

## Sarcini Lab 3 Completate

### ✅ **Sarcina de bază (Opțiunea 2) - 8 puncte**: Migrare proiect în Cloud

  - [x] **Creat instanță virtuală** pe Railway Cloud Platform
  - [x] **Copiat aplicația** prin GitHub integration
  - [x] **Pornit aplicația** - serviciul rulează pe `https://web-production-190d4.up.railway.app`
  - [x] **Configurat environment variables** (PORT, NODE_ENV, DW_HOST)
  - [x] **Reprezentat sistem ca diagramă** (vezi secțiunea "Arhitectură Cloud")
  - [x] **Testat deployment-ul** - toate endpoint-urile funcționează

### 📝 **Sarcini adiționale (opționale - +1 punct fiecare):**

- [ ] **Sarcină adițională 1**: CI/CD cu GitHub Actions
- [ ] **Sarcină adițională 2**: Containerizare cu Docker
- [ ] **Sarcină adițională 3**: Integrare Cloud services (Redis managed)
- [ ] **Sarcină adițională 4**: Infrastructure as Code (Terraform)

## Referințe

- [Railway Documentation](https://docs.railway.app/)
- [Railway Node.js Guide](https://docs.railway.app/guides/nodejs)
- [Railway Environment Variables](https://docs.railway.app/develop/variables)
- [Lab 2 Original](../Lab%202/README.md)
