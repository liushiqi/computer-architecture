`include "cpu_params.svh"

module io_state (
  input clock,
  input reset,
  // allow in
  input wb_allow_in,
  output io_allow_in,
  // from ex data
  input ex_stage_params::EXToIOData ex_to_io_bus,
  // back pass to id
  output io_stage_params::IOToIDBackPassData io_to_id_back_pass_bus,
  // to wb data
  output io_stage_params::IOToWBData io_to_wb_bus,
  // from data sram
  input cpu_core_params::CpuData data_read_data
);
  import io_stage_params::*;
  reg io_valid;
  wire io_ready_go;
  wire io_to_wb_valid;

  ex_stage_params::EXToIOData from_ex_data; // reg
  ProgramCount io_program_count;
  assign io_program_count = from_ex_data.program_count;

  CpuData memory_read_result;
  CpuData final_result;

  CpuData multiply_low_register;
  CpuData multiply_high_register;

  assign io_to_wb_bus = '{
    valid: io_to_wb_valid,
    program_count: io_program_count,
    final_result: final_result,
    register_file_address: from_ex_data.destination_register,
    register_file_write_enabled: from_ex_data.register_write
  };

  assign io_to_id_back_pass_bus = '{
    valid: from_ex_data.register_write & io_valid,
    write_register: from_ex_data.destination_register,
    write_data: final_result,
    previous_valid: from_ex_data.valid & ~from_ex_data.result_is_from_memory & from_ex_data.register_write,
    previous_write_register: from_ex_data.destination_register,
    previous_write_data: from_ex_data.alu_result
  };

  assign io_ready_go = ~(from_ex_data.divide_valid & ~ex_to_io_bus.divide_result_valid);
  assign io_allow_in = !io_valid || io_ready_go && wb_allow_in;
  assign io_to_wb_valid = io_valid && io_ready_go;
  always_ff @(posedge clock) begin
    if (reset) begin
      io_valid <= 1'b0;
    end else if (io_allow_in) begin
      io_valid <= ex_to_io_bus.valid;
    end
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      from_ex_data.valid <= 0;
    end if (ex_to_io_bus.valid && io_allow_in) begin
      from_ex_data <= ex_to_io_bus;
    end
  end

  always_ff @(posedge clock) begin
    if (from_ex_data.multiply_valid) begin
      multiply_low_register <= ex_to_io_bus.multiply_result[CPU_DATA_WIDTH - 1:0];
      multiply_high_register <= ex_to_io_bus.multiply_result[CPU_DATA_WIDTH * 2 - 1:CPU_DATA_WIDTH];
    end else if (from_ex_data.divide_valid & ex_to_io_bus.divide_result_valid) begin
      multiply_low_register <= ex_to_io_bus.divide_result;
      multiply_high_register <= ex_to_io_bus.divide_remain;
    end else if (from_ex_data.high_low_write) begin
      if (from_ex_data.result_high) begin
        multiply_high_register <= from_ex_data.source_register_data;
      end else if (from_ex_data.result_low) begin
        multiply_low_register <= from_ex_data.source_register_data;
      end
    end
  end

  assign memory_read_result = data_read_data;

  assign final_result =
    from_ex_data.result_is_from_memory ? memory_read_result :
    from_ex_data.result_high & ~from_ex_data.high_low_write ? multiply_high_register :
    from_ex_data.result_low & ~from_ex_data.high_low_write ? multiply_low_register : from_ex_data.alu_result;
endmodule : io_state
