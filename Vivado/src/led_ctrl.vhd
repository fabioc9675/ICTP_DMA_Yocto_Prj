----------------------------------------------------------------------------------
-- Company: ICTP
-- Engineer: Fabian Castano
-- 
-- Create Date: 21.09.2025 00:27:13
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_fsm is
    Port (
        clk      : in  std_logic;              -- Reloj
        reset    : in  std_logic;              -- Reset síncrono
        state    : in  std_logic_vector(3 downto 0); -- Selector de estado (00-11)
        data_in  : in  std_logic_vector(7 downto 0); -- Entrada de 0 a 255
        leds     : out std_logic_vector(7 downto 0)  -- Salida a LEDs
    );
end led_fsm;

architecture Behavioral of led_fsm is

    signal counter   : unsigned(32 downto 0) := (others => '0'); -- Para contar 1s
    signal seq_index : integer range 0 to 8 := 0;                -- Índice de LED secuencial
    signal led_reg   : std_logic_vector(7 downto 0) := (others => '0');

    constant CLK_FREQ : integer := 100000000; -- Frecuencia de reloj (50 MHz)
    constant ONE_SEC  : integer := 100000000; -- ciclos para 1 segundo

begin

    process(clk, reset)
    begin
        if reset = '0' then
            counter   <= (others => '0');
            seq_index <= 0;
            led_reg   <= (others => '0');

        elsif rising_edge(clk) then
            case state is
                -- Estado 1: LEDs impares encendidos
                when "0001" =>
                    led_reg <= "10101010"; -- L7 L6 ... L0  (pares apagados, impares encendidos)
                    seq_index <= 0;
                    counter <= (others => '0');

                -- Estado 2: Encendido secuencial (1s cada LED)
                when "0010" =>
                    if seq_index < 8 then
                        if counter = ONE_SEC-1 then
                            counter <= (others => '0');
                            led_reg <= (others => '0');
                            led_reg(seq_index) <= '1'; -- enciende solo el LED actual
                            seq_index <= seq_index + 1;
                        else
                            counter <= counter + 1;
                        end if;
                    end if;

                -- Estado 3: 4 primeros ON, 4 últimos OFF
                when "0100" =>
                    led_reg <= "00001111"; -- L7..L4 apagados, L3..L0 encendidos
                    seq_index <= 0;
                    counter <= (others => '0');

                -- Estado 4: mostrar valor de entrada
                when "1000" => -- "11"
                    led_reg <= data_in;
                    seq_index <= 0;
                    counter <= (others => '0');
                    
                when others => -- "11"
                    counter   <= (others => '0');
                    seq_index <= 0;
                    led_reg   <= (others => '0');
                    counter <= (others => '0');
            end case;
        end if;
    end process;

    leds <= led_reg;

end Behavioral;
