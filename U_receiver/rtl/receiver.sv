module receiver #(
    parameter CLK_FREQ = 100_000_000,  // 100MHz
    parameter BAUD_RATE = 115200
) (
    input  logic        clk,    
    input  logic        rst_n,    
    input  logic        rx,       
    output logic [7:0]  data,     
    output logic        valid,    
    output logic        busy      
);

    localparam BIT_CYCLES = CLK_FREQ / BAUD_RATE;
    
    typedef enum logic  [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t [1:0] state;
    logic [15:0] counter;
    logic [2:0] bit_count;
    logic [7:0] shift_reg;
    
    //FSM State
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            data <= 0;
            valid <= 0;
            busy <= 0;
            counter <= 0;
            bit_count <= 0;
            shift_reg <= 0;
        end
        else begin
            valid <= 0; 
            case (state)
                IDLE: begin
                    busy <= 0;
                    if (rx == 0) begin
                        state <= START;
                        busy <= 1;
                        counter <= BIT_CYCLES/2; 
                    end
                end
                START: begin
                    if (counter == 0) begin
                        state <= DATA;
                        counter <= BIT_CYCLES;
                        bit_count <= 0;
                    end
                    else begin
                        counter <= counter - 1;
                    end
                end
                DATA: begin
                    if (counter == 0) begin
                        shift_reg <= {rx, shift_reg[7:1]}; 
                        counter <= BIT_CYCLES;
                        if (bit_count == 7) begin
                            state <= STOP;
                        end
                        else begin
                            bit_count <= bit_count + 1;
                        end
                    end
                    else begin
                        counter <= counter - 1;
                    end
                end
                STOP: begin
                    if (counter == 0) begin
                        data <= shift_reg; 
                        valid <= 1;      
                        state <= IDLE;
                    end
                    else begin
                        counter <= counter - 1;
                    end
                end
            endcase
        end
    end

endmodule