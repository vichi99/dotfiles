#!/bin/sh

# Fetch BTC price and keep only first two digits
RATE=$(curl -s 'https://api.coinbase.com/v2/prices/BTC-USD/spot' \
  | grep -o '"amount":"[^"]*"' \
  | cut -d'"' -f4 \
  | cut -d'.' -f1 \
  | sed 's/^\(..\).*/\1/')


if [ -n "$RATE" ]; then
  sketchybar --set $NAME icon="₿" label="${RATE}K $" label.padding_left=0
fi
