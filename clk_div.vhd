----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/31/2018 01:28:44 AM
-- Design Name: 
-- Module Name: clk_div - rtl
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

entity clk_div is
    Port ( clk_in     : in STD_LOGIC;
           clr        : in STD_LOGIC;
           clk_div128 : out STD_LOGIC);
end clk_div;

architecture rtl of clk_div is
  signal clk_divider: unsigned(6 downto 0);
begin

  clk_div_proc: process(clk_in, clr)
  begin
    if (clr = '1') then
      clk_divider <= (others=>'0');
    elsif (rising_edge(clk_in)) then
      clk_divider <= clk_divider + 1;
    end if;  
  end process;
  clk_div128 <= clk_divider(6);

end rtl;
