`include "include/cpu_core_params.svh"

module priorirty_selector#(
  parameter type DataType = cpu_core_params::cpu_data_t,
  parameter SELECT_PORTS = 4,
  parameter PRIORITY = selector_params::HIGH_TO_LOW
) (
  input select [SELECT_PORTS - 1],
  input DataType inputs [SELECT_PORTS],
  output DataType result
);
  import selector_params::*;
  DataType outputs [SELECT_PORTS];

  generate
    if (PRIORITY == HIGH_TO_LOW) begin
      assign outputs[SELECT_PORTS - 1] = inputs[SELECT_PORTS - 1];
      for (genvar i = 0; i < SELECT_PORTS - 1; i++) begin
        assign outputs[i] = select[i] ? inputs[i] : outputs[i + 1];
      end
      assign result = outputs[0];
    end else begin
      assign outputs[0] = inputs[0];
      for (genvar i = 1; i < SELECT_PORTS; i++) begin
        assign outputs[i] = select[i] ? inputs[i + 1] : outputs[i];
      end
      assign result = outputs[SELECT_PORTS - 1];
    end
  endgenerate
endmodule