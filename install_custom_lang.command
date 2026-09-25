#!/bin/zsh
# install_custom_lang.command
# download and install custom language component, require internet connection

SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
DOWNLOAD_TARGET_DIR="${SCRIPT_DIR}/custom_lang"

echo "========================================"
echo "Custom Language Installer"
echo "This operation requires an active internet connection."
echo "========================================"

# check internet connectivity
if ! curl -s --connect-timeout 4 https://github.com > /dev/null ; then
    echo "[ERROR] No internet connection detected."
    echo "Please check your network and try again."
    exit 1
fi

echo "[INFO] Internet connection OK."

mkdir -p "${DOWNLOAD_TARGET_DIR}"
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to create target directory ${DOWNLOAD_TARGET_DIR}"
    exit 1
fi

# example download url, replace with real resource later
REMOTE_URL="https://example.com/custom_lang_package.zip"
ZIP_SAVE_PATH="${DOWNLOAD_TARGET_DIR}/custom_lang_package.zip"

echo "[INFO] Start downloading custom language package ..."
curl -L --progress-bar "${REMOTE_URL}" -o "${ZIP_SAVE_PATH}"
if [ $? -ne 0 ]; then
    echo "[ERROR] Download failed."
    exit 1
fi

echo "[INFO] Download completed."

echo "[INFO] Unpacking archive ..."
unzip -q -o "${ZIP_SAVE_PATH}" -d "${DOWNLOAD_TARGET_DIR}"
if [ $? -ne 0 ]; then
    echo "[ERROR] Unzip failed."
    exit 1
fi

rm -f "${ZIP_SAVE_PATH}"
echo "[INFO] Cleanup temporary archive done."

echo "[SUCCESS] Custom language installed to:"
echo "  ${DOWNLOAD_TARGET_DIR}"
echo "Install finished."
exit 0
