`include "include/tlb_params.svh"

module tlb_adapter #(
  parameter TLB_NUM = 16
) (
  input clk,
  // search port 0
  input [18:0] s0_vpn2,
  input s0_odd_page,
  input [7:0] s0_asid,
  output s0_found,
  output [$clog2(TLB_NUM)-1:0] s0_index,
  output [19:0] s0_pfn,
  output [2:0] s0_c,
  output s0_d,
  output s0_v,
  // search port 1
  input [18:0] s1_vpn2,
  input s1_odd_page,
  input [7:0] s1_asid,
  output s1_found,
  output [$clog2(TLB_NUM)-1:0] s1_index,
  output [19:0] s1_pfn,
  output [2:0] s1_c,
  output s1_d,
  output s1_v,
  // write port
  input we,
  input [$clog2(TLB_NUM)-1:0] w_index,
  input [18:0] w_vpn2,
  input [7:0] w_asid,
  input w_g,
  input [19:0] w_pfn0,
  input [2:0] w_c0,
  input w_d0,
  input w_v0,
  input [19:0] w_pfn1,
  input [2:0] w_c1,
  input w_d1,
  input w_v1,
  // read port
  input [$clog2(TLB_NUM)-1:0] r_index,
  output [18:0] r_vpn2,
  output [7:0] r_asid,
  output r_g,
  output [19:0] r_pfn0,
  output [2:0] r_c0,
  output r_d0,
  output r_v0,
  output [19:0] r_pfn1,
  output [2:0] r_c1,
  output r_d1,
  output r_v1
);
  tlb_params::search_request_t request1;
  tlb_params::search_result_t responce1;
  tlb_params::search_request_t request2;
  tlb_params::search_result_t responce2;
  tlb_params::tlb_request_t write_data;
  tlb_params::tlb_request_t read_data;

  assign request1 = '{
    virtual_page_number: s0_vpn2,
    is_odd_page: s0_odd_page,
    asid: s0_asid
  };

  assign {
    s0_found,
    s0_index,
    {s0_pfn, s0_c, s0_d, s0_v}
  } = responce1;

  assign request2 = '{
    virtual_page_number: s1_vpn2,
    is_odd_page: s1_odd_page,
    asid: s1_asid
  };

  assign {
    s1_found,
    s1_index,
    {s1_pfn, s1_c, s1_d, s1_v}
  } = responce2;

  assign write_data = '{
    virtual_page_number: w_vpn2,
    asid: w_asid,
    is_global: w_g,
    even_page: '{
      page_frame_number: w_pfn0,
      is_cached: w_c0,
      is_dirty: w_d0,
      is_valid: w_v0
    },
    odd_page: '{
      page_frame_number: w_pfn1,
      is_cached: w_c1,
      is_dirty: w_d1,
      is_valid: w_v1
    }
  };

  assign {
    r_vpn2,
    r_asid,
    r_g,
    {r_pfn0, r_c0, r_d0, r_v0},
    {r_pfn1, r_c1, r_d1, r_v1}
  } = read_data;

  tlb u_tlb (
    .clock(clk),
    .request1,
    .responce1,
    .request2,
    .responce2,
    .write_enabled(we),
    .write_index(w_index),
    .write_data,
    .read_index(r_index),
    .read_data
  );
endmodule