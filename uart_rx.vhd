-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Kateryna Zdebska (xzdebs00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
    signal data_cnt : std_logic_vector(3 downto 0);
    signal data_cnt_dmx_en : std_logic;
    signal clk_first_bit_cnt : std_logic_vector(4 downto 0);
    signal clk_first_bit_cnt_en : std_logic;
    signal mid_clk_cnt : std_logic_vector(4 downto 0);
    signal mid_clk_cnt_en : std_logic;
    signal validate : std_logic;
begin
    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        DIN => DIN,
        DATA_CNT => data_cnt,
        DATA_CNT_DMX_EN => data_cnt_dmx_en,
        CLK_FIRST_BIT_CNT => clk_first_bit_cnt,
        CLK_FIRST_BIT_CNT_EN => clk_first_bit_cnt_en,
        MID_CLK_CNT => mid_clk_cnt,
        MID_CLK_CNT_EN => mid_clk_cnt_en,
        DOUT_VLD => validate
    );

    DOUT_VLD <= validate;

    first_bit_clk_counter: process(CLK, RST, clk_first_bit_cnt_en, data_cnt_dmx_en)
    begin
        if RST = '1' or clk_first_bit_cnt_en = '0' then
                clk_first_bit_cnt <= "00000";
        elsif rising_edge(CLK) then
            if (clk_first_bit_cnt = "11000" and data_cnt_dmx_en = '1') then
                clk_first_bit_cnt <= "00001";
            else
                clk_first_bit_cnt <= clk_first_bit_cnt + 1;
            end if;
        end if; 
    end process;

    middle_clk_counter: process(CLK, RST, mid_clk_cnt_en, data_cnt_dmx_en)
    begin
        if RST = '1' or mid_clk_cnt_en = '0' then
            mid_clk_cnt <= "00000";
        elsif rising_edge(CLK) then
            if (mid_clk_cnt(4) = '1' and data_cnt_dmx_en = '1') then
                mid_clk_cnt <= "00001";
            else
                mid_clk_cnt <= mid_clk_cnt+1;
            end if;
        end if;     
    end process;

    data_counter: process(CLK, RST, mid_clk_cnt, data_cnt_dmx_en)
    begin
        if (RST = '1' or data_cnt_dmx_en = '0') then
            data_cnt <= "0000";
        elsif rising_edge(CLK) then
            if (mid_clk_cnt(4) = '1' and data_cnt_dmx_en = '1') then
                data_cnt <= data_cnt+1;
            end if;
        end if;     
    end process;

    dmx_reg: process(CLK, RST, mid_clk_cnt_en, validate, clk_first_bit_cnt_en, clk_first_bit_cnt, data_cnt_dmx_en, mid_clk_cnt, data_cnt)
    begin
        if (RST = '1' or (validate = '0' and mid_clk_cnt_en = '0' and clk_first_bit_cnt_en = '0') ) then
            DOUT <= "00000000";
        elsif rising_edge(CLK) then
            if clk_first_bit_cnt = "11000" or (mid_clk_cnt(4) = '1' and data_cnt_dmx_en = '1') then 
                case data_cnt is
                    when "0000" => DOUT(0) <= DIN;
                    when "0001" => DOUT(1) <= DIN;
                    when "0010" => DOUT(2) <= DIN;
                    when "0011" => DOUT(3) <= DIN;
                    when "0100" => DOUT(4) <= DIN;
                    when "0101" => DOUT(5) <= DIN;
                    when "0110" => DOUT(6) <= DIN;
                    when "0111" => DOUT(7) <= DIN;
                    when "1000" => DOUT <= "00000000";
                    when others =>  null;
                end case;
            end if;
        end if;
    end process;
end architecture;
