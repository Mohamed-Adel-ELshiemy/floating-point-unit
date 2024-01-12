`timescale 1ns/1ps

module fpu_tb();

reg clk_tb;
reg  [31:0] A_tb, B_tb;
reg  [1:0] opcode_tb;
wire [31:0] O_tb;

initial
begin
	clk_tb    = 1'b1;
	A_tb      = 32'd0;
	B_tb      = 32'd0;
	opcode_tb = 2'b00;
	#10
	$display("------Addition-------");
	A_tb      = 7.5;
	B_tb      = 3.25;
	opcode_tb = 2'b00;
	#10
	$display("------Subtraction-------");
	A_tb      = 32'd7;
	B_tb      = 32'd3;
	opcode_tb = 2'b01;
	#10
	$display("------Division-------");
	A_tb      = 32'd7;
	B_tb      = 32'd3;
	opcode_tb = 2'b10;
	#10
	$display("------Multiplication-------");
	A_tb      = 32'd7;
	B_tb      = 32'd3;
	opcode_tb = 2'b11;
	#10
	$stop;
end

always #5 clk_tb = ~clk_tb;

fpu UUT(
		.clk(clk_tb),
		.A(A_tb),
		.B(B_tb),
		.opcode(opcode_tb),
		.O(O_tb)
);

endmodule
