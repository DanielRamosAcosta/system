#!/bin/sh
set -e

echo "===== Piped Frontend Entrypoint Start ====="
echo "BACKEND_HOSTNAME: ${BACKEND_HOSTNAME}"
echo "HTTP_MODE: ${HTTP_MODE}"

if [ -z "${BACKEND_HOSTNAME}" ]; then
    echo "ERROR: BACKEND_HOSTNAME not set"
    exit 1
fi

HTTP_MODE=${HTTP_MODE:-https}
echo "Using HTTP_MODE: ${HTTP_MODE}"

echo "===== Replacing URLs in assets ====="
echo "Step 1: Replacing https://pipedapi.kavin.rocks with ${HTTP_MODE}://pipedapi.kavin.rocks"
sed -i "s@https://pipedapi.kavin.rocks@${HTTP_MODE}://pipedapi.kavin.rocks@g" /usr/share/nginx/html/assets/*
echo "Step 1: Done"

echo "Step 2: Replacing pipedapi.kavin.rocks with ${BACKEND_HOSTNAME}"
sed -i "s@pipedapi.kavin.rocks@${BACKEND_HOSTNAME}@g" /usr/share/nginx/html/assets/*
echo "Step 2: Done"

echo "===== Verifying replacements ====="
if grep -q "pipedapi.kavin.rocks" /usr/share/nginx/html/assets/* 2>/dev/null; then
    echo "WARNING: Still found pipedapi.kavin.rocks in assets"
    grep -l "pipedapi.kavin.rocks" /usr/share/nginx/html/assets/* 2>/dev/null | head -3
else
    echo "SUCCESS: No pipedapi.kavin.rocks found in assets"
fi

if grep -q "${BACKEND_HOSTNAME}" /usr/share/nginx/html/assets/* 2>/dev/null; then
    echo "SUCCESS: Found ${BACKEND_HOSTNAME} in assets"
    grep -l "${BACKEND_HOSTNAME}" /usr/share/nginx/html/assets/* 2>/dev/null | head -3
else
    echo "WARNING: ${BACKEND_HOSTNAME} not found in assets"
fi

if [ -n "${HTTP_WORKERS}" ]; then
    echo "Setting HTTP_WORKERS to ${HTTP_WORKERS}"
    sed -i "s/worker_processes  auto;/worker_processes  ${HTTP_WORKERS};/g" /etc/nginx/nginx.conf
fi

if [ -n "${HTTP_PORT}" ]; then
    echo "Setting HTTP_PORT to ${HTTP_PORT}"
    sed -i "s/80;/${HTTP_PORT};/g" /etc/nginx/conf.d/default.conf
fi

echo "===== Starting nginx ====="
exec nginx -g "daemon off;"
