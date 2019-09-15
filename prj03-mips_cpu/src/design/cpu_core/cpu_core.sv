`include "cpu_params.svh"

module cpu_core (
  input clock,
  input reset_,
  // inst sram interface
  output instruction_enabled,
  output [3:0] instruction_write_strobe,
  output [31:0] instruction_address,
  output [31:0] instruction_write_data,
  input [31:0] instruction_read_data,
  // data sram interface
  output data_enabled,
  output [3:0] data_write_enabled,
  output [31:0] data_address,
  output [31:0] data_write_data,
  input [31:0] data_read_data,
  // trace debug interface
  output [31:0] debug_program_count,
  output [3:0] debug_register_file_write_enabled,
  output [4:0] debug_register_file_write_address,
  output [31:0] debug_register_file_write_data
);
  reg reset;
  always_ff @(posedge clock) reset <= ~reset_;

  wire id_allow_in;
  wire ex_allow_in;
  wire io_allow_in;
  wire wb_allow_in;
  if_stage_params::IFToIDInstructionBusData if_to_id_instruction_bus;
  id_stage_params::IDToEXDecodeBusData id_to_ex_decode_bus;
  ex_stage_params::EXToIOData ex_to_io_bus;
  io_stage_params::IOToWBData io_to_wb_bus;
  wb_stage_params::WBToRegisterFileData wb_to_register_file_data;
  id_stage_params::IDToIFBranchBusData id_to_if_branch_bus;

// instruction fetch stage
  if_stage if_stage(
    .clock,
    .reset,
    // id allow in
    .id_allow_in,
    // branch bus
    .id_to_if_branch_bus,
    // output to id
    .if_to_id_instruction_bus,
    // instruction sram interface
    .instruction_enabled,
    .instruction_write_strobe,
    .instruction_address,
    .instruction_write_data,
    .instruction_read_data
  );

// instruction decode stage
  id_stage id_stage(
    .clock,
    .reset,
    // allow in
    .ex_allow_in,
    .id_allow_in,
    // from if stage
    .if_to_id_instruction_bus,
    //to es
    .id_to_ex_decode_bus,
    //to fs
    .id_to_if_branch_bus,
    //to rf: for write back
    .wb_to_register_file_data
  );

// execute stage
  ex_stage ex_stage(
    .clock,
    .reset,
    //allowin
    .io_allow_in,
    .ex_allow_in,
    //from ds
    .id_to_ex_decode_bus,
    //to ms
    .ex_to_io_bus,
    // data sram interface
    .data_enabled,
    .data_write_enabled,
    .data_address,
    .data_write_data
  );

// io stage
  io_state io_stage(
    .clock,
    .reset,
    // allow in
    .wb_allow_in,
    .io_allow_in,
    // from es data
    .ex_to_io_bus,
    // to io data
    .io_to_wb_bus,
    // from data sram
    .data_read_data
  );

// write back stage
  wb_stage wb_stage(
    .clock,
    .reset,
    //allowin
    .wb_allow_in,
    // from io data
    .io_to_wb_bus,
    // to register file: for write back
    .wb_to_register_file_data,
    // trace debug interface
    .debug_program_count,
    .debug_register_file_write_enabled,
    .debug_register_file_write_address,
    .debug_register_file_write_data
  );
endmodule : cpu_core
