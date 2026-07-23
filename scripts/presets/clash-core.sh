#!/bin/bash
# @preset: clash-core
# @description: 下载 OpenClash Meta 核心与 GeoIP 规则数据
# @type: build
# 用法: bash clash-core.sh
# 依赖环境变量: CLASH_ARCH (由 device.conf 设定), OPENWRT_DIR (工作流传入)

set -e

FILES_DIR="${OPENWRT_DIR:-.}/files"
mkdir -p "$FILES_DIR/etc/openclash/core"

CLASH_META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/dev/meta/clash-linux-${CLASH_ARCH:-arm64}.tar.gz"
GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
ASN_MMDB_URL="https://cdn.jsdelivr.net/gh/P3TERX/GeoLite.mmdb@download/GeoLite2-ASN.mmdb"
MODEL_BIN_URL="https://github.com/vernesong/mihomo/releases/download/LightGBM-Model/Model.bin"

wget -qO- "$CLASH_META_URL" | tar xOvz > "$FILES_DIR/etc/openclash/core/clash_meta"
wget -qO- "$GEOIP_URL" > "$FILES_DIR/etc/openclash/GeoIP.dat"
wget -qO- "$GEOSITE_URL" > "$FILES_DIR/etc/openclash/GeoSite.dat"
wget -qO- "$ASN_MMDB_URL" > "$FILES_DIR/etc/openclash/ASN.mmdb"
wget -qO- "$MODEL_BIN_URL" > "$FILES_DIR/etc/openclash/Model.bin"

chmod +x "$FILES_DIR/etc/openclash/core/clash"*

echo "Clash Meta 核心与规则数据预置完成 (架构: ${CLASH_ARCH:-arm64})"
