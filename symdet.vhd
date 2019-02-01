----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2018 11:34:48 PM
-- Design Name: 
-- Module Name: symdet - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.07 - Final
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.numeric_std.all;

entity symdet is
    Port (d_bin, clk, clr : in STD_LOGIC;
           dot, dash, lg, wg, valid : out STD_LOGIC);
end symdet;

architecture Behavioral of symdet is

    component fifo_generator_0 IS
      PORT (
        clk : IN STD_LOGIC;
        srst : IN STD_LOGIC;
        din : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
        full : OUT STD_LOGIC;
        empty : OUT STD_LOGIC
      );
    END component;
    signal fifocounter_0: integer range 0 to 35000 := 0;
    signal fifocounter_1: integer range 0 to 35000 := 0;
    signal unlocked: STD_LOGIC := '0';
    signal endflag: STD_LOGIC := '0';
    signal unit: integer range 0 to 10000 := 1000;
    signal currentdin: integer range 0 to 1:=1;
    signal prevdin: integer range 0 to 1:=1;
    signal counter_0: integer range 0 to 35000:=0;
    signal counter_1: integer range 0 to 35000:=0;
    signal value0: integer range 0 to 35000:=0;
    signal value1: integer range 0 to 35000:=0;
    signal found: STD_LOGIC := '0';
    signal silence: STD_LOGIC := '0';
    signal silence1: STD_LOGIC := '0';
    signal silence2: STD_LOGIC := '0';
    signal silence3: STD_LOGIC := '0';
    signal silence4: STD_LOGIC := '0';
    signal read_delay: STD_LOGIC := '0';
    signal read_delay2: STD_LOGIC := '0';
    signal output_a : std_logic_vector(16 downto 0);
    signal output_b : std_logic_vector(17 downto 16);
    signal answer_a: integer range 0 to 35000:=0;
    signal answer_b: integer range 0 to 35000:=0;
    signal fifo_reset: STD_LOGIC := '0';
    signal write: STD_LOGIC := '0';
    signal read: STD_LOGIC;
    signal fifo_in, fifo_out: STD_LOGIC_VECTOR(17 DOWNTO 0);
    signal full,empty: STD_LOGIC;
begin
    
    QUEUE: fifo_generator_0 port map (clk, fifo_reset, fifo_in, write, read, fifo_out, full, empty);
    
    fifo_reset <= '0';

    proc_incoming: process (clk, clr)
    begin
        if(clr = '1') then
            fifocounter_0<=0;
            fifocounter_1<=0;
        end if;
            
        if (clk'event and clk = '1') then
            silence <= '0';
            if d_bin = '0' then
                if endflag = '0' then
                    fifocounter_0 <= fifocounter_0 + 1;
                    currentdin<=0;
                end if;
            else
                fifocounter_1 <= fifocounter_1 + 1;
                if endflag = '1' then
                    endflag <= '0';
                end if;
                currentdin<=1;
            end if;
            if (prevdin  = currentdin) then
                write <= '0';
            end if;
            if fifocounter_0 > unit * 8 then
                fifocounter_0 <= 0;
                found <= '1';
                endflag <= '1';
                silence <= '1';
            end if;
            if not (prevdin  = currentdin) then       
                if full = '0' then
                    if(prevdin = 0) then
                        if fifocounter_0 > 10 then
                        write <= '1';
                        output_a <= conv_std_logic_vector(fifocounter_0, output_a'length);
                        output_b <= conv_std_logic_vector(0, output_b'length);
                        fifo_in(16 downto 0) <= conv_std_logic_vector(fifocounter_0, output_a'length);
                        fifo_in(17 downto 16) <= conv_std_logic_vector(0, output_b'length);
                        counter_0 <= fifocounter_0;
                        fifocounter_0<=0;
                        found <= '1';
                        end if;
                    else
                        write <= '1';
                        output_a <= conv_std_logic_vector(fifocounter_1, output_a'length);
                        output_b <= conv_std_logic_vector(1, output_b'length);
                        fifo_in(16 downto 0) <= conv_std_logic_vector(fifocounter_1, output_a'length);
                        fifo_in(17 downto 16) <= conv_std_logic_vector(1, output_b'length);
                        counter_1 <= fifocounter_1;
                        fifocounter_1<=0;
                        found <= '0';
                    end if;
                 end if;     
             end if;      
            prevdin <= currentdin;
        end if;
    end process;
 
    proc_estimate: process (clk, found, counter_0, counter_1)
    begin
    if (clk'event and clk = '1') then
        unlocked <= '0';
        if found = '1' then
            if counter_0 < unit * 8 then
                if 100*counter_0 > 95*3*counter_1 and 100*counter_0 < 105*3*counter_1 then
                    unit <= counter_1;
                    value0 <= 0;
                    value1 <= 0;
                    unlocked <= '1';
                elsif 100*counter_1 > 95*3*counter_0 and 100*counter_1 < 105*3*counter_0 then
                    unit <= counter_0;
                    value0 <= 0;
                    value1 <= 0;
                    unlocked <= '1';
                elsif 100*counter_0 > 95*7*counter_1 and 100*counter_0 < 105*7*counter_1 then
                    unit <= counter_1;
                    value0 <= 0;
                    value1 <= 0;
                    unlocked <= '1';
                elsif 100*3*counter_0 > 95*7*counter_1 and 100*3*counter_0 < 105*7*counter_1 then
                    unit <= counter_1 / 3;
                    value0 <= 0;
                    value1 <= 0;
                    unlocked <= '1';
                elsif 100*counter_0 > 95*counter_1 and 100*counter_0 < 105*counter_1 then
                    value0 <= counter_0;
                    value1 <= counter_1;
                    unlocked <= '0';
                end if;
            else
                unlocked <= '1';
            end if;
        end if;
    end if;
    end process;
    
    proc_out: process (clk, read_delay)
    begin
        if (clk'event and clk = '1') then
            if read_delay = '1' then
                answer_b <= conv_integer(fifo_out(17 downto 16));
                if conv_integer(fifo_out(17 downto 16)) = 1 then
                   answer_a <= conv_integer(fifo_out(15 downto 0));
                else
                    answer_a <= conv_integer(fifo_out(16 downto 0));
                end if;
            end if;
        end if;
    end process;
    
    proc_output: process (clk, read_delay2, unlocked, silence4)
    begin
        if (clk'event and clk = '1') then
            if read_delay2 = '0' then
                dot <= '0';
                dash <= '0';
                lg <= '0';
                wg <= '0';
                valid <= '0';
            else
               if answer_b = 1 then
                   lg <= '0';
                   wg <= '0';
                   if 100*answer_a > 95*unit and 100*answer_a < 105*unit then          
                       dot <= '1';
                       valid <= '1';
                   elsif 100*answer_a > 95*3*unit and 100*answer_a < 105*3*unit then
                       dash <= '1';
                       valid <= '1';
                   end if;
              else
                    dot <= '0';
                    dash <= '0';
                    if 100*answer_a > 95*3*unit and 100*answer_a < 105*3*unit then
                       lg <= '1';
                       valid <= '1';
                   elsif 100*answer_a > 95*7*unit and 100*answer_a < 105*7*unit then
                       wg <= '1';
                       valid <= '1';
                   else
                        valid <= '0';
                   end if;
               end if;
           end if;
           if silence4 = '1' then
                lg <= '1';
                valid <= '1';
            end if;
        end if;
    end process;
    
    proc_read: process (unlocked, empty)
    begin
        read <= unlocked and (not empty);
    end process;
    
    proc_readdelay: process (read, clk)
    begin
        if(clk' event and clk='1') then
            if (read='1') then
                read_delay<='1';
            else
                read_delay<='0';
            end if;
       end if;
    end process;
    
    proc_readdelay2: process (read_delay, clk)
        begin
            if(clk' event and clk='1') then
                if (read_delay='1') then
                    read_delay2<='1';
                else
                    read_delay2<='0';
                end if;
           end if;
        end process;
        
    proc_silencedelay: process (silence, clk)
    begin
        if(clk' event and clk='1') then
            if (silence='1') then
                silence1<='1';
            else
                silence1<='0';
            end if;
       end if;
    end process;
    
    proc_silencedelay2: process (silence1, clk)
        begin
            if(clk' event and clk='1') then
                if (silence1='1') then
                    silence2<='1';
                else
                    silence2<='0';
                end if;
           end if;
        end process;
        
    proc_silencedelay3: process (silence2, clk)
        begin
            if(clk' event and clk='1') then
                if (silence2='1') then
                    silence3<='1';
                else
                    silence3<='0';
                end if;
           end if;
        end process;
        
        proc_silencedelay4: process (silence3, clk)
            begin
                if(clk' event and clk='1') then
                    if (silence3='1') then
                        silence4<='1';
                    else
                        silence4<='0';
                    end if;
               end if;
            end process;


end Behavioral;