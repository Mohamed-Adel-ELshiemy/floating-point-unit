// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Thu Dec 23 00:14:23 2025
// Host        : DESKTOP-018HARF running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {d:/MSD Full Semester/MSD620 ASIC and FPGA Design Course/Final
//               Project/Single Precision Floating Point Unit/Single Precision Floating Point
//               Unit.srcs/sources_1/ip/vio_0/vio_0_stub.v}
// Design      : vio_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "vio,Vivado 2020.2" *)
module vio_0(clk, probe_in0, probe_in1, probe_out0, 
  probe_out1, probe_out2, probe_out3, probe_out4)
/* synthesis syn_black_box black_box_pad_pin="clk,probe_in0[31:0],probe_in1[0:0],probe_out0[0:0],probe_out1[3:0],probe_out2[31:0],probe_out3[31:0],probe_out4[0:0]" */;
  input clk;
  input [31:0]probe_in0;
  input [0:0]probe_in1;
  output [0:0]probe_out0;
  output [3:0]probe_out1;
  output [31:0]probe_out2;
  output [31:0]probe_out3;
  output [0:0]probe_out4;
endmodule
