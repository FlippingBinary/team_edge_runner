module synchronizer
  import definitions_pkg::*;
(
    input  logic clk,
    input  logic in,
    output logic baud,
    output logic out
);

  localparam int BaudPeriod = CLOCK_RATE / BAUD_RATE;  // ex: 8
  localparam int BaudWidth = $clog2(BaudPeriod);  // ex: 4
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
  logic [1:0] in_reg = 0;
  // The pending output signal
  logic pending_out = 0;
  // Clock cycles of stability since last input transition, or baud
  logic [BaudWidth-1:0] counter = 0;

  always_ff @(posedge clk) begin
    // Double-register update
    in_reg <= {in_reg[0], in};
  end

  // Stabilize and delay the data signal
  always_ff @(posedge clk) begin
    if (in_reg[1] == pending_out || in_reg[0] == pending_out) begin
      // The input partially matches the output.
      // We're not at a transition.
      case (counter)
        ThreeQuarterBaudPeriod: begin
          counter <= (counter - HalfBaudPeriod) + 1;
          out <= pending_out;
          baud <= ~baud;
        end
        QuarterBaudPeriod: begin
          counter <= counter + 1;
          out <= pending_out;
          baud <= ~baud;
        end
        default: begin
          counter <= counter + 1;
        end
      endcase
    end else begin
      // The input is stable and different than the output.
      // We're at a transition.
      if (counter >= HalfBaudPeriod) begin
        baud <= ~baud;
      end
      counter <= 0;
      pending_out <= in_reg[1];
    end
  end
endmodule
