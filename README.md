Configurable-Precision, Low-Power, Pipelined Floating-Point Unit (FPU)
Half-Precision (16-bit) + Single-Precision (32-bit) Unified Architecture

Author: Mohamed Adel Elshiemy
License: MIT
Technology: Verilog HDL — FPGA/ASIC Ready
Publication: Submitted to Q1 Journal

🔍 Project Overview

This repository contains the complete hardware design and implementation of a configurable-precision, low-power, pipelined Floating-Point Unit (FPU) supporting both:

Half Precision (16-bit, IEEE-754-2008 Binary16)
Single Precision (32-bit, IEEE-754-2008 Binary32)

The project demonstrates a unified, scalable, and power-aware datapath capable of executing:

Addition / Subtraction
Multiplication
Division
Comparison
Float ↔ Integer Conversions

The design integrates a pipeline-aware Control Unit, dedicated HP and SP datapaths, and modular arithmetic units, resulting in a compact yet powerful floating-point subsystem suitable for:

- High-performance embedded systems
- DSP processors
- ML accelerators
- FPGA-based scientific computing
- Low-power IoT inference engines

This repository provides the full synthesizable RTL, control unit, datapath modules, comparator logic, testbenches, and top-level integration.

=> Project Motivation

Modern computing demands flexible floating-point hardware capable of operating at multiple precisions, optimizing both:

Performance (through pipelining and parallelism)
Energy efficiency (through selective activation of HP or SP units)

The proposed architecture enables dynamic precision selection at runtime based on application requirements, making it ideal for:

Adaptive machine learning workloads
Mixed-precision numerical solvers
Scientific computing with precision tuning
FPGA-accelerated heterogeneous systems

This README serves as a complete documentation for reviewers, researchers, and engineers evaluating the proposed methodology.

=> Key Contributions

This work introduces several important contributions to floating-point hardware design:

1. Unified Multi-Precision FPU

A single architecture supports half and single precision using a shared control layer, reducing silicon area and power.

2. Low-Power Pipelined Control Unit

A 3-stage pipelined control structure selectively activates only the needed datapath, ensuring low dynamic power and reduced switching activity.

3. Configurable Precision Selection

Users and systems can dynamically select:
  00 = Half Precision  
  01 = Single Precision  

4. Modular and Scalable RTL Architecture

All arithmetic operations are implemented as fully independent, synthesizable Verilog modules.

5. Optimized Comparator Design (Gate-Level Equivalent)

Comparator designed using gate-equivalent logic instead of behavioral operators to ensure correct synthesis for low-power FPU datapaths.

6. FPGA-Validated Architecture

Tested and ready for:

- AMD Zynq UltraScale+ ZCU106
- Genesys2, Nexys 4, and other Xilinx/Intel FPGA Boards

Prposed FPU Propject Hierarchy
<img width="940" height="624" alt="README Hierarchy" src="https://github.com/user-attachments/assets/464f5c6b-62f6-4a21-8948-4612505680b2" />


System Architecture

The FPU consists of the following subsystems:

1- Half-Precision FPU datapath
- Compliant with IEEE-754 binary16
- Supports ADD/SUB/MUL/DIV/COMP
- Includes optimized mantissa normalization and rounding
- Integrated comparator with gate-level logic

2- Single-Precision FPU datapath
- IEEE-754 binary32 compliant
- Independent modules for add, mul, div, f2i, i2f
- Fast multi-stage normalization and alignment

3- Pipeline-Aware Control Unit
- Implements a 3-stage pipeline:
-------------------------------------------------------
| Stage	   |  Description                              |
|------------------------------------------------------|
| Stage 1	 |  Operand decoding + precision selection   |
| Stage 2	 |  Operation routing + datapath activation  |
| Stage 3	 |  Completion detection + result forwarding |
|------------------------------------------------------|

Outputs from the CU include:
- start_hp, start_sp
- hp_op, sp_op
- stageX_en
- out_sel
- ready

=> Unified Top-Level Integration

The top module connects the HP and SP paths and selects outputs based on precision:
- HP result is extended to 32 bits
- SP result passes directly
- Comparator outputs are directly exposed

=> How to Use the FPU

For Simulation;
Use any HDL simulator such as:
1- ModelSim / Questa
2- Xilinx Vivado Simulator
3- Synopsys VCS
4- Cadence Xcelium

Run:
- vsim work.tb_configurable_top
- run -all

or with Vivado:
- xvlog src/*.v
- xelab tb_configurable_top
- xsim tb_configurable_top -runall

=> FPGA Synthesis

The design has been validated on:
- AMD Zynq UltraScale+ ZCU106 Evaluation Board

To synthesize:
- vivado -mode tcl -source scripts/build_fpu.tcl

📊 Performance Summary
------------------------------------------------------------
Feature	             | Half Precision	  |   Single Precision
------------------------------------------------------------
Latency	             | 2–3 cycles	       |  3–6 cycles
Max Frequency	       | 120–150 MHz	      | 100–120 MHz
Area	                | Very Low	         |  Moderate
Power	Ultra          | Low	              |  Low
IEEE-754 Compliance	 | Yes	              |  YEs

Actual numbers depend on selected FPGA and synthesis constraints.


Contributions
Contributions are welcome, especially in:

- Pipeline extension
- More precision formats (bfloat16, FP8)
- Better rounding modes
- Hardware acceleration libraries

Contact

Mohamed Adel Elshiemy
Email: mmilad@nu.edu.eg
