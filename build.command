#!/bin/zsh
# build.command：构建 .app 应用包，依赖py2app
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
cd "${SCRIPT_DIR}"

echo "===== Build macOS Dev‑C++ App ====="

# 检查py2app
if ! python3 -c "import py2app" 2>/dev/null;then
    echo "[INSTALL] 安装 py2app"
    python3 -m pip install py2app
fi

# 生成setup.py
cat > setup.py << EOF
from setuptools import setup
setup(
    app=["main_gui.py"],
    options={"py2app":{
        "argv_emulation": True,
        "resources":[
            "build.command",
            "control.command",
            "privilege‑escalation.command",
            "quick search.command",
            "Quick compilation.command",
            "fast.dmg"
        ],
        "iconfile":""
    }},
    setup_requires=["py2app"]
)
EOF

# 清理旧构建产物
rm -rf build dist *.egg-info

# 开始打包
python3 setup.py py2app

echo ""
echo "[FINISH] App输出目录： ${SCRIPT_DIR}/dist/main_gui.app"
echo "注意：已经购买开发者证书，打开不会提示‘无法验证开发者’"
exit 0
