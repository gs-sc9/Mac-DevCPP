#!/bin/zsh
# auto_format.command clang‑format代码格式化，复刻Dev‑C++风格
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
SRC_FILE="$1"

if [ -z "${SRC_FILE}" ] || [ ! -f "${SRC_FILE}" ];then
    echo "用法： ./auto_format.command 源码文件.cpp"
    exit 1
fi

# Dev‑C++ 风格配置
FORMAT_CONF="${SCRIPT_DIR}/.clang-format"
cat > "${FORMAT_CONF}" <<'EOF'
BasedOnStyle: LLVM
IndentWidth: 4
TabWidth: 4
UseTab: Never
BreakBeforeBraces: Attach
ColumnLimit: 120
PointerAlignment: Left
EOF

if ! command -v clang-format &> /dev/null
then
    echo "[ERROR] 未找到clang‑format，执行 brew install clang-format"
    exit 1
fi

echo "格式化：${SRC_FILE}"
clang-format -i "${SRC_FILE}" --style=file:"${FORMAT_CONF}"
echo "✅格式化完成"
exit 0
