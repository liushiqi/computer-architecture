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

namespace eval values {
  set ip_gen_loc ${::project_path}/${::project_name}.srcs/sources_1/ip
}

set ip_name data_ram
if {![file exists ${values::ip_gen_loc}/${ip_name}/${ip_name}.xci]} {
  create_ip -vlnv xilinx.com:ip:blk_mem_gen -module_name ${ip_name}
  set_property -dict [list CONFIG.Use_Byte_Write_Enable {true} \
                           CONFIG.Byte_Size {8} \
                           CONFIG.Write_Width_A {32} \
                           CONFIG.Write_Depth_A {65536} \
                           CONFIG.Read_Width_A {32} \
                           CONFIG.Write_Width_B {32} \
                           CONFIG.Read_Width_B {32} \
                           CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
                           CONFIG.Load_Init_File {false} \
                           CONFIG.Coe_File {no_coe_file_loaded} \
                           CONFIG.Fill_Remaining_Memory_Locations {false} \
                           CONFIG.Remaining_Memory_Locations {0}] [get_ips ${ip_name}]
  validate_ip -save_ip [get_ips ${ip_name}]
  generate_target all [get_files ${values::ip_gen_loc}/${ip_name}/${ip_name}.xci]
  create_fileset -blockset ${ip_name} -define_from ${ip_name}
}

set ip_name inst_ram
if {![file exists ${values::ip_gen_loc}/${ip_name}/${ip_name}.xci]} {
  create_ip -vlnv xilinx.com:ip:blk_mem_gen -module_name ${ip_name}
  set_property -dict [list CONFIG.Use_Byte_Write_Enable {true} \
                           CONFIG.Byte_Size {8} \
                           CONFIG.Write_Width_A {32} \
                           CONFIG.Write_Depth_A {262144} \
                           CONFIG.Read_Width_A {32} \
                           CONFIG.Write_Width_B {32} \
                           CONFIG.Read_Width_B {32} \
                           CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
                           CONFIG.Load_Init_File {true} \
                           CONFIG.Coe_File "${::simulation_result_path}/inst_ram.coe" \
                           CONFIG.Fill_Remaining_Memory_Locations {false} \
                           CONFIG.Remaining_Memory_Locations {0}] [get_ips ${ip_name}]
  validate_ip -save_ip [get_ips ${ip_name}]
  generate_target all [get_files ${values::ip_gen_loc}/${ip_name}/${ip_name}.xci]
  create_fileset -blockset ${ip_name} -define_from ${ip_name}
}

# Do simulation
set_property verilog_define "TRACE_REF_FILE=\"${simulation_result_path}/trace.txt\"" [get_filesets sim_1]
set_property target_simulator "XSim" [current_project]
launch_simulation -mode behavioral
run -all
