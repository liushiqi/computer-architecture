`include "cpu_params.svh"

module if_stage (
  input clock,
  input reset,
  // id allows in
  input id_allow_in,
  // branch bus
  input id_stage_params::IDToIFBranchBusData id_to_if_branch_bus,
  // to id
  output if_stage_params::IFToIDInstructionBusData if_to_id_instruction_bus,
  // instruction sram interface
  output instruction_ram_enabled,
  output [3:0] instruction_ram_write_strobe,
  output cpu_core_params::Address instruction_ram_address,
  output cpu_core_params::CpuData instruction_ram_write_data,
  input cpu_core_params::CpuData instruction_ram_read_data
);
  import if_stage_params::*;
  reg if_valid;
  wire if_ready_go;
  wire if_allow_in;
  wire to_if_valid;
  wire if_to_id_valid;

  ProgramCount sequence_program_count;
  ProgramCount next_program_count;

  CpuData if_instruction;
  CpuData if_program_count; // reg
  assign if_to_id_instruction_bus = '{
    valid: if_to_id_valid,
    program_count: if_program_count,
    instruction: if_instruction
  };

  // pre-if stage
  assign to_if_valid = ~reset;
  assign sequence_program_count = if_program_count + 3'h4;
  assign next_program_count = id_to_if_branch_bus.taken ? id_to_if_branch_bus.target : sequence_program_count;

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

  assign instruction_ram_enabled = to_if_valid && if_allow_in;
  assign instruction_ram_write_strobe = 4'h0;
  assign instruction_ram_address = next_program_count;
  assign instruction_ram_write_data = 32'b0;

  assign if_instruction = instruction_ram_read_data;
endmodule: if_stage
