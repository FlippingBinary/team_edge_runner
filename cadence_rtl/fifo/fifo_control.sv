module fifo_control
  import definitions_pkg::*;
  (
    input   logic clk, 
    input   logic rstN,
    input   logic rd, wr,
    output  logic [$clog2(FIFO_DEPTH)-1:0] rd_addr, wr_addr,
    output  logic wr_en,
    output  logic full, empty, valid
  );

  logic [$clog2(FIFO_DEPTH)-1:0] rd_ptr, rd_ptr_next;
  logic [$clog2(FIFO_DEPTH)-1:0] wr_ptr, wr_ptr_next;
  logic full_next, empty_next, valid_next;

  always_ff @(posedge clk) begin
    if (!rstN) begin
      rd_ptr  <= '0;
      wr_ptr  <= '0;
      full    <= 1'b0;
      empty   <= 1'b1;
      valid   <= 0;
    end
    else begin
      rd_ptr  <= rd_ptr_next;
      wr_ptr  <= wr_ptr_next;
      full    <= full_next;
      empty   <= empty_next;
      valid   <= valid_next;
    end
  end

  always_comb begin
    rd_ptr_next  = rd_ptr;
    wr_ptr_next  = wr_ptr;
    full_next    = full;
    empty_next   = empty;
    valid_next   = ~empty; 
    wr_en = wr & (~full);
    case ({wr, rd})
      2'b01: begin // read
        if (~empty) begin
          rd_ptr_next = rd_ptr + 1'b1;
          full_next = 1'b0;
          if (rd_ptr_next == wr_ptr) begin
            empty_next = 1'b1;
            valid_next = 1'b0;
          end
        end
      end
      2'b10: begin // write
        if (~full) begin
          wr_ptr_next = wr_ptr + 1'b1;
          empty_next = 1'b0;
          valid_next = 1'b1;
          if (wr_ptr_next == rd_ptr) full_next = 1'b1;
        end
      end
      2'b11: begin // read, write
        if (~empty) begin
          wr_ptr_next = wr_ptr + 1'b1;
          rd_ptr_next = rd_ptr + 1'b1;
          if (full) wr_en = 1'b1;
        end
        else begin
          valid_next = 1'b1;
        end
      end
      default: ; // no read, no write
    endcase
  end

  // assign wr_en = (wr & (~full));   

  assign rd_addr = rd_ptr;
  assign wr_addr = wr_ptr;

endmodule: fifo_control