module multiply_stage1 (
  input clock,
  input reset,
  input cpu_core_params::CpuData input1,
  input cpu_core_params::CpuData input2,
  input is_signed,
  output multiplier_params::Stage1ToStage2BusData stage1_to_stage2_bus
);
  import multiplier_params::*;
  wire [CPU_DATA_WIDTH / 2:0] wallace_input [CPU_DATA_WIDTH * 2];

  wire [CPU_DATA_WIDTH * 2 - 1:0] part_result [CPU_DATA_WIDTH / 2 + 1];
  wire [CPU_DATA_WIDTH / 2:0] neg_input1;

  assign stage1_to_stage2_bus = '{
    wallace_input: wallace_input,
    carry_input: neg_input1
  };

  wire [CPU_DATA_WIDTH:0] input1_result [3];
  wire [CPU_DATA_WIDTH + 2:0] input2_extended;

  assign input1_result[0] = {(CPU_DATA_WIDTH){1'b0}};
  assign input1_result[1] = {is_signed & input1[CPU_DATA_WIDTH - 1], input1};
  assign input1_result[2] = {input1, 1'b0};
  assign input2_extended = {{2{is_signed & input2[CPU_DATA_WIDTH - 1]}}, input2, 1'b0};

  generate
    for (genvar index = 0; index < CPU_DATA_WIDTH / 2 + 1; index++) begin
      wire [2:0] multiply;
      wire [1:0] select;
      wire [CPU_DATA_WIDTH:0] selected;
      wire [CPU_DATA_WIDTH * 2 - 1:0] non_negative_result;
      assign multiply = input2_extended[index * 2] + input2_extended[index * 2 + 1] + (input2_extended[index * 2 + 2] ? 3'b110 : 3'b000);
      assign select[0] = multiply[0];
      assign select[1] = multiply[1] & ~multiply[0];
      assign neg_input1[index] = multiply[2];
      assign selected = input1_result[select];
      assign non_negative_result = {{(32 - 2 * index){is_signed & selected[CPU_DATA_WIDTH]}}, selected, {(2 * index){1'b0}}};
      assign part_result[index] = neg_input1[index] ? ~non_negative_result : non_negative_result;
    end
  endgenerate

  generate
    for (genvar index1 = 0; index1 < CPU_DATA_WIDTH / 2 + 1; index1++) begin
      for (genvar index2 = 0; index2 < CPU_DATA_WIDTH * 2; index2++) begin
        assign wallace_input[index2][index1] = part_result[index1][index2];
      end
    end
  endgenerate
endmodule

module wallace_adder (
  input [16:0] added_values,
  input [13:0] carry_in,
  output result,
  output carry,
  output [13:0] carry_out
);
  wire [11:0] second_step_input;

  assign {carry_out[0], second_step_input[0]} = added_values[16] + added_values[15] + added_values[14];
  assign {carry_out[1], second_step_input[1]} = added_values[13] + added_values[12] + added_values[11];
  assign {carry_out[2], second_step_input[2]} = added_values[10] + added_values[9] + added_values[8];
  assign {carry_out[3], second_step_input[3]} = added_values[7] + added_values[6] + added_values[5];
  assign {carry_out[4], second_step_input[4]} = added_values[4] + added_values[3] + added_values[2];
  assign second_step_input[5] = added_values[1];
  assign second_step_input[6] = added_values[0];
  assign second_step_input[7] = carry_in[0];
  assign second_step_input[8] = carry_in[1];
  assign second_step_input[9] = carry_in[2];
  assign second_step_input[10] = carry_in[3];
  assign second_step_input[11] = carry_in[4];

  wire [5:0] third_step_input;
  assign {carry_out[5], third_step_input[0]} = second_step_input[0] + second_step_input[1] + second_step_input[2];
  assign {carry_out[6], third_step_input[1]} = second_step_input[3] + second_step_input[4] + second_step_input[5];
  assign {carry_out[7], third_step_input[2]} = second_step_input[6] + second_step_input[7] + second_step_input[8];
  assign {carry_out[8], third_step_input[3]} = second_step_input[9] + second_step_input[10] + second_step_input[11];
  assign third_step_input[4] = carry_in[5];
  assign third_step_input[5] = carry_in[6];

  wire [5:0] fourth_step_input;
  assign {carry_out[9], fourth_step_input[0]} = third_step_input[0] + third_step_input[1] + third_step_input[2];
  assign {carry_out[10], fourth_step_input[1]} = third_step_input[3] + third_step_input[4] + third_step_input[5];
  assign fourth_step_input[2] = carry_in[7];
  assign fourth_step_input[3] = carry_in[8];
  assign fourth_step_input[4] = carry_in[9];
  assign fourth_step_input[5] = carry_in[10];

  wire [2:0] fifth_step_input;
  assign {carry_out[11], fifth_step_input[0]} = fourth_step_input[0] + fourth_step_input[1] + fourth_step_input[2];
  assign {carry_out[12], fifth_step_input[1]} = fourth_step_input[3] + fourth_step_input[4] + fourth_step_input[5];
  assign fifth_step_input[2] = carry_in[11];

  wire [2:0] sixth_step_input;
  assign {carry_out[13], sixth_step_input[0]} = fifth_step_input[0] + fifth_step_input[1] + fifth_step_input[2];
  assign sixth_step_input[1] = carry_in[12];
  assign sixth_step_input[2] = carry_in[13];
  assign {carry, result} = sixth_step_input[0] + sixth_step_input[1] + sixth_step_input[2];
endmodule

module multiply_stage2 (
  input clock,
  input reset,
  input multiplier_params::Stage1ToStage2BusData stage1_to_stage2_bus,
  output multiplier_params::MultiplyResultData result
);
  import multiplier_params::*;
  Stage1ToStage2BusData from_stage1_data;
  wire [CPU_DATA_WIDTH * 2 - 1:0] adder_input1;
  wire [CPU_DATA_WIDTH * 2:0] adder_input2;
  wire [13:0] carry_values [CPU_DATA_WIDTH * 2 + 1];

  assign result = adder_input1 + adder_input2 + from_stage1_data.carry_input[0];

  assign carry_values[0] = from_stage1_data.carry_input[15:2];
  assign adder_input2[0] = from_stage1_data.carry_input[1];
  generate
    for (genvar i = 0; i < CPU_DATA_WIDTH * 2; i++) begin
      wallace_adder adder(
        .added_values(from_stage1_data.wallace_input[i]),
        .carry_in(carry_values[i]),
        .result(adder_input1[i]),
        .carry(adder_input2[i + 1]),
        .carry_out(carry_values[i + 1])
      );
    end
  endgenerate

  always_ff @(posedge clock) begin
    from_stage1_data <= stage1_to_stage2_bus;
  end
endmodule

module multiplier (
  input clock,
  input reset,
  input cpu_core_params::CpuData input1,
  input cpu_core_params::CpuData input2,
  input is_signed,
  output multiplier_params::MultiplyResultData result
);
  multiplier_params::Stage1ToStage2BusData stage1_to_stage2_bus;

  multiply_stage1 stage1(
    .clock,
    .reset,
    .input1,
    .input2,
    .is_signed,
    .stage1_to_stage2_bus
  );

  multiply_stage2 stage2(
    .clock,
    .reset,
    .stage1_to_stage2_bus,
    .result
  );
endmodule
