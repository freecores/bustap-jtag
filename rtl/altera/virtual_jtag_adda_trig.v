module virtual_jtag_adda_trig(trig_out);

parameter trig_width  = 32;

output [trig_width-1:0] trig_out;

reg [trig_width-1:0] trig_out;

wire tdi, tck, cdr, cir, e1dr, e2dr, pdr, sdr, udr, uir;
reg  tdo;
reg  [trig_width-1:0] trig_instr_reg;
reg  bypass_reg;

wire [1:0] ir_in;
wire trig_instr = ~ir_in[1] &  ir_in[0]; // 1

always @(posedge tck)
begin
  if (trig_instr && e1dr)
    trig_out <= trig_instr_reg;
end

/* trig_instr Instruction Handler */		
always @ (posedge tck)
  if ( trig_instr && cdr )
    trig_instr_reg <= trig_instr_reg;
  else if ( trig_instr && sdr )
    trig_instr_reg <= {tdi, trig_instr_reg[trig_width-1:1]};

/* Bypass register */
always @ (posedge tck)
  bypass_reg <= tdi;

/* Node TDO Output */
always @ ( trig_instr, trig_instr_reg, bypass_reg )
begin
  if (trig_instr)
    tdo <= trig_instr_reg[0];
  else
    tdo <= bypass_reg;// Used to maintain the continuity of the scan chain.
end

sld_virtual_jtag	sld_virtual_jtag_component (
				.ir_in (ir_in),
				.ir_out (2'b0),
				.tdo (tdo),
				.tdi (tdi),
				.tms (),
				.tck (tck),
				.virtual_state_cir (cir),
				.virtual_state_pdr (pdr),
				.virtual_state_uir (uir),
				.virtual_state_sdr (sdr),
				.virtual_state_cdr (cdr),
				.virtual_state_udr (udr),
				.virtual_state_e1dr (e1dr),
				.virtual_state_e2dr (e2dr),
				.jtag_state_rti (),
				.jtag_state_e1dr (),
				.jtag_state_e2dr (),
				.jtag_state_pir (),
				.jtag_state_tlr (),
				.jtag_state_sir (),
				.jtag_state_cir (),
				.jtag_state_uir (),
				.jtag_state_pdr (),
				.jtag_state_sdrs (),
				.jtag_state_sdr (),
				.jtag_state_cdr (),
				.jtag_state_udr (),
				.jtag_state_sirs (),
				.jtag_state_e1ir (),
				.jtag_state_e2ir ());
	defparam
		sld_virtual_jtag_component.sld_auto_instance_index = "NO",
		sld_virtual_jtag_component.sld_instance_index = 2,
		sld_virtual_jtag_component.sld_ir_width = 2,
		sld_virtual_jtag_component.sld_sim_action = "((1,1,1,2))",
		sld_virtual_jtag_component.sld_sim_n_scan = 1,
		sld_virtual_jtag_component.sld_sim_total_length = 2;
		
endmodule
