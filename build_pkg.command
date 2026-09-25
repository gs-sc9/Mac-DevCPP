#!/bin/zsh
# build_pkg.command：把Mac‑DevCPP.app打包成pkg安装包

SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
cd "${SCRIPT_DIR}"

APP_PATH="${SCRIPT_DIR}/dist/Mac‑DevCPP.app"
OUT_PKG="${SCRIPT_DIR}/dist/Mac‑DevCPP‑Test.pkg"

if [ ! -d "${APP_PATH}" ]; then
    echo "❌找不到 Mac‑DevCPP.app，请先完成打包，dist目录必须存在app"
    exit 1
fi

rm -f "${OUT_PKG}"

echo "开始构建pkg安装包..."
pkgbuild \
--component "${APP_PATH}" \
--install-location /Applications \
--identifier com.macdevcpp.app \
--version 1.0.0 \
"${OUT_PKG}"

if [ -f "${OUT_PKG}" ]; then
    echo ""
    echo "✅pkg生成成功！"
    echo "输出文件：${OUT_PKG}"
    echo ""
    echo "⚠️警告：此pkg未签名，其他用户安装会被macOS安全拦截！"
    echo ""
    open dist
else
    echo "❌pkg构建失败！"
    exit 1
fi
