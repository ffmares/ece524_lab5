# Run setup_lab5.tcl first. Produces all nine required cases plus stress tests.
set root [file normalize [file join [file dirname [info script]] ..]]
foreach ip_name {fir_compiler_0 dds_500k dds_1600k} {
    if {[llength [get_ips -quiet $ip_name]] != 1} {
        error "Missing required IP $ip_name. Run $root/scripts/setup_lab5.tcl successfully before starting simulations."
    }
}
file mkdir [file join $root results]
set simset [get_filesets sim_1]
set old_runtime [get_property xsim.simulate.runtime $simset]
set_property xsim.simulate.runtime 0ns $simset
foreach arch {0 1 2} {
    foreach test {0 1 2 3} {
        set_property generic [list ARCH=$arch TEST_CASE=$test USE_DDS=1] $simset
        launch_simulation
        # Discover the live HDL objects instead of assuming a /tb_fir scope.
        # Resolve before running so a lookup problem cannot waste a full case.
        set received_objects [get_objects -quiet -r -filter {NAME =~ *received} /*]
        set passed_objects [get_objects -quiet -r -filter {NAME =~ *passed} /*]
        if {[llength $received_objects] != 1 || [llength $passed_objects] != 1} {
            set_property xsim.simulate.runtime $old_runtime $simset
            error "Cannot uniquely locate testbench counters. HDL scopes: [get_scopes -r /*]; received: $received_objects; passed: $passed_objects"
        }
        puts "Checking HDL objects: $received_objects and $passed_objects"
        log_wave -r /
        run all
        set actual [get_value -radix unsigned $received_objects]
        set passed [get_value -radix unsigned $passed_objects]
        if {$actual != 277 || $passed ni {TRUE true 1}} { error "Simulation failed: architecture $arch case $test; received $actual" }
        close_sim
        set dir [file join [get_property DIRECTORY [current_project]] \
            [get_property NAME [current_project]].sim sim_1 behav xsim]
        foreach name {fir_trace.csv tb_fir_behav.wdb simulate.log} {
            set path [file join $dir $name]
            if {[file exists $path]} {
                file copy -force $path [file join $root results arch${arch}_case${test}_${name}]
            }
        }
    }
}
set_property generic {ARCH=0 TEST_CASE=0 USE_DDS=1} $simset
set_property xsim.simulate.runtime $old_runtime $simset
puts "Completed the nine assignment simulations and three stress simulations."
