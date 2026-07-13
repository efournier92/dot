#!/bin/sh
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

out="$model"

if [ -n "$used" ]; then
  out="$out | ctx: $(printf '%.0f' "$used")%"
fi

if [ -n "$week_pct" ]; then
  out="$out | 7d: $(printf '%.0f' "$week_pct")%"
fi

if [ -n "$five_pct" ] && [ -n "$five_resets" ]; then
  now=$(date +%s)
  diff=$((five_resets - now))
  if [ "$diff" -gt 0 ]; then
    h=$((diff / 3600))
    m=$(( (diff % 3600) / 60 ))
    timer="${h}h$(printf '%02d' $m)m"
  else
    timer="0h00m"
  fi
  out="$out | 5h: $(printf '%.0f' "$five_pct")% ($timer)"
fi

echo "$out"
