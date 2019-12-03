`ifndef TLB_PARAMS_SVH
`define TLB_PARAMS_SVH

package tlb_params;
  parameter TLB_NUM = 16;

  typedef struct packed {
    logic [19:0] page_frame_number;
    logic [2:0] is_cached;
    logic is_dirty;
    logic is_valid;
  } entry_t;

  typedef struct packed {
    logic [18:0] virtual_page_number;
    logic [7:0] asid;
    logic is_global;
    entry_t even_page;
    entry_t odd_page;
  } tlb_request_t;

  typedef tlb_request_t tlb_entry_t;

  typedef struct packed {
    logic [18:0] virtual_page_number;
    logic is_odd_page;
    logic [7:0] asid;
  } search_request_t;

  typedef struct packed {
    logic found;
    logic [$clog2(TLB_NUM) - 1:0] index;
    entry_t entry;
  } search_result_t;
endpackage

`endif