`include "cpu_params.svh"
`include "coprocessor_params.svh"

module cpu_core (
  input clock,
  input reset_,
  // inst sram interface
  output instruction_ram_enabled,
  output [3:0] instruction_ram_write_strobe,
  output [31:0] instruction_ram_address,
  output [31:0] instruction_ram_write_data,
  input [31:0] instruction_ram_read_data,
  // data sram interface
  output data_ram_enabled,
  output [3:0] data_ram_write_enabled,
  output [31:0] data_ram_address,
  output [31:0] data_ram_write_data,
  input [31:0] data_ram_read_data,
  // trace debug interface
  output [31:0] debug_program_count,
  output [3:0] debug_register_file_write_enabled,
  output [4:0] debug_register_file_write_address,
  output [31:0] debug_register_file_write_data
);
  import cpu_core_params::*;
  reg reset;
  always_ff @(posedge clock) reset <= ~reset_;

  wire id_allow_in;
  wire ex_allow_in;
  wire io_allow_in;
  wire wb_allow_in;
  if_stage_params::IFToIDInstructionBusData if_to_id_instruction_bus;

  id_stage_params::IDToEXDecodeBusData id_to_ex_decode_bus;
  id_stage_params::IDToIFBranchBusData id_to_if_branch_bus;

  ex_stage_params::EXToIOData ex_to_io_bus;
  ex_stage_params::EXToIDBackPassData ex_to_id_back_pass_bus;

  io_stage_params::IOToWBData io_to_wb_bus;
  io_stage_params::IOToIDBackPassData io_to_id_back_pass_bus;

  wb_stage_params::WBToRegisterFileData wb_to_register_file_bus;
  wb_stage_params::WBExceptionBus wb_exception_bus;
  wb_stage_params::WBToIDBackPassData wb_to_id_back_pass_bus;

  coprocessor0_params::CP0ToIFData cp0_to_if_data_bus;
  coprocessor0_params::WBToCP0Data wb_to_cp0_data_bus;
  CpuData cp0_read_data;

  // instruction fetch stage
  if_stage u_if_stage(
    .clock,
    .reset,
    // id allow in
    .id_allow_in,
    // branch bus
    .id_to_if_branch_bus,
    // output to id
    .if_to_id_instruction_bus,
    // exception bus
    .wb_exception_bus,
    // instruction sram interface
    .instruction_ram_enabled,
    .instruction_ram_write_strobe,
    .instruction_ram_address,
    .instruction_ram_write_data,
    .instruction_ram_read_data
  );

  // instruction decode stage
  id_stage u_id_stage(
    .clock,
    .reset,
    // allow in
    .ex_allow_in,
    .id_allow_in,
    // from if stage
    .if_to_id_instruction_bus,
    // backpass
    .ex_to_id_back_pass_bus,
    .io_to_id_back_pass_bus,
    .wb_to_id_back_pass_bus,
    // to ex
    .id_to_ex_decode_bus,
    // to if branch
    .id_to_if_branch_bus,
    // exception bus
    .wb_exception_bus,
    //to rf: for write back
    .wb_to_register_file_bus
  );

  // execute stage
  ex_stage u_ex_stage(
    .clock,
    .reset,
    // allow in
    .io_allow_in,
    .ex_allow_in,
    // from ds
    .id_to_ex_decode_bus,
    // to id
    .ex_to_id_back_pass_bus,
    // to io
    .ex_to_io_bus,
    // exception bus
    .wb_exception_bus,
    // data sram interface
    .data_ram_enabled,
    .data_ram_write_enabled,
    .data_ram_address,
    .data_ram_write_data
  );

  // io stage
  io_state u_io_stage(
    .clock,
    .reset,
    // allow in
    .wb_allow_in,
    .io_allow_in,
    // from es data
    .ex_to_io_bus,
    // to id backpass
    .io_to_id_back_pass_bus,
    // exception bus
    .wb_exception_bus,
    // to io data
    .io_to_wb_bus,
    // from data sram
    .data_ram_read_data
  );

  // write back stage
  wb_stage u_wb_stage(
    .clock,
    .reset,
    //allowin
    .wb_allow_in,
    // from io data
    .io_to_wb_bus,
    // to id backpass
    .wb_to_id_back_pass_bus,
    // to register file: for write back
    .wb_to_register_file_bus,
    // to cp0 write data
    .wb_to_cp0_data_bus,
    // exception bus
    .wb_exception_bus,
    // trace debug interface
    .debug_program_count,
    .debug_register_file_write_enabled,
    .debug_register_file_write_address,
    .debug_register_file_write_data
  );

  coprocessor0 u_coprocessor0(
    .clock,
    .reset,
    .wb_to_cp0_data_bus,
    .cp0_to_if_data_bus,
    .cp0_read_data
  );
endmodule : cpu_core
