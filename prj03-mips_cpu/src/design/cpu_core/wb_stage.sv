`include "cpu_params.svh"
`include "coprocessor_params.svh"

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
  // to cp0 write data
  output coprocessor0_params::WBToCP0Data wb_to_cp0_data_bus,
  input cpu_core_params::CpuData cp0_read_data,
  // exception data
  output wb_stage_params::WBExceptionBus wb_exception_bus,
  // trace debug interface
  output cpu_core_params::ProgramCount debug_program_count,
  output [3:0] debug_register_file_write_enabled,
  output [4:0] debug_register_file_write_address,
  output cpu_core_params::CpuData debug_register_file_write_data
);
  import wb_stage_params::*;
  reg wb_valid;
  wire wb_ready_go;
  reg exception_valid;
  reg eret_flush;

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

  assign wb_to_cp0_data_bus = '{
    address_register: from_io_data.cp0_address_register,
    address_select: from_io_data.cp0_address_select,
    write_enabled: from_io_data.move_to_cp0,
    write_data: from_io_data.final_result,
    exception_valid: from_io_data.exception_valid,
    exception_address: wb_program_count,
    eret_flush: from_io_data.eret_flush,
    in_delay_slot: from_io_data.in_delay_slot,
    exception_code: from_io_data.exception_code
  };

  assign wb_to_id_back_pass_bus = '{
    valid: from_io_data.register_file_write_enabled & wb_valid,
    write_register: from_io_data.register_file_address,
    write_strobe: from_io_data.register_file_write_strobe,
    write_data: register_file_write_data
  };

  assign wb_exception_bus = '{
    exception_valid: exception_valid,
    eret_flush: eret_flush
  };

  assign wb_ready_go = 1'b1;
  assign wb_allow_in = !wb_valid || wb_ready_go;
  always_ff @(posedge clock) begin
    if (reset) begin
      wb_valid <= 1'b0;
    end else if (wb_allow_in) begin
      wb_valid <= (exception_valid || eret_flush) ? 1'b0 : io_to_wb_bus.valid;
    end
  end

  always_ff @(posedge clock) begin
    if (io_to_wb_bus.valid && wb_allow_in) begin
      from_io_data <= io_to_wb_bus;
    end
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      exception_valid <= 1'b0;
    end else if (from_io_data.exception_valid) begin
      exception_valid <= 1'b1;
    end else if (!from_io_data.exception_valid) begin
      exception_valid <= 1'b0;
    end
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      eret_flush <= 1'b0;
    end else if (from_io_data.eret_flush) begin
      eret_flush <= 1'b1;
    end else if (!from_io_data.eret_flush) begin
      eret_flush <= 1'b0;
    end
  end

  assign register_file_write_enabled = from_io_data.register_file_write_enabled && !from_io_data.exception_valid && wb_valid;
  assign register_file_write_strobe = from_io_data.register_file_write_strobe;
  assign register_file_write_address = from_io_data.register_file_address;
  assign register_file_write_data = from_io_data.move_from_cp0 ? cp0_read_data : from_io_data.final_result;

  // debug info generate
  assign debug_program_count = wb_program_count;
  assign debug_register_file_write_enabled = {4{register_file_write_enabled}} & from_io_data.register_file_write_strobe;
  assign debug_register_file_write_address = from_io_data.register_file_address;
  assign debug_register_file_write_data = from_io_data.final_result;
endmodule : wb_stage
