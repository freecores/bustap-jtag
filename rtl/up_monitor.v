//**************************************************************
// Module             : up_monitor.v
// Platform           : Windows xp sp2
// Simulator          : Modelsim 6.5b
// Synthesizer        : QuartusII 10.1 sp1
// Place and Route    : QuartusII 10.1 sp1
// Targets device     : Cyclone III
// Author             : Bibo Yang  (ash_riple@hotmail.com)
// Organization       : www.opencores.org
// Revision           : 2.0 
// Date               : 2012/03/12
// Description        : Top level glue logic to group together 
//                      the JTAG input and output modules.
//**************************************************************

`timescale 1ns/1ns

module up_monitor (
	input        clk,
	input        wr_en,rd_en,
	input [15:2] addr_in,
	input [31:0] data_in
);

reg        wr_en_d1,rd_en_d1;
reg [15:2] addr_in_d1;
reg [31:0] data_in_d1;

wire [31:0] addr_mask0,addr_mask1,addr_mask2,addr_mask3,addr_mask4,addr_mask5,addr_mask6,addr_mask7,
            addr_mask8,addr_mask9,addr_mask10,addr_mask11,addr_mask12,addr_mask13,addr_mask14,addr_mask15;
reg         addr_mask_ok;

wire [49:0] trig_cond;
wire        trig_en   = trig_cond[49];
wire        trig_set  = trig_cond[48];
wire [15:0] trig_addr = trig_cond[47:32];
wire [31:0] trig_data = trig_cond[31:0];
reg         trig_cond_ok;

wire [47:0] capture_in;
wire        capture_wr;

// bus input pipeline, allowing back-to-back/continuous bus access
always @(posedge clk)
begin
	wr_en_d1   <= wr_en;
	rd_en_d1   <= rd_en;
	addr_in_d1 <= addr_in;
	data_in_d1 <= data_in;
end

// address range based capture enable
always @(posedge clk)
begin
	if (((addr_in[15:2]<=addr_mask0[31:18] && addr_in[15:2]>=addr_mask0[15:2]) ||
	     (addr_in[15:2]<=addr_mask1[31:18] && addr_in[15:2]>=addr_mask1[15:2]) ||
	     (addr_in[15:2]<=addr_mask2[31:18] && addr_in[15:2]>=addr_mask2[15:2]) ||
	     (addr_in[15:2]<=addr_mask3[31:18] && addr_in[15:2]>=addr_mask3[15:2]) ||
	     (addr_in[15:2]<=addr_mask4[31:18] && addr_in[15:2]>=addr_mask4[15:2]) ||
	     (addr_in[15:2]<=addr_mask5[31:18] && addr_in[15:2]>=addr_mask5[15:2]) ||
	     (addr_in[15:2]<=addr_mask6[31:18] && addr_in[15:2]>=addr_mask6[15:2]) ||
	     (addr_in[15:2]<=addr_mask7[31:18] && addr_in[15:2]>=addr_mask7[15:2])
	    ) //inclusive address range set: addr_mask 0 - 7
	    &&
	    ((addr_in[15:2]>addr_mask8 [31:18] || addr_in[15:2]<addr_mask8 [15:2]) &&
	     (addr_in[15:2]>addr_mask9 [31:18] || addr_in[15:2]<addr_mask9 [15:2]) &&
	     (addr_in[15:2]>addr_mask10[31:18] || addr_in[15:2]<addr_mask10[15:2]) &&
	     (addr_in[15:2]>addr_mask11[31:18] || addr_in[15:2]<addr_mask11[15:2]) &&
	     (addr_in[15:2]>addr_mask12[31:18] || addr_in[15:2]<addr_mask12[15:2]) &&
	     (addr_in[15:2]>addr_mask13[31:18] || addr_in[15:2]<addr_mask13[15:2]) &&
	     (addr_in[15:2]>addr_mask14[31:18] || addr_in[15:2]<addr_mask14[15:2]) &&
	     (addr_in[15:2]>addr_mask15[31:18] || addr_in[15:2]<addr_mask15[15:2])
	    ) //exclusive address range set: addr_mask 8 - 15
	)
		addr_mask_ok <= wr_en;
	else
		addr_mask_ok <= 0;
end

// address-data based capture trigger
always @(posedge clk)
begin
	if (trig_en==0)                       // trigger not enabled, trigger gate forced open
		trig_cond_ok <= 1;
	else if (trig_set==0)                 // trigger enabled and trigger stopped, trigger gate forced close
		trig_cond_ok <= 0;
	else                                  // trigger enabled and trigger started, trigger gate conditional open
		if (trig_addr[15:2]==addr_in[15:2] && trig_data==data_in)
			trig_cond_ok <= wr_en;// trigger gate kept open until trigger stoped
end

// generate capture wr-in
assign capture_in = {addr_in_d1[15:2],2'b0,data_in_d1[31:0]};
assign capture_wr = wr_en_d1 && addr_mask_ok && trig_cond_ok;

// instantiate capture mask, as input
virtual_jtag_addr_mask u_virtual_jtag_addr_mask (
	.mask_out0(addr_mask0),
	.mask_out1(addr_mask1),
	.mask_out2(addr_mask2),
	.mask_out3(addr_mask3),
	.mask_out4(addr_mask4),
	.mask_out5(addr_mask5),
	.mask_out6(addr_mask6),
	.mask_out7(addr_mask7),
	.mask_out8(addr_mask8),
	.mask_out9(addr_mask9),
	.mask_out10(addr_mask10),
	.mask_out11(addr_mask11),
	.mask_out12(addr_mask12),
	.mask_out13(addr_mask13),
	.mask_out14(addr_mask14),
	.mask_out15(addr_mask15)
	);
defparam
	u_virtual_jtag_addr_mask.addr_width	= 32,
	u_virtual_jtag_addr_mask.mask_index	= 4,
	u_virtual_jtag_addr_mask.mask_num	= 16;

// instantiate capture trigger, as input
virtual_jtag_adda_trig u_virtual_jtag_adda_trig (
	.trig_out(trig_cond)
	);
defparam
	u_virtual_jtag_adda_trig.trig_width	= 50;

// instantiate capture fifo, as output
virtual_jtag_adda_fifo u_virtual_jtag_adda_fifo (
	.clk(clk),
	.wr_en(capture_wr),
	.data_in(capture_in)
	);
defparam
	u_virtual_jtag_adda_fifo.data_width	= 48,
	u_virtual_jtag_adda_fifo.fifo_depth	= 512,
	u_virtual_jtag_adda_fifo.addr_width	= 9,
	u_virtual_jtag_adda_fifo.al_full_val	= 511,
	u_virtual_jtag_adda_fifo.al_empt_val	= 0;

endmodule
