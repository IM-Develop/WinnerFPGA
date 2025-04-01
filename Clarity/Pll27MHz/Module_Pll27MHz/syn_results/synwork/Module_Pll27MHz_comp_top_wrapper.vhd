--
-- Synopsys
-- Vhdl wrapper for top level design, written on Tue Apr  1 09:49:46 2025
--
library ieee;
use ieee.std_logic_1164.all;
library ecp5um;
use ecp5um.components.all;

entity wrapper_for_Module_Pll27MHz is
   port (
      CLKI : in std_logic;
      CLKOP : out std_logic;
      CLKOS : out std_logic;
      LOCK : out std_logic
   );
end wrapper_for_Module_Pll27MHz;

architecture structure of wrapper_for_Module_Pll27MHz is

component Module_Pll27MHz
 port (
   CLKI : in std_logic;
   CLKOP : out std_logic;
   CLKOS : out std_logic;
   LOCK : out std_logic
 );
end component;

signal tmp_CLKI : std_logic;
signal tmp_CLKOP : std_logic;
signal tmp_CLKOS : std_logic;
signal tmp_LOCK : std_logic;

begin

tmp_CLKI <= CLKI;

CLKOP <= tmp_CLKOP;

CLKOS <= tmp_CLKOS;

LOCK <= tmp_LOCK;



u1:   Module_Pll27MHz port map (
		CLKI => tmp_CLKI,
		CLKOP => tmp_CLKOP,
		CLKOS => tmp_CLKOS,
		LOCK => tmp_LOCK
       );
end structure;
