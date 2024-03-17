#!/bin/bash

# 定义目录路径
TARGET_DIR="/data/wwwroot"

# 检查目录是否存在
if [ ! -d "$TARGET_DIR" ]; then
    echo "目标目录 $TARGET_DIR 不存在。"
    exit 1
fi

# 遍历并处理每个子目录
find "$TARGET_DIR" -mindepth 1 -maxdepth 1 -type d | while read -r d; do
    echo "正在处理目录: $d"
    # 创建必要的目录
    mkdir -p "$d/public" "$d/log" "$d/ssl" "$d/waf"

    # 创建日志文件，如果不存在
    for logfile in "access.log" "error.log"; do
        if [ ! -f "$d/log/$logfile" ]; then
            touch "$d/log/$logfile"
        fi
    done

    # 创建SSL文件，如果不存在
    for sslfile in "fullchain.pem" "privkey.pem"; do
        if [ ! -f "$d/ssl/$sslfile" ]; then
            touch "$d/ssl/$sslfile"
        fi
    done

    echo "处理完毕: $d"
done
