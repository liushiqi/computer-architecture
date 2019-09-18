`ifndef CPU_PARAMS
`define CPU_PARAMS

package cpu_core_params;
  parameter CPU_DATA_WIDTH = 32;

  typedef logic [CPU_DATA_WIDTH - 1:0] CpuData;
  typedef CpuData Address;
  typedef CpuData ProgramCount;
endpackage : cpu_core_params

package if_stage_params;
  import cpu_core_params::*;
  export cpu_core_params::Address;
  export cpu_core_params::CpuData;
  export cpu_core_params::ProgramCount;

  typedef struct packed {
    logic valid;
    ProgramCount program_count;
    CpuData instruction;
  } IFToIDInstructionBusData;
endpackage : if_stage_params

package id_stage_params;
  import cpu_core_params::*;
  export cpu_core_params::CpuData;
  export cpu_core_params::ProgramCount;

  typedef struct packed {
    logic valid;
    ProgramCount program_count;
    CpuData multi_use_register_value;
    CpuData source_register_value;
    logic [15:0] immediate;
    logic [4:0] destination_register;
    logic memory_write;
    logic register_write;
    logic source2_is_8;
    logic source2_is_immediate;
    logic source1_is_program_count;
    logic source1_is_shift_amount;
    logic is_load_operation;
    logic [11:0] alu_operation;
  } IDToEXDecodeBusData;

  typedef struct packed {
    logic taken;
    CpuData target;
  } IDToIFBranchBusData ;
endpackage : id_stage_params

package ex_stage_params;
  import cpu_core_params::*;
  export cpu_core_params::CpuData;
  export cpu_core_params::ProgramCount;

  typedef struct packed {
    logic valid;
    logic [4:0] write_register;
    CpuData write_data;
  } EXToIDBackPassData;

  typedef struct packed {
    logic valid;
    ProgramCount program_count;
    CpuData alu_result;
    logic [4:0] destination_register;
    logic register_write;
    logic result_is_from_memory;
  } EXToIOData;
endpackage : ex_stage_params

package io_stage_params;
  import cpu_core_params::*;
  export cpu_core_params::ProgramCount;

  typedef struct packed {
    logic valid;
    logic [4:0] write_register;
    CpuData write_data;
  } IOToIDBackPassData;

  typedef struct packed {
    logic valid;
    ProgramCount program_count;
    CpuData final_result;
    logic [4:0] register_file_address;
    logic register_file_write_enabled;
  } IOToWBData;
endpackage : io_stage_params

package wb_stage_params;
  import cpu_core_params::*;
  export cpu_core_params::CpuData;
  export cpu_core_params::ProgramCount;

  typedef struct packed {
    logic valid;
    logic [4:0] write_register;
    CpuData write_data;
  } WBToIDBackPassData;

  typedef struct packed {
    logic write_enabled;
    logic [4:0] write_address;
    CpuData write_data;
  } WBToRegisterFileData;
endpackage : wb_stage_params

`endif