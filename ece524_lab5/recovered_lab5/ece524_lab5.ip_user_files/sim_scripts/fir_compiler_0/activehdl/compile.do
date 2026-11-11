transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xbip_utils_v3_0_11
vlib activehdl/axi_utils_v2_0_7
vlib activehdl/fir_compiler_v7_2_20
vlib activehdl/xil_defaultlib

vmap xbip_utils_v3_0_11 activehdl/xbip_utils_v3_0_11
vmap axi_utils_v2_0_7 activehdl/axi_utils_v2_0_7
vmap fir_compiler_v7_2_20 activehdl/fir_compiler_v7_2_20
vmap xil_defaultlib activehdl/xil_defaultlib

vcom -work xbip_utils_v3_0_11 -93  \
"../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_7 -93  \
"../../../ipstatic/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work fir_compiler_v7_2_20 -93  \
"../../../ipstatic/hdl/fir_compiler_v7_2_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../../../ece524_lab5.gen/sources_1/ip/fir_compiler_0/sim/fir_compiler_0.vhd" \


