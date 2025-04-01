

--
-- Verific VHDL Description of module Pll27MHz
--

library ieee ;
use ieee.std_logic_1164.all ;

entity Pll27MHz is
    port (Module_Pll27MHz_CLKI: in std_logic;
        Module_Pll27MHz_CLKOP: out std_logic;
        Module_Pll27MHz_CLKOS: out std_logic;
        Module_Pll27MHz_LOCK: out std_logic
    );
    
end entity Pll27MHz; -- sbp_module=true 

architecture Pll27MHz of Pll27MHz is 
    component Module_Pll27MHz is
        port (CLKI: in std_logic;
            CLKOP: out std_logic;
            CLKOS: out std_logic;
            LOCK: out std_logic
        );
        
    end component Module_Pll27MHz; -- not_need_bbox=true 
    
    
    
begin
    Module_Pll27MHz_inst: component Module_Pll27MHz port map (CLKI=>Module_Pll27MHz_CLKI,
            CLKOP=>Module_Pll27MHz_CLKOP,CLKOS=>Module_Pll27MHz_CLKOS,LOCK=>Module_Pll27MHz_LOCK);
    
end architecture Pll27MHz; -- sbp_module=true 

