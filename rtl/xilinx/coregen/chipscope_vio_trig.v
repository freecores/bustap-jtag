///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2012 Xilinx, Inc.
// All Rights Reserved
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor     : Xilinx
// \   \   \/     Version    : 14.2
//  \   \         Application: Xilinx CORE Generator
//  /   /         Filename   : chipscope_vio_trig.v
// /___/   /\     Timestamp  : Tue Nov 20 10:37:58 中国标准时间 2012
// \   \  /  \
//  \___\/\___\
//
// Design Name: Verilog Synthesis Wrapper
///////////////////////////////////////////////////////////////////////////////
// This wrapper is used to integrate with Project Navigator and PlanAhead

`timescale 1ns/1ps

module chipscope_vio_trig(
    CONTROL,
    CLK,
    SYNC_OUT);


inout [35 : 0] CONTROL;
input CLK;
output [65 : 0] SYNC_OUT;

endmodule
