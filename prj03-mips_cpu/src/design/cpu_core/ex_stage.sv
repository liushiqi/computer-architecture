`include "cpu_params.svh"

module ex_stage (
  input clock,
  input reset,
  // allow in
  input io_allow_in,
  output ex_allow_in,
  // from id instructoin decode data
  input id_stage_params::IDToEXDecodeBusData id_to_ex_decode_bus,
  // backpass data
  output ex_stage_params::EXToIDBackPassData ex_to_id_back_pass_bus,
  // exception data
  input wb_stage_params::WBExceptionBus wb_exception_bus,
  output wire ex_have_exception_forwards,
  input wire ex_have_exception_backwards,
  // to io data
  output ex_stage_params::EXToIOData ex_to_io_bus,
  // data sram interface
  output data_ram_enabled,
  output [3:0] data_ram_write_enabled,
  output [31:0] data_ram_address,
  output [31:0] data_ram_write_data
);
  import ex_stage_params::*;
  reg ex_valid;
  wire ex_ready_go;
  wire ex_to_io_valid;

  wire ex_have_exception;
  wire should_flush;
  wire [5:0] exception_code;
  wire address_exception;
  wire overflow_exception;
  wire alu_overflow;

  id_stage_params::IDToEXDecodeBusData from_id_data; // reg
  ProgramCount ex_program_count;
  assign ex_program_count = from_id_data.program_count;

  wire [31:0] alu_input1;
  wire [31:0] alu_input2;
  wire [31:0] alu_result;

  multiplier_params::MultiplyResultData multiply_result;
  wire divide_result_valid;
  CpuData divide_result;
  CpuData divide_remain;

  wire result_is_from_memory;

  assign result_is_from_memory = from_id_data.is_load_operation;
  assign ex_to_io_bus = '{
    valid: ex_to_io_valid,
    program_count: ex_program_count,
    alu_result: alu_result,
    source_register_data: from_id_data.source_register_value,
    multi_use_register_data: from_id_data.multi_use_register_value,
    write_register: from_id_data.write_register,
    destination_register: from_id_data.destination_register,
    multi_use_register: from_id_data.multi_use_register,
    address_select: from_id_data.address_select,
    register_write: from_id_data.register_write,
    memory_address: alu_result,
    is_load_left: from_id_data.memory_io_type[3],
    is_load_right: from_id_data.memory_io_type[1],
    is_load_word: from_id_data.memory_io_type[4],
    is_load_half_word: from_id_data.memory_io_type[2],
    is_load_byte: from_id_data.memory_io_type[0],
    memory_io_unsigned: from_id_data.memory_io_unsigned,
    result_is_from_memory: result_is_from_memory,
    multiply_valid: from_id_data.multiply_valid,
    multiply_result: multiply_result,
    divide_valid: from_id_data.divide_valid,
    divide_result_valid: divide_result_valid,
    divide_result: divide_result,
    divide_remain: divide_remain,
    result_high: from_id_data.result_high,
    result_low: from_id_data.result_low,
    high_low_write: from_id_data.high_low_write,
    move_from_cp0: from_id_data.move_from_cp0,
    move_to_cp0: from_id_data.move_to_cp0,
    exception_valid: from_id_data.exception_valid || ex_have_exception,
    in_delay_slot: from_id_data.in_delay_slot,
    eret_flush: from_id_data.eret_flush,
    exception_code: exception_code,
    is_address_fault: from_id_data.is_address_fault | address_exception,
    badvaddr_value: (from_id_data.is_address_fault ? from_id_data.badvaddr_value : address_exception ? alu_result : 32'b0)
  };

  wire [4:0] backpass_address;
  assign backpass_address = {5{from_id_data.register_write & ex_valid}} & from_id_data.write_register;
  assign ex_to_id_back_pass_bus = '{
    valid: from_id_data.register_write & ex_valid,
    data_valid: from_id_data.valid & ~from_id_data.is_load_operation & ~(from_id_data.result_high | from_id_data.result_low) & ~from_id_data.move_from_cp0 & from_id_data.register_write,
    write_register: from_id_data.write_register,
    write_data: alu_result
  };

  assign ex_ready_go = 1'b1;
  assign ex_allow_in = !ex_valid || ex_ready_go && io_allow_in;
  assign ex_to_io_valid = ex_valid && ex_ready_go;
  always_ff @(posedge clock) begin
    if (reset) begin
      ex_valid <= 1'b0;
    end else if (wb_exception_bus.exception_valid || wb_exception_bus.eret_flush) begin
      ex_valid <= 1'b0;
    end else if (ex_allow_in) begin
      ex_valid <= id_to_ex_decode_bus.valid;
    end
  end

  always_ff @(posedge clock) begin
    if (id_to_ex_decode_bus.valid && ex_allow_in) begin
      from_id_data <= id_to_ex_decode_bus;
    end
  end

  assign ex_have_exception_forwards = (from_id_data.exception_valid || from_id_data.eret_flush || ex_have_exception) && ex_valid;
  assign address_exception = (from_id_data.memory_io_type[4] && (alu_result[1:0] != 2'b00)) || (from_id_data.memory_io_type[2] && (alu_result[0] != 1'b0));
  assign overflow_exception = from_id_data.do_overflow_check && alu_overflow;
  assign ex_have_exception = from_id_data.memory_write ? address_exception : overflow_exception;
  assign exception_code = from_id_data.exception_valid || from_id_data.eret_flush ? from_id_data.exception_code : (from_id_data.memory_write & address_exception) ? 5'h05 : overflow_exception ? 5'h0c : 5'h00;
  assign should_flush = ex_have_exception_forwards || ex_have_exception_backwards;

  assign alu_input1 =
    from_id_data.source1_is_shift_amount ? {27'b0, from_id_data.immediate[10:6]} :
    from_id_data.source1_is_program_count ? from_id_data.program_count[31:0] : from_id_data.source_register_value;
  assign alu_input2 =
    from_id_data.source2_is_immediate ? {{16{~from_id_data.source2_is_unsigned & from_id_data.immediate[15]}}, from_id_data.immediate[15:0]} :
    from_id_data.source2_is_8 ? 32'd8 : from_id_data.multi_use_register_value;

  alu u_alu(
    .alu_operation(from_id_data.alu_operation),
    .alu_input_1(alu_input1),
    .alu_input_2(alu_input2),
    .alu_output(alu_result),
    .alu_overflow
  );

  assign data_ram_enabled = !should_flush;
  assign data_ram_write_enabled = from_id_data.memory_write && ex_valid ? (
    ({4{from_id_data.memory_io_type[4]}} & 4'b1111) |
    ({4{from_id_data.memory_io_type[3]}} & (
      ({4{alu_result[1:0] == 2'b00}} & 4'b0001) |
      ({4{alu_result[1:0] == 2'b01}} & 4'b0011) |
      ({4{alu_result[1:0] == 2'b10}} & 4'b0111) |
      ({4{alu_result[1:0] == 2'b11}} & 4'b1111))) |
    ({4{from_id_data.memory_io_type[2]}} & (
      ({4{alu_result[1:0] == 2'b00}} & 4'b0011) |
      ({4{alu_result[1:0] == 2'b10}} & 4'b1100))) |
    ({4{from_id_data.memory_io_type[1]}} & (
      ({4{alu_result[1:0] == 2'b00}} & 4'b1111) |
      ({4{alu_result[1:0] == 2'b01}} & 4'b1110) |
      ({4{alu_result[1:0] == 2'b10}} & 4'b1100) |
      ({4{alu_result[1:0] == 2'b11}} & 4'b1000))) |
    ({4{from_id_data.memory_io_type[0]}} & (
      ({4{alu_result[1:0] == 2'b00}} & 4'b0001) |
      ({4{alu_result[1:0] == 2'b01}} & 4'b0010) |
      ({4{alu_result[1:0] == 2'b10}} & 4'b0100) |
      ({4{alu_result[1:0] == 2'b11}} & 4'b1000)))
  ) : 4'h0;
  assign data_ram_address = from_id_data.memory_io_type[1] ? {alu_result[31:2], 2'b0} : alu_result;
  assign data_ram_write_data =
    from_id_data.memory_io_type[0] ? {4{from_id_data.multi_use_register_value[7:0]}} :
    from_id_data.memory_io_type[2] ? {2{from_id_data.multi_use_register_value[15:0]}} :
    from_id_data.memory_io_type[1] ? (
      alu_result[1:0] == 2'b00 ? from_id_data.multi_use_register_value :
      alu_result[1:0] == 2'b01 ? {from_id_data.multi_use_register_value[23:0], 8'b0} :
      alu_result[1:0] == 2'b10 ? {from_id_data.multi_use_register_value[15:0], 16'b0} :
        {from_id_data.multi_use_register_value[7:0], 24'b0}) :
    from_id_data.memory_io_type[3] ? (
      alu_result[1:0] == 2'b00 ? {24'b0, from_id_data.multi_use_register_value[31:24]} :
      alu_result[1:0] == 2'b01 ? {16'b0, from_id_data.multi_use_register_value[31:16]} :
      alu_result[1:0] == 2'b10 ? {8'b0, from_id_data.multi_use_register_value[31:8]} :
        from_id_data.multi_use_register_value) : from_id_data.multi_use_register_value;

  multiplier u_multiplier (
    .clock,
    .reset,
    .input1(alu_input1),
    .input2(alu_input2),
    .is_signed(from_id_data.multiply_divide_signed),
    .result(multiply_result)
  );

  divider u_divider (
    .clock,
    .reset,
    .divide_request_valid(from_id_data.divide_valid),
    .is_signed_input(from_id_data.multiply_divide_signed),
    .input1(alu_input1),
    .input2(alu_input2),
    .divide_result_valid,
    .divide_result,
    .divide_remain
  );
endmodule : ex_stage
