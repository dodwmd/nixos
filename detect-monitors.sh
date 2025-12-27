#!/usr/bin/env bash
# Helper script to detect monitor configuration

echo "=== Detecting Monitors ==="
echo ""

if command -v niri &> /dev/null; then
    echo "Using niri to detect outputs:"
    niri msg outputs 2>/dev/null || echo "Niri not running yet"
    echo ""
fi

if command -v wlr-randr &> /dev/null; then
    echo "Using wlr-randr:"
    wlr-randr
    echo ""
fi

if [ -d /sys/class/drm ]; then
    echo "Available DRM outputs:"
    for output in /sys/class/drm/card*/card*/status; do
        if [ -f "$output" ]; then
            name=$(basename $(dirname "$output"))
            status=$(cat "$output")
            echo "  $name: $status"
        fi
    done
fi

echo ""
echo "Update home/profiles/exodus/niri-config.nix with the correct output names"
