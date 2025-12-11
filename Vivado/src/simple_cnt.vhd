----------------------------------------------------------------------------------
-- Company: ICTP
-- Engineer: Fabian Castano
-- 
-- Create Date: 21.09.2025 00:27:13
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity contador is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           cont : out STD_LOGIC_VECTOR (31 downto 0));
end contador;

architecture Behavioral of contador is

signal cont_int : integer := 0;
signal cont_clk : integer := 0;

begin

process (clk, rst)
begin
    if rst = '0' then
        cont_int <= 0;
        cont_clk <= 0;
    elsif rising_edge(clk) then
        cont_clk <= (cont_clk + 1) mod 25000000;
        if cont_clk = 0 then 
            cont_int <= cont_int + 1;
        end if;
    end if;

end process;

cont <= std_logic_vector(to_unsigned(cont_int, 32));


end Behavioral;
