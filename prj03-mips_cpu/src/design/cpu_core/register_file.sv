module register_file(
  input clock,
  input reset,
  input [4:0] read_address_1,
  output cpu_core_params::CpuData read_data_1,
  input [4:0] read_address_2,
  output cpu_core_params::CpuData read_data_2,
  input write_enabled,
  input [4:0] write_address,
  input cpu_core_params::CpuData write_data
);
  cpu_core_params::CpuData data [31:1];
  cpu_core_params::CpuData read_data [31:0];

  assign read_data[0] = 32'b0;
  generate
    for (genvar i = 1; i <= 31; i++)
      assign read_data[i] = data[i];
  endgenerate

// write
  always_ff @(posedge clock) begin : writing
    if (write_enabled & (write_address != 0))
      data[write_address] <= write_data;
  end : writing

// read output
  assign read_data_1 = read_data[read_address_1];
  assign read_data_2 = read_data[read_address_2];
endmodule : register_file
