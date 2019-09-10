`default_nettype none

module show_sw(
  input wire clock,
  input wire reset_,
  input wire [3:0] switch_,
  output wire [7:0] num_selector_,
  output wire [6:0] num_output,
  output wire [3:0] led
);
// 1. get switch data
// 2. show switch data in digital number:
//   only show 0~9
//   if >=10, digital number keep old data.
// 3. show previous switch data in led.
//   can show any switch data.
  reg [3:0] got_data_1;
  reg [3:0] got_data_2;
  reg [3:0] prev_data;

// new value
  always @(posedge clock) begin
    got_data_1 <= ~switch_;     // BUG delete 
  end

  always @(posedge clock)begin
    got_data_2 <= got_data_1;  // BUG should not use block assign
  end

//previous value
  always @(posedge clock) begin
    if (!reset_) begin
      prev_data <= 4'd0;
    end else if (got_data_2 != got_data_1) begin
      prev_data <= got_data_2;
    end
  end

//show led: previous value
  assign led = ~prev_data;

//show number: new value
  show_num u_show_num(
    .clock(clock),
    .reset_(reset_),
    .to_show_data(got_data_1),
    .num_selector_(num_selector_), // BUG name not correct
    .num_output(num_output)
  );
endmodule: show_sw

module show_num(
  input wire clock,
  input wire reset_,
  input wire [3:0] to_show_data,
  output wire [7:0] num_selector_,
  output reg [6:0] num_output
);
//digital number display
  assign num_selector_ = 8'b0111_1111;

  wire [6:0] next_num_output;

  always @(posedge clock) begin
    if (!reset_) begin
      num_output <= 7'b0000000;
    end else begin
      num_output <= next_num_output;
    end
  end

//keep unchange if show_dtaa>=10
  wire [6:0] previous_output;
  assign previous_output = num_output; // BUG Meaningless add

  assign next_num_output =
    to_show_data == 4'd0 ? 7'b1111110:   // 0
    to_show_data == 4'd1 ? 7'b0110000:   // 1
    to_show_data == 4'd2 ? 7'b1101101:   // 2
    to_show_data == 4'd3 ? 7'b1111001:   // 3
    to_show_data == 4'd4 ? 7'b0110011:   // 4
    to_show_data == 4'd5 ? 7'b1011011:   // 5
    to_show_data == 4'd6 ? 7'b1011111:   // BUG: 6 not defined
    to_show_data == 4'd7 ? 7'b1110000:   // 7
    to_show_data == 4'd8 ? 7'b1111111:   // 8
    to_show_data == 4'd9 ? 7'b1111011:   // 9
    previous_output;
endmodule: show_num
