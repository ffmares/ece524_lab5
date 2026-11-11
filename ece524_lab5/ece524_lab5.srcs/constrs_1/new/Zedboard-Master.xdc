# Lab 5 is a filter-core simulation / out-of-context implementation project.
# The assignment specifies a 5 MHz clock (200 ns). No board pins are assigned:
# the 16-bit input and 37-bit result are core interfaces, not board switches.
create_clock -name sample_clock -period 200.000 [get_ports clk]
