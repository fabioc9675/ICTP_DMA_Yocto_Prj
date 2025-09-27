----------------------------------------------------------------------------------
-- Company: ICTP
-- Engineer: Fabian Castaño
-- 
-- Create Date: 21.09.2025 00:27:13
-- Modificado: 25.09.2025
-- Generador de onda Diente de Sierra
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Entidad principal
entity sawtooth_wave_gen is
    Port ( 
            clk       : in  STD_LOGIC;
            rst       : in  STD_LOGIC;
            saw_out   : out STD_LOGIC_VECTOR (15 downto 0)
         );
end sawtooth_wave_gen;

architecture Behavioral of sawtooth_wave_gen is

    signal saw_value : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

begin

    process(clk, rst)
    begin
        if rst = '1' then
            saw_value <= (others => '0');
        elsif rising_edge(clk) then
            -- Incremento lineal
            saw_value <= saw_value + 256; 
        end if;
    end process;

    -- salida
    saw_out <= saw_value;

end Behavioral;