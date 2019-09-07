`timescale 1ns / 1ps

`default_nettype none

module register_file_testbench();
  reg clock;

  reg [4:0] read_address_1;
  wire [31:0] read_data_1;
  reg [4:0] read_address_2;
  wire [31:0] read_data_2;
  reg write_enabled;
  reg [4:0] write_address;
  reg [31:0] write_data;

  reg [ 3:0] task_phase;

  register_file u_regfile(.*);

  // clock
  initial begin
    clock = 1'b1;
  end

  always #5 clock = ~clock;

  initial begin
    read_address_1 =  5'd0;
    read_address_2 =  5'd0;
    write_address  =  5'd0;
    write_data  = 32'd0;
    write_enabled     =  1'd0;
    task_phase =  4'd0;
    #2000;

    $display("=============================");
    $display("Test Begin");
    #1;

    // Part 0 Begin
    #10;
    task_phase = 4'd0;
    write_enabled         = 1'b0;
    write_address      = 5'd1;
    write_data      = 32'hffffffff;
    read_address_1     = 5'd1;
    #10;
    write_enabled         = 1'b1;
    write_address      = 5'd1;
    write_data      = 32'h1111ffff;
    #10;
    write_enabled         = 1'b0;
    read_address_1     = 5'd2;
    read_address_2     = 5'd1;
    #10;
    read_address_1     = 5'd1;
    #200;

    // Part 1 Begin
    #10;
    task_phase = 4'd1;
    write_enabled         = 1'b1;
    write_data      = 32'h0000ffff;
    write_address      =  5'h10;
    read_address_1     =  5'h10;
    read_address_2     =  5'h0f;
    #10;
    write_data      = 32'h1111ffff;
    write_address      =  5'h11;
    read_address_1     =  5'h11;
    read_address_2     =  5'h10;
    #10;
    write_data      = 32'h2222ffff;
    write_address      =  5'h12;
    read_address_1     =  5'h12;
    read_address_2     =  5'h11;
    #10;
    write_data      = 32'h3333ffff;
    write_address      =  5'h13;
    read_address_1     =  5'h13;
    read_address_2     =  5'h12;
    #10;
    write_data      = 32'h4444ffff;
    write_address      =  5'h14;
    read_address_1     =  5'h14;
    read_address_2     =  5'h13;
    #10;
    read_address_1     =  5'h15;
    read_address_2     =  5'h14;
    #10;

    #200;
    
    // Part 2 Begin
    #10;
    task_phase = 4'd2;
    write_enabled         = 1'b1;
    read_address_1     =  5'h10;
    read_address_2     =  5'h0f;
    #10;
    read_address_1     =  5'h11;
    read_address_2     =  5'h10;
    #10;
    read_address_1     =  5'h12;
    read_address_2     =  5'h11;
    #10;
    read_address_1     =  5'h13;
    read_address_2     =  5'h12;
    #10;
    read_address_1     =  5'h14;
    read_address_2     =  5'h13;
    #10;

    #50;
    $display("TEST END");
    $finish;
  end
endmodule
