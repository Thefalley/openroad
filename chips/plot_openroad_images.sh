#!/usr/bin/env bash
# Copia los plots de OpenROAD (save_images) desde flow/reports a chips/
# Los plots se generan automáticamente durante make (etapa 6_report).
# Uso: ./plot_openroad_images.sh [nangate45] [gcd]
PLATFORM=${1:-nangate45}
DESIGN=${2:-gcd}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$SCRIPT_DIR/../flow/reports/$PLATFORM/$DESIGN/base"
if [ -d "$SRC" ]; then
  cp "$SRC"/final_*.webp "$SRC"/cts_*.webp "$SCRIPT_DIR/" 2>/dev/null
  echo "Plots copiados a chips/"
else
  echo "No hay plots. Ejecuta primero: cd flow && ./util/docker_shell make DESIGN_CONFIG=./designs/$PLATFORM/$DESIGN/config.mk"
fi
