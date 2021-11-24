--VHDL instantiation template

component Pll27MHz is
    port (Module_Pll27MHz_CLKI: in std_logic;
        Module_Pll27MHz_CLKOP: out std_logic;
        Module_Pll27MHz_CLKOS: out std_logic;
        Module_Pll27MHz_LOCK: out std_logic
    );
    
end component Pll27MHz; -- sbp_module=true 
_inst: Pll27MHz port map (Module_Pll27MHz_CLKI => __,Module_Pll27MHz_CLKOP => __,
            Module_Pll27MHz_CLKOS => __,Module_Pll27MHz_LOCK => __);
