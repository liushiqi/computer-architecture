`ifndef CPU_CORE_PARAMS_SVH
`define CPU_CORE_PARAMS_SVH

package cpu_core_params;
  parameter CPU_DATA_WIDTH = 32;

  typedef logic [CPU_DATA_WIDTH - 1:0] cpu_data_t;
  typedef cpu_data_t address_t;
  typedef cpu_data_t program_count_t;
endpackage: cpu_core_params

package multiplier_params;
  import cpu_core_params::*;
  export cpu_core_params::cpu_data_t;
  export cpu_core_params::CPU_DATA_WIDTH;

  typedef logic [CPU_DATA_WIDTH * 2 - 1:0] multiply_result_bus_t;

  typedef struct {
     logic [CPU_DATA_WIDTH / 2:0] wallace_input [CPU_DATA_WIDTH * 2];
     logic [CPU_DATA_WIDTH / 2:0] carry_input;
  } multiply_stages_bus_t;
endpackage: multiplier_params

package divider_params;
  import cpu_core_params::*;
  export cpu_core_params::cpu_data_t;
  export cpu_core_params::CPU_DATA_WIDTH;

  typedef enum logic [1:0] {
    WAITING_STATE = 2'b00,
    LOAD_STATE = 2'b01,
    DIVIDE_STATE = 2'b10,
    RETURN_STATE = 2'b11
  } divide_state_t;
endpackage: divider_params

package selector_params;
  typedef enum logic {
    LOW_TO_HIGH,
    HIGH_TO_LOW
  } priority_t;
endpackage

`endif