#!/bin/bash

# --- 配置区域 ---
# 下载 Xray 核心 (这里使用官方版本，你可以随时换成别的链接)
DOWNLOAD_URL="https://github.com/XTLS/Xray-core/releases/download/v1.8.4/Xray-linux-64.zip"
# 伪装的文件名
BIN_NAME="web"
# ----------------

echo "正在初始化环境..."

# 1. 下载核心文件
if [ ! -f "$BIN_NAME" ]; then
    echo "正在下载核心..."
    wget -O core.zip $DOWNLOAD_URL
    unzip core.zip
    mv xray $BIN_NAME
    rm core.zip geo* LICENSE README.md
    chmod +x $BIN_NAME
    echo "下载完成。"
else
    echo "核心文件已存在。"
fi

# 2. 生成配置文件 (config.json)
# 注意：HF 强制监听 7860 端口
echo "正在生成配置..."
cat << EOF > config.json
{
  "inbounds": [
    {
      "port": 7860,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$UUID"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vl"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF

# 3. 启动
echo "启动服务..."
./$BIN_NAME -c config.json
