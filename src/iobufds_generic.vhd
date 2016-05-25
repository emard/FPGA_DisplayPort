----------------------------------------------------------------------------------
-- AUTHOR=EMARD
-- LICENSE=BSD
-- 
-- Create Date:    2016-05-25
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 

-- generic replacement for vendor-specific differential pair
-- bidirectional i/o buffer module IOBUFDS
--
-- useful for low speed DP_AUX ports where
-- vendor-specific differential pair can't be used
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity iobufds_generic is
    Port ( 
         I       : in    STD_LOGIC;
         O       : out   STD_LOGIC;
         IO, IOB : inout STD_LOGIC; -- differential endpoint
         T       : in    STD_LOGIC  -- 3-state control '1'-IO/IOB=input '0'-IO/IOB=output
    );
end iobufds_generic;

architecture Behavioral of iobufds_generic is
begin

  IO  <=     I when T='0' else 'Z';
  IOB <= not I when T='0' else 'Z';
  
  O <= IO; -- simplest, ignores IOB input, might be sufficient
  -- O <= IO and (IO xor IOB); -- '1' only when both pairs are different, else '0'
end Behavioral;
