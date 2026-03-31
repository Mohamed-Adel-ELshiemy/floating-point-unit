`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mohamed Adel Elshiemy
// 
// Create Date: 10/05/2025 08:00:00 AM
// Design Name: 
// Module Name: FPU_SP_i2f.v
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


module fpu_sp_i2f(
        input  wire          clk,
        input  wire          rst_n,
        input  wire [31:0]   din,
        input  wire          dval,
        output reg [31:0]   result,
        output reg          rdy
      );


  reg       [2:0] state;
  parameter WAIT_REQ      = 3'd0,
            CONVERT_0     = 3'd1,
            CONVERT_1     = 3'd2,
            CONVERT_2     = 3'd3,
            ROUND         = 3'd4,
            PACK          = 3'd5,
            OUT_RDY       = 3'd6;

  reg [31:0] a, z, value;
  reg [23:0] z_m;
  reg [7:0] z_r;
  reg [7:0] z_e;
  reg z_s;
  reg guard, round_bit, sticky;

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
                   state <= CONVERT_0;
                 end
               end


          CONVERT_0:
          begin
            if ( a == 0 ) begin
              z_s <= 0;
              z_m <= 0;
              z_e <= -127;
              state <= PACK;
            end else begin
              value <= a[31] ? -a : a;
              z_s <= a[31];
              state <= CONVERT_1;
            end
          end

          CONVERT_1:
          begin
            z_e <= 31;
            z_m <= value[31:8];
            z_r <= value[7:0];
            state <= CONVERT_2;
          end

          CONVERT_2:
          begin
            if (!z_m[23]) begin
              z_e <= z_e - 1;
              z_m <= z_m << 1;
              z_m[0] <= z_r[7];
              z_r <= z_r << 1;
            end else begin
              guard <= z_r[7];
              round_bit <= z_r[6];
              sticky <= z_r[5:0] != 0;
              state <= ROUND;
            end
          end

          ROUND:
          begin
            if (guard && (round_bit || sticky || z_m[0])) begin
              z_m <= z_m + 1;
              if (z_m == 24'hffffff) begin
                z_e <=z_e + 1;
              end
            end
            state <= PACK;
          end

          PACK:
          begin
            z[22 : 0] <= z_m[22:0];
            z[30 : 23] <= z_e + 127;
            z[31] <= z_s;
            state <= OUT_RDY;
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
