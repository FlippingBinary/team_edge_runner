`timescale 1ps/1ps

module uart_rx_tb;
    import definitions_pkg::*;
    // Signals
    logic clk;
    logic rstN;
    logic rx;
    logic [7:0] dout;
    logic rx_done;

    // Instantiate the Receiver module
    rx_top top(
        .clk(clk),
        .rstN(rstN),
        .rx(rx),
        .dout(dout),
        .rx_done(rx_done)
    );
    // Clock generation
    initial begin
        clk = 0;
    end

    always #50 clk = ~clk;

    // Test procedure
    initial begin
        // Initialize signals
        rstN = 1;
        rx = 1; // Idle state for UART line

        // Apply reset
        rstN = 0;
        #100;
        rstN = 1;

        // Send 8 bytes of data
        send_byte(8'hA5); // Example byte 1
        send_byte(8'h5A); // Example byte 2
        send_byte(8'hFF); // Example byte 3
        send_byte(8'h00); // Example byte 4
        send_byte(8'h12); // Example byte 5
        send_byte(8'h34); // Example byte 6
        send_byte(8'h56); // Example byte 7
        send_byte(8'h78); // Example byte 8

        // Wait for the receiver to finish
        wait(rx_done);

        // Check the received data
        if (dout == 8'h78) begin
            $display("Test passed: Received data %h", dout);
        end else begin
            $display("Test failed: Received data %h", dout);
        end

        // End simulation
        $finish;
    end

    // Task to send a byte of data
    task send_byte(input [7:0] bytei);
        integer i;
        // Start bit
        rx = 0;
        #(100 * DIVISOR * OVERSAMPLE);
        // Data bits
        for (i = 0; i < 8; i = i + 1) begin
            rx = bytei[i];
            #(100 * DIVISOR * OVERSAMPLE);
        end
        // Stop bit
        rx = 1;
        #(100 * DIVISOR * OVERSAMPLE);
    endtask

endmodule: uart_rx_tb