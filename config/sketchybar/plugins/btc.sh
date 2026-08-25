#!/bin/sh

# Wait a bit if this is triggered by system_woke (network may not be ready immediately)
if [ "$SENDER" = "system_woke" ]; then
  sleep 0.5
fi

RATE=""
DEFAULT_LABEL="..."
DEFAULT_ICON="₿"

# USD price -> thousands for label "NNNK $"
usd_to_k() {
  awk -v p="$1" 'BEGIN {
    if (p == "" || p !~ /^[0-9.]+$/) exit 1
    printf "%.0f", p / 1000 + 0.0001
  }' 2>/dev/null
}

# Method 1: Coinbase API (primary method)
if command -v curl >/dev/null 2>&1; then
  RAW=$(curl -s --max-time 5 --connect-timeout 3 'https://api.coinbase.com/v2/prices/BTC-USD/spot' 2>/dev/null \
    | grep -o '"amount":"[^"]*"' 2>/dev/null \
    | cut -d'"' -f4 2>/dev/null | head -1)
  RATE=$(usd_to_k "$RAW")
fi

# Method 2: Alternative API - Binance (fallback)
if [ -z "$RATE" ] && command -v curl >/dev/null 2>&1; then
  RAW=$(curl -s --max-time 5 --connect-timeout 3 'https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT' 2>/dev/null \
    | grep -o '"price":"[^"]*"' 2>/dev/null \
    | cut -d'"' -f4 2>/dev/null | head -1)
  RATE=$(usd_to_k "$RAW")
fi

# Method 3: Alternative API - CoinGecko (fallback)
if [ -z "$RATE" ] && command -v curl >/dev/null 2>&1; then
  RAW=$(curl -s --max-time 5 --connect-timeout 3 'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd' 2>/dev/null \
    | grep -o '"usd":[0-9.]*' 2>/dev/null \
    | cut -d':' -f2 2>/dev/null | head -1)
  RATE=$(usd_to_k "$RAW")
fi

# Validate RATE is a number and not empty
if [ -z "$RATE" ] || ! [ "$RATE" -eq "$RATE" ] 2>/dev/null; then
  # Set default label to ensure item is visible
  sketchybar --set $NAME icon="$DEFAULT_ICON" label="$DEFAULT_LABEL" label.padding_left=0 2>/dev/null || \
    sketchybar --set $NAME icon="$DEFAULT_ICON" label="$DEFAULT_LABEL" label.padding_left=0
  exit 0
fi

# Format label with "K $" suffix
FORMATTED_LABEL="${RATE}K $"

# Always set label to ensure item is visible
sketchybar --set $NAME icon="$DEFAULT_ICON" label="$FORMATTED_LABEL" label.padding_left=0 2>/dev/null || \
  sketchybar --set $NAME icon="$DEFAULT_ICON" label="$FORMATTED_LABEL" label.padding_left=0
