library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_SYMDET is
end test_SYMDET;

architecture Behavioral of test_SYMDET is
    component SYMDET
        port(clk, clr : in std_logic;
             dash,dot,lg, wg : out std_logic;
             valid : out std_logic;
             d_bin : in std_logic);
    end component;
    
    component mcdecoder
        port(clk,valid,clr : in std_logic;
             dash,dot,lg,wg : in std_logic;
             dvalid,error : out std_logic;
             dout : out std_logic_vector(7 downto 0));
    end component;

    
    signal clk, clr: std_logic:='0';
    signal d_bin : std_logic;
    signal dash,dot,lg, wg : std_logic:='0';
    signal count_d,count_g : integer range 0 TO 35000:=0; 
    constant clkPeriod : time := 20.8333 us;   --48KHZ
    constant number: integer :=1000;
    signal flag : std_logic :='1';
    signal one_number,zero_number: integer range 0 TO 35000:=number;
    
    signal valid : std_logic;
    signal dvalid, error : std_logic:='0';
    signal dout :  std_logic_vector(7 downto 0);

 begin 
 SYMDECTION: SYMDET port map (clk,clr,dash,dot,lg,wg,valid,d_bin);
 decoder: mcdecoder port map (clk,valid,clr,dash,dot,lg,wg, dvalid,error,dout);
 
  clkPro : process 
              begin
                 clk <= '0';
                 wait for clkPeriod/2;
                 clk <= '1';
                 wait for clkPeriod/2;
            end process;   
 

 clr <= '0';

 process (clk,one_number)                    --Transfer the number to a series of 1 or 1
    begin
       if (clk'event and clk='1') then
          if (one_number>0) then
            if (count_d < one_number) and (flag='1') then
              d_bin <= '1';
              count_d <= count_d + 1;
            elsif (count_d >= one_number) and (flag='1') then
                count_d <= 0;
                flag <= '0';
            elsif (count_g <zero_number) and (flag='0') then
                count_g <= count_g + 1;
                d_bin <= '0';
            elsif (count_g >= zero_number) and (flag='0') then
                count_g <= 0;
                flag<='1';
             end if;
           else
               d_bin<='0';
               count_g <= 0;
               count_d <= 0;
               flag<='1';
            end if;
        end if;                 
 end process;  
 
 process
       begin
       --dot,dot,lg,dash,dash,wg,dot,dash,dash,silence
       --dash,lg,dot,lg,dot,silence
       one_number <= number;
       zero_number <=number;
       wait for clkPeriod*number*3;
       
       one_number <= number-2;
       zero_number <=3*number;
       wait for clkPeriod*4*number;
       
       one_number <= 3*number;
       zero_number <=number+1;
       wait for clkPeriod*number*4;
       
       zero_number <=number;
       wait for clkPeriod*3*number;
       
       one_number <= number;
       zero_number <=7 * number;
        wait for clkPeriod*number*8;  
       
       one_number <= 3*number;
       zero_number <= number;
       wait for clkPeriod*number*8;
             
       one_number<=0;  
           
       wait for clkPeriod*number*25;
       one_number <=3*number;
       zero_number <=3*number;
        
       wait for clkPeriod*number*6;
       one_number <=number;
       zero_number <=3*number;
         
       wait for clkPeriod*number*8;
       one_number <=0;
       wait;        
 end process;             
 end Behavioral;