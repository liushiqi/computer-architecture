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
  input [7:0] wa_sid,
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
endmodule