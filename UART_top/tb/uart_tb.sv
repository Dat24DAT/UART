module uart_tb;

    // Parameters
    parameter CLK_FREQ = 100_000_000;  // 100MHz
    parameter BAUD_RATE = 115200;
    parameter BIT_TIME = 1s / BAUD_RATE;
    parameter CLK_PERIOD = 1s / CLK_FREQ;
    
    // Signals
    logic clk;
    logic rst_n;
    logic tx_start;
    logic [7:0] tx_data;
    logic tx_busy;
    logic tx_out;
    logic rx_in;
    logic [7:0] rx_data;
    logic rx_valid;
    logic rx_busy;
    
    logic [7:0] test_data;
    int error_count;
    
    uart #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uart_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx_out(tx_out),
        .rx_in(rx_in),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_busy(rx_busy)
    );
    
    assign rx_in = tx_out;
    
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    initial begin
        rst_n = 0;
        tx_start = 0;
        tx_data = 0;
        error_count = 0;
        
        
        #(CLK_PERIOD * 10);
        rst_n = 1;
        #(CLK_PERIOD * 10);
        
        // Test 1: 
        test_data = 8'h55; // 01010101
        $display("Test 1: gui data 0x%h", test_data);
        tx_data = test_data;
        tx_start = 1;
        #CLK_PERIOD;
        tx_start = 0;
        wait(rx_valid);
        #(CLK_PERIOD);
      
        if (rx_data !== test_data) begin
            $error("Test 1 failed: Expected 0x%h, got 0x%h", test_data, rx_data);
            error_count++;
        end
        
        // Test 2
        #(BIT_TIME * 20);
        test_data = 8'hAA; // 10101010
        $display("Test 2: gui data 0x%h", test_data);
        tx_data = test_data;
        tx_start = 1;
        #CLK_PERIOD;
        tx_start = 0;
        
        wait(rx_valid);
        #(CLK_PERIOD);
        
        if (rx_data !== test_data) begin
            $error("Test 2 failed: Expected 0x%h, got 0x%h", test_data, rx_data);
            error_count++;
        end
        
        // Test 3: Random values
        #(BIT_TIME * 20);
        for (int i = 0; i < 10; i++) begin
            test_data = $urandom_range(0, 255);
            $display("Test 3.%0d: gui data 0x%h", i, test_data);
            tx_data = test_data;
            tx_start = 1;
            #CLK_PERIOD;
            tx_start = 0;
            
            wait(rx_valid);
            #(CLK_PERIOD);
            
            if (rx_data !== test_data) begin
                $error("Test 3.%0d failed: Expected 0x%h, got 0x%h", i, test_data, rx_data);
                error_count++;
            end
            
            #(BIT_TIME * 20);
        end
        
        
        // Summary
        if (error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("Tests completed with %0d errors", error_count);
        end
        
        $finish;
    end
    
    
endmodule