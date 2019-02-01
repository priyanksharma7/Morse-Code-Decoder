----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/31/2018 10:06:03 AM
-- Design Name: 
-- Module Name: oneshot - rtl
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

entity uart_wren is
    Port ( 
           clr : in std_logic;
           clk : in STD_LOGIC;
           wr_valid : in STD_LOGIC;
           dout : out STD_LOGIC;
           data_in : in std_logic_vector(7 downto 0);
           data_out : out std_logic_vector(7 downto 0));
           
end uart_wren;

architecture rtl of uart_wren is

component fifo_uart IS
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END component;
  type state_type is (S_IDLE, S_ONE, S_HOLD);
  signal state, next_state : state_type;
  
  signal empty : std_logic;
  signal full : std_logic;
  signal wr_en : std_logic;
  signal rd_en : std_logic;
  
  
  signal longenough : std_logic;
  signal holdcnt_start : std_logic;
  signal holdcnt: unsigned(15 downto 0);

begin
fifo_uart_inst: fifo_uart port map(
    clk => clk,
    srst => clr,
    din => data_in,
    wr_en => wr_en,
    rd_en =>rd_en,
    dout => data_out,
    full => full,
    empty => empty);
--Insert the following in the architecture after the begin keyword

  process(full,wr_valid)
    begin
        wr_en <= wr_valid and (not full);
    end process;
    
   SYNC_PROC: process (clk)
   begin
     if (rising_edge(clk)) then
       state <= next_state;
      end if;
   end process;

   --MOORE State-Machine - Outputs based on state only
   OUTPUT_DECODE: process (state)
   begin
      --insert statements to decode internal output signals
      --below is simple example
      if state = S_ONE then
        dout <= '1';
      else
        dout <= '0';
      end if;
   end process;

   NEXT_STATE_DECODE: process (state, empty, longenough)
   begin
      next_state <= state;  --default is to stay in current state
      rd_en <= '0';
      case (state) is
         when S_IDLE =>
            if empty = '0' then
               rd_en <= '1';
               next_state <= S_ONE;
            end if;
         when S_ONE =>
            next_state <= S_HOLD;
         when S_HOLD =>
           if longenough = '1' then
             next_state <= S_IDLE;
           end if;
         when others =>
            next_state <= S_IDLE;
      end case;
   end process;

  proc_holdcnt : process(clk)
  begin
    if (rising_edge(clk)) then
      if state = S_ONE then
        holdcnt <= (others => '0');
      else
        holdcnt <= holdcnt + 1;
      end if;
    end if;
  end process;
  longenough <= '1' when to_integer(holdcnt) = (6000 - 1) else '0'; 
  
end rtl;
