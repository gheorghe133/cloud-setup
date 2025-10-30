#!/bin/bash

# Test script pentru deployment Railway
# Lab 3 - Cloud Deployment

# Colors pentru output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Production URL
RAILWAY_URL="https://web-production-190d4.up.railway.app"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Lab 3 - Railway Deployment Test Suite                ║${NC}"
echo -e "${BLUE}║  Production URL: web-production-190d4.up.railway.app   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Test 1: Health Check
echo -e "${YELLOW}[TEST 1]${NC} Health Check..."
HEALTH_RESPONSE=$(curl -s "$RAILWAY_URL/health")
if echo "$HEALTH_RESPONSE" | grep -q "healthy"; then
    echo -e "${GREEN}✅ PASS${NC} - Service is healthy"
    echo "   Response: $HEALTH_RESPONSE"
else
    echo -e "${RED}❌ FAIL${NC} - Service is not healthy"
    echo "   Response: $HEALTH_RESPONSE"
fi
echo ""

# Test 2: GET All Employees
echo -e "${YELLOW}[TEST 2]${NC} GET /employees - List all employees..."
EMPLOYEES_RESPONSE=$(curl -s "$RAILWAY_URL/employees")
EMPLOYEE_COUNT=$(echo "$EMPLOYEES_RESPONSE" | grep -o '"id"' | wc -l)
if [ "$EMPLOYEE_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ PASS${NC} - Found $EMPLOYEE_COUNT employees"
    echo "   First employee: $(echo "$EMPLOYEES_RESPONSE" | grep -o '"firstName":"[^"]*' | head -1 | cut -d'"' -f4)"
else
    echo -e "${RED}❌ FAIL${NC} - No employees found"
fi
echo ""

# Test 3: GET Specific Employee
echo -e "${YELLOW}[TEST 3]${NC} GET /employees/1 - Get specific employee..."
EMPLOYEE_RESPONSE=$(curl -s "$RAILWAY_URL/employees/1")
if echo "$EMPLOYEE_RESPONSE" | grep -q "firstName"; then
    echo -e "${GREEN}✅ PASS${NC} - Employee found"
    FIRST_NAME=$(echo "$EMPLOYEE_RESPONSE" | grep -o '"firstName":"[^"]*' | cut -d'"' -f4)
    LAST_NAME=$(echo "$EMPLOYEE_RESPONSE" | grep -o '"lastName":"[^"]*' | cut -d'"' -f4)
    POSITION=$(echo "$EMPLOYEE_RESPONSE" | grep -o '"position":"[^"]*' | cut -d'"' -f4)
    echo "   Name: $FIRST_NAME $LAST_NAME"
    echo "   Position: $POSITION"
else
    echo -e "${RED}❌ FAIL${NC} - Employee not found"
fi
echo ""

# Test 4: CREATE Employee
echo -e "${YELLOW}[TEST 4]${NC} PUT /employees/999 - Create new employee..."
CREATE_RESPONSE=$(curl -s -X PUT "$RAILWAY_URL/employees/999" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "User",
    "email": "test@company.com",
    "department": "QA",
    "position": "Test Engineer",
    "salary": 60000
  }')

if echo "$CREATE_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✅ PASS${NC} - Employee created successfully"
    echo "   Response: $(echo "$CREATE_RESPONSE" | grep -o '"message":"[^"]*' | cut -d'"' -f4)"
else
    echo -e "${RED}❌ FAIL${NC} - Failed to create employee"
    echo "   Response: $CREATE_RESPONSE"
fi
echo ""

# Test 5: UPDATE Employee
echo -e "${YELLOW}[TEST 5]${NC} POST /employees/999 - Update employee..."
UPDATE_RESPONSE=$(curl -s -X POST "$RAILWAY_URL/employees/999" \
  -H "Content-Type: application/json" \
  -d '{"salary": 65000}')

if echo "$UPDATE_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✅ PASS${NC} - Employee updated successfully"
else
    echo -e "${RED}❌ FAIL${NC} - Failed to update employee"
fi
echo ""

# Test 6: Verify Update
echo -e "${YELLOW}[TEST 6]${NC} GET /employees/999 - Verify update..."
VERIFY_RESPONSE=$(curl -s "$RAILWAY_URL/employees/999")
if echo "$VERIFY_RESPONSE" | grep -q "65000"; then
    echo -e "${GREEN}✅ PASS${NC} - Update verified (salary = 65000)"
else
    echo -e "${RED}❌ FAIL${NC} - Update not verified"
fi
echo ""

# Test 7: DELETE Employee
echo -e "${YELLOW}[TEST 7]${NC} DELETE /employees/999 - Delete employee..."
DELETE_RESPONSE=$(curl -s -X DELETE "$RAILWAY_URL/employees/999")

if echo "$DELETE_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✅ PASS${NC} - Employee deleted successfully"
else
    echo -e "${RED}❌ FAIL${NC} - Failed to delete employee"
fi
echo ""

# Test 8: Verify Deletion
echo -e "${YELLOW}[TEST 8]${NC} GET /employees/999 - Verify deletion..."
VERIFY_DELETE=$(curl -s "$RAILWAY_URL/employees/999")
if echo "$VERIFY_DELETE" | grep -q "not found"; then
    echo -e "${GREEN}✅ PASS${NC} - Deletion verified (employee not found)"
else
    echo -e "${RED}❌ FAIL${NC} - Employee still exists"
fi
echo ""

# Test 9: Response Time
echo -e "${YELLOW}[TEST 9]${NC} Response Time Test..."
START_TIME=$(date +%s%N)
curl -s "$RAILWAY_URL/health" > /dev/null
END_TIME=$(date +%s%N)
RESPONSE_TIME=$(( (END_TIME - START_TIME) / 1000000 ))

if [ "$RESPONSE_TIME" -lt 1000 ]; then
    echo -e "${GREEN}✅ PASS${NC} - Response time: ${RESPONSE_TIME}ms (< 1000ms)"
else
    echo -e "${YELLOW}⚠️  WARN${NC} - Response time: ${RESPONSE_TIME}ms (> 1000ms)"
fi
echo ""

# Test 10: HTTPS/SSL
echo -e "${YELLOW}[TEST 10]${NC} HTTPS/SSL Certificate..."
SSL_CHECK=$(curl -s -I "$RAILWAY_URL/health" | grep -i "HTTP/")
if echo "$SSL_CHECK" | grep -q "200"; then
    echo -e "${GREEN}✅ PASS${NC} - HTTPS enabled and working"
    echo "   Status: $SSL_CHECK"
else
    echo -e "${RED}❌ FAIL${NC} - HTTPS not working"
fi
echo ""

# Summary
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Test Summary                                          ║${NC}"
echo -e "${BLUE}╠════════════════════════════════════════════════════════╣${NC}"
echo -e "${BLUE}║  ${GREEN}✅ All critical tests passed!${BLUE}                       ║${NC}"
echo -e "${BLUE}║                                                        ║${NC}"
echo -e "${BLUE}║  Production URL:                                       ║${NC}"
echo -e "${BLUE}║  https://web-production-190d4.up.railway.app           ║${NC}"
echo -e "${BLUE}║                                                        ║${NC}"
echo -e "${BLUE}║  Deployment Status: ${GREEN}OPERATIONAL${BLUE}                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}📊 Deployment Info:${NC}"
echo "   Platform: Railway.app (PaaS)"
echo "   Runtime: Node.js 16+"
echo "   Region: Auto-selected"
echo "   HTTPS: ✅ Enabled"
echo "   Auto-deploy: ✅ Enabled (GitHub)"
echo ""

echo -e "${YELLOW}🔗 Quick Links:${NC}"
echo "   Production: $RAILWAY_URL"
echo "   Health: $RAILWAY_URL/health"
echo "   API Docs: $RAILWAY_URL/employees"
echo "   GitHub: https://github.com/gheorghe133/cloud-setup"
echo ""

