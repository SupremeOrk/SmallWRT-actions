#!/bin/bash

# https://github.com/SupremeOrk/SmallWRT-actions
#
# Copyright (c) 2024-2026
#
# This is free software, licensed under the GNU GPLv3 License.
# See /LICENSE for more information.

# 用途：feeds update 之后、feeds install 之前执行的 DIY 脚本 (在 build.yml 中调用)
# 功能：用自定义克隆的版本替换 feeds 中自带的包

set -e

# --- OpenClash: 替换 feeds 旧版本 ---
rm -rf feeds/luci/applications/luci-app-openclash
mv p-temp/clash/luci-app-openclash feeds/luci/applications/luci-app-openclash

# --- luci-theme-argon: 替换为 jerrykuku 版本 ---
rm -rf feeds/luci/themes/luci-theme-argon 2>/dev/null || true
if [ -d package/luci-theme-argon ]; then
  cp -r package/luci-theme-argon feeds/luci/themes/luci-theme-argon
fi

# --- trv-portal: 部署自定义包 (Rust 二进制由上游 CI 预编译) ---
if [ -d p-temp/trv-portal/openwrt/trv-portal ]; then
  mkdir -p package/trv-portal
  cp -r p-temp/trv-portal/openwrt/trv-portal/* package/trv-portal/
fi
if [ -d p-temp/trv-portal/openwrt/luci-app-trv-portal ]; then
  mkdir -p package/luci-app-trv-portal
  cp -r p-temp/trv-portal/openwrt/luci-app-trv-portal/* package/luci-app-trv-portal/
fi

# --- amneziawg: 部署自定义包 ---
if [ -d p-temp/awg-openwrt/kmod-amneziawg ]; then
  mkdir -p package/kmod-amneziawg
  cp -r p-temp/awg-openwrt/kmod-amneziawg/* package/kmod-amneziawg/
fi
if [ -d p-temp/awg-openwrt/amneziawg-tools ]; then
  mkdir -p package/amneziawg-tools
  cp -r p-temp/awg-openwrt/amneziawg-tools/* package/amneziawg-tools/
fi
if [ -d p-temp/awg-openwrt/luci-proto-amneziawg ]; then
  mkdir -p package/luci-proto-amneziawg
  cp -r p-temp/awg-openwrt/luci-proto-amneziawg/* package/luci-proto-amneziawg/
fi

# --- auto-apn: 部署到文件覆盖层 (首次启动自动运行) ---
if [ -d p-temp/auto-apn ]; then
  mkdir -p files/etc/init.d files/etc/hotplug.d/iface
  cp p-temp/auto-apn/mcc-mnc-apn.txt files/etc/
  cp p-temp/auto-apn/auto-apn-init.sh files/etc/init.d/auto-apn
  cp p-temp/auto-apn/99-auto-apn-hotplug.sh files/etc/hotplug.d/iface/99-auto-apn
  chmod +x files/etc/init.d/auto-apn files/etc/hotplug.d/iface/99-auto-apn
  echo "auto-apn: 已部署到 files/ (首次启动自动配置 APN)"
fi

# --- 清理临时目录 ---
rm -rf p-temp

exit 0
