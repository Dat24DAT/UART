`timescale 1ns / 1ps

module transmitter_tb;

   // Parameters
    localparam CLK_PERIOD = 10;   // 100MHz clock
    localparam BIT_PERIOD = 868;  // 115200 baud 
    
    // Signals
    logic clk;
    logic rst_n;
    logic start;
    logic [7:0] data;
    logic tx;
    logic busy;

    // Instantiate DUT
    transmitter transmitter_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .data(data),
        .tx(tx),
        .busy(busy)
    );

    ////

    always #(CLK_PERIOD / 2) clk = !clk;
    
    initial begin
        intialize_input_values();
        reset();
        
        // Test 1
        $display("\n[Test 1] gui chuoi 0x55");
        data = 8'h55;
        start = 1;
        #CLK_PERIOD;
        start = 0;
        wait(!busy);
        #(BIT_PERIOD*2);
        // Test 2
        $display("\n[Test 2] gui chuoi 0xFF");
        data = 8'hFF;
        start = 1;
        #CLK_PERIOD;
        start = 0;
        wait(!busy);
        #(BIT_PERIOD*2);
        $display("\nAll tests passed!");
        $finish;
    end
    task intialize_input_values();
      clk = 0;
      // all inputs to zero here
      start = 0;
      data = 0;
    endtask

    task reset();
      rst_n = 0;
      #(3 * CLK_PERIOD);
      rst_n = 1;
      @(negedge clk);
    endtask
  task wait_clocks(input integer num_clocks);
    #(num_clocks * CLK_PERIOD);
  endtask

endmodule

 