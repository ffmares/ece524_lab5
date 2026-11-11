vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xbip_utils_v3_0_11
vlib questa_lib/msim/axi_utils_v2_0_7
vlib questa_lib/msim/fir_compiler_v7_2_20
vlib questa_lib/msim/xil_defaultlib

vmap xbip_utils_v3_0_11 questa_lib/msim/xbip_utils_v3_0_11
vmap axi_utils_v2_0_7 questa_lib/msim/axi_utils_v2_0_7
vmap fir_compiler_v7_2_20 questa_lib/msim/fir_compiler_v7_2_20
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vcom -work xbip_utils_v3_0_11  -93  \
"../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_7  -93  \
"../../../ipstatic/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work fir_compiler_v7_2_20  -93  \
"../../../ipstatic/hdl/fir_compiler_v7_2_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../../ece524_lab5.gen/sources_1/ip/fir_compiler_0/sim/fir_compiler_0.vhd" \


