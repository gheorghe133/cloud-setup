#!/usr/bin/env node

/**
 * Launcher script for Railway deployment
 * Starts both Data Warehouse and Reverse Proxy
 */

const { fork } = require('child_process');
const path = require('path');

// Railway assigns $PORT - we'll use it for the proxy (public-facing)
const PROXY_PORT = process.env.PORT || 8080;
const WAREHOUSE_PORT = 3000;

console.log('🚀 Starting Lab 3 - Cloud Deployment');
console.log('=====================================');
console.log(`Proxy Port: ${PROXY_PORT} (public)`);
console.log(`Warehouse Port: ${WAREHOUSE_PORT} (internal)`);
console.log('=====================================\n');

let warehouse, proxy;

// Start Data Warehouse on port 3000
console.log('📦 Starting Data Warehouse...');
warehouse = fork(path.join(__dirname, 'src/warehouse/server.js'), [], {
  env: {
    ...process.env,
    PORT: WAREHOUSE_PORT,
    DW_PORT: WAREHOUSE_PORT,
    DW_HOST: '0.0.0.0',
    NODE_ENV: process.env.NODE_ENV || 'production'
  },
  silent: false
});

warehouse.on('error', (error) => {
  console.error('❌ Data Warehouse failed to start:', error);
  process.exit(1);
});

warehouse.on('exit', (code, signal) => {
  console.error(`❌ Data Warehouse exited with code ${code}, signal ${signal}`);
  if (proxy) proxy.kill();
  process.exit(code || 1);
});

// Wait for warehouse to start, then start proxy
setTimeout(() => {
  console.log('🔄 Starting Reverse Proxy...');
  proxy = fork(path.join(__dirname, 'src/proxy/server.js'), [], {
    env: {
      ...process.env,
      PORT: PROXY_PORT,
      PROXY_PORT: PROXY_PORT,
      PROXY_HOST: '0.0.0.0',
      DW_SERVERS: `localhost:${WAREHOUSE_PORT}`,
      NODE_ENV: process.env.NODE_ENV || 'production'
    },
    silent: false
  });

  proxy.on('error', (error) => {
    console.error('❌ Reverse Proxy failed to start:', error);
    if (warehouse) warehouse.kill();
    process.exit(1);
  });

  proxy.on('exit', (code, signal) => {
    console.error(`❌ Reverse Proxy exited with code ${code}, signal ${signal}`);
    if (warehouse) warehouse.kill();
    process.exit(code || 1);
  });

  console.log('\n✅ Both services starting...');
  console.log(`🌐 Proxy (public): http://0.0.0.0:${PROXY_PORT}`);
  console.log(`📦 Warehouse (internal): http://localhost:${WAREHOUSE_PORT}`);
}, 3000);

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('\n🛑 Received SIGTERM, shutting down gracefully...');
  if (proxy) proxy.kill('SIGTERM');
  if (warehouse) warehouse.kill('SIGTERM');
  setTimeout(() => process.exit(0), 5000);
});

process.on('SIGINT', () => {
  console.log('\n🛑 Received SIGINT, shutting down gracefully...');
  if (proxy) proxy.kill('SIGINT');
  if (warehouse) warehouse.kill('SIGINT');
  setTimeout(() => process.exit(0), 5000);
});

