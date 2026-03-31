`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mohamed Adel Elshiemy
// 
// Create Date: 12/30/2025 09:34:00 AM
// Design Name: 
// Module Name: SP_F_Division_tb
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

module FPU_HP_ADD_SUB (
    output reg [1:0] OFUF,
    output reg done,
    output reg [15:0] result,

    input [15:0] X, Y,
    input addSub, reset, clk
);

    // ======================================================================
    //  INTERNAL REGISTERS
    // ======================================================================
    reg [3:0] state;

    reg xSign, ySign, zSign;
    reg [4:0] xExp, yExp, zExp;
    reg [10:0] xMan, yMan, zMan;

    reg xBigger;

    reg [4:0] tempExp;
    reg [10:0] tempMan;

    reg [11:0] addSubManTemp;

    reg [10:0] subNormTemp;
    reg [4:0] tempZExp;

    // ======================================================================
    //  ===================  LOGIC-GATE COMPARATOR NETWORKS  =================
    // ======================================================================
    // ----------------------------
    // 1. ZERO DETECTORS
    // ----------------------------
    wire X_is_zero = ~|X;
    wire Y_is_zero = ~|Y;

    // ----------------------------
    // 2. EXPONENT COMPARATORS
    // ----------------------------
    wire exp_equal = &(xExp ~^ yExp);

    wire exp_gt =
        ( xExp[4] & ~yExp[4]) |
        ((xExp[4] ~^ yExp[4]) &  xExp[3] & ~yExp[3]) |
        ((xExp[4] ~^ yExp[4]) & (xExp[3] ~^ yExp[3]) & xExp[2] & ~yExp[2]) |
        ((xExp[4] ~^ yExp[4]) & (xExp[3] ~^ yExp[3]) &
         (xExp[2] ~^ yExp[2]) & xExp[1] & ~yExp[1]) |
        ((xExp[4] ~^ yExp[4]) & (xExp[3] ~^ yExp[3]) &
         (xExp[2] ~^ yExp[2]) & (xExp[1] ~^ yExp[1]) &
         xExp[0] & ~yExp[0]);

    wire exp_lt = ~exp_equal & ~exp_gt;

    // ----------------------------
    // 3. MANTISSA COMPARATORS (10-bit)
    // ----------------------------
    wire man_equal = &(xMan[9:0] ~^ yMan[9:0]);

    wire man_gt =
        (xMan[9] & ~yMan[9]) |
        ((xMan[9] ~^ yMan[9]) & xMan[8] & ~yMan[8]) |
        ((xMan[9] ~^ yMan[9]) & (xMan[8] ~^ yMan[8]) & xMan[7] & ~yMan[7]) |
        ((xMan[9] ~^ yMan[9]) & (xMan[8] ~^ yMan[8]) &
         (xMan[7] ~^ yMan[7]) & xMan[6] & ~yMan[6]) |
        ((xMan[9] ~^ yMan[9]) & (xMan[8] ~^ yMan[8]) &
         (xMan[7] ~^ yMan[7]) & (xMan[6] ~^ yMan[6]) &
         xMan[5] & ~yMan[5]) |
        ((xMan[9] ~^ yMan[9]) & (xMan[8] ~^ yMan[8]) &
         (xMan[7] ~^ yMan[7]) & (xMan[6] ~^ yMan[6]) &
         (xMan[5] ~^ yMan[5]) & xMan[4] & ~yMan[4]) |
        ((xMan[9] ~^ yMan[9]) & (xMan[8] ~^ yMan[8]) &
         (xMan[7] ~^ yMan[7]) & (xMan[6] ~^ yMan[6]) &
         (xMan[5] ~^ yMan[5]) & (xMan[4] ~^ yMan[4]) &
         xMan[3] & ~yMan[3]) |
        ((xMan[9] ~^ yMan[9]) & (xMan[8] ~^ yMan[8]) &
         (xMan[7] ~^ yMan[7]) & (xMan[6] ~^ yMan[6]) &
         (xMan[5] ~^ yMan[5]) & (xMan[4] ~^ yMan[4]) &
         (xMan[3] ~^ yMan[3]) & xMan[2] & ~yMan[2]) |
        ((xMan[9] ~^ yMan[9]) & (xMan[8] ~^ yMan[8]) &
         (xMan[7] ~^ yMan[7]) & (xMan[6] ~^ yMan[6]) &
         (xMan[5] ~^ yMan[5]) & (xMan[4] ~^ yMan[4]) &
         (xMan[3] ~^ yMan[3]) & (xMan[2] ~^ yMan[2]) &
         xMan[1] & ~yMan[1]) |
        ((xMan[9] ~^ yMan[9]) & (xMan[8] ~^ yMan[8]) &
         (xMan[7] ~^ yMan[7]) & (xMan[6] ~^ yMan[6]) &
         (xMan[5] ~^ yMan[5]) & (xMan[4] ~^ yMan[4]) &
         (xMan[3] ~^ yMan[3]) & (xMan[2] ~^ yMan[2]) &
         (xMan[1] ~^ yMan[1]) & xMan[0] & ~yMan[0]);

    wire man_lt = ~man_equal & ~man_gt;

    // ----------------------------
    // 4. Hidden bit / zero mantissa detectors
    // ----------------------------
    wire xMan_is_zero = ~|xMan;
    wire yMan_is_zero = ~|yMan;

    // ----------------------------
    // 5. Leading hidden bit comparator
    // ----------------------------
    wire hidden_zero = (addSubManTemp[10] == 0); // Rewritten below:
    wire hidden_zero_gate = ~addSubManTemp[10];

    // ======================================================================
    //  COMBINATIONAL LOGIC
    // ======================================================================
    always @(*) begin

        // ----------------------------
        // State 3 exponent alignment
        // ----------------------------
        if (exp_lt) begin
            tempExp = xExp + 5'b00001;
            tempMan = xMan >> 1;
        end else if (exp_gt) begin
            tempExp = yExp + 5'b00001;
            tempMan = yMan >> 1;
        end else begin
            tempExp = 0;
            tempMan = 0;
        end

        // ----------------------------
        // State 5: addition or subtraction
        // ----------------------------
        if (~(xSign ^ ySign)) begin
            addSubManTemp = xMan + yMan;
            zSign = xSign;
        end else begin
            if (xBigger)
                addSubManTemp = xMan - yMan;
            else
                addSubManTemp = yMan - xMan;

            zSign = (xSign & xBigger);
        end

        // ----------------------------
        // State 9: normalization loop
        // ----------------------------
        if (~addSubManTemp[10]) begin
            subNormTemp = zMan << 1;
            tempZExp = zExp - 5'b00001;
        end else begin
            subNormTemp = 0;
            tempZExp = zExp;
        end
    end

    // ======================================================================
    //  SEQUENTIAL FSM
    // ======================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin

            state <= 0;

            xSign <= X[15];
            ySign <= Y[15];

            xExp <= X[14:10];
            yExp <= Y[14:10];

            xMan <= {1'b1, X[9:0]};
            yMan <= {1'b1, Y[9:0]};

            // Determine which mantissa is larger
            if (exp_gt)
                xBigger <= 1'b1;
            else if (exp_lt)
                xBigger <= 1'b0;
            else begin
                if (man_gt)
                    xBigger <= 1'b1;
                else
                    xBigger <= 1'b0;
            end

            done  <= 0;
            OFUF <= 2'b00;
        end

        else begin
            case (state)

                //------------------------------------------------------------------
                // STATE 0
                //------------------------------------------------------------------
                0: begin
                    if (X_is_zero || Y_is_zero)
                        state <= 1;
                    else begin
                        if (addSub)
                            state <= 2;
                        else begin
                            if (exp_equal)
                                state <= 5;
                            else
                                state <= 3;
                        end
                    end
                end

                //------------------------------------------------------------------
                // STATE 1 — simple zero handling
                //------------------------------------------------------------------
                1: begin
                    if (~X_is_zero)
                        result <= X;
                    else if (~Y_is_zero) begin
                        if (addSub)
                            result <= {~Y[15], Y[14:0]};
                        else
                            result <= Y;
                    end

                    done  <= 1'b1;
                    state <= 1;
                end

                //------------------------------------------------------------------
                // STATE 2 — change sign for subtraction
                //------------------------------------------------------------------
                2: begin
                    ySign <= ~ySign;
                    if (exp_equal)
                        state <= 5;
                    else
                        state <= 3;
                end

                //------------------------------------------------------------------
                // STATE 3 — exponent alignment
                //------------------------------------------------------------------
                3: begin
                    if (exp_lt) begin
                        xExp <= tempExp;
                        xMan <= tempMan;

                        if (xMan_is_zero)
                            state <= 4;
                        else if (tempExp == yExp)
                            state <= 5;
                        else
                            state <= 3;

                    end else if (exp_gt) begin

                        yExp <= tempExp;
                        yMan <= tempMan;

                        if (yMan_is_zero)
                            state <= 4;
                        else if (tempExp == xExp)
                            state <= 5;
                        else
                            state <= 3;
                    end
                end

                //------------------------------------------------------------------
                // STATE 4 — propagate zero mantissa result
                //------------------------------------------------------------------
                4: begin
                    if (xMan_is_zero)
                        result <= {zExp, Y[14:0]};
                    else if (yMan_is_zero)
                        result <= {zExp, X[14:0]};
                    done <= 1;
                    state <= 4;
                end

                //------------------------------------------------------------------
                // STATE 5 — combine mantissas
                //------------------------------------------------------------------
                5: begin
                    zExp <= xExp;
                    zMan <= addSubManTemp[10:0];

                    if (~|addSubManTemp)
                        state <= 6;
                    else if (addSubManTemp[11])
                        state <= 7;
                    else if (~addSubManTemp[10])
                        state <= 9;
                    else
                        state <= 11;
                end

                //------------------------------------------------------------------
                // STATE 6 — result = 0
                //------------------------------------------------------------------
                6: begin
                    result <= 16'b0;
                    done   <= 1;
                    state  <= 6;
                end

                //------------------------------------------------------------------
                // STATE 7 — mantissa overflow normalization
                //------------------------------------------------------------------
                7: begin
                    if (&zExp[4:1] & ~zExp[0]) // == 11110
                        state <= 8;
                    else begin
                        zMan <= addSubManTemp >> 1;
                        zExp <= zExp + 5'b00001;
                        state <= 11;
                    end
                end

                //------------------------------------------------------------------
                // STATE 8 — exponent overflow
                //------------------------------------------------------------------
                8: begin
                    result <= 16'bz;
                    OFUF   <= 2'b10;
                end

                //------------------------------------------------------------------
                // STATE 9 — left-shift normalization loop
                //------------------------------------------------------------------
                9: begin
                    if (~|zExp)
                        state <= 10;
                    else begin
                        zMan <= subNormTemp;
                        zExp <= tempZExp;

                        if (subNormTemp[10])
                            state <= 11;
                        else
                            state <= 9;
                    end
                end

                //------------------------------------------------------------------
                // STATE 10 — exponent underflow
                //------------------------------------------------------------------
                10: begin
                    OFUF <= 2'b01;
                    done <= 1;
                    state <= 10;
                end

                //------------------------------------------------------------------
                // STATE 11 — result normalized
                //------------------------------------------------------------------
                11: begin
                    result <= {zSign, zExp, zMan[9:0]};
                    done   <= 1;
                    state  <= 11;
                end

                default: state <= 0;

            endcase
        end
    end
endmodule
