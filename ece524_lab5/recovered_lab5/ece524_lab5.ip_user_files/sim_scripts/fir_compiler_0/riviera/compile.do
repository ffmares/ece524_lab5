transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xbip_utils_v3_0_11
vlib riviera/axi_utils_v2_0_7
vlib riviera/fir_compiler_v7_2_20
vlib riviera/xil_defaultlib

vmap xbip_utils_v3_0_11 riviera/xbip_utils_v3_0_11
vmap axi_utils_v2_0_7 riviera/axi_utils_v2_0_7
vmap fir_compiler_v7_2_20 riviera/fir_compiler_v7_2_20
vmap xil_defaultlib riviera/xil_defaultlib

vcom -work xbip_utils_v3_0_11 -93  -incr \
"../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_7 -93  -incr \
"../../../ipstatic/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work fir_compiler_v7_2_20 -93  -incr \
"../../../ipstatic/hdl/fir_compiler_v7_2_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../../ece524_lab5.gen/sources_1/ip/fir_compiler_0/sim/fir_compiler_0.vhd" \


