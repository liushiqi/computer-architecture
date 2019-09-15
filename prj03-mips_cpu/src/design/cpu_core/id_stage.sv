`include "cpu_params.svh"

module id_stage (
  input clock,
  input reset,
  // id allow in
  input ex_allow_in,
  output id_allow_in,
  // from if instruction bus data
  input if_stage_params::IFToIDInstructionBusData if_to_id_instruction_bus,
  // to ex decode result data
  output id_stage_params::IDToEXDecodeBusData id_to_ex_decode_bus,
  //to fs
  output id_stage_params::IDToIFBranchBusData id_to_if_branch_bus,
  // to register file: for write back stage
  input wb_stage_params::WBToRegisterFileData wb_to_register_file_data
);
  import id_stage_params::*;
  reg id_valid;
  wire id_ready_go;
  wire id_to_ex_valid;

  if_stage_params::IFToIDInstructionBusData from_if_data;
  CpuData id_instruction;
  ProgramCount id_program_count;
  assign id_instruction = from_if_data.instruction;
  assign id_program_count = from_if_data.program_count;

  wb_stage_params::WBToRegisterFileData register_file_write_signals;
  assign register_file_write_signals = wb_to_register_file_data;

  wire branch_taken;
  wire [31:0] branch_target;

  wire [11:0] alu_operation;
  wire is_load_operation;
  wire source1_is_shift_amount;
  wire source1_is_program_count;
  wire source2_is_immediate;
  wire source2_is_8;
  wire result_from_memory;
  wire register_write;
  wire memory_write;
  wire [4:0] write_register;
  wire [15:0] immediate;
  wire [31:0] source_register_value;
  wire [31:0] multi_use_register_value;

  wire [5:0] operation_code;
  wire [4:0] source_register;
  wire [4:0] multi_use_register;
  wire [4:0] destination_register;
  wire [4:0] shift_amount;
  wire [5:0] function_code;
  wire [25:0] jump_address;
  wire [63:0] operation_code_decoded;
  wire [31:0] source_register_decoded;
  wire [31:0] multi_use_register_decoded;
  wire [31:0] destination_register_decoded;
  wire [31:0] shift_amount_decoded;
  wire [63:0] function_code_decoded;

  wire instruction_addu;
  wire instruction_subu;
  wire instruction_slt;
  wire instruction_sltu;
  wire instruction_and;
  wire instruction_or;
  wire instruction_xor;
  wire instruction_nor;
  wire instruction_sll;
  wire instruction_srl;
  wire instruction_sra;
  wire instruction_addiu;
  wire instruction_lui;
  wire instruction_lw;
  wire instruction_sw;
  wire instruction_beq;
  wire instruction_bne;
  wire instruction_jal;
  wire instruction_jr;

  wire destination_is_register31;
  wire detination_is_multi_use;

  wire [4:0] register_file_read_address_1;
  wire [31:0] register_file_read_data_1;
  wire [4:0] register_file_read_address_2;
  wire [31:0] register_file_read_data_2;

  wire source_registers_are_equal;

  assign id_to_if_branch_bus = {branch_taken, branch_target};

  assign id_to_ex_decode_bus = '{
    id_to_ex_valid,
    id_program_count,
    multi_use_register_value,
    source_register_value,
    immediate,
    write_register,
    memory_write,
    register_write,
    source2_is_8,
    source2_is_immediate,
    source1_is_program_count,
    source1_is_shift_amount,
    is_load_operation,
    alu_operation
  };

  assign id_ready_go = 1'b1;
  assign id_allow_in = !id_valid || (id_ready_go && ex_allow_in);
  assign id_to_ex_valid = id_valid && id_ready_go;
  always_ff @(posedge clock) begin
    if (reset) begin
      id_valid <= 1'b0;
    end else if (id_allow_in) begin
      id_valid <= if_to_id_instruction_bus.valid;
    end
  end

  always_ff @(posedge clock) begin
    if (if_to_id_instruction_bus.valid && id_allow_in) begin
      from_if_data <= if_to_id_instruction_bus;
    end
  end

  assign operation_code = id_instruction[31:26];
  assign source_register = id_instruction[25:21];
  assign multi_use_register = id_instruction[20:16];
  assign destination_register = id_instruction[15:11];
  assign shift_amount = id_instruction[10:6];
  assign function_code = id_instruction[5:0];
  assign immediate = id_instruction[15:0];
  assign jump_address = id_instruction[25:0];

  decoder_6_to_64 u_decoder_operation(.in(operation_code), .out(operation_code_decoded));
  decoder_6_to_64 u_decoder_function(.in(function_code), .out(function_code_decoded));
  decoder_5_to_32 u_decoder_source(.in(source_register), .out(source_register_decoded));
  decoder_5_to_32 u_decoder_multi_use(.in(multi_use_register), .out(multi_use_register_decoded));
  decoder_5_to_32 u_decoder_destination(.in(destination_register), .out(destination_register_decoded));
  decoder_5_to_32 u_decoder_shift_amount(.in(shift_amount), .out(shift_amount_decoded));

  assign instruction_addu = operation_code_decoded[6'h00] & function_code_decoded[6'h21] & shift_amount_decoded[5'h00];
  assign instruction_subu = operation_code_decoded[6'h00] & function_code_decoded[6'h23] & shift_amount_decoded[5'h00];
  assign instruction_slt = operation_code_decoded[6'h00] & function_code_decoded[6'h2a] & shift_amount_decoded[5'h00];
  assign instruction_sltu = operation_code_decoded[6'h00] & function_code_decoded[6'h2b] & shift_amount_decoded[5'h00];
  assign instruction_and = operation_code_decoded[6'h00] & function_code_decoded[6'h24] & shift_amount_decoded[5'h00];
  assign instruction_or = operation_code_decoded[6'h00] & function_code_decoded[6'h25] & shift_amount_decoded[5'h00];
  assign instruction_xor = operation_code_decoded[6'h00] & function_code_decoded[6'h26] & shift_amount_decoded[5'h00];
  assign instruction_nor = operation_code_decoded[6'h00] & function_code_decoded[6'h27] & shift_amount_decoded[5'h00];
  assign instruction_sll = operation_code_decoded[6'h00] & function_code_decoded[6'h00] & source_register_decoded[5'h00];
  assign instruction_srl = operation_code_decoded[6'h00] & function_code_decoded[6'h02] & source_register_decoded[5'h00];
  assign instruction_sra = operation_code_decoded[6'h00] & function_code_decoded[6'h03] & source_register_decoded[5'h00];
  assign instruction_addiu = operation_code_decoded[6'h09];
  assign instruction_lui = operation_code_decoded[6'h0f] & source_register_decoded[5'h00];
  assign instruction_lw = operation_code_decoded[6'h23];
  assign instruction_sw = operation_code_decoded[6'h2b];
  assign instruction_beq = operation_code_decoded[6'h04];
  assign instruction_bne = operation_code_decoded[6'h05];
  assign instruction_jal = operation_code_decoded[6'h03];
  assign instruction_jr = operation_code_decoded[6'h00] & function_code_decoded[6'h08] & multi_use_register_decoded[5'h00] & destination_register_decoded[5'h00] & shift_amount_decoded[5'h00];

  assign alu_operation[0] = instruction_addu | instruction_addiu | instruction_lw | instruction_sw | instruction_jal;
  assign alu_operation[1] = instruction_subu;
  assign alu_operation[2] = instruction_slt;
  assign alu_operation[3] = instruction_sltu;
  assign alu_operation[4] = instruction_and;
  assign alu_operation[5] = instruction_nor;
  assign alu_operation[6] = instruction_or;
  assign alu_operation[7] = instruction_xor;
  assign alu_operation[8] = instruction_sll;
  assign alu_operation[9] = instruction_srl;
  assign alu_operation[10] = instruction_sra;
  assign alu_operation[11] = instruction_lui;

  assign source1_is_shift_amount = instruction_sll | instruction_srl | instruction_sra;
  assign source1_is_program_count = instruction_jal;
  assign source2_is_immediate = instruction_addiu | instruction_lui | instruction_lw | instruction_sw;
  assign source2_is_8 = instruction_jal;
  assign result_from_memory = instruction_lw;
  assign destination_is_register31 = instruction_jal;
  assign detination_is_multi_use = instruction_addiu | instruction_lui | instruction_lw;
  assign register_write = ~instruction_sw & ~instruction_beq & ~instruction_bne & ~instruction_jr;
  assign memory_write = instruction_sw;
  assign is_load_operation = instruction_lw;

  assign write_register = destination_is_register31 ? 5'd31 : detination_is_multi_use ? multi_use_register : destination_register;

  assign register_file_read_address_1 = source_register;
  assign register_file_read_address_2 = multi_use_register;
  register_file u_regfile(
    .clock(clock),
    .reset(reset),
    .read_address_1(register_file_read_address_1),
    .read_data_1(register_file_read_data_1),
    .read_address_2(register_file_read_address_2),
    .read_data_2(register_file_read_data_2),
    .write_enabled(register_file_write_signals.write_enabled),
    .write_address(register_file_write_signals.write_address),
    .write_data(register_file_write_signals.write_data)
  );

  assign source_register_value = register_file_read_data_1;
  assign multi_use_register_value = register_file_read_data_2;

  assign source_registers_are_equal = (source_register_value == multi_use_register_value);
  assign branch_taken = ((instruction_beq && source_registers_are_equal) || (instruction_bne && !source_registers_are_equal) || instruction_jal || instruction_jr) && id_valid;
  assign branch_target =
    (instruction_beq || instruction_bne) ? (if_to_id_instruction_bus.program_count + {{14{immediate[15]}}, immediate[15:0], 2'b0}) :
    (instruction_jr) ? source_register_value : {if_to_id_instruction_bus.program_count[31:28], jump_address[25:0], 2'b0};
endmodule : id_stage
