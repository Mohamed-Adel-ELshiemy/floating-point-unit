module comparator (
    output reg [2:0] result,
    input  [15:0] X, Y,
    input clk
);

    // ----------------------------------------------------------
    // 1. SIGN BIT COMPARISON (1-bit magnitude comparator)
    // ----------------------------------------------------------
    wire X_sign = X[15];
    wire Y_sign = Y[15];

    wire sign_X_gt_Y = ~X_sign &  Y_sign; // X>Y when X=0 and Y=1
    wire sign_X_lt_Y =  X_sign & ~Y_sign; // X<Y when X=1 and Y=0
    wire sign_equal  = ~(sign_X_gt_Y | sign_X_lt_Y);

    // ----------------------------------------------------------
    // 2. EXPONENT COMPARISON (5-bit magnitude comparator)
    // ----------------------------------------------------------
    wire [4:0] Xe = X[14:10];
    wire [4:0] Ye = Y[14:10];

    // Equality (XNOR all bits)
    wire exp_equal = &(Xe ~^ Ye);

    // Compute greater-than using priority logic:
    wire exp_gt = ( Xe[4] & ~Ye[4]) |
                  ( (Xe[4] ~^ Ye[4]) &  Xe[3] & ~Ye[3]) |
                  ( (Xe[4] ~^ Ye[4]) & (Xe[3] ~^ Ye[3]) &  Xe[2] & ~Ye[2]) |
                  ( (Xe[4] ~^ Ye[4]) & (Xe[3] ~^ Ye[3]) & (Xe[2] ~^ Ye[2]) & Xe[1] & ~Ye[1]) |
                  ( (Xe[4] ~^ Ye[4]) & (Xe[3] ~^ Ye[3]) & (Xe[2] ~^ Ye[2]) & (Xe[1] ~^ Ye[1]) & Xe[0] & ~Ye[0]);

    wire exp_lt = ~exp_equal & ~exp_gt;

    // ----------------------------------------------------------
    // 3. MANTISSA COMPARISON (10-bit magnitude comparator)
    // ----------------------------------------------------------
    wire [9:0] Xm = X[9:0];
    wire [9:0] Ym = Y[9:0];

    wire mant_equal = &(Xm ~^ Ym);

    wire mant_gt =
        (Xm[9] & ~Ym[9]) |
        ((Xm[9] ~^ Ym[9]) & Xm[8] & ~Ym[8]) |
        ((Xm[9] ~^ Ym[9]) & (Xm[8] ~^ Ym[8]) & Xm[7] & ~Ym[7]) |
        ((Xm[9] ~^ Ym[9]) & (Xm[8] ~^ Ym[8]) & (Xm[7] ~^ Ym[7]) & Xm[6] & ~Ym[6]) |
        ((Xm[9] ~^ Ym[9]) & (Xm[8] ~^ Ym[8]) & (Xm[7] ~^ Ym[7]) & (Xm[6] ~^ Ym[6]) & Xm[5] & ~Ym[5]) |
        ((Xm[9] ~^ Ym[9]) & (Xm[8] ~^ Ym[8]) & (Xm[7] ~^ Ym[7]) & (Xm[6] ~^ Ym[6]) & (Xm[5] ~^ Ym[5]) & Xm[4] & ~Ym[4]) |
        ((Xm[9] ~^ Ym[9]) & (Xm[8] ~^ Ym[8]) & (Xm[7] ~^ Ym[7]) & (Xm[6] ~^ Ym[6]) & (Xm[5] ~^ Ym[5]) &
         (Xm[4] ~^ Ym[4]) & Xm[3] & ~Ym[3]) |
        ((Xm[9] ~^ Ym[9]) & (Xm[8] ~^ Ym[8]) & (Xm[7] ~^ Ym[7]) & (Xm[6] ~^ Ym[6]) & (Xm[5] ~^ Ym[5]) &
         (Xm[4] ~^ Ym[4]) & (Xm[3] ~^ Ym[3]) & Xm[2] & ~Ym[2]) |
        ((Xm[9] ~^ Ym[9]) & (Xm[8] ~^ Ym[8]) & (Xm[7] ~^ Ym[7]) & (Xm[6] ~^ Ym[6]) & (Xm[5] ~^ Ym[5]) &
         (Xm[4] ~^ Ym[4]) & (Xm[3] ~^ Ym[3]) & (Xm[2] ~^ Ym[2]) & Xm[1] & ~Ym[1]) |
        ((Xm[9] ~^ Ym[9]) & (Xm[8] ~^ Ym[8]) & (Xm[7] ~^ Ym[7]) & (Xm[6] ~^ Ym[6]) & (Xm[5] ~^ Ym[5]) &
         (Xm[4] ~^ Ym[4]) & (Xm[3] ~^ Ym[3]) & (Xm[2] ~^ Ym[2]) & (Xm[1] ~^ Ym[1]) & Xm[0] & ~Ym[0]);

    wire mant_lt = ~mant_equal & ~mant_gt;

    // ----------------------------------------------------------
    // 4. FINAL PRIORITY DECISION (Same as original)
    // ----------------------------------------------------------
    always @(posedge clk) begin
        if (sign_X_gt_Y)
            result <= 3'b100;   // X > Y
        else if (sign_X_lt_Y)
            result <= 3'b010;   // X < Y
        else if (exp_gt)
            result <= 3'b100;
        else if (exp_lt)
            result <= 3'b010;
        else if (mant_gt)
            result <= 3'b100;
        else if (mant_lt)
            result <= 3'b010;
        else
            result <= 3'b001;   // equal
    end

endmodule
