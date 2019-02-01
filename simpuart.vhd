----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/30/2018 11:51:42 PM
-- Design Name: 
-- Module Name: simpuart - rtl
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity simpuart is
    Port ( 
           din : in STD_LOGIC_VECTOR (7 downto 0);
           wen : in STD_LOGIC;
           sout : out STD_LOGIC;
           clr : in STD_LOGIC;
           clk_48k : in STD_LOGIC);
end simpuart;

architecture rtl of simpuart is
  type state_type is (S_IDLE, S_STARTBIT, S_D0, S_D1, S_D2, S_D3, S_D4, S_D5, S_D6, S_D7, S_STOPBIT, IDLE);
  signal state, next_state : state_type;
  
  signal d_tx_i : std_logic_vector(7 downto 0);
  
  signal baudcnt : unsigned(2 downto 0);
  signal baud : std_logic;
begin

--Insert the following in the architecture after the begin keyword
SYNC_PROC: process (clk_48k, clr)
begin
   if (rising_edge(clk_48k)) then
      if (clr = '1') then
         state <= S_IDLE;
      else
         state <= next_state;
      end if;
   end if;
end process;

-- OUTPUT LOGIC
sout <= '1' when state = S_IDLE else
        '0' when state = S_STARTBIT else
        d_tx_i(0) when state = S_D0 else
        d_tx_i(1) when state = S_D1 else
        d_tx_i(2) when state = S_D2 else
        d_tx_i(3) when state = S_D3 else
        d_tx_i(4) when state = S_D4 else
        d_tx_i(5) when state = S_D5 else
        d_tx_i(6) when state = S_D6 else
        d_tx_i(7) when state = S_D7 else
        '1' when state = S_STOPBIT else
        '1';
       
NEXT_STATE_DECODE: process (state, wen, baud)
begin
   next_state <= state;  --default is to stay in current state
   case (state) is
      when S_IDLE =>
         if wen = '1' then
            next_state <= S_STARTBIT;
         end if;
      when S_STARTBIT =>
         if baud = '1' then
            next_state <= S_D0;
         end if;
      when S_D0 =>
         if baud = '1' then
           next_state <= S_D1;
         end if;
      when S_D1 =>
         if baud = '1' then
            next_state <= S_D2;
         end if;
      when S_D2 =>
         if baud = '1' then
            next_state <= S_D3;
         end if;
      when S_D3 =>
         if baud = '1' then
            next_state <= S_D4;
         end if;
      when S_D4 =>
         if baud = '1' then
            next_state <= S_D5;
         end if;
      when S_D5 =>
         if baud = '1' then
            next_state <= S_D6;
         end if;
      when S_D6 =>
         if baud = '1' then
            next_state <= S_D7;
         end if;
      when S_D7 =>
         if baud = '1' then
            next_state <= S_STOPBIT;
         end if;
      when S_STOPBIT =>
         if baud = '1' then
            next_state <= S_IDLE;
         end if;
      when others =>
         next_state <= S_IDLE;
   end case;
end process;

-- Generate 9600 Baud from 48k input (1:5)
proc_genbaud: process(clk_48k, clr)
begin
  if (clr = '1') then
    baudcnt <= (others => '0');
  elsif (rising_edge(clk_48k)) then
    if ( (state = S_IDLE) or (to_integer(baudcnt) = 4)) then
      baudcnt <= (others=>'0');
    else
      baudcnt <= baudcnt + 1;
    end if;
  end if;
end process;
baud <= '1' when (to_integer(baudcnt) = 4) else '0';

-- Latch input data (may change to FIFO)
proc_d_tx_i: process(clk_48k, clr)
begin
  if (clr = '1') then
    d_tx_i <= (others=>'0');
  elsif (rising_edge(clk_48k)) then
    if (wen = '1') then
      d_tx_i <= din;
    end if;
  end if;
end process;


end rtl;
