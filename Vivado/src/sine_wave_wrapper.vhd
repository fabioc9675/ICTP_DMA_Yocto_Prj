library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;
library work ;

entity sine_axi_wrapper is
  generic( 
    sine_res : integer :=16;
    dest_res : integer := 8;
    id_res   : integer := 8;
    id : integer :=0);
  port (
    --variables
    destination : in STD_LOGIC_VECTOR(dest_res -1 downto 0);
    --axis port
    s_axis_clk  : in std_logic;
    s_axis_rstn : in  std_logic;

    s_axis_tdata    :  out STD_LOGIC_VECTOR(sine_res -1  downto 0);
    s_axis_tready   : in  STD_LOGIC;
    s_axis_tvalid   : out STD_LOGIC;
    s_axis_tdest    : out STD_LOGIC_VECTOR(dest_res-1 downto 0);  
    s_axis_tid      : out STD_LOGIC_VECTOR(id_res-1 downto 0);
    s_axis_tlast    : out STD_LOGIC
  ) ;
end sine_axi_wrapper ; 

architecture arch of sine_axi_wrapper is

signal rst : std_logic;

begin   
    rst<=not s_axis_rstn;
    sine_wave_gen_inst: entity work.sine_wave_gen
     generic map(dres => sine_res)
     port map(
        clk => s_axis_clk,
        rst => rst,
        sine_out => s_axis_tdata,
        last => s_axis_tlast
    );

    s_axis_tid <= std_logic_vector(to_unsigned(id, id_res));
    s_axis_tdest <= destination;

    s_axis_tvalid <= '0' when s_axis_rstn = '0' else '1';

end architecture ;