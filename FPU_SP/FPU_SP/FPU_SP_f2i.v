`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mohamed Adel Elshiemy
// 
// Create Date: 10/10/2025 08:32:29 PM
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


module fpu_sp_f2i(
        input  wire          clk,
        input  wire          rst_n,
        input  wire [31:0]   din,
        input  wire          dval,
        output reg [31:0]   result,
        output reg          rdy
      );


  reg       [2:0] state;
  parameter WAIT_REQ      = 3'd0,
            SPECIAL_CASES = 3'd1,
            UNPACK        = 3'd2,
            CONVERT       = 3'd3,
            OUT_RDY       = 3'd4;

  reg [31:0] a_m, a, z;
  reg [8:0] a_e;
  reg a_s;

  always @(negedge rst_n or posedge clk)
  begin
    if (rst_n == 0) begin
      state         <= WAIT_REQ;
      rdy           <= 1'b0;
    end else begin
        case(state)
           WAIT_REQ:
           begin
             rdy   <= 1'b0;
             if (dval) begin
               a <= din;
               state <= UNPACK;
             end
           end

          UNPACK:
          begin
            a_m[31:8] <= {1'b1, a[22 : 0]};
            a_m[7:0] <= 0;
            a_e <= a[30 : 23] - 127;
            a_s <= a[31];
            state <= SPECIAL_CASES;
          end

          SPECIAL_CASES:
          begin
            if ($signed(a_e) == -127) begin
              z <= 0;
              state <= OUT_RDY;
            end else if ($signed(a_e) > 31) begin
              z <= 32'h80000000;
              state <= OUT_RDY;
            end else begin
              state <= CONVERT;
            end
          end

          CONVERT:
          begin
            if ($signed(a_e) < 31 && a_m) begin
              a_e <= a_e + 1;
              a_m <= a_m >> 1;
            end else begin
              if (a_m[31]) begin
                z <= 32'h80000000;
              end else begin
                z <= a_s ? -a_m : a_m;
              end
              state <= OUT_RDY;
            end
          end

          OUT_RDY:
          begin
            rdy        <= 1;
            result     <= z;
            state      <= WAIT_REQ;
          end

        endcase
    end
  end

endmodule
