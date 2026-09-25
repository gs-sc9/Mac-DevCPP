#!/bin/zsh
# airdrop_share.command 唤起mac原生隔空投送分享面板
# 参数：./airdrop_share.command 文件路径
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)

TARGET_FILE="$1"

if [ -z "${TARGET_FILE}" ];then
    echo "用法： ./airdrop_share.command 要发送的文件"
    exit 1
fi

if [ ! -f "${TARGET_FILE}" ];then
    echo "[ERROR] 文件不存在: ${TARGET_FILE}"
    exit 1
fi

# 调用macOS系统分享（包含隔空投送、信息等）
open -a SharingPicker "${TARGET_FILE}"
echo "✅已唤起系统分享面板，请手动选择隔空投送设备发送文件"
exit 0
