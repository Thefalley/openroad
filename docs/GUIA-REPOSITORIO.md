# Guía del Repositorio OpenROAD-flow-scripts

Información práctica sobre ejemplos, constraints, relojes y requisitos RTL para ASIC.

---

## 1. Ejemplos del repositorio

### Por complejidad (de menor a mayor)

| Diseño | Descripción | Celdas aprox. | Plataformas |
|--------|-------------|---------------|-------------|
| **gcd** | Greatest Common Divisor. Hello world del flujo. | ~250 | nangate45, sky130hd, sky130hs, ihp-sg13g2, gf180, asap7, gf12 |
| **aes** | Cifrador AES. | ~5K | Todas |
| **ibex** | Core RISC-V 32-bit (low-power). | ~15K | nangate45, sky130, ihp-sg13g2, gf180, asap7, gf12 |
| **riscv32i** | Core RISC-V 32-bit simple. | ~8K | sky130hd, sky130hs, gf180 |
| **jpeg** | Codificador JPEG. | ~20K | nangate45, sky130, ihp-sg13g2, gf180, asap7, gf12 |
| **uart** | UART básico. | ~500 | asap7, gf180 |
| **ethmac** | Controlador Ethernet. | ~15K | asap7, rapidus2hp |
| **swerv** | SweRV RISC-V core. | ~100K | nangate45, asap7, gf12 |
| **ariane** | Ariane RISC-V 64-bit. | ~200K | nangate45, gf12 |
| **cva6** | CVA6 (Ariane) RISC-V 64-bit. | ~300K | asap7, rapidus2hp |
| **microwatt** | CPU OpenPOWER. | ~500K | sky130hd |
| **black_parrot** | SoC RISC-V multi-core. | Muy grande | nangate45 |
| **chameleon** | SoC con Ibex + IPs (AHB, APB). | ~50K | sky130hd |

### Qué aporta cada ejemplo

- **gcd**: plantilla mínima de constraints y config.mk
- **aes**: diseño combinacional/secuencial típico
- **ibex**: core con JTAG, interrupciones, caches
- **microwatt**: múltiples relojes (ext_clk, jtag_tck), UART, SPI, GPIO
- **ethmac**: múltiples dominios de reloj (tx_clk, rx_clk, top_clk)
- **mempool_group**: diseño jerárquico con múltiples bloques
- **chameleon**: SoC completo con bus AHB/APB

---

## 2. Constraints SDC – apuntes

### Lista de constraints más útiles

| Constraint | Qué hace |
|------------|----------|
| `create_clock -name X -period T [get_ports clk]` | Define reloj con período T (ns) en el puerto clk |
| `create_clock -name X -period T -waveform {0 T/2} [get_ports clk]` | Reloj con duty cycle 50% explícito |
| `set_input_delay D -clock CLK [get_ports in*]` | Retardo externo en las entradas respecto a CLK |
| `set_output_delay D -clock CLK [get_ports out*]` | Retardo externo en las salidas respecto a CLK |
| `set_false_path -from [get_ports a] -to [get_ports b]` | Excluye paths de análisis de timing |
| `set_false_path -to [get_ports debug*]` | Excluye puertos de debug |
| `set_clock_groups -logically_exclusive -group [get_clocks A] -group [get_clocks B]` | Relojes que nunca están activos a la vez (ej. clk vs jtag_clk) |
| `set_clock_uncertainty U [get_clocks clk]` | Margen para jitter/skew |
| `set_clock_transition T [get_clocks clk]` | Transición máxima de reloj |
| `set_max_fanout N [current_design]` | Límite de fanout para buffers |
| `set_driving_cell -lib_cell inv -pin Y [all_inputs]` | Carga de conducción en entradas |
| `set_load L [all_outputs]` | Carga en salidas |
| `set_timing_derate -early 0.95 -late 1.05` | Factor de margen para OCV |
| `set_multicycle_path -setup N -from A -to B` | Path que usa N ciclos |
| `set_dont_touch [get_cells ram_*]` | No optimizar celdas (p. ej. SRAM) |

### Plantilla SDC mínima (un reloj)

```tcl
current_design mi_diseno

set clk_name core_clock
set clk_port_name clk
set clk_period 1.0
set clk_io_pct 0.2

create_clock -name $clk_name -period $clk_period [get_ports $clk_port_name]

set non_clock_inputs [all_inputs -no_clocks]
set_input_delay  [expr $clk_period * $clk_io_pct] -clock $clk_name $non_clock_inputs
set_output_delay [expr $clk_period * $clk_io_pct] -clock $clk_name [all_outputs]
```

`clk_io_pct` reserva margen para I/O (20 % del período suele ser razonable).

---

## 3. Relojes – skew, sincronismo, CTS

### Diferencia con FPGA (MMCM, PLL)

En ASIC **no** se usan PLL/MMCM como en FPGA. El reloj entra por un puerto y:

1. **CTS (Clock Tree Synthesis)** construye el árbol de reloj con buffers para:
   - Minimizar **skew** entre flops
   - Balancear **latencia**
   - Controlar **slew** (transiciones)

2. **Clock gating** se hace con celdas tipo `OPENROAD_CLKGATE` (latch + AND) para ahorrar potencia. El flujo lo inserta si el PDK lo soporta.

3. **Múltiples relojes** (ej. clk + jtag_clk) se manejan con:
   - `create_clock` por cada reloj
   - `set_clock_groups -logically_exclusive` si no son síncronos
   - `set_false_path` entre dominios si no hay transferencia timing‑critical

### Parámetros CTS (config.mk)

- `CTS_CLUSTER_SIZE`: número de sinks por cluster
- `CTS_CLUSTER_DIAMETER`: diámetro máximo del cluster
- `CTS_BUF_LIST`: lista de buffers para el árbol
- `CTS_BUF_DISTANCE`: separación entre buffers

El script `cts.tcl` llama a `clock_tree_synthesis` con `-sink_clustering_enable` y `-repair_clock_nets`.

---

## 4. Requisitos RTL para ASIC

### Cambios típicos respecto a RTL de FPGA

| Aspecto | FPGA | ASIC (OpenROAD) |
|---------|------|------------------|
| Reset | Asíncrono habitual | Preferible síncrono para STA |
| Inicialización | Valores en `initial` | Evitar `initial` para lógica; usar reset |
| Clock | PLL/MMCM | Un puerto `clk` limpio |
| Recursos | BRAM, DSP | Usar SRAM/macros del PDK o memoria RTL |
| Primitivas | Específicas de vendor | Solo Verilog/SystemVerilog estándar |

### Recomendaciones RTL

1. **Reset síncrono**  
   Usar flops con reset síncrono; el PDK provee celdas con set/reset.

2. **Un único reloj por dominio**  
   Un puerto `clk` por dominio; dividir con lógica síncrona si hace falta.

3. **Sin `initial` en lógica**  
   Los `initial` para registros no son sintetizables de forma portable; mejor reset explícito.

4. **Memorias**  
   - SRAM: instanciar macros del PDK (LEF/LIB) o usar generadores
   - Registros: inferir flops estándar

5. **Nombres de puertos**  
   Coincidir con los usados en el SDC (p. ej. `clk`, `clk_i`, etc.).

6. **Jerarquía**  
   El flujo puede trabajar con diseños planos o jerárquicos (`OPENROAD_HIERARCHICAL`).

7. **Blackboxes**  
   Definir módulos vacíos para memorias/macros; el LEF/LIB define timing y geometría.

### Archivos necesarios por diseño

- **RTL**: `VERILOG_FILES` en `config.mk`
- **SDC**: `SDC_FILE` → `constraint.sdc`
- **config.mk**: `DESIGN_NAME`, `PLATFORM`, rutas, variables de síntesis/floorplan

---

## 5. Config.mk – variables clave

```makefile
export DESIGN_NAME = mi_modulo
export PLATFORM    = nangate45   # o sky130hd, ihp-sg13g2, gf180, etc.

export VERILOG_FILES = $(DESIGN_HOME)/src/mi_modulo/mi_modulo.v
export SDC_FILE      = $(DESIGN_HOME)/$(PLATFORM)/mi_modulo/constraint.sdc

# Síntesis
export ABC_AREA      = 1          # 1=área, 0=velocidad
export CORE_UTILIZATION = 55      # % uso del core
export PLACE_DENSITY    = 0.65    # Densidad de placement

# Clock gating (si el PDK lo soporta)
export CLKGATE_MAP_FILE = $(PLATFORM_DIR)/cells_clkgate.v
```

---

## 6. Orden del flujo

1. **Síntesis** (Yosys) → netlist `.v`
2. **Floorplan** → tamaño del chip, core area
3. **Placement** → posición de celdas
4. **CTS** → árbol de reloj
5. **Routing** → global + detailed
6. **Fill + merge** → GDS final

En cada etapa se usan los constraints del SDC para optimización y verificación de timing.
