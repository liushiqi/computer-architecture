`ifndef COPROCESSOR_PARAMS_SVH
`define COPROCESSOR_PARAMS_SVH

`include "cpu_core_params.svh"
`include "tlb_params.svh"

package coprocessor0_params;
  import cpu_core_params::*;
  export cpu_core_params::cpu_data_t;
  export cpu_core_params::CPU_DATA_WIDTH;

  typedef struct packed {
    address_t exception_address;
    logic [7:0] interrupt_valid;
    logic [7:0] asid;
  } cp0_to_if_bus_t;

  typedef struct packed {
    logic [7:0] asid;
  } cp0_to_ex_bus_t;

  typedef struct packed {
    logic probe;
    logic [30 - $clog2(tlb_params::TLB_NUM):0] zero;
    logic [$clog2(tlb_params::TLB_NUM) - 1:0] index;
  } index_t;

  typedef struct packed {
    logic [5:0] zero;
    logic [19:0] page_frame_number;
    logic [2:0] cache;
    logic dirty;
    logic valid;
    logic is_global;
  } entry_lo_t;

  typedef address_t badvaddr_t;

  typedef cpu_data_t count_t;

  typedef struct packed {
    logic [18:0] virtual_page_number;
    logic [4:0] zero;
    logic [7:0] asid;
  } entry_hi_t;

  typedef cpu_data_t compare_t;

  typedef struct packed {
    logic [8:0] zero1;
    logic boot_exception_vector;
    logic [5:0] zero2;
    logic [7:0] interrupt_mask;
    logic [5:0] zero3;
    logic exception_level;
    logic interrupt_enabled;
  } status_t;

  typedef struct packed {
    logic in_delay_slot;
    logic timer_interrupt;
    logic [13:0] zero1;
    logic [5:0] hardware_interrupt;
    logic [1:0] software_interrupt;
    logic zero2;
    logic [4:0] exception_code;
    logic [1:0] zero3;
  } cause_t;

  typedef address_t epc_t;
endpackage: coprocessor0_params

`endif