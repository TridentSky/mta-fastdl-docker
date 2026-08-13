#!/bin/bash
echo "=========================================="
echo "MTA:SA Server - Trident Sky Edition"
echo "MySQL Ready | FastDL Ready"
echo "https://tridentsky.net/"
echo "=========================================="

echo "[MySQL] Checking MySQL module..."
if [ ! -f "x64/modules/mta_mysql.so" ] || [ ! -s "x64/modules/mta_mysql.so" ]; then
    echo "[MySQL] Installing MySQL module..."
    mkdir -p x64/modules
    rm -f x64/modules/mta_mysql.so
    wget --timeout=10 --tries=3 -q -O x64/modules/mta_mysql.so https://nightly.mtasa.com/files/modules/64/mta_mysql.so
    if [ -s "x64/modules/mta_mysql.so" ]; then
        chmod 755 x64/modules/mta_mysql.so
        echo "[MySQL] ✓ Module installed successfully"
    else
        echo "[MySQL] ✗ Failed to download module"
        rm -f x64/modules/mta_mysql.so
    fi
else
    echo "[MySQL] ✓ Module already present"
fi

if [ "${FASTDL_ENABLED}" = "1" ]; then
    echo "[FastDL] Initializing on port ${FASTDL_PORT}..."

    if ! command -v nginx &> /dev/null; then
        echo "[FastDL] Warning: Nginx not found, FastDL disabled"
        FASTDL_ENABLED=0
    fi
fi

if [ "${FASTDL_ENABLED}" = "1" ]; then

    mkdir -p /tmp/nginx_cache/{client_body,proxy,fastcgi,uwsgi,scgi}

    cat > /tmp/nginx.conf << 'EOF'
worker_processes auto;
worker_rlimit_nofile 16384;
error_log /tmp/nginx_error.log error;
pid /tmp/nginx.pid;
events {
    worker_connections 4096;
    multi_accept on;
}
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    client_body_temp_path /tmp/nginx_cache/client_body;
    proxy_temp_path /tmp/nginx_cache/proxy;
    fastcgi_temp_path /tmp/nginx_cache/fastcgi;
    uwsgi_temp_path /tmp/nginx_cache/uwsgi;
    scgi_temp_path /tmp/nginx_cache/scgi;
    access_log off;
    server_tokens off;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 30;
    client_header_timeout 15s;
    client_body_timeout 15s;
    send_timeout 30s;
    reset_timedout_connection on;
    client_max_body_size 1m;
    max_ranges 1;
    limit_conn_zone $binary_remote_addr zone=perip:10m;
    sendfile_max_chunk 512k;
    open_file_cache max=10000 inactive=60s;
    open_file_cache_valid 60s;
    open_file_cache_min_uses 1;
    open_file_cache_errors off;
    gzip on;
    gzip_types application/octet-stream text/xml;
    server {
EOF

    echo "        listen ${FASTDL_PORT};" >> /tmp/nginx.conf

    cat >> /tmp/nginx.conf << 'EOF'
        root /home/container/mods/deathmatch/resource-cache/http-client-files;
        access_log off;
        error_log /tmp/nginx_server_error.log error;
        limit_conn perip 100;
        location ~ /\. {
            deny all;
        }
        location / {
            autoindex off;
            limit_except GET {
                deny all;
            }
        }
    }
}
EOF

    nginx -t -c /tmp/nginx.conf 2>&1 | grep -v "alert" | grep -v "warn" > /tmp/nginx_test.log

    if nginx -c /tmp/nginx.conf 2>/dev/null; then
        sleep 1
        if pgrep -x nginx > /dev/null; then
            echo "[FastDL] ✓ Active on port ${FASTDL_PORT}"
        else
            echo "[FastDL] ✗ Failed to start"
        fi
    else
        echo "[FastDL] ✗ Config test failed"
    fi
else
    echo "[FastDL] Disabled (Set FASTDL_ENABLED=1 to enable)"
fi

echo ""
echo "[MTA] Configuring mtaserver.conf..."

if [ "${FASTDL_ENABLED}" = "1" ]; then
    FASTDL_URL="http://${SERVER_IP}:${FASTDL_PORT}/"

    if grep -q "<httpdownloadurl>" mods/deathmatch/mtaserver.conf 2>/dev/null; then
        sed -i "s|<httpdownloadurl>.*</httpdownloadurl>|<httpdownloadurl>${FASTDL_URL}</httpdownloadurl>|g" mods/deathmatch/mtaserver.conf
    else
        sed -i "s|</config>|    <httpdownloadurl>${FASTDL_URL}</httpdownloadurl>\n</config>|g" mods/deathmatch/mtaserver.conf
    fi
    echo "[MTA] FastDL URL configured: ${FASTDL_URL}"
else
    if grep -q "<httpdownloadurl>" mods/deathmatch/mtaserver.conf 2>/dev/null; then
        sed -i "/<httpdownloadurl>/d" mods/deathmatch/mtaserver.conf
    fi
    echo "[MTA] FastDL disabled - URL removed from config"
fi

echo "[MTA] Starting server on port ${SERVER_PORT}..."
exec ./mta-server64 --port ${SERVER_PORT} --httpport ${SERVER_WEBPORT} -n
