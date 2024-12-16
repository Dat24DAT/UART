module transmitter 
#(parameter N = 8) (
    input logic clk, rst,
    input logic tx_start,      // notice transmitter status
    input logic sample_tick,   // sample status
    input logic [N-1:0] din,   // data_in
    output logic tx_done,       // receiving done status
    output logic tx    
);
    typedef enum logic [2:0] {idle, start, data, stop} statetype;

    // declare signal of registers
    statetype state_next, state_reg;
    logic [3:0] sample_next, sample_reg;
    logic [2:0] seriallength_next, seriallength_reg;
    logic [7:0] serial_next, serial_reg;
    logic tx_next, tx_reg;

    // body
    // 1. register
    always_ff @( posedge clk, posedge rst ) begin 
        if (rst) begin 
            state_reg <= idle;
            sample_reg <= 0;
            seriallength_reg <= 0;
            sample_reg <= 0;
            tx_reg <= 1'b1;
        end else begin 
            state_reg <= state_next;
            sample_reg <= sample_next;
            seriallength_reg <= seriallength_next;
            sample_reg <= sample_next;
            tx_reg <= tx_next;
        end
    end

    // 2. nextstate logic
    always_comb begin 
        state_next = state_reg;
        sample_next = sample_reg;
        seriallength_next = seriallength_reg;
        sample_next = sample_reg;
        tx_next = tx_reg;
        case (state_reg) 
            idle: begin 
                tx_next = 1'b1;
                if (tx_start) begin 
                    state_next = start;
                    sample_next = 0;
                    serial_next = din;
                end
            end
            start: begin 
                tx_next = 0;
                if (sample_tick) begin 
                    if (sample_reg==4'd15) begin 
                        state_next = data;
                        sample_next = 0;
                        seriallength_next = 0;
                    end else begin 
                        sample_next = sample_reg + 1'b1;
                    end
                end
            end
            data: begin 
                tx_next = serial_reg[0];
                if (sample_tick) begin 
                    if (sample_reg==4'd15) begin 
                        sample_next = 0;
                        serial_next = serial_reg >> 1;
                        if (seriallength_reg == (N - 1)) begin 
                            state_next = stop;
                        end else begin 
                            seriallength_next = seriallength_reg + 1'b1;
                        end 
                    end else begin 
                        sample_next = sample_reg + 1'b1;
                    end
                end
            end
            stop: begin 
                tx_next = 1'b1;
                if (sample_tick) begin 
                    if (sample_reg==4'd15) begin 
                        state_next = idle;
                    end else begin 
                        sample_next = sample_reg + 1'b1;
                    end
                end
            end
        endcase
    end
        
    
    // output 
    assign tx = tx_reg;
    assign tx_done = (state_reg==stop)?1'b1:0;
endmodule
