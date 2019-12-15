`include "include/if_stage_params.svh"
`include "include/id_stage_params.svh"
`include "include/wb_stage_params.svh"
`include "include/coprocessor_params.svh"
`include "include/tlb_params.svh"

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
  // tlb interface
  output tlb_params::search_request_t tlb_request,
  input tlb_params::search_result_t tlb_result,
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

  wire to_if_address_exception;
  wire to_if_tlb_refill;
  wire to_if_tlb_invalid;
  wire to_if_exception_valid;

  wire if_have_exception;
  wire should_flush;
  reg address_exception;
  reg tlb_refill;
  reg tlb_invalid;
  wire interrupt;
  wire [5:0] exception_code;

  program_count_t sequence_program_count;
  program_count_t next_program_count;
  wire is_unmapped_space;

  reg program_count_cache_valid;
  program_count_t program_count_cache;
  program_count_t real_program_count;
  address_t translated_program_count;
  reg instruction_cache_valid;
  reg instruction_waiting;
  reg instruction_ignore;
  reg exception_valid;
  cpu_data_t instruction_cache;
  assign real_program_count = program_count_cache_valid ? program_count_cache : next_program_count;

  cpu_data_t if_instruction;
  cpu_data_t if_program_count; // reg
  assign if_to_id_bus = '{
    valid: if_to_id_valid,
    program_count: if_program_count,
    instruction: if_instruction,
    exception_valid: !if_have_exception_backwards && if_have_exception,
    exception_code: exception_code,
    is_address_fault: address_exception,
    tlb_refill: tlb_refill,
    tlb_exception: tlb_refill || tlb_invalid,
    badvaddr_value: {32{address_exception || tlb_refill || tlb_invalid}} & if_program_count
  };

  // pre-if stage
  assign to_if_valid = !reset;
  assign sequence_program_count = if_program_count + 3'h4;
  assign next_program_count =
    wb_exception_bus.tlb_refill ? 32'hbfc00200 :
    wb_exception_bus.exception_valid ? 32'hbfc00380 :
    wb_exception_bus.eret_flush ? cp0_to_if_data_bus.exception_address :
    wb_exception_bus.tlb_write_flush ? wb_exception_bus.program_count_plus4 :
    id_to_if_branch_bus.taken ? id_to_if_branch_bus.target : sequence_program_count;

  assign tlb_request = '{
    virtual_page_number: real_program_count[31:13],
    is_odd_page: real_program_count[12],
    asid: cp0_to_if_data_bus.asid
  };
  assign is_unmapped_space = real_program_count[31:30] == 2'b10;
  assign translated_program_count = is_unmapped_space ? {2'b00, real_program_count[29:0]} : {tlb_result.entry.page_frame_number, real_program_count[11:0]};

  assign to_if_address_exception = if_program_count[1:0] != 2'b00;
  assign to_if_tlb_refill = !is_unmapped_space && !tlb_result.found;
  assign to_if_tlb_invalid = !is_unmapped_space && tlb_result.found && !tlb_result.entry.is_valid;
  assign to_if_exception_valid = to_if_address_exception || to_if_tlb_refill || to_if_tlb_invalid;

  always_ff @(posedge clock) begin
    if (reset) begin
      program_count_cache_valid <= 1'b0;
    end else if (wb_exception_bus.exception_valid || wb_exception_bus.eret_flush) begin
      program_count_cache_valid <= 1'b1;
    end else if ((to_if_valid && if_allow_in) || should_flush || (exception_valid && instruction_ram_address_ready)) begin
      program_count_cache_valid <= 1'b0;
    end else if (!program_count_cache_valid) begin
      program_count_cache_valid <= 1'b1;
    end
  end

  always_ff @(posedge clock) begin
    if (!program_count_cache_valid) begin
      program_count_cache <= real_program_count;
    end
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      exception_valid <= 1'b0;
    end else if (wb_exception_bus.exception_valid || wb_exception_bus.eret_flush) begin
      exception_valid <= 1'b1;
    end else if (instruction_ram_address_ready && !instruction_ignore) begin
      exception_valid <= 1'b0;
    end
  end

  // if stage
  assign if_ready_go = ((instruction_cache_valid || (instruction_ram_data_ready && !instruction_ignore)) && (instruction_ram_address_ready || to_if_exception_valid)) || if_have_exception;
  assign if_allow_in = !if_valid || (if_ready_go && id_allow_in);
  assign if_to_id_valid = if_valid && if_ready_go;
  always_ff @(posedge clock) begin
    if (reset) begin
      if_valid <= 1'b0;
    end else if (should_flush && !if_have_exception) begin
      if_valid <= 1'b0;
    end else if (if_allow_in) begin
      if_valid <= to_if_valid;
    end
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      if_program_count <= 32'hbfbffffc;  //trick: to make nextpc be 0xbfc00000 during reset
    end else if (to_if_valid && if_allow_in) begin
      if_program_count <= real_program_count;
    end
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      instruction_cache_valid <= 1'b0;
    end else if ((if_ready_go && id_allow_in) || should_flush || exception_valid) begin
      instruction_cache_valid <= 1'b0;
    end else if (instruction_ram_data_ready && !instruction_ignore) begin
      instruction_cache_valid <= 1'b1;
    end
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      instruction_waiting <= 1'b0;
    end else if (instruction_ram_data_ready) begin
      instruction_waiting <= 1'b0;
    end else if (instruction_ram_address_ready) begin
      instruction_waiting <= 1'b1;
    end
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      instruction_ignore <= 1'b0;
    end else if (instruction_ram_data_ready) begin
      instruction_ignore <= 1'b0;
    end else if ((wb_exception_bus.exception_valid || wb_exception_bus.eret_flush) && instruction_waiting) begin
      instruction_ignore <= 1'b1;
    end
  end

  always_ff @(posedge clock) begin
    if (instruction_ram_data_ready && !instruction_ignore) begin
      instruction_cache <= instruction_ram_read_data;
    end
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      address_exception <= 1'b0;
      tlb_refill <= 1'b0;
      tlb_invalid <= 1'b0;
    end else if(if_allow_in && to_if_valid) begin
      address_exception <= to_if_address_exception;
      tlb_refill <= to_if_tlb_refill;
      tlb_invalid <= to_if_tlb_invalid;
    end
  end

  assign interrupt = |cp0_to_if_data_bus.interrupt_valid;
  assign if_have_exception = address_exception | interrupt | tlb_refill | tlb_invalid;
  assign exception_code = interrupt ? 5'h00 : (tlb_refill || tlb_invalid) ? 5'h02 : address_exception ? 5'h04 : 5'h00;
  assign should_flush = if_have_exception_backwards || if_have_exception;

  assign instruction_ram_request = !instruction_ignore && id_allow_in && (is_unmapped_space || (tlb_result.found && tlb_result.entry.is_valid)) && (wb_exception_bus.exception_valid || wb_exception_bus.eret_flush || !should_flush);
  assign instruction_ram_write = 1'b0;
  assign instruction_ram_size = 2'b10;
  assign instruction_ram_address = translated_program_count;
  assign instruction_ram_write_strobe = 4'h0;
  assign instruction_ram_write_data = 32'b0;

  assign if_instruction = instruction_cache_valid ? instruction_cache : instruction_ram_read_data;
endmodule: if_stage