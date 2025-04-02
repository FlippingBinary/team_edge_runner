module non_max_suppression
  import definitions_pkg::*;
  (
    input   logic [98:0]  gradient_magnitude,
    input   logic [17:0]  gradient_direction,
    input   logic         gradient_mag_valid,
    input   logic         gradient_dir_valid,
    output  logic [10:0]  nms_magnitude,
    output  logic [1:0]   nms_direction,
    output  logic         nms_valid
  );


  logic [10:0]  curr_magnitude;
  logic [1:0]   curr_direction;

  assign curr_magnitude = gradient_magnitude[54:44];
  assign curr_direction = gradient_direction[9:8];

  assign nms_direction  = curr_direction;
  assign nms_valid      = gradient_mag_valid & gradient_dir_valid;

  always_comb begin
    nms_magnitude = curr_magnitude;
    case (curr_direction) 
      2'b00: begin
        if ((curr_magnitude <= gradient_magnitude[65:55]) || (curr_magnitude <= gradient_magnitude[43:33]))
          nms_magnitude = '0;
      end
      2'b01: begin
        if ((curr_magnitude <= gradient_magnitude[98:88]) || (curr_magnitude <= gradient_magnitude[10:0]))
          nms_magnitude = '0;
      end
      2'b10: begin
        if ((curr_magnitude <= gradient_magnitude[87:77]) || (curr_magnitude <= gradient_magnitude[21:11]))
          nms_magnitude = '0;
      end
      2'b11: begin
        if ((curr_magnitude <= gradient_magnitude[76:66]) || (curr_magnitude <= gradient_magnitude[32:21]))
          nms_magnitude = '0;
      end
    endcase
  end
  
endmodule: non_max_suppression