#!/bin/bash
# @preset: snapshot-settings
# @description: 快照初始化设置 (argon 主题 / CST-8 时区 / 网络诊断 / 包转发，首次启动执行)
# @type: uci-defaults
# 用法: bash snapshot-settings.sh
# 将首次启动配置写入 files/etc/uci-defaults/98-snapshot-init.sh

set -e

FILES_DIR="${OPENWRT_DIR:-.}/files"
mkdir -p "$FILES_DIR/etc/uci-defaults"

cat > "$FILES_DIR/etc/uci-defaults/98-snapshot-init.sh" << 'UCI_EOF'
#!/bin/sh
# Snapshot init settings — runs on first boot

# Set default theme to luci-theme-argon
uci set luci.main.mediaurlbase='/luci-static/argon'
uci set luci.main.pollinterval='1'
uci commit luci

# timezone
uci set system.@system[0].timezone=CST-8
uci set system.@system[0].zonename=Asia/Shanghai
uci commit system

# log level
uci set system.@system[0].conloglevel='1'
uci set system.@system[0].cronloglevel='9'
uci commit system

# diagnostics
uci set luci.diag.dns='www.baidu.com'
uci set luci.diag.ping='www.baidu.com'
uci set luci.diag.route='www.baidu.com'
uci commit luci

# packet steering
uci -q get network.globals.packet_steering > /dev/null || {
    uci set network.globals='globals'
    uci set network.globals.packet_steering=1
    uci commit network
}

# disable coremark
sed -i '/coremark/d' /etc/crontabs/root
crontab /etc/crontabs/root

# Disable IPv6 prefix
sed -i 's/^[^#].*option ula/#&/' /etc/config/network

# Disable autostart by default for some packages
cd /etc/rc.d
rm -f S98udptools || true
rm -f S99nft-qos || true

# Try to execute init.sh (if exists)
if [ -f "/boot/init.sh" ]; then
  bash /boot/init.sh
fi

exit 0
UCI_EOF

chmod +x "$FILES_DIR/etc/uci-defaults/98-snapshot-init.sh"
echo "快照初始化设置已写入 files/etc/uci-defaults/98-snapshot-init.sh"
