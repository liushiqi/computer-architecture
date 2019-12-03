`include "include/tlb_params.svh"

module tlb (
  input clock,
  input tlb_params::search_request_t request1,
  output tlb_params::search_result_t responce1,
  input tlb_params::search_request_t request2,
  output tlb_params::search_result_t responce2,
  input write_enabled,
  input [$clog2(tlb_params::TLB_NUM) - 1:0] write_index,
  input tlb_params::tlb_request_t write_data,
  input [$clog2(tlb_params::TLB_NUM) - 1:0] read_index,
  output tlb_params::tlb_request_t read_data
);
  import tlb_params::*;
  tlb_entry_t entries [TLB_NUM];

  assign read_data = entries[read_index];

  wire [TLB_NUM - 1:0] matched1;
  logic [$clog2(TLB_NUM) - 1:0] match_index1 [TLB_NUM + 1];
  entry_t match_entry1 [TLB_NUM + 1];
  wire matched_all1;
  logic [$clog2(TLB_NUM) - 1:0] match_all_index1;
  entry_t match_all_entry1;

  assign match_index1[TLB_NUM] = {$clog2(TLB_NUM){1'b0}};
  assign match_entry1[TLB_NUM] = '{20'b0, 2'b0, 1'b0, 1'b0};
  assign matched_all1 = |matched1;
  assign match_all_index1 = match_index1[0];
  assign match_all_entry1 = match_entry1[0];

  wire [TLB_NUM - 1:0] matched2;
  logic [$clog2(TLB_NUM) - 1:0] match_index2 [TLB_NUM + 1];
  entry_t match_entry2 [TLB_NUM + 1];
  wire matched_all2;
  logic [$clog2(TLB_NUM) - 1:0] match_all_index2;
  entry_t match_all_entry2;

  assign match_index2[TLB_NUM] = {$clog2(TLB_NUM){1'b0}};
  assign match_entry2[TLB_NUM] = '{20'b0, 2'b0, 1'b0, 1'b0};
  assign matched_all2 = |matched2;
  assign match_all_index2 = match_index2[0];
  assign match_all_entry2 = match_entry2[0];

  assign responce1 = '{
    found: matched_all1,
    index: match_all_index1,
    entry: match_all_entry1
  };

  assign responce2 = '{
    found: matched_all2,
    index: match_all_index2,
    entry: match_all_entry2
  };

  generate
    for (genvar i = 0; i < TLB_NUM; i++) begin
      assign matched1[i] = request1.virtual_page_number == entries[i].virtual_page_number && (request1.asid == entries[i].asid || entries[i].is_global);
      assign match_index1[i] = ({$clog2(TLB_NUM){matched1[i]}} & i) | match_index1[i + 1];
      assign match_entry1[i] = ({$bits(entry_t){matched1[i] & request1.is_odd_page}} & entries[i].odd_page) | ({$bits(entry_t){matched1[i] & ~request1.is_odd_page}} & entries[i].even_page) | match_entry1[i + 1];

      assign matched2[i] = request2.virtual_page_number == entries[i].virtual_page_number && (request2.asid == entries[i].asid || entries[i].is_global);
      assign match_index2[i] = ({$clog2(TLB_NUM){matched2[i]}} & i) | match_index2[i + 1];
      assign match_entry2[i] = ({$bits(entry_t){matched2[i] & request2.is_odd_page}} & entries[i].odd_page) | ({$bits(entry_t){matched2[i] & ~request2.is_odd_page}} & entries[i].even_page) | match_entry2[i + 1];
    end
  endgenerate

  always_ff @(posedge clock) begin
    if (write_enabled) begin
      entries[write_index] <= write_data;
    end
  end
endmodule