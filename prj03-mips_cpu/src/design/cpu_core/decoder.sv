module decoder #(
  parameter INPUT_WIDTH = 5,
  parameter OUTPUT_WIDTH = 2 ** INPUT_WIDTH
)(
  input [INPUT_WIDTH - 1:0] in,
  output [OUTPUT_WIDTH - 1:0] out
);
  generate
    for (genvar i = 0; i < OUTPUT_WIDTH; i++) begin : decoder_for_loop
      assign out[i] = (in == i);
    end : decoder_for_loop
  endgenerate
endmodule
