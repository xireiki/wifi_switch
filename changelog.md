## WLAN Switching 更新日志

### v1.2
  - 支持兼容模式（其他模块）

### v1.1
  - 修复检测不到神秘的 Bug
  - 修复未进行 toast 配置的 Bug

### v1.0-fix
  - 修复 case 笔误

### v1.0
1. 高级功能需要安装后打开 `/data/adb/modules/wifi_switch/config.sh` 文件进行配置，配置文件实时生效

2. 默认不进行配置是 WiFi 下关闭神秘模块的代理

3. 配置环境可跳过，目前使用 toast 的地方较少，toast 用于在配置出错时通知用户

4. 一共有 3 个模式（默认第一个，也就是不配置）: `switch`、`selector` 和 `mode`
  - switch: 如 2 的描述
  - selector: WiFi 下切换“国内出口”选择的出站
  - mode: WiFi 下切换 clash_mode

5. 可配置不同 WiFi 下切换的出站或者 clash_mode
