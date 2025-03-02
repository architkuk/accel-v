`timescale 1ns / 1ps

module dense_layer_tb;

  // Parameters
  localparam IN_FEATURES = 128;
  localparam OUT_FEATURES = 64;
  localparam NUM_WARMUP = 10;
  localparam NUM_ITERS = 100;
  localparam CLK_PERIOD = 10;

  // Signals
  reg clk;
  reg rst;
  reg data_in_valid;
  reg [1023:0] data_in;  // Flattened: 128 x 8 bits
  wire [511:0] data_out;  // Flattened: 64 x 8 bits
  wire data_out_valid;

  // Instantiate the dense_layer module
  dense_layer dut (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .data_in_valid(data_in_valid),
    .data_out(data_out),
    .data_out_valid(data_out_valid)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // Test stimulus
  initial begin
    integer iter, i;  // Move integer declarations here
    // Initialize signals
    rst = 1;
    data_in_valid = 0;
    data_in = 0;

    // Wait 100 ns for global reset
    #100;
    rst = 0;
    #100;

    // Warmup iterations
    for (iter = 0; iter < NUM_WARMUP; iter = iter + 1) begin
      // Random input data
      for (i = 0; i < IN_FEATURES; i = i + 1) begin
        data_in[i*8 +: 8] = i % 256;
      end
      
      data_in_valid = 1;
      #CLK_PERIOD;
      data_in_valid = 0;
      #(10*CLK_PERIOD);
    end

    // Test iterations
    for (iter = 0; iter < NUM_ITERS; iter = iter + 1) begin
      // Different input for each iteration
      for (i = 0; i < IN_FEATURES; i = i + 1) begin
        data_in[i*8 +: 8] = (1 + (i * iter)) % 256;  // Example pattern
      end
      
      data_in_valid = 1;
      #CLK_PERIOD;
      data_in_valid = 0;

      // Wait for computation to complete
      #(10*CLK_PERIOD);

      // Check output
      $display("Iteration %0d:", iter);
      for(i = 0; i < OUT_FEATURES; i = i + 1) begin
        $display("  Output[%0d]: %0d", i, data_out[i*8 +: 8]);
      end
    end

    $display("Simulation Finished.");
    $finish;
  end

endmodule
