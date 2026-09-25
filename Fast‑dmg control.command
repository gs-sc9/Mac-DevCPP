#!/bin/zsh
# Fast‑dmg control.command
# 根据mac物理内存自动设置dmg镜像大小，生成/删除/重建 fast.dmg
# 卸载、挂载操作统一调用 privilege.command 提权，日志规范适配PyQt
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
PRIVILEGE_SCRIPT="${SCRIPT_DIR}/privilege.command"
DMG_FILE="${SCRIPT_DIR}/fast.dmg"
MOUNT_POINT="/Volumes/fast_compile"

# 获取总内存 MB
TOTAL_RAM_MB=$(( $(sysctl -n hw.memsize) / 1024 / 1024 ))
echo "==== fast.dmg 镜像控制器 ===="
echo "Info: 本机总内存：${TOTAL_RAM_MB} MB"

CALC_SIZE=$(( TOTAL_RAM_MB / 4 ))
if [ $CALC_SIZE -lt 256 ];then
    CALC_SIZE=256
fi
if [ $CALC_SIZE -gt 4096 ];then
    CALC_SIZE=4096
fi
echo "Info: 自动分配镜像大小：${CALC_SIZE} MB"
echo ""

# 如果镜像已挂载，调用提权脚本卸载
if [ -d "${MOUNT_POINT}" ];then
    echo "Info: 检测到镜像已挂载，调用提权脚本执行卸载..."
    "${PRIVILEGE_SCRIPT}" detach_dmg
    DETACH_RET=$?
    if [ ${DETACH_RET} -ne 0 ];then
        echo "Warning: 卸载旧镜像失败，继续尝试删除dmg文件"
    fi
fi

# 删除旧dmg文件，调用提权脚本处理受保护文件
if [ -f "${DMG_FILE}" ];then
    echo "Info: 删除旧 fast.dmg"
    "${PRIVILEGE_SCRIPT}" rm_file "${DMG_FILE}"
    RM_RET=$?
    if [ ${RM_RET} -ne 0 ];then
        echo "Warning: 删除旧镜像文件失败，继续尝试创建"
    fi
fi

echo "Info: 正在创建新 fast.dmg 大小 ${CALC_SIZE}M ..."
hdiutil create -size "${CALC_SIZE}m" -fs APFS -type SPARSE "${DMG_FILE%.dmg}"
# sparse转换为dmg
hdiutil convert "${DMG_FILE%.dmg}.sparseimage" -format UDRO -o "${DMG_FILE}"
rm -f "${DMG_FILE%.dmg}.sparseimage"

if [ -f "${DMG_FILE}" ];then
    echo "Done: fast.dmg 创建完成！路径：${DMG_FILE}"
    echo "Info: 调用提权脚本自动挂载镜像到 ${MOUNT_POINT}"
    "${PRIVILEGE_SCRIPT}" mount_dmg
    MOUNT_RET=$?
    if [ ${MOUNT_RET} -eq 0 ] && [ -d "${MOUNT_POINT}" ];then
        echo "Done: 镜像挂载成功！挂载点:${MOUNT_POINT}"
        echo "Info: 打开镜像内部文件夹"
        open "${MOUNT_POINT}"
    else
        echo "Error: dmg挂载失败，请手动尝试挂载"
        exit 2
    fi
else
    echo "Error: fast.dmg 创建失败"
    exit 1
fi
exit 0
