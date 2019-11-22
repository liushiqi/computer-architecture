`ifndef WB_STAGE_PARAMS_SVH
`define WB_STAGE_PARAMS_SVH

`include "cpu_core_params.svh"

package wb_stage_params;
  import cpu_core_params::*;
  export cpu_core_params::cpu_data_t;
  export cpu_core_params::program_count_t;

  typedef struct packed {
    logic valid;
    logic [4:0] write_register;
    logic [3:0] write_strobe;
    cpu_data_t write_data;
  } wb_to_id_back_pass_bus_t;

  typedef struct packed {
    logic write_enabled;
    logic [4:0] write_address;
    logic [3:0] write_strobe;
    cpu_data_t write_data;
  } wb_to_register_file_bus_t;

  typedef struct packed {
    logic exception_valid;
    logic eret_flush;
  } wb_exception_bus_t;

  typedef struct packed {
    logic [4:0] address_register;
    logic [2:0] address_select;
    logic write_enabled;
    cpu_data_t write_data;
    logic exception_valid;
    address_t exception_address;
    logic eret_flush;
    logic in_delay_slot;
    logic [4:0] exception_code;
    logic is_address_fault;
    address_t badvaddr_value;
  } wb_to_cp0_bus_t;
endpackage: wb_stage_params

`endif