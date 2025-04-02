`timescale 1ps/1ps

module uart_tx_tb;
    import definitions_pkg::*;
    // Signals
    logic clk;
    logic rstN;
    logic [7:0] din;
    logic tx_start;
    logic tx;
    logic tx_done;

    tx_top top(
        .clk(clk),
        .rstN(rstN),
        .din(din),
        .tx_start(tx_start),
        .tx(tx),
        .tx_done(tx_done)
    );

    // Clock generation
    initial begin
        clk = 0;
    end

    always #50 clk = ~clk;

    // Test procedure
    initial begin
        // Initialize signals
        rstN = 0;
        tx_start = 0;
        din = 8'h00;

        #100;
        rstN = 1;
        #100;

        din = 8'b10010110;
        #100;
        tx_start = 1;
        #100;
        tx_start = 0;
        wait(tx_done);
        #100;
        
        din = 8'b10000111;
        #100;
        tx_start = 1;
        #100;
        tx_start = 0;
        wait(tx_done);
        #100;
        
        $finish;
    end

endmodule: uart_tx_tb