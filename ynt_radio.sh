#!/usr/bin/env bash
# ゆめのたね放送局: 日本のインターネットコミュニティ放送局
# 番組はパーソナリティによるトーク中心（音楽だけの番組はほぼなし）, 24時間生放送
# 用法: ynt_radio.sh [red|orange|yellow|green|blue|purple]  (省略時 red)
# 配信源: 公式プレーヤーの CloudFront 直リンク（固定URL・認証なし）；断線自動再接続
CHANNEL="${1:-red}"
STREAM_URL="https://d2kz66ab55q61t.cloudfront.net/$CHANNEL"

while true; do
  code=$(curl -s --max-time 8 --max-filesize 8192 -o /dev/null -w '%{http_code}' -A "Mozilla/5.0" "$STREAM_URL")
  if [ "$code" != 200 ]; then
    echo "[$(date '+%F %T')] 放送に接続できません。10秒後に再試行します..."
    sleep 10
    continue
  fi
  echo "[$(date '+%F %T')] 再生中: $STREAM_URL"
  mpv --no-video --really-quiet --cache=yes --audio-display=no "$STREAM_URL"
  ec=$?
  [ "$ec" -eq 0 ] && break   # 前台菜单模式: mpv 按 q 正常退出 → 返回菜单
  echo "[$(date '+%F %T')] 接続が切れました (exit=$ec)。3秒後に再接続します..."
  sleep 3
done
