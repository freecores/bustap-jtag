library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity up_monitor is
port (
	up_clk		: in std_logic;
	up_wbe		: in std_logic;
	up_csn		: in std_logic;
	up_addr		: in std_logic_vector(15 downto 2);
	up_data_io		: in std_logic_vector(31 downto 0)
);
end up_monitor;

architecture synth of up_monitor is

component virtual_jtag_adda_fifo is
	generic(
		data_width	: integer;
		fifo_depth	: integer;
		addr_width	: integer;
		al_full_val	: integer;
		al_empt_val	: integer
	);
	port(
		clk		: in std_logic;
		wr_en	: in std_logic;
		data_in	: in std_logic_vector(data_width-1 downto 0)
	);
end component virtual_jtag_adda_fifo;

signal up_csn_d1, up_csn_d2, up_csn_d3, up_csn_d4	: std_logic;
signal up_csn_neg_pulse		: std_logic;
signal up_bus_content		: std_logic_vector(47 downto 0);

type addr_array is array (15 downto 0) of std_logic_vector (31 downto 0);

component virtual_jtag_addr_mask is
	generic(
		addr_width	: integer;
		mask_index	: integer;
		mask_num	: integer
	);
	port(
		mask_out0	: out std_logic_vector (31 downto 0);
		mask_out1	: out std_logic_vector (31 downto 0);
		mask_out2	: out std_logic_vector (31 downto 0);
		mask_out3	: out std_logic_vector (31 downto 0);
		mask_out4	: out std_logic_vector (31 downto 0);
		mask_out5	: out std_logic_vector (31 downto 0);
		mask_out6	: out std_logic_vector (31 downto 0);
		mask_out7	: out std_logic_vector (31 downto 0);
		mask_out8	: out std_logic_vector (31 downto 0);
		mask_out9	: out std_logic_vector (31 downto 0);
		mask_out10	: out std_logic_vector (31 downto 0);
		mask_out11	: out std_logic_vector (31 downto 0);
		mask_out12	: out std_logic_vector (31 downto 0);
		mask_out13	: out std_logic_vector (31 downto 0);
		mask_out14	: out std_logic_vector (31 downto 0);
		mask_out15	: out std_logic_vector (31 downto 0)
	);
end component virtual_jtag_addr_mask;

signal addr_mask : addr_array;
signal addr_mask_ok : std_logic;

component virtual_jtag_adda_trig is
	generic(
		trig_width	: integer
	);
	port(
		trig_out	: out std_logic_vector(trig_width-1 downto 0)
	);
end component virtual_jtag_adda_trig;

signal trig_condition	: std_logic_vector(49 downto 0);
alias  trig_en		: std_logic is trig_condition(49);
alias  trig_set		: std_logic is trig_condition(48);
alias  trig_addr	: std_logic_vector(15 downto 0) is trig_condition(47 downto 32);
alias  trig_data	: std_logic_vector(31 downto 0) is trig_condition(31 downto 0);
signal trig_condition_ok : std_logic;

begin

process (up_clk)
begin
	if (up_clk'event and up_clk='1') then
		up_csn_d1 <= up_csn or up_wbe;
		up_csn_d2 <= up_csn_d1;
		up_csn_d3 <= up_csn_d2;
		up_csn_d4 <= up_csn_d3;
	end if;
end process;


process (up_clk)
begin
	if (up_clk'event and up_clk='1') then
		if ((	(up_addr(15 downto 2)<=addr_mask(0)(31 downto 18) and up_addr(15 downto 2)>=addr_mask(0)(15 downto 2)) or
			(up_addr(15 downto 2)<=addr_mask(1)(31 downto 18) and up_addr(15 downto 2)>=addr_mask(1)(15 downto 2)) or
			(up_addr(15 downto 2)<=addr_mask(2)(31 downto 18) and up_addr(15 downto 2)>=addr_mask(2)(15 downto 2)) or
			(up_addr(15 downto 2)<=addr_mask(3)(31 downto 18) and up_addr(15 downto 2)>=addr_mask(3)(15 downto 2)) or
			(up_addr(15 downto 2)<=addr_mask(4)(31 downto 18) and up_addr(15 downto 2)>=addr_mask(4)(15 downto 2)) or
			(up_addr(15 downto 2)<=addr_mask(5)(31 downto 18) and up_addr(15 downto 2)>=addr_mask(5)(15 downto 2)) or
			(up_addr(15 downto 2)<=addr_mask(6)(31 downto 18) and up_addr(15 downto 2)>=addr_mask(6)(15 downto 2)) or
			(up_addr(15 downto 2)<=addr_mask(7)(31 downto 18) and up_addr(15 downto 2)>=addr_mask(7)(15 downto 2))
		    ) --inclusive address set
		    and
		    (	(up_addr(15 downto 2)>addr_mask(8) (31 downto 18) or up_addr(15 downto 2)<addr_mask(8) (15 downto 2)) and
			(up_addr(15 downto 2)>addr_mask(9) (31 downto 18) or up_addr(15 downto 2)<addr_mask(9) (15 downto 2)) and
			(up_addr(15 downto 2)>addr_mask(10)(31 downto 18) or up_addr(15 downto 2)<addr_mask(10)(15 downto 2)) and
			(up_addr(15 downto 2)>addr_mask(11)(31 downto 18) or up_addr(15 downto 2)<addr_mask(11)(15 downto 2)) and
			(up_addr(15 downto 2)>addr_mask(12)(31 downto 18) or up_addr(15 downto 2)<addr_mask(12)(15 downto 2)) and
			(up_addr(15 downto 2)>addr_mask(13)(31 downto 18) or up_addr(15 downto 2)<addr_mask(13)(15 downto 2)) and
			(up_addr(15 downto 2)>addr_mask(14)(31 downto 18) or up_addr(15 downto 2)<addr_mask(14)(15 downto 2)) and
			(up_addr(15 downto 2)>addr_mask(15)(31 downto 18) or up_addr(15 downto 2)<addr_mask(15)(15 downto 2))
	    	    ) --exclusive address set
	    	   ) then
			addr_mask_ok <= '1';
		else
			addr_mask_ok <= '0';
		end if;
	end if;
end process;

process (up_clk)
begin
	if (up_clk'event and up_clk='1') then
		if (trig_en='0') then
			trig_condition_ok <= '1';
		elsif (trig_set='0') then
			trig_condition_ok <= '0';
		elsif (up_csn_d1='0' and up_csn_d2='1') then
			if (trig_addr(15 downto 2)=up_addr(15 downto 2) and trig_data=up_data_io) then
				trig_condition_ok <= '1';
			end if;
		end if;
	end if;
end process;

up_csn_neg_pulse <= (not up_csn_d3) and up_csn_d4 and addr_mask_ok and trig_condition_ok;
up_bus_content <= up_addr(15 downto 2) & "00" & up_data_io(31 downto 0);

u_virtual_jtag_adda_fifo : virtual_jtag_adda_fifo
generic map
	(
	data_width	=> 48,
	fifo_depth	=> 512,
	addr_width	=> 9,
	al_full_val	=> 511,
	al_empt_val	=> 0
	)
port map
	(
	clk		=> up_clk,
	wr_en	=> up_csn_neg_pulse,
	data_in	=> up_bus_content
	);

u_virtual_jtag_addr_mask : virtual_jtag_addr_mask
generic map
	(
	addr_width	=> 32,
	mask_index	=> 4,
	mask_num	=> 16
	)
port map
	(
	mask_out0	=> addr_mask(0),
	mask_out1	=> addr_mask(1),
	mask_out2	=> addr_mask(2),
	mask_out3	=> addr_mask(3),
	mask_out4	=> addr_mask(4),
	mask_out5	=> addr_mask(5),
	mask_out6	=> addr_mask(6),
	mask_out7	=> addr_mask(7),
	mask_out8	=> addr_mask(8),
	mask_out9	=> addr_mask(9),
	mask_out10	=> addr_mask(10),
	mask_out11	=> addr_mask(11),
	mask_out12	=> addr_mask(12),
	mask_out13	=> addr_mask(13),
	mask_out14	=> addr_mask(14),
	mask_out15	=> addr_mask(15)
	);

u_virtual_jtag_adda_trig : virtual_jtag_adda_trig
generic map
	(
	trig_width	=> 50
	)
port map
	(
	trig_out	=> trig_condition
	);

end synth;
