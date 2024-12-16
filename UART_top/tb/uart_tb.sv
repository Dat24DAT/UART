
module uart_tb;

// Parameters
localparam integer CLK_PERIOD = 10000;
localparam integer N = 8;
localparam integer W = 2;
//Declare Ports
logic clk;
logic rst;
logic r_uart;
logic w_uart;
logic rx;
logic [7:0] w_data;
logic tx_full;
logic rx_empty;
logic tx;
logic [7:0] r_data;

//instantiate DUT here
uart # (
    .N(N),
    .W(W)
  )
  uart_inst (
    .clk(clk),
    .rst(rst),
    .r_uart(r_uart),
    .w_uart(w_uart),
    .rx(rx),
    .w_data(w_data),
    .tx_full(tx_full),
    .rx_empty(rx_empty),
    .tx(tx),
    .r_data(r_data)
  );

always #(CLK_PERIOD / 2) clk = !clk;
initial begin
  intialize_input_values();
  reset();
  //give inputs at the negedge of the clock here
  // Test Case 1: Write Data
  write_data(8'hA5); // Example data
  wait_clocks(10); // Wait for the UART to process

  // Test Case 2: Read Data
  read_data();

  // Test Case 3: Check for overflow condition
  // Attempt to write data when tx_full is high
  w_uart = 1;
  w_data = 8'hFF; // Attempt to write
  @(negedge clk);
  if (tx_full) begin
      $display("Passed overflow test: tx_full is high, cannot write.");
  end else begin
      $error("Failed overflow test: tx_full is low, should be high.");
  end
  
  $finish();
end
//utility tasks
task reset();
  rst = 1;
  #(3 * CLK_PERIOD);
  rst = 0;
  @(negedge clk);
endtask

task intialize_input_values();
  clk = 0;
  // all inputs to zero here
  r_uart = 0;
  w_uart = 0;
  rx = 1; // Idle state for RX line
  w_data = 8'b0;
endtask

task write_data(input logic [7:0] data);
    @(negedge clk);
    w_data = data;
    w_uart = 1; // Assert write
    @(negedge clk);
    w_uart = 0; // Deassert write
endtask

task read_data();
    @(negedge clk);
    r_uart = 1; // Assert read
    @(negedge clk);
    if (!rx_empty) begin
        check_outputs(r_data, 8'hA5); // Check if received data matches sent data
    end else begin
        $error("Failed read test: rx_empty is high, no data to read.");
    end
    r_uart = 0; // Deassert read
endtask

task check_outputs(input logic [0:2] outputs, input logic [0:2] expected_outputs);
  @(negedge clk);
  assert (outputs === expected_outputs) begin
    $display("Passed the test case");
  end else $error("Failed. Outputs: %3d Expected Outputs: %3d", outputs, expected_outputs);

endtask

task wait_clocks(input integer num_clocks);
  #(num_clocks * CLK_PERIOD);
endtask
endmodule
