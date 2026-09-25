#!/bin/zsh
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
cd "${SCRIPT_DIR}"

# 检查源码
if [ ! -f "./main_gui.py" ];then
    echo "Error：当前目录找不到 main_gui.py！"
    exit 1
fi

rm -rf build dist *.spec

# 安装pyinstaller（使用当前python环境）
python3 -m pip install pyinstaller

echo "开始打包"
python3 -m PyInstaller -w -n "Mac-DevCPP" \
--add-data "*.command:Resources" \
main_gui.py

echo "赋予脚本可执行权限 + 清除隔离属性"
find dist/Mac-DevCPP.app/Contents/Resources -name "*.command" -exec chmod +x {} \;
find dist/Mac-DevCPP.app/Contents/Resources -name "*.command" -exec xattr -cr {} \;

echo "✅ 打包完成！"
open dist
