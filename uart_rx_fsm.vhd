-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author: Kateryna Zdebska (xzdebs00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity UART_RX_FSM is
    port(
       CLK : in std_logic;
       RST : in std_logic;
       DIN : in std_logic;
       DATA_CNT : in std_logic_vector(3 downto 0);
       DATA_CNT_DMX_EN : out std_logic;
       CLK_FIRST_BIT_CNT : in std_logic_vector(4 downto 0);
       CLK_FIRST_BIT_CNT_EN : out std_logic;
       MID_CLK_CNT : in std_logic_vector(4 downto 0);
       MID_CLK_CNT_EN : out std_logic;
       DOUT_VLD : out std_logic
    );
end entity;



architecture behavioral of UART_RX_FSM is
    type state_type is (WAITING_FOR_THE_START_BIT, WAITING_FOR_THE_FIRST_BIT, READING_DATA, WAITING_FOR_THE_STOP_BIT, VALIDATION);
    signal current_state : state_type := WAITING_FOR_THE_START_BIT;
begin
    state_change: process (CLK, RST, DIN, DATA_CNT) 
    begin
        if (RST = '1') then
            current_state <= WAITING_FOR_THE_START_BIT;
        elsif rising_edge(CLK) then
            case current_state is
                when WAITING_FOR_THE_START_BIT =>
                    if DIN='0' then
                        current_state <= WAITING_FOR_THE_FIRST_BIT;
                    end if;
                when WAITING_FOR_THE_FIRST_BIT =>
                    if CLK_FIRST_BIT_CNT="11000" then --24 clk
                        current_state <= READING_DATA;
                    end if;
                when READING_DATA =>
                    if MID_CLK_CNT="1111" and DATA_CNT = "1000" then 
                        current_state <= WAITING_FOR_THE_STOP_BIT;
                    end if;
                when WAITING_FOR_THE_STOP_BIT =>
                    if DIN='1' then
                        current_state <= VALIDATION;
                    end if;
                when VALIDATION =>
                    current_state <= WAITING_FOR_THE_START_BIT;
                when others => 
                    null;
            end case;
        end if;
    end process;

    output: process(DIN, current_state)
	begin
	    case current_state is
	        when WAITING_FOR_THE_START_BIT =>
                DOUT_VLD <= '0';
                CLK_FIRST_BIT_CNT_EN <= '0';
	            MID_CLK_CNT_EN <= '0';
	            DATA_CNT_DMX_EN <= '0';
	        when WAITING_FOR_THE_FIRST_BIT =>
                DOUT_VLD <= '0';
                CLK_FIRST_BIT_CNT_EN <= '1';
                MID_CLK_CNT_EN <= '1';
	            DATA_CNT_DMX_EN <= '0';
	        when READING_DATA =>
                DOUT_VLD <= '0';
                CLK_FIRST_BIT_CNT_EN <= '0';
                MID_CLK_CNT_EN <= '1';
	            DATA_CNT_DMX_EN <= '1';
	        when WAITING_FOR_THE_STOP_BIT =>
                DOUT_VLD <= '0';
                CLK_FIRST_BIT_CNT_EN <= '0';
                MID_CLK_CNT_EN <= '1';
	            DATA_CNT_DMX_EN <= '0';
	        when VALIDATION =>
                DOUT_VLD <= '1';
                CLK_FIRST_BIT_CNT_EN <= '0';
	            MID_CLK_CNT_EN <= '0';
	            DATA_CNT_DMX_EN <= '0';
	    end case;
	end process;
end architecture;