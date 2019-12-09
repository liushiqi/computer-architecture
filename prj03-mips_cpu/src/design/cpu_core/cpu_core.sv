`include "include/cpu_core_params.svh"
`include "include/if_stage_params.svh"
`include "include/id_stage_params.svh"
`include "include/ex_stage_params.svh"
`include "include/io_stage_params.svh"
`include "include/wb_stage_params.svh"
`include "include/coprocessor_params.svh"

module cpu_core(
  input clock,
  input reset_,
  // instruction ram interface
  output instruction_ram_request,
  output instruction_ram_write,
  output [1:0] instruction_ram_size,
  output cpu_core_params::cpu_data_t instruction_ram_address,
  output cpu_core_params::cpu_data_t instruction_ram_write_data,
  output [3:0] instruction_ram_write_strobe,
  input cpu_core_params::cpu_data_t instruction_ram_read_data,
  input instruction_ram_address_ready,
  input instruction_ram_data_ready,
  // data ram interface
  output data_ram_request,
  output data_ram_write,
  output [1:0] data_ram_size,
  output cpu_core_params::cpu_data_t data_ram_address,
  output cpu_core_params::cpu_data_t data_ram_write_data,
  output [3:0] data_ram_write_strobe,
  input cpu_core_params::cpu_data_t data_ram_read_data,
  input data_ram_address_ready,
  input data_ram_data_ready,
  // trace debug interface
  output cpu_core_params::cpu_data_t debug_program_count,
  output [3:0] debug_register_file_write_enabled,
  output [4:0] debug_register_file_write_address,
  output cpu_core_params::cpu_data_t debug_register_file_write_data,
  // interrupt
  input [5:0] hardware_interrupt
);
  import cpu_core_params::*;
  reg reset;
  always_ff @(posedge clock) reset <= ~reset_;

  wire id_allow_in;
  wire ex_allow_in;
  wire io_allow_in;
  wire wb_allow_in;
  if_stage_params::if_to_id_bus_t if_to_id_bus;

  id_stage_params::id_to_ex_bus_t id_to_ex_bus;
  id_stage_params::id_to_if_branch_bus_t id_to_if_branch_bus;

  ex_stage_params::ex_to_io_bus_t ex_to_io_bus;
  ex_stage_params::ex_to_id_back_pass_bus_t ex_to_id_back_pass_bus;

  io_stage_params::io_to_wb_bus_t io_to_wb_bus;
  io_stage_params::io_to_id_back_pass_bus_t io_to_id_back_pass_bus;

  wb_stage_params::wb_to_register_file_bus_t wb_to_register_file_bus;
  wb_stage_params::wb_exception_bus_t wb_exception_bus;
  wb_stage_params::wb_to_id_back_pass_bus_t wb_to_id_back_pass_bus;
  wb_stage_params::wb_to_cp0_bus_t wb_to_cp0_data_bus;

  coprocessor0_params::cp0_to_if_bus_t cp0_to_if_data_bus;
  cpu_data_t cp0_read_data;

  tlb_params::search_request_t tlb_request1;
  tlb_params::search_result_t tlb_responce1;
  tlb_params::search_request_t tlb_request2;
  tlb_params::search_result_t tlb_responce2;
  tlb_params::search_request_t tlb_request3;
  tlb_params::search_result_t tlb_responce3;
  wire tlb_write_enabled;
  wire [$clog2(tlb_params::TLB_NUM) - 1:0] tlb_write_index;
  tlb_params::tlb_request_t tlb_write_data;
  wire [$clog2(tlb_params::TLB_NUM) - 1:0] tlb_read_index;
  tlb_params::tlb_request_t tlb_read_data;

  wire id_have_exception_forwards;
  wire ex_have_exception_forwards;
  wire io_have_exception_forwards;
  wire wb_have_exception_forwards;

  wire if_have_exception_backwards;
  wire id_have_exception_backwards;
  wire ex_have_exception_backwards;
  wire io_have_exception_backwards;

  assign if_have_exception_backwards = id_have_exception_forwards | ex_have_exception_forwards | io_have_exception_forwards;
  assign id_have_exception_backwards = ex_have_exception_forwards | io_have_exception_forwards | wb_have_exception_forwards;
  assign ex_have_exception_backwards = io_have_exception_forwards | wb_have_exception_forwards;
  assign io_have_exception_backwards = wb_have_exception_forwards;

  // instruction fetch stage
  if_stage u_if_stage(
    .clock,
    .reset,
    // id allow in
    .id_allow_in,
    // branch bus
    .id_to_if_branch_bus,
    // output to id
    .if_to_id_bus,
    // exception bus
    .wb_exception_bus,
    .cp0_to_if_data_bus,
    .if_have_exception_backwards,
    // instruction sram interface
    .instruction_ram_request,
    .instruction_ram_write,
    .instruction_ram_size,
    .instruction_ram_address,
    .instruction_ram_write_data,
    .instruction_ram_write_strobe,
    .instruction_ram_read_data,
    .instruction_ram_address_ready,
    .instruction_ram_data_ready
  );

  // instruction decode stage
  id_stage u_id_stage(
    .clock,
    .reset,
    // allow in
    .ex_allow_in,
    .id_allow_in,
    // from if stage
    .if_to_id_bus,
    // backpass
    .ex_to_id_back_pass_bus,
    .io_to_id_back_pass_bus,
    .wb_to_id_back_pass_bus,
    // to ex
    .id_to_ex_bus,
    // to if branch
    .id_to_if_branch_bus,
    // exception bus
    .wb_exception_bus,
    .id_have_exception_forwards,
    .id_have_exception_backwards,
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
    .id_to_ex_bus,
    // to id
    .ex_to_id_back_pass_bus,
    // to io
    .ex_to_io_bus,
    // exception bus
    .wb_exception_bus,
    .ex_have_exception_forwards,
    .ex_have_exception_backwards,
    // data sram interface
    .data_ram_request,
    .data_ram_write,
    .data_ram_size,
    .data_ram_address,
    .data_ram_write_data,
    .data_ram_write_strobe,
    .data_ram_address_ready
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
    .io_have_exception_forwards,
    .io_have_exception_backwards,
    // to io data
    .io_to_wb_bus,
    // from data sram
    .data_ram_read_data,
    .data_ram_data_ready
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
    .cp0_read_data,
    // exception bus
    .wb_exception_bus,
    .wb_have_exception_forwards,
    // tlb
    .tlb_write_enabled,
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
    .cp0_read_data,
    .tlb_request(tlb_request3),
    .tlb_responce(tlb_responce3),
    .tlb_read_index,
    .tlb_read_data,
    .tlb_write_index,
    .tlb_write_data,
    .hardware_interrupt
  );

  tlb u_tlb(
    .clock,
    .request1(tlb_request1),
    .responce1(tlb_responce1),
    .request2(tlb_request2),
    .responce2(tlb_responce2),
    .request3(tlb_request3),
    .responce3(tlb_responce3),
    .write_enabled(tlb_write_enabled),
    .write_index(tlb_write_index),
    .write_data(tlb_write_data),
    .read_index(tlb_read_index),
    .read_data(tlb_read_data)
  );
endmodule: cpu_core