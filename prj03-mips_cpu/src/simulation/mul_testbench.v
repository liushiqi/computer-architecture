`timescale 1ns / 1ps

module mul_testbench;
  // inputs
  reg clock;
  reg reset;
  reg is_signed;
  reg [31:0] input1;
  reg [31:0] input2;
  // outputs
  wire signed [63:0] result;
  
  wire ok;

  // Instantiate the Unit Under Test
  multiplier multiplier (
    .clock(clock),
    .reset(reset),
    .is_signed(is_signed),
    .input1(input1),
    .input2(input2),
    .result(result)
  );

  initial begin
    // initialize inputs
    clock = 0;
    reset = 1;
    is_signed = 0;
    input1 = 0;
    input2 = 0;
    #100;
    reset = 0;
  end

  always #5 clock = ~clock;

  // 产生随机乘数和有符号控制信号
  always @(posedge clock) begin
    input1 <= $random;
    input2 <= $random; // $random 为系统任务,产生一个随机的 32 位有符号数
    is_signed <= {$random}%2; // 加了拼接符,{$random}产生一个非负数,除 2 取余得到 0 或 1
  end

  // 寄存乘数和有符号乘控制信号,因为是两级流水,故存一拍
  reg [31:0] input1_ref;
  reg [31:0] input2_ref;
  reg is_signed_ref;
  reg [31:0] count;

  always @(posedge clock) begin
    if (reset) begin
      input1_ref <= input1;
      input2_ref <= input2;
      is_signed_ref <= is_signed;
      count <= 32'b0;
    end else begin
      input1_ref <= input1;
      input2_ref <= input2;
      is_signed_ref <= is_signed;
      count <= count + 1;
    end
  end

  // 参考结果
  wire signed [63:0] result_ref;
  wire signed [32:0] input1_extended;
  wire signed [32:0] input2_extended;
  assign input1_extended = {is_signed_ref & input1_ref[31], input1_ref};
  assign input2_extended = {is_signed_ref & input2_ref[31], input2_ref};
  assign result_ref = input1_extended * input2_extended;
  assign ok = (result_ref == result);

  // 打印运算结果
  initial begin
    $monitor("input1 = %x, input2 = %x, signed = %x, result = %x, ok = %x", input1_ref, input2_ref, is_signed_ref, result, ok);
  end

  // 判断结果是否正确
  always @(posedge clock) begin
    if (!reset && ok !== 1) begin
      $display("Error : input1 = %x, input2 = %x, signed = %x result = %x, result_ref = %x, ok = %x", input1_ref, input2_ref, is_signed_ref, result, result_ref, ok);
      $finish;
    end
  end

  initial begin
    #100000 $display("Test passed!");
    $finish;
  end
endmodule
