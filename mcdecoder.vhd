----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 10/12/2018 12:44:03 PM
-- Design Name:
-- Module Name: mcdecoder - Behavioral
-- Project Name: Morse Code Decoder for Homework 1
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

entity mcdecoder is
    Port ( dot : in STD_LOGIC;
           dash : in STD_LOGIC;
           lg : in STD_LOGIC;
           wg : in STD_LOGIC;
           valid : in STD_LOGIC;
           dout : out STD_LOGIC_VECTOR (7 downto 0);
           dvalid : out STD_LOGIC;
           error : out STD_LOGIC;
           clr : in STD_LOGIC;
           clk : in STD_LOGIC);
end mcdecoder;

architecture Behavioral of mcdecoder is

   --Use descriptive names for the states, like st1_reset, st2_search
   type state_type is (reset, space, A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z, O_dot, O_dash, U_dash, S0,S1,S2,S3,S4,S5,S6,S7,S8,S9, err);
   signal state, next_state : state_type;

begin

   --A clock process for state register
   proc_statereg: process (clk, clr)
   begin
      if (clr = '1') then
         -- jump to reset state here
         state <= reset;
     end if;
     if (clk'event and clk = '1') then
         state <= next_state;
      end if;
   end process;

   --MEALY State-Machine - Outputs based on state and inputs
   proc_output: process (state, lg, wg, valid)
   begin
      --insert statements to decode internal output signals
      --below is simple example
      if valid = '1' and (lg = '1' or wg = '1') then
        dvalid <= '1';
        if state = space then
            dout <= "01000000";
        elsif state = A then
            dout <= "01000001";
        elsif state = B then
            dout <= "01000010";
        elsif state = C then
            dout <= "01000011";
        elsif state = D then
            dout <= "01000100";
        elsif state = E then
            dout <= "01000101";
        elsif state = F then
            dout <= "01000110";
        elsif state = G then
            dout <= "01000111";
        elsif state = H then
            dout <= "01001000";
        elsif state = I then
            dout <= "01001001";
        elsif state = J then
            dout <= "01001010";
        elsif state = K then
            dout <= "01001011";
        elsif state = L then
            dout <= "01001100";
        elsif state = M then
            dout <= "01001101";
        elsif state = N then
            dout <= "01001110";
        elsif state = O then
            dout <= "01001111";
        elsif state = P then
            dout <= "01010000";
        elsif state = Q then
            dout <= "01010001";
        elsif state = R then
            dout <= "01010010";
        elsif state = S then
            dout <= "01010011";
        elsif state = T then
            dout <= "01010100";
        elsif state = U then
            dout <= "01010101";
        elsif state = V then
            dout <= "01010110";
        elsif state = W then
            dout <= "01010111";
        elsif state = X then
            dout <= "01011000";
        elsif state = Y then
            dout <= "01011001";
        elsif state = Z then
            dout <= "01011010";
        -- Extra states
        elsif state = O_dot then
            dout <= "01011011";
        elsif state = O_dash then
            dout <= "01011100";
        elsif state = U_dash then
            dout <= "01011101";
        -- Digits
        elsif state = S0 then
            dout <= "00110000";
        elsif state = S1 then
            dout <= "00110001";
        elsif state = S2 then
            dout <= "00110010";
        elsif state = S3 then
            dout <= "00110011";
        elsif state = S4 then
            dout <= "00110100";
        elsif state = S5 then
            dout <= "00110101";
        elsif state = S6 then
            dout <= "00110110";
        elsif state = S7 then
            dout <= "00110111";
        elsif state = S8 then
            dout <= "00111000";
        elsif state = S9 then
            dout <= "00111001";
        -- Error states
        elsif state = err then
            error <= '1';
            dvalid <= '0';
        end if;
    else
        dvalid <= '0';
    end if;
   end process;
   -- Next State Logic.  This corresponds to your next state logic table
   proc_ns: process (state, dot, dash, lg, wg, valid)
   begin
      --declare default state for next_state to avoid latches
      next_state <= state;  --default is to stay in current state
      --insert statements to decode next_state
      --below is a simple example
      if wg = '1' and valid = '1' then
        next_state <= space;
      elsif lg = '1' and valid = '1' then
        next_state <= reset;
      else
          case (state) is
            when space =>
                if valid = '1' and wg = '0' then
                    next_state <= reset;
                    if dot = '1' and valid = '1' then
                        next_state <= E;
                    elsif dash = '1' and valid = '1' then
                        next_state <= T;
                    else
                        next_state <= state;
                    end if;
                end if;
            when reset =>
                if dot = '1' and valid = '1' then
                    next_state <= E;
                elsif dash = '1' and valid = '1' then
                    next_state <= T;
                else
                    next_state <= state;
                end if;
             when A =>
                if valid = '1' and dot = '1' then
                    next_state <= R;
                elsif valid = '1' and dash = '1' then
                    next_state <= W;
                else
                    next_state <= state;
                end if;
            when B =>
                if valid = '1' and dot = '1' then
                    next_state <= S6;
                elsif valid = '1' and dash = '1' then
                    next_state <= err;
                else
                    next_state <= state;
                end if;
            when C =>
                if valid = '1' and dot = '1' then
                    next_state <= reset;
                elsif valid = '1' and dash = '1' then
                    next_state <= reset;
                else
                    next_state <= state;
                end if;
             when D =>
                   if valid = '1' and dot = '1' then
                       next_state <= B;
                   elsif valid = '1' and dash = '1' then
                       next_state <= X;
                   else
                       next_state <= state;
                   end if;
               when E =>
                   if valid = '1' and dot = '1' then
                       next_state <= I;
                   elsif valid = '1' and dash = '1' then
                       next_state <= A;
                   else
                       next_state <= state;
                   end if;
               when F =>
                   if valid = '1' and dot = '1' then
                       next_state <= reset;
                   elsif valid = '1' and dash = '1' then
                       next_state <= reset;
                   else
                       next_state <= state;
                   end if;
             when G =>
                      if valid = '1' and dot = '1' then
                          next_state <= Z;
                      elsif valid = '1' and dash = '1' then
                          next_state <= Q;
                      else
                          next_state <= state;
                      end if;
                  when H =>
                      if valid = '1' and dot = '1' then
                          next_state <= S5;
                      elsif valid = '1' and dash = '1' then
                          next_state <= S4;
                      else
                          next_state <= state;
                      end if;
                  when I =>
                      if valid = '1' and dot = '1' then
                          next_state <= S;
                      elsif valid = '1' and dash = '1' then
                          next_state <= U;
                      else
                          next_state <= state;
                      end if;
                   when J =>
                         if valid = '1' and dot = '1' then
                             next_state <= err;
                         elsif valid = '1' and dash = '1' then
                             next_state <= S1;
                         else
                             next_state <= state;
                         end if;
                     when K =>
                         if valid = '1' and dot = '1' then
                             next_state <= C;
                         elsif valid = '1' and dash = '1' then
                             next_state <= Y;
                         else
                             next_state <= state;
                         end if;
                     when L =>
                         if valid = '1' and dot = '1' then
                             next_state <= reset;
                         elsif valid = '1' and dash = '1' then
                             next_state <= reset;
                         else
                             next_state <= state;
                         end if;
                        when M =>
                            if valid = '1' and dot = '1' then
                                next_state <= G;
                            elsif valid = '1' and dash = '1' then
                                next_state <= O;
                            else
                                next_state <= state;
                            end if;
                        when N =>
                            if valid = '1' and dot = '1' then
                                next_state <= D;
                            elsif valid = '1' and dash = '1' then
                                next_state <= K;
                            else
                                next_state <= state;
                            end if;
                        when O =>
                            if valid = '1' and dot = '1' then
                                next_state <= O_dot;
                            elsif valid = '1' and dash = '1' then
                                next_state <= O_dash;
                            else
                                next_state <= state;
                            end if;
                        when O_dot =>
                            if valid = '1' and dot = '1' then
                                next_state <= S8;
                            elsif valid = '1' and dash = '1' then
                                next_state <= err;
                            else
                                next_state <= state;
                            end if;
                        when O_dash =>
                                if valid = '1' and dot = '1' then
                                    next_state <= S9;
                                elsif valid = '1' and dash = '1' then
                                    next_state <= S0;
                                else
                                    next_state <= state;
                                end if;
                         when P =>
                               if valid = '1' and dot = '1' then
                                   next_state <= reset;
                               elsif valid = '1' and dash = '1' then
                                   next_state <= reset;
                               else
                                   next_state <= state;
                               end if;
                           when Q =>
                               if valid = '1' and dot = '1' then
                                   next_state <= reset;
                               elsif valid = '1' and dash = '1' then
                                   next_state <= reset;
                               else
                                   next_state <= state;
                               end if;
                           when R =>
                               if valid = '1' and dot = '1' then
                                   next_state <= L;
                               elsif valid = '1' and dash = '1' then
                                   next_state <= err;
                               else
                                   next_state <= state;
                               end if;
                         when S =>
                                  if valid = '1' and dot = '1' then
                                      next_state <= H;
                                  elsif valid = '1' and dash = '1' then
                                      next_state <= V;
                                  else
                                      next_state <= state;
                                  end if;
                              when T =>
                                  if valid = '1' and dot = '1' then
                                      next_state <= N;
                                  elsif valid = '1' and dash = '1' then
                                      next_state <= M;
                                  else
                                      next_state <= state;
                                  end if;
                              when U =>
                                  if valid = '1' and dot = '1' then
                                      next_state <= F;
                                  elsif valid = '1' and dash = '1' then
                                      next_state <= U_dash;
                                  else
                                      next_state <= state;
                                  end if;
                              when U_dash =>
                                    if valid = '1' and dot = '1' then
                                        next_state <= err;
                                    elsif valid = '1' and dash = '1' then
                                        next_state <= S2;
                                    else
                                        next_state <= state;
                                    end if;
                               when V =>
                                     if valid = '1' and dot = '1' then
                                         next_state <= err;
                                     elsif valid = '1' and dash = '1' then
                                         next_state <= S3;
                                     else
                                         next_state <= state;
                                     end if;
                                 when W =>
                                     if valid = '1' and dot = '1' then
                                         next_state <= P;
                                     elsif valid = '1' and dash = '1' then
                                         next_state <= J;
                                     else
                                         next_state <= state;
                                     end if;
                                 when X =>
                                     if valid = '1' and dot = '1' then
                                         next_state <= reset;
                                     elsif valid = '1' and dash = '1' then
                                         next_state <= reset;
                                     else
                                         next_state <= state;
                                     end if;
                                    when Y =>
                                        if valid = '1' and dot = '1' then
                                            next_state <= reset;
                                        elsif valid = '1' and dash = '1' then
                                            next_state <= reset;
                                        else
                                            next_state <= state;
                                        end if;
                                    when Z =>
                                        if valid = '1' and dot = '1' then
                                            next_state <= S7;
                                        elsif valid = '1' and dash = '1' then
                                            next_state <= err;
                                        else
                                            next_state <= state;
                                        end if;
                                    when S0 =>
                                        if valid = '1' and (dot = '1' or dash = '1') then
                                            next_state <= reset;
                                        else
                                            next_state <= state;
                                        end if;
                                     when S1 =>
                                           if valid = '1' and (dot = '1' or dash = '1') then
                                             next_state <= reset;
                                           else
                                               next_state <= state;
                                           end if;
                                       when S2 =>
                                           if valid = '1' and (dot = '1' or dash = '1') then
                                               next_state <= reset;
                                           else
                                               next_state <= state;
                                           end if;
                                       when S3 =>
                                           if valid = '1' and (dot = '1' or dash = '1') then
                                               next_state <= reset;
                                           else
                                               next_state <= state;
                                           end if;
                                     when S4 =>
                                       if valid = '1' and (dot = '1' or dash = '1') then
                                           next_state <= reset;
                                       else
                                           next_state <= state;
                                       end if;
                                    when S5 =>
                                          if valid = '1' and (dot = '1' or dash = '1') then
                                            next_state <= reset;
                                          else
                                              next_state <= state;
                                          end if;
                                      when S6 =>
                                          if valid = '1' and (dot = '1' or dash = '1') then
                                              next_state <= reset;
                                          else
                                              next_state <= state;
                                          end if;
                                      when S7 =>
                                          if valid = '1' and (dot = '1' or dash = '1') then
                                              next_state <= reset;
                                          else
                                              next_state <= state;
                                          end if;
                                       when S8 =>
                                          if valid = '1' and (dot = '1' or dash = '1') then
                                              next_state <= reset;
                                          else
                                              next_state <= state;
                                          end if;
                                       when S9 =>
                                             if valid = '1' and (dot = '1' or dash = '1') then
                                               next_state <= reset;
                                             else
                                                 next_state <= state;
                                             end if;
                                        when err =>
                                            next_state <= reset;
          end case;
      end if;
   end process;

end Behavioral;