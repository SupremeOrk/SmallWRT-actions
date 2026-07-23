# ImmWRT — ImmortalWrt 自动编译

利用 GitHub Actions 自动编译 [ImmortalWrt](https://github.com/chasey-dev/immortalwrt-mt798x-rebase) 固件。

> 目标设备：GL-MT3600BE (Beryl 7) / MT7987 (filogic) / 25.12-dev-wifi7

## 快速开始

1. Fork 本仓库
2. 修改 `device.conf` 适配你的设备
3. 放入 `.config` 文件到 `configs/`
4. 触发 Actions → "编译 ImmortalWrt" → Run workflow

## 目录结构

```text
ImmWRT/
├── .github/workflows/
│   ├── compile.yml                  #   可复用编译工作流 (workflow_call)
│   ├── build-cloud.yml              #   Cloud Runner 调用方 (定时 + 手动 + API)
│   ├── build-selfhosted.yml         #   Self-Hosted Runner 调用方 (手动)
│   └── clean-configs.yml            #   旧配置清理
├── device.conf                      # ★ 设备元数据 (唯一数据源)
├── configs/                         # 编译配置文件
│   ├── gl-mt3600be-full.config      #   完整配置 (make defconfig 产物)
│   └── gl-mt3600be-seed.config      #   种子配置 (仅顶层选项)
├── source-url.txt                   # 源码仓库 URL
├── source-track.txt                 # 远端提交跟踪记录
├── banner.txt                       # SSH 登录横幅
├── scripts/
│   ├── diy/                         # 编译 DIY 脚本
│   │   ├── 01-clone-plugins.sh      #   feeds update 前执行
│   │   └── 02-replace-openclash.sh  #   feeds update 后执行
│   ├── presets/                     # ★ 预设脚本 (放入即自动识别)
│   │   ├── clash-core.sh            #   下载 Clash Meta 核心 + GeoIP
│   │   ├── terminal-tools.sh        #   安装 oh-my-zsh 终端工具
│   │   ├── snapshot-settings.sh     #   快照初始化设置 (uci-defaults)
│   │   └── smallwrt-branding.sh     #   SmallWRT 品牌定制 (版本号)
│   └── lib.sh                       # 共享 shell 函数库
├── files/                           # ★ OpenWrt 标准文件覆盖层
│   ├── etc/uci-defaults/
│   │   └── 99-custom.sh             #   首次启动: LAN IP / SSH / mirrors
│   ├── root/
│   │   └── .zshrc                   #   zsh 配置
│   └── usr/lib/lua/luci/view/themes/argon/
│       └── footer.htm               #   LuCI 页脚 (SmallWRT 品牌)
├── README.md
└── LICENSE
```

## 架构设计

### 数据驱动，非硬编码

所有设备参数集中在 [device.conf](device.conf) 中，工作流通过 `source device.conf` 读取：

```bash
DEVICE_NAME="glinet_gl-mt3600be"
DEVICE_TITLE="GL-MT3600BE (Beryl 7)"
CHIP_NAME="mt7987"
CLASH_ARCH="arm64"
SOURCE_REPO="https://github.com/chasey-dev/immortalwrt-mt798x-rebase"
SOURCE_BRANCH="25.12-dev-wifi7"
CONFIG_PREFIX="gl-mt3600be"
```

### 配置自动发现

配置文件按 `<prefix>-<variant>.config` 命名放入 `configs/`。添加新变体只需放入文件，然后在 workflow_dispatch 输入中添加选项名。

### 预设脚本自动发现

每个 `scripts/presets/*.sh` 头部包含自描述元数据：

```bash
# @preset: clash-core
# @description: 下载 OpenClash Meta 核心与 GeoIP 规则数据
# @type: build          # build = 编译时执行; uci-defaults = 写入首次启动脚本
```

新增预设：放入脚本 → 在 workflow_dispatch 添加布尔输入 → 在编译步骤的 preset 映射中添加 case 分支。

### 编译流程

1. **prepare** — 加载 `device.conf`，检测源码更新，解析配置选择
2. **compile** — 拉取源码 → DIY 脚本 → feeds 更新 → 应用配置 → 执行预设 → 编译 → 打包发布

## workflow_dispatch 参数

Cloud 和 Self-Hosted 工作流共享相同的输入参数：

| 参数 | 类型 | 默认 | 说明 |
| ---- | ---- | ---- | ---- |
| `config_variant` | choice | full | 配置文件变体：`full` (完整) 或 `seed` (种子) |
| `preset_clash` | boolean | true | 预置 OpenClash Meta 核心 + GeoIP |
| `preset_zsh` | boolean | true | 预置 oh-my-zsh 终端工具 |
| `preset_snapshot` | boolean | true | 预置快照初始化设置 |
| `preset_branding` | boolean | true | SmallWRT 品牌定制 (版本号 / LuCI Footer) |

定时触发（仅 Cloud）默认使用 `full` 配置 + 全部预设开启。

## 扩展指南

### 添加新配置变体

1. 放入 `configs/<prefix>-<variant>.config`
2. 在 `build.yml` 的 `workflow_dispatch.inputs.config_variant.options` 中添加选项

### 添加新预设

1. 创建 `scripts/presets/<name>.sh`，含 `@preset` 元数据头
2. 在 `build.yml` 的 `workflow_dispatch.inputs` 中添加布尔输入
3. 在 `build.yml` 的 "执行构建预设" step 的 case 语句中添加映射

### 适配新设备

1. 修改 `device.conf` 中的设备参数
2. 替换 `configs/` 中的配置文件
3. 修改 `files/etc/uci-defaults/99-custom.sh` 中的 LAN IP
4. 更新 `banner.txt`

## 品牌定制 (SmallWRT)

固件使用 SmallWRT 品牌，由 `smallwrt-branding.sh` 预设控制：

- **固件版本**：`ImmortalWrt SNAPSHOT Compiled by Ethan R{date}`（{date} = 编译日期，如 `R2026.07.23`）
- **LuCI 页脚**：显示 `SmallWRT | Compiled by Ethan | {version}`（通过 `files/.../footer.htm` 覆盖 argon 默认页脚）
- **SSH Banner**：SmallWRT ASCII 艺术字横幅（`banner.txt`）
- **描述格式**：向 `.config` 写入 `CONFIG_VERSION_CODE="Compiled by Ethan R{date}"`，`make` 时自动注入 `/etc/openwrt_release`

可通过 workflow_dispatch 的 `preset_branding` 选项关闭版本号定制。

## 固件默认信息

- **管理地址**：`192.168.5.1/24`
- **账号/密码**：`root` / 无密码
- **SSH**：openssh-server 已启用，dropbear 已禁用
- **LuCI**：`http://192.168.5.1`，默认主题 argon
- **品牌**：SmallWRT（banner + footer），版本号含 `Compiled by Ethan R{date}`
- **首次启动自动执行**：
  - `99-custom.sh`：LAN IP 设置、SSH 切换、mirrors.sh 生成
  - `98-snapshot-init.sh`（可选）：argon 主题、CST-8 时区、网络诊断、包转发

## Runner 双模式

项目支持两种编译执行环境，通过不同的 workflow 入口触发：

| 模式 | Workflow | Runner | 产物 | 触发 |
| ---- | -------- | ------ | ---- | ---- |
| **Cloud** | `build-cloud.yml` | GitHub `ubuntu-24.04` | Artifact + Release | 定时 + 手动 + API |
| **Self-Hosted** | `build-selfhosted.yml` | 用户自托管 `self-hosted` | 本地 `/srv/workspace/.smallwrt-actions/artifacts/` | 手动 |

### Cloud (`build-cloud.yml`)
- 每次重新安装依赖，全新编译
- 自动上传 Artifact 并创建 Release
- 360 分钟超时

### Self-Hosted (`build-selfhosted.yml`)
- 依赖预装，跳过 apt-get
- 源码持久化到 `/srv/workspace/.smallwrt-actions/openwrt/`（增量拉取）
- 产物保存到 `/srv/workspace/.smallwrt-actions/artifacts/<device>/<variant>/<date>/`
- 1440 分钟（24h）超时，不上传 Release

## 触发方式

| 触发 | build-cloud.yml | build-selfhosted.yml |
| ---- | --------------- | -------------------- |
| 定时 | 每周三、六 03:00 (北京时间) | ❌ |
| 手动 | Actions → Cloud Build → Run workflow | Actions → Self-Hosted Build → Run workflow |
| API | `repository_dispatch` | ❌ |

## 许可证

[GPL-3.0](LICENSE)
