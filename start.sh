#!/bin/bash
clear
echo "=========================================="
echo "MTA:SA Server - Trident Sky Edition"
echo "MySQL Ready | FastDL Ready"
echo "www.tridentsky.net"
echo "=========================================="

if [ "${FASTDL_ENABLED}" = "1" ]; then
    echo "[FastDL] Checking Nginx installation..."
    if ! command -v nginx &> /dev/null; then
        echo "[FastDL] Installing Nginx..."
        apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nginx-light > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "[FastDL] Nginx installed successfully"
        else
            echo "[FastDL] Failed to install Nginx - Skipping FastDL"
            echo ""
            echo "[MTA] Starting server on port ${SERVER_PORT}..."
            ./mta-server64 --port ${SERVER_PORT} --httpport ${SERVER_WEBPORT} -n
            exit 0
        fi
    fi

    echo "[FastDL] Initializing on port ${FASTDL_PORT}..."

    mkdir -p /tmp/nginx_cache/{client_body,proxy,fastcgi,uwsgi,scgi}

    cat > /tmp/nginx.conf << 'EOF'
worker_processes auto;
error_log /tmp/nginx_error.log warn;
pid /tmp/nginx.pid;
events {
    worker_connections 1024;
}
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    client_body_temp_path /tmp/nginx_cache/client_body;
    proxy_temp_path /tmp/nginx_cache/proxy;
    fastcgi_temp_path /tmp/nginx_cache/fastcgi;
    uwsgi_temp_path /tmp/nginx_cache/uwsgi;
    scgi_temp_path /tmp/nginx_cache/scgi;
    sendfile on;
    tcp_nopush on;
    keepalive_timeout 30;
    gzip on;
    gzip_types application/octet-stream text/xml;
    server {
EOF

    echo "        listen ${FASTDL_PORT};" >> /tmp/nginx.conf

    cat >> /tmp/nginx.conf << 'EOF'
        root /home/container/mods/deathmatch/resource-cache/http-client-files;
        access_log /tmp/nginx_access.log;
        error_log /tmp/nginx_server_error.log;
        location / {
            autoindex off;
        }
    }
}
EOF

    echo "[FastDL] Testing Nginx config..."
    nginx -t -c /tmp/nginx.conf

    if [ $? -eq 0 ]; then
        nginx -c /tmp/nginx.conf
        sleep 2
        if pgrep -x nginx > /dev/null; then
            echo "[FastDL] ✓ Active on port ${FASTDL_PORT}"
            echo "[FastDL] Test URL: http://YOUR_IP:${FASTDL_PORT}/admin/conf/interiors.xml"
        else
            echo "[FastDL] ✗ Failed to start - Check /tmp/nginx_error.log"
            cat /tmp/nginx_error.log 2>/dev/null || echo "No error log found"
        fi
    else
        echo "[FastDL] ✗ Config test failed"
    fi
else
    echo "[FastDL] Disabled (Set FASTDL_ENABLED=1 to enable)"
fi

echo ""
echo "[MTA] Starting server on port ${SERVER_PORT}..."
./mta-server64 --port ${SERVER_PORT} --httpport ${SERVER_WEBPORT} -n
