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

set ip_name axi_ram
if {![file exists ${values::ip_gen_loc}/${ip_name}/${ip_name}.xci]} {
  create_ip -vlnv xilinx.com:ip:blk_mem_gen -module_name ${ip_name}
  set_property -dict [list CONFIG.Component_Name {axi_ram} \
                           CONFIG.Interface_Type {AXI4} \
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

set ip_name axi_crossbar_1x2
if {![file exists ${values::ip_gen_loc}/${ip_name}/${ip_name}.xci]} {
  create_ip -vlnv xilinx.com:ip:axi_crossbar -module_name  ${ip_name}
  set_property -dict [list CONFIG.ADDR_RANGES {8} \
                           CONFIG.PROTOCOL {AXI3} \
                           CONFIG.ID_WIDTH {4} \
                           CONFIG.S00_THREAD_ID_WIDTH {4} \
                           CONFIG.S01_THREAD_ID_WIDTH {4} \
                           CONFIG.S02_THREAD_ID_WIDTH {4} \
                           CONFIG.S03_THREAD_ID_WIDTH {4} \
                           CONFIG.S04_THREAD_ID_WIDTH {4} \
                           CONFIG.S05_THREAD_ID_WIDTH {4} \
                           CONFIG.S06_THREAD_ID_WIDTH {4} \
                           CONFIG.S07_THREAD_ID_WIDTH {4} \
                           CONFIG.S08_THREAD_ID_WIDTH {4} \
                           CONFIG.S09_THREAD_ID_WIDTH {4} \
                           CONFIG.S10_THREAD_ID_WIDTH {4} \
                           CONFIG.S11_THREAD_ID_WIDTH {4} \
                           CONFIG.S12_THREAD_ID_WIDTH {4} \
                           CONFIG.S13_THREAD_ID_WIDTH {4} \
                           CONFIG.S14_THREAD_ID_WIDTH {4} \
                           CONFIG.S15_THREAD_ID_WIDTH {4} \
                           CONFIG.S00_WRITE_ACCEPTANCE {4} \
                           CONFIG.S00_READ_ACCEPTANCE {4} \
                           CONFIG.S01_BASE_ID {0x00000010} \
                           CONFIG.S02_BASE_ID {0x00000020} \
                           CONFIG.S03_BASE_ID {0x00000030} \
                           CONFIG.S04_BASE_ID {0x00000040} \
                           CONFIG.S05_BASE_ID {0x00000050} \
                           CONFIG.S06_BASE_ID {0x00000060} \
                           CONFIG.S07_BASE_ID {0x00000070} \
                           CONFIG.S08_BASE_ID {0x00000080} \
                           CONFIG.S09_BASE_ID {0x00000090} \
                           CONFIG.S10_BASE_ID {0x000000a0} \
                           CONFIG.S11_BASE_ID {0x000000b0} \
                           CONFIG.S12_BASE_ID {0x000000c0} \
                           CONFIG.S13_BASE_ID {0x000000d0} \
                           CONFIG.S14_BASE_ID {0x000000e0} \
                           CONFIG.S15_BASE_ID {0x000000f0} \
                           CONFIG.M00_A00_BASE_ADDR {0x1faf0000} \
                           CONFIG.M00_A01_BASE_ADDR {0xbfaf0000} \
                           CONFIG.M01_A00_BASE_ADDR {0x1fc00000} \
                           CONFIG.M01_A01_BASE_ADDR {0x20000000} \
                           CONFIG.M01_A02_BASE_ADDR {0x80000000} \
                           CONFIG.M01_A03_BASE_ADDR {0x40000000} \
                           CONFIG.M01_A04_BASE_ADDR {0xc0000000} \
                           CONFIG.M01_A05_BASE_ADDR {0x00000000} \
                           CONFIG.M01_A06_BASE_ADDR {0xa0000000} \
                           CONFIG.M01_A07_BASE_ADDR {0xbfc00000} \
                           CONFIG.M00_A00_ADDR_WIDTH {16} \
                           CONFIG.M00_A01_ADDR_WIDTH {16} \
                           CONFIG.M01_A00_ADDR_WIDTH {22} \
                           CONFIG.M01_A01_ADDR_WIDTH {29} \
                           CONFIG.M01_A02_ADDR_WIDTH {29} \
                           CONFIG.M01_A03_ADDR_WIDTH {30} \
                           CONFIG.M01_A04_ADDR_WIDTH {30} \
                           CONFIG.M01_A05_ADDR_WIDTH {28} \
                           CONFIG.M01_A06_ADDR_WIDTH {28} \
                           CONFIG.M01_A07_ADDR_WIDTH {22}] [get_ips ${ip_name}]
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
