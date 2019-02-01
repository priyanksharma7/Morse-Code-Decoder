library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PmodMIC3 is
  Port    (    
    CLK      : in std_logic;        --CLK = 6.14MHZ Clock  
    RST      : in std_logic;
     
  --Pmod interface signals
    SDATA   : in std_logic;
    SCLK     : out std_logic;  --SCLK = SCK
    nCS      : out std_logic;  --nCS = SS
        
    --User interface signals
    DATA    : out std_logic_vector(11 downto 0);
    START    : in std_logic; 
    DONE     : out std_logic
            );

end PmodMIC3;

architecture PmodMic of PmodMIC3 is

type states is (Idle, ShiftIn, SyncData);  

          signal current_state : states;
          signal next_state    : states;
          signal temp          : std_logic_vector(15 downto 0);              
          signal clk_div1       : std_logic;      
          signal clk_counter   : std_logic_vector;    
          signal shiftCounter  : std_logic_vector(3 downto 0) := x"0"; 
          signal enShiftCounter: std_logic;
          signal enParalelLoad : std_logic;

begin
      
        clock_divide : process(rst,clk)
        begin
            if rst = '1' then
                clk_counter <= "0";
            elsif (clk = '1' and clk'event) then
                clk_counter <= clk_counter + '1';
            end if;
        end process;

        clk_div1 <= clk_counter(0);
        SCLK <=  not clk_counter(0); 

counter : process(clk_div1, enParalelLoad, enShiftCounter)
        begin
            if (clk_div1 = '1' and clk_div1'event) then
               
                if (enShiftCounter = '1') then 
                   temp <= temp(14 downto 0) & SDATA; 
                    shiftCounter <= shiftCounter + '1';
                elsif (enParalelLoad = '1') then
                   shiftCounter <= "0000";
                   DATA <= temp(11 downto 0);
                end if;
            end if;
        end process;
   
SYNC_PROC: process (clk_div1, rst)
   begin
      if (clk_div1'event and clk_div1 = '1') then
         if (rst = '1') then
            current_state <= Idle;
         else
            current_state <= next_state;
         end if;        
      end if;
   end process;
    
OUTPUT_DECODE: process (current_state)
   begin
      if current_state = Idle then
            enShiftCounter <='0';
            DONE <='1';
            nCS <='1';
            enParalelLoad <= '0';
        elsif current_state = ShiftIn then
            enShiftCounter <='1';
            DONE <='0';
            nCS <='0';
            enParalelLoad <= '0';
        else --if current_state = SyncData then
            enShiftCounter <='0';
            DONE <='0';
            nCS <='1';
            enParalelLoad <= '1';
        end if;
   end process;    
    
  NEXT_STATE_DECODE: process (current_state, START, shiftCounter)
   begin
      
      next_state <= current_state;  -- default is to stay in current state
     
      case (current_state) is
         when Idle =>
            if START = '1' then
               next_state <= ShiftIn;
            end if;
         when ShiftIn =>
            if shiftCounter = x"F" then
               next_state <= SyncData;
            end if;
         when SyncData =>
            if START = '0' then
            next_state <= Idle;
            end if;
         when others =>
            next_state <= Idle;
      end case;      
   end process;
end PmodMic;