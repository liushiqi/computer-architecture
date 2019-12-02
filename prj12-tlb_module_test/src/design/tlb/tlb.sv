`include "include/tlb_params.svh"

module tlb (
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

  wire [TLB_NUM - 1:0] matched1;
  entry_t match_results [TLB_NUM];
  wire [TLB_NUM - 1:0] matched2;

  generate
    for (genvar i = 0; i < TLB_NUM; i++) begin
      assign matched1[i] = request1[i].virtual_page_number == entries[i].virtual_page_number && (request1[i].asid == entries[i].asid || entries[i].is_global);
      assign match_results[i] = request1[i].is_odd_page ? entries[i].odd_page : entries[i].even_page;

      assign matched2[i] = request2[i].virtual_page_number == entries[i].virtual_page_number && (request2[i].asid == entries[i].asid || entries[i].is_global);
    end
  endgenerate
endmodule