# stream

本机终端播放快捷菜单：一键选择主播或电台，基于 [streamlink](https://streamlink.github.io/) + [mpv](https://mpv.io/) 播放。

## 网页版（异构实现）

同一份菜单的 GitHub Pages 网页版：<https://syu-toutousai.github.io/stream/>（源码即本仓库 `index.html`）

- 点击菜单（或按 `1–7`、深链 `#suk` / `#radio` 等）会弹出一个**无地址栏的独立播放窗口**，与终端版「选台即开 mpv 窗口」对应；
- 虎牙 / 抖音 / 电台（radio5.cn 官方播放器）一律弹窗播放；电台窗口内需点一次它自带的播放键；
- 电台窗口内提示「播放源已失效」时，**再点一次本项即可**（会强制刷新播放窗口，重新取流）；
- 同名窗口自动复用；弹窗被拦截时页面状态栏会给出直达链接；从主页 <https://syu-toutousai.github.io/> 也可进入。
- 电台 FM91.4 停播时段为北京时间 01:00–06:00，此时官方源无流（网页版/终端版都一样）。

## 菜单内容

| 选项 | 名称 | 类型 | 实现 |
| --- | --- | --- | --- |
| 1 | 不求人 | 抖音直播 | `streamlink` → `mpv` |
| 2 | Suk | 虎牙直播 | `streamlink` → `mpv` |
| 3 | 雨果 | 虎牙直播 | `streamlink` → `mpv` |
| 4 | 潮州交通音乐广播 FM91.4 | 电台 | 从 radio5.cn 取流 → `mpv` |
| 5 | 晚玉阿 | 抖音直播 | `streamlink` → `mpv` |
| 6 | PEL和平精英赛事 | 虎牙直播 | `streamlink` → `mpv` |
| 7 | 清宁 | 抖音直播 | `streamlink` → `mpv` |
| 8 | Japanese Everyday | YouTube 日语节目 | `yt-dlp` 枚举频道视频 → `mpv` 随机播放 |
| 9 | NHKワールド・ラジオ日本 | 电台（日本） | nhkworld.jp 官方 HLS 流 → `mpv` |
| 0 | ゆめのたね放送局 | 电台（日本・トーク） | 六色频道二级菜单（`1`–`6` 彩色选台）→ CloudFront 官方流 → `mpv` |

## 文件说明

- `stream`：选择菜单入口。每次显示菜单前并行探测各直播源在线状态并标注（VOD 不探测）；播放结束返回菜单，输入 `q` 才退出。
- `index.html`：GitHub Pages 网页版播放台（终端菜单的异构实现，见上）。
- `huya.sh`：虎牙 / 抖音直播稳定播放（断线自动重连；`mpv` 按 `q` 退出或 `Ctrl+C` 结束不重连）。
- `cz_radio.sh`：潮州交通音乐广播 FM91.4，流地址含时效 token，脚本会自动重新取流续播；前台（菜单）模式下 `mpv` 按 `q` 退出则返回菜单，后台 `cz-radio.service` 断线仍自动续播。
- `nhk_radio.sh`：NHKワールド・ラジオ日本（日本語同时配信），官方 HLS 固定地址、无 token；r1 主源取不到时自动回落到备用流，断线自动重连；`mpv` 按 `q` 退出返回菜单。
- `ynt_radio.sh`：ゆめのたね放送局（日本的互联网社区电台，以谈话节目为主），六色频道（`red`/`orange`/`yellow`/`green`/`blue`/`purple`）直连 CloudFront 官方流，固定地址、无 token；断线自动重连，`mpv` 按 `q` 退出返回菜单。
- `yt_random.sh`：随机播放 YouTube 频道视频（默认 [@JapaneseEveryday](https://www.youtube.com/@JapaneseEveryday)）。
  视频列表缓存在 `~/.cache/stream-yt/`（24 小时），每次启动 `mpv --shuffle` 随机排序；加载失败的视频自动跳过。
  播放进度按视频记录在 `~/.cache/stream-yt/watch_later/`：`q` 退出后下次先续播上次中断的视频，其余仍随机，
  随机遇到看过的视频从上次进度继续（不想要先续播可加 `--playlist-start=no`）。

## 依赖

必需：

- `bash`
- `mpv`：播放器
- `streamlink`：虎牙 / 抖音拉流
- `yt-dlp`：YouTube 频道视频枚举与播放（选项 8）
- `curl` + `python3`：`cz_radio.sh` 获取并解析流地址
- `grep`：脚本内部提取页面 nonce（一般系统自带）

可选：

- `systemd`（用户级）：`cz_radio.sh` 从菜单前台启动时会顺带停掉后台的 `cz-radio.service`，避免两路声音重叠；后台常驻用法见下。
- `PulseAudio` / `PipeWire`：用于调节音量（`pactl` / `wpctl`）。

网络条件：

- 直播：可访问 `huya.com`、`live.douyin.com`
- 电台：可访问 `radio5.cn`、`ytcastmp3.radio.cn`
- 电台（NHK）：可访问 `nhkworld.jp`（Clash 线路不稳时脚本会自动重连/落备流）
- 电台（ゆめのたね）：可访问 `d2kz66ab55q61t.cloudfront.net`（六色频道均为全球可达的官方流）
- YouTube（选项 8）：可访问 `youtube.com`（本机经 Clash TUN 代理，行情不稳时会加载失败，`mpv` 会自动跳到下一个）

以 Arch Linux 为例安装：

```bash
sudo pacman -S mpv streamlink yt-dlp curl python
```

其他发行版用对应的包管理器安装同名软件即可。

## 安装部署

```bash
mkdir -p ~/bin
cp stream huya.sh cz_radio.sh nhk_radio.sh ynt_radio.sh yt_random.sh ~/bin/
chmod +x ~/bin/stream ~/bin/huya.sh ~/bin/cz_radio.sh ~/bin/nhk_radio.sh ~/bin/ynt_radio.sh ~/bin/yt_random.sh

# 确保 ~/bin 在 PATH 中（写入 ~/.bashrc 或 ~/.zshrc）：
export PATH="$HOME/bin:$PATH"
```

## 使用

```bash
stream
# 1) 不求人 [在线]  2) Suk [在线]  3) 雨果 [在线]  4) 潮州交通音乐广播FM91.4 [在线]
# 5) 晚玉阿 [未开播]  6) PEL和平精英赛事 [在线]  7) 清宁 [未开播]  8) Japanese Everyday(随机日语)  9) NHKワールド・ラジオ日本 [在线]
# 0) ゆめのたね放送局(色を選ぶ) [在线]
```

- 启动（及每次播放结束返回菜单）时自动探测各直播源，菜单项后标注 `[在线]` / `[未开播]` / `[停播]` / `[未知]`；VOD 类（选项 8）不探测、不标注。
- 选项 0：先进入六色频道二级菜单（`1`–`6` 即选即播，颜色仅作显示；`q` 返回主菜单）；六色中任一频道在线，主菜单该项即标注 `[在线]`。
- 选择后前台播放：`mpv` 按 `q` 结束播放并回到菜单；在菜单输入 `q` 退出整个脚本；`Ctrl+C` 直接结束脚本。

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
  在播放中断后会重新获取新地址并自动续播，长时间挂机无需人工干预。注意该台北京时间
  01:00–06:00 停播，停播期间取到的流无法出声，属正常现象。
- 抖音直播链接可能随时间失效或需要登录 cookies；失败时请更新 `stream` 中的链接，
  或给 `streamlink` 增加 `--http-header` / cookies 参数。
- 虎牙重连逻辑：`mpv` 正常退出（`q`）或 `Ctrl+C` 不重连；异常中断 3 秒后自动重试。
- 相关仓库：[huya-live](https://github.com/syu-toutousai/huya-live)（`huya.sh` 的独立维护版本）。
