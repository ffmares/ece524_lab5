onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc"  -gARCH=0 -gTEST_CASE=0 -gUSE_DDS=1 -L xbip_utils_v3_0_11 -L axi_utils_v2_0_7 -L fir_compiler_v7_2_20 -L xil_defaultlib -L secureip -lib xil_defaultlib xil_defaultlib.fir_compiler_0

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {fir_compiler_0.udo}

run 1000ns

quit -force
