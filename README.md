# Cloud-Based Data Warehouse with Reverse Proxy

![CI/CD Pipeline](https://github.com/gheorghe133/cloud-setup/actions/workflows/ci.yml/badge.svg)

A distributed system implementing a RESTful Data Warehouse API with an intelligent Reverse Proxy layer, deployed on Railway.app cloud platform.

## Production Deployment

**Data Warehouse API:** https://data-warehouse.up.railway.app  
**Reverse Proxy Server:** https://reverse-proxy-server.up.railway.app

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Internet / Clients                       │
│                    (HTTPS Requests via Railway)                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              Reverse Proxy Server (Port 8080)                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Features:                                                │  │
│  │  - Round-Robin Load Balancing                             │  │
│  │  - Response Caching (TTL-based)                           │  │
│  │  - Connection Pooling                                     │  │
│  │  - Health Monitoring                                      │  │
│  │  - Request/Response Logging                               │  │
│  └───────────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ Private Network (web:8080)
                             │ Railway Internal DNS
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              Data Warehouse Server (Port 8080)                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  REST API Endpoints:                                      │  │
│  │  - GET    /employees       (List all)                     │  │
│  │  - GET    /employees/:id   (Get by ID)                    │  │
│  │  - PUT    /employees/:id   (Create)                       │  │
│  │  - POST   /employees/:id   (Update)                       │  │
│  │  - DELETE /employees/:id   (Delete)                       │  │
│  │  - GET    /health          (Health check)                 │  │
│  │                                                           │  │
│  │  Storage: Thread-safe in-memory Map                       │  │
│  │  Formats: JSON, XML                                       │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Key Features

### Reverse Proxy

- **Load Balancing:** Round-robin algorithm for request distribution
- **Caching:** Intelligent response caching with configurable TTL
- **Connection Management:** HTTP/HTTPS connection pooling
- **Health Checks:** Periodic backend server health monitoring
- **Metrics:** Real-time statistics and performance monitoring

### Data Warehouse

- **RESTful API:** Complete CRUD operations for employee management
- **Content Negotiation:** JSON and XML response formats
- **Thread-Safe Storage:** Concurrent request handling
- **Request Validation:** Input validation and error handling
- **Logging:** Structured JSON logging for all operations

## Technology Stack

- **Runtime:** Node.js 16+
- **Framework:** Express.js 4.x
- **Cloud Platform:** Railway.app (PaaS)
- **CI/CD:** GitHub Actions
- **Testing:** Jest + Supertest
- **Security:** Helmet.js, CORS
- **Compression:** gzip compression
- **Logging:** Morgan + Custom JSON logger

## Environment Configuration

### Data Warehouse Service

```bash
NODE_ENV=production
PORT=8080
```

### Reverse Proxy Service

```bash
NODE_ENV=production
PORT=8080
PROXY_HOST=0.0.0.0
DW_SERVERS=web:8080
```

## API Documentation

### Data Warehouse Endpoints

#### Health Check

```bash
GET /health
```

Response:

```json
{
  "status": "healthy",
  "timestamp": "2025-10-30T12:00:00.000Z",
  "uptime": 3600,
  "version": "1.0.0"
}
```

#### List All Employees

```bash
GET /employees
```

#### Get Employee by ID

```bash
GET /employees/:id
```

#### Create Employee

```bash
PUT /employees/:id
Content-Type: application/json

{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "department": "Engineering",
  "position": "Software Engineer",
  "salary": 75000
}
```

#### Update Employee

```bash
POST /employees/:id
Content-Type: application/json

{
  "salary": 80000
}
```

#### Delete Employee

```bash
DELETE /employees/:id
```

### Reverse Proxy Endpoints

#### Proxy Health Check

```bash
GET /proxy/health
```

#### Proxy Statistics

```bash
GET /proxy/stats
```

#### Clear Cache

```bash
DELETE /proxy/cache
```

## Testing

### Run Unit Tests

```bash
npm test
```

### Run Tests with Coverage

```bash
npm run test:coverage
```

### Test Results

```
Test Suites: 2 passed, 2 total
Tests:       17 passed, 17 total
- Employee Model: 11 tests
- Employee Service: 6 tests
```

## CI/CD Pipeline

### GitHub Actions Workflow

**Triggers:**

- Push to `main` or `develop` branches
- Pull requests to `main`

**Jobs:**

1. **Test** - Runs on Node.js 16.x, 18.x, 20.x

   - Install dependencies
   - Run unit tests
   - Generate coverage reports

2. **Lint** - Code quality checks

   - Syntax validation

3. **Build** - Verify build integrity

   - Dependency installation verification

4. **Deploy Status** - Deployment notification
   - Railway auto-deploy information

### Railway Auto-Deploy

**Process:**

1. Code pushed to `main` branch
2. GitHub Actions runs automated tests
3. Railway detects repository changes
4. Automatic build and deployment (approximately 60 seconds)
5. Health checks verify deployment success

## Deployment

### Prerequisites

- Node.js 16+ installed
- Railway.app account
- GitHub repository

### Deploy to Railway

1. **Connect Repository**

   ```bash
   railway link
   ```

2. **Configure Environment Variables**

   - Set variables in Railway Dashboard
   - See Environment Configuration section above

3. **Deploy**
   ```bash
   git push origin main
   ```

Railway will automatically detect the Node.js application and deploy using the Procfile configuration.

## Local Development

### Install Dependencies

```bash
npm install
```

### Run Data Warehouse

```bash
npm run start:warehouse
```

### Run Reverse Proxy

```bash
npm run start:proxy
```

### Run All Services

```bash
npm start
```

## Monitoring

### Health Checks

```bash
# Data Warehouse
curl https://data-warehouse.up.railway.app/health

# Reverse Proxy
curl https://reverse-proxy-server.up.railway.app/proxy/health
```

### Performance Metrics

```bash
# Load balancer statistics
curl https://reverse-proxy-server.up.railway.app/proxy/stats
```

## Cost Estimation

**Railway Free Tier:**

- $5 credit per month
- 500 execution hours (approximately 20 days 24/7)
- 100GB bandwidth

**Estimated Monthly Cost:**

- Data Warehouse: $2.50
- Reverse Proxy: $2.50
- **Total: $5.00** (covered by free tier credit)

## Repository

**GitHub:** https://github.com/gheorghe133/cloud-setup  
**License:** MIT

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── ci.yml                 # GitHub Actions CI/CD
├── src/
│   ├── client/
│   │   └── client.js              # Test client
│   ├── config/
│   │   └── config.js              # Configuration
│   ├── proxy/
│   │   ├── cache/
│   │   │   └── CacheManager.js
│   │   ├── connections/
│   │   │   └── ConnectionManager.js
│   │   ├── loadbalancer/
│   │   │   └── RoundRobinBalancer.js
│   │   └── server.js              # Proxy server
│   ├── utils/
│   │   ├── logger.js
│   │   └── responseFormatter.js
│   └── warehouse/
│       ├── controllers/
│       │   └── EmployeeController.js
│       ├── models/
│       │   └── Employee.js
│       ├── services/
│       │   └── EmployeeService.js
│       ├── storage/
│       │   └── ThreadSafeStorage.js
│       └── server.js              # Warehouse server
├── Procfile                       # Railway deployment config
├── railway.json                   # Railway build config
└── package.json                   # Dependencies
```
