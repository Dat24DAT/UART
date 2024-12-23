
module baudrate_tb;

// Parameters
localparam integer CLK_PERIOD = 10000;
//Declare Ports
logic clk;
logic rst;
logic sample_tick;

//instantiate DUT here
baudrate  baudrate_inst (
    .sys_clk(clk),
    .rst(rst),
    .sample_tick(sample_tick)
  );

always #(CLK_PERIOD / 2) clk = !clk;
initial begin
  intialize_input_values();
  reset();
  //give inputs at the negedge of the clock here
  @(negedge clk);
  wait_clocks(200);
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
