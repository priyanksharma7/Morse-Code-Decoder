----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/30/2018 11:48:47 PM
-- Design Name: 
-- Module Name: testdecoder - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity testdecoder is
    Port ( 
           RsTx : out STD_LOGIC;
           btnC: in std_logic;
           clr : in STD_LOGIC;
           clk_100m : in STD_LOGIC);
end testdecoder;

architecture rtl of testdecoder is
  component clk_wiz_0 
    PORT ( clk_6144: out std_logic;
           reset   : in  std_logic;
           locked  : out std_logic;
           clk_100m: in  std_logic);
  end component;
  component clk_div
      Port ( clk_in     : in STD_LOGIC;
             clr        : in STD_LOGIC;
             clk_div128 : out STD_LOGIC);
  end component;
  component simpuart
      Port ( din : in STD_LOGIC_VECTOR (7 downto 0);
         wen : in STD_LOGIC;
         sout : out STD_LOGIC;
         clr : in STD_LOGIC;
         clk_48k : in STD_LOGIC);
  end component;
  component symdet
      Port ( d_bin : in STD_LOGIC;
             dot : out STD_LOGIC;
             dash : out STD_LOGIC;
             lg : out STD_LOGIC;
             wg : out STD_LOGIC;
             valid : out STD_LOGIC;
             clr : in STD_LOGIC;
             clk : in STD_LOGIC);
  end component;
  component mcgen is
    Port (clk : in std_logic;
          button : in std_logic;
          data_rom: out std_logic);
  end component;
  component mcdecoder is
      port(clk : in std_logic;
           valid : in std_logic;
           clr : in std_logic;
           dash : in std_logic;
           dot : in std_logic;
           lg :in std_logic;
           wg : in std_logic;
           dvalid :  out std_logic;
           error : out std_logic;
           dout : out std_logic_vector(7 downto 0));
  end component;
  component uart_wren
      Port (
             clr : in std_logic;
             clk : in STD_LOGIC;
             wr_valid : in STD_LOGIC;
             dout : out STD_LOGIC;
             data_in : in std_logic_vector(7 downto 0);
             data_out : out std_logic_vector(7 downto 0));
   end component;
   
  signal clk_6144: std_logic;
  signal clk_48k: std_logic;
  signal clk_locked: std_logic;
  
  signal uart_wr: std_logic;
  signal sout_i:std_logic_vector(0 downto 0);
 
 --Decorder signal
  signal dot : std_logic;
  signal dash : std_logic;
  signal lg : std_logic;
  signal wg : std_logic;
  signal valid : std_logic;  
  signal d_bin : std_logic;
  signal dvalid: std_logic;
  signal error: std_logic;
  signal decoder_out : std_logic_vector(7 downto 0);
  --FIFO signal
  signal uartFIFO_out : std_logic_vector(7 downto 0);
  signal empty : std_logic;
  signal empty_out : std_logic;
  signal read_out :  STD_logic;
begin -- architecture rtl

  clk_wiz_0_inst: clk_wiz_0 PORT MAP (
    clk_6144=>clk_6144,
    reset=>clr,
    locked=>clk_locked,
    clk_100m=>clk_100m);
  clk_div_inst: clk_div PORT MAP (
    clk_in=>clk_6144,
    clr=>clr,
    clk_div128=>clk_48k);
    
  RsTx <= sout_i(0);
  simpuart_inst: simpuart PORT MAP (
       din=>uartFIFO_out,
       wen=>uart_wr,
       sout=>sout_i(0),
       clr=>clr,
       clk_48k=>clk_48k);
  uart_wren_inst: uart_wren PORT MAP (
       clr => clr,
       clk => clk_48k,
       wr_valid => dvalid,
       dout => uart_wr,
       data_in => decoder_out,
       data_out => uartFIFO_out);
       
  symdet_inst: symdet PORT MAP (
       d_bin=>d_bin,
       dot=>dot,
       dash=>dash,
       lg=>lg,
       wg=>wg,
       valid=>valid,
       clr=>clr,
       clk=>clk_48k);
       
   mcgen_inst: mcgen PORT MAP (
         clk => clk_48k,
         button => btnC,
         data_rom=> d_bin);
         
   mcdecoder_inst: mcdecoder PORT MAP (
         clk => clk_48k,
         valid => valid,
          clr =>clr,
          dash=>dash,
          dot=>dot,
          lg=>lg,
          wg=>wg,
          dvalid=>dvalid,
          error=> error,
          dout => decoder_out);    
end rtl;
