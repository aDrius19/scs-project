library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity Top_Level is
    Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
           B : in STD_LOGIC_VECTOR (3 downto 0);
           in_sel : in STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sel : in STD_LOGIC_VECTOR (3 downto 0);
           O : out STD_LOGIC_VECTOR (7 downto 0));
end Top_Level;

architecture Behavioral of Top_Level is

component wallace_tree is
    Port ( A : in  STD_LOGIC_VECTOR (3 downto 0);
           B : in  STD_LOGIC_VECTOR (3 downto 0);
           prod : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

component division is
    Port ( A: in std_logic_vector(3 downto 0);
           B: in std_logic_vector(3 downto 0);
           Q: out std_logic_vector(3 downto 0);
           R: out std_logic_vector(3 downto 0));
end component;

signal tmp : signed(3 downto 0) := (others => '0');
signal logicAND, logicOR, logicNOT, rotLeft, rotRight: std_logic_vector(3 downto 0);
signal bigInput, opposite : std_logic_vector(4 downto 0);
signal Mult_Out, Div_Out, temp : std_logic_vector(7 downto 0) := (others => '0');

begin

   Multiplication: wallace_tree port map (A => A, B => B, prod => Mult_Out);
   Div: division port map(A => A, B => B, Q => Div_Out(7 downto 4), R => Div_Out(3 downto 0)); 
   
   MUX_Selection: process(sel, rst, clk, in_sel, A, B)
   begin
    if( A = "0000" and B = "0000" and in_sel = '0' and rst = '0' and sel = "0000") then O <= (others => '0');
    else
        case sel is
            when "0000" =>  
                                if (rst = '1') then     --addition in 2's Complement
                                    O <= (others => '0');
                                elsif (rising_edge(clk)) then            
                                    tmp <= signed(A) + signed(B);
                                    if ((tmp > 7) or (tmp < to_signed(8, A'length))) then
                                       O <= (others => '1');
                                    else 
                                       O <= "0000" & std_logic_vector(tmp);
                                    end if;
                                end if;
                                    
            when "0001" =>  
                                if (rst = '1') then     --substraction in 2's Complement
                                    O <= (others => '0');
                                elsif (rising_edge(clk)) then            
                                    tmp <= signed(A) - signed(B);
                                    if ((to_integer(tmp) > 7) or (tmp < to_signed(8, A'length))) then
                                        O <= (others => '1');
                                    else 
                                        O <= "0000" & std_logic_vector(tmp);
                                    end if;
                                end if;
                            
            when "0010" =>  
                           
                                if (rst = '1') then     --increasing a chosen input
                                    O <= (others => '0');
                                elsif (rising_edge(clk)) then 
                                    if (in_sel = '0') then
                                        O <= "0000" & A + 1;
                                    else 
                                        O <= "0000" & B + 1;       
                                    end if;
                                end if;
                          
            when "0011" =>   
                            
                                if (rst = '1') then     --decreasing a chosen input
                                    O <= (others => '0');
                                elsif (rising_edge(clk)) then 
                                    if (in_sel = '0') then
                                        O <= "0000" & A - 1;
                                    else 
                                        O <= "0000" & B - 1;       
                                    end if;
                                end if;
                           
            when "0100" =>  
                            
                                if (rst = '1') then     --Logic AND for two inputs
                                    O <= (others => '0');
                                elsif (rising_edge(clk)) then 
                                    for i in 0 to 3 loop
                                        logicAND(i) <= A(i) and B(i);
                                    end loop;     
                                    O(3 downto 0) <= logicAND;
                                end if;
                           
            when "0101" =>  
                          
                                if (rst = '1') then     --Logic OR for two inputs
                                    O <= (others => '0');
                                elsif (rising_edge(clk)) then 
                                    for i in 0 to 3 loop
                                        logicOR(i) <= A(i) or B(i);
                                    end loop;     
                                    O(3 downto 0) <= logicOR;
                                end if; 
 
            when "0110" =>   

                                if (rst = '1') then     --Logic NOT for one chosen input
                                    O <= (others => '0');
                                elsif (rising_edge(clk)) then 
                                    if (in_sel = '0') then
                                        for i in 0 to 3 loop
                                            logicNOT(i) <= not A(i);
                                        end loop;     
                                    else
                                        for i in 0 to 3 loop
                                            logicNOT(i) <= not B(i);
                                        end loop;
                                    end if;
                                    O(3 downto 0) <= logicNOT;
                                end if;

            when "0111" =>   
                                if (rst = '1') then     --Opposite of a chosen input
                                    O <= (others => '0');
                                elsif (rising_edge(clk)) then 
                                    if (in_sel = '0') then
                                        bigInput(0) <= B(3);
                                      
                                        for i in 0 to 3 loop
                                            bigInput(i + 1) <= A(i);
                                        end loop; 
                                      
                                        for j in 0 to 4 loop
                                            opposite(j) <= not bigInput(j);
                                        end loop;  
                                        O(4 downto 0) <= opposite + 1;
                                    else
                                        for i in 0 to 3 loop
                                            bigInput(i) <= B(i);
                                        end loop; 
                                        bigInput(4) <= A(0);
                                        for j in 0 to 4 loop
                                            opposite(j) <= not bigInput(j);
                                        end loop;  
                                        O(4 downto 0) <= opposite + 1;
                                    end if;                  
                                end if; 
                            
            when "1000" =>  
                            if (rst = '1') then     -- Rotate left by one bit a chosen input
                                O <= (others => '0');
                            elsif (rising_edge(clk)) then 
                                if (in_sel = '0') then
                                    O(3 downto 0) <= std_logic_vector(unsigned(A) rol 1);      
                                else
                                    O(3 downto 0) <= std_logic_vector(unsigned(B) rol 1);
                                end if;                  
                            end if;
                            
            when "1001" =>  
                            if (rst = '1') then     -- Rotate right by one bit a chosen input
                                O <= (others => '0');
                            elsif (rising_edge(clk)) then 
                                if (in_sel = '0') then
                                    O(3 downto 0) <= std_logic_vector(unsigned(A) ror 1);      
                                else
                                    O(3 downto 0) <= std_logic_vector(unsigned(B) ror 1);
                                end if;                  
                            end if;
                            
            when "1010" =>  
                            if (rst = '1') then     -- Up Accumulator for a chosen input
                                temp <= "00000000";
                                O <= (others => '0'); 
                            elsif (rising_edge(clk)) then 
                                if (in_sel = '0') then
                                    temp <= temp + A; 
                                    O <= temp;
                                else
                                    temp <= temp + B;
                                    O <= temp;
                                end if; 
                            end if; 
                            
            when "1011" => O <= Mult_Out;   --Multiplication of inputs
            when others => O <= Div_Out;    --Division of inputs                                                                                                                   
        end case;
      end if;
    end process;  
end Behavioral;