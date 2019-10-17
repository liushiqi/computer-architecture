module alu(
  input [11:0] alu_operation,
  input [31:0] alu_input_1,
  input [31:0] alu_input_2,
  output [31:0] alu_output
);
  wire operation_add;
  wire operation_sub;
  wire operation_slt;
  wire operation_sltu;
  wire operation_and;
  wire operation_nor;
  wire operation_or;
  wire operation_xor;
  wire operation_sll;
  wire operation_srl;
  wire operation_sra;
  wire operation_lui;

  // control code decomposition
  assign operation_add = alu_operation[0];
  assign operation_sub = alu_operation[1];
  assign operation_slt = alu_operation[2];
  assign operation_sltu = alu_operation[3];
  assign operation_and = alu_operation[4];
  assign operation_nor = alu_operation[5];
  assign operation_or = alu_operation[6];
  assign operation_xor = alu_operation[7];
  assign operation_sll = alu_operation[8];
  assign operation_srl = alu_operation[9];
  assign operation_sra = alu_operation[10];
  assign operation_lui = alu_operation[11];

  wire [31:0] add_sub_result;
  wire [31:0] slt_result;
  wire [31:0] sltu_result;
  wire [31:0] and_result;
  wire [31:0] nor_result;
  wire [31:0] or_result;
  wire [31:0] xor_result;
  wire [31:0] lui_result;
  wire [31:0] sll_result;
  wire [63:0] sr64_result;
  wire [31:0] sr_result;


  // 32-bit adder
  wire [31:0] adder_input_1;
  wire [31:0] adder_input_2;
  wire adder_carry_in;
  wire [31:0] adder_result;
  wire adder_carry_out;

  assign adder_input_1 = alu_input_1;
  assign adder_input_2 = (operation_sub | operation_slt | operation_sltu) ? ~alu_input_2:alu_input_2;
  assign adder_carry_in = (operation_sub | operation_slt | operation_sltu) ? 1'b1:1'b0;
  assign {adder_carry_out, adder_result} = adder_input_1+adder_input_2+adder_carry_in;

  // add, sub result
  assign add_sub_result = adder_result;

  // slt result
  assign slt_result[31:1] = 31'b0;
  assign slt_result[0] = (alu_input_1[31] & ~alu_input_2[31])
    | ((alu_input_1[31] ~^ alu_input_2[31]) & adder_result[31]);

  // sltu result
  assign sltu_result[31:1] = 31'b0;
  assign sltu_result[0] = ~adder_carry_out;

  // bitwise operation
  assign and_result = alu_input_1 & alu_input_2;
  assign or_result = alu_input_1 | alu_input_2;
  assign nor_result = ~or_result;
  assign xor_result = alu_input_1 ^ alu_input_2;
  assign lui_result = {alu_input_2[15:0], 16'b0};

  // sll result
  assign sll_result = alu_input_2 << alu_input_1[4:0];

  // srl, sra result
  assign sr64_result = {{32{operation_sra & alu_input_2[31]}}, alu_input_2[31:0]} >> alu_input_1[4:0];

  assign sr_result = sr64_result[32:0];

  // final result mux
  assign alu_output = ({32{operation_add | operation_sub}} & add_sub_result)
    | ({32{operation_slt}} & slt_result)
    | ({32{operation_sltu}} & sltu_result)
    | ({32{operation_and}} & and_result)
    | ({32{operation_nor}} & nor_result)
    | ({32{operation_or}} & or_result)
    | ({32{operation_xor}} & xor_result)
    | ({32{operation_lui}} & lui_result)
    | ({32{operation_sll}} & sll_result)
    | ({32{operation_srl | operation_sra}} & sr_result);
endmodule
