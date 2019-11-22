`include "include/coprocessor_params.svh"

module coprocessor0(
  input clock,
  input reset,
  input wb_stage_params::wb_to_cp0_bus_t wb_to_cp0_data_bus,
  output coprocessor0_params::cp0_to_if_bus_t cp0_to_if_data_bus,
  output cpu_core_params::cpu_data_t cp0_read_data,
  input [5:0] hardware_interrupt
);
  import coprocessor0_params::*;
  wire [31:0] address_register_decoded;
  wire [7:0] address_select_decoded;

  decoder #(.INPUT_WIDTH(5)) u_address_register_decoder(.in(wb_to_cp0_data_bus.address_register), .out(address_register_decoded));
  decoder #(.INPUT_WIDTH(3)) u_address_select_decoder(.in(wb_to_cp0_data_bus.address_select), .out(address_select_decoded));

  wire address_badvaddr;
  wire address_count;
  wire address_compare;
  wire address_status;
  wire address_cause;
  wire address_epc;

  assign address_badvaddr = address_register_decoded[5'h08] & address_select_decoded[3'h0];
  assign address_count = address_register_decoded[5'h09] & address_select_decoded[3'h0];
  assign address_compare = address_register_decoded[5'h0b] & address_select_decoded[3'h0];
  assign address_status = address_register_decoded[5'h0c] & address_select_decoded[3'h0];
  assign address_cause = address_register_decoded[5'h0d] & address_select_decoded[3'h0];
  assign address_epc = address_register_decoded[5'h0e] & address_select_decoded[3'h0];

  badvaddr_t badvaddr_value;
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.exception_valid && wb_to_cp0_data_bus.is_address_fault) begin
      badvaddr_value <= wb_to_cp0_data_bus.badvaddr_value;
    end
  end

  count_t count_value;
  reg tick;
  always_ff @(posedge clock) begin
    if (reset) begin
      tick <= 1'b0;
    end else if (wb_to_cp0_data_bus.write_enabled && address_count) begin
      tick <= 1'b0;
    end else begin
      tick <= ~tick;
    end
  end
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.write_enabled && address_count) begin
      count_value <= wb_to_cp0_data_bus.write_data;
    end else if (tick) begin
      count_value <= count_value + 1'b1;
    end
  end

  compare_t compare_value;
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.write_enabled && address_compare) begin
      compare_value <= wb_to_cp0_data_bus.write_data;
    end
  end

  status_t status_value;
  status_t status_write_value;
  reg [7:0] status_interrupt_mask;
  reg status_exception_level;
  reg status_interrupt_enabled;
  assign status_write_value = status_t'(wb_to_cp0_data_bus.write_data);
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

  cause_t cause_value;
  cause_t cause_write_value;
  reg cause_in_delay_slot;
  reg cause_timer_interrupt;
  reg [5:0] cause_hardware_interrupt;
  reg [1:0] cause_software_interrupt;
  reg [4:0] cause_exception_code;
  assign cause_write_value = cause_t'(wb_to_cp0_data_bus.write_data);
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
    end else if (wb_to_cp0_data_bus.exception_valid && !status_value.exception_level) begin
      cause_in_delay_slot <= wb_to_cp0_data_bus.in_delay_slot;
    end
  end
  always_ff @(posedge clock) begin
    if (reset) begin
      cause_timer_interrupt <= 1'b0;
    end else if (wb_to_cp0_data_bus.write_enabled && address_compare) begin
      cause_timer_interrupt <= 1'b0;
    end else if (count_value == compare_value) begin
      cause_timer_interrupt <= 1'b1;
    end
  end
  always_ff @(posedge clock) begin
    if (reset) begin
      cause_hardware_interrupt <= 6'b0;
    end else begin
      cause_hardware_interrupt <= {hardware_interrupt[5] | cause_timer_interrupt, hardware_interrupt[4:0]};
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

  epc_t epc_value;
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.exception_valid && !status_value.exception_level) begin
      epc_value <= wb_to_cp0_data_bus.in_delay_slot ? (wb_to_cp0_data_bus.exception_address - 4) : wb_to_cp0_data_bus.exception_address;
    end else if (wb_to_cp0_data_bus.write_enabled && address_epc) begin
      epc_value <= wb_to_cp0_data_bus.write_data;
    end
  end

  assign cp0_read_data =
    ({CPU_DATA_WIDTH{address_badvaddr}} & cpu_data_t'(badvaddr_value)) |
    ({CPU_DATA_WIDTH{address_count}} & cpu_data_t'(count_value)) |
    ({CPU_DATA_WIDTH{address_compare}} & cpu_data_t'(compare_value)) |
    ({CPU_DATA_WIDTH{address_status}} & cpu_data_t'(status_value)) |
    ({CPU_DATA_WIDTH{address_cause}} & cpu_data_t'(cause_value)) |
    ({CPU_DATA_WIDTH{address_epc}} & cpu_data_t'(epc_value));
  assign cp0_to_if_data_bus = '{
    exception_address: epc_value,
    interrupt_valid : {cause_value.hardware_interrupt, cause_value.software_interrupt} & status_value.interrupt_mask & {8{status_value.interrupt_enabled}} & {8{~status_value.exception_level}}
  };
endmodule: coprocessor0