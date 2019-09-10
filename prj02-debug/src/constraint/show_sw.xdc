#set_property SEVERITY {Warning} [get_drc_checks RTSTAT-2]
#时钟信号连接
set_property PACKAGE_PIN AC19 [get_ports clock]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets clock]
create_clock -period 10.000 -name clock -waveform {0.000 5.000} [get_ports clock]

#reset
set_property PACKAGE_PIN Y3 [get_ports reset_]

#LED
set_property PACKAGE_PIN K23 [get_ports {led[0]}]
set_property PACKAGE_PIN J21 [get_ports {led[1]}]
set_property PACKAGE_PIN H23 [get_ports {led[2]}]
set_property PACKAGE_PIN J19 [get_ports {led[3]}]

#NUM
set_property PACKAGE_PIN D3  [get_ports {num_selector_[7]}]
set_property PACKAGE_PIN D25 [get_ports {num_selector_[6]}]
set_property PACKAGE_PIN D26 [get_ports {num_selector_[5]}]
set_property PACKAGE_PIN E25 [get_ports {num_selector_[4]}]
set_property PACKAGE_PIN E26 [get_ports {num_selector_[3]}]
set_property PACKAGE_PIN G25 [get_ports {num_selector_[2]}]
set_property PACKAGE_PIN G26 [get_ports {num_selector_[1]}]
set_property PACKAGE_PIN H26 [get_ports {num_selector_[0]}]

set_property PACKAGE_PIN C3 [get_ports {num_output[0]}]
set_property PACKAGE_PIN E6 [get_ports {num_output[1]}]
set_property PACKAGE_PIN B2 [get_ports {num_output[2]}]
set_property PACKAGE_PIN B4 [get_ports {num_output[3]}]
set_property PACKAGE_PIN E5 [get_ports {num_output[4]}]
set_property PACKAGE_PIN D4 [get_ports {num_output[5]}]
set_property PACKAGE_PIN A2 [get_ports {num_output[6]}]
#set_property PACKAGE_PIN C4 :DP

#switch_
set_property PACKAGE_PIN AB6  [get_ports {switch_[3]}]
set_property PACKAGE_PIN W6   [get_ports {switch_[2]}]
set_property PACKAGE_PIN AA7  [get_ports {switch_[1]}]
set_property PACKAGE_PIN Y6   [get_ports {switch_[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports clock]
set_property IOSTANDARD LVCMOS33 [get_ports reset_]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {num_output[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {num_selector_[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switch_[*]}]
