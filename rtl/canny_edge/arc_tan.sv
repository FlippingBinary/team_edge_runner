module arc_tan(
  input   logic   signed [10:0]  Gx, Gy,
  output  logic          [1:0]   angle // 0: 0, 1:45, 2:90, 3:135
);

  logic [10:0] Gx_u, Gy_u; // unsigned values of gradients
  logic [21:0] Gx_cl, Gx_ch; // Gx_cl = Gx_u * 424, Gx_ch = Gx_u * 2472
  logic [21:0] Gy_c; // Gy_c = Gy_u * 1024 i.e. (Gy_u << 10)

  always_comb begin
    angle = 2'b00; 

    Gx_u  = Gx[10] ? (~Gx + 1'b1) : Gx;
    Gy_u  = Gy[10] ? (~Gy + 1'b1) : Gy;

    Gx_cl = Gx_u * 424;
    Gx_ch = Gx_u * 2472;
    Gy_c = (Gy_u << 10);

    if (Gx == 0 && Gy == 0) begin
      angle = 2'b00; 
    end
    else if (Gx == 0) begin
      angle = 2'b10; 
    end
    else if (Gy == 0) begin
      angle = 2'b00; 
    end
    else begin
      if      (Gy_c <= Gx_cl) angle = 2'b00;
      else if (Gy_c >= Gx_ch) angle = 2'b10;
      else begin
        if (((Gx > 0) && (Gy > 0)) || ((Gx < 0) && (Gy < 0))) 
          angle = 2'b01;
        else  
          angle = 2'b11;
      end 
    end
  end
  
endmodule: arc_tan