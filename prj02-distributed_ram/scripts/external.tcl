namespace eval bram_values {
	set ip_gen_loc ${::project_path}/${::project_name}.srcs/sources_1/ip
}

set ip_name distributed_ram
if {![file exists ${bram_values::ip_gen_loc}/${ip_name}/${ip_name}.xci]} {
  create_ip -vlnv xilinx.com:ip:dist_mem_gen -module_name ${ip_name}
  set_property -dict [list CONFIG.depth {65536} \
                           CONFIG.data_width {32}] [get_ips ${ip_name}]
  validate_ip -save_ip [get_ips ${ip_name}]
  generate_target all [get_files ${bram_values::ip_gen_loc}/${ip_name}/${ip_name}.xci]
  create_fileset -blockset ${ip_name} -define_from ${ip_name}
}

if {${::command} == "bitstream" || ${::command} == "implementation"} {
  synth_ip [get_ips ${ip_name}]
}
