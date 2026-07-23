#!/bin/bash

# https://github.com/SupremeOrk/SmallWRT-actions
#
# Copyright (c) 2024-2026
#
# This is free software, licensed under the GNU GPLv3 License.
# See /LICENSE for more information.

# 用途：feeds update 之前执行的 DIY 脚本 (在 build.yml 中调用)
# 功能：克隆第三方软件包到源码树，供后续编译使用

# --- OpenClash (vernesong) ---
git clone -b master --single-branch --filter=blob:none https://github.com/vernesong/OpenClash p-temp/clash

# --- 文件管理插件 quickfile ---
git clone https://github.com/sbwml/luci-app-quickfile package/quickfile

# --- proton2025 主题 ---
git clone https://github.com/ChesterGoodiny/luci-theme-proton2025 package/luci-theme-proton2025

# --- RUN 安装工具 ---
git clone https://github.com/wukongdaily/luci-app-run package/luci-app-run

# --- 自定义 luci-theme-argon (jerrykuku, master) ---
# 替换 feeds 中的标准版本，提供完整 argon 体验 (含 luci-app-argon-config)
git clone --depth=1 --single-branch --branch master https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon

# --- 自定义 trv-portal (bedasrv, main) ---
git clone --depth=1 --single-branch --branch main https://github.com/bedasrv/trv-portal p-temp/trv-portal

# --- 自定义 amneziawg (bedasrv, master) ---
git clone --depth=1 --single-branch --branch master https://github.com/bedasrv/awg-openwrt p-temp/awg-openwrt

# --- openwrt-auto-apn (bedasrv, main) ---
git clone --depth=1 --single-branch --branch main https://github.com/bedasrv/openwrt-auto-apn p-temp/auto-apn

exit 0
