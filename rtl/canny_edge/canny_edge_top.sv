module canny_edge_top
  import definitions_pkg::*;
  (
    input   logic       clk, 
    input   logic       rstN,
    input   logic [7:0] pixel_in,
    input   logic       pixel_in_valid,
    output  logic [7:0] pixel_out,
    output  logic       pixel_out_valid
  );

  logic [71:0]  pl1_data_out, pl2_data_out;
  logic [98:0]  pl3_data_out; 
  logic [17:0]  pl4_data_out;
  logic [17:0]  pl5_data_out;
  logic         pl1_data_out_valid, pl2_data_out_valid, pl3_data_out_valid, pl4_data_out_valid, pl5_data_out_valid;
  logic [7:0]   gaussian_pixel_out;
  logic         gaussian_pixel_out_valid;
  logic [10:0]  gradient_magnitude;
  logic [1:0]   gradient_direction;
  logic         gradient_out_valid; 
  logic [7:0]   sobel_out;
  logic [7:0]   sobel_out_x, sobel_out_y;
  logic         sobel_xy_valid;
  logic [10:0]  nms_magnitude;
  logic [1:0]   nms_direction;
  logic         nms_valid;
  logic [1:0]   strength;
  logic         str_valid;

  pixel_loader pl1(
    .clk(clk),
    .rstN(rstN),
    .pixel_in(pixel_in),
    .pixel_in_valid(pixel_in_valid),
    .pixel_data_out(pl1_data_out),
    .pixel_data_out_valid(pl1_data_out_valid)
  );

  gaussian_filter g1(
    .clk(clk),
    .rstN(rstN),
    .gaussian_data_in(pl1_data_out),
    .gaussian_data_in_valid(pl1_data_out_valid),
    .gaussian_pixel_out(gaussian_pixel_out),
    .gaussian_pixel_out_valid(gaussian_pixel_out_valid)
  );

  pixel_loader pl2(
    .clk(clk),
    .rstN(rstN),
    .pixel_in(gaussian_pixel_out),
    .pixel_in_valid(gaussian_pixel_out_valid),
    .pixel_data_out(pl2_data_out),
    .pixel_data_out_valid(pl2_data_out_valid)
  );

  gradient_calculation gc(
    .clk(clk), 
    .rstN(rstN),
    .gradient_data_in(pl2_data_out),
    .gradient_data_in_valid(pl2_data_out_valid),
    .gradient_magnitude(gradient_magnitude),
    .gradient_direction(gradient_direction),
    .gradient_out_valid(gradient_out_valid),
    .pixel_out(sobel_out),
    .pixel_out_x(sobel_out_x),
    .pixel_out_y(sobel_out_y),
    .pixel_xy_valid(sobel_xy_valid)
  );

  pixel_loader #(.ITEM_SIZE(11)) pl3(
    .clk(clk),
    .rstN(rstN),
    .pixel_in(gradient_magnitude),
    .pixel_in_valid(gradient_out_valid),
    .pixel_data_out(pl3_data_out),
    .pixel_data_out_valid(pl3_data_out_valid)
  );

  pixel_loader #(.ITEM_SIZE(2)) pl4(
    .clk(clk),
    .rstN(rstN),
    .pixel_in(gradient_direction),
    .pixel_in_valid(gradient_out_valid),
    .pixel_data_out(pl4_data_out),
    .pixel_data_out_valid(pl4_data_out_valid)
  );

  non_max_suppression nms(
    .gradient_magnitude(pl3_data_out),
    .gradient_direction(pl4_data_out),
    .gradient_mag_valid(pl3_data_out_valid),
    .gradient_dir_valid(pl4_data_out_valid),
    .nms_magnitude(nms_magnitude),
    .nms_direction(nms_direction),
    .nms_valid(nms_valid)
  );

  double_threshold db(
    .magnitude(nms_magnitude),
    .mag_valid(nms_valid),
    .strength(strength),
    .str_valid(str_valid)
  );

  pixel_loader #(.ITEM_SIZE(2)) pl5(
    .clk(clk),
    .rstN(rstN),
    .pixel_in(strength),
    .pixel_in_valid(str_valid),
    .pixel_data_out(pl5_data_out),
    .pixel_data_out_valid(pl5_data_out_valid)
  );

  hysteresis ht(
    .strength(pl5_data_out),
    .str_valid(pl5_data_out_valid),
    .edge_out(pixel_out),
    .edge_out_valid(pixel_out_valid)
  );


endmodule: canny_edge_top