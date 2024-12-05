library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity top is
    Port (  Clock100MHz : in std_logic := '1';
            ADC_CLK : OUT STD_LOGIC := '0';
            ADC_CS : OUT STD_LOGIC := '1';
            ADC_DOUT : IN STD_LOGIC := '1';
            Button3 : in std_logic := '0';
            Segment_A, Segment_B, Segment_C, Segment_D, Segment_E, Segment_F, Segment_G : out std_logic := '1';
            Segment_DP, Segment_D1, Segment_D2, Segment_D3, Segment_D4, Segment_Dots : out std_logic := '1');
end top;

architecture Behavioral of top is

component debouncer is
    Port ( Clock100MHz : in std_logic := '1';
           trig : in STD_LOGIC := '0';
           output : out STD_LOGIC := '0');
end component debouncer;

component adc is
Port (  ADC_CLK : OUT STD_LOGIC := '0';
        ADC_CS : OUT STD_LOGIC := '1';
        ADC_DOUT : IN STD_LOGIC := '1';
        Enable : IN STD_LOGIC := '0';
        Clock : IN STD_LOGIC := '1';
        data : OUT STD_LOGIC_VECTOR(11 downto 0) := (others => '0'));
end component adc;

component binary_to_bcd is
port (  Clock : in std_logic := '1';
        data : in std_logic_vector(11 downto 0) := (others => '0');
        bcd0, bcd1, bcd2, bcd3 : out std_logic_vector(3 downto 0) := (others => '0'));
end component binary_to_bcd;

component bcd_to_7segment is
Port (  BCDin : in STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
        Seven_Segment : out STD_LOGIC_VECTOR (6 downto 0) := (others => '0'));
end component bcd_to_7segment;

signal trig : STD_LOGIC := '0';
signal output : STD_LOGIC := '0';
signal Enable : STD_LOGIC := '0';
signal Clock : STD_LOGIC := '1';
signal data : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');                         --12-bit vector signal for ADC data.
signal bcd0, bcd1, bcd2, bcd3 : std_logic_vector(3 downto 0) := (others => '0');       -- 4-bit vector signals for BCD representation of the data.
signal BCDin : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');                       --7-bit vector signal for driving the 7-segment display.
signal Seven_Segment : STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
signal licz : std_logic := '0';
signal licznik : integer := 0;
signal licznik2 : integer := 0;
begin
debouncer_com : debouncer port map (Clock100MHz => Clock100MHz,                        --This section of the VHDL code instantiates and connects the components within the top.vhd architecture:
                                    trig => trig,
                                    output => output);
adc_com : adc port map (    ADC_CLK => ADC_CLK,
                            ADC_CS => ADC_CS,
                            ADC_DOUT => ADC_DOUT,
                            Enable => Enable,
                            Clock => Clock,
                            data => data);
binary_bcd_comp : binary_to_bcd port map (  Clock => Clock,
                                            data => data,
                                            bcd0 => bcd0,
                                            bcd1 => bcd1,
                                            bcd2 => bcd2,
                                            bcd3 => bcd3);
bcd_7segment_comp : bcd_to_7segment port map (  BCDin => BCDin,
                                                Seven_Segment => Seven_Segment);
trig <= Button3;   --trig is assigned the value of Button3 (button input).
Enable <= output;  --Enable is assigned the value of output from the debouncer.
Segment_A <= Seven_Segment(6);  --The segments of the 7-segment display (Segment_A to Segment_G) are assigned the corresponding bits from the Seven_Segment signal.
Segment_B <= Seven_Segment(5);
Segment_C <= Seven_Segment(4);
Segment_D <= Seven_Segment(3);
Segment_E <= Seven_Segment(2);
Segment_F <= Seven_Segment(1);
Segment_G <= Seven_Segment(0);

process(Clock100MHz)
begin
    if (Clock100MHz'event and Clock100MHz = '1') then
        if (licznik = 1000) then      --zlicza do 1000
            Clock <= not Clock;
            licznik <= 0;  -- jak zliczy to sie zeruje
        else
            licznik <= licznik + 1;  --jak nnie zliczyl to sie inkementuje o 1
        end if;
    end if;
end process;

process(Clock, Enable)
begin
    if (Clock'event and Clock = '1') then  --The process is triggered on the rising edge of Clock.
        if (Enable = '1') then
            licz <= '0';
        elsif (licz = '0') then
            licz <= '1';
        end if;
    end if;
end process;

process(Clock, licz)
begin
    if (Clock'event and Clock = '1') then
        if (licz = '1') then
            if (licznik2 = 75) then
                licznik2 <= 0;
            else
                licznik2 <= licznik2 + 1;
            end if;
        else
            licznik2 <= 0;
        end if;
    end if;
end process;

process(Clock, licznik2)  --The value of licznik2 determines which segments are activated and which BCD digit is displayed.
begin
    if (Clock'event and Clock = '1') then 
        if (licznik2 = 35) then
            Segment_D1 <= '0';  --At count 35, the first display (Segment_D1) is updated.
            Segment_D2 <= '1';
            Segment_D3 <= '1';
            Segment_D4 <= '1';
            BCDin <= bcd3;
            Segment_DP <= '0';  --In the VHDL code, setting Segment_DP to '0' when licznik2 equals 35 turns on the decimal point for the first digit (Segment_D1). This indicates that the decimal point should be illuminated only when the first digit is active. The value '0' typically means the segment is on, depending on the display's common cathode or anode configuration.
            Segment_Dots <= '1';
        elsif (licznik2 = 45) then
            Segment_D1 <= '1';
            Segment_D2 <= '0';  --At count 45, the second display (Segment_D2) is updated.
            Segment_D3 <= '1';
            Segment_D4 <= '1';
            BCDin <= bcd2;
            Segment_DP <= '1';
            Segment_Dots <= '1';
        elsif (licznik2 = 55) then
            Segment_D1 <= '1';
            Segment_D2 <= '1';
            Segment_D3 <= '0'; --At count 55, the third display (Segment_D3) is updated.
            Segment_D4 <= '1';
            BCDin <= bcd1;
            Segment_DP <= '1';
            Segment_Dots <= '1';
        elsif (licznik2 = 65) then
            Segment_D1 <= '1';
            Segment_D2 <= '1';
            Segment_D3 <= '1';
            Segment_D4 <= '0';  --At count 65, the fourth display (Segment_D4) is updated.
            BCDin <= bcd0;
            Segment_DP <= '1';
            Segment_Dots <= '1';
        elsif (licznik2 = 75) then  --At count 75, the display resets, and the cycle restarts.
            Segment_D1 <= '1';
            Segment_D2 <= '1';
            Segment_D3 <= '1';
            Segment_D4 <= '1';
            BCDin <= (others => '0');
            Segment_DP <= '1';
            Segment_Dots <= '1';
        end if;
    end if;
end process;

end Behavioral;
