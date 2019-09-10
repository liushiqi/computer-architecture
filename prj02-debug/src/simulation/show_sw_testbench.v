module show_sw_testbench;
  reg clk;
  reg resetn;
  reg [3:0] switch;  //input

  initial begin
    #100;
    clk = 1'b0;
    resetn = 1'b0;

    #500;
    resetn = 1'b1;
  end
  always #5 clk = ~clk;

//set switch
  initial begin
    #100;
    switch = 4'hf;
    #500;
    #1;
    switch = 4'h8;  //~switch: 7
    #100;
    switch = 4'h9;  //~switch: 6
    #100;
    switch = 4'he;  //~switch: 1
    #100;
    switch = 4'h2;  //~switch: d
    #100;
    switch = 4'h0;  //~switch: f
    #100;
    $finish;
  end

  show_sw u_show_sw(
    .clock(clk),
    .reset_(resetn),
    .switch_(switch),  //input
    .num_selector_(), //new value
    .num_output(),
    .led()            //previous value
  );
endmodule
