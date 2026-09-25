#!/bin/zsh
# quick search.command 项目代码快速搜索
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)

echo "==== Quick Search 代码搜索工具 ===="
SEARCH_KEY="$1"

if [ -z "${SEARCH_KEY}" ];then
    echo "用法："
    echo "./quick search.command 关键词"
    echo "示例： ./quick search.command int main"
    exit 0
fi

echo "在目录 ${SCRIPT_DIR} 搜索：【${SEARCH_KEY}】"
echo "------------------------------"

# 搜索 .c .cpp .h .hpp 源码文件，忽略dmg挂载目录
grep -r -n --include=*.c --include=*.cpp --include=*.h --include=*.hpp \
    --exclude-dir=fast_compile "${SEARCH_KEY}" "${SCRIPT_DIR}"

if [ $? -ne 0 ]; then
    echo "未找到匹配内容"
fi

echo "------------------------------"
echo "搜索结束"
exit 0
