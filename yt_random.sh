#!/usr/bin/env bash
# 随机播放 YouTube 频道节目:每次启动随机排序,已播放过的从上次进度续播;mpv 按 q 退出,Enter/> 跳到下一个
# 用法: yt_random.sh [频道URL] [额外 mpv 参数...]
CHANNEL="${1:-https://www.youtube.com/@JapaneseEveryday}"
CHANNEL="${CHANNEL%/}"
CHANNEL="${CHANNEL%/videos}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/stream-yt"
CACHE="$CACHE_DIR/$(basename "$CHANNEL").txt"
WATCH_LATER="$CACHE_DIR/watch_later"
TTL=86400  # 视频列表缓存 24 小时

mkdir -p "$CACHE_DIR" "$WATCH_LATER"
if [ ! -s "$CACHE" ] || [ "$(($(date +%s) - $(stat -c %Y "$CACHE")))" -gt "$TTL" ]; then
  yt-dlp --flat-playlist --skip-download --print "%(webpage_url)s" \
    "$CHANNEL/videos" > "$CACHE.tmp" 2>/dev/null \
    && mv "$CACHE.tmp" "$CACHE" || rm -f "$CACHE.tmp"
fi

YTDL_FORMAT="bestvideo+bestaudio/best"
MPV_OPTS=(--shuffle --ytdl-format="$YTDL_FORMAT" --resume-playback
  --save-position-on-quit --watch-later-directory="$WATCH_LATER"
  --write-filename-in-watch-later-config)
if [ -s "$CACHE" ]; then
  exec mpv "${MPV_OPTS[@]}" --playlist="$CACHE" "${@:2}"
else
  echo "[$(date +%T)] 视频列表获取失败,直接播放频道页..." >&2
  exec mpv "${MPV_OPTS[@]}" "$CHANNEL/videos" "${@:2}"
fi
