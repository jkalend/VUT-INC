-- uart.vhd: UART controller - receiving part
-- Author(s): Jan Kalenda (xkalen07)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-------------------------------------------------
entity UART_RX is
port(	
  CLK      : in std_logic;
	RST      : in std_logic;
	DIN      : in std_logic;
	DOUT     : out std_logic_vector(7 downto 0);
	DOUT_VLD : out std_logic
);
end UART_RX;   

-------------------------------------------------
architecture behavioral of UART_RX is
signal counter    : std_logic_vector(4 downto 0):= "00001" ;
signal bits       : std_logic_vector(3 downto 0):= "0000" ;
signal startcnt   : std_logic_vector(4 downto 0):= "00001" ;
signal vld        : std_logic := '0';
signal outb       : std_logic := '0';
signal startenb   : std_logic := '0';
signal counterenb : std_logic := '0';


begin
  
  -- FSM
  FSM: entity work.UART_FSM(behavioral)
    port map (
        CLK             => CLK,
        RST             => RST,
        DIN             => DIN,
        COUNTER         => counter,
        BITS            => bits, -- bit counter
        STARTCNT        => startcnt, -- counter for the start_bit
        VLD             => vld, -- VLD from FSM
        OUTB            => outb, -- signal to write on DOUT
        STARTENB        => startenb,
        COUNTERENB      => counterenb
    );
  
    
    process(CLK) begin
      if rising_edge(CLK) then

        if RST = '1' then
          DOUT <= "00000000"; -- DOUT nullified on reset
        end if;
        
        --for every 16 CLK cycles
        if counterenb = '1' then
          counter <= counter + "1";
        else
          counter <= "00001"; -- resets the counter
        end if;
        
        -- waits for the first bit
        if startenb = '1' then
           startcnt <= startcnt + "1";
        else
          startcnt <="00001";
        end if;
       
        if outb = '1' then
          if counter = "10000" then
            counter <= "00001";
            
            case bits is
              when "0000" => DOUT(0) <= DIN;
              when "0001" => DOUT(1) <= DIN;
              when "0010" => DOUT(2) <= DIN;
              when "0011" => DOUT(3) <= DIN;
              when "0100" => DOUT(4) <= DIN;
              when "0101" => DOUT(5) <= DIN;
              when "0110" => DOUT(6) <= DIN;
              when "0111" => DOUT(7) <= DIN;
              when others => null;
            end case;
          
            bits <= bits + "1";   
            
          end if;    
          
      else
        bits <= "0000";
      end if;

      DOUT_VLD <= '0'; -- DOUT_VLD is 0 by default

      if vld = '1' and DIN = '1' then
          DOUT_VLD <= '1';
        end if;
      
  end if;
  
end process;

end behavioral;
