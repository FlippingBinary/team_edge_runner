module hysteresis
  import definitions_pkg::*;
  (
    input   logic [17:0]  strength,
    input   logic         str_valid,
    output  logic [7:0]   edge_out,
    output  logic         edge_out_valid
  );

  always_comb begin
    edge_out = 8'h00;
    case (strength[9:8]) // center pixel strength
      2'b00:    edge_out = 8'h00; // NO edge
      2'b10:    edge_out = 8'hff; // Strong edge
      2'b01: begin // weak edge -> check 8-connected neighbors
        for (int i=0; i < 9; i++) begin
          if (strength[i*2+:2] == 2'b10) edge_out = 8'hff;
        end
      end
      default:  edge_out = 8'h00;
    endcase
  end

  assign edge_out_valid = str_valid;

endmodule: hysteresis