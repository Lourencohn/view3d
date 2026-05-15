#!/usr/bin/env bash
# Pergunta a plataforma, sobe o emulador correspondente e roda `flutter run`.
#
# Uso:
#   ./scripts/dev.sh           # menu interativo (i / a)
#   ./scripts/dev.sh ios       # direto no iOS Simulator
#   ./scripts/dev.sh android   # direto no Pixel 9 Pro
#
# Flags extras vão pro `flutter run`:
#   ./scripts/dev.sh ios --release
#   ./scripts/dev.sh android --dart-define=FOO=bar

set -euo pipefail

TARGET="${1:-}"
case "$TARGET" in
  ios|android) shift || true ;;
  "")
    echo "Onde rodar?"
    echo "  [i] iOS Simulator"
    echo "  [a] Android (Pixel 9 Pro)"
    printf "→ "
    read -r choice
    case "$choice" in
      i|I|ios)     TARGET="ios" ;;
      a|A|android) TARGET="android" ;;
      *) echo "Cancelado."; exit 1 ;;
    esac
    ;;
  *) echo "Alvo desconhecido: $TARGET (use ios | android)"; exit 1 ;;
esac

ANDROID_EMU="Pixel_9_Pro"

wait_for_ios() {
  echo "→ aguardando iOS Simulator inicializar..."
  until xcrun simctl list devices booted | grep -q "Booted"; do
    sleep 1
  done
  echo "✓ iOS Simulator pronto"
}

wait_for_android() {
  echo "→ aguardando emulador Android inicializar..."
  until adb shell getprop sys.boot_completed 2>/dev/null | grep -q "1"; do
    sleep 2
  done
  echo "✓ Android emulator pronto"
}

boot_ios() {
  if xcrun simctl list devices booted | grep -q "Booted"; then
    echo "✓ iOS Simulator já está rodando"
  else
    echo "→ abrindo iOS Simulator..."
    open -a Simulator
    wait_for_ios
  fi
}

boot_android() {
  if flutter devices 2>/dev/null | grep -qi "android"; then
    echo "✓ Android emulator já está rodando"
  else
    echo "→ iniciando emulador $ANDROID_EMU em background..."
    flutter emulators --launch "$ANDROID_EMU" >/dev/null 2>&1 &
    wait_for_android
  fi
}

if [[ "$TARGET" == "ios" ]]; then
  boot_ios
else
  boot_android
fi

sleep 2
echo
echo "→ devices visíveis:"
flutter devices
echo

# Resolve device-id via flutter devices --machine (JSON) + jq.
if [[ "$TARGET" == "ios" ]]; then
  DEVICE_ID=$(flutter devices --machine 2>/dev/null \
    | jq -r '.[] | select(.targetPlatform == "ios") | .id' | head -1)
else
  DEVICE_ID=$(flutter devices --machine 2>/dev/null \
    | jq -r '.[] | select(.targetPlatform | startswith("android")) | .id' | head -1)
fi

if [[ -z "$DEVICE_ID" ]]; then
  echo "✗ Não encontrei device $TARGET conectado."
  exit 1
fi

echo "→ rodando em $TARGET (device id: $DEVICE_ID)"
exec flutter run -d "$DEVICE_ID" "$@"
