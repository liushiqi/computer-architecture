`ifndef ID_STAGE_PARAMS_SVH
`define ID_STAGE_PARAMS_SVH

`include "cpu_core_params.svh"

package id_stage_params;
  import cpu_core_params::*;
  export cpu_core_params::cpu_data_t;
  export cpu_core_params::program_count_t;
  export cpu_core_params::CPU_DATA_WIDTH;

  typedef struct packed {
    logic valid;
    program_count_t program_count;
    cpu_data_t multi_use_register_value;
    cpu_data_t source_register_value;
    logic [15:0] immediate;
    logic [4:0] write_register;
    logic [4:0] destination_register;
    logic [4:0] multi_use_register;
    logic [2:0] address_select;
    logic memory_read;
    logic memory_write;
    logic [4:0] memory_io_type;
    logic memory_io_unsigned;
    logic register_write;
    logic source2_is_8;
    logic source2_is_immediate;
    logic source2_is_unsigned;
    logic source1_is_program_count;
    logic source1_is_shift_amount;
    logic multiply_valid;
    logic divide_valid;
    logic multiply_divide_signed;
    logic result_high;
    logic result_low;
    logic high_low_write;
    logic [11:0] alu_operation;
    logic move_from_cp0;
    logic move_to_cp0;
    logic exception_valid;
    logic in_delay_slot;
    logic eret_flush;
    logic do_overflow_check;
    logic [4:0] exception_code;
    logic is_address_fault;
    address_t badvaddr_value;
    logic tlb_read;
    logic tlb_write;
    logic tlb_probe;
    logic tlb_refill;
    logic tlb_exception;
  } id_to_ex_bus_t;

  typedef struct packed {
    logic taken;
    cpu_data_t target;
  } id_to_if_branch_bus_t ;
endpackage: id_stage_params

`endif