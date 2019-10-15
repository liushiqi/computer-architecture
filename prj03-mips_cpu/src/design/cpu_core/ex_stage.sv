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
  // to io data
  output ex_stage_params::EXToIOData ex_to_io_bus,
  // data sram interface
  output data_enabled,
  output [3:0] data_write_enabled,
  output [31:0] data_address,
  output [31:0] data_write_data
);
  import ex_stage_params::*;
  reg ex_valid;
  wire ex_ready_go;
  wire ex_to_io_valid;

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
    destination_register: from_id_data.destination_register,
    register_write: from_id_data.register_write,
    register_write_strobe: data_write_enabled,
    result_is_from_memory: result_is_from_memory,
    multiply_valid: from_id_data.multiply_valid,
    multiply_result: multiply_result,
    divide_valid: from_id_data.divide_valid,
    divide_result_valid: divide_result_valid,
    divide_result: divide_result,
    divide_remain: divide_remain,
    result_high: from_id_data.result_high,
    result_low: from_id_data.result_low,
    high_low_write: from_id_data.high_low_write
  };

  wire [4:0] backpass_address;
  assign backpass_address = {5{from_id_data.register_write & ex_valid}} & from_id_data.destination_register;
  assign ex_to_id_back_pass_bus = '{
    valid: from_id_data.register_write & ex_valid,
    write_register: from_id_data.destination_register
  };

  assign ex_ready_go = 1'b1;
  assign ex_allow_in = !ex_valid || ex_ready_go && io_allow_in;
  assign ex_to_io_valid = ex_valid && ex_ready_go;
  always_ff @(posedge clock) begin
    if (reset) begin
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
    .alu_output(alu_result)
  );

  assign data_enabled = 1'b1;
  assign data_write_enabled = from_id_data.memory_write && ex_valid ? (
    ({4{from_id_data.memory_io_type[4]}} & 4'b1111) |
    ({4{from_id_data.memory_io_type[3]}} & (
      ({4{alu_result[1:0] == 4'b00}} & 4'b0001) |
      ({4{alu_result[1:0] == 4'b01}} & 4'b0011) |
      ({4{alu_result[1:0] == 4'b10}} & 4'b0111) |
      ({4{alu_result[1:0] == 4'b11}} & 4'b1111))) |
    ({4{from_id_data.memory_io_type[2]}} & (
      ({4{alu_result[1:0] == 4'b00}} & 4'b0011) |
      ({4{alu_result[1:0] == 4'b10}} & 4'b1100))) |
    ({4{from_id_data.memory_io_type[1]}} & (
      ({4{alu_result[1:0] == 4'b00}} & 4'b1111) |
      ({4{alu_result[1:0] == 4'b01}} & 4'b1110) |
      ({4{alu_result[1:0] == 4'b10}} & 4'b1100) |
      ({4{alu_result[1:0] == 4'b11}} & 4'b1000))) |
    ({4{from_id_data.memory_io_type[0]}} & (
      ({4{alu_result[1:0] == 4'b00}} & 4'b0001) |
      ({4{alu_result[1:0] == 4'b01}} & 4'b0010) |
      ({4{alu_result[1:0] == 4'b10}} & 4'b0100) |
      ({4{alu_result[1:0] == 4'b11}} & 4'b1000)))
  ) : 4'h0;
  assign data_address = {alu_result[31:2], 2'b0};
  assign data_write_data = (
    from_id_data.memory_io_type[0] ? {4{from_id_data.multi_use_register_value[7:0]}} :
    from_id_data.memory_io_type[2] ? {2{from_id_data.multi_use_register_value[15:0]}} : from_id_data.multi_use_register_value);

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
