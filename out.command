#!/bin/zsh
# out.command 运行编译产物
# 参数：$1 = 可执行文件完整路径
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
PRIVILEGE_SCRIPT="${SCRIPT_DIR}/privilege.command"

EXE_PATH="$1"
if [ -z "$EXE_PATH" ]; then
    echo "Error: No executable file path provided."
    exit 1
fi
if [ ! -f "$EXE_PATH" ]; then
    echo "Error: Executable not found -> $EXE_PATH"
    exit 2
fi

echo "Info: ====================================="
echo "Info: Running program: $EXE_PATH"
echo "Info: ====================================="

# 确保可执行文件拥有执行权限，调用统一提权脚本
"${PRIVILEGE_SCRIPT}" chmod_file "${EXE_PATH}"
CHMOD_RET=$?
if [ ${CHMOD_RET} -ne 0 ];then
    echo "Warning: 赋予执行权限失败，尝试直接运行"
fi

# 执行程序
"$EXE_PATH"
EXIT_CODE=$?

echo "Info: ====================================="
echo "Info: Program finished. Exit code: $EXIT_CODE"
exit ${EXIT_CODE}
