#!/bin/bash
# @preset: terminal-tools
# @description: 预装 oh-my-zsh 及常用插件 (autosuggestions/syntax-highlighting/completions)
# @type: build
# 用法: bash terminal-tools.sh
# 依赖环境变量: GITHUB_WORKSPACE (GitHub Actions 默认), OPENWRT_DIR (工作流传入)

set -e

FILES_DIR="${OPENWRT_DIR:-.}/files"
mkdir -p "$FILES_DIR/root"
pushd "$FILES_DIR/root"

# Clone oh-my-zsh
git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh ./.oh-my-zsh

# Install extra plugins
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ./.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ./.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-completions ./.oh-my-zsh/custom/plugins/zsh-completions

# Copy .zshrc from static files
if [ -f "$GITHUB_WORKSPACE/files/root/.zshrc" ]; then
  cp "$GITHUB_WORKSPACE/files/root/.zshrc" .
else
  echo "警告: .zshrc 未找到，跳过复制"
fi

popd

# Preload oh-my-zsh completion cache after boot so SSH logins stay fast
mkdir -p "$FILES_DIR/etc/init.d" "$FILES_DIR/etc/rc.d"
cat > "$FILES_DIR/etc/init.d/zsh-preload" <<'EOF'
#!/bin/sh /etc/rc.common

START=99

start() {
	(
		sleep 20
		[ -x /usr/bin/zsh ] || exit 0
		[ -r /root/.zshrc ] || exit 0
		HOME=/root USER=root SHELL=/usr/bin/zsh /usr/bin/zsh -i -c exit >/tmp/zsh-preload.log 2>&1
	) &
}
EOF
chmod 755 "$FILES_DIR/etc/init.d/zsh-preload"
ln -sf ../init.d/zsh-preload "$FILES_DIR/etc/rc.d/S99zsh-preload"

echo "oh-my-zsh 终端工具预置完成"
