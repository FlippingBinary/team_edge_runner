module synchronizer (
    input  logic clk,
    input  logic in,
    output logic baud,
    output logic out
);
  import definitions_pkg::CLOCK_RATE;
  import definitions_pkg::BAUD_RATE;

  localparam int BaudPeriod = CLOCK_RATE / BAUD_RATE;  // ex: 8
  localparam int BaudWidth = $clog2(BaudPeriod);  // ex: 4
  localparam int DoubleBaudPeriod = 2 * BaudPeriod;  // ex: 16
  localparam int DoubleBaudWidth = $clog2(DoubleBaudPeriod);  // ex: 5
  localparam int HalfBaudPeriod = BaudPeriod / 2;  // ex: 4
  localparam int HalfBaudWidth = $clog2(HalfBaudPeriod);  // ex: 3
  localparam int QuarterBaudPeriod = BaudPeriod / 4;  // ex: 2
  localparam int QuarterBaudWidth = $clog2(QuarterBaudPeriod);  // ex: 2
  localparam int ThreeQuarterBaudPeriod = HalfBaudPeriod + QuarterBaudPeriod;  // ex: 6
  localparam int ThreeQuarterBaudWidth = $clog2(ThreeQuarterBaudPeriod);  // ex: 4

  initial begin
    if (CLOCK_RATE % BAUD_RATE != 0) begin
      $fatal("BAUD_RATE must be a multiple of CLOCK_RATE");
    end

    if (BaudPeriod < 8) begin
      // This also ensures QuarterBaud is at least 2
      $fatal("CLOCK_RATE must be more than 8 times BAUD_RATE");
    end
  end

  // double-register to stabilize input
  logic [QuarterBaudPeriod-1:0] in_reg = 0;
  // The pending output signal that will be activated when {pending_countdown}
  // drops to zero.
  logic pending_out = 0;
  // The number of clock cycles remaining before setting {out} to {pending_out}
  logic pending_countdown = 0;
  // The number of clock cycles remaining while baud is high.
  logic [BaudWidth-1:0] baud_high_countdown = 0;
  // The number of clock cycles remaining while baud is low.
  logic [BaudWidth-1:0] baud_low_countdown = 0;

  // Stabilize and delay the data signal
  always_ff @(posedge clk) begin
    // Double-register update
    in_reg <= {in_reg[QuarterBaudPeriod-2:0], in};

    if (in_reg[0] != pending_out && (&in_reg || ~|in_reg)) begin
      // The input is stable and different than the output.
      // We're at a transition. This transition will need to synchronize with
      // the negative edge of the baud signal in {HalfBaudPeriod} cycles.
      if (baud) begin
        // We must transition low, then transition high in time to transition
        // low when {pending_out} is ready for output.
        if (baud_high_countdown < QuarterBaudPeriod) begin
          // The baud has already been high for some time, so drop it low.
          // It needs to be low for a third of the time between the start of
          // the current {HalfBaudPeriod}.
          baud_high_countdown <= QuarterBaudPeriod - 1;
          baud_low_countdown <= QuarterBaudPeriod;
          baud <= 1'b0;
        end else begin
          baud_high_countdown <= HalfBaudPeriod - 1;
          baud_low_countdown  <= HalfBaudPeriod;
        end
      end else begin
        // We must transition high at some point between now and
        // {HalfBaudPeriod} so that we can transition low at that time.
        if (baud_low_countdown < QuarterBaudPeriod) begin
          baud_high_countdown <= QuarterBaudPeriod;
          baud_low_countdown  <= QuarterBaudPeriod - 1;
        end else begin
          baud_high_countdown <= HalfBaudPeriod;
          baud_low_countdown <= HalfBaudPeriod - 1;
          baud <= 1'b1;
        end
      end
      pending_out <= in_reg[0];
      pending_countdown <= HalfBaudPeriod;
    end else begin
      // The input partially matches the output.
      // We're not at a transition.
      if (baud_high_countdown == 0) begin
        baud <= 1'b0;
        baud_high_countdown <= HalfBaudPeriod - 1;
      end else if (baud_low_countdown == 0) begin
        baud <= 1'b1;
        baud_low_countdown <= HalfBaudPeriod - 1;
      end else begin
        baud_low_countdown  <= baud_low_countdown - (baud ? 0 : 1);
        baud_high_countdown <= baud_high_countdown - (baud ? 1 : 0);
      end

      if (pending_countdown > 0) begin
        pending_countdown <= pending_countdown - 1;
        out <= out;
      end else begin
        out <= pending_out;
      end
    end
  end
endmodule
