#!/bin/zsh
# build_universal_app.command
# Mac-DevCPP Universal2 双架构合并脚本
# 合并 x86_64(Intel) + arm64(Apple Silicon)

# ========= 配置区，按需修改 =========
APP_NAME="Mac-DevCPP"
INPUT_INTEL="./${APP_NAME}"
INPUT_ARM="./${APP_NAME}"
OUTPUT_UNIVERSAL="./${APP_NAME}_Universal.app"
# ====================================

echo "===== Mac-DevCPP Universal2 打包工具 ====="
echo "Intel App: ${INPUT_INTEL}"
echo "Arm App: ${INPUT_ARM}"
echo "输出通用App: ${OUTPUT_UNIVERSAL}"
echo ""

# 检查输入文件是否存在
if [ ! -d "${INPUT_INTEL}" ]; then
    echo "Error：找不到Intel版本 ${INPUT_INTEL}"
    exit 1
fi
if [ ! -d "${INPUT_ARM}" ]; then
    echo "Error：找不到Arm版本 ${INPUT_ARM}"
    exit 1
fi

# 如果旧输出包存在，先删除
if [ -d "${OUTPUT_UNIVERSAL}" ]; then
    echo "Warning: 旧通用包存在，正在删除..."
    rm -rf "${OUTPUT_UNIVERSAL}"
fi

# 以Arm版App为基础复制整套App目录（资源、plist、icns、脚本全部复用Arm版）
echo "Step1: 复制Arm版本App作为基础框架..."
cp -R "${INPUT_ARM}" "${OUTPUT_UNIVERSAL}"

# 定义可执行文件路径
EXEC_PATH="Contents/MacOS/${APP_NAME}"
EXEC_INTEL="${INPUT_INTEL}/${EXEC_PATH}"
EXEC_ARM="${INPUT_ARM}/${EXEC_PATH}"
EXEC_UNI="${OUTPUT_UNIVERSAL}/${EXEC_PATH}"

echo "Step2: 用lipo合并两个架构的主程序..."
lipo -create "${EXEC_INTEL}" "${EXEC_ARM}" -output "${EXEC_UNI}"

# 赋予可执行权限
chmod +x "${EXEC_UNI}"

# 验证合并结果
echo ""
echo "Step3: 验证架构信息"
lipo -info "${EXEC_UNI}"

echo ""
echo "✅ 合并完成！输出：${OUTPUT_UNIVERSAL}"
echo "提示：还需要手动重新签名 + 公证（notarize）才能正常分发"
