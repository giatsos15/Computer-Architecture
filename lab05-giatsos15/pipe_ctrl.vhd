library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipe_ctrl is
	port(
		rs            : in  std_logic_vector(4 downto 0);
		rt            : in  std_logic_vector(4 downto 0);
		isStore       : in  std_logic;
		isNop         : in  std_logic;
		readsRs       : in  std_logic;
		readsRt       : in  std_logic;
		-- From Stage Ex  --
		ex_rd         : in  std_logic_vector(4 downto 0);
		ex_regWrite   : in  std_logic;
		ex_isLoad     : in  std_logic;
		ex_brTaken    : in  std_logic;
		-- From Stage Mem --
		mem_rd        : in  std_logic_vector(4 downto 0);
		mem_regWrite  : in  std_logic;
		--  For Stage IF  --
		flush         : out std_logic;
		flowChange    : out std_logic;
		stall         : out std_logic;
		--  For Stage ID  --
		id_forwardA   : out std_logic_vector(1 downto 0) := "00"; -- Select Register from Register File.
		id_forwardB   : out std_logic_vector(1 downto 0) := "00"; -- Select Register from Register File.
		id_ldstBypass : out std_logic := '0'
	);
end entity pipe_ctrl;

architecture RTL of pipe_ctrl is
	signal ofStall : std_logic;
	constant empty : std_logic_vector(4 downto 0) := (others => '0');
begin
	stall         <= ofStall;
	flush         <= ex_brTaken;
	flowChange    <= ex_brTaken;
	id_forwardA <= "00";
	if ((ex_regWrite = '1' and rs = ex_rd) or (mem_regWrite = '1' and rs = mem_rd))
	 id_forwardA = "10";
	if ((wb_regWrite = "1" and wb_rd /= "0") or (mem_regWrite = "1" and mem_rd /= "0") and (ex_rd /= ex_rs or mem_rd /= rs) and (wb_rd = ex_rs or mem_rd = rs))
	 id_forwardA = "01";
	id_forwardB <= "00";
	if ((ex_regWrite = '1' and rt = ex_rd) or (mem_regWrite = '1' and rt = mem_rd))
	  id_forwardB = "10";
	if ((wb_regWrite = "1" and wb_rd /= "0") or (mem_regWrite = "1" and mem_rd /= "0") and (ex_rd /= ex_rt or mem_rd /= rt) and (wb_rd = ex_rt or mem_rd = rt))
	 id_forwardB = "01";
	id_ldstBypass <= '0';

	stalling : process(rs, rt, isStore, isNop, readsRs, readsRt, ex_rd, ex_regWrite, ex_isLoad, mem_rd, mem_regWrite)
	begin
		ofStall <= '0'; 
		if (ex_regWrite = '1' and rs = ex_rd) then
		  id_ldstBypass = ex_rs;
		  ofStall <= '1';
		if (mem_regWrite = '1' and rs = mem_rd) then
		  id_ldstBypass = mem_rs;
			ofStall <= '1';
		end if;
		-- Stalls for Data Dependence on Rt:
		if (ex_regWrite = '1' and rt = ex_rd) then
		  id_ldstBypass = ex_rt;
		  ofStall <= '1';
		if (mem_regWrite = '1' and rt = mem_rd) then
		  id_ldstBypass = mem_rs;
			ofStall <= '1';
		end if;
	end process stalling;
end architecture RTL;
