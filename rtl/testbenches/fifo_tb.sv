`timescale 1ns/1ps

module fifo_tb;
  import definitions_pkg::*;

  logic clk; 
  logic rstN;
  logic rd, wr;
  logic [FIFO_WIDTH-1:0] wr_data;
  logic [FIFO_WIDTH-1:0] rd_data;
  logic full, empty, valid;

  fifo uut(
    .clk(clk),
    .rstN(rstN),
    .rd(rd),
    .wr(wr),
    .wr_data(wr_data),
    .rd_data(rd_data),
    .full(full),
    .empty(empty),
    .valid(valid)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 1;
    rstN = 0;
    rd = 0;
    wr = 0;
    @(negedge clk); 
    rstN = 1;
  end

  initial begin
    
    // write till full 
    for (int i = 0; i < FIFO_DEPTH; i++) begin
      @(negedge clk);
      wr_data = 8'hf0 + i;
      wr = 1'b1;
      @(negedge clk);
      wr = 1'b0;
    end

    // read till empty
    for (int i = 0; i < FIFO_DEPTH; i++) begin
      @(negedge clk);
      rd = 1'b1;
      @(negedge clk);
      rd = 1'b0;
    end    
    
    // read and write while empty
    @(negedge clk);
    wr_data = 8'h11;
    wr = 1;
    rd = 1;
    @(negedge clk);
    wr = 0;
    rd = 0;
    
    // read when empty
    @(negedge clk);
    rd = 1;
    @(negedge clk);
    rd = 0;

    // read when empty
    @(negedge clk);
    rd = 1;
    @(negedge clk);
    rd = 0;
    
    // read and write while empty
    @(negedge clk);
    wr_data = 8'h22;
    wr = 1;
    rd = 1;
    @(negedge clk);
    wr = 0;
    rd = 0;
        
     // read till empty
    for (int i = 0; i < FIFO_DEPTH; i++) begin
      @(negedge clk);
      rd = 1'b1;
      @(negedge clk);
      rd = 1'b0;
    end 
    
    for (int i = 0; i < 4; i++) begin
      @(negedge clk);
      wr_data = 8'he0 + i;
      wr = 1'b1;
      @(negedge clk);
      wr = 1'b0;
    end
    
    for (int i = 0; i < 4; i++) begin
      @(negedge clk);
      rd = 1'b1;
      @(negedge clk);
      rd = 1'b0;
    end 
    
    for (int i = 0; i < 8; i++) begin
      @(negedge clk);
      wr_data = 8'hf0 + i;
      wr = 1'b1;
      @(negedge clk);
      wr = 1'b0;
    end

    // read and write while full
    @(negedge clk);
    wr_data = 8'h33;
    wr = 1;
    rd = 1;
    @(negedge clk);
    wr = 0;
    rd = 0;
    
    // read and write while full
    @(negedge clk);
    wr_data = 8'h44;
    wr = 1;
    rd = 1;
    @(negedge clk);
    wr = 0;
    rd = 0;
    
    for (int i = 0; i < 16; i++) begin
      @(negedge clk);
      rd = 1'b1;
      @(negedge clk);
      rd = 1'b0;
    end 
    
    #20;
    $finish;
  end

endmodule: fifo_tb