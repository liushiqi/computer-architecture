set command [lindex $argv 0]

set part_name xc7a200tfbg676-2

set project_name mips_cpu

set design_top axi_ifc_top
set simulation_top axi_testbench

set script_path [file dirname [info script]]
set project_path ${script_path}/../project
set project_file ${project_path}/${project_name}.xpr

set source_path ${script_path}/../src
set design_path ${source_path}/design
set simulation_path ${source_path}/simulation
set constraint_path ${source_path}/constraint

set sim_name behav

set simulation_result_path ${script_path}/../sim

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

proc get_files_in_dir {dirs} {
  set files []
  foreach dir $dirs {
    foreach file [glob -directory $dir *] {
      if {[file isfile $file]} {
        append files [format "%s " $file]
      } else {
        set result [get_files $file]
        foreach f $result {
          append files [format "%s " $f]
        }
      }
    }
  }
  return $files
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

proc generate_bitstream {} {
  file mkdir ${::bit_path}
  file mkdir ${::report_path}
  file mkdir ${::report_synthesis_path}
  file mkdir ${::report_implement_path}

  # setting Synthesis options
  set_property strategy {Vivado Synthesis defaults} [get_runs synth_1]
  # keep module port names in the netlist
  set_property steps.synth_design.args.flatten_hierarchy {none} [get_runs synth_1]

  # setting Implementation options
  set_property steps.phys_opt_design.is_enabled true [get_runs impl_1]
  # the following implementation options will increase runtime, but get the best timing results
  set_property strategy Performance_Explore [get_runs impl_1]

  # Synthesizing design
  synth_design -top ${::design_top} -part ${::part_name} -flatten_hierarchy none
  # Design optimization
  opt_design

  # Output utilization and timing reports.
  report_utilization -hierarchical -file ${::report_synthesis_path}/utilization.rpt
  report_timing_summary -delay_type max -max_paths 10 -file ${::report_synthesis_path}/timing.rpt
  report_clock_utilization -file ${::report_synthesis_path}/clock_util.rpt

  # Placement
  place_design
  # Physical design optimization
  phys_opt_design

  # Output utilization and timing reports.
  report_utilization -hierarchical -file ${::report_implement_path}/post_place_utilization.rpt
  report_timing_summary -delay_type max -max_paths 10 -file ${::report_implement_path}/post_place_timing.rpt
  report_clock_utilization -file ${::report_implement_path}/post_place_clock_util.rpt

  # routing
  route_design

  # Output utilization and timing reports.
  report_utilization -hierarchical -file ${::report_implement_path}/post_route_utilization.rpt
  report_timing_summary -delay_type max -max_paths 10 -file ${::report_implement_path}/post_route_timing.rpt
  report_clock_utilization -file ${::report_implement_path}/post_route_clock_util.rpt

  if {${::command} == "bitstream"} {
    # bitstream generation
    write_bitstream -force ${::bit_file}
  }
}

proc number_of_cpus {} {
  # Windows puts it in an environment variable
  global tcl_platform env
  if {$tcl_platform(platform) eq "windows"} {
    return $env(NUMBER_OF_PROCESSORS)
  }

  # Check for sysctl (OSX, BSD)
  set sysctl [auto_execok "sysctl"]
  if {[llength $sysctl]} {
    if {![catch {exec {*}$sysctl -n "hw.ncpu"} cores]} {
      return $cores
    }
  }

  # Assume Linux, which has /proc/cpuinfo, but be careful
  if {![catch {open "/proc/cpuinfo"} f]} {
    set cores [regexp -all -line {^processor\s} [read $f]]
    close $f
    if {$cores > 0} {
      return $cores
    }
  }

  return -1;
}

set max_process [number_of_cpus]

open_prj
source ${script_path}/external.tcl

if {${command} == "open"} {
  start_gui
} elseif {${command} == "simulation"} {
  set wave_config_file ${simulation_result_path}/${sim_name}.wcfg
  # Create sim path
  if {![file exists ${wave_config_file}]} {
    file mkdir ${simulation_result_path}
    file copy ${script_path}/wcfg/behav.wcfg ${wave_config_file}
  }
  add_files -norecurse -fileset sim_1 ${wave_config_file}

  # Do simulation
  set_property verilog_define "TRACE_REF_FILE=\"${simulation_result_path}/trace.txt\"" [get_filesets sim_1]
  set_property target_simulator "XSim" [current_project]
  set_property xsim.view ${wave_config_file} [get_filesets sim_1]
  launch_simulation -mode behavioral
  run -all
  start_gui
} elseif {${command} == "bitstream" || ${command} == "implementation"} {
  generate_bitstream
} elseif {${command} == "board"} {
  open_hw
  connect_hw_server
  open_hw_target
  set_property program.file ${bit_file} [get_hw_devices *]
  program_hw_devices
  close_hw
}
