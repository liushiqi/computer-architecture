`include "coprocessor_params.svh"

module coprocessor0 (
  input clock,
  input reset,
  input coprocessor0_params::WBToCP0Data wb_to_cp0_data_bus,
  output coprocessor0_params::CP0ToIFData cp0_to_if_data_bus,
  output cpu_core_params::CpuData cp0_read_data
);
  import coprocessor0_params::*;
  wire [31:0] address_register_decoded;
  wire [7:0] address_select_decoded;

  decoder #(.INPUT_WIDTH(5)) u_address_register_decoder(.in(wb_to_cp0_data_bus.address_register), .out(address_register_decoded));
  decoder #(.INPUT_WIDTH(3)) u_address_select_decoder(.in(wb_to_cp0_data_bus.address_select), .out(address_select_decoded));
  
  wire address_status;
  wire address_cause;
  wire address_epc;

  assign address_status = address_register_decoded[5'h0c] & address_select_decoded[3'h0];
  assign address_cause = address_register_decoded[5'h0d] & address_select_decoded[3'h0];
  assign address_epc = address_register_decoded[5'h0e] & address_select_decoded[3'h0];

  StatusData status_value;
  StatusData status_write_value;
  reg [7:0] status_interrupt_mask;
  reg status_exception_level;
  reg status_interrupt_enabled;
  assign status_write_value = StatusData'(wb_to_cp0_data_bus.write_data);
  assign status_value = '{
    zero1: 9'b0,
    boot_exception_vector: 1'b1,
    zero2: 6'b0,
    interrupt_mask: status_interrupt_mask,
    zero3: 6'b0,
    exception_level: status_exception_level,
    interrupt_enabled: status_interrupt_enabled
  };
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.write_enabled && address_status) begin
      status_interrupt_mask <= status_write_value.interrupt_mask;
    end
  end
  always_ff @(posedge clock) begin
    if (reset) begin
      status_exception_level <= 1'b0;
    end else if (wb_to_cp0_data_bus.exception_valid) begin
      status_exception_level <= 1'b1;
    end else if (wb_to_cp0_data_bus.eret_flush) begin
      status_exception_level <= 1'b0;
    end else if (wb_to_cp0_data_bus.write_enabled && address_status) begin
      status_exception_level <= status_write_value.exception_level;
    end
  end
  always_ff @(posedge clock) begin
    if (reset) begin
      status_interrupt_enabled <= 0;
    end else if (wb_to_cp0_data_bus.write_enabled && address_status) begin
      status_interrupt_enabled <= status_write_value.interrupt_enabled;
    end
  end

  CauseData cause_value;
  CauseData cause_write_value;
  reg cause_in_delay_slot;
  reg cause_timer_interrupt;
  reg [5:0] cause_hardware_interrupt;
  reg [1:0] cause_software_interrupt;
  reg [4:0] cause_exception_code;
  assign cause_write_value = CauseData'(wb_to_cp0_data_bus.write_data);
  assign cause_value = '{
    in_delay_slot: cause_in_delay_slot,
    timer_interrupt: cause_timer_interrupt,
    zero1: 14'b0,
    hardware_interrupt: cause_hardware_interrupt,
    software_interrupt: cause_software_interrupt,
    zero2: 1'b0,
    exception_code: cause_exception_code,
    zero3: 2'b0
  };
  always_ff @(posedge clock) begin
    if (reset) begin
      cause_in_delay_slot <= 1'b0;
    end else if (wb_to_cp0_data_bus.exception_valid && status_value.exception_level) begin
      cause_in_delay_slot <= wb_to_cp0_data_bus.in_delay_slot;
    end
  end
  always_ff @(posedge clock) begin
    if (reset) begin
      cause_timer_interrupt <= 1'b0;
    end
  end
  always_ff @(posedge clock) begin
    if (reset) begin
      cause_hardware_interrupt <= 6'b0;
    end
  end
  always_ff @(posedge clock) begin
    if (reset) begin
      cause_software_interrupt <= 2'b0;
    end else if (wb_to_cp0_data_bus.write_enabled && address_cause) begin
      cause_software_interrupt <= cause_write_value.software_interrupt;
    end
  end
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.exception_valid) begin
      cause_exception_code <= wb_to_cp0_data_bus.exception_code;
    end
  end

  EPCData epc_value;
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.exception_valid && !status_value.exception_level) begin
      epc_value <= wb_to_cp0_data_bus.in_delay_slot ? (wb_to_cp0_data_bus.exception_address - 4) : wb_to_cp0_data_bus.exception_address;
    end else if (wb_to_cp0_data_bus.write_enabled && address_epc) begin
      epc_value <= wb_to_cp0_data_bus.write_data;
    end
  end

  assign cp0_read_data =
    ({CPU_DATA_WIDTH{address_status}} & CpuData'(status_value)) |
    ({CPU_DATA_WIDTH{address_cause}} & CpuData'(cause_value)) |
    ({CPU_DATA_WIDTH{address_epc}} & CpuData'(epc_value));
  assign cp0_to_if_data_bus = '{
    exception_address: epc_value
  };
endmodule : coprocessor0