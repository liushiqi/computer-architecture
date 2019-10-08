proc update_coe_files {} {
  if {![file exists ${::simulation_result_path}/data_ram.coe] || ![file exists ${::simulation_result_path}/inst_ram.coe]} {
    exec make testbench
    exec make trace
  }
}

update_coe_files

namespace eval values {
  set ip_gen_loc ${::project_path}/${::project_name}.srcs/sources_1/ip
}

set ip_name clk_pll
if {![file exists ${values::ip_gen_loc}/${ip_name}/${ip_name}.xci]} {
  create_ip -vlnv xilinx.com:ip:clk_wiz -module_name ${ip_name}
  set_property -dict [list CONFIG.PRIMITIVE {PLL} \
                           CONFIG.CLKOUT2_USED {true} \
                           CONFIG.NUM_OUT_CLKS {2} \
                           CONFIG.CLK_OUT1_PORT {cpu_clk} \
                           CONFIG.CLK_OUT2_PORT {timer_clk} \
                           CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50.000} \
                           CONFIG.CLKOUT1_DRIVES {BUFG} \
                           CONFIG.CLKOUT2_DRIVES {BUFG} \
                           CONFIG.CLKOUT3_DRIVES {BUFG} \
                           CONFIG.CLKOUT4_DRIVES {BUFG} \
                           CONFIG.CLKOUT5_DRIVES {BUFG} \
                           CONFIG.CLKOUT6_DRIVES {BUFG} \
                           CONFIG.CLKOUT7_DRIVES {BUFG} \
                           CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
                           CONFIG.USE_LOCKED {false} \
                           CONFIG.USE_RESET {false} \
                           CONFIG.MMCM_DIVCLK_DIVIDE {1} \
                           CONFIG.MMCM_CLKFBOUT_MULT_F {9} \
                           CONFIG.MMCM_COMPENSATION {ZHOLD} \
                           CONFIG.MMCM_CLKOUT0_DIVIDE_F {18} \
                           CONFIG.MMCM_CLKOUT1_DIVIDE {9} \
                           CONFIG.CLKOUT1_JITTER {159.475} \
                           CONFIG.CLKOUT1_PHASE_ERROR {105.461} \
                           CONFIG.CLKOUT2_JITTER {137.681} \
                           CONFIG.CLKOUT2_PHASE_ERROR {105.461}] [get_ips ${ip_name}]
  validate_ip -save_ip [get_ips ${ip_name}]
  generate_target all [get_files ${values::ip_gen_loc}/${ip_name}/${ip_name}.xci]
  create_fileset -blockset ${ip_name} -define_from ${ip_name}
}

if {${::command} == "bitstream" || ${::command} == "implementation"} {
  synth_ip [get_ips ${ip_name}]
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

if {${::command} == "bitstream" || ${::command} == "implementation"} {
  synth_ip [get_ips ${ip_name}]
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

if {${::command} == "bitstream" || ${::command} == "implementation"} {
  synth_ip [get_ips ${ip_name}]
}

if {${::command} == "simulation"} {
  if {${::argc} >= 2} {
    set ::sim_name multiply
    set_property top [lindex ${::argv} 1] [get_filesets sim_1]
  }
}
