`timescale 1ns / 1ps

module receiver_tb;

    // Parameters
    localparam CLK_PERIOD = 10;   // 100MHz clock
    localparam BIT_PERIOD = 868;  // 115200 baud (868 clocks at 100MHz)
    
    // Signals
    logic clk;
    logic rst_n;
    logic rx;
    logic [7:0] data;
    logic valid;
    logic busy;

    // Instantiate DUT
    receiver  #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(115200)
    ) receiver_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .data(data),
        .valid(valid),
        .busy(busy)
    );

    // Clock generation
    always #(CLK_PERIOD / 2) clk = !clk;
    
    // Task to send one UART byte
    task send_byte(input [7:0] byte_data);
        rx = 0; #BIT_PERIOD;                   
        for (int i = 0; i < 8; i++) begin      
            rx = byte_data[i];
            #BIT_PERIOD;
        end
        rx = 1; #BIT_PERIOD;                  
    endtask
    
    initial begin
        initialize_input_values();
        reset();
        
        // Test 1: Receive 0x55
        $display("\n[Test 1] Nhan chuoi 0x55");
        send_byte(8'h55);
        wait(valid);
        if (data === 8'h55) 
            $display("Nhan dung: 0x%h", data);
        else
            $display("Loi: Nhan duoc 0x%h, mong doi 0x55", data);
        
        #(BIT_PERIOD*2);
        
        // Test 2: Receive 0xFF
        $display("\n[Test 2] Nhan chuoi 0xFF");
        send_byte(8'hFF);
        wait(valid);
        if (data === 8'hFF) 
            $display("Nhan dung: 0x%h", data);
        else
            $display("Loi: Nhan duoc 0x%h, mong doi 0xFF", data);
        
        #(BIT_PERIOD*2);
        
        $display("\nAll tests completed!");
        $finish;
    end
    
    task initialize_input_values();
        clk = 0;
        rx = 1;  
        rst_n = 1;
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