//**************************************************************
// Module             : up_monitor_wrapper.v
// Platform           : Windows xp sp2
// Simulator          : Modelsim 6.5b
// Synthesizer        : QuartusII 10.1 sp1
// Place and Route    : QuartusII 10.1 sp1
// Targets device     : Cyclone III
// Author             : Bibo Yang  (ash_riple@hotmail.com)
// Organization       : www.opencores.org
// Revision           : 2.0 
// Date               : 2012/03/12
// Description        : Common CPU interface to pipelined access
//                      interface converter.
//**************************************************************

`timescale 1ns/1ns

module up_monitor_wrapper (up_clk,up_wbe,up_csn,up_addr,up_data_io);

// common CPU bus interface
input        up_clk;
input        up_wbe,up_csn;
input [15:2] up_addr;
input [31:0] up_data_io;

// prepare for generating wr_en pulse
reg up_wr_d1, up_wr_d2, up_wr_d3;
always @(posedge up_clk) begin
	up_wr_d1 <= !up_wbe & !up_csn;
	up_wr_d2 <= up_wr_d1;
	up_wr_d3 <= up_wr_d2;
end

// prepare for generating rd_en pulse
reg up_rd_d1, up_rd_d2, up_rd_d3;
always @(posedge up_clk) begin
	up_rd_d1 <= up_wbe & !up_csn;
	up_rd_d2 <= up_rd_d1;
	up_rd_d3 <= up_rd_d2;
end

// map to pipelined access interface
wire        clk     = up_clk;
wire        wr_en   = up_wr_d2 & !up_wr_d3;
wire        rd_en   = up_rd_d2 & !up_rd_d3;
wire [15:2] addr_in = up_addr;
wire [31:0] data_in = up_data_io;

up_monitor inst (
	.clk(clk),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.addr_in(addr_in),
	.data_in(data_in)
);

endmodule
