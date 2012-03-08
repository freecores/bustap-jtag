
module up_monitor (up_clk,up_wbe,up_csn,up_addr,up_data_io);

input up_clk,up_wbe,up_csn;
input [15:2] up_addr;
input [31:0] up_data_io;

reg up_csn_d1, up_csn_d2, up_csn_d3, up_csn_d4;
wire up_csn_neg_pulse;
wire [47:0] up_bus_content;

wire [49:0] trig_condition;
wire 		trig_en 	= trig_condition[49];
wire 		trig_set 	= trig_condition[48];
wire [15:0] trig_addr 	= trig_condition[47:32];
wire [31:0] trig_data 	= trig_condition[31:0];
reg trig_condition_ok;

wire [31:0]	addr_mask0,addr_mask1,addr_mask2,addr_mask3,addr_mask4,addr_mask5,addr_mask6,addr_mask7,
			addr_mask8,addr_mask9,addr_mask10,addr_mask11,addr_mask12,addr_mask13,addr_mask14,addr_mask15;
reg addr_mask_ok;

always @(posedge up_clk)
begin
	up_csn_d1 <= up_csn || up_wbe;
	up_csn_d2 <= up_csn_d1;
	up_csn_d3 <= up_csn_d2;
	up_csn_d4 <= up_csn_d3;
end

always @(posedge up_clk)
begin
	if ((	(up_addr[15:2]<=addr_mask0[31:18] && up_addr[15:2]>=addr_mask0[15:2]) ||
			(up_addr[15:2]<=addr_mask1[31:18] && up_addr[15:2]>=addr_mask1[15:2]) ||
			(up_addr[15:2]<=addr_mask2[31:18] && up_addr[15:2]>=addr_mask2[15:2]) ||
			(up_addr[15:2]<=addr_mask3[31:18] && up_addr[15:2]>=addr_mask3[15:2]) ||
			(up_addr[15:2]<=addr_mask4[31:18] && up_addr[15:2]>=addr_mask4[15:2]) ||
			(up_addr[15:2]<=addr_mask5[31:18] && up_addr[15:2]>=addr_mask5[15:2]) ||
			(up_addr[15:2]<=addr_mask6[31:18] && up_addr[15:2]>=addr_mask6[15:2]) ||
			(up_addr[15:2]<=addr_mask7[31:18] && up_addr[15:2]>=addr_mask7[15:2])
		) //inclusive address set
		&&
		(	(up_addr[15:2]>addr_mask8 [31:18] || up_addr[15:2]<addr_mask8 [15:2]) &&
			(up_addr[15:2]>addr_mask9 [31:18] || up_addr[15:2]<addr_mask9 [15:2]) &&
			(up_addr[15:2]>addr_mask10[31:18] || up_addr[15:2]<addr_mask10[15:2]) &&
			(up_addr[15:2]>addr_mask11[31:18] || up_addr[15:2]<addr_mask11[15:2]) &&
			(up_addr[15:2]>addr_mask12[31:18] || up_addr[15:2]<addr_mask12[15:2]) &&
			(up_addr[15:2]>addr_mask13[31:18] || up_addr[15:2]<addr_mask13[15:2]) &&
			(up_addr[15:2]>addr_mask14[31:18] || up_addr[15:2]<addr_mask14[15:2]) &&
			(up_addr[15:2]>addr_mask15[31:18] || up_addr[15:2]<addr_mask15[15:2])
	    ) //exclusive address set
	)
			addr_mask_ok <= 1;
		else
			addr_mask_ok <= 0;
end

always @(posedge up_clk)
begin
	if (trig_en==0)
		trig_condition_ok <= 1;
	else if (trig_set==0)
		trig_condition_ok <= 0;
	else if (up_csn_d1==0 && up_csn_d2==1)
		if (trig_addr[15:2]==up_addr[15:2] && trig_data==up_data_io)
			trig_condition_ok <= 1;
end

assign up_csn_neg_pulse = !up_csn_d3 && up_csn_d4 && addr_mask_ok && trig_condition_ok;
assign up_bus_content 	= {up_addr[15:2],2'b0,up_data_io[31:0]};

virtual_jtag_adda_fifo u_virtual_jtag_adda_fifo (
	.clk(up_clk),
	.wr_en(up_csn_neg_pulse),
	.data_in(up_bus_content)
	);
defparam
	u_virtual_jtag_adda_fifo.data_width	= 48,
	u_virtual_jtag_adda_fifo.fifo_depth	= 512,
	u_virtual_jtag_adda_fifo.addr_width	= 9,
	u_virtual_jtag_adda_fifo.al_full_val	= 511,
	u_virtual_jtag_adda_fifo.al_empt_val	= 0;

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

virtual_jtag_adda_trig u_virtual_jtag_adda_trig (
	.trig_out(trig_condition)
	);
defparam
	u_virtual_jtag_adda_trig.trig_width	= 50;

endmodule
