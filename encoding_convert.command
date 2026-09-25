#!/bin/zsh
# encoding_convert.command 自动检测编码，GBK <--> UTF‑8
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
TARGET_FILE="$1"

if [ -z "${TARGET_FILE}" ] || [ ! -f "${TARGET_FILE}" ];then
    echo "用法： ./encoding_convert.command 源码.cpp"
    exit 1
fi

if ! command -v uchardet &> /dev/null
then
    echo "[WARN] 缺少编码检测工具，执行：brew install uchardet"
    exit 1
fi

# 自动检测文件编码
DETECT_ENC=$(uchardet "${TARGET_FILE}" | tr '[:lower:]' '[:upper:]')
echo "检测文件编码: ${DETECT_ENC}"

# 如果是GBK/GB2312，转为UTF‑8；UTF‑8不处理
if [[ "${DETECT_ENC}" == "GBK" || "${DETECT_ENC}" == "GB2312" ]];then
    echo "检测到GBK编码，转换为UTF‑8"
    iconv -f GBK -t UTF‑8 "${TARGET_FILE}" -o "${TARGET_FILE}.tmp"
    mv "${TARGET_FILE}.tmp" "${TARGET_FILE}"
    echo "✅已转换为UTF‑8"
elif [[ "${DETECT_ENC}" == "UTF‑8" ]];then
    echo "文件已是UTF‑8，无需转换"
else
    echo "未识别为GBK/UTF‑8，跳过转换"
fi

exit 0
