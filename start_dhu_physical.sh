#!/usr/bin/env bash
set -euo pipefail

ADB="/c/Users/Lenovo/AppData/Local/Android/Sdk/platform-tools/adb.exe"
DHU="/c/Users/Lenovo/AppData/Local/Android/Sdk/extras/google/auto/desktop-head-unit.exe"
DEVICE="${DEVICE:-}"

if [[ ! -f "$ADB" ]]; then
  echo "[ERROR] adb not found: $ADB"
  exit 1
fi

if [[ ! -f "$DHU" ]]; then
  echo "[ERROR] desktop-head-unit.exe not found: $DHU"
  exit 1
fi

echo "[1/3] Checking device..."
if [[ -n "$DEVICE" ]]; then
  if ! "$ADB" devices | grep -q "^$DEVICE[[:space:]]\+device$"; then
    echo "[ERROR] Device $DEVICE not connected."
    echo "Connect phone and enable USB debugging, then retry."
    exit 1
  fi
else
  DEVICE="$($ADB devices | awk '$2=="device" {print $1; exit}')"
  if [[ -z "$DEVICE" ]]; then
    echo "[ERROR] No authorized adb device found."
    echo "Connect phone, unlock screen, and allow USB debugging prompt."
    "$ADB" devices
    exit 1
  fi
  echo "[INFO] Using detected device: $DEVICE"
fi

echo "[2/3] Setting ADB forward tcp:5277..."
"$ADB" forward tcp:5277 tcp:5277

echo "[3/3] Preparing Android Auto on phone..."
"$ADB" -s "$DEVICE" shell am start -n com.google.android.projection.gearhead/.frx.SetupActivity >/dev/null 2>&1 || true
"$ADB" -s "$DEVICE" shell am start -n com.google.android.projection.gearhead/.companion.settings.DefaultSettingsActivity >/dev/null 2>&1 || true

echo "[4/4] Starting DHU (auto-reconnect mode)..."

while true; do
  "$DHU"
  echo "[INFO] DHU exited. Reconnecting in 2 seconds..."
  sleep 2
  "$ADB" forward tcp:5277 tcp:5277 >/dev/null 2>&1 || true
done
