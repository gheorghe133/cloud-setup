# Lab 3 - Cloud Deployment

Web Proxy + Data Warehouse deployed pe **Railway.app**

## 🚀 Production URLs

✅ **Data Warehouse:** https://data-warehouse.up.railway.app
✅ **Reverse Proxy:** https://reverse-proxy-server.up.railway.app

## Arhitectură

```
Internet
   ↓
Reverse Proxy (reverse-proxy-server.up.railway.app:8080)
   ↓ Private Network (web:8080)
Data Warehouse (data-warehouse.up.railway.app:8080)
```

**Features:**

- Load Balancing (Round-Robin)
- Response Caching (TTL-based)
- Health Checks
- HTTPS/SSL
- Auto-deploy (GitHub → Railway)

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

## Tech Stack

- **Runtime:** Node.js 16+
- **Framework:** Express.js
- **Cloud:** Railway.app (PaaS)
- **CI/CD:** GitHub integration
- **Storage:** In-memory (thread-safe Map)

## Repository

**GitHub:** https://github.com/gheorghe133/cloud-setup
