module mod_m_counter #(
    parameter N = 8
) (
   input logic clk, rst,
   output logic [N-1:0] q,
   output logic sample_tick
);

localparam M = 163;
// declare signal state 
logic [N-1:0] state_next, state_reg;

// body 
// 1. register

always @(posedge clk , posedge rst) begin
    if (rst) begin 
        state_reg <= 0;
    end else begin 
        state_reg <= state_next;
    end
end

// 2. next_state logic
assign state_next = (state_reg == M-1)? 0 : state_reg + 1'b1;

// 3. output logic
assign q = state_reg;
assign sample_tick = (state_reg == M-1)? 1'b1 : 1'b0;
endmodule
