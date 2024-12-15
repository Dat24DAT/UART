
module fifo_buffer_tb;

// Parameters
localparam integer CLK_PERIOD = 10000;
localparam integer B = 8;
localparam integer W = 4;
//Declare Ports
logic clk;
logic rst;
logic r;
logic w;
logic [B-1:0] w_data;
logic empty;
logic full;
logic [B-1:0] r_data;

//instantiate DUT here
fifo_buffer # (
    .B(B),
    .W(W)
  )
  fifo_buffer_inst (
    .clk(clk),
    .rst(rst),
    .r(r),
    .w(w),
    .w_data(w_data),
    .empty(empty),
    .full(full),
    .r_data(r_data)
  );


always #(CLK_PERIOD / 2) clk = !clk;
initial begin
  intialize_input_values();
  reset();
  //give inputs at the negedge of the clock here
  // Write data to FIFO
  for (int i = 0; i < 2**W; i++) begin
    @(negedge clk);
    w_data = i;
    w = 1;
    wait_clocks(1);
    w = 0; // Disable write enable after one clock cycle
  end
  for (int i = 0; i < 2**W; i++) begin
    @(negedge clk);
    r = 1;
    wait_clocks(1);
    r = 0; // Disable write enable after one clock cycle
  end
  wait_clocks(5);
  $finish();
end
////utility tasks
task reset();
  rst = 1;
  #(3 * CLK_PERIOD);
  rst = 0;
  @(negedge clk);
endtask

task intialize_input_values();
  clk = 0;
  // all inputs to zero here
  r = 1'b0;
  w = 1'b0;
  w_data = 0;
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
