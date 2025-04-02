module baud_gen
  import definitions_pkg::*;
  (
    input   logic clk, 
    input   logic rstN,
    output  logic tick
  );

  logic [$clog2(DIVISOR)-1:0] counter_reg;
  logic [$clog2(DIVISOR)-1:0] counter_next;

  always_ff @(posedge clk) begin
    if (!rstN) begin
      counter_reg <= '0;
    end
    else begin
      counter_reg <= counter_next;
    end
  end

  assign counter_next = (counter_reg == (DIVISOR-1))? 0 : counter_reg + 1;
  assign tick = (counter_reg == 0);

endmodule: baud_gen
