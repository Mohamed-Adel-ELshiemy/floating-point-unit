`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mohamed Ade Elshiemy
// 
// Create Date: 01/25/2026 10:00:34 AM
// Design Name: 
// Module Name: FPU_Control_Unit
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

module FPU_Control_Unit (
    input  wire        clk,
    input  wire        reset,

    // Input configuration
    input  wire [1:0]  precision_sel,    // 00=Half, 01=Single
    input  wire [3:0]  opcode,           // ADD, SUB, MUL, DIV, COMP, F2I, I2F…
    input  wire        data_valid,

    // Ready signals from submodules
    input  wire        hp_done,
    input  wire        sp_done,

    // Control outputs
    output reg         start_hp,
    output reg         start_sp,
    output reg [3:0]   hp_op,            // Encoded: 0=ADD,1=SUB,2=MUL,3=DIV,4=COMP
    output reg [3:0]   sp_op,            // Same but for SP

    // Pipeline controls
    output reg         stage1_en,
    output reg         stage2_en,
    output reg         stage3_en,

    // Output selection
    output reg  [1:0]  out_sel,          // Select HP/SP result MUX
    output reg         ready
);

// FSM States
localparam IDLE      = 3'b000;
localparam STAGE1    = 3'b001;
localparam STAGE2    = 3'b010;
localparam STAGE3    = 3'b011;
localparam COMPLETE  = 3'b100;

reg [2:0] state, next_state;

//------------------------------------------------------
// Opcode Mapping
//------------------------------------------------------
localparam OP_ADD = 4'b0000;
localparam OP_SUB = 4'b0001;
localparam OP_MUL = 4'b0010;
localparam OP_DIV = 4'b0011;
localparam OP_COMP= 4'b0100;
localparam OP_F2I = 4'b0101;
localparam OP_I2F = 4'b0110;

//------------------------------------------------------
// FSM Sequential Logic
//------------------------------------------------------
always @(posedge clk or posedge reset) begin
    if (reset)
        state <= IDLE;
    else
        state <= next_state;
end

//------------------------------------------------------
// FSM Next-State Logic
//------------------------------------------------------
always @(*) begin
    next_state = state;
    case (state)

        IDLE: begin
            if (data_valid)
                next_state = STAGE1;
        end

        STAGE1: begin
            next_state = STAGE2;
        end

        STAGE2: begin
            next_state = STAGE3;
        end

        STAGE3: begin
            if ((precision_sel == 2'b00 && hp_done) ||
                (precision_sel == 2'b01 && sp_done))
                next_state = COMPLETE;
        end

        COMPLETE: begin
            next_state = IDLE;
        end
    endcase
end

//------------------------------------------------------
// Output & Control Logic
//------------------------------------------------------
always @(*) begin

    // Default values
    start_hp = 0;
    start_sp = 0;
    hp_op    = 4'hF;
    sp_op    = 4'hF;

    stage1_en = 0;
    stage2_en = 0;
    stage3_en = 0;

    out_sel = 2'b00;
    ready   = 0;

    case (state)

        IDLE: begin
            if (data_valid) begin
                // precision detection
                case (precision_sel)
                    2'b00: begin // Half precision
                        start_hp = 1;
                        hp_op = opcode;
                        out_sel = 2'b00;
                    end
                    2'b01: begin // Single precision
                        start_sp = 1;
                        sp_op = opcode;
                        out_sel = 2'b01;
                    end
                endcase
            end
        end

        STAGE1: begin
            stage1_en = 1;
        end

        STAGE2: begin
            stage2_en = 1;
        end

        STAGE3: begin
            stage3_en = 1;
        end

        COMPLETE: begin
            ready = 1;
        end

    endcase
end

endmodule
