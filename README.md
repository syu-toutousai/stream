# stream

本机终端播放快捷菜单：一键选择主播或电台，基于 [streamlink](https://streamlink.github.io/) + [mpv](https://mpv.io/) 播放。

## 网页版（异构实现）

同一份菜单的 GitHub Pages 网页版：<https://syu-toutousai.github.io/stream/>（源码即本仓库 `index.html`）

- 点击菜单（或按 `1–6`、深链 `#suk` / `#radio` 等）会弹出一个**无地址栏的独立播放窗口**，与终端版「选台即开 mpv 窗口」对应；
- 虎牙 / 抖音 / 电台（radio5.cn 官方播放器）一律弹窗播放；电台窗口内需点一次它自带的播放键；
- 同名窗口自动复用；弹窗被拦截时页面状态栏会给出直达链接；从主页 <https://syu-toutousai.github.io/> 也可进入。

## 菜单内容

| 选项 | 名称 | 类型 | 实现 |
| --- | --- | --- | --- |
| 1 | 不求人 | 抖音直播 | `streamlink` → `mpv` |
| 2 | Suk | 虎牙直播 | `streamlink` → `mpv` |
| 3 | 雨果 | 虎牙直播 | `streamlink` → `mpv` |
| 4 | 潮州交通音乐广播 FM91.4 | 电台 | 从 radio5.cn 取流 → `mpv` |

## 文件说明

- `stream`：选择菜单入口，`exec` 到对应播放脚本。
- `index.html`：GitHub Pages 网页版播放台（终端菜单的异构实现，见上）。
- `huya.sh`：虎牙 / 抖音直播稳定播放（断线自动重连；`mpv` 按 `q` 退出或 `Ctrl+C` 结束不重连）。
- `cz_radio.sh`：潮州交通音乐广播 FM91.4，流地址含时效 token，脚本会自动重新取流续播。

## 依赖

必需：

- `bash`
- `mpv`：播放器
- `streamlink`：虎牙 / 抖音拉流
- `curl` + `python3`：`cz_radio.sh` 获取并解析流地址
- `grep`：脚本内部提取页面 nonce（一般系统自带）

可选：

- `systemd`（用户级）：`cz_radio.sh` 从菜单前台启动时会顺带停掉后台的 `cz-radio.service`，避免两路声音重叠；后台常驻用法见下。
- `PulseAudio` / `PipeWire`：用于调节音量（`pactl` / `wpctl`）。

网络条件：

- 直播：可访问 `huya.com`、`live.douyin.com`
- 电台：可访问 `radio5.cn`、`ytcastmp3.radio.cn`

以 Arch Linux 为例安装：

```bash
sudo pacman -S mpv streamlink curl python
```

其他发行版用对应的包管理器安装同名软件即可。

## 安装部署

```bash
mkdir -p ~/bin
cp stream huya.sh cz_radio.sh ~/bin/
chmod +x ~/bin/stream ~/bin/huya.sh ~/bin/cz_radio.sh

# 确保 ~/bin 在 PATH 中（写入 ~/.bashrc 或 ~/.zshrc）：
export PATH="$HOME/bin:$PATH"
```

## 使用

```bash
stream
# 1) 不求人  2) Suk  3) 雨果  4) 潮州交通音乐广播FM91.4
```

选择后前台播放：`mpv` 按 `q` 退出，或 `Ctrl+C` 结束。

### 电台后台常驻

```bash
# 启动
systemd-run --user --unit=cz-radio --collect ~/bin/cz_radio.sh

# 查看 / 停止
systemctl --user status cz-radio
systemctl --user stop cz-radio
```

> 注意：`cz_radio.sh` 从菜单（前台）启动时会自动 `systemctl --user stop cz-radio.service`，
> 反之在 `cz-radio.service` 中运行时（检测到 `INVOCATION_ID`）不会自我停止。

### 调节音量

```bash
pactl set-sink-volume @DEFAULT_SINK@ 50%
```

## 说明与注意事项

- 电台流来自 `radio5.cn` 的播放接口，返回的 `radio.cn` 地址带有时效 token；`cz_radio.sh`
  在播放中断后会重新获取新地址并自动续播，长时间挂机无需人工干预。
- 抖音直播链接可能随时间失效或需要登录 cookies；失败时请更新 `stream` 中的链接，
  或给 `streamlink` 增加 `--http-header` / cookies 参数。
- 虎牙重连逻辑：`mpv` 正常退出（`q`）或 `Ctrl+C` 不重连；异常中断 3 秒后自动重试。
- 相关仓库：[huya-live](https://github.com/syu-toutousai/huya-live)（`huya.sh` 的独立维护版本）。
