set_property -name {xsim.simulate.runtime} -value {400} -objects [get_filesets sim_1]

launch_simulation

set curr_wave [current_wave_config]
if { [string length $curr_wave] == 0 } {
  add_wave /
  set_property needs_save false [current_wave_config]
}

start_gui
