package definitions_pkg;
  parameter IMAGE_WIDTH   = 512;

  // FIFO params
  parameter FIFO_WIDTH = 8;         // each entry is 1 byte pixel
  parameter FIFO_DEPTH = 8192;   // can buffer upto 16 image rows

  // UART params
  parameter int   CLK_FREQ      = 10_000_000;              
  parameter int   BAUD_RATE     = 312500;                     
  parameter real  CLK_PER_BIT   = CLK_FREQ / BAUD_RATE;        
  parameter int   OVERSAMPLE    = 16;      
  parameter int   HOLD_TIME     = OVERSAMPLE / 2;
  parameter int   DIVISOR       = CLK_PER_BIT / OVERSAMPLE;                     

  const logic [7:0] gaussian_kernel_3 [0:8] =  '{
    8'h1, 8'h2, 8'h1, 
    8'h2, 8'h4, 8'h2, 
    8'h1, 8'h2, 8'h1 
  };

  // sobel X kernel
  const logic signed [7:0] sobel_x [0:8] = '{
    8'shff, 8'sh00, 8'sh01,
    8'shfe, 8'sh00, 8'sh02,
    8'shff, 8'sh00, 8'sh01
  };

  // sobel Y kernel
  const logic signed [7:0] sobel_y [0:8] = '{
    8'shff, 8'shfe, 8'shff,
    8'sh00, 8'sh00, 8'sh00,
    8'sh01, 8'sh02, 8'sh01
  };

endpackage: definitions_pkg