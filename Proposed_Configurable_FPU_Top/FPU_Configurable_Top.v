`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mohamed Adel Elshiemy
// 
// Create Date: 01/25/2026 07:00:12 AM
// Design Name: 
// Module Name: SP_F_Division_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: Configurable Precision Low-Power Pipelined FPU
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module FPU_Configurable_Top (
    input  wire        clk,
    input  wire        reset,

    // Configuration Inputs
    input  wire [1:0]  precision_sel,    // 00 = Half Precision, 01 = Single Precision
    input  wire [3:0]  opcode,           // ADD/SUB/MUL/DIV/COMP/F2I/I2F
    input  wire        data_valid,

    // Operands
    input  wire [31:0] X_in,
    input  wire [31:0] Y_in,

    // Outputs
    output wire [31:0] result_out,
    output wire        ready,
    output wire [1:0]  OFUF_out,         // Only valid for HP
    output wire [2:0]  compResult_out    // Only valid for HP compare
);

///////////////////////////////////////////////////////////////////////////////
// Internal Signals
///////////////////////////////////////////////////////////////////////////////

// Half precision (HP) signals
wire [15:0] hp_result;
wire [1:0]  hp_OFUF;
wire        hp_done;
wire [2:0]  hp_comp_out;
reg  [3:0]  hp_op;

// Single precision (SP) signals
wire [31:0] sp_result;
wire        sp_done;
reg  [3:0]  sp_op;

// Control signals
wire start_hp, start_sp;
wire stage1_en, stage2_en, stage3_en;
wire [1:0] out_sel;

///////////////////////////////////////////////////////////////////////////////
// Submodule Instantiation — Half Precision Pipeline
///////////////////////////////////////////////////////////////////////////////
FPU_HP_Top u_HP (
    .OFUF   (hp_OFUF),
    .done   (hp_done),
    .result (hp_result),
    .compResult (hp_comp_out),
    .X      (X_in[15:0]),
    .Y      (Y_in[15:0]),
    .opcode (hp_op[1:0]),
    .reset  (reset),
    .clk    (clk)
);

///////////////////////////////////////////////////////////////////////////////
// Submodule Instantiation — Single Precision Pipeline
///////////////////////////////////////////////////////////////////////////////
fpu_sp_top u_SP (
    .clk    (clk),
    .rst_n  (~reset),
    .cmd    (sp_op),
    .din1   (X_in),
    .din2   (Y_in),
    .dval   (start_sp),
    .result (sp_result),
    .rdy    (sp_done)
);

///////////////////////////////////////////////////////////////////////////////
// Control Unit
///////////////////////////////////////////////////////////////////////////////
FPU_Control_Unit u_CTRL (
    .clk           (clk),
    .reset         (reset),

    .precision_sel (precision_sel),
    .opcode        (opcode),
    .data_valid    (data_valid),

    // Done signals
    .hp_done       (hp_done),
    .sp_done       (sp_done),

    // Control outputs
    .start_hp      (start_hp),
    .start_sp      (start_sp),
    .hp_op         (hp_op),
    .sp_op         (sp_op),

    .stage1_en     (stage1_en),
    .stage2_en     (stage2_en),
    .stage3_en     (stage3_en),

    .out_sel       (out_sel),
    .ready         (ready)
);

///////////////////////////////////////////////////////////////////////////////
// Output Multiplexer
///////////////////////////////////////////////////////////////////////////////
assign result_out = (out_sel == 2'b00) ? {16'b0, hp_result} : 
                    (out_sel == 2'b01) ? sp_result          :
                                          32'b0;

assign OFUF_out        = hp_OFUF;
assign compResult_out  = hp_comp_out;

endmodule
