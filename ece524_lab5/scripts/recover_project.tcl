# Run from a fresh Vivado session; do not open the crashing XPR first.
# Creates a separate project while retaining the existing RTL and scripts.
set root [file normalize [file join [file dirname [info script]] ..]]
if {[current_project -quiet] ne ""} {
    error "Close the currently open project before running recovery."
}
set recovery_dir [file join $root recovered_lab5]
if {[file exists $recovery_dir]} {
    error "recovered_lab5 already exists. Open its XPR, or rename that folder before retrying recovery."
}
set src [file join $root ece524_lab5.srcs sources_1 new]
set tb [file join $root ece524_lab5.srcs sim_1 new tb_fir.v]
set xdc [file join $root ece524_lab5.srcs constrs_1 new Zedboard-Master.xdc]
foreach path [list $tb $xdc [file join $src main.v] [file join $src fir_parallel.v] [file join $src fir_serial.v] [file join $src fir_defs.vh]] {
    if {![file isfile $path]} { error "Missing source: $path" }
}
puts "Recovery: creating a fresh project without loading the original XPR or IP."
create_project ece524_lab5 $recovery_dir -part xc7z020clg484-3
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
foreach name {main.v fir_parallel.v fir_serial.v fir_defs.vh} {
    add_files -norecurse [file join $src $name]
}
set_property file_type {Verilog Header} [get_files [file join $src fir_defs.vh]]
add_files -fileset sim_1 -norecurse $tb
add_files -fileset constrs_1 -norecurse $xdc
foreach fileset {sources_1 sim_1} {
    set_property include_dirs [list $src] [get_filesets $fileset]
}
set_property top main [get_filesets sources_1]
set_property top tb_fir [get_filesets sim_1]
set_property generic {ARCH=0} [get_filesets sources_1]
set_property generic {ARCH=0 TEST_CASE=0 USE_DDS=0} [get_filesets sim_1]
set_property xsim.simulate.runtime 3ms [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "Recovery project created: [file join $recovery_dir ece524_lab5.xpr]"
puts "First test: launch_simulation (parallel impulse, no vendor IP required)."
puts "After that succeeds, close_sim and source [file join $root scripts setup_lab5.tcl] to generate the full lab IP."
