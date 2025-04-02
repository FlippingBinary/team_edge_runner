module uart_receiver_tb
  import definitions_pkg::*;
();
  localparam int ClockPeriod = 1e9 / CLOCK_RATE;
  localparam int BaudPeriod = 1e9 / BAUD_RATE;

  logic clk, enabled, in;
  logic busy, done, err;
  logic [7:0] out;

  // Instantiate the receiver module
  receiver uart_rx (
      .clk(clk),
      .enabled(enabled),
      .in(in),
      .busy(busy),
      .done(done),
      .err(err),
      .out(out)
  );

  // Generate clock signal
  always #ClockPeriod clk = ~clk;

  initial begin
    $display("Starting UART receiver testbench...");

    // Initialize signals
    clk = 0;
    enabled = 0;
    in = 1'b1;  // Idle state

    // Enable the receiver
    #BaudPeriod enabled = 1'b1;

    // Simulate receiving a byte (e.g., 0x5A)
    // Start bit
    in = 1'b0;
    #BaudPeriod
    // Data bits (LSB first: 01011010)
    in = 1'b0;
    #BaudPeriod;  // LSB
    in = 1'b1;
    #BaudPeriod;
    in = 1'b0;
    #BaudPeriod;
    in = 1'b1;
    #BaudPeriod;
    in = 1'b1;
    #BaudPeriod;
    in = 1'b0;
    #BaudPeriod;
    in = 1'b1;
    #BaudPeriod;
    in = 1'b0;
    #BaudPeriod;
    // Stop bit
    in = 1'b1;
    #BaudPeriod

    // Check the received data and flags
    if (out == 8'h5A && done) begin
      $display("Test passed: Received data %h", out);
    end else begin
      $display("Test failed");
    end

    // Disable the receiver
    enabled = 1'b0;
    #BaudPeriod;

    $finish;
  end
endmodule
