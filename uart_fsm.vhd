library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK        : in std_logic;
   RST        : in std_logic;
   DIN        : in std_logic;
   COUNTER    : in std_logic_vector(4 downto 0);
   STARTCNT   : in std_logic_vector(4 downto 0);
   BITS       : in std_logic_vector(3 downto 0);

   VLD        : out std_logic;
   OUTB       : out std_logic;
   STARTENB   : out std_logic;
   COUNTERENB : out std_logic
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
type STATE_TYPE is (START, WAIT_BIT, READ, WAIT_STOP, VALIDATE);
signal state : STATE_TYPE := START;
begin 
  
  -- Moore outputs
  OUTB <= '1' when state = READ
  else '0';

  VLD <= '1' when state = VALIDATE
  else '0';

  -- counter used for both states, but only READ enables write onto registers
  COUNTERENB <= '1' when state = READ or state = WAIT_STOP
  else '0';

  STARTENB <= '1' when state = WAIT_BIT
  else '0';
  

  process (CLK) begin 
    if rising_edge(CLK) then
      if RST = '1' then
        
        state <= START;
  
      else

          case state is
          
            when START => if DIN = '0' then
                            state <= WAIT_BIT;  
                          end if;                  
          
            when WAIT_BIT => if STARTCNT = "01000" then
                              state <= READ;  
                            end if;                     
                                  
            when READ => if BITS = "1000" then
                          state <= WAIT_STOP;
                        end if;                    
                                  
            when WAIT_STOP => if COUNTER = "01111" then
                              state <= VALIDATE; 
                            end if;
                                  
            when VALIDATE  => state <= START;
            

            -- fallback                      
            when others          => null;

          end case; 
      end if;
    end if;
  end process;
end behavioral;
