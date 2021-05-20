library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity Top_Level_tb is
end;

architecture bench of Top_Level_tb is

  component Top_Level
      Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
             B : in STD_LOGIC_VECTOR (3 downto 0);
             clk : in STD_LOGIC;
             in_sel : in STD_LOGIC;
             rst : in STD_LOGIC;
             sel : in STD_LOGIC_VECTOR (3 downto 0);
             O : out STD_LOGIC_VECTOR (7 downto 0));
  end component;

  signal A: STD_LOGIC_VECTOR (3 downto 0);
  signal B: STD_LOGIC_VECTOR (3 downto 0);
  signal clk: STD_LOGIC;
  signal in_sel : STD_LOGIC;
  signal rst: STD_LOGIC;
  signal sel : STD_LOGIC_VECTOR (3 downto 0);
  signal O: STD_LOGIC_VECTOR (7 downto 0);

  constant clock_period: time := 10 ns;

begin

  uut: Top_Level port map ( A   => A,
                            B   => B,
                            clk => clk,
                            in_sel => in_sel,
                            rst => rst,
                            sel => sel,
                            O   => O );
                            
 clocking: process
  begin
      clk <= '0';
      wait for clock_period / 2;
      clk <= '1';
      wait for clock_period / 2;
  end process;                           

  stimulus: process
  begin
  wait for 100 ns;
  
    rst <= '0';
    A <= "0010"; --add
    B <= "1110";
    sel <= "0000";
    wait for 100 ns;
    
    rst <= '0';
    A <= "1101"; --sub
    B <= "1011";
    sel <= "0001";
    wait for 100 ns;
    
    A <= "1101";  --inc
    in_sel <= '0';
    sel <= "0010";
    wait for 100 ns;
    
    B <= "1100"; --dec
    in_sel <= '1';
    sel <= "0011";
    wait for 100 ns;
    
    A <= "1101"; --and
    B <= "1001";
    sel <= "0100";
    wait for 100 ns;
    
    A <= "1101"; --or
    B <= "1111";
    sel <= "0101";
    wait for 100 ns;
    
    A <= "1101"; --not but with B select
    in_sel <= '1';
    sel <= "0110";
    wait for 100 ns;
    
    rst <= '1'; --opposite with reset
    B <= "1011";
    in_sel <= '1';
    sel <= "0111";
    wait for 100 ns;
    
    rst <= '0'; --opposite without reset
    B <= "1011";
    in_sel <= '1';
    sel <= "0111";
    wait for 100 ns;
    
    rst <= '0'; --rot left
    A <= "1011";
    in_sel <= '0';
    sel <= "1000";
    wait for 100 ns;
    
    rst <= '0'; --rot right
    B <= "1011";
    in_sel <= '1';
    sel <= "1001";
    wait for 100 ns;
    
    rst <= '0'; --up accumulator
    A <= "0011";
    in_sel <= '0';
    sel <= "1010";
    wait for 100 ns;
    
    rst <= '0'; --multi
    A <= "0011";
    B <= "1011";
    sel <= "1011";
    wait for 100 ns;
    
    rst <= '0'; --div
    A <= "0011";
    B <= "1011";
    sel <= "1111";
    wait;
  end process;
end;