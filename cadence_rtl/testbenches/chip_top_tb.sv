module chip_top_tb;
  import definitions_pkg::*;

  // Clock and reset signals
  logic clk;
  logic rstN;
  
  // UART serial lines: 'rx' is the input to chip_top, 'tx' is its output
  logic rx;
  wire  tx;

  // Instantiate chip_top DUT
  chip_top uut (
    .clk(clk),
    .rstN(rstN),
    .rx(rx),
    .tx(tx)
  );

  // Clock generation: adjust CLK_PERIOD as needed
  localparam CLK_PERIOD = 10;
  always #(CLK_PERIOD/2) clk = ~clk;

  // Image memory and pixel count
  byte image_mem[512*512];
  integer total_pixels;

  // File handle for output
  int file_out;

  //--------------------------------------------------------------------------
  // Task: Read image data from file
  //--------------------------------------------------------------------------
  task read_image_file;
    int file;
    int byte_data;
    int i;
    begin
      file = $fopen("/projects/howard/edge_runners_chip_backup/aayush/canny_edge/testImages/images_binary/t001.txt", "rb");
      if (file == 0) begin
        $error("ERROR: Could not open input file.");
        $finish;
      end
      i = 0;
      while (!$feof(file)) begin
        byte_data = $fgetc(file);
        if (byte_data == -1)
          break;
        image_mem[i] = byte_data;
        i = i + 1;
      end
      total_pixels = i;
      $display("Input file read complete. Total pixels: %0d", total_pixels);
      $fclose(file);
    end
  endtask

  //--------------------------------------------------------------------------
  // Task: Clear output file
  //--------------------------------------------------------------------------
  task clear_output_file;
    input string path;
    int file_temp;
    begin
      file_temp = $fopen(path, "w");
      if (file_temp == 0)
        $display("Error: Unable to open output file for writing.");
      $fclose(file_temp);
    end
  endtask

  //--------------------------------------------------------------------------
  // Task: Write a pixel value to the output file
  //--------------------------------------------------------------------------
  task write_pixel_to_file;
    input [7:0] pixel;
    input string path;
    int file_temp;
    begin
      file_temp = $fopen(path, "a");
      if (file_temp) begin
        $fwrite(file_temp, "%b\n", pixel);
        $fclose(file_temp);
      end else begin
        $display("Error: Unable to write to output file.");
      end
    end
  endtask

  //--------------------------------------------------------------------------
  // Task: UART Transmit
  // Sends one byte serially on 'rx' using a standard UART format.
  // Assumes: 1 start bit (0), 8 data bits (LSB first), 1 stop bit (1).
  //--------------------------------------------------------------------------
  task uart_tx;
    input [7:0] data;
    integer j;
    // Define bit period; adjust BIT_PERIOD as needed for your design.
    localparam BIT_PERIOD = 320;
    begin
      // Start bit
      rx = 0;
      #(BIT_PERIOD);
      // Data bits (LSB first)
      for (j = 0; j < 8; j = j + 1) begin
        rx = data[j];
        #(BIT_PERIOD);
      end
      // Stop bit
      rx = 1;
      #(BIT_PERIOD);
      // Ensure idle state
      rx = 1;
      #(BIT_PERIOD);
    end
  endtask

  //--------------------------------------------------------------------------
  // Task: UART Receive
  // Waits for a start bit on the 'tx' line, then samples the next 8 bits.
  //--------------------------------------------------------------------------
  task uart_rx(output [7:0] data);
    integer j;
    reg [7:0] temp;
    localparam BIT_PERIOD = 320;
    begin
      // Wait half a bit period to sample in the middle of the start bit
      #(BIT_PERIOD/2);
      // Sample each data bit in the middle of its period
      for (j = 0; j < 8; j = j + 1) begin
        temp[j] = tx;
        #(BIT_PERIOD);
      end
      // Optionally, wait for the stop bit period
      #(BIT_PERIOD);
      data = temp;
    end
  endtask

  //--------------------------------------------------------------------------
  // Main Test Sequence
  //--------------------------------------------------------------------------
  initial begin
    // Initialize signals: set clock low, assert reset, and idle UART line high.
    clk = 0;
    rstN = 0;
    rx = 1;

    // Clear the output file
    clear_output_file("/projects/howard/edge_runners_chip_backup/aayush/canny_edge/testImages/output_binary/edge.txt");

    // Read input image file into memory
    read_image_file();

    // Apply reset for a short period
    #100;
    rstN = 1;
    #100;

    // For every pixel in the image, transmit it via UART,
    // then receive the processed (edge-detected) pixel from the TX line.
    for (int i = 0; i < total_pixels; i++) begin
      // Transmit pixel (as one UART frame) into chip_top
      uart_tx(image_mem[i]);
      // Wait a short delay to allow internal processing (adjust as needed)
      #(20);
    end
  end

  always @(posedge clk) begin
    if (tx == 0) begin
      // Receive the processed pixel via UART
      reg [7:0] received_pixel;
      uart_rx(received_pixel);
      // Write the received pixel to the output file
      write_pixel_to_file(received_pixel, "/projects/howard/edge_runners_chip_backup/aayush/canny_edge/testImages/output_binary/edge.txt");
    end
  end

endmodule