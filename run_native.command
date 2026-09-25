#!/bin/zsh
# run_native.command macOS原生clang编译运行，默认关闭，传入enable启用
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
SRC_FILE="$1"
MODE="$2"

# 默认关闭，只有第二个参数等于enable才工作
if [ "${MODE}" != "enable" ];then
    echo "[INFO] native本机编译模式：默认已关闭；调用示例： ./run_native.command test.cpp enable"
    exit 0
fi

if [ -z "${SRC_FILE}" ] || [ ! -f "${SRC_FILE}" ];then
    echo "用法： ./run_native.command 源码.cpp enable"
    exit 1
fi

BIN_OUT="${SCRIPT_DIR}/native_run_out"
mkdir -p "${BIN_OUT}"
EXE="${BIN_OUT}/app_native"

echo "==== macOS原生编译（clang++） ===="
clang++ -std=c++17 "${SRC_FILE}" -o "${EXE}" -Wall
if [ $? -eq 0 ];then
    echo "✅本机编译成功，运行程序："
    echo "----------------------------------------"
    "${EXE}"
    echo "----------------------------------------"
    echo "程序执行结束"
else
    echo "❌本机编译出错"
    exit 1
fi
exit 0
