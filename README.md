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
- **Data Warehouse API**: ✅ DEPLOYED & RUNNING
  - URL: https://web-production-190d4.up.railway.app
  - Status: Active
  - Features: CRUD operations, JSON/XML support, Health monitoring

### Local Development:
- **Reverse Proxy**: ✅ IMPLEMENTED (code in src/proxy/)
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

### 1. Data Warehouse Service

- **Runtime**: Node.js 16+
- **Framework**: Express.js
- **Port**: Dinamic (Railway $PORT)
- **Endpoints**:
  - `GET /employees`
  - `GET /employees/:id`
  - `PUT /employees/:id`
  - `POST /employees/:id`
  - `DELETE /employees/:id`

### 2. Reverse Proxy Service

- **Runtime**: Node.js 16+
- **Features**:
  - Load Balancing (Round-Robin)
  - Response Caching (TTL-based)
  - Connection Pooling
- **Port**: Dinamic (Railway $PORT)

### 3. Redis Database

- **Type**: Managed Redis (Railway Plugin)
- **Usage**: Caching + Connection Management
- **Connection**: Automatic via environment variables

## Deployment Steps

### Pas 1: Pregătire Repository

```bash
# Asigură-te că ești în Lab 3
cd "Lab 3"

# Verifică fișierele
ls -la
```

### Pas 2: Push la GitHub

```bash
# Inițializează git (dacă nu e deja)
git init
git add .
git commit -m "Lab 3: Railway deployment setup"

# Push la GitHub
git remote add origin https://github.com/USERNAME/PAD.git
git push -u origin main
```

### Pas 3: Deploy pe Railway

#### 3.1 Creează Proiect Nou

1. Mergi pe [railway.app](https://railway.app)
2. Click **"New Project"**
3. Selectează **"Deploy from GitHub repo"**
4. Alege repository-ul tău

#### 3.2 Deploy Data Warehouse

1. Click **"Add Service"** → **"GitHub Repo"**
2. Selectează branch-ul `main`
3. Root Directory: `Lab 3`
4. Start Command: `node src/warehouse/server.js`
5. **Environment Variables**:
   ```
   NODE_ENV=production
   DW_PORT=$PORT
   ```

#### 3.3 Adaugă Redis

1. Click **"New"** → **"Database"** → **"Add Redis"**
2. Railway va crea automat variabilele:
   - `REDIS_HOST`
   - `REDIS_PORT`
   - `REDIS_PASSWORD`
3. Link Redis la Data Warehouse service

#### 3.4 Deploy Reverse Proxy

1. Click **"Add Service"** → **"GitHub Repo"**
2. Root Directory: `Lab 3`
3. Start Command: `node src/proxy/server.js`
4. **Environment Variables**:
   ```
   NODE_ENV=production
   PROXY_PORT=$PORT
   DW_SERVERS=<data-warehouse-internal-url>:3000
   ```

#### 3.5 Generează Public URL

1. Selectează Proxy service
2. Click **"Settings"** → **"Networking"**
3. Click **"Generate Domain"**
4. Primești URL public: `https://your-app.up.railway.app`

## Environment Variables

### Data Warehouse Service

```bash
NODE_ENV=production
PORT=3000                    # Railway setează automat
DW_HOST=0.0.0.0
REDIS_HOST=<from-railway>
REDIS_PORT=<from-railway>
REDIS_PASSWORD=<from-railway>
```

### Reverse Proxy Service

```bash
NODE_ENV=production
PORT=8080                    # Railway setează automat
PROXY_HOST=0.0.0.0
DW_SERVERS=warehouse-service:3000
REDIS_HOST=<from-railway>
REDIS_PORT=<from-railway>
REDIS_PASSWORD=<from-railway>
```

## Testing

### Test Data Warehouse Direct

```bash
# GET all employees
curl https://warehouse-service.up.railway.app/employees

# GET specific employee
curl https://warehouse-service.up.railway.app/employees/1

# CREATE employee
curl -X PUT https://warehouse-service.up.railway.app/employees/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","position":"Developer","salary":50000}'
```

### Test prin Proxy

```bash
# Request prin proxy (cu caching)
curl https://proxy-service.up.railway.app/employees

# Verifică cache HIT
curl -v https://proxy-service.up.railway.app/employees
# Caută header: X-Cache: HIT
```

## Monitoring

### Railway Dashboard

- **Logs**: Real-time logs pentru fiecare service
- **Metrics**: CPU, Memory, Network usage
- **Deployments**: Istoric deploy-uri

### Health Checks

```bash
# Check warehouse health
curl https://warehouse-service.up.railway.app/health

# Check proxy health
curl https://proxy-service.up.railway.app/health
```

## Cost Estimation

Railway Free Tier:

- **$5 credit/lună** gratuit
- **500 ore execution** (~20 zile 24/7)
- **100GB bandwidth**

Servicii folosite:

- Data Warehouse: ~$2/lună
- Proxy: ~$2/lună
- Redis: ~$1/lună
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
