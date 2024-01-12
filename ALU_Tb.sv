////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//File Name: ALU_TB.v
//Created By: Mohamed Adel Milad 
//Date: 3-12-2023
//Project Name: Design of 32 Bit Floating Point ALU Based on Standard IEEE-754 in Verilog and its implementation on FPGA.
//institute: ITI
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//`include "fpu.v"
module ALU_Tb;

reg [31:0] a_operand,b_operand;
reg [1:0] Operation;
wire [31:0] ALU_Output;
/*
wire Exception;
wire Underflow;
wire Overflow;
*/
reg clk = 1'b0;

fpu dut(clk,a_operand,b_operand,Operation,ALU_Output);

always #5 clk = ~clk;

initial
begin
iteration (32'h4201_51EC,32'h4242_147B,32'h42A1_B333,2'b01,`__LINE__);

end

task iteration(
input [31:0] operand_a,operand_b,expected_value,
input [1:0] operation,
input integer line_num
//input expected_exception
);

	@(negedge clk)
	begin
		a_operand = operand_a;
		b_operand = operand_b;
		Operation = operation;
	end

	
	@(posedge clk)
	begin
		if ((expected_value == ALU_Output))
			$display ("Test Passed - Line Number -> %d", line_num);

		else 
			$display ("Test Failed Expected Result -> %h and Obtained Result -> %h of corresponding Operation -> %d and %d",expected_value,ALU_Output,operation,line_num);
	end

endtask

endmodule