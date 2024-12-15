
module receiver_tb;

// Parameters
localparam integer CLK_PERIOD = 10000;\
localparam integer N = 8;
//Declare Ports
logic clk;
logic rst;
logic rx;
logic sample_tick;
logic [N-1:0] dout;
logic rx_done;

//instantiate DUT here
receiver # (
    .(N)
  )
  receiver_inst (
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .sample_tick(sample_tick),
    .dout(dout),
    .rx_done(rx_done)
  );

always #(CLK_PERIOD / 2) clk = !clk;
initial begin
  intialize_input_values();
  reset();
  //give inputs at the negedge of the clock here
  @(negedge clk);
  rx = 1'b0;
  wait_clocks(1);
  @(negedge clk);
  sample_tick = 1'b1;
  wait_clocks(1);
  sample_tick = 0;
  wait_clocks(4);
  @(negedge clk);
  sample_tick = 1'b1;
  wait_clocks(1);
  sample_tick = 0;
  wait_clocks(4);
  @(negedge clk);
  sample_tick = 1'b1;
  wait_clocks(1);
  sample_tick = 0;
  wait_clocks(4);
  @(negedge clk);
  sample_tick = 1'b1;
  wait_clocks(1);
  sample_tick = 0;
  wait_clocks(4);
  wait_clocks(10);
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
  rx = 1'b1;
  sample_tick = 1'b0;
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
