module receiver #(parameter N = 8)(
   input logic clk, rst,
   input logic rx,            // notice receiving status
   input logic sample_tick,   // sample status
   output logic [N-1:0] dout, // data_in
   output logic rx_done       // receiving done status
);

    // declare state
    typedef enum logic [2:0] {idle, start, data, stop} statetype;

    // declare signal of registers
    statetype state_next, state_reg;
    logic [3:0] sample_next, sample_reg;
    logic [2:0] seriallength_next, seriallength_reg;
    logic [7:0] serial_next, serial_reg;

    // body
    // 1. register
    always @(posedge clk ,posedge rst) begin
        if (rst) begin 
            state_reg <= idle;
            sample_reg <= 0;
            seriallength_reg <= 0;
            serial_reg <= 0;
        end else begin 
            state_reg <= state_next;
            sample_reg <= sample_next;
            seriallength_reg <= seriallength_next;
            serial_reg <= serial_next;
        end
    end

    // 2. nextstate logic
    always_comb begin
        // default case 
        state_next = state_reg;
        sample_next = sample_reg;
        seriallength_next = seriallength_reg;
        serial_next = serial_reg;
        case (state_reg) 
            idle: begin 
                if (~rx) begin 
                    sample_next = 0;
                    state_next = start;
                end
            end
            start: begin 
                if(sample_tick) begin 
                    if (sample_reg==3'd7) begin 
                        sample_next = 0;
                        seriallength_next = 0;
                        state_next = data;
                    end else begin 
                        sample_next = sample_reg + 1'b1;
                    end
                end
            end
            data: begin 
                if (sample_tick) begin 
                    if (sample_reg==4'd15) begin 
                        sample_next = 0;
                        serial_next = {rx, serial_reg[7:1]};
                        if (seriallength_reg==N-1) begin 
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
                if (sample_tick) begin 
                    if (sample_reg==15) begin 
                        if (rx_done) begin 
                            state_next = idle;
                        end else begin 
                            sample_next = sample_reg + 1'b1;
                        end
                    end
                end
            end
        endcase
    end
endmodule
