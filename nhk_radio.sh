#!/usr/bin/env bash
# NHKワールド・ラジオ日本（日本語 同时配信）
# 播放源: nhkworld.jp 官方 HLS 直播流（固定地址, 无 token）；断线自动重连
# 主源 r1（masterpl, 官方直播页面引用）；取不到时回落到 nhkworld-radio media2
STREAM_URLS=(
  "https://masterpl.hls.nhkworld.jp/hls/r1/live/master.m3u8"
  "https://nhkworld-radio.nhkworld.jp/hls/live/nhkworld-radio-media2/index.m3u8"
)

get_stream() {
  local u
  for u in "${STREAM_URLS[@]}"; do
    if [ "$(curl -s -o /dev/null -w '%{http_code}' --max-time 8 -A "Mozilla/5.0" "$u")" = 200 ]; then
      echo "$u"
      return 0
    fi
  done
  return 1
}

while true; do
  url=$(get_stream)
  if [ -z "$url" ]; then
    echo "[$(date '+%F %T')] 放送に接続できません。10秒後に再試行します..."
    sleep 10
    continue
  fi
  echo "[$(date '+%F %T')] 再生中: $url"
  mpv --no-video --really-quiet --cache=yes --audio-display=no "$url"
  ec=$?
  [ "$ec" -eq 0 ] && break   # 前台菜单模式: mpv 按 q 正常退出 → 返回菜单
  echo "[$(date '+%F %T')] 接続が切れました (exit=$ec)。3秒後に再接続します..."
  sleep 3
done
