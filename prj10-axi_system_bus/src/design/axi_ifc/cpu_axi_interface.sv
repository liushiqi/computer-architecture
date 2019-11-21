package axi_params;
  typedef logic [31:0] AXIData;

  typedef enum logic [31:0] {
    READ_WAITING,
    READ_GET_DATA_RAM_ADDRESS,
    READ_SEND_DATA_RAM_ADDRESS,
    READ_GET_DATA_RAM_DATA,
    READ_SEND_DATA_RAM_DATA,
    READ_GET_INSTRUCTION_RAM_ADDRESS,
    READ_SEND_INSTRUCTION_RAM_ADDRESS,
    READ_GET_INSTRUCTION_RAM_DATA,
    READ_SEND_INSTRUCTION_RAM_DATA
  } ReadState;

  typedef enum logic [31:0] {
    WRITE_WAITING,
    WRITE_GET_DATA_RAM_ADDRESS,
    WRITE_SEND_DATA_RAM_ADDRESS,
    WRITE_SEND_DATA_RAM_DATA,
    WRITE_GET_DATA_RAM_APPLY,
    WRITE_SEND_DATA_RAM_APPLY
  } WriteState;
endpackage

module cpu_axi_interface (
  input clock,
  input reset_,
  // instruction ram
  input instruction_ram_request,
  input instruction_ram_write,
  input [1:0] instruction_ram_size,
  input axi_params::AXIData instruction_ram_address,
  input axi_params::AXIData instruction_ram_write_data,
  output axi_params::AXIData instruction_ram_read_data,
  output instruction_ram_address_ready,
  output instruction_ram_data_ready,
  // data ram
  input data_ram_request,
  input data_ram_write,
  input [1:0] data_ram_size,
  input axi_params::AXIData data_ram_address,
  input axi_params::AXIData data_ram_write_data,
  output axi_params::AXIData data_ram_read_data,
  output data_ram_address_ready,
  output data_ram_data_ready,
  // axi ar ports
  output [3:0] axi_read_address_id,
  output axi_params::AXIData axi_read_address,
  output [7:0] axi_read_address_length,
  output [2:0] axi_read_address_size,
  output [1:0] axi_read_address_burst,
  output [1:0] axi_read_address_lock,
  output [3:0] axi_read_address_cache,
  output [2:0] axi_read_address_protection,
  output axi_read_address_valid,
  input axi_read_address_ready,
  // axi r ports
  input [3:0] axi_read_data_id,
  input axi_params::AXIData axi_read_data,
  input [1:0] axi_read_data_response,
  input axi_read_data_last,
  input axi_read_data_valid,
  output axi_read_data_ready,
  // axi aw ports
  output [3:0] axi_write_address_id,
  output axi_params::AXIData axi_write_address,
  output [7:0] axi_write_address_length,
  output [2:0] axi_write_address_size,
  output [1:0] axi_write_address_burst,
  output [1:0] axi_write_address_lock,
  output [3:0] axi_write_address_cache,
  output [2:0] axi_write_address_protection,
  output axi_write_address_valid,
  input axi_write_address_ready,
  // axi w ports
  output [3:0] axi_write_data_id,
  output axi_params::AXIData axi_write_data,
  output [3:0] axi_write_data_strobe,
  output axi_write_data_last,
  output axi_write_data_valid,
  input axi_write_data_ready,
  // axi b ports
  input [3:0] axi_write_responce_id,
  input [1:0] axi_write_responce,
  input axi_write_responce_valid,
  output axi_write_responce_ready
);
  import axi_params::*;
  wire reset;
  assign reset = ~reset_;
  // state
  ReadState read_state;
  ReadState next_read_state;
  WriteState write_state;
  WriteState next_write_state;
  wire have_pending_write;
  wire have_pending_read;
  assign have_pending_write = write_state != WRITE_WAITING || (data_ram_request && data_ram_write) || (instruction_ram_request && instruction_ram_write);
  assign have_pending_read = read_state != READ_WAITING || (data_ram_request && ~data_ram_write);

  // cache
  AXIData data_ram_read_address_cache;
  AXIData data_ram_read_size_cache;
  AXIData data_ram_read_data_cache;
  AXIData instruction_ram_read_address_cache;
  AXIData instruction_ram_read_size_cache;
  AXIData instruction_ram_read_data_cache;
  AXIData data_ram_write_address_cache;
  AXIData data_ram_write_size_cache;
  AXIData data_ram_write_data_cache;
  reg [3:0] data_ram_write_data_strobe_cache;

  // cpu
  assign data_ram_read_data = data_ram_read_data_cache;
  assign data_ram_address_ready = read_state == READ_GET_DATA_RAM_ADDRESS || write_state == WRITE_GET_DATA_RAM_ADDRESS;
  assign data_ram_data_ready = read_state == READ_SEND_DATA_RAM_DATA || write_state == WRITE_SEND_DATA_RAM_APPLY;
  assign instruction_ram_read_data = instruction_ram_read_data_cache;
  assign instruction_ram_address_ready = read_state == READ_GET_INSTRUCTION_RAM_ADDRESS;
  assign instruction_ram_data_ready = read_state == READ_SEND_INSTRUCTION_RAM_DATA;

  // read
  assign axi_read_address_id = read_state == READ_SEND_DATA_RAM_ADDRESS ? 4'b1 : 4'b0;
  assign axi_read_address = read_state == READ_SEND_DATA_RAM_ADDRESS ? data_ram_read_address_cache : instruction_ram_read_address_cache;
  assign axi_read_address_length = 8'b0;
  assign axi_read_address_size = read_state == READ_SEND_DATA_RAM_ADDRESS ? data_ram_read_size_cache : instruction_ram_read_size_cache;
  assign axi_read_address_burst = 2'b1;
  assign axi_read_address_lock = 2'b0;
  assign axi_read_address_cache = 4'b0;
  assign axi_read_address_protection = 3'b0;
  assign axi_read_address_valid = read_state == READ_SEND_DATA_RAM_ADDRESS || read_state == READ_SEND_INSTRUCTION_RAM_ADDRESS;

  assign axi_read_data_ready = read_state == READ_GET_DATA_RAM_DATA | read_state == READ_GET_INSTRUCTION_RAM_DATA;

  always_ff @(posedge clock) begin
    if (reset) begin
      read_state <= READ_WAITING;
    end else begin
      read_state <= next_read_state;
    end
  end

  always_comb case(read_state)
    READ_WAITING: begin
      if (data_ram_request & ~data_ram_write & ~have_pending_write) begin
        next_read_state = READ_GET_DATA_RAM_ADDRESS;
      end else if (instruction_ram_request & ~instruction_ram_write & ~have_pending_write) begin
        next_read_state = READ_GET_INSTRUCTION_RAM_ADDRESS;
      end else begin
        next_read_state = read_state;
      end
    end
    READ_GET_DATA_RAM_ADDRESS: begin
      next_read_state = read_state.next;
    end
    READ_SEND_DATA_RAM_ADDRESS: begin
      if (axi_read_address_ready) begin
        next_read_state = read_state.next;
      end else begin
        next_read_state = read_state;
      end
    end
    READ_GET_DATA_RAM_DATA: begin
      if (axi_read_data_valid) begin
        next_read_state = read_state.next;
      end else begin
        next_read_state = read_state;
      end
    end
    READ_SEND_DATA_RAM_DATA: begin
      next_read_state = READ_WAITING;
    end
    READ_GET_INSTRUCTION_RAM_ADDRESS: begin
      next_read_state = read_state.next;
    end
    READ_SEND_INSTRUCTION_RAM_ADDRESS: begin
      if (axi_read_address_ready) begin
        next_read_state = read_state.next;
      end else begin
        next_read_state = read_state;
      end
    end
    READ_GET_INSTRUCTION_RAM_DATA: begin
      if (axi_read_data_valid) begin
        next_read_state = read_state.next;
      end else begin
        next_read_state = read_state;
      end
    end
    READ_SEND_INSTRUCTION_RAM_DATA: begin
      next_read_state = READ_WAITING;
    end
    default: begin
      next_read_state = READ_WAITING;
    end
  endcase

  always_ff @(posedge clock) begin
    if (read_state == READ_GET_DATA_RAM_ADDRESS) begin
      data_ram_read_address_cache <= data_ram_address;
    end
  end

  always_ff @(posedge clock) begin
    if (read_state == READ_GET_DATA_RAM_ADDRESS) begin
      data_ram_read_size_cache <= data_ram_size;
    end
  end

  always_ff @(posedge clock) begin
    if (read_state == READ_GET_DATA_RAM_DATA && axi_read_data_valid) begin
      data_ram_read_data_cache <= axi_read_data;
    end
  end

  always_ff @(posedge clock) begin
    if (read_state == READ_GET_INSTRUCTION_RAM_ADDRESS) begin
      instruction_ram_read_address_cache <= instruction_ram_address;
    end
  end

  always_ff @(posedge clock) begin
    if (read_state == READ_GET_INSTRUCTION_RAM_ADDRESS) begin
      instruction_ram_read_size_cache <= instruction_ram_size;
    end
  end

  always_ff @(posedge clock) begin
    if (read_state == READ_GET_INSTRUCTION_RAM_DATA && axi_read_data_valid) begin
      instruction_ram_read_data_cache <= axi_read_data;
    end
  end

  // write
  assign axi_write_address_id = 4'b1;
  assign axi_write_address = data_ram_write_address_cache;
  assign axi_write_address_length = 8'b0;
  assign axi_write_address_size = data_ram_write_size_cache;
  assign axi_write_address_burst = 2'b1;
  assign axi_write_address_lock = 2'b0;
  assign axi_write_address_cache = 4'b0;
  assign axi_write_address_protection = 3'b0;
  assign axi_write_address_valid = write_state == WRITE_SEND_DATA_RAM_ADDRESS;

  assign axi_write_data_id = 4'b1;
  assign axi_write_data = data_ram_write_data_cache;
  assign axi_write_data_strobe = data_ram_write_data_strobe_cache;
  assign axi_write_data_last = 1'b1;
  assign axi_write_data_valid = write_state == WRITE_SEND_DATA_RAM_DATA;

  assign axi_write_responce_ready = write_state == WRITE_GET_DATA_RAM_APPLY;

  always_ff @(posedge clock) begin
    if (reset) begin
      write_state <= WRITE_WAITING;
    end else begin
      write_state <= next_write_state;
    end
  end

  always_comb case(write_state)
    WRITE_WAITING: begin
      if (data_ram_request && data_ram_write && ~have_pending_read) begin
        next_write_state = WRITE_GET_DATA_RAM_ADDRESS;
      end else begin
        next_write_state = write_state;
      end
    end
    WRITE_GET_DATA_RAM_ADDRESS: begin
      next_write_state = write_state.next;
    end
    WRITE_SEND_DATA_RAM_ADDRESS: begin
      if (axi_write_address_ready) begin
        next_write_state = write_state.next;
      end else begin
        next_write_state = write_state;
      end
    end
    WRITE_SEND_DATA_RAM_DATA : begin
      if (axi_write_data_ready) begin
        next_write_state = write_state.next;
      end else begin
        next_write_state = write_state;
      end
    end
    WRITE_GET_DATA_RAM_APPLY: begin
      if (axi_write_responce_valid) begin
        next_write_state = write_state.next;
      end else begin
        next_write_state = write_state;
      end
    end
    WRITE_SEND_DATA_RAM_APPLY: begin
      next_write_state = WRITE_WAITING;
    end
    default: begin
      next_write_state = WRITE_WAITING;
    end
  endcase

  always_ff @(posedge clock) begin
    if (write_state == WRITE_GET_DATA_RAM_ADDRESS) begin
      data_ram_write_address_cache <= data_ram_address;
      data_ram_write_size_cache <= data_ram_size;
      data_ram_write_data_cache <= data_ram_write_data;
      data_ram_write_data_strobe_cache <=
        data_ram_size == 2 ? 4'b1111 :
        data_ram_size == 1 ? (data_ram_address[1:0] == 2'b10 ? 4'b1100 : 4'b0011) :
        (data_ram_address[1:0] == 2'b11 ? 4'b1000 : data_ram_address[1:0] == 2'b10 ? 4'b0100 : data_ram_address[1:0] == 2'b01 ? 4'b0010 : 4'b0001);
    end
  end
endmodule