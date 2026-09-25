#!/bin/zsh
# install_deps.command 一键安装依赖：Homebrew、mingw‑w64编译器
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)

echo "==== Dev‑C++ macOS 依赖一键安装 ===="

# 检查是否安装Homebrew
if ! command -v brew &> /dev/null
then
    echo "未检测到Homebrew，开始安装Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✅已存在Homebrew，执行更新"
    brew update
fi

echo ""
echo "安装 mingw‑w64 (Windows交叉编译器)"
brew install mingw‑w64

echo ""
echo "检查Python3"
if ! command -v python3 &> /dev/null
then
    echo "⚠️系统未找到python3，请确认系统环境"
else
    echo "✅python3 可用"
    echo "安装PyQt6 py2app"
    python3 -m pip install --user PyQt6 py2app
fi

echo ""
echo "====依赖安装完成===="
echo "下一步：运行 ./Fast‑dmg control.command 生成fast.dmg编译镜像"
exit 0
