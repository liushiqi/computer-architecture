namespace eval bram_values {
	set ip_gen_loc ${::project_path}/${::project_name}.srcs/sources_1/ip
}

set ip_name block_ram
if {![file exists ${bram_values::ip_gen_loc}/${ip_name}/${ip_name}.xci]} {
  create_ip -vlnv xilinx.com:ip:blk_mem_gen -module_name ${ip_name}
  set_property -dict [list CONFIG.Write_Width_A {32} \
                           CONFIG.Write_Depth_A {65536} \
                           CONFIG.Read_Width_A {32} \
                           CONFIG.Enable_A {Always_Enabled} \
                           CONFIG.Write_Width_B {32} \
                           CONFIG.Read_Width_B {32} \
                           CONFIG.Register_PortA_Output_of_Memory_Primitives {false}] [get_ips ${ip_name}]
  validate_ip -save_ip [get_ips ${ip_name}]
  generate_target all [get_files ${bram_values::ip_gen_loc}/${ip_name}/${ip_name}.xci]
  create_fileset -blockset ${ip_name} -define_from ${ip_name}
}
