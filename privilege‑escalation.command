#!/bin/zsh
# privilege.command 统一管理员提权脚本
# 任务: mount_dmg / detach_dmg / chmod_file / rm_file
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
DMG_FILE="${SCRIPT_DIR}/fast.dmg"
MOUNT_POINT="/Volumes/fast_compile"

# --------------------------
# 检测当前是否已经是root
# --------------------------
is_root(){
    [[ $EUID -eq 0 ]]
}

# --------------------------
# 提权函数：用AppleScript弹窗请求密码
# --------------------------
elevate(){
    local cmd="$1"
    osascript -e "do shell script \"${cmd}\" with administrator privileges"
}

TASK="$1"
TARGET_PATH="$2"

case "${TASK}" in
mount_dmg)
    echo "Info: Task=mount_dmg, prepare to mount fast.dmg"
    if [ -d "${MOUNT_POINT}" ];then
        echo "Warning: Mount point already exists, skip mount"
        exit 0
    fi
    CMD="mkdir -p '${MOUNT_POINT}'; hdiutil attach '${DMG_FILE}' -mountpoint '${MOUNT_POINT}' -nobrowse"
    RESULT=$(elevate "${CMD}" 2>&1)
    if [ $? -eq 0 ];then
        echo "Done: Privilege mount success -> ${MOUNT_POINT}"
    else
        echo "Error: Mount failed, message: ${RESULT}"
        exit 1
    fi
;;

detach_dmg)
    echo "Info: Task=detach_dmg, unmount fast_compile"
    if [ ! -d "${MOUNT_POINT}" ];then
        echo "Warning: Mount point not found, nothing to detach"
        exit 0
    fi
    CMD="hdiutil detach '${MOUNT_POINT}' -force"
    RESULT=$(elevate "${CMD}" 2>&1)
    if [ $? -eq 0 ];then
        echo "Done: Privilege detach success"
    else
        echo "Error: Detach failed, message: ${RESULT}"
        exit 1
    fi
;;

chmod_file)
    echo "Info: Task=chmod, path=${TARGET_PATH}"
    CMD="chmod +x '${TARGET_PATH}'"
    RESULT=$(elevate "${CMD}" 2>&1)
    if [ $? -eq 0 ];then
        echo "Done: chmod +x success ${TARGET_PATH}"
    else
        echo "Error: chmod failed ${RESULT}"
        exit 1
    fi
;;

rm_file)
    echo "Info: Task=rm protected file ${TARGET_PATH}"
    CMD="rm -f '${TARGET_PATH}'"
    RESULT=$(elevate "${CMD}" 2>&1)
    if [ $? -eq 0 ];then
        echo "Done: File removed ${TARGET_PATH}"
    else
        echo "Error: Remove failed ${RESULT}"
        exit 1
    fi
;;

*)
    echo "Error: Unknown task [${TASK}], available: mount_dmg,detach_dmg,chmod_file,rm_file"
    exit 1
;;
esac
exit 0
