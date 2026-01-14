library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vending_machine_tb is
end vending_machine_tb;

architecture tb of vending_machine_tb is
    signal clk    : std_logic := '0';
    signal rst_n  : std_logic := '0';
    signal coin_in: std_logic_vector(2 downto 0) := (others => '0');
    signal coin_valid: std_logic := '0';
    signal prod_sel: std_logic := '0';
    signal req_disp: std_logic := '0';
    signal req_change: std_logic := '0';
    signal dispense_prod: std_logic_vector(1 downto 0);
    signal change_out: std_logic;
    signal change_type: std_logic_vector(1 downto 0);
    signal coin_reject: std_logic;

    constant clk_period : time := 10 ns;

begin
    vending: entity work.vending_machine
        port map(
            clk => clk,
            rst_n => rst_n,
            coin_in => coin_in,
            coin_valid => coin_valid,
            prod_sel => prod_sel,
            req_disp => req_disp,
            req_change => req_change,
            dispense_prod => dispense_prod,
            change_out => change_out,
            change_type => change_type,
            coin_reject => coin_reject
        );
        
    clk_proc: process
    begin
        while now < 2000 ns loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    tb_proc: process
    begin
        rst_n <= '0';
        wait for 25 ns;
        rst_n <= '1';

        -- Sync to falling edge to avoid race conditions
        wait until falling_edge(clk);

        -- Pune 1 leu + 50b
        coin_in <= "010"; coin_valid <= '1';
        wait for clk_period;
        coin_in <= "001"; coin_valid <= '1'; -- 50b
        wait for clk_period;
        coin_valid <= '0'; coin_in <= "000";
        wait for clk_period;

        -- Cumpara prod0
        prod_sel <= '0'; req_disp <= '1';
        wait for clk_period;
        req_disp <= '0';

        wait for 20 ns;
        rst_n <= '0';
        wait for 25 ns;
        rst_n <= '1';
        
        wait until falling_edge(clk);

        -- Pune 5 lei
        coin_in <= "100"; coin_valid <= '1'; -- 5 lei
        wait for clk_period;
        coin_valid <= '0'; coin_in <= "000";
        wait for clk_period;
        
        -- Cumpara prod1
        prod_sel <= '1'; req_disp <= '1';
        wait for clk_period;
        req_disp <= '0';

        -- Cere restul
        wait for clk_period;
        req_change <= '1';
        wait for 100 ns; -- Asteapta mai multe cicluri pentru rest
        req_change <= '0';

        wait for 20 ns;
        rst_n <= '0';
        wait for 25 ns;
        rst_n <= '1';
        
        wait until falling_edge(clk);

        -- Incearca sa depaseasca suma maxima
        wait for clk_period;
        coin_in <= "100"; coin_valid <= '1';
        wait for clk_period;
        coin_valid <= '1'; coin_in <= "010";
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;
        -- Am atins suma maxima, urmatoarele monede trebuie respinse
        wait for clk_period;
        wait for clk_period;

        wait;
    end process;

end tb;