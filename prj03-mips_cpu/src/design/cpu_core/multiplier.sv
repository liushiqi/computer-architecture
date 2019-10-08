module multiply_stage1 (
  input cpu_core_params::CpuData input1,
  input cpu_core_params::CpuData input2,
  input is_signed,
  output 
);
  import multiplier_params::*;
  wire [CPU_DATA_WIDTH / 2:0] wallace_input [CPU_DATA_WIDTH * 2 + 2];

  wire [CPU_DATA_WIDTH * 2 + 1:0] part_result [CPU_DATA_WIDTH / 2 + 1];
  wire [CPU_DATA_WIDTH / 2:0] neg_input1;

  wire [CPU_DATA_WIDTH : 0] input1_extended;
  wire [CPU_DATA_WIDTH + 1 : 0] input1_result [3];
  wire [CPU_DATA_WIDTH + 1 : 0] input2_extended;
  assign input1_extended = {is_signed & input1[CPU_DATA_WIDTH], input1};
  assign input1_result[0] = {(CPU_DATA_WIDTH + 1){1'b0}};
  assign input1_result[1] = {is_signed & input1[CPU_DATA_WIDTH], input1_extended};
  assign input1_result[2] = {input1_extended, 1'b0};
  assign input2_extended = {is_signed & input2[CPU_DATA_WIDTH], input2, 0};

  generate
    for (genvar index = 0; index < CPU_DATA_WIDTH / 2 + 1; index++) begin
      wire [2:0] multiply;
      wire [1:0] select;
      wire [CPU_DATA_WIDTH + 1 : 0] non_negative_result;
      assign multiply = input2_extended[index * 2] + input2_extended[index * 2 + 1] + (input2_extended[index * 2 + 2] ? 3'b110 : 3'b000);
      assign select[0] = multiply[0];
      assign select[1] = multiply[1] & ~multiply[0];
      assign non_negative_result = input1_result[select];
      assign neg_input1[index] = multiply[2];
      assign part_result[index] = {{(32 - 2 * index){neg_input1[index] & is_signed & input1[CPU_DATA_WIDTH]}}, (neg_input1 ? ~non_negative_result : non_negative_result), {(2 * index){1'b0}}};
    end
  endgenerate

  generate
    for (genvar index1 = 0; index1 < CPU_DATA_WIDTH / 2 + 1; index1++) begin
      for (genvar index2 = 0; index2 < CPU_DATA_WIDTH * 2 + 2; index2++) begin
        assign wallace_input[index2][index1] = part_result[index1][index2];
      end
    end
  endgenerate
endmodule

module multiplier (
  input clock,
  input reset,
  input cpu_core_params::CpuData input1,
  input cpu_core_params::CpuData input2,
  input is_signed,
  output multiplier_params::MultiplyResultData result
);
endmodule
