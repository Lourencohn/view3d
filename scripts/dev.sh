#!/usr/bin/env bash
# Sobe emulador(es) e roda `flutter run` em todos os devices conectados.
#
# Uso:
#   ./scripts/dev.sh           # iOS + Android
#   ./scripts/dev.sh ios       # só iOS Simulator
#   ./scripts/dev.sh android   # só Pixel 9 Pro
#   ./scripts/dev.sh all       # alias para sem-argumento
#
# Aceita flags extras que são repassadas pro `flutter run`:
#   ./scripts/dev.sh ios --release
#   ./scripts/dev.sh -- --dart-define=FOO=bar

set -euo pipefail

TARGET="${1:-all}"
case "$TARGET" in
  ios|android|all) shift || true ;;
  --*|"") TARGET="all" ;;
  *) echo "Alvo desconhecido: $TARGET (use ios | android | all)"; exit 1 ;;
esac

ANDROID_EMU="Pixel_9_Pro"

wait_for_ios() {
  echo "→ aguardando iOS Simulator inicializar..."
  # Espera até existir pelo menos 1 device booted
  until xcrun simctl list devices booted | grep -q "Booted"; do
    sleep 1
  done
  echo "✓ iOS Simulator pronto"
}

wait_for_android() {
  echo "→ aguardando emulador Android inicializar..."
  # adb pode não estar no PATH; resolve via flutter
  ADB="$(dirname "$(command -v flutter)")/../../bin/adb"
  if ! command -v adb >/dev/null && [[ ! -x "$ADB" ]]; then
    # fallback: pega o adb do Android SDK padrão
    ADB="${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb"
  fi
  command -v adb >/dev/null && ADB=adb

  until "$ADB" shell getprop sys.boot_completed 2>/dev/null | grep -q "1"; do
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

case "$TARGET" in
  ios)     boot_ios ;;
  android) boot_android ;;
  all)     boot_ios; boot_android ;;
esac

# Pequena pausa pra o `flutter devices` enxergar tudo
sleep 2
echo
echo "→ devices visíveis:"
flutter devices
echo

# -d all roda em todos os devices conectados simultaneamente
if [[ "$TARGET" == "all" ]]; then
  exec flutter run -d all "$@"
elif [[ "$TARGET" == "ios" ]]; then
  exec flutter run -d ios "$@"
else
  exec flutter run -d android "$@"
fi
