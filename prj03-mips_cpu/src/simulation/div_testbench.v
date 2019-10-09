`timescale 1ns / 1ps

module div_testbench;
  // Inputs
  reg clock;
  reg reset;
  wire divide_request_valid;
  reg is_signed_input;
  reg [31:0] input1;
  reg [31:0] input2;

  // Outputs
  wire [31:0] divide_result;
  wire [31:0] divide_remain;
  wire divide_result_valid;

  // Instantiate the Unit Under Test
  divider divider (
    .clock(clock),
    .reset(reset),
    .divide_request_valid(divide_request_valid),
    .is_signed_input(is_signed_input),
    .input1(input1),
    .input2(input2),
    .divide_result(divide_result),
    .divide_remain(divide_remain),
    .divide_result_valid(divide_result_valid)
  );

  // Initialize Inputs
  initial begin
    reset = 1;
    #100;
    reset = 0;
  end
  
  initial begin
    clock = 1'b0;
  end

  always #5 clock = ~clock;

  //产生除法命令,正在进行除法
  reg div_is_run;
  integer wait_clk;
  initial begin
    div_is_run <= 1'b0;
    forever begin @(posedge clock);
      if (reset || divide_result_valid) begin
        div_is_run <= 1'b0;
        wait_clk <= {$random}%4;
      end else begin
        repeat (wait_clk) @(posedge clock);
        div_is_run <= 1'b1;
        wait_clk <= 0;
      end
    end
  end

  //随机生成有符号乘法控制信号和乘数
  assign divide_request_valid = div_is_run;
  always @(posedge clock) begin
    if (reset || divide_result_valid) begin
      is_signed_input <= 1'b0;
      input1 <= 32'd0;
      input2 <= 32'd1;
    end else if (!div_is_run) begin
      is_signed_input <= {$random}%2;
      input1 <= $random;
      input2 <= $random; //被除数随机产生 0 的概率很小,基本可忽略
    end
  end

  //-----{计算参考结果}begin
  //第一步,求 input1 和 input2 的绝对值,并判断商和余数的符号
  wire x_signed = input1[31] & is_signed_input;
  //input1 的符号位,做无符号时认为是 0
  wire y_signed = input2[31] & is_signed_input;
  //input2 的符号位,做无符号时认为是 0
  wire [31:0] x_abs;
  wire [31:0] y_abs;
  assign x_abs = ({32{x_signed}}^input1) + x_signed;
  //此处异或运算必须加括号,
  assign y_abs = ({32{y_signed}}^input2) + y_signed;
  //因为 verilog 中+的优先级更高
  wire s_ref_signed = (input1[31]^input2[31]) & is_signed_input;//运算结果商的符号位,做无符号时认为是 0
  wire r_ref_signed = input1[31] & is_signed_input;
  //运算结果余数的符号位,做无符号时认为是 0

  //第二步,求得商和余数的绝对值
  reg [31:0] s_ref_abs;
  reg [31:0] r_ref_abs;
  always @(clock) begin
    s_ref_abs <= x_abs/y_abs;
    r_ref_abs <= x_abs-s_ref_abs*y_abs;
  end

  //第三步,依据商和余数的符号位调整
  wire [31:0] s_ref;
  wire [31:0] r_ref;
  //此处异或运算必须加括号,因为 verilog 中+的优先级更高
  assign s_ref = ({32{s_ref_signed}}^s_ref_abs) + {30'd0,s_ref_signed};
  assign r_ref = ({32{r_ref_signed}}^r_ref_abs) + r_ref_signed;
  //-----{计算参考结果}end

  //判断结果是否正确
  wire s_ok;
  wire r_ok;
  assign s_ok = s_ref==divide_result;
  assign r_ok = r_ref==divide_remain;
  reg [5:0] time_out;
  //输出结果,将各 32 位(不论是有符号还是无符号数)扩展成 33 位有符号数,以便以 10 进制形式打印
  wire signed [32:0] x_d = {is_signed_input & input1[31], input1};
  wire signed [32:0] y_d = {is_signed_input & input2[31], input2};
  wire signed [32:0] s_d = {is_signed_input & divide_result[31], divide_result};
  wire signed [32:0] r_d = {is_signed_input & divide_remain[31], divide_remain};
  wire signed [32:0] s_ref_d = {is_signed_input & s_ref[31], s_ref};
  wire signed [32:0] r_ref_d = {is_signed_input & r_ref[31], r_ref};

  always @(posedge clock) begin
    if (divide_result_valid && divide_request_valid) begin
      if (s_ok && r_ok) begin
        $display("[time @%t]: input1=%x, input2=%x, signed=%x, divide_result=%x, divide_remain=%x, s_OK=%b, r_OK=%b", $time, x_d, y_d, is_signed_input, s_d, r_d, s_ok, r_ok);
      end else begin
        $display("[time @%t]Error: input1=%x, input2=%x, signed=%x, divide_result=%x, divide_remain=%x, s_ref=%x, r_ref=%x,s_OK=%b, r_OK=%b", $time, x_d, y_d, is_signed_input, s_d, r_d, s_ref_d, r_ref_d, s_ok, r_ok);
        $finish;
      end
    end
  end

  always @(posedge clock) begin
    if (reset || !div_is_run || divide_result_valid) begin
      time_out <= 6'd0;
    end else begin
      time_out <= time_out + 1'b1;
    end
  end

  always @(posedge clock) begin
    if (time_out == 6'd35) begin
      $display("Error: divide_request_valid no end in 34 clk!");
      $finish;
    end
  end

  initial begin
    #1000000 $display("Test passed!");
    $finish;
  end
endmodule
