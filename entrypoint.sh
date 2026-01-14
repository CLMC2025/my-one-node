#!/bin/bash

# --- 1. 强行修改容器 DNS (解决 YouTube 无法访问) ---
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf

# --- 2. 下载核心 ---
DOWNLOAD_URL="https://github.com/XTLS/Xray-core/releases/download/v1.8.4/Xray-linux-64.zip"
BIN_NAME="web"

if [ ! -f "$BIN_NAME" ]; then
    echo "正在下载核心..."
    wget -O core.zip $DOWNLOAD_URL
    unzip core.zip
    mv xray $BIN_NAME
    rm core.zip geo* LICENSE README.md
    chmod +x $BIN_NAME
fi

# --- 3. 生成配置 (带嗅探) ---
cat << EOF > config.json
{
  "log": { "loglevel": "warning" },
  "inbounds": [{
    "port": 7860,
    "protocol": "vless",
    "settings": { "clients": [{ "id": "$UUID" }], "decryption": "none" },
    "streamSettings": { "network": "ws", "wsSettings": { "path": "/vl" } },
    "sniffing": { "enabled": true, "destOverride": ["http", "tls"] }
  }],
  "outbounds": [{ "protocol": "freedom", "settings": { "domainStrategy": "UseIP" } }],
  "dns": { "servers": ["8.8.8.8", "1.1.1.1"] }
}
EOF

# --- 4. 【新增】自动保活模块 ---
# 说明：Hugging Face 只有收到 HTTP 请求才算活跃。
# 我们在后台每 2 分钟访问一次自己的域名。
if [ -n "$SPACE_HOST" ]; then
    echo "启动后台保活: https://$SPACE_HOST"
    while true; do 
        curl -s "https://$SPACE_HOST" > /dev/null
        sleep 120
    done &
fi

# --- 5. 启动主程序 ---
echo "启动服务..."
./$BIN_NAME -c config.json
