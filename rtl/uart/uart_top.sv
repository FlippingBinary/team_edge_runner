module uart_top
  import definitions_pkg::*;
  (
    input   logic clk,
    input   logic rstN,
    input   logic rx,
    output  logic tx,

    // receiver FIFO
    output  logic [FIFO_WIDTH-1:0] rx_rd_data,
    output  logic rx_valid,

    // transmitter FIFO
    input   logic [FIFO_WIDTH-1:0] tx_wr_data,
    input   logic tx_wr
  );

  logic s_tick;
  logic tx_full;
  logic rx_rd;

  assign rx_rd = ~tx_full;

  // receiver ports
  logic [7:0] dout;
  logic rx_done;

  // transmitter ports
  logic tx_start;
  logic [7:0] din;
  logic tx_done;

  // transmitter fifo ports
  logic [FIFO_WIDTH-1:0] tx_rd_data;
  logic tx_empty, tx_valid;
  logic rx_empty;

  
  baud_gen baud_gen_inst (
      .clk(clk),
      .rstN(rstN),
      .tick(s_tick)
  );

  uart_tx uart_tx_inst(
    .clk(clk),
    .rstN(rstN),
    .s_tick(s_tick),
    .din(tx_rd_data),
    .tx_start(tx_valid),
    .tx(tx),
    .tx_done(tx_done)
  );

  uart_rx uart_rx_inst(
    .clk(clk),
    .rstN(rstN),
    .s_tick(s_tick),
    .rx(rx),
    .dout(dout),
    .rx_done(rx_done)
  );

  fifo fifo_rx(
    .clk(clk),
    .rstN(rstN),
    .rd(rx_rd),
    .wr(rx_done),
    .wr_data(dout),
    .rd_data(rx_rd_data),
    .full(),
    .empty(rx_empty),
    .valid(rx_valid)
  );

  fifo fifo_tx(
    .clk(clk),
    .rstN(rstN),
    .rd(tx_done),
    .wr(tx_wr),
    .wr_data(tx_wr_data),
    .rd_data(tx_rd_data),
    .full(tx_full),
    .empty(tx_empty),
    .valid(tx_valid)
  );

endmodule: uart_top