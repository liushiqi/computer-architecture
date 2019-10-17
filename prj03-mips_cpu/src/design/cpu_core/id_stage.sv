`include "cpu_params.svh"

module id_stage (
  input clock,
  input reset,
  // id allow in
  input ex_allow_in,
  output id_allow_in,
  // from if instruction bus data
  input if_stage_params::IFToIDInstructionBusData if_to_id_instruction_bus,
  // backpass data
  input ex_stage_params::EXToIDBackPassData ex_to_id_back_pass_bus,
  input io_stage_params::IOToIDBackPassData io_to_id_back_pass_bus,
  input wb_stage_params::WBToIDBackPassData wb_to_id_back_pass_bus,
  // to ex decode result data
  output id_stage_params::IDToEXDecodeBusData id_to_ex_decode_bus,
  // to fs
  output id_stage_params::IDToIFBranchBusData id_to_if_branch_bus,
  // to register file: for write back stage
  input wb_stage_params::WBToRegisterFileData wb_to_register_file_bus
);
  import id_stage_params::*;
  reg id_valid;
  wire id_ready_go;
  wire id_to_ex_valid;

  if_stage_params::IFToIDInstructionBusData from_if_data; // reg
  CpuData id_instruction;
  ProgramCount id_program_count;
  assign id_instruction = from_if_data.instruction;
  assign id_program_count = from_if_data.program_count;

  wb_stage_params::WBToRegisterFileData register_file_write_signals;
  assign register_file_write_signals = wb_to_register_file_bus;

  wire branch_taken;
  wire [31:0] branch_target;

  wire [11:0] alu_operation;
  wire is_load_operation;
  wire is_jump_operation;
  wire source1_is_shift_amount;
  wire source1_is_program_count;
  wire source2_is_immediate;
  wire source2_is_unsigned;
  wire source2_is_8;
  wire multiply_valid;
  wire divide_valid;
  wire multiply_divide_signed;
  wire result_high;
  wire result_low;
  wire high_low_write;
  wire register_write;
  wire memory_write;
  wire [4:0] memory_io_type;
  wire memory_io_unsigned;
  wire [4:0] write_register;
  wire [15:0] immediate;
  wire [31:0] source_register_value;
  wire [31:0] multi_use_register_value;
  wire [31:0] source_register_post_value;
  wire [31:0] multi_use_register_post_value;
  wire multi_use_register_is_used;

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

  wire instruction_add;
  wire instruction_addi;
  wire instruction_addiu;
  wire instruction_addu;
  wire instruction_and;
  wire instruction_andi;
  wire instruction_beq;
  wire instruction_bgez;
  wire instruction_bgezal;
  wire instruction_bgtz;
  wire instruction_blez;
  wire instruction_bltz;
  wire instruction_bltzal;
  wire instruction_bne;
  wire instruction_div;
  wire instruction_divu;
  wire instruction_j;
  wire instruction_jal;
  wire instruction_jalr;
  wire instruction_jr;
  wire instruction_lb;
  wire instruction_lbu;
  wire instruction_lh;
  wire instruction_lhu;
  wire instruction_lui;
  wire instruction_lw;
  wire instruction_lwl;
  wire instruction_lwr;
  wire instruction_mfhi;
  wire instruction_mflo;
  wire instruction_mthi;
  wire instruction_mtlo;
  wire instruction_mult;
  wire instruction_multu;
  wire instruction_nor;
  wire instruction_or;
  wire instruction_ori;
  wire instruction_sb;
  wire instruction_sh;
  wire instruction_sll;
  wire instruction_sllv;
  wire instruction_slt;
  wire instruction_slti;
  wire instruction_sltiu;
  wire instruction_sltu;
  wire instruction_sra;
  wire instruction_srav;
  wire instruction_srl;
  wire instruction_srlv;
  wire instruction_sub;
  wire instruction_subu;
  wire instruction_sw;
  wire instruction_swl;
  wire instruction_swr;
  wire instruction_xor;
  wire instruction_xori;

  wire destination_is_register31;
  wire detination_is_multi_use;

  wire [4:0] register_file_read_address_1;
  wire [31:0] register_file_read_data_1;
  wire [4:0] register_file_read_address_2;
  wire [31:0] register_file_read_data_2;

  wire source_registers_are_equal;
  wire source_register_is_negative;
  wire source_register_is_positive;

  assign id_to_if_branch_bus = '{
    taken: branch_taken,
    target: branch_target
  };

  assign id_to_ex_decode_bus = '{
    valid: id_to_ex_valid,
    program_count: id_program_count,
    multi_use_register_value: multi_use_register_value,
    source_register_value: source_register_value,
    immediate: immediate,
    destination_register: write_register,
    memory_write: memory_write,
    memory_io_type: memory_io_type,
    memory_io_unsigned: memory_io_unsigned,
    register_write: register_write,
    source2_is_8: source2_is_8,
    source2_is_immediate: source2_is_immediate,
    source2_is_unsigned: source2_is_unsigned,
    source1_is_program_count: source1_is_program_count,
    source1_is_shift_amount: source1_is_shift_amount,
    is_load_operation: is_load_operation,
    multiply_valid: multiply_valid,
    divide_valid: divide_valid,
    multiply_divide_signed: multiply_divide_signed,
    result_high: result_high,
    result_low: result_low,
    high_low_write: high_low_write,
    alu_operation: alu_operation
  };

  wire [4:0] source_register_0_if_unused;
  wire [4:0] multi_use_register_0_if_unused;
  assign source_register_0_if_unused = source_register;
  assign multi_use_register_0_if_unused = multi_use_register & {5{multi_use_register_is_used}};
  wire id_should_be_blocked;
  assign id_should_be_blocked =
    ex_to_id_back_pass_bus.valid &&
    (!(ex_to_id_back_pass_bus.data_valid) || is_jump_operation) &&
    (ex_to_id_back_pass_bus.write_register != 5'b0) &&
    (ex_to_id_back_pass_bus.write_register == source_register_0_if_unused ||
      ex_to_id_back_pass_bus.write_register == multi_use_register_0_if_unused);
  assign id_ready_go = ~id_should_be_blocked;
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

  assign instruction_add = operation_code_decoded[6'h00] & function_code_decoded[6'h20] & shift_amount_decoded[5'h00];
  assign instruction_addi = operation_code_decoded[6'h08];
  assign instruction_addiu = operation_code_decoded[6'h09];
  assign instruction_addu = operation_code_decoded[6'h00] & function_code_decoded[6'h21] & shift_amount_decoded[5'h00];
  assign instruction_and = operation_code_decoded[6'h00] & function_code_decoded[6'h24] & shift_amount_decoded[5'h00];
  assign instruction_andi = operation_code_decoded[6'h0c];
  assign instruction_beq = operation_code_decoded[6'h04];
  assign instruction_bgez = operation_code_decoded[6'h01] & multi_use_register_decoded[6'h01];
  assign instruction_bgezal = operation_code_decoded[6'h01] & multi_use_register_decoded[6'h11];
  assign instruction_bgtz = operation_code_decoded[6'h07] & multi_use_register_decoded[6'h00];
  assign instruction_blez = operation_code_decoded[6'h06] & multi_use_register_decoded[6'h00];
  assign instruction_bltz = operation_code_decoded[6'h01] & multi_use_register_decoded[6'h00];
  assign instruction_bltzal = operation_code_decoded[6'h01] & multi_use_register_decoded[6'h10];
  assign instruction_bne = operation_code_decoded[6'h05];
  assign instruction_div = operation_code_decoded[6'h00] & function_code_decoded[6'h1a] & destination_register_decoded[5'h00] & shift_amount_decoded[5'h00];
  assign instruction_divu = operation_code_decoded[6'h00] & function_code_decoded[6'h1b] & destination_register_decoded[5'h00] & shift_amount_decoded[5'h00];
  assign instruction_j = operation_code_decoded[6'h02];
  assign instruction_jal = operation_code_decoded[6'h03];
  assign instruction_jalr = operation_code_decoded[6'h00] & function_code_decoded[6'h09] & multi_use_register_decoded[5'h00] & shift_amount_decoded[5'h00];
  assign instruction_jr = operation_code_decoded[6'h00] & function_code_decoded[6'h08] & multi_use_register_decoded[5'h00] & destination_register_decoded[5'h00] & shift_amount_decoded[5'h00];
  assign instruction_lb = operation_code_decoded[6'h20];
  assign instruction_lbu = operation_code_decoded[6'h24];
  assign instruction_lh = operation_code_decoded[6'h21];
  assign instruction_lhu = operation_code_decoded[6'h25];
  assign instruction_lui = operation_code_decoded[6'h0f] & source_register_decoded[5'h00];
  assign instruction_lw = operation_code_decoded[6'h23];
  assign instruction_lwl = operation_code_decoded[6'h22];
  assign instruction_lwr = operation_code_decoded[6'h26];
  assign instruction_mfhi = operation_code_decoded[6'h00] & function_code_decoded[6'h10] & source_register_decoded[5'h00] & multi_use_register_decoded[5'h00] & shift_amount_decoded[5'h00];
  assign instruction_mflo = operation_code_decoded[6'h00] & function_code_decoded[6'h12] & source_register_decoded[5'h00] & multi_use_register_decoded[5'h00] &  shift_amount_decoded[5'h00];
  assign instruction_mthi = operation_code_decoded[6'h00] & function_code_decoded[6'h11] & multi_use_register_decoded[5'h00] & destination_register_decoded[5'h00] & shift_amount_decoded[5'h00];
  assign instruction_mtlo = operation_code_decoded[6'h00] & function_code_decoded[6'h13] & multi_use_register_decoded[5'h00] & destination_register_decoded[5'h00] & shift_amount_decoded[5'h00];
  assign instruction_mult = operation_code_decoded[6'h00] & function_code_decoded[6'h18] & destination_register_decoded[5'h00] & shift_amount_decoded[5'h00];
  assign instruction_multu = operation_code_decoded[6'h00] & function_code_decoded[6'h19] & destination_register_decoded[5'h00] & shift_amount_decoded[5'h00];
  assign instruction_nor = operation_code_decoded[6'h00] & function_code_decoded[6'h27] & shift_amount_decoded[5'h00];
  assign instruction_or = operation_code_decoded[6'h00] & function_code_decoded[6'h25] & shift_amount_decoded[5'h00];
  assign instruction_ori = operation_code_decoded[6'h0d];
  assign instruction_sb = operation_code_decoded[6'h28];
  assign instruction_sh = operation_code_decoded[6'h29];
  assign instruction_sll = operation_code_decoded[6'h00] & function_code_decoded[6'h00] & source_register_decoded[5'h00];
  assign instruction_sllv = operation_code_decoded[6'h00] & function_code_decoded[6'h04] & shift_amount_decoded[5'h00];
  assign instruction_slt = operation_code_decoded[6'h00] & function_code_decoded[6'h2a] & shift_amount_decoded[5'h00];
  assign instruction_slti = operation_code_decoded[6'h0a];
  assign instruction_sltiu = operation_code_decoded[6'h0b];
  assign instruction_sltu = operation_code_decoded[6'h00] & function_code_decoded[6'h2b] & shift_amount_decoded[5'h00];
  assign instruction_sra = operation_code_decoded[6'h00] & function_code_decoded[6'h03] & source_register_decoded[5'h00];
  assign instruction_srav = operation_code_decoded[6'h00] & function_code_decoded[6'h07] & shift_amount_decoded[5'h00];
  assign instruction_srl = operation_code_decoded[6'h00] & function_code_decoded[6'h02] & source_register_decoded[5'h00];
  assign instruction_srlv = operation_code_decoded[6'h00] & function_code_decoded[6'h06] & shift_amount_decoded[5'h00];
  assign instruction_sub = operation_code_decoded[6'h00] & function_code_decoded[6'h22] & shift_amount_decoded[5'h00];
  assign instruction_subu = operation_code_decoded[6'h00] & function_code_decoded[6'h23] & shift_amount_decoded[5'h00];
  assign instruction_sw = operation_code_decoded[6'h2b];
  assign instruction_swl = operation_code_decoded[6'h2a];
  assign instruction_swr = operation_code_decoded[6'h2e];
  assign instruction_xor = operation_code_decoded[6'h00] & function_code_decoded[6'h26] & shift_amount_decoded[5'h00];
  assign instruction_xori = operation_code_decoded[6'h0e];

  assign alu_operation[0] = instruction_add | instruction_addi | instruction_addiu | instruction_addu | instruction_bgezal | instruction_bltzal | instruction_jal | instruction_jalr | instruction_lb | instruction_lbu | instruction_lh | instruction_lhu | instruction_lw | instruction_lwl | instruction_lwr | instruction_sb | instruction_sh | instruction_sw | instruction_swl | instruction_swr;
  assign alu_operation[1] = instruction_sub | instruction_subu;
  assign alu_operation[2] = instruction_slt | instruction_slti;
  assign alu_operation[3] = instruction_sltiu | instruction_sltu;
  assign alu_operation[4] = instruction_and | instruction_andi;
  assign alu_operation[5] = instruction_nor;
  assign alu_operation[6] = instruction_or | instruction_ori;
  assign alu_operation[7] = instruction_xor | instruction_xori;
  assign alu_operation[8] = instruction_sll | instruction_sllv;
  assign alu_operation[9] = instruction_srl | instruction_srlv;
  assign alu_operation[10] = instruction_sra | instruction_srav;
  assign alu_operation[11] = instruction_lui;

  assign source1_is_shift_amount = instruction_sll | instruction_srl | instruction_sra;
  assign source1_is_program_count = instruction_bgezal | instruction_bltzal | instruction_jal | instruction_jalr;
  assign source2_is_immediate = instruction_addi | instruction_addiu | instruction_andi | instruction_lui | instruction_lb | instruction_lbu | instruction_lh | instruction_lhu | instruction_lw | instruction_lwl | instruction_lwr | instruction_ori | instruction_slti | instruction_sltiu | instruction_sb | instruction_sh | instruction_sw | instruction_swl | instruction_swr | instruction_xori;
  assign source2_is_unsigned = instruction_andi | instruction_ori | instruction_xori;
  assign source2_is_8 = instruction_bgezal | instruction_bltzal | instruction_jal | instruction_jalr;
  assign multiply_valid = instruction_mult | instruction_multu;
  assign divide_valid = instruction_div | instruction_divu;
  assign multiply_divide_signed = instruction_mult | instruction_div;
  assign result_high = instruction_mfhi | instruction_mthi;
  assign result_low = instruction_mflo | instruction_mtlo;
  assign high_low_write = instruction_mthi | instruction_mtlo;
  assign destination_is_register31 = instruction_bgezal | instruction_bltzal | instruction_jal | instruction_jalr;
  assign detination_is_multi_use = instruction_addi | instruction_addiu | instruction_andi | instruction_lb | instruction_lbu | instruction_lh | instruction_lhu | instruction_lui | instruction_lw | | instruction_lwl | instruction_lwr | instruction_ori | instruction_slti | instruction_sltiu | instruction_xori;
  assign register_write = ~instruction_beq & ~instruction_bgez & ~instruction_bgtz & ~instruction_blez & ~instruction_bltz & ~instruction_bne & ~instruction_div & ~instruction_divu & ~instruction_j & ~instruction_jr & ~instruction_mthi & ~instruction_mtlo & ~instruction_mult & ~instruction_multu & ~instruction_sb & ~instruction_sh & ~instruction_sw & ~instruction_swl & ~instruction_swr;
  assign memory_write = instruction_sb | instruction_sh | instruction_sw | instruction_swl | instruction_swr;
  assign memory_io_unsigned = instruction_lbu | instruction_lhu;
  assign is_load_operation = instruction_lb | instruction_lbu | instruction_lh | instruction_lhu | instruction_lw | instruction_lwl | instruction_lwr;
  assign is_jump_operation = instruction_beq | instruction_bgez | instruction_bgezal | instruction_bgtz | instruction_blez | instruction_bltz | instruction_bltzal | instruction_bne | instruction_j | instruction_jal | instruction_jalr | instruction_jr;
  assign multi_use_register_is_used = instruction_add | instruction_addu | instruction_and | instruction_beq | instruction_bne | instruction_div | instruction_divu | instruction_mult | instruction_multu | instruction_nor | instruction_or | instruction_sll | instruction_sllv | instruction_slt | instruction_sltu | instruction_sra | instruction_srav | instruction_srl | instruction_srlv | instruction_sub | instruction_subu | instruction_sb | instruction_sh | instruction_sw | instruction_swl | instruction_swr;

  assign memory_io_type[4] = instruction_lw | instruction_sw;
  assign memory_io_type[3] = instruction_lwl | instruction_swl;
  assign memory_io_type[2] = instruction_lh | instruction_lhu | instruction_sh;
  assign memory_io_type[1] = instruction_lwr | instruction_swr;
  assign memory_io_type[0] = instruction_lb | instruction_lbu | instruction_sb;

  assign write_register = destination_is_register31 ? 5'd31 : detination_is_multi_use ? multi_use_register : destination_register;

  assign register_file_read_address_1 = source_register;
  assign register_file_read_address_2 = multi_use_register;
  register_file u_regfile(
    .clock(clock),
    .read_address_1(register_file_read_address_1),
    .read_data_1(register_file_read_data_1),
    .read_address_2(register_file_read_address_2),
    .read_data_2(register_file_read_data_2),
    .write_enabled(register_file_write_signals.write_enabled),
    .write_strobe(register_file_write_signals.write_strobe),
    .write_address(register_file_write_signals.write_address),
    .write_data(register_file_write_signals.write_data)
  );

  assign source_register_value[7:0] =
    (ex_to_id_back_pass_bus.valid && ex_to_id_back_pass_bus.data_valid && ex_to_id_back_pass_bus.write_register == source_register) ? ex_to_id_back_pass_bus.write_data[7:0] :
    (io_to_id_back_pass_bus.valid && io_to_id_back_pass_bus.write_strobe[0] && io_to_id_back_pass_bus.write_register == source_register) ? io_to_id_back_pass_bus.write_data[7:0] :
    (wb_to_id_back_pass_bus.valid && wb_to_id_back_pass_bus.write_strobe[0] && wb_to_id_back_pass_bus.write_register == source_register) ? wb_to_id_back_pass_bus.write_data[7:0] : register_file_read_data_1[7:0];
  assign multi_use_register_value[7:0] =
    (ex_to_id_back_pass_bus.valid && ex_to_id_back_pass_bus.data_valid && ex_to_id_back_pass_bus.write_register == multi_use_register) ? ex_to_id_back_pass_bus.write_data[7:0] :
    (io_to_id_back_pass_bus.valid && io_to_id_back_pass_bus.write_strobe[0] && io_to_id_back_pass_bus.write_register == multi_use_register) ? io_to_id_back_pass_bus.write_data[7:0] :
    (wb_to_id_back_pass_bus.valid && wb_to_id_back_pass_bus.write_strobe[0] && wb_to_id_back_pass_bus.write_register == multi_use_register) ? wb_to_id_back_pass_bus.write_data[7:0] : register_file_read_data_2[7:0];

  assign source_register_value[15:8] =
    (ex_to_id_back_pass_bus.valid && ex_to_id_back_pass_bus.data_valid && ex_to_id_back_pass_bus.write_register == source_register) ? ex_to_id_back_pass_bus.write_data[15:8] :
    (io_to_id_back_pass_bus.valid && io_to_id_back_pass_bus.write_strobe[1] && io_to_id_back_pass_bus.write_register == source_register) ? io_to_id_back_pass_bus.write_data[15:8] :
    (wb_to_id_back_pass_bus.valid && wb_to_id_back_pass_bus.write_strobe[1] && wb_to_id_back_pass_bus.write_register == source_register) ? wb_to_id_back_pass_bus.write_data[15:8] : register_file_read_data_1[15:8];
  assign multi_use_register_value[15:8] =
    (ex_to_id_back_pass_bus.valid && ex_to_id_back_pass_bus.data_valid && ex_to_id_back_pass_bus.write_register == multi_use_register) ? ex_to_id_back_pass_bus.write_data[15:8] :
    (io_to_id_back_pass_bus.valid && io_to_id_back_pass_bus.write_strobe[1] && io_to_id_back_pass_bus.write_register == multi_use_register) ? io_to_id_back_pass_bus.write_data[15:8] :
    (wb_to_id_back_pass_bus.valid && wb_to_id_back_pass_bus.write_strobe[1] && wb_to_id_back_pass_bus.write_register == multi_use_register) ? wb_to_id_back_pass_bus.write_data[15:8] : register_file_read_data_2[15:8];

  assign source_register_value[23:16] =
    (ex_to_id_back_pass_bus.valid && ex_to_id_back_pass_bus.data_valid && ex_to_id_back_pass_bus.write_register == source_register) ? ex_to_id_back_pass_bus.write_data[23:16] :
    (io_to_id_back_pass_bus.valid && io_to_id_back_pass_bus.write_strobe[2] && io_to_id_back_pass_bus.write_register == source_register) ? io_to_id_back_pass_bus.write_data[23:16] :
    (wb_to_id_back_pass_bus.valid && wb_to_id_back_pass_bus.write_strobe[2] && wb_to_id_back_pass_bus.write_register == source_register) ? wb_to_id_back_pass_bus.write_data[23:16] : register_file_read_data_1[23:16];
  assign multi_use_register_value[23:16] =
    (ex_to_id_back_pass_bus.valid && ex_to_id_back_pass_bus.data_valid && ex_to_id_back_pass_bus.write_register == multi_use_register) ? ex_to_id_back_pass_bus.write_data[23:16] :
    (io_to_id_back_pass_bus.valid && io_to_id_back_pass_bus.write_strobe[2] && io_to_id_back_pass_bus.write_register == multi_use_register) ? io_to_id_back_pass_bus.write_data[23:16] :
    (wb_to_id_back_pass_bus.valid && wb_to_id_back_pass_bus.write_strobe[2] && wb_to_id_back_pass_bus.write_register == multi_use_register) ? wb_to_id_back_pass_bus.write_data[23:16] : register_file_read_data_2[23:16];

  assign source_register_value[31:24] =
    (ex_to_id_back_pass_bus.valid && ex_to_id_back_pass_bus.data_valid && ex_to_id_back_pass_bus.write_register == source_register) ? ex_to_id_back_pass_bus.write_data[31:24] :
    (io_to_id_back_pass_bus.valid && io_to_id_back_pass_bus.write_strobe[3] && io_to_id_back_pass_bus.write_register == source_register) ? io_to_id_back_pass_bus.write_data[31:24] :
    (wb_to_id_back_pass_bus.valid && wb_to_id_back_pass_bus.write_strobe[3] && wb_to_id_back_pass_bus.write_register == source_register) ? wb_to_id_back_pass_bus.write_data[31:24] : register_file_read_data_1[31:24];
  assign multi_use_register_value[31:24] =
    (ex_to_id_back_pass_bus.valid && ex_to_id_back_pass_bus.data_valid && ex_to_id_back_pass_bus.write_register == multi_use_register) ? ex_to_id_back_pass_bus.write_data[31:24] :
    (io_to_id_back_pass_bus.valid && io_to_id_back_pass_bus.write_strobe[3] && io_to_id_back_pass_bus.write_register == multi_use_register) ? io_to_id_back_pass_bus.write_data[31:24] :
    (wb_to_id_back_pass_bus.valid && wb_to_id_back_pass_bus.write_strobe[3] && wb_to_id_back_pass_bus.write_register == multi_use_register) ? wb_to_id_back_pass_bus.write_data[31:24] : register_file_read_data_2[31:24];

  assign source_register_post_value[7:0] =
    (io_to_id_back_pass_bus.previous_valid && io_to_id_back_pass_bus.previous_write_register == source_register) ? io_to_id_back_pass_bus.previous_write_data[7:0] :
    (io_to_id_back_pass_bus.valid && io_to_id_back_pass_bus.write_strobe[0] && io_to_id_back_pass_bus.write_register == source_register) ? io_to_id_back_pass_bus.write_data[7:0] :
    (wb_to_id_back_pass_bus.valid && wb_to_id_back_pass_bus.write_strobe[0] && wb_to_id_back_pass_bus.write_register == source_register) ? wb_to_id_back_pass_bus.write_data[7:0] : register_file_read_data_1[7:0];
  assign multi_use_register_post_value[7:0] =
    (io_to_id_back_pass_bus.previous_valid && io_to_id_back_pass_bus.previous_write_register == multi_use_register) ? io_to_id_back_pass_bus.previous_write_data[7:0] :
    (io_to_id_back_pass_bus.valid && io_to_id_back_pass_bus.write_strobe[0] && io_to_id_back_pass_bus.write_register == multi_use_register) ? io_to_id_back_pass_bus.write_data[7:0] :
    (wb_to_id_back_pass_bus.valid && wb_to_id_back_pass_bus.write_strobe[0] && wb_to_id_back_pass_bus.write_register == multi_use_register) ? wb_to_id_back_pass_bus.write_data[7:0] : register_file_read_data_2[7:0];

  assign source_register_post_value[15:8] =
    (io_to_id_back_pass_bus.previous_valid && io_to_id_back_pass_bus.previous_write_register == source_register) ? io_to_id_back_pass_bus.previous_write_data[15:8] :
    (io_to_id_back_pass_bus.valid && io_to_id_back_pass_bus.write_strobe[1] && io_to_id_back_pass_bus.write_register == source_register) ? io_to_id_back_pass_bus.write_data[15:8] :
    (wb_to_id_back_pass_bus.valid && wb_to_id_back_pass_bus.write_strobe[1] && wb_to_id_back_pass_bus.write_register == source_register) ? wb_to_id_back_pass_bus.write_data[15:8] : register_file_read_data_1[15:8];
  assign multi_use_register_post_value[15:8] =
    (io_to_id_back_pass_bus.previous_valid && io_to_id_back_pass_bus.previous_write_register == multi_use_register) ? io_to_id_back_pass_bus.previous_write_data[15:8] :
    (io_to_id_back_pass_bus.valid && io_to_id_back_pass_bus.write_strobe[1] && io_to_id_back_pass_bus.write_register == multi_use_register) ? io_to_id_back_pass_bus.write_data[15:8] :
    (wb_to_id_back_pass_bus.valid && wb_to_id_back_pass_bus.write_strobe[1] && wb_to_id_back_pass_bus.write_register == multi_use_register) ? wb_to_id_back_pass_bus.write_data[15:8] : register_file_read_data_2[15:8];

  assign source_register_post_value[23:16] =
    (io_to_id_back_pass_bus.previous_valid && io_to_id_back_pass_bus.previous_write_register == source_register) ? io_to_id_back_pass_bus.previous_write_data[23:16] :
    (io_to_id_back_pass_bus.valid && io_to_id_back_pass_bus.write_strobe[2] && io_to_id_back_pass_bus.write_register == source_register) ? io_to_id_back_pass_bus.write_data[23:16] :
    (wb_to_id_back_pass_bus.valid && wb_to_id_back_pass_bus.write_strobe[2] && wb_to_id_back_pass_bus.write_register == source_register) ? wb_to_id_back_pass_bus.write_data[23:16] : register_file_read_data_1[23:16];
  assign multi_use_register_post_value[23:16] =
    (io_to_id_back_pass_bus.previous_valid && io_to_id_back_pass_bus.previous_write_register == multi_use_register) ? io_to_id_back_pass_bus.previous_write_data[23:16] :
    (io_to_id_back_pass_bus.valid && io_to_id_back_pass_bus.write_strobe[2] && io_to_id_back_pass_bus.write_register == multi_use_register) ? io_to_id_back_pass_bus.write_data[23:16] :
    (wb_to_id_back_pass_bus.valid && wb_to_id_back_pass_bus.write_strobe[2] && wb_to_id_back_pass_bus.write_register == multi_use_register) ? wb_to_id_back_pass_bus.write_data[23:16] : register_file_read_data_2[23:16];

  assign source_register_post_value[31:24] =
    (io_to_id_back_pass_bus.previous_valid && io_to_id_back_pass_bus.previous_write_register == source_register) ? io_to_id_back_pass_bus.previous_write_data[31:24] :
    (io_to_id_back_pass_bus.valid && io_to_id_back_pass_bus.write_strobe[3] && io_to_id_back_pass_bus.write_register == source_register) ? io_to_id_back_pass_bus.write_data[31:24] :
    (wb_to_id_back_pass_bus.valid && wb_to_id_back_pass_bus.write_strobe[3] && wb_to_id_back_pass_bus.write_register == source_register) ? wb_to_id_back_pass_bus.write_data[31:24] : register_file_read_data_1[31:24];
  assign multi_use_register_post_value[31:24] =
    (io_to_id_back_pass_bus.previous_valid && io_to_id_back_pass_bus.previous_write_register == multi_use_register) ? io_to_id_back_pass_bus.previous_write_data[31:24] :
    (io_to_id_back_pass_bus.valid && io_to_id_back_pass_bus.write_strobe[3] && io_to_id_back_pass_bus.write_register == multi_use_register) ? io_to_id_back_pass_bus.write_data[31:24] :
    (wb_to_id_back_pass_bus.valid && wb_to_id_back_pass_bus.write_strobe[3] && wb_to_id_back_pass_bus.write_register == multi_use_register) ? wb_to_id_back_pass_bus.write_data[31:24] : register_file_read_data_2[31:24];

  assign source_registers_are_equal = (source_register_post_value == multi_use_register_post_value);
  assign source_register_is_negative = (source_register_post_value[CPU_DATA_WIDTH - 1] == 1'b1);
  assign source_register_is_positive = (~source_register_is_negative && (source_register_post_value != 32'b0));
  assign branch_taken =
    ((instruction_beq && source_registers_are_equal) ||
      ((instruction_bgez || instruction_bgezal) && ~source_register_is_negative) ||
      (instruction_bgtz && source_register_is_positive) ||
      (instruction_blez && ~source_register_is_positive) ||
      ((instruction_bltz || instruction_bltzal) && source_register_is_negative) ||
      (instruction_bne && !source_registers_are_equal) ||
      instruction_j || instruction_jal || instruction_jalr || instruction_jr) && id_valid;
  assign branch_target =
    (instruction_beq || instruction_bgez || instruction_bgezal || instruction_bgtz || instruction_blez || instruction_bltz || instruction_bltzal || instruction_bne) ?
      (if_to_id_instruction_bus.program_count + {{14{immediate[15]}}, immediate[15:0], 2'b0}) :
    (instruction_jalr || instruction_jr) ? source_register_post_value : {if_to_id_instruction_bus.program_count[31:28], jump_address[25:0], 2'b0};
endmodule : id_stage
