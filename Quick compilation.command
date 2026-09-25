#!/bin/zsh
# Quick compilation.command 升级版：区分缺头文件 / 缺失函数
# 自动使用fast.dmg内存盘，增加挂载检测，兼容mac BSD工具
SOURCE_FILE="$1"
FAST_DMG_PATH="${SCRIPT_DIR}/fast.dmg"
MOUNT_POINT="/Volumes/fast_compile"

SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
FAST_DMG_PATH="${SCRIPT_DIR}/fast.dmg"
FUNCTION_LIB="${SCRIPT_DIR}/Function library.command"

if [ ! -d "${MOUNT_POINT}" ]; then
    if [ -f "${FAST_DMG_PATH}" ]; then
        echo "Info: Fast dmg not mounted, attaching..."
        hdiutil attach "${FAST_DMG_PATH}" -mountpoint "${MOUNT_POINT}" -nobrowse
        if [ $? -ne 0 ];then
            echo "Warning: fast.dmg挂载失败，使用本地目录编译"
            TMP_SRC="${SCRIPT_DIR}/tmp_auto_fill.cpp"
        else
            echo "Done: fast_compile内存盘挂载成功"
            TMP_SRC="${MOUNT_POINT}/tmp_auto_fill.cpp"
        fi
    else
        echo "Warning: fast.dmg不存在，使用本地临时文件"
        TMP_SRC="${SCRIPT_DIR}/tmp_auto_fill.cpp"
    fi
else
    echo "Info: fast_compile已挂载，使用内存盘编译"
    TMP_SRC="${MOUNT_POINT}/tmp_auto_fill.cpp"
fi

if [ ! -f "${SOURCE_FILE}" ];then
    echo "Error: Source file ${SOURCE_FILE} not found!"
    exit 1
fi

if [ ! -f "${FUNCTION_LIB}" ];then
    echo "Error: Function library.command 不存在！"
    exit 1
fi
chmod +x "${FUNCTION_LIB}"

cp "${SOURCE_FILE}" "${TMP_SRC}"
MAX_RETRY=5
RETRY=0

while [ $RETRY -lt $MAX_RETRY ];do
    COMPILE_ERR=$(g++ "${TMP_SRC}" -o "${MOUNT_POINT}/out_program" 2>&1)
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ];then
        echo "Compile success"
        echo "OUTPUT_EXE=${MOUNT_POINT}/out_program"
        exit 0
    fi

    if echo "$COMPILE_ERR" | grep -qE "file not found|was not declared in this scope"; then
        echo "Detect missing header / undeclared identifier"
        INCLUDE_LINE=$("${FUNCTION_LIB}" "header_auto" "$COMPILE_ERR")
        if [ -n "$INCLUDE_LINE" ]; then
            echo "Auto add: $INCLUDE_LINE"
            # 在文件顶部插入#include
            echo "$INCLUDE_LINE" | cat - "${TMP_SRC}" > "${MOUNT_POINT}/tmp.tmp" && mv "${MOUNT_POINT}/tmp.tmp" "${TMP_SRC}"
            RETRY=$((RETRY+1))
            continue
        else
            echo "Warning: No matched header to inject"
        fi
    fi

    MISS_FUNC=$(echo "$COMPILE_ERR" | grep -o 'undefined reference to `[^`]*' | sed 's/undefined reference to `//' | head -n1)
    if [ -n "$MISS_FUNC" ];then
        echo "Detect missing function: $MISS_FUNC"
        FUNC_SOURCE=$("${FUNCTION_LIB}" "func_auto" "$MISS_FUNC")
        if [ -z "$FUNC_SOURCE" ];then
            echo "Warning: Function library: cannot find [$MISS_FUNC] in any lib"
            echo "$COMPILE_ERR"
            exit 1
        fi
        echo "Auto append function $MISS_FUNC from library"
        echo "" >> "${TMP_SRC}"
        echo "$FUNC_SOURCE" >> "${TMP_SRC}"
        RETRY=$((RETRY+1))
        continue
    fi

    echo "$COMPILE_ERR"
    exit 1
done

echo "Warning: Reach max auto‑fill retry limit ($MAX_RETRY), compile failed"
exit 1
