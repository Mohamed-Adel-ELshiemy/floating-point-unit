`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mohamed Adel Elshiemy
// 
// Create Date: 11/05/2025 08:42:13 AM
// Design Name: 
// Module Name: FPU_SP_Top.v
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


module fpu_sp_top(
        input  wire          clk,
        input  wire          rst_n,
	    input  wire [3:0]    cmd,
        input  wire [31:0]   din1,
        input  wire [31:0]   din2,
        input  wire          dval,
        output wire [31:0]   result,
        output wire          rdy
);

`include "D:/MSD Full Semester/SP_FPU/Single Precision Floating Point Unit.srcs/sources_1/new/FPU_SP_Params.v"

//--------------------------------------------------
// Single Precision Adder Local decleration
// -------------------------------------------------
wire        sp_add_rdy;
wire [31:0] sp_add_result;

//--------------------------------------------------
// Single Precision Multiplication Local decleration
// -------------------------------------------------
wire        sp_mul_rdy;
wire [31:0] sp_mul_result;

//--------------------------------------------------
// Single Precision Division Local decleration
// -------------------------------------------------
wire        sp_div_rdy;
wire [31:0] sp_div_result;

//--------------------------------------------------
// Single Precision Float to integer Local decleration
// -------------------------------------------------
wire        sp_f2i_rdy;
wire [31:0] sp_f2i_result;

//--------------------------------------------------
// Single Precision integer to float Local decleration
// -------------------------------------------------
wire        sp_i2f_rdy;
wire [31:0] sp_i2f_result;

//-------------------------------------------------
//
wire sp_add_dval =  (dval) & (cmd == CMD_FPU_SP_ADD);
wire sp_mul_dval =  (dval) & (cmd == CMD_FPU_SP_MUL);
wire sp_div_dval =  (dval) & (cmd == CMD_FPU_SP_DIV);
wire sp_f2i_dval =  (dval) & (cmd == CMD_FPU_SP_F2I);
wire sp_i2f_dval =  (dval) & (cmd == CMD_FPU_SP_I2F);


assign rdy    = (cmd == CMD_FPU_SP_ADD) ? sp_add_rdy    : 
	            (cmd == CMD_FPU_SP_MUL) ? sp_mul_rdy    : 
		        (cmd == CMD_FPU_SP_DIV) ? sp_div_rdy    : 
		        (cmd == CMD_FPU_SP_F2I) ? sp_f2i_rdy    : 
		        (cmd == CMD_FPU_SP_I2F) ? sp_i2f_rdy    : 
		        1'b0;
assign result = (cmd == CMD_FPU_SP_ADD) ? sp_add_result : 
	            (cmd == CMD_FPU_SP_MUL) ? sp_mul_result : 
		        (cmd == CMD_FPU_SP_DIV) ? sp_div_result : 
		        (cmd == CMD_FPU_SP_F2I) ? sp_f2i_result : 
		        (cmd == CMD_FPU_SP_I2F) ? sp_i2f_result : 
		        1'b0;

// floating point adder
fpu_sp_add  u_sp_add (
        .clk               (clk             ),
        .rst_n             (rst_n           ),
        .din1              (din1[31:0]      ),
        .din2              (din2[31:0]      ),
        .dval              (sp_add_dval     ),
        .result            (sp_add_result   ),
        .rdy               (sp_add_rdy      )
      );

// floating point multipler
fpu_sp_mul  u_sp_mul (
        .clk               (clk             ),
        .rst_n             (rst_n           ),
        .din1              (din1[31:0]      ),
        .din2              (din2[31:0]      ),
        .dval              (sp_mul_dval     ),
        .result            (sp_mul_result   ),
        .rdy               (sp_mul_rdy      )
      );

// Floating Point Divider
SP_F_Division SP_F_Division_uut(
	.a(din1[31:0]),
	.b(din2[31:0]),
	.dval(sp_div_dval),
	.rdy(sp_div_rdy),
	.res(sp_div_result)
);

//// floating point divider
//fpu_sp_div  u_sp_div (
//        .clk               (clk             ),
//        .rst_n             (rst_n           ),
//        .din1              (din1[31:0]      ),
//        .din2              (din2[31:0]      ),
//        .dval              (sp_div_dval     ),
//        .result            (sp_div_result   ),
//        .rdy               (sp_div_rdy      )
//      );

// floating point Float to int
fpu_sp_f2i  u_sp_f2i (
        .clk               (clk             ),
        .rst_n             (rst_n           ),
        .din               (din1[31:0]      ),
        .dval              (sp_f2i_dval     ),
        .result            (sp_f2i_result   ),
        .rdy               (sp_f2i_rdy      )
      );
// floating point Float to int
fpu_sp_i2f  u_sp_i2f (
        .clk               (clk             ),
        .rst_n             (rst_n           ),
        .din               (din1[31:0]      ),
        .dval              (sp_i2f_dval     ),
        .result            (sp_i2f_result   ),
        .rdy               (sp_i2f_rdy      )
      );

endmodule
