`include "include/if_stage_params.svh"
`include "include/coprocessor_params.svh"

module if_stage(
  input clock,
  input reset,
  // id allows in
  input id_allow_in,
  // branch bus
  input id_stage_params::id_to_if_branch_bus_t id_to_if_branch_bus,
  // to id
  output if_stage_params::if_to_id_bus_t if_to_id_bus,
  // exception data
  input wb_stage_params::wb_exception_bus_t wb_exception_bus,
  input coprocessor0_params::cp0_to_if_bus_t cp0_to_if_data_bus,
  input wire if_have_exception_backwards,
  // instruction sram interface
  output instruction_ram_request,
  output instruction_ram_write,
  output [1:0] instruction_ram_size,
  output cpu_core_params::cpu_data_t instruction_ram_address,
  output cpu_core_params::cpu_data_t instruction_ram_write_data,
  output [3:0] instruction_ram_write_strobe,
  input cpu_core_params::cpu_data_t instruction_ram_read_data,
  input instruction_ram_address_ready,
  input instruction_ram_data_ready
);
  import if_stage_params::*;
  reg if_valid;
  wire if_ready_go;
  wire if_allow_in;
  wire to_if_valid;
  wire if_to_id_valid;

  wire if_have_exception;
  wire should_flush;
  wire address_exception;
  wire interrupt;
  wire [5:0] exception_code;

  program_count_t sequence_program_count;
  program_count_t next_program_count;

  cpu_data_t if_instruction;
  cpu_data_t if_program_count; // reg
  assign if_to_id_bus = '{
    valid: if_to_id_valid,
    program_count: if_program_count,
    instruction: if_instruction,
    exception_valid: !if_have_exception_backwards && if_have_exception,
    exception_code: exception_code,
    is_address_fault: address_exception,
    badvaddr_value: {32{address_exception}} & if_program_count
  };

  // pre-if stage
  assign to_if_valid = ~reset;
  assign sequence_program_count = if_program_count + 3'h4;
  assign next_program_count =
    wb_exception_bus.exception_valid ? 32'hbfc00380 :
    wb_exception_bus.eret_flush ? cp0_to_if_data_bus.exception_address :
    id_to_if_branch_bus.taken ? id_to_if_branch_bus.target : sequence_program_count;

  // if stage
  assign if_ready_go = 1'b1;
  assign if_allow_in = !if_valid || (if_ready_go && id_allow_in);
  assign if_to_id_valid = if_valid && if_ready_go;
  always_ff @(posedge clock) begin
    if (reset) begin
      if_valid <= 1'b0;
    end else if (if_allow_in) begin
      if_valid <= to_if_valid;
    end
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      if_program_count <= 32'hbfbffffc;  //trick: to make nextpc be 0xbfc00000 during reset
    end if (to_if_valid && if_allow_in) begin
      if_program_count <= next_program_count;
    end
  end

  assign address_exception = if_program_count[1:0] != 2'b00;
  assign interrupt = |cp0_to_if_data_bus.interrupt_valid;
  assign if_have_exception = address_exception | interrupt;
  assign exception_code = interrupt ? 5'h00 : address_exception ? 5'h04 : 5'h00;
  assign should_flush = if_have_exception_backwards || if_have_exception;

  assign instruction_ram_enabled = to_if_valid && if_allow_in && !(!wb_exception_bus.exception_valid && !wb_exception_bus.eret_flush && should_flush);
  assign instruction_ram_write_strobe = 4'h0;
  assign instruction_ram_address = next_program_count;
  assign instruction_ram_write_data = 32'b0;

  assign if_instruction = instruction_ram_read_data;
endmodule: if_stage
