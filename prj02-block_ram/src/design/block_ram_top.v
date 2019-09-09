`default_nettype none

module block_ram_top(
  input wire clock,
  input wire [15:0] ram_address,
  input wire [31:0] ram_write_data,
  input wire ram_write_enabled,
  output wire [31:0] ram_read_data
);
  block_ram block_ram(
    .clka(clock),
    .wea(ram_write_enabled),
    .addra(ram_address),
    .dina(ram_write_data),
    .douta(ram_read_data)
  );
endmodule
