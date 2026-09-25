#!/bin/zsh
# clean_cache.command 一键清理编译缓存、卸载fast.dmg镜像
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
MOUNT_POINT="/Volumes/fast_compile"

echo "===== 清理Dev‑C++ macOS缓存 ====="

# 卸载fast.dmg镜像
if [ -d "${MOUNT_POINT}" ]; then
    echo "正在卸载 fast_compile 镜像..."
    hdiutil detach "${MOUNT_POINT}"
    if [ $? -eq 0 ]; then
        echo "✅镜像卸载成功"
    else
        echo "⚠️镜像卸载失败，可以手动在访达推出"
    fi
fi

# 删除旧的sparse临时文件
rm -f "${SCRIPT_DIR}"/*.sparseimage
rm -f "${SCRIPT_DIR}"/*.sparsebundle

# 清理py2app打包缓存
rm -rf "${SCRIPT_DIR}/build"
rm -rf "${SCRIPT_DIR}/dist"
rm -rf "${SCRIPT_DIR}"/*.egg‑info

echo ""
echo "✅缓存清理完成"
echo "提示：fast.dmg镜像文件不会删除，如果需要重建，请运行 Fast‑dmg control.command"
exit 0
