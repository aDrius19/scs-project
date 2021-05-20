library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity division is
    Port ( A: in std_logic_vector(3 downto 0);
           B: in std_logic_vector(3 downto 0);
           Q: out std_logic_vector(3 downto 0);
           R: out std_logic_vector(3 downto 0));
end division;

architecture Behavioral of division is
signal sigA, sigB, sigQ, sigR: unsigned(3 downto 0);

begin 

  sigA <= unsigned(A);
  sigB <= unsigned(B);

  -- the division
  sigQ <= sigA / sigB;
  sigR <= sigA rem sigB;

  Q <= std_logic_vector(sigQ);
  R <= std_logic_vector(sigR); 
  
end Behavioral;