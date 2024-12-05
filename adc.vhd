library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adc is
Port (  ADC_CLK : OUT STD_LOGIC := '0';
        ADC_CS : OUT STD_LOGIC := '1';
        ADC_DOUT : IN STD_LOGIC := '1';
        Enable : IN STD_LOGIC := '0';
        Clock : IN STD_LOGIC := '1';
        data : OUT STD_LOGIC_VECTOR(11 downto 0) := (others => '0'));
end adc;

architecture Behavioral of adc is
    type stany is (idle, start, send, finished);
    signal stan, stan_nast : stany := idle;
    signal licznik : integer := 0;
    signal bufor : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal data_int : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
begin

process(Clock)
begin
    if (Clock'event and Clock = '1') then
        stan <= stan_nast;
    end if;
end process;
    
process(Clock, stan)
begin
    if (Clock'event and Clock = '1') then
        if (stan = start) then
            if (licznik = 3) then
                licznik <= 0;
            else
                licznik <= licznik + 1;
            end if;
        elsif (stan = send) then
            if (licznik = 10) then
                licznik <= 0;
            else
                licznik <= licznik + 1;
            end if;
        end if;
    end if;
end process;

process(stan, Clock)
begin
    case stan is
        when idle =>
            ADC_CLK <= '0';
            ADC_CS <= '1';
        when start =>
            ADC_CLK <= Clock;
            ADC_CS <= '0';
        when send =>
            ADC_CLK <= Clock;
            ADC_CS <= '0';
        when finished =>
            ADC_CLK <= '0';
            ADC_CS <= '1';
        when others =>
            ADC_CLK <= '0';
            ADC_CS <= '1';
    end case;
end process;

process(Clock, stan)
begin
    if (Clock'event and Clock = '1') then
        if (stan = send) then
            bufor <= bufor(10 downto 0) & ADC_DOUT;
        else
            bufor <= bufor;
        end if;
        if (stan = finished) then
            data_int <= bufor;
        else
            data_int <= data_int;
        end if;
    end if;
end process;

data <= data_int;
    
process(stan, Enable, licznik)
begin
    stan_nast <= stan;
    case stan is
        when idle =>
            if (Enable = '1') then
                stan_nast <= start;
            else
                stan_nast <= idle;
            end if;
        when start =>
            if (licznik = 3) then
                stan_nast <= send;
            else
                stan_nast <= start;
            end if;
        when send =>
            if (licznik = 10) then 
                stan_nast <= finished;
            else
                stan_nast <= send;
            end if;
        when finished =>
            stan_nast <= idle;
        when others =>
            stan_nast <= idle;
    end case;
end process;

end Behavioral;
