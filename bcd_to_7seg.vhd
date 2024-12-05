library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bcd_to_7segment is
Port (  BCDin : in STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
        Seven_Segment : out STD_LOGIC_VECTOR (6 downto 0) := (others => '0'));
end bcd_to_7segment;

architecture Behavioral of bcd_to_7segment is
begin

process(BCDin)  --converts a 4-bit Binary-Coded Decimal (BCD) input (BCDin) to a 7-segment display output
begin
    case BCDin is
        when "0000" =>
            Seven_Segment <= "0000001"; --0
        when "0001" =>
            Seven_Segment <= "1001111"; --1
        when "0010" =>
            Seven_Segment <= "0010010"; --2
        when "0011" =>
            Seven_Segment <= "0000110";
        when "0100" =>
            Seven_Segment <= "1001100";
        when "0101" =>
            Seven_Segment <= "0100100";
        when "0110" =>
            Seven_Segment <= "0100000";
        when "0111" =>
            Seven_Segment <= "0001111";
        when "1000" =>
            Seven_Segment <= "0000000";
        when "1001" =>
            Seven_Segment <= "0000100"; --9
        when others =>
            Seven_Segment <= "1111111"; --wylaczane
    end case;
end process;

end Behavioral;
