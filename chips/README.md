# Chips - Hello World OpenROAD

Plots de chips generados con OpenROAD-flow-scripts en este PC.

## Diseño actual: GCD (Greatest Common Divisor)

**Plataforma:** Nangate45  
**Fabricante/PDK:** Nangate (Finlandia) – tecnología europea

### Plots nativos de OpenROAD (save_images.tcl)

Estos plots se generan automáticamente durante el flujo 6_report usando el comando `save_image` de OpenROAD. Muestran vistas desde el ODB (formato nativo de OpenROAD).

| Archivo | Descripción |
|---------|-------------|
| `final_all.webp` | Vista completa con power, ground y routing |
| `final_routing.webp` | Solo routing (sin power/ground) |
| `final_placement.webp` | Placement sin routing ni fill cells |
| `final_clocks.webp` | Árbol de reloj y buffers |
| `final_congestion.webp` | Heat map de congestión |
| `final_resizer.webp` | Celdas creadas por el resizer |
| `final_worst_path.webp` | Peor path de timing |
| `final_ir_drop.webp` | Caída de tensión IR |
| `cts_core_clock.webp` | Árbol de reloj (diagrama) |
| `cts_core_clock_layout.webp` | Layout del clock tree |

### Plot vía KLayout (GDS)

- **gcd_nangate45.png** – exportación directa del GDS con KLayout

![GCD desde GDS](gcd_nangate45.png)

### Ubicación de archivos

- **Plots OpenROAD:** `flow/reports/nangate45/gcd/base/*.webp`
- **GDS (layout):** `flow/results/nangate45/gcd/base/6_final.gds`
- **Netlist:** `flow/results/nangate45/gcd/base/6_final.v`

### PDKs europeos en OpenROAD

| PDK | Fabricante | Ubicación | Diseño ejemplo |
|-----|------------|-----------|----------------|
| **nangate45** | Nangate | Finlandia | gcd ✓ |
| **ihp-sg13g2** | IHP | Alemania (Frankfurt Oder) | gcd (RC pending) |
| **gf180** | GlobalFoundries | Dresden, Alemania | ibex, riscv32i |

### Regenerar plots

Para exportar el GDS a PNG:

```bash
cd /c/project/openroad/flow
./util/docker_shell "klayout -z -nc -rx -rd in_file=./results/nangate45/gcd/base/6_final.gds -rd out_file=./results/nangate45/gcd/base/gcd_chip.png -rd width=1200 -rm util/gds_to_png.py"
```

Para otro diseño, cambia `nangate45/gcd` por la plataforma y diseño correspondientes.
