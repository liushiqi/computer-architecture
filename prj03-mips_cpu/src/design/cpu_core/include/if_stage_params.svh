`ifndef IF_STAGE_PARAMS_SVH
`define IF_STAGE_PARAMS_SVH

`include "cpu_core_params.svh"

package if_stage_params;
  import cpu_core_params::*;
  export cpu_core_params::address_t;
  export cpu_core_params::cpu_data_t;
  export cpu_core_params::program_count_t;

  typedef struct packed {
    logic valid;
    program_count_t program_count;
    cpu_data_t instruction;
    logic exception_valid;
    logic [4:0] exception_code;
    logic is_address_fault;
    logic tlb_refill;
    logic tlb_exception;
    address_t badvaddr_value;
  } if_to_id_bus_t;
endpackage: if_stage_params

`endif