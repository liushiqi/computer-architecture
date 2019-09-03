set command [lindex $argv 0]

set part_name xc7a200tfbg676-2

set project_name mips_cpu

set script_path [file dirname [info script]]
set project_path ${script_path}/../project
set project_file ${project_path}/${project_name}.xpr

set source_path ${script_path}/../src
set design_path ${source_path}/design
set simulation_path ${source_path}/simulation
set constraint_path ${source_path}/constraint

set simulation_result_path ${script_path}/../simulation
set wave_config_file ${simulation_result_path}/behav.wcfg
set wave_database_file ${simulation_result_path}/behav.wdb

proc remove_prj {} {
  if {[file exists ${::project_path}]} {
    file delete -force -- ${::project_path}
  }
}

proc create {} {
  remove_prj
  create_project ${::project_name} -force -dir ${::project_path} -part ${::part_name}
  add_project_files
}

proc open_prj {} {
  open_project ${::project_file}
}

proc add_project_files {} {
  remove_files -fileset sources_1 [get_files -of [get_filesets sources_1]]
  remove_files -fileset sim_1 [get_files -of [get_filesets sim_1]]
  remove_files -fileset constrs_1 [get_files -of [get_filesets constrs_1]]

  add_files -norecurse -fileset sources_1 ${::design_path}
  add_files -norecurse -fileset sim_1 ${::simulation_path}
  add_files -norecurse -fileset constrs_1 ${::constraint_path}
  update_top_module
}

proc update_top_module {} {
  set_property top led [get_filesets sources_1]
  update_compile_order -fileset sources_1

  set_property top testbench [get_filesets sim_1]
  update_compile_order -fileset sim_1
}

if {${command} == "create"} {
  create
} elseif {${command} == "open"} {
  if {![file exists $project_path]} {
    create
  } else {
    open_prj
  }
  add_project_files
  start_gui
} elseif {${command} == "load_src"} {
  open_prj
  add_project_files
} elseif {${command} == "sim"} {
  # TODO
}