module uart_rx
  import definitions_pkg::*;
  (
    input   logic       clk,
    input   logic       rstN,
    input   logic       rx,
    input   logic       s_tick,
    output  logic [7:0] dout,
    output  logic       rx_done
  );

  typedef enum logic [1:0] {
    IDLE = 2'b00,
    START = 2'b01,
    DATA = 2'b10,
    STOP = 2'b11
    } state_t;
  
  state_t state_reg, state_next;
  logic [$clog2(OVERSAMPLE)-1:0] s_reg, s_next;
  logic [2:0] n_reg, n_next;
  logic [7:0] dout_reg, dout_next;
  
  always_ff @(posedge clk) begin
    if (!rstN) begin
      state_reg <= IDLE;
      s_reg <= '0;
      n_reg <= '0;
      dout_reg <= 8'b0;
    end
    else begin
      state_reg <= state_next;
      s_reg <= s_next;
      n_reg <= n_next;
      dout_reg <= dout_next;
    end
  end

  always_comb begin
    state_next = state_reg;
    s_next = s_reg;
    n_next = n_reg;
    dout_next = dout_reg;
    rx_done = 0;

    case (state_reg) 
      IDLE: begin
        if (~rx) begin
          state_next = START;
          s_next = 0;
        end
      end
      START: begin
        if (s_tick) begin
          if (s_reg == (HOLD_TIME-1)) begin
            state_next = DATA;
            s_next = 0;
            n_next = 0;
          end
          else begin
            s_next = s_reg + 1;
          end
        end
      end
      DATA: begin
        if (s_tick) begin
          if (s_reg == (OVERSAMPLE-1)) begin
            dout_next = {rx, dout_reg[7:1]};
            s_next = 0;
            if (n_reg == 7) 
              state_next = STOP;
            else 
              n_next = n_reg + 1;
          end
          else begin
            s_next = s_reg + 1;
          end 
        end
      end
      STOP: begin
        if (s_tick) begin
          if (s_reg == (OVERSAMPLE-1)) begin
            state_next = IDLE;
            rx_done = 1'b1;
          end
          else begin
            s_next = s_reg + 1;
          end
        end
      end

    endcase
  end

  assign dout = dout_reg;

endmodule: uart_rx
