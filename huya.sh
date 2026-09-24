#!/usr/bin/env bash
# 稳定看虎牙直播:断开自动重连;mpv 按 q 退出或 Ctrl+C 结束
URL="${1:-huya.com/52009}"
QUALITY="${2:-best}"

while :; do
  streamlink --retry-streams 999 --retry-open 10 \
    --stream-timeout 120 \
    -p mpv "$URL" "$QUALITY"
  ec=$?
  [ "$ec" -eq 0 ] && break   # mpv 正常退出(q),不重连
  [ "$ec" -eq 130 ] && break # Ctrl+C,不重连
  echo "[$(date +%T)] 连接中断 (exit=$ec),3 秒后重连..."
  sleep 3
done
