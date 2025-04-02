module uart_tx
  import definitions_pkg::*;
  (
    input   logic clk,
    input   logic rstN,
    input   logic s_tick,
    input   logic [7:0] din,
    input   logic tx_start,
    output  logic tx,
    output  logic tx_done
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
  logic [7:0] data_reg, data_next;
  logic tx_reg, tx_next;

  always_ff @(posedge clk) begin
    if (!rstN) begin
      state_reg <= IDLE;
      s_reg <= '0;
      n_reg <= '0;
      data_reg <= '0;
      tx_reg <= 1'b1;
    end
    else begin
      state_reg <= state_next;
      s_reg <= s_next;
      n_reg <= n_next;
      data_reg <= data_next;
      tx_reg <= tx_next;
    end
  end

  always_comb begin
    state_next = state_reg;
    s_next = s_reg;
    n_next = n_reg;
    data_next = data_reg;
    tx_next = tx_reg;
    tx_done = 1'b0;

    case (state_reg) 
      IDLE: begin
        tx_next = 1'b1; // hold for idle
        if (tx_start) begin
          state_next = START;
          s_next = 0;
          data_next = din;
        end
      end
      START: begin
        tx_next = 1'b0;
        if (s_tick) begin
          if (s_reg == (OVERSAMPLE-1)) begin
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
        tx_next = data_reg[0];
        if (s_tick) begin
          if (s_reg == (OVERSAMPLE-1)) begin
            data_next = (data_reg >> 1);
            s_next = 0;
            if (n_reg == 7) begin
              state_next = STOP;
            end
            else begin
              n_next = n_reg + 1;
            end
          end
          else begin
            s_next = s_reg + 1;
          end
        end
      end
      STOP: begin
        tx_next = 1'b1;
        if (s_tick) begin
          if (s_reg == (OVERSAMPLE-1)) begin
            tx_done = 1'b1;
            state_next = IDLE;
          end
          else begin
            s_next = s_reg + 1;
          end
        end
      end
    endcase
  end

  assign tx = tx_reg;

endmodule: uart_tx
