set command [lindex $argv 0]

set part_name xc7a200tfbg676-2

set project_name mips_cpu_trace

set design_top soc_lite_top
set simulation_top tb_top

set script_path [file dirname [info script]]
set project_path ${script_path}/../trace_project
set project_file ${project_path}/${project_name}.xpr

set source_path ${script_path}/../src/trace
set design_path ${source_path}/design
set simulation_path ${source_path}/simulation
set constraint_path ${source_path}/constraint

set simulation_result_path ${script_path}/../sim
set wave_config_file ${simulation_result_path}/behav.wcfg

set bit_path ${script_path}/../bit
set bit_file ${bit_path}/system.bit

set report_path ${script_path}/../report
set report_synthesis_path ${report_path}/synthesis
set report_implement_path ${report_path}/implement

proc remove_prj {} {
  if {[file exists ${::project_path}]} {
    file delete -force -- ${::project_path}
  }
}

proc create {} {
  create_project ${::project_name} -force -dir ${::project_path} -part ${::part_name}
  add_project_files
}

proc open_prj {} {
  if {![file exists ${::project_path}]} {
    create
  } else {
    open_project ${::project_file}
    update_project_files
  }
}

proc add_project_files {} {
  add_files -fileset sources_1 ${::design_path}
  add_files -fileset sim_1 ${::simulation_path}
  add_files -fileset constrs_1 ${::constraint_path}
  update_top_module

}

proc update_project_files {} {
  remove_files -fileset sources_1 [get_files -of [get_filesets sources_1]]
  remove_files -fileset sim_1 [get_files -of [get_filesets sim_1]]
  remove_files -fileset constrs_1 [get_files -of [get_filesets constrs_1]]
  add_project_files
}

proc update_top_module {} {
  set_property top ${::design_top} [get_filesets sources_1]
  update_compile_order -fileset sources_1

  set_property top ${::simulation_top} [get_filesets sim_1]
  update_compile_order -fileset sim_1
}

open_prj
source ${script_path}/external.tcl

# Do simulation
set_property verilog_define "TRACE_REF_FILE=\"${simulation_result_path}/trace.txt\"" [get_filesets sim_1]
set_property target_simulator "XSim" [current_project]
launch_simulation -mode behavioral
run -all
