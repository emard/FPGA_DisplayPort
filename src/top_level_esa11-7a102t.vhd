----------------------------------------------------------------------------------
-- Module Name: top_level - Behavioral
--
-- Description: Top level of my DisplayPort design.
-- 
----------------------------------------------------------------------------------
-- FPGA_DisplayPort from https://github.com/hamsternz/FPGA_DisplayPort
------------------------------------------------------------------------------------
-- The MIT License (MIT)
-- 
-- Copyright (c) 2015 Michael Alan Field <hamster@snap.net.nz>
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
------------------------------------------------------------------------------------
----- Want to say thanks? ----------------------------------------------------------
------------------------------------------------------------------------------------
--
-- This design has taken many hours - 3 months of work. I'm more than happy
-- to share it if you can make use of it. It is released under the MIT license,
-- so you are not under any onus to say thanks, but....
-- 
-- If you what to say thanks for this design either drop me an email, or how about 
-- trying PayPal to my email (hamster@snap.net.nz)?
--
--  Educational use - Enough for a beer
--  Hobbyist use    - Enough for a pizza
--  Research use    - Enough to take the family out to dinner
--  Commercial use  - A weeks pay for an engineer (I wish!)
--------------------------------------------------------------------------------------
--  Ver | Date       | Change
--------+------------+---------------------------------------------------------------
--  0.1 | 2015-09-17 | Initial Version
--  0.2 | 2015-09-29 | Updated for Opsis
------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- only for the IBUFDS
Library UNISIM;
use UNISIM.vcomponents.all;

entity top_level_esa11 is
    port ( 
        --clk100              : in    std_logic;        
        i_100MHz_N, i_100MHz_P: in    std_logic;
        --debug               : out   std_logic_vector(7 downto 0) := (others => '0');
        led: out std_logic_vector(7 downto 0) := (others => '0');
        ------------------------------
        gtptxp          : out   std_logic_vector(1 downto 0);
        gtptxn          : out   std_logic_vector(1 downto 0);    

        refclk0_p       : in  STD_LOGIC;
        refclk0_n       : in  STD_LOGIC;

        refclk1_p       : in  STD_LOGIC;
        refclk1_n       : in  STD_LOGIC;
        ------------------------------
        dp_tx_hp_detect : in    std_logic;
        dp_tx_aux_p : inout std_logic;
        dp_tx_aux_n : inout std_logic;
        dp_rx_aux_p : inout std_logic;
        dp_rx_aux_n : inout std_logic
    );
end top_level_esa11;

architecture Behavioral of top_level_esa11 is
   constant use_hw_8b10b_support : std_logic := '1'; -- Note HW 8b/10b not yet working for SPartan 6

	COMPONENT channel_management
      GENERIC
      (
        C_aux_generic: boolean := false -- true: use GPIO instead of dedicated differential pair for dp_aux_* ports
      );
	  PORT(
		clk100               : IN std_logic;
        debug                : out std_logic_vector(7 downto 0);
		hpd                  : IN std_logic;
		stream_channel_count : IN std_logic_vector(2 downto 0);
		source_channel_count : IN std_logic_vector(2 downto 0);
		tx_clock_train       : out std_logic;
		tx_align_train       : out std_logic;
		tx_running           : IN std_logic_vector(3 downto 0);    
		aux_tx_p             : INOUT std_logic;
		aux_tx_n             : INOUT std_logic;
		aux_rx_p             : INOUT std_logic;
		aux_rx_n             : INOUT std_logic;      
		tx_powerup_channel   : OUT std_logic_vector(3 downto 0);
		tx_preemp_0p0        : OUT std_logic;
		tx_preemp_3p5        : OUT std_logic;
		tx_preemp_6p0        : OUT std_logic;
		tx_swing_0p4         : OUT std_logic;
		tx_swing_0p6         : OUT std_logic;
		tx_swing_0p8         : OUT std_logic;
        tx_link_established  : OUT std_logic
      );
	END COMPONENT;

    component test_source is
        port ( 
            clk          : in  std_logic;
            stream_channel_count : out std_logic_vector(2 downto 0);
            ready        : out std_logic;
            data         : out std_logic_vector(72 downto 0)
        );
    end component;
    
    COMPONENT main_stream_processing
        generic( use_hw_8b10b_support : std_logic);
        PORT(
           symbol_clk          : IN  std_logic;
           tx_link_established : IN  std_logic;
           source_ready        : IN  std_logic;
           tx_clock_train      : IN  std_logic;
           tx_align_train      : IN  std_logic;
           in_data             : IN  std_logic_vector(72 downto 0);          
           tx_symbols          : OUT std_logic_vector(79 downto 0)
        );
    END COMPONENT;

    component Transceiver is
    generic( use_hw_8b10b_support : std_logic);
    Port ( mgmt_clk        : in  STD_LOGIC;
           powerup_channel : in  STD_LOGIC_vector;
           debug           : out std_logic_vector(7 downto 0);

           preemp_0p0      : in  STD_LOGIC;
           preemp_3p5      : in  STD_LOGIC;
           preemp_6p0      : in  STD_LOGIC;
           
           swing_0p4       : in  STD_LOGIC;
           swing_0p6       : in  STD_LOGIC;
           swing_0p8       : in  STD_LOGIC;

           tx_running      : out STD_LOGIC_vector;

           symbolclk      : out STD_LOGIC;
           
           in_symbols     : in  std_logic_vector(79 downto 0);

           refclk0_p       : in  STD_LOGIC;
           refclk0_n       : in  STD_LOGIC;

           refclk1_p       : in  STD_LOGIC;
           refclk1_n       : in  STD_LOGIC;


           gtptxp         : out std_logic_vector(1 downto 0);
           gtptxn         : out std_logic_vector(1 downto 0));
    end component;

    component video_generator is
    Port (  clk              : in  STD_LOGIC;
            h_visible_len    : in  std_logic_vector(11 downto 0) := (others => '0');
            h_blank_len      : in  std_logic_vector(11 downto 0) := (others => '0');
            h_front_len      : in  std_logic_vector(11 downto 0) := (others => '0');
            h_sync_len       : in  std_logic_vector(11 downto 0) := (others => '0');
            
            v_visible_len    : in  std_logic_vector(11 downto 0) := (others => '0');
            v_blank_len      : in  std_logic_vector(11 downto 0) := (others => '0');
            v_front_len      : in  std_logic_vector(11 downto 0) := (others => '0');
            v_sync_len       : in  std_logic_vector(11 downto 0) := (others => '0');
            
            vid_blank        : out STD_LOGIC;
            vid_hsync        : out STD_LOGIC;
            vid_vsync        : out STD_LOGIC);
    end component;
    
    signal clk100: std_logic;
    
    --------------------------------------------------------------------------
    signal tx_powerup       : std_logic := '0';
    signal tx_clock_train   : std_logic := '0';
    signal tx_align_train   : std_logic := '0';    

    ---------------------------------------------
    -- Transceiver signals
    ---------------------------------------------
    signal symbolclk        : std_logic := '0';
    
    signal tx_running       : std_logic_vector(3 downto 0) := (others => '0');
    signal tx_powerup_channel  : std_logic_vector(3 downto 0);
    
    signal tx_preemp_0p0    : std_logic := '1';
    signal tx_preemp_3p5    : STD_LOGIC := '0';
    signal tx_preemp_6p0    : STD_LOGIC := '0';
           
    signal tx_swing_0p4     : STD_LOGIC := '1';
    signal tx_swing_0p6     : STD_LOGIC := '0';
    signal tx_swing_0p8     : STD_LOGIC := '0';

    ------------------------------------------------
    signal tx_link_established : std_logic := '0';
    ------------------------------------------------
    signal tx_debug        : std_logic_vector(7 downto 0);
    signal mgmt_debug:std_logic_vector(7 downto 0);
    signal clk_blinky, refclk0_blinky, refclk1_blinky: unsigned(25 downto 0);
    signal refclk0, refclk1: std_logic;

    constant source_channel_count : std_logic_vector(2 downto 0) := "010";
    signal stream_channel_count : std_logic_vector(2 downto 0) := "000";
    signal test_signal_ready      : std_logic;
    
    signal msa_merged_data     : std_logic_vector(72 downto 0) := (others => '0');  -- With switching point
    signal tx_symbols          : std_logic_vector(79 downto 0) := (others => '0');

    constant BE     : std_logic_vector(8 downto 0) := "111111011";   -- K27.7
    constant BS     : std_logic_vector(8 downto 0) := "110111100";   -- K28.5
    constant SR     : std_logic_vector(8 downto 0) := "100011100";   -- K28.0

begin

i_clk_diff_to_1end: IBUFDS
--generic map (
--   DIFF_TERM => FALSE, -- Differential Termination
--   IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
--   IOSTANDARD => "DEFAULT")
port map (
   I    => i_100MHz_P, -- Diff_p buffer input (connect directly to top-level port)
   IB   => i_100MHz_N, -- Diff_n buffer input (connect directly to top-level port)
   O    => clk100      -- single ended clock output
);

i_channel_management: channel_management
        GENERIC MAP
        (
            C_aux_generic => true -- true: use GPIO instead of dedicated differential pair for dp_aux_* ports
        )
        PORT MAP(
		clk100               => clk100,
        debug                => mgmt_debug,
		hpd                  => dp_tx_hp_detect,
		aux_tx_p             => dp_tx_aux_p,
		aux_tx_n             => dp_tx_aux_n,
		aux_rx_p             => dp_rx_aux_p,
		aux_rx_n             => dp_rx_aux_n,
		stream_channel_count => stream_channel_count,
		source_channel_count => source_channel_count,
		tx_clock_train       => tx_clock_train,
		tx_align_train       => tx_align_train,
		tx_powerup_channel   => tx_powerup_channel,
		tx_preemp_0p0        => tx_preemp_0p0,
		tx_preemp_3p5        => tx_preemp_3p5,
		tx_preemp_6p0        => tx_preemp_6p0,
		tx_swing_0p4         => tx_swing_0p4,
		tx_swing_0p6         => tx_swing_0p6,
		tx_swing_0p8         => tx_swing_0p8,
		tx_running           => tx_running,
      tx_link_established  => tx_link_established
	);

i_test_source: test_source port map (
            clk                  => symbolclk,
            stream_channel_count => stream_channel_count,
            ready                => test_signal_ready,
            data                 => msa_merged_data
        );
    

----------------------------------------------------------------------
Inst_main_stream_processing: main_stream_processing generic map (
      use_hw_8b10b_support => use_hw_8b10b_support
   ) PORT MAP(
		symbol_clk          => symbolclk,
		tx_link_established => tx_link_established,
		source_ready        => test_signal_ready,
		tx_clock_train      => tx_clock_train,
		tx_align_train      => tx_align_train,
		in_data             => msa_merged_data,
		tx_symbols          => tx_symbols
	);

i_tx0: Transceiver generic map (
      use_hw_8b10b_support => use_hw_8b10b_support
   ) Port map ( 
       mgmt_clk        => clk100,
       powerup_channel => tx_powerup_channel,
       tx_running      => tx_running,
       debug           => tx_debug,

       preemp_0p0      => tx_preemp_0p0, 
       preemp_3p5      => tx_preemp_3p5,
       preemp_6p0      => tx_preemp_6p0,
           
       swing_0p4       => tx_swing_0p4,
       swing_0p6       => tx_swing_0p6,
       swing_0p8       => tx_swing_0p8,

       in_symbols      => tx_symbols,
                  
       gtptxp          => gtptxp,
       gtptxn          => gtptxn,
       symbolclk       => symbolclk,       

       refclk0_p       => refclk0_p,
       refclk0_n       => refclk0_n,

       refclk1_p       => refclk1_p,
       refclk1_n       => refclk1_n);


--    debug(0) <= tx_link_established; 
--    debug(0) <= mgmt_debug(0);
--   debug(0) <= tx_clock_train;

    --clock_blinkie
    process(clk100)
    begin
      if rising_edge(clk100) then
        clk_blinky <= clk_blinky + 1;
      end if;
    end process;

    process(tx_debug(0))
    begin
      if rising_edge(tx_debug(0)) then
        refclk0_blinky <= refclk0_blinky + 1;
      end if;
    end process;

    process(tx_debug(1))
    begin
      if rising_edge(tx_debug(1)) then
        refclk1_blinky <= refclk1_blinky + 1;
      end if;
    end process;

    led(0) <= tx_running(0);
    led(1) <= tx_link_established;
    led(2) <= tx_clock_train;
    led(4) <= refclk0_blinky(25);
    led(5) <= refclk1_blinky(25);
    led(7) <= clk_blinky(25);

--process(symbolclk)
--   begin
--   
--      -- SHow the HBLANK as a debug of the video stream.
--      if rising_edge(symbolclk) then
--         -- Look for BS symbols
--         if sr_inserted_data(8 downto 0) = "110111100" or sr_inserted_data(17 downto 9) = "110111100" then
--            debug(0) <= toggle and tx_link_established; --'1';
--            toggle <= not toggle;
--         end if;
--         -- Look for BE symbols
--         if sr_inserted_data(8 downto 0) = "111111011" or sr_inserted_data(17 downto 9) = "111111011" then
--            debug(0) <= toggle and tx_link_established; --'0';
--            toggle <= not toggle;
--         end if;
--      end if;
--   end process;
--process(gclk)
--   begin
--      if rising_edge(gclk) then
--         count <= count + 1;
--         case count(10 downto 8) is
--            when "000"  => debug(0) <= not count(7);
--            when "001"  => debug(0) <= tx_debug(0);
--            when "010"  => debug(0) <= tx_debug(1);
--            when "011"  => debug(0) <= tx_debug(2);
--            when "100"  => debug(0) <= tx_debug(3);
--            when "101"  => debug(0) <= tx_debug(4);
--            when "110"  => debug(0) <= tx_debug(5);
--            when others => debug(0) <= tx_debug(6);
--         end case;
--      end if;
--   end process;
end Behavioral;
