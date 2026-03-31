`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2025 11:40:51 AM
// Design Name: 
// Module Name: PFU_SP_tb
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


module PFU_SP_tb();

reg          clk   ;
reg          rst_n ;
reg [3:0]    cmd   ;
reg [31:0]   din1  ;
reg [31:0]   din2  ;
reg          dval  ;
wire [31:0]  result;
wire         rdy   ;

initial 
begin
    clk   = 1'b1   ;
    rst_n = 1'b0   ;
    cmd   = 4'b0000;
    din1  = 32'h00000000    ;
    din2  = 32'h00000000    ;
    dval  = 1'b0   ;
    #10
    rst_n = 1'b1   ;
    dval  = 1'b1   ;
    #20
    cmd   = 4'b0001;
    din1  = 32'hbe800000/*0.25   */;
    din2  = 32'h3f000000/*0.5    */;
    dval  = 1'b1   ;
    $display("Addition of: din1 = %f, din2 = %f, The result is %f", din1, din2, /*$bitstoreal*/(result));
    #180
    cmd   = 4'b0010;
    dval  = 1'b1   ;
    $display("Multiplication of: din1 = %f, din2 = %f, The result is %f", din1, din2, /*$bitstoreal*/(result));
    #180
    cmd   = 4'b0011;
    dval  = 1'b1   ;
    $display("Division of: din1 = %f, din2 = %f, The result is %f", din1, din2, /*$bitstoreal*/(result));
//    #180
//    cmd   = 4'b0100;
//    dval  = 1'b1   ;
//    $display("Float to Integer of: din1 = %f, din2 = %f, The result is %f", din1, din2, /*$bitstoreal*/(result));
    #120
    cmd   = 4'b0101;
    dval  = 1'b1   ;
    $display("Integer to Float of: din1 = %f, din2 = %f, The result is %f", din1, din2, /*$bitstoreal*/(result));
//    #100
//    din1  = 32'h40700000/*3.75   */;
//    din2  = 32'hc0700000/*-3.75    */;   
    #120
    $stop;
end

fpu_sp_top fpu_sp_top_uut(
                        .clk(clk),
                        .rst_n(rst_n),
                        .cmd(cmd),
                        .din1(/*$realtobits*/(din1)),
                        .din2(/*$realtobits*/(din2)),
                        .dval(dval),
                        .result(result),
                        .rdy(rdy)
                       );

always #5 clk = !clk;

endmodule
