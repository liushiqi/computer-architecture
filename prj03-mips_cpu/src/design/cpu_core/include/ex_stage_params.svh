`ifndef EX_STAGE_PARAMS_SVH
`define EX_STAGE_PARAMS_SVH

`include "cpu_core_params.svh"

package ex_stage_params;
  import cpu_core_params::*;
  export cpu_core_params::cpu_data_t;
  export cpu_core_params::program_count_t;

  typedef struct packed {
    logic valid;
    logic data_valid;
    logic [4:0] write_register;
    cpu_data_t write_data;
  } ex_to_id_back_pass_bus_t;

  typedef struct packed {
    logic valid;
    program_count_t program_count;
    cpu_data_t alu_result;
    cpu_data_t source_register_data;
    cpu_data_t multi_use_register_data;
    logic [4:0] write_register;
    logic [4:0] destination_register;
    logic [4:0] multi_use_register;
    logic [2:0] address_select;
    logic register_write;
    address_t memory_address;
    logic is_load_left;
    logic is_load_right;
    logic is_load_word;
    logic is_load_half_word;
    logic is_load_byte;
    logic memory_io_unsigned;
    logic result_is_from_memory;
    logic memory_write;
    logic multiply_valid;
    multiplier_params::multiply_result_bus_t multiply_result;
    logic divide_valid;
    logic divide_result_valid;
    cpu_data_t divide_result;
    cpu_data_t divide_remain;
    logic result_high;
    logic result_low;
    logic high_low_write;
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
  } ex_to_io_bus_t;
endpackage: ex_stage_params

`endif