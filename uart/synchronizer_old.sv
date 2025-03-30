// This module generates a baud clock that is synchronized to the input signal.

module synchronizer
  import definitions_pkg::*;
(
    input  logic clk,    // System clock
    input  logic enabled,  // System reset
    input  logic rx,     // Received signal
    output logic rxClk   // Synchronized clock signal
);

  localparam int OversampleCycles = CLOCK_RATE / BAUD_RATE;  // ex: 8
  localparam int HalfBaudCycles = OversampleCycles / 2;  // ex: 4
  localparam int HalfBaudWidth = $clog2(HalfBaudCycles);  // ex: 3
  localparam int QuarterBaudCycles = OversampleCycles / 4;  // ex: 2
  localparam int QuarterBaudWidth = $clog2(QuarterBaudCycles);  // ex: 2

  initial begin
    if (CLOCK_RATE % BAUD_RATE != 0) begin
      $fatal("BAUD_RATE must be a multiple of CLOCK_RATE");
    end

    if (OversampleCycles < 8) begin
      // This also ensures QuarterBaud is at least 2
      $fatal("CLOCK_RATE must be more than 8 times BAUD_RATE");
    end
  end

  typedef enum logic [1:0] {
    IDLE,  // Waiting for stable high input
    STARTING,  // Waiting for stable low input
    SYNCHRONIZING,  // Waiting for stable high input again
    CONNECTED  // Transmitting the buffered signal
  } state_t;

  state_t state = IDLE;
  // {OversampleCycles} plus one for a double-register
  logic [OversampleCycles:0] in_buffer = '{default: 0};
  logic [HalfBaudCycles-1:0] high_pattern = {QuarterBaudCycles{1'b1}};
  logic [HalfBaudCycles-1:0] low_pattern = {QuarterBaudCycles{1'b0}};
  // A counter for the baud generator in the connected state
  logic [HalfBaudWidth-1:0] counter = 0;

  always_ff @(posedge clk) begin
    if (!enabled) begin
      state <= IDLE;
    end
  end

  always_ff @(posedge clk) begin
    // Shift the input buffer with new input
    in_buffer <= {in_buffer[OversampleCycles-1:0], rx};
  end

  always_ff @(posedge clk) begin
    unique case (state)
      IDLE: begin
        rxClk <= 1'b1;
        // We're looking for the signal to transition from high to low,
        // with quarter baud stability for both halves of the transition.
        if (in_buffer[HalfBaudCycles:1] == {high_pattern, low_pattern}) begin
          state <= STARTING;
        end
      end
      STARTING: begin
        rxClk <= 1'b0;
        // We're looking for the signal to transition from low to high,
        // with quarter baud stability for both halves of the transition.
        if (in_buffer[HalfBaudCycles:1] == {low_pattern, high_pattern}) begin
          state <= SYNCHRONIZING;
        end
      end
      SYNCHRONIZING: begin
        rxClk <= 1'b1;
        // We're looking for the signal to transition from high to low,
        // with quarter baud stability for both halves of the transition.
        if (in_buffer[HalfBaudCycles:1] == {high_pattern, low_pattern}) begin
          state <= CONNECTED;
          // The counter starts at the 
          counter <= QuarterBaudCycles[HalfBaudWidth-1:0];
        end
      end
      CONNECTED: begin
      end
    endcase
    if (enabled) begin
      if (!synchronized) begin
        rxClk <= 1'b1;
        if (in_buffer && !in_reg) begin
          // All the bits in the {in_buffer} are high
        end
        if (counter >= QuarterBaudCycles) begin
          if (|in_buffer) begin
            // At least one bit in the buffer is high, so limit the counter
            counter <= QuarterBaudCycles;
          end else synchronized <= 1'b1;
        end else begin
          counter <= counter + 1;
        end
      end else begin
        if (counter >= HalfBaudCycles) begin
          rxClk   <= ~rxClk;
          counter <= '{default: 0};
        end else begin
          counter <= counter + 1;
        end
      end
    end else begin
      synchronized <= 1'b0;
      counter <= '{default: 0};
    end
  end
endmodule
