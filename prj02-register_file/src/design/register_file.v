`timescale 1ns / 1ps

`default_nettype none

module register_file(
  input wire clock,
  input wire [4:0] read_address_1,
  output wire [31:0] read_data_1,
  input wire [4:0] read_address_2,
  output wire [31:0] read_data_2,
  input wire write_enabled,
  input wire [4:0] write_address,
  input wire [31:0] write_data
);
  reg [31:0] data[31:0];

  // write
  always @(posedge clock) begin
    if (write_enabled) begin
      data[write_address] <= write_data;
    end
  end

  // read port 1
  assign read_data_1 = (read_address_1 == 5'b0) ? 32'b0 : data[read_address_1];
  // read port 2
  assign read_data_2 = (read_address_2 == 5'b0) ? 32'b0 : data[read_address_2];
endmodule
