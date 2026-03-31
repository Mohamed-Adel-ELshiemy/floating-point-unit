`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 1/05/2026 07:34:52 AM
// Design Name: 
// Module Name: FPU_Full_Test_Float_Benchmark_tb.v
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define N_TESTS 100000

module SP_F_Division_tb();

	reg clk = 0;
	reg [31:0] a;
	reg [31:0] b;
	
	wire [31:0] res;
	wire exception;

	reg [31:0] expected_res;

	reg [95:0] testVector [`N_TESTS-1:0];

	reg test_stop_enable;

	integer mcd;
	integer test_n = 0;
	integer pass   = 0;
	integer error  = 0;

	SP_F_Division DUT(a,b,exception,res);

	always #5 clk = ~clk;

	initial  
	begin 
		$readmemh("D:/MSD Full Semester/MSD620 ASIC and FPGA Design Course/Final Project/SP_F_DIV/Test.txt", testVector);
		mcd = $fopen("D:/MSD Full Semester/MSD620 ASIC and FPGA Design Course/Final Project/SP_F_DIV/Error_Results.txt");
	end 

	always @(posedge clk) 
	begin
			{a,b,expected_res} = testVector[test_n];
			test_n = test_n + 1'b1;

			#2;
			if (res[31:12] == expected_res[31:12])
				begin
					//$fdisplay (mcd,"TestPassed Test Number -> %d",test_n);
					pass = pass + 1'b1;
				end

			if (res[31:12] != expected_res[31:12])
				begin
					$fdisplay (mcd,"Test Failed Expected res = %h,Obtained res = %h,Test Number-> %d",expected_res,res,test_n);
					$display ("Zero Division Error or some other error",mcd,"Test Failed Expected res = %h,Obtained res = %h,Test Number-> %d",expected_res,res,test_n);
					error = error + 1'b1;
				end
			
			if (test_n >= `N_TESTS) 
			begin
				$fdisplay(mcd,"Completed %d tests, %d passes and %d fails.", test_n, pass, error);
				test_stop_enable = 1'b1;
			end
	end

always @(posedge test_stop_enable)
begin
$fclose(mcd);
$finish;
end

endmodule
