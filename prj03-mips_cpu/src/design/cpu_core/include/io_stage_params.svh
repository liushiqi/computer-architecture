`ifndef IO_STAGE_PARAMS_SVH
`define IO_STAGE_PARAMS_SVH

`include "cpu_core_params.svh"

package io_stage_params;
  import cpu_core_params::*;
  export cpu_core_params::cpu_data_t;
  export cpu_core_params::program_count_t;
  export cpu_core_params::CPU_DATA_WIDTH;

  typedef struct packed {
    logic valid;
    logic data_valid;
    logic [4:0] write_register;
    logic [3:0] write_strobe;
    cpu_data_t write_data;
    logic previous_valid;
    logic previous_data_valid;
    logic [4:0] previous_write_register;
    cpu_data_t previous_write_data;
  } io_to_id_back_pass_bus_t;

  typedef struct packed {
    logic valid;
    program_count_t program_count;
    cpu_data_t final_result;
    logic [4:0] register_file_address;
    logic register_file_write_enabled;
    logic [3:0] register_file_write_strobe;
    logic [4:0] cp0_address_register;
    logic [2:0] cp0_address_select;
    logic move_from_cp0;
    logic move_to_cp0;
    logic exception_valid;
    logic in_delay_slot;
    logic eret_flush;
    logic [4:0] exception_code;
    logic is_address_fault;
    address_t badvaddr_value;
    logic tlb_read;
    logic tlb_write;
    logic tlb_probe;
  } io_to_wb_bus_t;
endpackage: io_stage_params

`endif