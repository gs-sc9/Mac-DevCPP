#!/bin/zsh
# build_universal_app.command
# 适配macOS28：Intel机仅编译x86_64；Apple硅可构建universal2双架构
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
MAIN_PY="${SCRIPT_DIR}/main_gui.py"
APP_NAME="Mac-DevCPP"
DIST_FOLDER="${SCRIPT_DIR}/dist"
BUILD_FOLDER="${SCRIPT_DIR}/build"
OUTPUT_UNIVERSAL_APP="${DIST_FOLDER}/${APP_NAME}.app"

# 清理旧打包产物
echo "Info: 清理旧打包目录..."
rm -rf "${DIST_FOLDER}" "${BUILD_FOLDER}"

# 校验主程序文件
if [ ! -f "${MAIN_PY}" ];then
    echo "Error: 找不到main_gui.py，请确认脚本放在源码目录！"
    exit 1
fi

# 获取当前系统版本与CPU架构
OS_VER=$(sw_vers -productVersion | cut -d. -f1)
CURR_ARCH=$(uname -m)
echo "Info: 当前系统主版本: ${OS_VER}，CPU架构: ${CURR_ARCH}"

# 检查python3是否存在
if ! command -v python3 &> /dev/null
then
    echo "Error: 未检测到 python3，请先安装Python3！"
    exit 1
fi
# 检查pyinstaller是否安装
if ! python3 -m PyInstaller --version &> /dev/null
then
    echo "Error: PyInstaller未安装，执行 pip3 install pyinstaller"
    exit 1
fi

BUILD_INTEL=1
BUILD_ARM=1

# Intel x86_64机器，无法编译arm64
if [[ "${CURR_ARCH}" == "x86_64" ]];then
    echo "Warning: 当前是Intel(x86_64) Mac，不能编译arm64版本，仅构建x86_64"
    BUILD_ARM=0
fi

# macOS >=28 关闭Intel切片构建
if [[ ${OS_VER} -ge 28 ]];then
    echo "Warning: 当前系统 >= macOS28，不再支持通用Rosetta，跳过x86_64构建，仅编译arm64原生版本"
    BUILD_INTEL=0
fi

# 存放编译好的App路径
ARM_APP=""
INTEL_APP=""

# --------------------------
# 1. 编译 arm64 (Apple Silicon)版本（仅Apple硅机器才执行）
# --------------------------
if [[ ${BUILD_ARM} -eq 1 ]];then
    echo "Info: 正在构建 arm64 (Apple Silicon) 版本..."
    arch -arm64 python3 -m PyInstaller \
        --noconsole \
        --windowed \
        --name "${APP_NAME}-arm64" \
        --target-arch arm64 \
        --add-data "${SCRIPT_DIR}/*.command:Resources" \
        "${MAIN_PY}"
    ARM_APP="${DIST_FOLDER}/${APP_NAME}-arm64.app"
    if [ ! -d "${ARM_APP}" ];then
        echo "Error: arm64打包失败"
        exit 1
    fi
fi

# --------------------------
# 2. 编译 x86_64 (Intel)版本
# --------------------------
if [[ ${BUILD_INTEL} -eq 1 ]];then
    echo "Info: 正在构建 x86_64 (Intel) 版本..."
    # Apple硅环境执行x86_64时设置环境变量抑制Rosetta弹窗
    if [[ "${CURR_ARCH}" == "arm64" ]]; then
        export ARCHPREFERENCE=Rosetta
    fi
    arch -x86_64 python3 -m PyInstaller \
        --noconsole \
        --windowed \
        --name "${APP_NAME}-x86_64" \
        --target-arch x86_64 \
        --add-data "${SCRIPT_DIR}/*.command:Resources" \
        "${MAIN_PY}"
    INTEL_APP="${DIST_FOLDER}/${APP_NAME}-x86_64.app"
    if [ ! -d "${INTEL_APP}" ];then
        echo "Warning: x86_64打包失败"
        BUILD_INTEL=0
    fi
fi

# --------------------------
# 3. 合并架构 / 复制单架构包
# --------------------------
if [[ ${BUILD_ARM} -eq 1 && ${BUILD_INTEL} -eq 1 ]];then
    # 双架构全部编译成功，lipo合并Universal2
    cp -R "${ARM_APP}" "${OUTPUT_UNIVERSAL_APP}"
    ARM_BIN="${ARM_APP}/Contents/MacOS/${APP_NAME}-arm64"
    INTEL_BIN="${INTEL_APP}/Contents/MacOS/${APP_NAME}-x86_64"
    UNI_BIN="${OUTPUT_UNIVERSAL_APP}/Contents/MacOS/${APP_NAME}"
    echo "Info: lipo合并arm64+x86_64通用二进制..."
    lipo -create "${ARM_BIN}" "${INTEL_BIN}" -output "${UNI_BIN}"
    chmod +x "${UNI_BIN}"
elif [[ ${BUILD_ARM} -eq 1 ]];then
    # 只有arm64
    cp -R "${ARM_APP}" "${OUTPUT_UNIVERSAL_APP}"
    UNI_BIN="${OUTPUT_UNIVERSAL_APP}/Contents/MacOS/${APP_NAME}-arm64"
elif [[ ${BUILD_INTEL} -eq 1 ]];then
    # 只有x86_64（你当前Intel电脑就走这个分支）
    cp -R "${INTEL_APP}" "${OUTPUT_UNIVERSAL_APP}"
    UNI_BIN="${OUTPUT_UNIVERSAL_APP}/Contents/MacOS/${APP_NAME}-x86_64"
else
    echo "Error: 没有任何架构可以打包，退出"
    exit 1
fi

# --------------------------
# 4. 统一给所有command脚本赋予执行权限
# --------------------------
echo "Info: 处理command脚本权限..."
SCRIPT_TARGET="${OUTPUT_UNIVERSAL_APP}/Contents/Resources"
find "${SCRIPT_TARGET}" -name "*.command" -exec chmod +x {} \;

# --------------------------
# 5. 写入Info.plist，注册cpp文件关联
# --------------------------
PLIST_PATH="${OUTPUT_UNIVERSAL_APP}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes array" "${PLIST_PATH}"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0 dict" "${PLIST_PATH}"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeName string C++ Source File" "${PLIST_PATH}"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions array" "${PLIST_PATH}"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions:0 string cpp" "${PLIST_PATH}"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeRole string Editor" "${PLIST_PATH}"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:LSHandlerRank string Owner" "${PLIST_PATH}"

# --------------------------
# 6. 验证架构
# --------------------------
echo ""
echo "==== 架构验证 ===="
lipo -info "${UNI_BIN}"

echo ""
echo "Done: App打包完成！"
if [[ ${CURR_ARCH} == "x86_64" ]];then
    echo "Info: Intel机器，产物仅x86_64版本，只能在Intel Mac上运行"
else
    if [[ ${OS_VER} -ge 28 ]];then
        echo "Info: 当前为macOS28，产物仅arm64原生版本，只支持Apple Silicon Mac"
    else
        echo "Info: 输出通用双架构App，支持Intel+Apple Silicon（在Apple硅macOS<=27环境打包）"
    fi
fi
echo "Info: 输出路径：${OUTPUT_UNIVERSAL_APP}"
echo "Info: 下一步可执行 register_cpp_assoc.command 注册.cpp文件关联"
exit 0
