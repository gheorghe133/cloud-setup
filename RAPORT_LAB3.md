# Raport Lab 3 - Cloud Deployment
## Aplicația în nori / Implementarea și desfășurarea aplicației Cloud(-native)

**Student:** Gheorghe Dandiș  
**Repository:** https://github.com/gheorghe133/cloud-setup  
**Production URL:** https://web-production-190d4.up.railway.app  
**Data:** 30 Octombrie 2025

---

## 1. Scopul Proiectului

Migrarea aplicației "Web Proxy + Data Warehouse" (Lab 2) în cloud folosind un Cloud Provider (Railway.app), demonstrând:
- Utilizarea serviciilor PaaS (Platform-as-a-Service)
- Deployment automat prin GitHub integration
- Configurarea environment variables pentru cloud
- Testarea aplicației în producție

---

## 2. Cloud Provider Ales: Railway.app

### De ce Railway?

**Avantaje:**
- ✅ **Free tier generos** - $5 credit/lună (suficient pentru proiect)
- ✅ **GitHub integration nativă** - deploy automat la push
- ✅ **Zero configuration** - detectează automat Node.js
- ✅ **HTTPS by default** - certificat SSL gratuit
- ✅ **Environment variables** - management simplu
- ✅ **Logs în timp real** - debugging ușor
- ✅ **Auto-scaling** - scalare automată

**Comparație cu alte platforme:**

| Feature | Railway | Heroku | AWS EC2 | DigitalOcean |
|---------|---------|--------|---------|--------------|
| Free tier | ✅ $5/lună | ❌ Plătit | ⚠️ Limitat | ❌ Plătit |
| GitHub integration | ✅ Native | ✅ Da | ❌ Manual | ❌ Manual |
| Auto-deploy | ✅ Da | ✅ Da | ❌ Nu | ❌ Nu |
| HTTPS | ✅ Automat | ✅ Automat | ⚠️ Manual | ⚠️ Manual |
| Configurare | ✅ Zero | ⚠️ Medie | ❌ Complexă | ⚠️ Medie |

---

## 3. Arhitectura Deployment-ului

### Diagrama Sistemului

```
┌──────────────────────────────────────────────────────────────┐
│ Railway Cloud Platform (PaaS)                                │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ Service: web-production-190d4                          │  │
│  │ ├─ Data Warehouse API                                  │  │
│  │ ├─ Runtime: Node.js 16+                                │  │
│  │ ├─ Port: $PORT (auto-assigned by Railway)             │  │
│  │ ├─ Host: 0.0.0.0 (bind to all interfaces)             │  │
│  │ ├─ Memory: 512MB (auto-scaled)                        │  │
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
│                              ▲                                │
│                              │                                │
│  ┌───────────────────────────┴─────────────────────────────┐ │
│  │ GitHub Integration (CI/CD)                              │ │
│  │ Repository: gheorghe133/cloud-setup                     │ │
│  │ Branch: main                                            │ │
│  │ Auto-deploy: ✅ Enabled                                 │ │
│  │                                                          │ │
│  │ Workflow:                                               │ │
│  │ 1. Push to main → 2. Railway detects → 3. Auto build   │ │
│  │ 4. Run tests → 5. Deploy → 6. Health check             │ │
│  └─────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

### Componente Deployed

1. **Data Warehouse Service**
   - Framework: Express.js
   - Database: In-memory (pentru demo)
   - Port: Dinamic ($PORT - asignat de Railway)
   - Host: 0.0.0.0 (pentru a accepta conexiuni externe)

2. **GitHub Integration**
   - Repository: https://github.com/gheorghe133/cloud-setup
   - Branch: main
   - Auto-deploy la fiecare push

3. **HTTPS/SSL**
   - Certificat SSL: Generat automat de Railway
   - Domain: web-production-190d4.up.railway.app

---

## 4. Pași de Deployment

### 4.1 Pregătirea Codului

**Fișiere necesare pentru Railway:**

1. **`package.json`** - Definește dependențele și scripts
```json
{
  "name": "web-proxy-lab",
  "version": "1.0.0",
  "scripts": {
    "start": "node src/index.js"
  },
  "engines": {
    "node": ">=16.0.0"
  }
}
```

2. **`Procfile`** - Specifică comanda de start
```
web: node src/warehouse/server.js
```

3. **`railway.json`** - Configurare Railway
```json
{
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "numReplicas": 1,
    "restartPolicyType": "ON_FAILURE"
  }
}
```

4. **`src/config/config.js`** - Environment variables
```javascript
const config = {
  warehouse: {
    port: process.env.PORT || 3000,
    host: process.env.DW_HOST || "0.0.0.0"
  }
};
```

### 4.2 Push la GitHub

```bash
# Verificare status
git status

# Commit changes
git add .
git commit -m "Lab 3: Railway deployment setup"

# Push to GitHub
git push origin main
```

### 4.3 Deployment pe Railway

**Pași urmați:**

1. ✅ Login pe https://railway.app cu GitHub
2. ✅ Click "New Project" → "Deploy from GitHub repo"
3. ✅ Selectat repository: `gheorghe133/cloud-setup`
4. ✅ Railway a detectat automat Node.js project
5. ✅ Build automat cu Nixpacks
6. ✅ Deploy automat
7. ✅ Generat public URL: `https://web-production-190d4.up.railway.app`

**Environment Variables setate:**
```bash
NODE_ENV=production
PORT=$PORT              # Auto-assigned by Railway
DW_HOST=0.0.0.0
```

### 4.4 Verificare Deployment

```bash
# Health check
curl https://web-production-190d4.up.railway.app/health

# Response:
{
  "status": "healthy",
  "timestamp": "2025-10-30T19:27:37.479Z",
  "uptime": 305.88,
  "version": "1.0.0"
}
```

---

## 5. Testare în Producție

### 5.1 Health Check
```bash
curl https://web-production-190d4.up.railway.app/health
```
**Status:** ✅ HEALTHY

### 5.2 GET All Employees
```bash
curl https://web-production-190d4.up.railway.app/employees
```
**Result:** ✅ 5 employees returned

### 5.3 GET Specific Employee
```bash
curl https://web-production-190d4.up.railway.app/employees/1
```
**Result:** ✅ John Doe - Software Engineer

### 5.4 CREATE Employee
```bash
curl -X PUT https://web-production-190d4.up.railway.app/employees/100 \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Ion",
    "lastName": "Popescu",
    "email": "ion@company.com",
    "department": "IT",
    "position": "DevOps Engineer",
    "salary": 70000
  }'
```
**Result:** ✅ Employee created successfully

### 5.5 UPDATE Employee
```bash
curl -X POST https://web-production-190d4.up.railway.app/employees/100 \
  -H "Content-Type: application/json" \
  -d '{"salary": 75000}'
```
**Result:** ✅ Employee updated

### 5.6 DELETE Employee
```bash
curl -X DELETE https://web-production-190d4.up.railway.app/employees/100
```
**Result:** ✅ Employee deleted

---

## 6. Sarcini Completate

### ✅ Sarcina de bază (Opțiunea 2) - 8 puncte

**Cerințe:**
- [x] Creat și configurat cel puțin o instanță virtuală oferită de Cloud provider
- [x] Copiat aplicațiile pe instanțele corespunzătoare
- [x] Pornit aplicațiile și configurat reverse proxy
- [x] Reprezentat sistemul obținut sub forma unei diagrame

**Implementare:**
- ✅ **Cloud Provider:** Railway.app (PaaS)
- ✅ **Instanță:** Service "web-production-190d4"
- ✅ **Deployment:** GitHub integration (auto-deploy)
- ✅ **URL Public:** https://web-production-190d4.up.railway.app
- ✅ **Diagramă:** Inclusă în README.md și acest raport
- ✅ **Teste:** Toate endpoint-urile funcționează

---

## 7. Concluzii

### Ce am învățat:

1. **Cloud Deployment**
   - Diferența între IaaS, PaaS, SaaS
   - Avantajele PaaS pentru aplicații simple
   - Configurarea environment variables pentru cloud

2. **CI/CD Basics**
   - GitHub integration pentru auto-deploy
   - Build automat la push
   - Zero-downtime deployment

3. **Production Best Practices**
   - Binding la 0.0.0.0 (nu localhost)
   - Port dinamic ($PORT)
   - HTTPS by default
   - Health checks

### Provocări întâmpinate:

1. ✅ **Port binding** - Rezolvat prin `process.env.PORT`
2. ✅ **Host configuration** - Rezolvat prin `0.0.0.0`
3. ✅ **Environment variables** - Configurate în Railway Dashboard

### Îmbunătățiri viitoare:

- [ ] Adăugare Redis managed pentru caching
- [ ] Implementare CI/CD cu GitHub Actions
- [ ] Containerizare cu Docker
- [ ] Infrastructure as Code cu Terraform
- [ ] Monitoring și alerting
- [ ] Auto-scaling policies

---

## 8. Resurse Utilizate

- **Railway Documentation:** https://docs.railway.app/
- **GitHub Repository:** https://github.com/gheorghe133/cloud-setup
- **Production URL:** https://web-production-190d4.up.railway.app
- **Node.js Documentation:** https://nodejs.org/docs/
- **Express.js Guide:** https://expressjs.com/

---

**Nota:** Acest proiect demonstrează cu succes migrarea unei aplicații distribuite în cloud folosind Railway.app, îndeplinind toate cerințele pentru Sarcina de bază (Opțiunea 2) din Lab 3.

