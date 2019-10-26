`ifndef COPROCESSOR_PARAMS
`define COPROCESSOR_PARAMS

package coprocessor0_params;
  import cpu_core_params::*;

  typedef struct packed {
    logic [4:0] address_register;
    logic [2:0] address_select;
    logic write_enabled;
    CpuData write_data;
  } WBToCP0Data;

  typedef struct packed {
    logic [7:0] zero1;
    logic bev;
    logic [5:0] zero2;
    logic [7:0] mask;
    logic [5:0] zero3;
    logic exception_level;
    logic interrupt_enabled;
  } StatusData;

  typedef struct packed {
    logic delay_slot;
    logic yimer_interrupt;
    logic [13:0] zero1;
    logic [5:0] hardware_interrupt;
    logic [1:0] software_interrupt;
    logic zero2;
    logic [4:0] exception_code;
    logic [1:0] zero3;
  } CauseData;

  typedef AddressData EPCData;
endpackage;

`endif