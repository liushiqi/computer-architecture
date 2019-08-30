`timescale 1ns / 1ps

module testbench;
  reg clock;
  reg reset;
  wire [15:0] led_controller;

  initial begin
    clock = 0;
    reset = 1'b0;
    #200;
    reset = 1'b1;
  end

  always #5 clock = ~clock;

  led #(
    .COUNT_1S(27'd100)
  ) u_led (
    .clock(clock),
    .reset(reset),
    .led_controller(led_controller)
  );
endmodule
