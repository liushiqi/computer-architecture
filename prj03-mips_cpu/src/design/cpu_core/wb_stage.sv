`include "cpu_params.svh"

module wb_stage (
  input clock,
  input reset,
  // allow in
  output wb_allow_in,
  // from io data
  input io_stage_params::IOToWBData io_to_wb_bus,
  // back pass data to id
  output wb_stage_params::WBToIDBackPassData wb_to_id_back_pass_bus,
  // to register file: for write back
  output wb_stage_params::WBToRegisterFileData wb_to_register_file_bus,
  // trace debug interface
  output cpu_core_params::ProgramCount debug_program_count,
  output [3:0] debug_register_file_write_enabled,
  output [4:0] debug_register_file_write_address,
  output cpu_core_params::CpuData debug_register_file_write_data
);
  import wb_stage_params::*;
  reg wb_valid;
  wire wb_ready_go;

  io_stage_params::IOToWBData from_io_data; // reg
  ProgramCount wb_program_count;
  assign wb_program_count = from_io_data.program_count;

  wire register_file_write_enabled;
  wire [3:0] register_file_write_strobe;
  wire [4:0] register_file_write_address;
  CpuData register_file_write_data;
  assign wb_to_register_file_bus = '{
    write_enabled: register_file_write_enabled,
    write_address: register_file_write_address,
    write_strobe: register_file_write_strobe,
    write_data: register_file_write_data
  };

  assign wb_to_id_back_pass_bus = '{
    valid: from_io_data.register_file_write_enabled & wb_valid,
    write_register: from_io_data.register_file_address,
    write_strobe: from_io_data.register_file_write_strobe,
    write_data: register_file_write_data
  };

  assign wb_ready_go = 1'b1;
  assign wb_allow_in = !wb_valid || wb_ready_go;
  always_ff @(posedge clock) begin
    if (reset) begin
      wb_valid <= 1'b0;
    end else if (wb_allow_in) begin
      wb_valid <= io_to_wb_bus.valid;
    end
  end

  always_ff @(posedge clock) begin
    if (io_to_wb_bus.valid && wb_allow_in) begin
      from_io_data <= io_to_wb_bus;
    end
  end

  assign register_file_write_enabled = from_io_data.register_file_write_enabled && wb_valid;
  assign register_file_write_strobe = from_io_data.register_file_write_strobe;
  assign register_file_write_address = from_io_data.register_file_address;
  assign register_file_write_data = from_io_data.final_result;

  // debug info generate
  assign debug_program_count = wb_program_count;
  assign debug_register_file_write_enabled = {4{register_file_write_enabled}} & from_io_data.register_file_write_strobe;
  assign debug_register_file_write_address = from_io_data.register_file_address;
  assign debug_register_file_write_data = from_io_data.final_result;
endmodule : wb_stage
