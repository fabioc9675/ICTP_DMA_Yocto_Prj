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
entity multiplex is
    Port ( 
            sel       : in  std_logic_vector(3 downto 0); -- Selector de forma de onda
            wave_in_1 : in  std_logic_vector(15 downto 0); -- Entrada de onda 1
            wave_in_2 : in  std_logic_vector(15 downto 0); -- Entrada de onda 2
            wave_in_3 : in  std_logic_vector(15 downto 0); -- Entrada de onda 3 
            wave_out   : out STD_LOGIC_VECTOR (15 downto 0)
         );
end multiplex;

architecture Behavioral of multiplex is
    signal wave_value : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin   
    process(sel, wave_in_1, wave_in_2, wave_in_3)
    begin
        case sel is
            when "0001" =>
                wave_value <= wave_in_1; -- Onda 1
            when "0010" =>
                wave_value <= wave_in_2; -- Onda 2
            when "0011" =>
                wave_value <= wave_in_3; -- Onda 3
            when "0100" =>
                wave_value <= X"FFFF"; -- Onda 4
            when "0101" =>
                wave_value <= X"00FF"; -- Onda 5
            when "0110" =>
                wave_value <= X"0F0F"; -- Onda 6
            when "0111" =>
                wave_value <= X"F0F0"; -- Onda 7
            when others =>
                wave_value <= (others => '0'); -- Default a 0
        end case;
    end process;

    -- salida
    wave_out <= wave_value;

end Behavioral;