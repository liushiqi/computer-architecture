`include "include/coprocessor_params.svh"

module coprocessor0(
  input clock,
  input reset,
  input wb_stage_params::wb_to_cp0_bus_t wb_to_cp0_data_bus,
  output coprocessor0_params::cp0_to_if_bus_t cp0_to_if_data_bus,
  output cpu_core_params::cpu_data_t cp0_read_data,
  output tlb_params::search_request_t tlb_request,
  input tlb_params::search_result_t tlb_responce,
  output [$clog2(tlb_params::TLB_NUM) - 1:0] tlb_write_index,
  output tlb_params::tlb_request_t tlb_write_data,
  output [$clog2(tlb_params::TLB_NUM) - 1:0] tlb_read_index,
  input tlb_params::tlb_request_t tlb_read_data,
  input [5:0] hardware_interrupt
);
  import coprocessor0_params::*;
  wire [31:0] address_register_decoded;
  wire [7:0] address_select_decoded;

  decoder #(.INPUT_WIDTH(5)) u_address_register_decoder(.in(wb_to_cp0_data_bus.address_register), .out(address_register_decoded));
  decoder #(.INPUT_WIDTH(3)) u_address_select_decoder(.in(wb_to_cp0_data_bus.address_select), .out(address_select_decoded));

  wire address_index;
  wire address_entrylo0;
  wire address_entrylo1;
  wire address_badvaddr;
  wire address_count;
  wire address_entryhi;
  wire address_compare;
  wire address_status;
  wire address_cause;
  wire address_epc;

  assign address_index = address_register_decoded[5'h00] & address_select_decoded[3'h0];
  assign address_entrylo0 = address_register_decoded[5'h02] & address_select_decoded[3'h0];
  assign address_entrylo1 = address_register_decoded[5'h03] & address_select_decoded[3'h0];
  assign address_badvaddr = address_register_decoded[5'h08] & address_select_decoded[3'h0];
  assign address_count = address_register_decoded[5'h09] & address_select_decoded[3'h0];
  assign address_entryhi = address_register_decoded[5'h0a] & address_select_decoded[3'h0];
  assign address_compare = address_register_decoded[5'h0b] & address_select_decoded[3'h0];
  assign address_status = address_register_decoded[5'h0c] & address_select_decoded[3'h0];
  assign address_cause = address_register_decoded[5'h0d] & address_select_decoded[3'h0];
  assign address_epc = address_register_decoded[5'h0e] & address_select_decoded[3'h0];

  index_t index_value;
  index_t index_write_value;
  reg index_probe;
  reg [$clog2(tlb_params::TLB_NUM) - 1:0] index_index;
  assign index_write_value = index_t'(wb_to_cp0_data_bus.write_data);
  assign index_value = '{
    probe: index_probe,
    zero: 0,
    index: index_index
  };
  always_ff @(posedge clock) begin
    if (reset) begin
      index_probe <= 1'b0;
    end else if (wb_to_cp0_data_bus.tlb_probe && !tlb_responce.found) begin
      index_probe <= 1'b1;
    end else if (wb_to_cp0_data_bus.tlb_probe && tlb_responce) begin
      index_probe <= 1'b0;
    end
  end
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.tlb_probe && tlb_responce.found) begin
      index_index <= tlb_responce.index;
    end else if (wb_to_cp0_data_bus.write_enabled && address_index) begin
      index_index <= index_write_value.index;
    end
  end

  entry_lo_t entrylo0_value;
  entry_lo_t entrylo0_write_value;
  reg [19:0] entrylo0_page_frame_number;
  reg [2:0] entrylo0_cache;
  reg entrylo0_dirty;
  reg entrylo0_valid;
  reg entrylo0_is_global;
  assign entrylo0_write_value = entry_lo_t'(wb_to_cp0_data_bus.write_data);
  assign entrylo0_value = '{
    zero: 6'b0,
    page_frame_number: entrylo0_page_frame_number,
    cache: entrylo0_cache,
    dirty: entrylo0_dirty,
    valid: entrylo0_valid,
    is_global: entrylo0_is_global
  };
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.write_enabled && address_entrylo0) begin
      entrylo0_page_frame_number <= entrylo0_write_value.page_frame_number;
    end else if (wb_to_cp0_data_bus.tlb_read) begin
      entrylo0_page_frame_number <= tlb_read_data.even_page.page_frame_number;
    end
  end
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.write_enabled && address_entrylo0) begin
      entrylo0_cache <= entrylo0_write_value.cache;
    end else if (wb_to_cp0_data_bus.tlb_read) begin
      entrylo0_cache <= tlb_read_data.even_page.is_cached;
    end
  end
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.write_enabled && address_entrylo0) begin
      entrylo0_dirty <= entrylo0_write_value.dirty;
    end else if (wb_to_cp0_data_bus.tlb_read) begin
      entrylo0_dirty <= tlb_read_data.even_page.is_dirty;
    end
  end
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.write_enabled && address_entrylo0) begin
      entrylo0_valid <= entrylo0_write_value.valid;
    end else if (wb_to_cp0_data_bus.tlb_read) begin
      entrylo0_valid <= tlb_read_data.even_page.is_valid;
    end
  end
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.write_enabled && address_entrylo0) begin
      entrylo0_is_global <= entrylo0_write_value.is_global;
    end else if (wb_to_cp0_data_bus.tlb_read) begin
      entrylo0_is_global <= tlb_read_data.is_global;
    end
  end

  entry_lo_t entrylo1_value;
  entry_lo_t entrylo1_write_value;
  reg [19:0] entrylo1_page_frame_number;
  reg [2:0] entrylo1_cache;
  reg entrylo1_dirty;
  reg entrylo1_valid;
  reg entrylo1_is_global;
  assign entrylo1_write_value = entry_lo_t'(wb_to_cp0_data_bus.write_data);
  assign entrylo1_value = '{
    zero: 6'b0,
    page_frame_number: entrylo1_page_frame_number,
    cache: entrylo1_cache,
    dirty: entrylo1_dirty,
    valid: entrylo1_valid,
    is_global: entrylo1_is_global
  };
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.write_enabled && address_entrylo1) begin
      entrylo1_page_frame_number <= entrylo1_write_value.page_frame_number;
    end else if (wb_to_cp0_data_bus.tlb_read) begin
      entrylo1_page_frame_number <= tlb_read_data.odd_page.page_frame_number;
    end
  end
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.write_enabled && address_entrylo1) begin
      entrylo1_cache <= entrylo1_write_value.cache;
    end else if (wb_to_cp0_data_bus.tlb_read) begin
      entrylo1_cache <= tlb_read_data.odd_page.is_cached;
    end
  end
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.write_enabled && address_entrylo1) begin
      entrylo1_dirty <= entrylo1_write_value.dirty;
    end else if (wb_to_cp0_data_bus.tlb_read) begin
      entrylo1_dirty <= tlb_read_data.odd_page.is_dirty;
    end
  end
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.write_enabled && address_entrylo1) begin
      entrylo1_valid <= entrylo1_write_value.valid;
    end else if (wb_to_cp0_data_bus.tlb_read) begin
      entrylo1_valid <= tlb_read_data.odd_page.is_valid;
    end
  end
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.write_enabled && address_entrylo1) begin
      entrylo1_is_global <= entrylo1_write_value.is_global;
    end else if (wb_to_cp0_data_bus.tlb_read) begin
      entrylo1_is_global <= tlb_read_data.is_global;
    end
  end

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

  entry_hi_t entryhi_value;
  entry_hi_t entryhi_write_value;
  reg [18:0] entryhi_virtual_page_number;
  reg [7:0] entryhi_asid;
  assign entryhi_write_value = entry_hi_t'(wb_to_cp0_data_bus.write_data);
  assign entryhi_value = '{
    virtual_page_number: entryhi_virtual_page_number,
    zero: 5'b0,
    asid: entryhi_asid
  };
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.tlb_read) begin
      entryhi_virtual_page_number <= tlb_read_data.virtual_page_number;
    end else if (wb_to_cp0_data_bus.write_enabled && address_entryhi) begin
      entryhi_virtual_page_number <= entryhi_write_value.virtual_page_number;
    end
  end
  always_ff @(posedge clock) begin
    if (wb_to_cp0_data_bus.tlb_read) begin
      entryhi_asid <= tlb_read_data.asid;
    end if (wb_to_cp0_data_bus.write_enabled && address_entryhi) begin
      entryhi_asid <= entryhi_write_value.asid;
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
    ({CPU_DATA_WIDTH{address_index}} & cpu_data_t'(index_value)) |
    ({CPU_DATA_WIDTH{address_entrylo0}} & cpu_data_t'(entrylo0_value)) |
    ({CPU_DATA_WIDTH{address_entrylo1}} & cpu_data_t'(entrylo1_value)) |
    ({CPU_DATA_WIDTH{address_badvaddr}} & cpu_data_t'(badvaddr_value)) |
    ({CPU_DATA_WIDTH{address_count}} & cpu_data_t'(count_value)) |
    ({CPU_DATA_WIDTH{address_entryhi}} & cpu_data_t'(entryhi_value)) |
    ({CPU_DATA_WIDTH{address_compare}} & cpu_data_t'(compare_value)) |
    ({CPU_DATA_WIDTH{address_status}} & cpu_data_t'(status_value)) |
    ({CPU_DATA_WIDTH{address_cause}} & cpu_data_t'(cause_value)) |
    ({CPU_DATA_WIDTH{address_epc}} & cpu_data_t'(epc_value));
  assign cp0_to_if_data_bus = '{
    exception_address: epc_value,
    interrupt_valid : {cause_value.hardware_interrupt, cause_value.software_interrupt} & status_value.interrupt_mask & {8{status_value.interrupt_enabled}} & {8{~status_value.exception_level}}
  };

  assign tlb_request = '{
    virtual_page_number: entryhi_value.virtual_page_number,
    is_odd_page: 1'b0,
    asid: entryhi_value.asid
  };
  assign tlb_read_index = index_value.index;
  assign tlb_write_data = '{
    virtual_page_number: entryhi_value.virtual_page_number,
    asid: entryhi_value.asid,
    is_global: entrylo0_value.is_global & entrylo1_value.is_global,
    even_page: '{
      page_frame_number: entrylo0_value.page_frame_number,
      is_cached: entrylo0_value.cache,
      is_dirty: entrylo0_value.dirty,
      is_valid: entrylo0_value.valid
    },
    odd_page: '{
      page_frame_number: entrylo1_value.page_frame_number,
      is_cached: entrylo1_value.cache,
      is_dirty: entrylo1_value.dirty,
      is_valid: entrylo1_value.valid
    }
  };
  assign tlb_write_index = index_value.index;
endmodule: coprocessor0