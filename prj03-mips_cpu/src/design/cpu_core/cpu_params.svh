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
  export cpu_core_params::CPU_DATA_WIDTH;

  typedef struct packed {
    logic valid;
    ProgramCount program_count;
    CpuData multi_use_register_value;
    CpuData source_register_value;
    logic [15:0] immediate;
    logic [4:0] destination_register;
    logic memory_write;
    logic [4:0] memory_io_type;
    logic memory_io_unsigned;
    logic register_write;
    logic source2_is_8;
    logic source2_is_immediate;
    logic source2_is_unsigned;
    logic source1_is_program_count;
    logic source1_is_shift_amount;
    logic is_load_operation;
    logic multiply_valid;
    logic divide_valid;
    logic multiply_divide_signed;
    logic result_high;
    logic result_low;
    logic high_low_write;
    logic [11:0] alu_operation;
  } IDToEXDecodeBusData;

  typedef struct packed {
    logic taken;
    CpuData target;
  } IDToIFBranchBusData ;
endpackage : id_stage_params

package multiplier_params;
  import cpu_core_params::*;
  export cpu_core_params::CpuData;
  export cpu_core_params::CPU_DATA_WIDTH;

  typedef logic [CPU_DATA_WIDTH * 2 - 1:0] MultiplyResultData;

  typedef struct {
     logic [CPU_DATA_WIDTH / 2:0] wallace_input [CPU_DATA_WIDTH * 2];
     logic [CPU_DATA_WIDTH / 2:0] carry_input;
  } Stage1ToStage2BusData;
endpackage : multiplier_params

package divider_params;
  import cpu_core_params::*;
  export cpu_core_params::CpuData;
  export cpu_core_params::CPU_DATA_WIDTH;
  
  typedef enum bit [1:0] {
    WAITING_STATE = 2'b00,
    LOAD_STATE = 2'b01,
    DIVIDE_STATE = 2'b10,
    RETURN_STATE = 2'b11
  } State;
endpackage: divider_params

package ex_stage_params;
  import cpu_core_params::*;
  export cpu_core_params::CpuData;
  export cpu_core_params::ProgramCount;

  typedef struct packed {
    logic valid;
    logic data_valid;
    logic [4:0] write_register;
    CpuData write_data;
  } EXToIDBackPassData;

  typedef struct packed {
    logic valid;
    ProgramCount program_count;
    CpuData alu_result;
    CpuData source_register_data;
    logic [4:0] destination_register;
    logic register_write;
    logic [1:0] memory_address_final;
    logic is_load_left;
    logic is_load_right;
    logic is_load_half_word;
    logic is_load_byte;
    logic memory_io_unsigned;
    logic result_is_from_memory;
    logic multiply_valid;
    multiplier_params::MultiplyResultData multiply_result;
    logic divide_valid;
    logic divide_result_valid;
    CpuData divide_result;
    CpuData divide_remain;
    logic result_high;
    logic result_low;
    logic high_low_write;
  } EXToIOData;
endpackage : ex_stage_params

package io_stage_params;
  import cpu_core_params::*;
  export cpu_core_params::CpuData;
  export cpu_core_params::ProgramCount;
  export cpu_core_params::CPU_DATA_WIDTH;

  typedef struct packed {
    logic valid;
    logic [4:0] write_register;
    logic [3:0] write_strobe;
    CpuData write_data;
    logic previous_valid;
    logic [4:0] previous_write_register;
    CpuData previous_write_data;
  } IOToIDBackPassData;

  typedef struct packed {
    logic valid;
    ProgramCount program_count;
    CpuData final_result;
    logic [4:0] register_file_address;
    logic register_file_write_enabled;
    logic [3:0] register_file_write_strobe;
  } IOToWBData;
endpackage : io_stage_params

package wb_stage_params;
  import cpu_core_params::*;
  export cpu_core_params::CpuData;
  export cpu_core_params::ProgramCount;

  typedef struct packed {
    logic valid;
    logic [4:0] write_register;
    logic [3:0] write_strobe;
    CpuData write_data;
  } WBToIDBackPassData;

  typedef struct packed {
    logic write_enabled;
    logic [4:0] write_address;
    logic [3:0] write_strobe;
    CpuData write_data;
  } WBToRegisterFileData;
endpackage : wb_stage_params

`endif