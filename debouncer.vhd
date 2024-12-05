library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer is
    Port ( Clock100MHz : in std_logic := '1';
           trig : in STD_LOGIC := '0';
           output : out STD_LOGIC := '0');
end debouncer;

architecture Behavioral of debouncer is
type stany is (stabilny, niestabilny, opoznienie);
signal stan, stan_nast : stany := stabilny;
signal delay : integer := 0;
signal delay2 : integer := 0;

begin

reg : process(Clock100MHz)
begin
    if (Clock100MHz'event and Clock100MHz = '1') then
        stan <= stan_nast;
    end if;
end process reg;

komb : process(stan, delay, delay2, trig)
begin
    case stan is
        when stabilny =>
            if (trig = '1') then
                stan_nast <= opoznienie;
            else
                stan_nast <= stabilny;
            end if;
        when opoznienie =>
            if (trig = '1') then
                if (delay = 10000) then
                    stan_nast <= niestabilny;
                else
                    stan_nast <= opoznienie;
                end if;
            else
                stan_nast <= stabilny;
            end if;
        when niestabilny =>
            if (delay2 = 500000) then
                stan_nast <= stabilny;
            else
                stan_nast <= niestabilny;
            end if;
        when others =>
            stan_nast <= stabilny;
    end case;
end process komb;

licznik : process(Clock100MHz)
begin
    if (Clock100MHz'event and Clock100MHz = '1') then
        if (stan = opoznienie) then
            delay <= delay + 1;
            if (delay = 10000) then
                delay <= 0;
            end if;
        elsif (stan = niestabilny) then
            delay2 <= delay2 + 1;
            if (delay2 = 500000) then
                delay2 <= 0;
            end if;
        else
            delay <= 0;
            delay2 <= 0;
        end if;
    end if;
end process licznik;

wy : process(stan)
begin
    case stan is
        when stabilny =>
            output <= '0';
        when opoznienie =>
            output <= '1';
        when niestabilny =>
            output <= '0';
        when others =>
            output <= '0';
    end case;
end process wy;

end Behavioral;
