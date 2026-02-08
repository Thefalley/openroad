# OpenROAD Hello World

Este documento describe cómo ejecutar el ejemplo mínimo (diseño GCD) para demostrar que OpenROAD-flow-scripts funciona en este PC.

## Requisitos

- **Docker Desktop** instalado y en ejecución
- **Git Bash** (viene con Git for Windows)

## Ejecución rápida

1. Abre **Git Bash**
2. Ve al proyecto:
   ```bash
   cd /c/project/openroad
   ```
3. Ejecuta el script hello world:
   ```bash
   bash hello-world.sh
   ```

La primera vez descargará la imagen Docker (`openroad/orfs:latest`) y ejecutará el flujo completo RTL→GDS para el diseño GCD (Greatest Common Divisor) en la plataforma nangate45. Suele tardar 5-15 minutos.

## Ejecución manual (sin script)

```bash
cd /c/project/openroad/flow
./util/docker_shell make DESIGN_CONFIG=./designs/nangate45/gcd/config.mk
```

## Verificar éxito

Si termina bien, deberías ver:

- Mensaje de finalización del flujo
- Archivos en `flow/results/nangate45/gcd/base/`, por ejemplo:
  - `gcd.v` (netlist)
  - `gcd.gds` (layout GDSII)
  - `6_final.gds` (resultado final)

## Si falla

1. **"Docker no está instalado"**  
   Instala Docker Desktop: https://docs.docker.com/desktop/install/windows-install/

2. **"docker_shell: command not found"** o errores de Bash  
   Usa Git Bash, no PowerShell.

3. **"Cannot connect to Docker daemon"**  
   Inicia Docker Desktop y espera a que esté listo (icono en la bandeja del sistema).
