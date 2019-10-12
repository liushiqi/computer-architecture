module divider (
  input clock,
  input reset,
  input divide_request_valid,
  input is_signed_input,
  input cpu_core_params::CpuData input1,
  input cpu_core_params::CpuData input2,
  output divide_result_valid,
  output cpu_core_params::CpuData divide_result,
  output cpu_core_params::CpuData divide_remain
);
  import divider_params::*;
  reg [CPU_DATA_WIDTH:0] remain;
  reg [CPU_DATA_WIDTH - 1:0] result;
  wire [CPU_DATA_WIDTH:0] not_positive_divisor, not_positive_neg_divisor;
  reg [CPU_DATA_WIDTH:0] divisor, neg_divisor;
  reg [5:0] count;
  reg negative;
  reg remain_should_negative;
  wire is_to_return;

  wire [CPU_DATA_WIDTH:0] next_remain;
  wire [CPU_DATA_WIDTH -1:0] next_result;
  wire [CPU_DATA_WIDTH -1:0] part_right_divide_remain;

  wire [CPU_DATA_WIDTH:0] temprary_remain_1;
  wire [CPU_DATA_WIDTH - 1:0] temprary_result_1;

  assign not_positive_divisor = {is_signed_input & input2[CPU_DATA_WIDTH - 1], input2};
  assign not_positive_neg_divisor = ~{is_signed_input & input2[CPU_DATA_WIDTH - 1], input2} + 1;

  assign {temprary_remain_1, temprary_result_1} = {remain[CPU_DATA_WIDTH - 1:0], result, 1'b0};
  assign next_remain = remain[CPU_DATA_WIDTH] ? temprary_remain_1 + divisor : temprary_remain_1 + neg_divisor;
  assign next_result = {temprary_result_1[CPU_DATA_WIDTH - 1:1], ~next_remain[CPU_DATA_WIDTH]};

  State state, next_state;

  assign is_to_return = count == 6'h1e;

  assign divide_result_valid = state == RETURN_STATE;
  assign divide_result = negative ? ~result + 1 : result;
  assign part_right_divide_remain = remain[CPU_DATA_WIDTH] ? (remain[CPU_DATA_WIDTH - 1:0] + divisor[CPU_DATA_WIDTH - 1:0]) : remain[CPU_DATA_WIDTH - 1:0];
  assign divide_remain = remain_should_negative ? ~part_right_divide_remain + 1 : part_right_divide_remain;

  always_ff @(posedge clock) begin: state_data
    if (reset) begin
      state <= WAITING_STATE;
    end else begin
      state <= next_state;
    end
  end: state_data

  always_comb begin: next_state_data
    next_state = WAITING_STATE;
    case (state)
      WAITING_STATE: if (divide_request_valid) begin
        next_state = LOAD_STATE;
      end else begin
        next_state = WAITING_STATE;
      end
      LOAD_STATE:
        next_state = DIVIDE_STATE;
      DIVIDE_STATE: if (is_to_return) begin
        next_state = RETURN_STATE;
      end else begin
        next_state = DIVIDE_STATE;
      end
      RETURN_STATE:
        next_state = WAITING_STATE;
      default:
        next_state = WAITING_STATE;
    endcase
  end: next_state_data

  always_ff @(posedge clock) begin: continue_data
    if (reset) begin
      count <= 0;
    end else if (state == DIVIDE_STATE) begin
      count <= count + 1;
    end else begin
      count <= 0;
    end
  end: continue_data

  always_ff @(posedge clock) begin: calculate_data
    if (reset) begin
      remain <= 0;
      result <= 0;
      divisor <= 0;
      neg_divisor <= 0;
      negative <= 0;
    end else begin
      case (next_state)
        LOAD_STATE: begin
          remain <= 0;
          result <= is_signed_input ? (input1[CPU_DATA_WIDTH - 1] ? ~input1 + 1 : input1) : input1;
          divisor <= not_positive_divisor[CPU_DATA_WIDTH] ? not_positive_neg_divisor : not_positive_divisor;
          neg_divisor <= not_positive_divisor[CPU_DATA_WIDTH] ? not_positive_divisor : not_positive_neg_divisor;
          negative <= is_signed_input & (input1[CPU_DATA_WIDTH - 1] ^ input2[CPU_DATA_WIDTH - 1]);
          remain_should_negative <= is_signed_input & input1[CPU_DATA_WIDTH - 1];
        end
        default: begin
          remain <= next_remain;
          result <= next_result;
        end
      endcase
    end
  end: calculate_data
endmodule: divider
