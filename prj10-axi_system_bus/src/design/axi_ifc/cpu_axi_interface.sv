package axi_params;
  typedef logic [31:0] AXIData;

  typedef enum logic [31:0] {
    DATA_WAITING,
    GETTING_DATA_RAM_READ_ADDRESS,
    SENDING_DATA_RAM_READ_ADDRESS,
    GETTING_DATA_RAM_READ_DATA,
    SENDING_DATA_RAM_READ_DATA,
    GETTING_DATA_RAM_WRITE_ADDRESS,
    SENDING_DATA_RAM_WRITE_ADDRESS,
    SENDING_DATA_RAM_WRITE_DATA,
    GETTING_DATA_RAM_WRITE_APPLY,
    SENDING_DATA_RAM_WRITE_APPLY
  } DataState;
  
  typedef enum logic [31:0] {
    INSTRUCTION_WAITING,
    GETTING_INSTRUCTION_RAM_ADDRESS,
    SENDING_INSTRUCTION_RAM_ADDRESS,
    GETTING_INSTRUCTION_RAM_DATA,
    SENDING_INSTRUCTION_RAM_DATA
  } InstructionState;
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
  DataState data_state;
  DataState next_data_state;
  InstructionState instruction_state;
  InstructionState next_instruction_state;
  reg have_pending_write;

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
  assign data_ram_address_ready = data_state == GETTING_DATA_RAM_READ_ADDRESS || data_state == GETTING_DATA_RAM_WRITE_ADDRESS;
  assign data_ram_data_ready = data_state == SENDING_DATA_RAM_READ_DATA || data_state == SENDING_DATA_RAM_WRITE_APPLY;
  assign instruction_ram_read_data = instruction_ram_read_data_cache;
  assign instruction_ram_address_ready = instruction_state == GETTING_INSTRUCTION_RAM_ADDRESS;
  assign instruction_ram_data_ready = instruction_state == SENDING_INSTRUCTION_RAM_DATA;

  // read
  assign axi_read_address_id = data_state == SENDING_DATA_RAM_READ_ADDRESS ? 4'b1 : 4'b0;
  assign axi_read_address = data_state == SENDING_DATA_RAM_READ_ADDRESS ? data_ram_read_address_cache : instruction_ram_read_address_cache;
  assign axi_read_address_length = 8'b0;
  assign axi_read_address_size = data_state == SENDING_DATA_RAM_READ_ADDRESS ? data_ram_read_size_cache : instruction_ram_read_size_cache;
  assign axi_read_address_burst = 2'b1;
  assign axi_read_address_lock = 2'b0;
  assign axi_read_address_cache = 4'b0;
  assign axi_read_address_protection = 3'b0;
  assign axi_read_address_valid = data_state == SENDING_DATA_RAM_READ_ADDRESS || instruction_state == SENDING_INSTRUCTION_RAM_ADDRESS;

  assign axi_read_data_ready = data_state == GETTING_DATA_RAM_READ_DATA || instruction_state == GETTING_INSTRUCTION_RAM_DATA;

  // write
  assign axi_write_address_id = 4'b1;
  assign axi_write_address = data_ram_write_address_cache;
  assign axi_write_address_length = 8'b0;
  assign axi_write_address_size = data_ram_write_size_cache;
  assign axi_write_address_burst = 2'b1;
  assign axi_write_address_lock = 2'b0;
  assign axi_write_address_cache = 4'b0;
  assign axi_write_address_protection = 3'b0;
  assign axi_write_address_valid = data_state == SENDING_DATA_RAM_WRITE_ADDRESS;

  assign axi_write_data_id = 4'b1;
  assign axi_write_data = data_ram_write_data_cache;
  assign axi_write_data_strobe = data_ram_write_data_strobe_cache;
  assign axi_write_data_last = 1'b1;
  assign axi_write_data_valid = data_state == SENDING_DATA_RAM_WRITE_DATA;

  assign axi_write_responce_ready = data_state == GETTING_DATA_RAM_WRITE_APPLY;

  // data
  always_ff @(posedge clock) begin
    if (reset) begin
      data_state <= DATA_WAITING;
    end else begin
      data_state <= next_data_state;
    end
  end

  always_comb case(data_state)
    DATA_WAITING: begin
      if (data_ram_request && data_ram_write) begin
        next_data_state = GETTING_DATA_RAM_WRITE_ADDRESS;
      end else if (data_ram_request && ~data_ram_write) begin
        next_data_state = GETTING_DATA_RAM_READ_ADDRESS;
      end else begin
        next_data_state = data_state;
      end
    end
    GETTING_DATA_RAM_READ_ADDRESS: begin
      next_data_state = data_state.next;
    end
    SENDING_DATA_RAM_READ_ADDRESS: begin
      if (axi_read_address_ready) begin
        next_data_state = data_state.next;
      end else begin
        next_data_state = data_state;
      end
    end
    GETTING_DATA_RAM_READ_DATA : begin
      if (axi_read_data_valid && axi_read_data_id == 4'b1) begin
        next_data_state = data_state.next;
      end else begin
        next_data_state = data_state;
      end
    end
    SENDING_DATA_RAM_READ_DATA : begin
      next_data_state = DATA_WAITING;
    end
    GETTING_DATA_RAM_WRITE_ADDRESS: begin
      next_data_state = data_state.next;
    end
    SENDING_DATA_RAM_WRITE_ADDRESS: begin
      if (axi_write_address_ready) begin
        next_data_state = data_state.next;
      end else begin
        next_data_state = data_state;
      end
    end
    SENDING_DATA_RAM_WRITE_DATA : begin
      if (axi_write_data_ready) begin
        next_data_state = data_state.next;
      end else begin
        next_data_state = data_state;
      end
    end
    GETTING_DATA_RAM_WRITE_APPLY: begin
      if (axi_write_responce_valid) begin
        next_data_state = data_state.next;
      end else begin
        next_data_state = data_state;
      end
    end
    SENDING_DATA_RAM_WRITE_APPLY: begin
      next_data_state = DATA_WAITING;
    end
    default: begin
      next_data_state = DATA_WAITING;
    end
  endcase

  always_ff @(posedge clock) begin
    if (data_state == GETTING_DATA_RAM_READ_ADDRESS) begin
      data_ram_read_address_cache <= data_ram_address;
      data_ram_read_size_cache <= data_ram_size;
    end
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      have_pending_write <= 1'b0;
    end if (next_data_state == GETTING_DATA_RAM_WRITE_ADDRESS) begin
      have_pending_write <= 1'b1;
    end else if (next_data_state == DATA_WAITING) begin
      have_pending_write <= 1'b0;
    end
  end

  always_ff @(posedge clock) begin
    if (data_state == GETTING_DATA_RAM_READ_DATA && axi_read_data_valid) begin
      data_ram_read_data_cache <= axi_read_data;
    end
  end

  always_ff @(posedge clock) begin
    if (data_state == GETTING_DATA_RAM_WRITE_ADDRESS) begin
      data_ram_write_address_cache <= data_ram_address;
      data_ram_write_size_cache <= data_ram_size;
      data_ram_write_data_cache <= data_ram_write_data;
      data_ram_write_data_strobe_cache <=
        data_ram_size == 2 ? 4'b1111 :
        data_ram_size == 1 ? (data_ram_address[1:0] == 2'b10 ? 4'b1100 : 4'b0011) :
        (data_ram_address[1:0] == 2'b11 ? 4'b1000 : data_ram_address[1:0] == 2'b10 ? 4'b0100 : data_ram_address[1:0] == 2'b01 ? 4'b0010 : 4'b0001);
    end
  end

  // instruction
  always_ff @(posedge clock) begin
    if (reset) begin
      instruction_state <= INSTRUCTION_WAITING;
    end else begin
      instruction_state <= next_instruction_state;
    end
  end

  always_comb case(instruction_state)
    INSTRUCTION_WAITING: begin
      if (instruction_ram_request && ~instruction_ram_write && ~(have_pending_write && data_ram_write_address_cache == instruction_ram_address)) begin
        next_instruction_state = instruction_state.next;
      end else begin
        next_instruction_state = instruction_state;
      end
    end
    GETTING_INSTRUCTION_RAM_ADDRESS: begin
      next_instruction_state = instruction_state.next;
    end
    SENDING_INSTRUCTION_RAM_ADDRESS: begin
      if (axi_read_address_ready && data_state != SENDING_DATA_RAM_READ_ADDRESS) begin
        next_instruction_state = instruction_state.next;
      end else begin
        next_instruction_state = instruction_state;
      end
    end
    GETTING_INSTRUCTION_RAM_DATA: begin
      if (axi_read_data_valid && axi_read_data_id == 4'b0) begin
        next_instruction_state = instruction_state.next;
      end else begin
        next_instruction_state = instruction_state;
      end
    end
    SENDING_INSTRUCTION_RAM_DATA: begin
      next_instruction_state = INSTRUCTION_WAITING;
    end
    default: begin
      next_instruction_state = INSTRUCTION_WAITING;
    end
  endcase

  always_ff @(posedge clock) begin
    if (instruction_state == GETTING_INSTRUCTION_RAM_ADDRESS) begin
      instruction_ram_read_address_cache <= instruction_ram_address;
      instruction_ram_read_size_cache <= instruction_ram_size;
    end
  end

  always_ff @(posedge clock) begin
    if (instruction_state == GETTING_INSTRUCTION_RAM_DATA && axi_read_data_valid) begin
      instruction_ram_read_data_cache <= axi_read_data;
    end
  end
endmodule