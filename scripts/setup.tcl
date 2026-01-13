create_project proj ./proj -force

add_files -fileset sources_1 [glob src/*.vhd]
add_files -fileset sim_1 [glob sim/*.vhd]

set_property top comp_sim [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

close_project
