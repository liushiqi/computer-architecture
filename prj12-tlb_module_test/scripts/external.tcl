namespace eval values {
  set ip_gen_loc ${::project_path}/${::project_name}.srcs/sources_1/ip
}

set ip_name clk_pll
if {![file exists ${values::ip_gen_loc}/${ip_name}/${ip_name}.xci]} {
  create_ip -vlnv xilinx.com:ip:clk_wiz -module_name ${ip_name}
  set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50.000} \
                           CONFIG.USE_LOCKED {false} \
                           CONFIG.USE_RESET {false} \
                           CONFIG.MMCM_CLKOUT0_DIVIDE_F {20.000} \
                           CONFIG.CLKOUT1_JITTER {151.636}] [get_ips ${ip_name}]
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
