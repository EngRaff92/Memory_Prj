#!/bin/bash

# create the vcd file
touch dump.vcd
# iverlog simulation
echo "Doing Verilog simulation with iverilog"
iverilog byte_sram.sv sram_tb_top.sv -g2012 -gassertions -Wtimescale;
vvp a.out;
gtkwave sram_tb.gtkw &

## yosys synthesis
#yosys sram.ys
