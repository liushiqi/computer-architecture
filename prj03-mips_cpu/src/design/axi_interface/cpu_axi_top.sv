module cpu_axi_top(
  input [5:0] interrupt,

  input aclk,
  input aresetn,

  output [3:0] arid,
  output [31:0] araddr,
  output [7:0] arlen,
  output [2:0] arsize,
  output [1:0] arburst,
  output [1:0] arlock,
  output [3:0] arcache,
  output [2:0] arprot,
  output arvalid,
  input arready,

  input [3:0] rid,
  input [31:0] rdata,
  input [1:0] rresp,
  input rlast,
  input rvalid,
  output rready,

  output [3:0] awid,
  output [31:0] awaddr,
  output [7:0] awlen,
  output [2:0] awsize,
  output [1:0] awburst,
  output [1:0] awlock,
  output [3:0] awcache,
  output [2:0] awprot,
  output awvalid,
  input awready,

  output [3:0] wid,
  output [31:0] wdata,
  output [3:0] wstrb,
  output wlast,
  output wvalid,
  input wready,

  input [3:0] bid,
  input [1:0] bresp,
  input bvalid,
  output bready,

  //debug interface
  output [31:0] debug_wb_pc,
  output [3:0] debug_wb_rf_wen,
  output [4:0] debug_wb_rf_wnum,
  output [31:0] debug_wb_rf_wdata
);
  // instruction ram
  wire instruction_ram_request;
  wire instruction_ram_write;
  wire [1:0] instruction_ram_size;
  wire axi_params::axi_data_t instruction_ram_address;
  wire axi_params::axi_data_t instruction_ram_write_data;
  wire [3:0] instruction_ram_write_strobe;
  wire axi_params::axi_data_t instruction_ram_read_data;
  wire instruction_ram_address_ready;
  wire instruction_ram_data_ready;
  // data ram
  wire data_ram_request;
  wire data_ram_write;
  wire [1:0] data_ram_size;
  wire axi_params::axi_data_t data_ram_address;
  wire axi_params::axi_data_t data_ram_write_data;
  wire [3:0] data_ram_write_strobe;
  wire axi_params::axi_data_t data_ram_read_data;
  wire data_ram_address_ready;
  wire data_ram_data_ready;

  cpu_axi_interface u_cpu_axi_interface (
    .clock(aclk),
    .reset_(aresetn),
    // instruction ram
    .instruction_ram_request,
    .instruction_ram_write,
    .instruction_ram_size,
    .instruction_ram_address,
    .instruction_ram_write_data,
    .instruction_ram_write_strobe,
    .instruction_ram_read_data,
    .instruction_ram_address_ready,
    .instruction_ram_data_ready,
      // data ram
    .data_ram_request,
    .data_ram_write,
    .data_ram_size,
    .data_ram_address,
    .data_ram_write_data,
    .data_ram_write_strobe,
    .data_ram_read_data,
    .data_ram_address_ready,
    .data_ram_data_ready,
    // axi ar ports
    .axi_read_address_id(arid),
    .axi_read_address(araddr),
    .axi_read_address_length(arlen),
    .axi_read_address_size(arsize),
    .axi_read_address_burst(arburst),
    .axi_read_address_lock(arlock),
    .axi_read_address_cache(arcache),
    .axi_read_address_protection(arprot),
    .axi_read_address_valid(arvalid),
    .axi_read_address_ready(arready),
    // axi r ports
    .axi_read_data_id(rid),
    .axi_read_data(rdata),
    .axi_read_data_response(rresp),
    .axi_read_data_last(rlast),
    .axi_read_data_valid(rvalid),
    .axi_read_data_ready(rready),
    // axi aw ports
    .axi_write_address_id(awid),
    .axi_write_address(awaddr),
    .axi_write_address_length(awlen),
    .axi_write_address_size(awsize),
    .axi_write_address_burst(awburst),
    .axi_write_address_lock(awlock),
    .axi_write_address_cache(awcache),
    .axi_write_address_protection(awprot),
    .axi_write_address_valid(awvalid),
    .axi_write_address_ready(awready),
    // axi w ports
    .axi_write_data_id(wid),
    .axi_write_data(wdata),
    .axi_write_data_strobe(wstrb),
    .axi_write_data_last(wlast),
    .axi_write_data_valid(wvalid),
    .axi_write_data_ready(wready),
    // axi b ports
    .axi_write_responce_id(bid),
    .axi_write_responce(bresp),
    .axi_write_responce_valid(bvalid),
    .axi_write_responce_ready(bready)
  );

  cpu_core u_cpu_core(
    .clock(aclk),
    .reset_(aresetn),
    .instruction_ram_request,
    .instruction_ram_write,
    .instruction_ram_size,
    .instruction_ram_address,
    .instruction_ram_write_data,
    .instruction_ram_write_strobe,
    .instruction_ram_read_data,
    .instruction_ram_address_ready,
    .instruction_ram_data_ready,
      // data ram
    .data_ram_request,
    .data_ram_write,
    .data_ram_size,
    .data_ram_address,
    .data_ram_write_data,
    .data_ram_write_strobe,
    .data_ram_read_data,
    .data_ram_address_ready,
    .data_ram_data_ready,
    // trace debug interface
    .debug_program_count(debug_wb_pc),
    .debug_register_file_write_enabled(debug_wb_rf_wen),
    .debug_register_file_write_address(debug_wb_rf_wnum),
    .debug_register_file_write_data(debug_wb_rf_wdata),
    .hardware_interrupt(interrupt)
  );
endmodule