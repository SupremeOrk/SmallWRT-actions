#!/bin/bash
# scripts/lib.sh — ImmWRT 构建共享函数库
# 用法: source "$GITHUB_WORKSPACE/scripts/lib.sh"

# 解析 preset 脚本的 @preset 元数据
# 输出格式: <preset_name>|<type>|<description>
parse_preset_meta() {
  local script="$1"
  local name type desc
  name=$(sed -n 's/^# @preset: *//p' "$script" | head -1)
  type=$(sed -n 's/^# @type: *//p' "$script" | head -1)
  desc=$(sed -n 's/^# @description: *//p' "$script" | head -1)
  echo "${name:-$(basename "$script" .sh)}|${type:-build}|${desc:-无描述}"
}

# 列出所有可用的 build 预设
list_build_presets() {
  local dir="${1:-scripts/presets}"
  if [ -d "$dir" ]; then
    for script in "$dir"/*.sh; do
      [ -f "$script" ] || continue
      local meta
      meta=$(parse_preset_meta "$script")
      local type=$(echo "$meta" | cut -d'|' -f2)
      if [ "$type" = "build" ]; then
        echo "$script"
      fi
    done
  fi
}

# 列出所有可用的 uci-defaults 预设
list_uci_presets() {
  local dir="${1:-scripts/presets}"
  if [ -d "$dir" ]; then
    for script in "$dir"/*.sh; do
      [ -f "$script" ] || continue
      local meta
      meta=$(parse_preset_meta "$script")
      local type=$(echo "$meta" | cut -d'|' -f2)
      if [ "$type" = "uci-defaults" ]; then
        echo "$script"
      fi
    done
  fi
}

# 列出所有可用的配置文件 (configs/<prefix>-*.config)
list_configs() {
  local dir="${1:-configs}"
  local prefix="${2:-gl-mt3600be}"
  if [ -d "$dir" ]; then
    find "$dir" -maxdepth 1 -name "${prefix}-*.config" -type f | sort
  fi
}

# 从配置文件名提取 variant 名称 (e.g. "full" from "gl-mt3600be-full.config")
config_variant() {
  local config_file="$1"
  local prefix="${2:-gl-mt3600be}"
  basename "$config_file" .config | sed "s/^${prefix}-//"
}

# 记录日志 (带时间戳)
log_info()  { echo "[$(date '+%H:%M:%S')] INFO  $*"; }
log_warn()  { echo "[$(date '+%H:%M:%S')] WARN  $*"; }
log_error() { echo "[$(date '+%H:%M:%S')] ERROR $*"; }
