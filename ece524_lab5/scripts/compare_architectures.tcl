# Run after setup_lab5.tcl. No board I/O or bitstream: compare filter cores OOC.
set root [file normalize [file join [file dirname [info script]] ..]]
set out [file join $root results]
file mkdir $out
synth_ip [get_ips fir_compiler_0]
foreach arch {0 1 2} {
    synth_design -top main -part [get_property PART [current_project]] \
        -mode out_of_context -generic ARCH=$arch
    if {[llength [get_clocks -quiet]] == 0} { create_clock -period 200 -name sample_clock [get_ports clk] }
    report_utilization -file [file join $out arch${arch}_synth_utilization.rpt]
    opt_design
    place_design
    route_design
    report_utilization -file [file join $out arch${arch}_utilization.rpt]
    report_timing_summary -file [file join $out arch${arch}_timing.rpt]
    write_checkpoint -force [file join $out arch${arch}_routed.dcp]
    close_design
}
