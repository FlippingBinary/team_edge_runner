module fifo_data
  import definitions_pkg::*;
  (
    input   logic clk,
    input   logic rstN,
    input   logic [$clog2(FIFO_DEPTH)-1:0]  rd_addr, wr_addr,
    input   logic wr_en,
    input   logic [FIFO_WIDTH-1:0] wr_data,
    output  logic [FIFO_WIDTH-1:0] rd_data
  );

  logic [FIFO_WIDTH-1:0] queue [0:FIFO_DEPTH-1];

  always_ff @(posedge clk) begin
    if (!rstN) begin
      queue   <= '{default: 0};
    end
    else begin
      if (wr_en) begin
        queue[wr_addr] <= wr_data;
      end
    end
  end

  // First Word Fall Through FWFT FIFO implementation
  assign rd_data = queue[rd_addr];

endmodule: fifo_data