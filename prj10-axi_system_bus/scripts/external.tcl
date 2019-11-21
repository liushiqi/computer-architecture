namespace eval values {
  set ip_gen_loc ${::project_path}/${::project_name}.srcs/sources_1/ip
}

set ip_name axi_ram
if {![file exists ${values::ip_gen_loc}/${ip_name}/${ip_name}.xci]} {
  create_ip -vlnv xilinx.com:ip:blk_mem_gen -module_name ${ip_name}
  set_property -dict [list CONFIG.Interface_Type {AXI4} \
                           CONFIG.AXI_Type {AXI4_Full} \
                           CONFIG.Use_AXI_ID {true} \
                           CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
                           CONFIG.Use_Byte_Write_Enable {true} \
                           CONFIG.Byte_Size {8} \
                           CONFIG.Assume_Synchronous_Clk {true} \
                           CONFIG.Write_Width_A {32} \
                           CONFIG.Write_Depth_A {262144} \
                           CONFIG.Read_Width_A {32} \
                           CONFIG.Operating_Mode_A {READ_FIRST} \
                           CONFIG.Write_Width_B {32} \
                           CONFIG.Read_Width_B {32} \
                           CONFIG.Operating_Mode_B {READ_FIRST} \
                           CONFIG.Enable_B {Use_ENB_Pin} \
                           CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
                           CONFIG.Load_Init_File {true} \
                           CONFIG.Coe_File "${::simulation_result_path}/axi_ram.coe" \
                           CONFIG.Fill_Remaining_Memory_Locations {true} \
                           CONFIG.Use_RSTB_Pin {true} \
                           CONFIG.Reset_Type {ASYNC} \
                           CONFIG.Additional_Inputs_for_Power_Estimation {false} \
                           CONFIG.Port_B_Clock {100} \
                           CONFIG.Port_B_Enable_Rate {100} \
                           CONFIG.EN_SAFETY_CKT {false}] [get_ips ${ip_name}]
  validate_ip -save_ip [get_ips ${ip_name}]
  generate_target all [get_files ${values::ip_gen_loc}/${ip_name}/${ip_name}.xci]
  create_fileset -blockset ${ip_name} -define_from ${ip_name}
}

if {${::command} == "bitstream" || ${::command} == "implementation"} {
  synth_ip [get_ips ${ip_name}]
}

if {${::command} == "simulation"} {
  if {${::argc} >= 2} {
    set name [lindex ${::argv} 1]
    set ::sim_name ${name}_behav
    set_property top ${name}_testbench [get_filesets sim_1]
  }
}
