#!/bin/bash
# @preset: smallwrt-branding
# @description: SmallWRT 品牌定制 — 固件版本号加入 Compiled by Ethan + 编译日期
# @type: build
# 用法: bash smallwrt-branding.sh
# 依赖环境变量: OPENWRT_DIR (工作流传入)

set -e

BUILD_DATE=$(date +%Y.%m.%d)
VERSION_CODE="Compiled by Ethan R${BUILD_DATE}"

cd "${OPENWRT_DIR:-.}"

# 写入 CONFIG_VERSION_CODE 到 .config
# OpenWrt 版本描述格式: {DIST} {RELEASE} {CODE}
# 最终效果: ImmortalWrt SNAPSHOT Compiled by Ethan R2026.07.23
if grep -q '^CONFIG_VERSION_CODE=' .config 2>/dev/null; then
  sed -i "s|^CONFIG_VERSION_CODE=.*|CONFIG_VERSION_CODE=\"${VERSION_CODE}\"|" .config
else
  echo "CONFIG_VERSION_CODE=\"${VERSION_CODE}\"" >> .config
fi

echo "SmallWRT 品牌信息已写入 .config"
echo "  版本代码: ${VERSION_CODE}"
echo "  最终显示: ImmortalWrt SNAPSHOT ${VERSION_CODE} / LuCI Master ..."
