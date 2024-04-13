#!/bin/bash

# 检查是否以root权限运行
if [[ $(id -u) -ne 0 ]]; then
    echo "此脚本需要以root权限运行。请使用sudo执行此脚本。"
    exit 1
fi

# 定义目录路径
TARGET_DIR="/data/wwwroot"

# 第一步：列出$TARGET_DIR目录下的所有子目录
echo "列出所有子目录:"
subdirs=($(find "$TARGET_DIR" -mindepth 1 -maxdepth 1 -type d))
for dir in "${subdirs[@]}"; do
    echo "$dir"
done

# 检查并创建必要的目录
echo "检查并创建目录:"
for dir in "${subdirs[@]}"; do
    for subdir in public log ssl waf; do
        if [ ! -d "$dir/$subdir" ]; then
            mkdir -p "$dir/$subdir"
            echo "创建了目录: $dir/$subdir"
        else
            echo "已存在目录: $dir/$subdir"
        fi
    done
done

# 第二步：检查并创建必要的文件
echo "检查并创建必要的文件:"
for dir in "${subdirs[@]}"; do
    # 检查 log 文件
    for logfile in access.log error.log; do
        if [ ! -f "$dir/log/$logfile" ]; then
            touch "$dir/log/$logfile"
            echo "创建了文件: $dir/log/$logfile"
        else
            echo "已存在文件: $dir/log/$logfile"
        fi
    done

    # 检查 ssl 文件
    for sslfile in origin.crt private.key; do
        if [ ! -f "$dir/ssl/$sslfile" ]; then
            touch "$dir/ssl/$sslfile"
            echo "创建了文件: $dir/ssl/$sslfile"
        else
            echo "已存在文件: $dir/ssl/$sslfile"
        fi
    done
done

# 第三步：移动文件到public目录
echo "移动文件到 public 目录:"
if [ -d "/data/wwwroot/default" ]; then
    mkdir -p "/data/wwwroot/default/public"
    find "/data/wwwroot/default" -mindepth 1 -maxdepth 1 ! -name "public" -exec mv {} "/data/wwwroot/default/public/" \;
    echo "文件已移动到 /data/wwwroot/default/public/"
else
    echo "/data/wwwroot/default 目录不存在"
fi

# 第四步：修改权限
echo "修改文件和目录的所有者:"
chown -R www:www "$TARGET_DIR"
echo "权限修改完成。"
