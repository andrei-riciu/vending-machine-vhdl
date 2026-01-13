#!/usr/bin/env tclsh
# Vivado TCL script: create project and run VHDL simulation
# Usage (from project root):
#   vivado -mode batch -source vhdl/run_vivado_sim.tcl

# --- Configuration (edit if needed) ---
set proj_name "vending_sim"
set proj_dir "./vivado_${proj_name}"
set sim_time "100 us"    ;# simulation run time (e.g. 100 us, 100ns, 1 ms)
set top_tb "vending_machine_tb"  ;# top-level testbench entity name

# --- Create project directory ---
if {![file exists $proj_dir]} {
    file mkdir $proj_dir
}

# Create a fresh project (force overwrite if exists)
create_project $proj_name $proj_dir -force

# Add VHDL source files (adjust paths if your layout differs)
add_files -norecurse {vhdl/vending_machine.vhd vhdl/vending_machine_tb.vhd}

# Ensure compile order is updated for sources
update_compile_order -fileset sources_1

# Set the top-level to the testbench entity (change $top_tb if needed)
# If this fails, change the fileset name to "sim_1" or adjust the entity name.
set_property top $top_tb [get_filesets sources_1]

# Launch the simulator, run for configured time, then exit
launch_simulation
run $sim_time

# Close Vivado (returns control to shell)
quit
