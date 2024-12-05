library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity binary_to_bcd is
port (  Clock : in std_logic := '1';
        data : in std_logic_vector(11 downto 0) := (others => '0');
        bcd0, bcd1, bcd2, bcd3 : out std_logic_vector(3 downto 0) := (others => '0'));
end binary_to_bcd ;

architecture behaviour of binary_to_bcd is
    type stany is (start, shift, finished);
    signal stan, stan_nast: stany := start;
    signal binary, binary_next: std_logic_vector(11 downto 0) := (others => '0');
    signal bcds, bcds_reg, bcds_next: std_logic_vector(15 downto 0) := (others => '0');
    signal bcds_out_reg, bcds_out_reg_next: std_logic_vector(15 downto 0) := (others => '0');
    signal shift_counter, shift_counter_next: natural range 0 to 12 := 0;
begin

process(Clock)
begin
    if (Clock'event and Clock = '1') then
        binary <= binary_next;
        bcds <= bcds_next;
        stan <= stan_nast;
        bcds_out_reg <= bcds_out_reg_next;
        shift_counter <= shift_counter_next;
    end if;
end process;

process(stan, binary, data, bcds, bcds_reg, shift_counter)
begin
    stan_nast <= stan;
    bcds_next <= bcds;
    binary_next <= binary;
    shift_counter_next <= shift_counter;
    case stan is
        when start =>
            stan_nast <= shift;
            binary_next <= data;
            bcds_next <= (others => '0');
            shift_counter_next <= 0;
        when shift =>
            if shift_counter = 12 then
                stan_nast <= finished;
            else
                binary_next <= binary(10 downto 0) & '0';
                bcds_next <= bcds_reg(14 downto 0) & binary(11);
                shift_counter_next <= shift_counter + 1;
            end if;
        when finished =>
            stan_nast <= start;
    end case;
end process;

bcds_reg(15 downto 12) <= bcds(15 downto 12) + 3 when bcds(15 downto 12) > 4 else bcds(15 downto 12);
bcds_reg(11 downto 8) <= bcds(11 downto 8) + 3 when bcds(11 downto 8) > 4 else bcds(11 downto 8);
bcds_reg(7 downto 4) <= bcds(7 downto 4) + 3 when bcds(7 downto 4) > 4 else bcds(7 downto 4);
bcds_reg(3 downto 0) <= bcds(3 downto 0) + 3 when bcds(3 downto 0) > 4 else bcds(3 downto 0);
bcds_out_reg_next <= bcds when stan = finished else bcds_out_reg;
bcd3 <= bcds_out_reg(15 downto 12);
bcd2 <= bcds_out_reg(11 downto 8);
bcd1 <= bcds_out_reg(7 downto 4);
bcd0 <= bcds_out_reg(3 downto 0);

end behaviour;
