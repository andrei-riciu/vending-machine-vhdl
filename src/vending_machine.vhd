library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vending_machine is
    Port (
        clk           : in  std_logic;
        rst_n         : in  std_logic;
        
        coin_in       : in  std_logic_vector(2 downto 0);
        coin_valid    : in  std_logic;
        prod_sel      : in  std_logic;
        req_disp      : in  std_logic;
        req_change    : in  std_logic;
        
        dispense_prod : out std_logic_vector(1 downto 0);
        change_out    : out std_logic;
        change_type   : out std_logic_vector(1 downto 0);
        coin_reject   : out std_logic
    );
end vending_machine;

architecture Behavioral of vending_machine is
    type state_t is (S_ASTEAPTA, S_BANI, S_REST);
    signal state : state_t := S_ASTEAPTA;

    signal amount : integer range 0 to 20 := 0;

    constant PRICE0 : integer := 3;
    constant PRICE1 : integer := 5;

    constant V50  : integer := 1;
    constant V1L : integer := 2;
    constant V5L : integer := 10;
    constant MAX_AMOUNT : integer := 20;

    signal dispense_reg : std_logic_vector(1 downto 0) := "00";
    signal change_out_reg: std_logic := '0';
    signal change_type_reg: std_logic_vector(1 downto 0) := "00";
    signal coin_reject_reg: std_logic := '0';

begin

    dispense_prod <= dispense_reg;
    change_out    <= change_out_reg;
    change_type   <= change_type_reg;
    coin_reject   <= coin_reject_reg;

    process(clk, rst_n)
        variable coin_value : integer := 0;
        variable selected_price : integer := 0;
    begin
        if rst_n = '0' then
            state <= S_ASTEAPTA;
            amount <= 0;
            dispense_reg <= "00";
            change_out_reg <= '0';
            change_type_reg <= "00";
            coin_reject_reg <= '0';
        elsif rising_edge(clk) then
            dispense_reg <= "00";
            change_out_reg <= '0';
            change_type_reg <= "00";
            coin_reject_reg <= '0';

            coin_value := 0;
            if coin_valid = '1' then
                if coin_in = "001" then
                    coin_value := V50;
                elsif coin_in = "010" then
                    coin_value := V1L;
                elsif coin_in = "100" then
                    coin_value := V5L;
                end if;
            end if;
            
            if prod_sel = '0' then
                selected_price := PRICE0;
            else
                selected_price := PRICE1;
            end if;

            case state is
                when S_ASTEAPTA | S_BANI =>
                    if coin_valid = '1' and coin_value > 0 then
                        if amount + coin_value <= MAX_AMOUNT then
                            amount <= amount + coin_value;
                            state <= S_BANI;
                        else
                            coin_reject_reg <= '1';
                        end if;
                    end if;

                    if req_disp = '1' then
                        if amount >= selected_price then
                            if prod_sel = '0' then
                                dispense_reg <= "01";
                            else
                                dispense_reg <= "10";
                            end if;
                            amount <= amount - selected_price;
                            state <= S_BANI;
                        else
                            dispense_reg <= "00";
                        end if;
                    end if;

                    if req_change = '1' and amount > 0 then
                        state <= S_REST;
                    end if;

                when S_REST =>
                    if amount >= V1L then
                        change_out_reg <= '1';
                        change_type_reg <= "10";
                        amount <= amount - V1L;
                    elsif amount >= V50 then
                        change_out_reg <= '1';
                        change_type_reg <= "01";
                        amount <= amount - V50;
                    else
                        state <= S_ASTEAPTA;
                    end if;

                    if amount = 0 then
                        state <= S_ASTEAPTA;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;
