transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+fir_compiler_0  -gARCH=0 -gTEST_CASE=0 -gUSE_DDS=1 -L xbip_utils_v3_0_11 -L axi_utils_v2_0_7 -L fir_compiler_v7_2_20 -L xil_defaultlib -L secureip -O5 xil_defaultlib.fir_compiler_0

do {fir_compiler_0.udo}

run 1000ns

endsim

quit -force
