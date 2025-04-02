module double_threshold
  import definitions_pkg::*;
  (
    input   logic [10:0] magnitude,
    input   logic        mag_valid,
    output  logic [1:0]  strength, // 0 = no edge, 1 = weak edge, 2 = strong edge
    output  logic        str_valid
  );

  always_comb begin
    if (magnitude > 40) 
      strength = 2'b10; // strong
    else if (magnitude < 20)
      strength = 2'b00; // no edge
    else 
      strength = 2'b01; // weak edge
  end

  assign str_valid = mag_valid;

endmodule: double_threshold