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
    signal current_state : state_t := S_ASTEAPTA;
    signal next_state    : state_t;

    signal amount      : integer range 0 to 20 := 0;
    signal next_amount : integer range 0 to 20;

    constant PRICE0 : integer := 3;
    constant PRICE1 : integer := 5;

    constant V50  : integer := 1;
    constant V1L : integer := 2;
    constant V5L : integer := 10;
    constant MAX_AMOUNT : integer := 20;

    signal dispense_reg : std_logic_vector(1 downto 0) := "00";
    signal next_dispense : std_logic_vector(1 downto 0);
    
    signal change_out_reg: std_logic := '0';
    signal next_change_out: std_logic;
    
    signal change_type_reg: std_logic_vector(1 downto 0) := "00";
    signal next_change_type: std_logic_vector(1 downto 0);
    
    signal coin_reject_reg: std_logic := '0';
    signal next_coin_reject: std_logic;

begin

    dispense_prod <= dispense_reg;
    change_out    <= change_out_reg;
    change_type   <= change_type_reg;
    coin_reject   <= coin_reject_reg;

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            current_state <= S_ASTEAPTA;
            amount <= 0;
            dispense_reg <= "00";
            change_out_reg <= '0';
            change_type_reg <= "00";
            coin_reject_reg <= '0';
        elsif rising_edge(clk) then
            current_state <= next_state;
            amount <= next_amount;
            dispense_reg <= next_dispense;
            change_out_reg <= next_change_out;
            change_type_reg <= next_change_type;
            coin_reject_reg <= next_coin_reject;
        end if;
    end process;

    process(current_state, amount, coin_in, coin_valid, prod_sel, req_disp, req_change)
        variable coin_value : integer;
        variable selected_price : integer;
    begin
        next_state <= current_state;
        next_amount <= amount;
        next_dispense <= "00";
        next_change_out <= '0';
        next_change_type <= "00";
        next_coin_reject <= '0';

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

        case current_state is
            when S_ASTEAPTA | S_BANI =>
                if coin_valid = '1' and coin_value > 0 then
                    if amount + coin_value <= MAX_AMOUNT then
                        next_amount <= amount + coin_value;
                        next_state <= S_BANI;
                    else
                        next_coin_reject <= '1';
                    end if;
                end if;

                if req_disp = '1' then
                    if amount >= selected_price then
                        if prod_sel = '0' then
                            next_dispense <= "01";
                        else
                            next_dispense <= "10";
                        end if;
                        next_amount <= amount - selected_price;
                        next_state <= S_BANI;
                    else
                        next_dispense <= "00";
                    end if;
                end if;

                if req_change = '1' and amount > 0 then
                    next_state <= S_REST;
                end if;

            when S_REST =>
                if amount >= V1L then
                    next_change_out <= '1';
                    next_change_type <= "10";
                    next_amount <= amount - V1L;
                elsif amount >= V50 then
                    next_change_out <= '1';
                    next_change_type <= "01";
                    next_amount <= amount - V50;
                else
                    next_state <= S_ASTEAPTA;
                end if;

                if amount = 0 then
                    next_state <= S_ASTEAPTA;
                end if;

        end case;
    end process;

end Behavioral;