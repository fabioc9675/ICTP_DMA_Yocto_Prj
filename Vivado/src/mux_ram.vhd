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
entity mux_ram is
    Port ( 
            sel       : in  std_logic_vector(1 downto 0); -- Selector de forma de onda
            signal_1  : in  std_logic_vector(15 downto 0); -- Entrada de onda 1
            signal_2  : in  std_logic_vector(15 downto 0); -- Entrada de onda 2
            pos_1     : in  std_logic; -- Entrada de onda 3 
            pos_2     : in  std_logic; -- Entrada de onda 3 
            signal_o  : out std_logic_vector(15 downto 0); -- Entrada de onda 3 
            pos_o     : out STD_LOGIC
         );     
end mux_ram;

architecture Behavioral of mux_ram is
    signal wave_value : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal pos_value  : STD_LOGIC := '0';

begin   
    process(sel, signal_1, signal_2, pos_1, pos_2)
    begin
        case sel is
            when "01" =>
                wave_value <= signal_1; -- Onda 1
                pos_value  <= pos_1;
            when "10" =>
                wave_value <= signal_2; -- Onda 2
                pos_value  <= pos_2;
            when others =>
                wave_value <= (others => '0'); -- Default a 0
                pos_value  <= '0';
        end case;
    end process;

    -- salida
    signal_o <= wave_value;
    pos_o    <= pos_value;

end Behavioral;