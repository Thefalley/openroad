#!/usr/bin/env bash
#
# OpenROAD-flow-scripts Hello World
# Ejecuta el diseño GCD (Greatest Common Divisor) para verificar que todo funciona.
# Ejecutar desde Git Bash: bash hello-world.sh
#

set -e

FLOW_DIR="$(cd "$(dirname "$0")/flow" && pwd)"

echo "=========================================="
echo "OpenROAD Hello World - diseño GCD"
echo "=========================================="

# Comprobar Docker
if ! command -v docker &> /dev/null; then
    echo ""
    echo "ERROR: Docker no está instalado o no está en el PATH."
    echo "Instala Docker Desktop: https://docs.docker.com/desktop/install/windows-install/"
    echo ""
    exit 1
fi

echo "Docker: $(docker --version)"
echo ""
echo "Ejecutando flujo RTL->GDS para diseño GCD (nangate45)..."
echo "Esto puede tardar varios minutos la primera vez (descarga imagen Docker)."
echo ""

cd "$FLOW_DIR"
./util/docker_shell make DESIGN_CONFIG=./designs/nangate45/gcd/config.mk

echo ""
echo "=========================================="
echo "Hello World completado correctamente."
echo "Resultados en: flow/results/nangate45/gcd/base/"
echo "=========================================="
