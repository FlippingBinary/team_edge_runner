module uart_transmitter_tb
  import definitions_pkg::*;
();
  localparam int ClockPeriod = 1e9 / CLOCK_RATE;
  localparam int BaudPeriod = 1e9 / BAUD_RATE;

  logic clk, enabled, start;
  logic [7:0] in;
  logic busy, done, out;

  // Instantiate the transmitter module
  transmitter uart_tx (
      .clk(clk),
      .enabled(enabled),
      .start(start),
      .data(in),
      .busy(busy),
      .done(done),
      .out(out)
  );

  // Generate clock signal
  always #ClockPeriod clk = ~clk;

  initial begin
    $display("Starting UART transmitter testbench...");

    // Initialize signals
    clk = 0;
    enabled = 0;
    start = 0;
    in = 8'h00;  // Default data

    // Enable the transmitter
    #BaudPeriod enabled = 1'b1;

    // Start transmission of a byte (e.g., 0x5A)
    in = 8'h5A;
    start = 1'b1;
    #BaudPeriod start = 1'b0;  // Clear start signal

    // Wait until done is asserted
    @(posedge done);

    // Check the output sequence (start bit, data bits LSB first, stop bit)
    if (out == 1'b0) begin  // Start bit
      $display("Start bit correctly transmitted");
    end else begin
      $display("Error in start bit transmission");
    end

    #BaudPeriod;  // Data bits
    if (out == 1'b0 && out == 1'b1 && out == 1'b0 && out == 1'b1 &&
            out == 1'b1 && out == 1'b0 && out == 1'b1 && out == 1'b0) begin // Data bits LSB first
      $display("Data bits correctly transmitted");
    end else begin
      $display("Error in data bits transmission");
    end

    #BaudPeriod;  // Stop bit
    if (out == 1'b1) begin  // Stop bit
      $display("Stop bit correctly transmitted");
    end else begin
      $display("Error in stop bit transmission");
    end

    // Disable the transmitter
    enabled = 1'b0;
    #BaudPeriod;

    $finish;
  end
endmodule
