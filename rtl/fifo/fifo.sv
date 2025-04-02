module fifo
  import definitions_pkg::*;
  (
    input   logic clk, 
    input   logic rstN,
    input   logic rd, wr,
    input   logic [FIFO_WIDTH-1:0] wr_data,
    output  logic [FIFO_WIDTH-1:0] rd_data,
    output  logic full, empty, valid
  );

  logic [$clog2(FIFO_DEPTH)-1:0] rd_addr, wr_addr;
  logic wr_en;

  fifo_control ctrl(
    .clk(clk), 
    .rstN(rstN),
    .rd(rd),
    .wr(wr),
    .rd_addr(rd_addr),
    .wr_addr(wr_addr),
    .wr_en(wr_en),
    .full(full),
    .empty(empty),
    .valid(valid)
  );

  fifo_data data(
    .clk(clk),
    .rstN(rstN),
    .rd_addr(rd_addr),
    .wr_addr(wr_addr),
    .wr_en(wr_en),
    .wr_data(wr_data),
    .rd_data(rd_data)
  );

endmodule: fifo
