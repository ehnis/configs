#!/usr/bin/env bash
LAYOUT=$(xkb-switch -p)
case $LAYOUT in
    us) echo '{"text": "🇺🇸", "tooltip": "English"}' ;;
    ru) echo '{"text": "🇷🇺", "tooltip": "Russian"}' ;;
    *) echo '{"text": "⌨", "tooltip": "Unknown"}' ;;
esac
