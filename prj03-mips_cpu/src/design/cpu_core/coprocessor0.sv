`include "coprocessor_params.svh"

module coprocessor0 (
  input clock,
  input reset,
  input coprocessor0_params::WBToCP0Data wb_to_cp0_data_bus,
  output cpu_core_params::CpuData cp0_read_data
);
  import coprocessor0_params::*;
  wire [31:0] address_register_decoded;
  wire [7:0] address_select_decoded;

  decoder #(.INPUT_WIDTH(5)) u_address_register_decoder(.in(address_register), .out(address_register_decoded));
  decoder #(.INPUT_WIDTH(3)) u_address_select_decoder(.in(address_select), .out(address_select_decoded));
  
  wire address_status;
  wire address_cause;
  wire address_epc;

  assign address_status = address_register_decoded[5'h0c] & address_select_decoded[3'h0];
  assign address_cause = address_register_decoded[5'h0d] & address_select_decoded[3'h0];
  assign address_epc = address_register_decoded[5'h0e] & address_select_decoded[3'h0];

  StatusData status_value;
  StatusData status_write_value;
  

  CauseData cause_value;
  CauseData cause_write_value;

  EPCData epc_value;
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.write_enabled & wb_to_cp0_data_bus.address_epc) begin
      epc_value <= wb_to_cp0_data_bus.write_data;
    end
  end
endmodule;