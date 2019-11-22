module register_file(
  input clock,
  input [4:0] read_address_1,
  output cpu_core_params::cpu_data_t read_data_1,
  input [4:0] read_address_2,
  output cpu_core_params::cpu_data_t read_data_2,
  input write_enabled,
  input [4:0] write_address,
  input [3:0] write_strobe,
  input cpu_core_params::cpu_data_t write_data
);
  cpu_core_params::cpu_data_t data [31:1];
  cpu_core_params::cpu_data_t read_data [31:0];

  assign read_data[0] = 32'b0;
  generate
    for (genvar i = 1; i <= 31; i++)
      assign read_data[i] = data[i];
  endgenerate

  // write
  always_ff @(posedge clock) begin : writing
    if (write_enabled && (write_address != 4'b0)) begin
      data[write_address][7:0] <= write_strobe[0] ? write_data[7:0] : data[write_address][7:0];
      data[write_address][15:8] <= write_strobe[1] ? write_data[15:8] : data[write_address][15:8];
      data[write_address][23:16] <= write_strobe[2] ? write_data[23:16] : data[write_address][23:16];
      data[write_address][31:24] <= write_strobe[3] ? write_data[31:24] : data[write_address][31:24];
    end
  end : writing

  // read output
  assign read_data_1 = read_data[read_address_1];
  assign read_data_2 = read_data[read_address_2];
endmodule: register_file
