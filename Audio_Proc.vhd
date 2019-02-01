library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.numeric_std.all;

entity Audio_Proc is
 Port ( 
 data_in    : in std_logic_vector(11 downto 0);
 in_start, out_data :     out std_logic; 
 in_done, clk, clr      : in std_logic -- 48k clock
 );
end Audio_Proc;

architecture Behavioral of Audio_Proc is
signal input         : std_logic_vector(11 downto 0); 
signal absolute_val  : integer :=0;
signal threshold : std_logic_vector (10 downto 0) := "00000001111" ;
signal w_ctr: integer :=0;
-- WINDOW CTR
signal w_sum: integer :=0;
-- WINDOW SUM
signal w_avg: integer :=0;
-- WINDOW AVG
-- SIGOUT = OUT_DATA
begin
proc_clk : process(clk, clr)
        begin
            if (clk = '1' and clk'event) then
                if(not in_done  = '1') then
                in_start<='1';
                absolute_val <= conv_integer(data_in(10 downto 0));
                -- We now have the absolute value
                
                if (w_ctr >= 128) then
                    w_ctr<=0;
                    w_sum<=0;
                    w_avg<=0;
                end if;
            
                w_ctr<=w_ctr+1;
                w_sum<=w_sum+absolute_val;
                w_avg<=(w_sum)/(w_ctr);
                
                    if(w_avg > threshold) then
                        out_data <= '1';
                    else
                        out_data<='0';
                    end if;
                    else
                        in_start<='0';
                    end if; 
                end if;
        end process;
end Behavioral;
