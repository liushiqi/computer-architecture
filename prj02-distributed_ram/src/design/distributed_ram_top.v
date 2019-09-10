`default_nettype none

module distributed_ram_top(
  input wire clock,
  input wire [15:0] ram_address,
  input wire [31:0] ram_write_data,
  input wire ram_write_enabled,
  output wire [31:0] ram_read_data
);
  distributed_ram distributed_ram(
    .clk(clock),
    .we(ram_write_enabled),
    .a(ram_address),
    .d(ram_write_data),
    .spo(ram_read_data)
  );
endmodule
