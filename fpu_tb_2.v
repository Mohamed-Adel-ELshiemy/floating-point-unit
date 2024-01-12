module fpu_tb_2;
  // Inputs to the DUT are reg type
  reg clock;
  reg [31:0] a, b;
  reg [1:0] op;
  reg [31:0] correct;

  // Outputs from the DUT are wire type
  wire [31:0] out;
  wire [49:0] pro;

  // Instantiate the Device Under Test (DUT)
  // Using named instantiation
  fpu U1 (
    .clk(clock),
    .A(a),
    .B(b),
    .opcode(op),
    .O(out)
  );

  // Create a 10MHz clock
  always #100 clock = ~clock; // Every 100 nanoseconds invert
  
  wire [31:0] result,byte;
  
  // Initial blocks are sequential and start at time 0
  initial begin
    $dumpfile("fpu_tb.vcd");
    $dumpvars(0, clock, a, b, op, out);
    clock = 0;

    // Set the operation based on the command line argument
    // (Assuming that the command-line argument is passed as op)
    // You may need to modify this part based on how op is passed in your system
    if ($value$plusargs("ADD"))
      op = 2'b00;
    else if ($value$plusargs("SUB"))
      op = 2'b01;
    else if ($value$plusargs("DIV"))
      op = 2'b10;
    else if ($value$plusargs("MULT"))
      op = 2'b11;

    // Loop for the number of tests
    // If a FloatingPointError occurs, decrement n and try again
    integer n;
    for (n = 0; n < numTests; n = n + 1) begin
      // If we get a FloatingPointError: invalid value encountered in add
      // then decrement n and try again
      // try
        byte = $random;
        a = $realtobits($bitstoreal(byte));
        byte = $random;
        b = $realtobits($bitstoreal(byte));
        case (op)
          2'b00: result = a + b;
          2'b01: result = a - b;
          2'b10: result = a / b;
          2'b11: result = a * b;
        endcase

        // Assign values to inputs and expected output
        a = $realtobits(a);
        b = $realtobits(b);
        correct = $realtobits(result);

        // Display values and check correctness
        #400; // Delay for simulation

        if (op == 2'b00 && (correct - out > 2) && (out - correct > 2)) begin
          $display("A      : %b %b %b %h", a[31], a[30:23], a[22:0], a);
          $display("B      : %b %b %b %h", b[31], b[30:23], b[22:0], b);
          $display("Output : %b %b %b %h", out[31], out[30:23], out[22:0], out);
          $display("Correct: %b %b %b %h", correct[31], correct[30:23], correct[22:0], correct);
          $display();
        end
      end
    end

    $display("Done.");
    $finish; // Stop the simulation
  end
endmodule
