`timescale 1ns/1ps

`default_nettype none

module led #(
  parameter COUNT_1S = 27'd38_196_600
)(
  input wire clock,
  input wire reset,
  output reg [15:0] led_controller
);
  reg [26:0] count;
  wire count_eq_1s;

  assign count_eq_1s = count == COUNT_1S;

  always @(posedge clock) begin
    if (!reset) begin
      count <= 27'd0;
    end else if (count_eq_1s) begin
      count <= 27'd0;
    end else begin
      count <= count + 1'b1;
    end
  end

  always @(posedge clock) begin
    if (!reset) begin
      led_controller <= 16'hfffe;
    end else if (count_eq_1s) begin
      led_controller <= {led_controller[14:0], led_controller[15]};
    end
  end
endmodule
