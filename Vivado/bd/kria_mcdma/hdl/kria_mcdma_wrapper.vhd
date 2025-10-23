--Copyright 1986-2023 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2022.2.2_AR000035739 (lin64) Build 3788238 Tue Feb 21 19:59:23 MST 2023
--Date        : Sun Sep 28 22:50:31 2025
--Host        : kboXPS running 64-bit Ubuntu 22.04.5 LTS
--Command     : generate_target kria_mcdma_wrapper.bd
--Design      : kria_mcdma_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity kria_mcdma_wrapper is
  port (
    fan_en_b : out STD_LOGIC_VECTOR ( 0 to 0 );
    uf_leds_tri_io : inout STD_LOGIC_VECTOR ( 1 downto 0 )
  );
end kria_mcdma_wrapper;

architecture STRUCTURE of kria_mcdma_wrapper is
  component kria_mcdma is
  port (
    uf_leds_tri_i : in STD_LOGIC_VECTOR ( 1 downto 0 );
    uf_leds_tri_o : out STD_LOGIC_VECTOR ( 1 downto 0 );
    uf_leds_tri_t : out STD_LOGIC_VECTOR ( 1 downto 0 );
    fan_en_b : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component kria_mcdma;
  component IOBUF is
  port (
    I : in STD_LOGIC;
    O : out STD_LOGIC;
    T : in STD_LOGIC;
    IO : inout STD_LOGIC
  );
  end component IOBUF;
  signal uf_leds_tri_i_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal uf_leds_tri_i_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal uf_leds_tri_io_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal uf_leds_tri_io_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal uf_leds_tri_o_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal uf_leds_tri_o_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal uf_leds_tri_t_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal uf_leds_tri_t_1 : STD_LOGIC_VECTOR ( 1 to 1 );
begin
kria_mcdma_i: component kria_mcdma
     port map (
      fan_en_b(0) => fan_en_b(0),
      uf_leds_tri_i(1) => uf_leds_tri_i_1(1),
      uf_leds_tri_i(0) => uf_leds_tri_i_0(0),
      uf_leds_tri_o(1) => uf_leds_tri_o_1(1),
      uf_leds_tri_o(0) => uf_leds_tri_o_0(0),
      uf_leds_tri_t(1) => uf_leds_tri_t_1(1),
      uf_leds_tri_t(0) => uf_leds_tri_t_0(0)
    );
uf_leds_tri_iobuf_0: component IOBUF
     port map (
      I => uf_leds_tri_o_0(0),
      IO => uf_leds_tri_io(0),
      O => uf_leds_tri_i_0(0),
      T => uf_leds_tri_t_0(0)
    );
uf_leds_tri_iobuf_1: component IOBUF
     port map (
      I => uf_leds_tri_o_1(1),
      IO => uf_leds_tri_io(1),
      O => uf_leds_tri_i_1(1),
      T => uf_leds_tri_t_1(1)
    );
end STRUCTURE;
