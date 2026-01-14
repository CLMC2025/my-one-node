# 使用 Debian 作为基础系统
FROM debian:bullseye-slim

# 安装下载工具和解压工具
RUN apt-get update && apt-get install -y wget unzip iproute2 && \
    rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 复制启动脚本放入容器
COPY entrypoint.sh .

# 赋予脚本执行权限
RUN chmod +x entrypoint.sh

# 创建一个非 root 用户 (Hugging Face 强制要求)
RUN useradd -m -u 1000 user
USER 1000
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# 启动命令
CMD ["./entrypoint.sh"]
