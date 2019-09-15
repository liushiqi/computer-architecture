module decoder_5_to_32(
  input [4:0] in,
  output [31:0] out
);
  generate
    for (genvar i = 0; i < 32; i++) begin : generator_for_decoder_5_to_32
      assign out[i] = (in == i);
    end : generator_for_decoder_5_to_32
  endgenerate
endmodule

module decoder_6_to_64(
  input [5:0] in,
  output [63:0] out
);
  generate
    for (genvar i = 0; i < 64; i++) begin : generator_for_decoder_6_to_64
      assign out[i] = (in == i);
    end : generator_for_decoder_6_to_64
  endgenerate
endmodule
