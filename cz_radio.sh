#!/usr/bin/env bash
# 潮州交通音乐广播 FM91.4
# 播放源: radio5.cn -> ytcastmp3.radio.cn（地址含时效 token，自动刷新续播）
REFERER="https://radio5.cn/play/radio/czbtv-traffic-music-radio"

[ -z "$INVOCATION_ID" ] && systemctl --user stop cz-radio.service 2>/dev/null

get_stream() {
  local cookies page nonce
  cookies=$(mktemp)
  page=$(curl -s --max-time 20 -c "$cookies" -A "Mozilla/5.0" "$REFERER")
  nonce=$(echo "$page" | grep -oE '"nonce":"[a-f0-9]+"' | head -1 | cut -d'"' -f4)
  curl -s --max-time 20 -b "$cookies" -A "Mozilla/5.0" \
    -H "X-WP-Nonce: $nonce" -H "Referer: $REFERER" \
    "https://radio5.cn/api/play/play/1719?type=post" \
    | python3 -c "import sys,json;print(json.load(sys.stdin).get('stream_url',''))" 2>/dev/null
  rm -f "$cookies"
}

while true; do
  url=$(get_stream)
  if [ -z "$url" ]; then
    echo "[$(date '+%F %T')] failed to get stream url, retrying..."
    sleep 10
    continue
  fi
  echo "[$(date '+%F %T')] playing: $url"
  mpv --no-video --really-quiet --cache=yes --audio-display=no "$url"
  echo "[$(date '+%F %T')] stream ended, reconnecting..."
  sleep 3
done
