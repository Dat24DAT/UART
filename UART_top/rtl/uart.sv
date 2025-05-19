module uart #(
    parameter CLK_FREQ = 100_000_000,  // 100MHz system clock
    parameter BAUD_RATE = 115200
) (
    input  logic        clk,
    input  logic        rst_n,
    
    // Transmitter interface
    input  logic        tx_start,
    input  logic [7:0]  tx_data,
    output logic        tx_busy,
    output logic        tx_out,
    
    // Receiver interface
    input  logic        rx_in,
    output logic [7:0]  rx_data,
    output logic        rx_valid,
    output logic        rx_busy
);

    // Instantiate transmitter
    transmitter #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uart_tx (
        .clk(clk),
        .rst_n(rst_n),
        .start(tx_start),
        .data(tx_data),
        .tx(tx_out),
        .busy(tx_busy)
    );

    // Instantiate receiver
    receiver #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uart_rx (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx_in),
        .data(rx_data),
        .valid(rx_valid),
        .busy(rx_busy)
    );

endmodule