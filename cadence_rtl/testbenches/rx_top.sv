module rx_top
  (
    input   logic clk, 
    input   logic rstN,
    input   logic rx,
    output  logic [7:0] dout,
    output  logic rx_done
  );

  logic s_tick;

  uart_rx uut (
          .clk(clk),
          .rstN(rstN),
          .rx(rx),
          .s_tick(s_tick),
          .dout(dout),
          .rx_done(rx_done)
      );
      
  baud_gen baud_gen_inst (
      .clk(clk),
      .rstN(rstN),
      .tick(s_tick)
  );

endmodule: rx_top