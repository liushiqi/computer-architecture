`timescale 1ns/1ps

module block_ram_testbench();
  reg clock;
  reg ram_write_enabled;
  reg [15:0] ram_address;
  reg [31:0] ram_write_data;
  wire [31:0] ram_read_data;
  reg [3:0] task_phase;

  block_ram_top u_ram_top(.*);

  initial begin
    clock = 1'b1;
  end

  always #5 clock = ~clock;

  initial begin
    ram_address = 16'd0;
    ram_write_data = 32'd0;
    ram_write_enabled = 1'd0;
    task_phase = 4'd0;
    #2000;

    $display("=============================");
    $display("Test Begin");
    #1;
    // Part 0 Begin
    #10;
    task_phase = 4'd0;
    ram_write_enabled = 1'b0;
    ram_address = 16'hf0;
    ram_write_data = 32'hffffffff;
    #10;
    ram_write_enabled = 1'b1;
    ram_address = 16'hf0;
    ram_write_data = 32'h11223344;
    #10;
    ram_write_enabled = 1'b0;
    ram_address = 16'hf1;
    #10;
    ram_write_enabled = 1'b0;
    ram_address = 16'hf0;

    #200;
    // Part 1 Begin
    #10;
    task_phase = 4'd1;
    ram_write_enabled = 1'b1;
    ram_write_data = 32'hff00;
    ram_address = 16'hf0;
    #10;
    ram_write_data = 32'hff11;
    ram_address = 16'hf1;
    #10;
    ram_write_data = 32'hff22;
    ram_address = 16'hf2;
    #10;
    ram_write_data = 32'hff33;
    ram_address = 16'hf3;
    #10;
    ram_write_data = 32'hff44;
    ram_address = 16'hf4;
    #10;

    #200;
    // Part 2 Begin
    #10;
    task_phase = 4'd2;
    ram_write_enabled = 1'b0;
    ram_address = 16'hf0;
    ram_write_data = 32'hffffffff;
    #10;
    ram_address = 16'hf1;
    #10;
    ram_address = 16'hf2;
    #10;
    ram_address = 16'hf3;
    #10;
    ram_address = 16'hf4;
    #10;

    #50;
    $display("TEST END");
    $finish;
  end
endmodule
