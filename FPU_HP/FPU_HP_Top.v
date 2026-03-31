`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mohamed Adel Elshiemy
// 
// Create Date: 11/20/2025 02:34:52 PM
// Design Name: 
// Module Name: FPU_HP_Top
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

module FPU_HP_Top (
    output reg [1:0] OFUF,
    output reg done,
    output reg [15:0] result,
    output [2:0] compResult,
    input [15:0] X, Y,
    input [1:0] opcode,
    input reset, clk 
    );

    reg addSub, mulDiv;

    wire [1:0] addSubOFUF, mulDivOFUF;
    wire addSubDone, mulDivDone;
    wire [15:0] addSubResult, mulDivResult;

    FPU_HP_ADD_SUB u0 (addSubOFUF, addSubDone, addSubResult, X, Y, addSub, reset, clk);
    FPU_HP_MUL_DIV u1 (mulDivOFUF, mulDivDone, mulDivResult, X, Y, mulDiv, reset, clk);
    FPU_HP_COMP u2 (compResult, X, Y, clk);

    always @ (*) begin //combinational logic
        case(opcode) 
            0: begin //add
                addSub = 0;
                mulDiv = 1'bz;
                OFUF = addSubOFUF;
                done = addSubDone;
                result = addSubResult;
            end
            1: begin //sub
                addSub = 1;
                mulDiv = 1'bz;
                OFUF = addSubOFUF;
                done = addSubDone;
                result = addSubResult;
            end
            2: begin //mul
                addSub = 1'bz;
                mulDiv = 0;
                OFUF = mulDivOFUF;
                done = mulDivDone;
                result = mulDivResult;
            end
            3: begin //div
                addSub = 1'bz;
                mulDiv = 1;
                OFUF = mulDivOFUF;
                done = mulDivDone;
                result = mulDivResult;                
            end
            default: begin
                addSub = 1'bz;
                mulDiv = 1'bz;
                OFUF = 1'bz;
                done = 1'bz;
                result = 1'bz;
            end
        endcase
    end

endmodule
