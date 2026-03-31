`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mohamed Adel Elshiemy
// 
// Create Date: 09/10/2025 08:00:23 PM
// Design Name: 
// Module Name: FPU_SP_Params
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


parameter CMD_FPU_SP_ADD  = 4'b0001; // Single Precision (32 bit) Adder 
parameter CMD_FPU_SP_MUL  = 4'b0010; // Single Precision (32 bit) Multipler
parameter CMD_FPU_SP_DIV  = 4'b0011; // Single Precision (32 bit) Divider
parameter CMD_FPU_SP_F2I  = 4'b0100; // Single Precision (32 bit) Float to Integer
parameter CMD_FPU_SP_I2F  = 4'b0101; // Single Precision (32 bit) Integer to Float
