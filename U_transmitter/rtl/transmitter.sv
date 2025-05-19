
module transmitter #(
    parameter CLK_FREQ = 100_000_000,  // 100MHz system clock
    parameter BAUD_RATE = 115200
) (
    input  logic        clk,     
    input  logic        rst_n,  
    input  logic        start,   
    input  logic [7:0]  data,    
    output logic        tx,      
    output logic        busy     
);

    
    localparam BAUD_DIVISOR = CLK_FREQ / BAUD_RATE;
    
    // FSM states
    typedef enum logic [1:0] {
        IDLE,
        START_BIT,
        DATA_BITS,
        STOP_BIT
    } state_t;
    
    state_t [1:0] state;
    logic [2:0] bit_counter;
    logic [7:0] shift_reg;
    logic [$clog2(BAUD_DIVISOR)-1:0] baud_counter;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tx <= 1;
            busy <= 0;
            bit_counter <= 0;
            shift_reg <= 0;
            baud_counter <= 0;
        end
        else begin
            unique case (state)
                IDLE: begin
                    tx <= 1; 
                    busy <= 0;
                    if (start) begin
                        state <= START_BIT;
                        shift_reg <= data;
                        busy <= 1;
                        baud_counter <= 0;
                    end
                end
                START_BIT: begin
                    tx <= 0; 
                    
                    if (baud_counter == BAUD_DIVISOR - 1) begin
                        baud_counter <= 0;
                        state <= DATA_BITS;
                        bit_counter <= 0;
                    end
                    else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                DATA_BITS: begin
                    tx <= shift_reg[0]; 
                    if (baud_counter == BAUD_DIVISOR - 1) begin
                        baud_counter <= 0;
                        shift_reg <= {1'b0, shift_reg[7:1]}; 
                        if (bit_counter == 7) begin
                            state <= STOP_BIT;
                        end
                        else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end
                    else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                STOP_BIT: begin
                    tx <= 1'b1;
                    if (baud_counter == BAUD_DIVISOR - 1) begin
                        baud_counter <= 0;
                        state <= IDLE;
                    end
                    else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
            endcase
        end
    end

endmodule