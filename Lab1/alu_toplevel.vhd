---------------------------------------------------
-- Original Lab Source Provided by Below
-- Source Modified for Lab by Group 7
---------------------------------------------------
---------------------------------------------------
-- School: University of Massachusetts Dartmouth
-- Department: Computer and Electrical Engineering
-- Engineer: Daniel Noyes
-- 
-- Create Date:    SPRING 2015
-- Module Name:    ALU_Toplevel
-- Project Name:   ALU
-- Target Devices: Spartan-3E
-- Tool versions:  Xilinx ISE 14.7
-- Description: ALU top level
---------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.all;

entity ALU is
    Port ( 
	 
			BTN : in  STD_LOGIC;
			SEG : out STD_LOGIC_VECTOR (7 downto 0);
			DP  : out STD_LOGIC;
			AN  : out STD_LOGIC_VECTOR (3 downto 0);
			SW  : in	STD_LOGIC_VECTOR (7 downto 0);
		  
			CLK      : in  STD_LOGIC;
  --        RA       : in  STD_LOGIC_VECTOR (7 downto 0);
   --       RB       : in  STD_LOGIC_VECTOR (7 downto 0);
         OPCODE   : in  STD_LOGIC_VECTOR (3 downto 0);
     --      CCR      : out STD_LOGIC_VECTOR (3 downto 0);
     --      ALU_OUT  : out STD_LOGIC_VECTOR (7 downto 0);
         LDST_OUT : out STD_LOGIC_VECTOR (7 downto 0)
			  );
end ALU;

architecture Structural of ALU is

      signal INPUT  : STD_LOGIC;
      signal OUTPUT : STD_LOGIC;
		signal PUSH : STD_LOGIC;
		
		signal SEL  : STD_LOGIC;
      signal IN_1 : STD_LOGIC_VECTOR (7 downto 0);
      signal OUT_1 : STD_LOGIC_VECTOR (7 downto 0);
      signal OUT_2 : STD_LOGIC_VECTOR (7 downto 0);

		signal RA			: STD_LOGIC_VECTOR (7 downto 0) := (OTHERS => '0');
		signal RB			: STD_LOGIC_VECTOR (7 downto 0) := (OTHERS => '0');

		signal ALU_OUT		: STD_LOGIC_VECTOR (7 downto 0) := (OTHERS => '0');
		signal CCR			: STD_LOGIC_VECTOR (3 downto 0) := (OTHERS => '0');

		signal arith     : STD_LOGIC_VECTOR (7 downto 0) := (OTHERS => '0');
		signal logic     : STD_LOGIC_VECTOR (7 downto 0) := (OTHERS => '0');
		signal shift     : STD_LOGIC_VECTOR (7 downto 0) := (OTHERS => '0');
		signal memory    : STD_LOGIC_VECTOR (7 downto 0) := (OTHERS => '0');
		signal ccr_arith : STD_LOGIC_VECTOR (3 downto 0) := (OTHERS => '0');
		signal ccr_logic : STD_LOGIC_VECTOR (3 downto 0) := (OTHERS => '0');
	 
		signal s2  : STD_LOGIC_VECTOR (3 downto 0) := "0000";
		signal s3  : STD_LOGIC_VECTOR (3 downto 0) := "0000";
		signal enl : STD_LOGIC := '1';
		signal dpc : STD_LOGIC_VECTOR (3 downto 0) := "1111";
		signal cen : STD_LOGIC := '0';
	
begin

    LDST_OUT <= memory;

    Arith_Unit: entity work.Arith_Unit
    port map(  
				A      => RA,
              B      => RB,
              OP     => OPCODE(2 downto 0),
              CCR    => ccr_arith,
              RESULT => arith
				  );

    Logic_Unit: entity work.Logic_Unit
    port map( 	 
					A      => RA,
              B      => RB,
              OP     => OPCODE(2 downto 0),
              CCR    => ccr_logic,
              RESULT => logic
				  );

    shift_unit: entity work.alu_shift_unit
    port map( 
					A      => RA,
              COUNT  => RB(2 downto 0),
              OP     => opcode(3),
              RESULT => shift
				  );

    Load_Store_Unit: entity work.Load_Store_Unit
    port map( 
					CLK    => CLK,
              A      => RA,
              IMMED  => RB,
              OP     => opcode,
              RESULT => memory
				  );

    ALU_Mux: entity work.ALU_Mux
    port map( 
					OP        => opcode,
              ARITH     => arith,
              LOGIC     => logic,
              SHIFT     => shift,
              MEMORY    => memory,
              CCR_ARITH => ccr_arith,
              CCR_LOGIC => ccr_logic,
              ALU_OUT   => ALU_OUT,
              CCR_OUT   => CCR
				  );
				  
    ALU_7Seg: entity work.SSegDriver
    port map( 
					CLK     => CLK,
              RST     => PUSH,
              EN      => enl,
              SEG_0   => ALU_OUT(3 downto 0),
              SEG_1   => ALU_OUT(7 downto 4),
              SEG_2   => SW(7 downto 4),
              SEG_3   => SW(3 downto 0),
              DP_CTRL => dpc,
              COL_EN  => cen,
              SEG_OUT => SEG (6 downto 0),
              DP_OUT  => DP,
              AN_OUT  => AN
				  );
				  
		ALU_Sel: entity work.sel_1to2
		port map(
				SEL  => PUSH,
           IN_1 => SW(7 downto 0),
           OUT_1 => RA,
           OUT_2 => RB
			);
			
		ALU_Deb: entity work.debounce
		port map(
           INPUT  => BTN,
           OUTPUT => PUSH
			);

end Structural;

