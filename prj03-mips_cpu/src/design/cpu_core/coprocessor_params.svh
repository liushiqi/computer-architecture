`ifndef COPROCESSOR_PARAMS
`define COPROCESSOR_PARAMS

`include "cpu_params.svh"

package coprocessor0_params;
  import cpu_core_params::*;
  export cpu_core_params::CpuData;
  export cpu_core_params::CPU_DATA_WIDTH;

  typedef struct packed {
    Address exception_address;
    logic [7:0] interrupt_valid;
  } CP0ToIFData;

  typedef struct packed {
    logic [4:0] address_register;
    logic [2:0] address_select;
    logic write_enabled;
    CpuData write_data;
    logic exception_valid;
    Address exception_address;
    logic eret_flush;
    logic in_delay_slot;
    logic [4:0] exception_code;
    logic is_address_fault;
    Address badvaddr_value;
  } WBToCP0Data;

  typedef Address BadVAddrData;

  typedef CpuData CountData;

  typedef CpuData CompareData;

  typedef struct packed {
    logic [8:0] zero1;
    logic boot_exception_vector;
    logic [5:0] zero2;
    logic [7:0] interrupt_mask;
    logic [5:0] zero3;
    logic exception_level;
    logic interrupt_enabled;
  } StatusData;

  typedef struct packed {
    logic in_delay_slot;
    logic timer_interrupt;
    logic [13:0] zero1;
    logic [5:0] hardware_interrupt;
    logic [1:0] software_interrupt;
    logic zero2;
    logic [4:0] exception_code;
    logic [1:0] zero3;
  } CauseData;

  typedef Address EPCData;
endpackage : coprocessor0_params

`endif