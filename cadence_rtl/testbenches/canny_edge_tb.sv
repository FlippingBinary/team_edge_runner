`timescale 1ps/1ps

module canny_edge_tb;

  logic         clk;
  logic         rstN;
  logic [7:0]   pixel_in;
  logic         pixel_in_valid;
  logic [7:0]   pixel_out;
  logic         pixel_out_valid;

  canny_edge_top DUT(
    .clk(clk),
    .rstN(rstN),
    .pixel_in(pixel_in),
    .pixel_in_valid(pixel_in_valid),
    .pixel_out(pixel_out),
    .pixel_out_valid(pixel_out_valid)
  );

  byte image_mem[512*512]; // Array to store image data 

  task read_txt_file;
    int file;               // File handle
    int byte_data;          // Variable to store byte data
    int i;                  // Loop index
    
    // Open the file for reading
    file = $fopen("C:\\Users\\ROG\\Desktop\\canny_edge\\testImages\\images_binary\\t111.txt", "rb");
    if (file == 0) begin
      $error("ERROR: Could not open the text file.");
      $finish;
    end
    
    // Read the file byte by byte (for text files, each character is 1 byte)
    i = 0;
    while (!$feof(file)) begin
      byte_data = $fgetc(file); // Read 1 byte
      if (byte_data == -1) begin
        // End of file or an error
        break;
      end
      image_mem[i] = byte_data; // Store the byte in memory
      i = i + 1;
    end

    // Close the file
    $fclose(file);

    $display("File read complete. Total bytes read: %0d", i);
  endtask

  // Clock generation
  always #5 clk = ~clk;

  // Reset and drive the pixel input with random values
  initial begin
    clk = 1;
    rstN = 0;
    pixel_in = 8'b0;
    pixel_in_valid = 0;
    read_txt_file();

    // Apply reset for a few clock cycles
    #20;
    rstN = 1;

    for (int i = 0; i < 262144; i++) begin
      pixel_in = image_mem[i]; 
      pixel_in_valid = 1;  // Set the input valid
      #10;  // Wait for one clock cycle
    end
    pixel_in_valid = 0;
  end

  int file2;
  task clear_file;
    input string path;
    begin
      // clear the file
      file2 = $fopen(path, "w");
      if (file2 == 0) begin
        $display("Error: Unable to open file for writing.");
      end
      $fclose(file2);
    end
  endtask

  // Task to write pixel value to the .txt file
  task write_pixel_to_file;
    input logic [7:0] pixel_value;  // Pixel value to write
    input string path;
    begin
      // Open the file in append mode
      file2 = $fopen(path, "a");
      if (file2) begin
        // Write the pixel value to the file (in binary format, followed by newline)
        $fwrite(file2, "%b\n", pixel_value);  // Write binary representation of the pixel
        $fclose(file2);  // Close the file after writing
      end else begin
        $display("Error: Unable to open file for writing.");
      end
    end
  endtask

  task write_rgb_to_file;
    input logic [23:0] pixel_value;  // Pixel value to write
    input string path;
    begin
      // Open the file in append mode
      file2 = $fopen(path, "a");
      if (file2) begin
        // Write the pixel value to the file (in binary format, followed by newline)
        $fwrite(file2, "%b\n", pixel_value);  // Write binary representation of the pixel
        $fclose(file2);  // Close the file after writing
      end else begin
        $display("Error: Unable to open file for writing.");
      end
    end
  endtask

  initial begin
    clear_file("C:\\Users\\ROG\\Desktop\\canny_edge\\testImages\\output_binary\\edge.txt");
  end

  always @ (posedge clk) begin
    if (pixel_out_valid) begin
      write_pixel_to_file(pixel_out,
      "C:\\Users\\ROG\\Desktop\\canny_edge\\testImages\\output_binary\\edge.txt");
    end
  end

endmodule: canny_edge_tb