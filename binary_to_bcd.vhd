library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity binary_to_bcd is
port (  Clock : in std_logic := '1';
        data : in std_logic_vector(11 downto 0) := (others => '0');
        bcd0, bcd1, bcd2, bcd3 : out std_logic_vector(3 downto 0) := (others => '0'));  --4-bit BCD outputs representing the converted binary input.
end binary_to_bcd ;

architecture behaviour of binary_to_bcd is
    type stany is (start, shift, finished);
    signal stan, stan_nast: stany := start;
    signal binary, binary_next: std_logic_vector(11 downto 0) := (others => '0');
    signal bcds, bcds_reg, bcds_next: std_logic_vector(15 downto 0) := (others => '0');
    signal bcds_out_reg, bcds_out_reg_next: std_logic_vector(15 downto 0) := (others => '0');
    signal shift_counter, shift_counter_next: natural range 0 to 12 := 0;
begin

process(Clock)  --This process ensures that the state machine and data registers are updated synchronously with the clock, driving the binary to BCD conversion logic.
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
    stan_nast <= stan;  --stan_nast is set to the current state stan.
    bcds_next <= bcds;  --bcds_next, binary_next, shift_counter_next are set to their current values.
    binary_next <= binary;
    shift_counter_next <= shift_counter;
    case stan is
        when start =>
            stan_nast <= shift; --Transition to shift.
            binary_next <= data; --Initialize binary_next with data.
            bcds_next <= (others => '0'); --Reset bcds_next to zeros.
            shift_counter_next <= 0; --Reset shift_counter_next to 0.
        when shift =>  --Performs the bit-shifting and BCD adjustment.
            if shift_counter = 12 then  --If shift_counter equals 12, transition to finished.
                stan_nast <= finished;
            else
                binary_next <= binary(10 downto 0) & '0';  --Otherwise, shift binary left by 1 bit and append '0'.
                bcds_next <= bcds_reg(14 downto 0) & binary(11); --Update bcds_next by shifting left and appending the MSB of binary.
                shift_counter_next <= shift_counter + 1; --Increment shift_counter_next.
            end if;
        when finished =>  --Transition back to start.
            stan_nast <= start;
    end case;
end process;

bcds_reg(15 downto 12) <= bcds(15 downto 12) + 3 when bcds(15 downto 12) > 4 else bcds(15 downto 12); --Each 4-bit segment of bcds is checked if it is greater than 4. If so, 3 is added to it.
bcds_reg(11 downto 8) <= bcds(11 downto 8) + 3 when bcds(11 downto 8) > 4 else bcds(11 downto 8);
bcds_reg(7 downto 4) <= bcds(7 downto 4) + 3 when bcds(7 downto 4) > 4 else bcds(7 downto 4);
bcds_reg(3 downto 0) <= bcds(3 downto 0) + 3 when bcds(3 downto 0) > 4 else bcds(3 downto 0);
bcds_out_reg_next <= bcds when stan = finished else bcds_out_reg;
bcd3 <= bcds_out_reg(15 downto 12);
bcd2 <= bcds_out_reg(11 downto 8);
bcd1 <= bcds_out_reg(7 downto 4);
bcd0 <= bcds_out_reg(3 downto 0);

end behaviour;
