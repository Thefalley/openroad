# SDC – Qué es y primitivas de uso

## ¿Qué es SDC?

**SDC** (Synopsys Design Constraints) es el formato estándar en industria para describir restricciones de timing y diseño. Fue creado por Synopsys y hoy lo usan OpenSTA, OpenROAD, Vivado, Quartus, etc.

- **Archivo**: texto ASCII con extensión `.sdc`
- **Sintaxis**: Tcl (Tool Command Language)
- **Propósito**: definir relojes, retardos I/O, paths a ignorar, límites eléctricos, etc.
- **Uso**: síntesis, P&R y STA (Static Timing Analysis) leen el SDC para optimizar y verificar el diseño.

---

## Primitivas SDC por categoría

### 1. Contexto y unidades

| Primitiva | Uso |
|-----------|-----|
| `current_design nombre` | Define el módulo/design actual |
| `set_units -time ns -capacitance fF ...` | Unidades del archivo |
| `set sdc_version 2.0` | Versión SDC (opcional) |

---

### 2. Relojes

| Primitiva | Sintaxis | Descripción |
|-----------|----------|-------------|
| `create_clock` | `create_clock -name X -period T [get_ports clk]` | Reloj primario en puerto, período T (ns) |
| `create_clock -waveform` | `create_clock -name X -period 10 -waveform {0 5} [get_ports clk]` | Reloj con duty cycle explícito (rising en 0, falling en 5 ns) |
| `create_clock -add` | `create_clock -name X -period T -add [get_ports clk]` | Añade reloj sin borrar los existentes |
| `create_clock` (virtual) | `create_clock -name vclk -period T` | Reloj virtual, sin puerto físico |
| `create_generated_clock` | `create_generated_clock -name div -source [get_ports clk] -divide_by 2 [get_pins div/q]` | Reloj derivado (divisor, etc.) |
| `set_propagated_clock` | `set_propagated_clock [get_clocks clk]` | Usa latencia real en vez de ideal |
| `set_clock_latency` | `set_clock_latency 0.07 [get_clocks clk]` | Latencia estimada del árbol de reloj |
| `set_clock_uncertainty` | `set_clock_uncertainty 0.25 [get_clocks clk]` | Margen para jitter/skew |
| `set_clock_transition` | `set_clock_transition 0.15 [get_clocks clk]` | Transición máxima (slew) del reloj |
| `set_clock_groups` | `set_clock_groups -logically_exclusive -group [get_clocks A] -group [get_clocks B]` | Relojes mutuamente excluyentes (no hay paths entre ellos) |

---

### 3. Retardos I/O

| Primitiva | Sintaxis | Descripción |
|-----------|----------|-------------|
| `set_input_delay` | `set_input_delay D -clock CLK [get_ports in*]` | Retardo externo en entradas respecto al reloj CLK |
| `set_input_delay -max` | `set_input_delay -max D -clock CLK ...` | Retardo máximo |
| `set_input_delay -min` | `set_input_delay -min D -clock CLK ...` | Retardo mínimo |
| `set_input_delay -add_delay` | `set_input_delay -add_delay -max D ...` | Añade al constraint existente |
| `set_output_delay` | `set_output_delay D -clock CLK [get_ports out*]` | Retardo externo en salidas respecto a CLK |
| `set_output_delay -max/-min` | Idem que en input | |
| `set_output_delay -add_delay` | Idem que en input | |

---

### 4. Paths y timing

| Primitiva | Sintaxis | Descripción |
|-----------|----------|-------------|
| `set_false_path` | `set_false_path -from [get_ports a] -to [get_ports b]` | Excluye ese path del análisis de timing |
| `set_false_path -to` | `set_false_path -to [get_ports debug*]` | Excluye todos los paths que terminan en esos puertos |
| `set_false_path -from` | `set_false_path -from [get_ports rst]` | Excluye paths que salen de esos puertos |
| `set_multicycle_path` | `set_multicycle_path -setup 2 -from A -to B` | Path que usa N ciclos de reloj |
| `set_max_delay` | `set_max_delay D -from A -to B` | Retardo máximo entre A y B |
| `set_min_delay` | `set_min_delay D -from A -to B` | Retardo mínimo (hold) |
| `set_timing_derate` | `set_timing_derate -early 0.95 -late 1.05` | Factor de margen OCV (On-Chip Variation) |

---

### 5. Cargas y driving

| Primitiva | Sintaxis | Descripción |
|-----------|----------|-------------|
| `set_load` | `set_load 0.033 [all_outputs]` | Carga capacitiva en salidas (pF) |
| `set_driving_cell` | `set_driving_cell -lib_cell inv_2 -pin Y [all_inputs]` | Carga de conducción en entradas (modelada como celda) |
| `set_max_capacitance` | `set_max_capacitance 0.5 [all_inputs]` | Capacitancia máxima permitida |

---

### 6. Límites eléctricos y optimización

| Primitiva | Sintaxis | Descripción |
|-----------|----------|-------------|
| `set_max_fanout` | `set_max_fanout 10 [current_design]` | Fanout máximo antes de insertar buffers |
| `set_max_transition` | `set_max_transition 0.5 [current_design]` | Transición (slew) máxima permitida |
| `set_max_transition -clock_path` | `set_max_transition 0.1 -clock_path [get_clocks clk]` | Solo en redes de reloj |

---

### 7. Protección de celdas

| Primitiva | Sintaxis | Descripción |
|-----------|----------|-------------|
| `set_dont_touch` | `set_dont_touch [get_cells ram_*]` | No modificar esas celdas |
| `set_size_only` | `set_size_only [get_cells X]` | No cambiar tamaño |

---

### 8. Análisis funcional

| Primitiva | Sintaxis | Descripción |
|-----------|----------|-------------|
| `set_case_analysis` | `set_case_analysis 0 [get_ports scan_en]` | Fija valor en un puerto para análisis |

---

### 9. Colecciones (selection objects)

Se usan con `get_*` y `all_*` para identificar objetos:

| Primitiva | Uso |
|-----------|-----|
| `get_ports patron` | Puertos que coinciden con el patrón |
| `get_ports * -filter "direction==in"` | Puertos con filtro |
| `get_clocks *` | Todos los relojes |
| `get_cells patron` | Celdas |
| `get_pins patron` | Pines |
| `get_nets patron` | Nets |
| `all_inputs` | Todas las entradas |
| `all_outputs` | Todas las salidas |
| `all_inputs -no_clocks` | Entradas excluyendo relojes |
| `all_clocks` | Todos los relojes |
| `current_design` | Diseño actual |

Patrones tipo `*`, `?`, `[abc]` son los habituales de Tcl.

---

## Ejemplo mínimo SDC

```tcl
current_design mi_modulo

create_clock -name clk -period 1.0 [get_ports clk]

set_input_delay  0.2 -clock clk [all_inputs -no_clocks]
set_output_delay 0.2 -clock clk [all_outputs]
```

---

## Ejemplo con dos relojes (JTAG + core)

```tcl
current_design microwatt

create_clock -name ext_clk -period 15.0 [get_ports ext_clk]
create_clock -name jtag_tck -period 100.0 [get_ports jtag_tck]

set_clock_groups -logically_exclusive \
  -group [get_clocks ext_clk] \
  -group [get_clocks jtag_tck]

set_input_delay  3.0 -clock ext_clk [get_ports uart0_rxd]
set_output_delay 3.0 -clock ext_clk [get_ports uart0_txd]

set_input_delay  20.0 -clock jtag_tck [get_ports jtag_tdi]
set_output_delay 20.0 -clock jtag_tck [get_ports jtag_tdo]
```

---

## Referencias

- Especificación SDC (Synopsys)
- Documentación OpenSTA: https://github.com/The-OpenROAD-Project/OpenSTA
