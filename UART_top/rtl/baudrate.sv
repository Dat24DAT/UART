module baudrate (
    input logic sys_clk, rst,    
    output logic sample_tick
);
    parameter clk = 50000000; //50MHz
    parameter divider = 16;
    parameter baudrate = 19200; 
    parameter tick_counter = clk / (divider * baudrate);
    parameter tick_counter_width = $clog2(tick_counter);

    // declare signal state 
logic [tick_counter_width-1:0] state_next, state_reg;

// body 
// 1. register

always @(posedge sys_clk , posedge rst) begin
    if (rst) begin 
        state_reg <= 0;
    end else begin 
        state_reg <= state_next;
    end
end

// 2. next_state logic
assign state_next = (state_reg == tick_counter)? 0 : state_reg + 1'b1;

// 3. output logic
assign sample_tick = (state_reg == tick_counter)? 1'b1 : 1'b0;
endmodule
