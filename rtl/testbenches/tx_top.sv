module tx_top
(
  input   logic clk,
  input   logic rstN,
  input   logic tx_start,
  input   logic [7:0] din,
  output  logic tx,
  output  logic tx_done 
);

  logic s_tick;

  uart_tx uut (
      .clk(clk),
      .rstN(rstN),
      .s_tick(s_tick),
      .din(din),
      .tx_start(tx_start),
      .tx(tx),
      .tx_done(tx_done)
  );

  baud_gen baud_gen_inst (
      .clk(clk),
      .rstN(rstN),
      .tick(s_tick)
  );

endmodule: tx_top