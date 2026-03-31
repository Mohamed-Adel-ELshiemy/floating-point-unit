`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mohamed Adel Elshiemy
// 
// Create Date: 11/25/2025 12:00:42 PM
// Design Name: 
// Module Name: FPU_HP_MUL_DIV
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

module FPU_HP_MUL_DIV (
    output reg [1:0] OFUF, 
    output reg done, 
    output reg [15:0] result,
    input [15:0] X, Y,
    input mulDiv, reset, clk
);

    // ============================================
    // STATE REGISTERS & INTERNAL SIGNALS
    // ============================================
    reg [2:0] state;
    reg xSign, ySign, zSign;
    reg [4:0] xExp, yExp, zExp, tempExp;
    reg [10:0] xMan, yMan;

    reg signed [5:0] expSum;
    reg [21:0] manTemp;
    reg [21:0] manTempShifted;

    // ============================================================
    //  GATE-EQUIVALENT COMPARATOR LOGIC (NO < OR > OPERATORS)
    // ============================================================

    // -----------------------------
    // Equality detection (all sizes)
    // -----------------------------
    wire X_zero  = (X ~^ 16'b0) == 16'hFFFF;
    wire Y_zero  = (Y ~^ 16'b0) == 16'hFFFF;

    // -----------------------------
    // Comparison for expSum (signed 6-bit)
    // expSum_lt_zero
    // expSum_gt_30
    // -----------------------------

    wire expSum_sign = expSum[5];    // MSB = sign bit

    // expSum < 0  → sign bit = 1
    wire expSum_lt_zero = expSum_sign;

    // Compare expSum > 30 (decimal) = 5'b11110
    wire [5:0] CMP_30 = 6'b011110;

    wire expSum_gt_30 =
        (expSum[5] & ~CMP_30[5]) ? 1'b0 :    // negative cannot be >30
        (~expSum[5] & CMP_30[5]) ? 1'b1 :
        (expSum[4] & ~CMP_30[4]) ? 1'b1 :
        (~expSum[4] & CMP_30[4]) ? 1'b0 :
        (expSum[3] & ~CMP_30[3]) ? 1'b1 :
        (~expSum[3] & CMP_30[3]) ? 1'b0 :
        (expSum[2] & ~CMP_30[2]) ? 1'b1 :
        (~expSum[2] & CMP_30[2]) ? 1'b0 :
        (expSum[1] & ~CMP_30[1]) ? 1'b1 :
        (~expSum[1] & CMP_30[1]) ? 1'b0 :
        (expSum[0] & ~CMP_30[0]) ? 1'b1 :
        (~expSum[0] & CMP_30[0]) ? 1'b0 : 1'b0;

    // ============================================================
    //  MANTISSA OVERFLOW SHIFT DECISION:
    //  REPLACE: if (manTemp[20] == 1)
    // ============================================================
    wire manTemp20_is1 = manTemp[20];
    wire manTemp21_is1 = manTemp[21];

    // ============================================================
    //  MANUAL 22-BIT GREATER-THAN COMPARATOR (NO > USED)
    // ============================================================

    function automatic gt22;
        input [21:0] A, B;
        integer i;
        begin
            gt22 = 0;
            for (i = 21; i >= 0; i = i - 1) begin
                if (A[i] ^ B[i]) begin
                    gt22 = A[i];   // if A[i]=1 & B[i]=0 → A>B
                    disable gt22;
                end
            end
        end
    endfunction

    function automatic lt22;
        input [21:0] A, B;
        integer i;
        begin
            lt22 = 0;
            for (i = 21; i >= 0; i = i - 1) begin
                if (A[i] ^ B[i]) begin
                    lt22 = B[i];   // if A[i]=0 & B[i]=1 → A<B
                    disable lt22;
                end
            end
        end
    endfunction

    wire manTemp_gt_zero = gt22(manTemp, 22'b0);
    wire manTemp_lt_zero = lt22(manTemp, 22'b0);

    // ============================================================
    // COMBINATORIAL MULT/DIV BLOCK
    // ============================================================
    always @(*) begin
        
        if (mulDiv == 1'b0) begin
            expSum = xExp + yExp - 6'd15;
            manTemp = xMan * yMan;
        end else begin
            expSum = xExp - yExp + 6'd15;
            manTemp = {xMan, 11'b0} / {11'b0, yMan};
        end

        zSign = xSign ^ ySign;

        tempExp = zExp + 1;
    end

    // ============================================================
    // SEQUENTIAL FSM (NO COMPARATORS INSIDE)
    // ============================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;

            xSign <= X[15];
            ySign <= Y[15];
            xExp  <= X[14:10];
            yExp  <= Y[14:10];
            xMan  <= {1'b1, X[9:0]};
            yMan  <= {1'b1, Y[9:0]};

            done <= 0;
            OFUF <= 2'b00;
        end else begin

            case(state)

                0: begin
                    if (X_zero || Y_zero) begin
                        if (X_zero)
                            result <= 16'b0;
                        else if (mulDiv == 1'b0)
                            result <= 16'b0;
                        else
                            OFUF <= 2'b10;   // divide by zero → overflow
                        state <= 1;
                    end else begin
                        state <= 2;
                    end
                end

                1: state <= 1;

                2: begin
                    if (expSum_lt_zero) begin
                        OFUF <= 2'b01;
                        done <= 1;
                        state <= 3;
                    end else if (expSum_gt_30) begin
                        state <= 3;
                    end else
                        state <= 4;
                end

                3: state <= 3;

                4: begin
                    zExp <= expSum;

                    if (mulDiv)
                        manTempShifted <= {1'b0, manTemp[10:0], 10'b0};
                    else
                        manTempShifted <= manTemp;

                    if (manTemp21_is1) begin
                        if (expSum_gt_30) begin
                            OFUF <= 2'b10;
                            done <= 1;
                            state <= 3;
                        end else
                            state <= 7;
                    end else begin
                        if (manTemp20_is1) begin
                            manTempShifted <= manTemp << 1;
                            state <= 7;
                        end else
                            state <= 5;
                    end
                end

                5: begin
                    if (zExp == 5'b0)
                        state <= 6;
                    else begin
                        manTempShifted <= manTempShifted << 1;
                        zExp <= zExp - 1;
                        if (manTempShifted[20])
                            state <= 7;
                        else
                            state <= 5;
                    end
                end

                6: begin
                    OFUF <= 2'b01;
                    done <= 1;
                    state <= 6;
                end

                7: begin
                    if (manTemp21_is1)
                        result <= {zSign, tempExp, manTemp[20:11]};
                    else
                        result <= {zSign, zExp, manTempShifted[20:11]};

                    done <= 1;
                    state <= 7;
                end
            endcase
        end
    end

endmodule
