#!/bin/zsh
# control.command: App后端控制入口
# 负责: 挂载fast.dmg(调用privilege.command提权)、调用编译脚本、环境变量设置
# 日志统一替换为 Warning:/Error:/Done: 适配PyQt前端日志
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
FAST_DMG="${SCRIPT_DIR}/fast.dmg"
PRIVILEGE_SCRIPT="${SCRIPT_DIR}/privilege.command"
echo "===== Dev-C++ macOS control daemon ====="
echo "Info: 工作目录: ${SCRIPT_DIR}"

if [ ! -f "${FAST_DMG}" ];then
    echo "Warning: fast.dmg 不存在, 极速编译模式不可用"
fi
MOUNT_POINT="/Volumes/fast_compile"

if [ ! -d "${MOUNT_POINT}" ];then
    if [ -f "${FAST_DMG}" ];then
        echo "Info: 检测镜像未挂载，调用提权脚本挂载fast.dmg"
        "${PRIVILEGE_SCRIPT}" mount_dmg
        MOUNT_RET=$?
        if [ ${MOUNT_RET} -eq 0 ];then
            echo "Done: fast.dmg 已挂载到 ${MOUNT_POINT}"
        else
            echo "Warning: fast.dmg挂载失败，降级使用本地文件编译"
        fi
    fi
fi

SUB_CMD="$1"
case "${SUB_CMD}" in
compile)
    echo "Info: 执行快速编译"
    "${SCRIPT_DIR}/Quick compilation.command" "$2"
    ;;
compile_run)
    echo "Info: 执行编译+运行"
    COMPILE_OUT=$("${SCRIPT_DIR}/Quick compilation.command" "$2")
    COMPILE_RET=$?
    echo "${COMPILE_OUT}"
    if [ ${COMPILE_RET} -eq 0 ]; then
        EXE_FILE=$(echo "${COMPILE_OUT}" | grep 'OUTPUT_EXE=' | sed 's/OUTPUT_EXE=//')
        echo "Done: 编译成功，准备调用out.command运行程序"
        "${SCRIPT_DIR}/out.command" "${EXE_FILE}"
    else
        echo "Error: 编译失败，跳过运行"
    fi
;;
run_only)
    echo "Info: 仅运行程序"
    SRC_FILE="$2"
    EXE_FILE="${SRC_FILE%.cpp}"
    EXE_FILE="${EXE_FILE%.c}"
    "${SCRIPT_DIR}/out.command" "${EXE_FILE}"
    ;;
search)
    echo "Info: 执行快速搜索"
    "${SCRIPT_DIR}/quick search.command" "$2"
    ;;
escalate)
    shift
    "${PRIVILEGE_SCRIPT}" "$@"
    ;;
make_dmg)
    echo "Info: 生成fast.dmg镜像"
    "${SCRIPT_DIR}/Fast‑dmg control.command"
    ;;
clean)
    echo "Info: 执行缓存清理"
    "${SCRIPT_DIR}/clean_cache.command"
    ;;
install_deps)
    echo "Info: 执行依赖安装"
    "${SCRIPT_DIR}/install_deps.command"
    ;;
airdrop)
    shift
    "${SCRIPT_DIR}/airdrop_share.command" "$*"
    ;;
format)
    echo "Info: 执行代码格式化"
    "${SCRIPT_DIR}/auto_format.command" "$2"
    ;;
native_run)
    shift
    "${SCRIPT_DIR}/run_native.command" "$@"
    ;;
encoding_conv)
    echo "Info: 自动编码转换"
    "${SCRIPT_DIR}/encoding_convert.command" "$2"
    ;;
*)
    echo "Error: 未知子命令"
    echo "Info: 可用子命令：compile / compile_run / run_only / search / escalate / make_dmg / clean / install_deps / airdrop / format / native_run / encoding_conv"
    ;;
esac
exit 0

