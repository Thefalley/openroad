#!/usr/bin/env bash
# Genera PNG del chip. Uso: ./plot_chip.sh [platform/design] [width]
# Ejemplo: ./plot_chip.sh nangate45/gcd 1200
PLATFORM_DESIGN=${1:-nangate45/gcd}
WIDTH=${2:-1200}
NAME=$(echo $PLATFORM_DESIGN | tr '/' '_')
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../flow"
./util/docker_shell "klayout -z -nc -rx -rd in_file=./results/$PLATFORM_DESIGN/base/6_final.gds -rd out_file=./results/$PLATFORM_DESIGN/base/${NAME}_chip.png -rd width=$WIDTH -rm util/gds_to_png.py"
cp "results/$PLATFORM_DESIGN/base/${NAME}_chip.png" "../chips/" 2>/dev/null || true
echo "Plot guardado en chips/${NAME}_chip.png"
