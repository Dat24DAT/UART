module uart #(
    parameter N = 8,
              W = 2
)(
   input logic clk, rst,
   input logic r_uart, w_uart, rx,
   input logic [7:0] w_data,
   output logic tx_full, rx_empty, tx,
   output logic [7:0] r_data
);

// declare internal
// rx and tx internal 
logic sample_tick, rx_done, tx_done;
// fifo buffer
logic tx_empty, tx_fifo_not_empty;
logic [7:0] tx_fifo_out, rx_data_out;

baudrate 
    baudrate_inst 
    (.sys_clk(clk), 
     .rst(rst), 
     .sample_tick(sample_tick)
);

receiver # (
    .N(N)
  )
  receiver_inst (
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .sample_tick(sample_tick),
    .dout(rx_data_out),
    .rx_done(rx_done)
);
  
transmitter # (
    .N(N)
  )
  transmitter_inst (
    .clk(clk),
    .rst(rst),
    .tx_start(tx_fifo_not_empty),
    .sample_tick(sample_tick),
    .din(tx_fifo_out),
    .tx_done(tx_done),
    .tx(tx)
);

//fifo for rx
fifo_buffer # (
    .B(N),
    .W(W)
  )
  fifo_buffer_rx (
    .clk(clk),
    .rst(rst),
    .r(r_uart),
    .w(rx_done),
    .w_data(rx_data_out),
    .empty(rx_empty),
    .full(),
    .r_data(r_data)
);

//fifo for tx
fifo_buffer # (
    .B(N),
    .W(W)
  )
  fifo_buffer_tx (
    .clk(clk),
    .rst(rst),
    .r(tx_done),
    .w(w_uart),
    .w_data(w_data),
    .empty(tx_empty),
    .full(tx_full),
    .r_data(tx_fifo_out)
);

assign tx_fifo_not_empty = !tx_empty;
endmodule
