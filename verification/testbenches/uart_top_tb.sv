module uart_top_tb
  import definitions_pkg::*;
();
  localparam int ClockPeriod = 1e9 / CLOCK_RATE;
  localparam int BaudPeriod = 1e9 / BAUD_RATE;

  logic clk, rxEnabled, txEnabled, txStart;
  logic [7:0] in;
  logic [7:0] out;
  logic rxBusy, rxDone, rxErr, txBusy, txdone;
  logic rx, tx;

  // Instantiate the uart module
  uart uart_top (
      .clk(clk),
      .rxEnabled(rxEnabled),
      .txEnabled(txEnabled),
      .in(in),
      .out(out),
      .rx(rxBusy ? 1'b0 : 1'b1),  // Simulate RX line (invert rxBusy)
      .tx(tx),
      .rxBusy(rxBusy),
      .rxDone(rxDone),
      .rxErr(rxErr),
      .txBusy(txBusy),
      .txDone(txdone)
  );

  // Generate clock signal
  always #ClockPeriod clk = ~clk;

  initial begin
    $display("Starting UART testbench...");

    // Initialize signals
    clk = 0;
    rxEnabled = 0;
    txEnabled = 0;
    txStart = 0;
    in = 8'h00;  // Default data

    // Enable the transmitter and receiver
    #BaudPeriod rxEnabled = 1'b1;
    #BaudPeriod txEnabled = 1'b1;

    // Start transmission of a byte (e.g., 0x5A)
    in = 8'h5A;
    txStart = 1'b1;
    #BaudPeriod txStart = 1'b0;  // Clear start signal

    // Wait until txdone is asserted
    @(posedge txdone);

    // Simulate receiving the transmitted byte on the RX line
    rx = tx;

    // Wait until rxDone is asserted
    @(posedge rxDone);

    // Check the received data and flags
    if (out == 8'h5A && rxDone) begin
      $display("Test passed: Received data %h", out);
    end else begin
      $display("Test failed");
    end

    // Disable the transmitter and receiver
    rxEnabled = 1'b0;
    txEnabled = 1'b0;
    #BaudPeriod;

    $finish;
  end
endmodule
