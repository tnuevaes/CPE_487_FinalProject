LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY hexcalc IS
	PORT (
		clk_50MHz : IN STD_LOGIC; -- system clock (50 MHz)
		SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of four 7-seg displays
		SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0); -- common segments of 7-seg displays
		bt_clr : IN STD_LOGIC; -- calculator "clear" button
		bt_plus : IN STD_LOGIC; -- calculator "+" button
		bt_sub : IN STD_LOGIC; -- calculator "-" button
		bt_eq : IN STD_LOGIC; 
		KB_col : OUT STD_LOGIC_VECTOR (4 DOWNTO 1); -- keypad column pins
	    KB_row : IN STD_LOGIC_VECTOR (4 DOWNTO 1); -- keypad row pins
		SW0 : IN STD_LOGIC; -- initializing the first sw
		SW1 : IN STD_LOGIC); -- initializing the second sw
	   
END hexcalc;

ARCHITECTURE Behavioral OF hexcalc IS
	COMPONENT keypad IS
		PORT (
			samp_ck : IN STD_LOGIC;
			col : OUT STD_LOGIC_VECTOR (4 DOWNTO 1);
			row : IN STD_LOGIC_VECTOR (4 DOWNTO 1);
			value : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			hit : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT leddec16 IS
		PORT (
			dig : IN unsigned (2 DOWNTO 0);
			data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
	END COMPONENT;
	SIGNAL cnt : unsigned (20 DOWNTO 0); -- counter to generate timing signals
	SIGNAL kp_clk, kp_hit, sm_clk : std_logic;
	SIGNAL kp_value : std_logic_vector (3 DOWNTO 0);
	SIGNAL nx_acc, acc : std_logic_vector (31 DOWNTO 0); -- accumulated sum
	SIGNAL nx_operand, operand : std_logic_vector (31 DOWNTO 0); -- operand
	SIGNAL display : std_logic_vector (15 DOWNTO 0); -- value to be displayed
	SIGNAL led_mpx : unsigned (2 DOWNTO 0); -- 7-seg multiplexing clock
	TYPE state IS (ENTER_ACC, ACC_RELEASE, START_OP, OP_RELEASE, 
	ENTER_OP, SHOW_RESULT); -- state machine states
	SIGNAL pr_state, nx_state : state; -- present and next states
	SIGNAL choice: STD_LOGIC;
BEGIN
	ck_proc : PROCESS (clk_50MHz)
	BEGIN
		IF rising_edge(clk_50MHz) THEN -- on rising edge of clock
			cnt <= cnt + 1; -- increment counter
		END IF;
	END PROCESS;
	kp_clk <= cnt(15); -- keypad interrogation clock
	sm_clk <= cnt(20); -- state machine clock
	led_mpx <= cnt(19 DOWNTO 17); -- 7-seg multiplexing clock
	kp1 : keypad
	PORT MAP(
		samp_ck => kp_clk, col => KB_col, 
		row => KB_row, value => kp_value, hit => kp_hit
		);
		led1 : leddec16
		PORT MAP(
			dig => led_mpx, data => display, 
			anode => SEG7_anode, seg => SEG7_seg
		);
		sm_ck_pr : PROCESS (bt_clr, sm_clk) -- state machine clock process
		BEGIN
			IF bt_clr = '1' THEN -- reset to known state
				acc <= X"00000000";  
				operand <= X"00000000";
				pr_state <= ENTER_ACC;
			ELSIF rising_edge (sm_clk) THEN -- on rising clock edge
				pr_state <= nx_state; -- update present state
				acc <= nx_acc; -- update accumulator
				operand <= nx_operand; -- update operand
			END IF;
		END PROCESS;
		-- state maching combinatorial process
		-- determines output of state machine and next state
		sm_comb_pr : PROCESS (kp_hit, kp_value, bt_plus, bt_eq, acc, operand, pr_state)
		BEGIN
			nx_acc <= acc; -- Set value of nx_acc to initial keypress
			nx_operand <= operand; --Set value of nx_operant to value of second operand keypress
			display <= acc;
			CASE pr_state IS -- depending on present state...
				WHEN ENTER_ACC => -- waiting for next digit in 1st operand entry
					--Keep same logic
					IF kp_hit = '1' THEN
						nx_acc <= acc(11 DOWNTO 0) & kp_value; -- Set nx_acc to value of full number operand
						nx_state <= ACC_RELEASE;
					ELSIF bt_plus = '1' THEN  -- Choices
						nx_state <= START_OP;                                      -- FOR PROJECT: Nested if statements for multiple operations
						choice <= '1';
					ELSIF bt_sub ='1'then   -- Choices
					   nx_state <= START_OP;
					   choice <='0';
					ELSE
						nx_state <= ENTER_ACC;
					END IF;
				WHEN ACC_RELEASE => -- waiting for button to be released
					IF kp_hit = '0' THEN
						nx_state <= ENTER_ACC;
					ELSE nx_state <= ACC_RELEASE;
					END IF;
				WHEN START_OP => -- ready to start entering 2nd operand
					IF kp_hit = '1' THEN
						nx_operand <= X"000" & kp_value;
						nx_state <= OP_RELEASE;
						display <= operand;
					ELSE nx_state <= START_OP;
					END IF;
				WHEN OP_RELEASE => -- waiting for button ot be released
					display <= operand;
					IF kp_hit = '0' THEN
						nx_state <= ENTER_OP;
					ELSE nx_state <= OP_RELEASE;
					END IF;
				WHEN ENTER_OP => -- waiting for next digit in 2nd operand
					display <= operand;
					-- Only need to check here for SW0 and SW1 since we can use choice for different calculations
					-- Logic for Addition and Subtraction no switches on
					IF (SW0 = '0' AND SW1 = '0') THEN
						IF (bt_eq = '1' and choice='1') THEN
							nx_acc <= std_logic_vector(unsigned(acc) + unsigned(operand));
							nx_state <= SHOW_RESULT;
						ELSIF (bt_eq = '1'and choice= '0')then
						nx_acc <= std_logic_vector(unsigned(acc) - unsigned(operand));                                        -- FOR PROJECT: Nested if statements for multiple operations
						nx_state <= SHOW_RESULT;
						ELSIF kp_hit = '1' THEN
							nx_operand <= operand(11 DOWNTO 0) & kp_value;
							nx_state <= OP_RELEASE;
						ELSE nx_state <= ENTER_OP;
						END IF;
					ELSIF (SW0 = '1' AND SW1 = '0') THEN
					-- Logic for Multiplication and Division SW1 ON
						IF (bt_eq = '1' and choice='1') THEN
							nx_acc <= std_logic_vector(unsigned(acc) * unsigned(operand));
							nx_state <= SHOW_RESULT;
						ELSIF (bt_eq = '1'and choice= '0')then
							nx_acc <= std_logic_vector(unsigned(acc) / unsigned(operand));                                         
							nx_state <= SHOW_RESULT;
						ELSIF kp_hit = '1' THEN
							nx_operand <= operand(11 DOWNTO 0) & kp_value;
							nx_state <= OP_RELEASE;
						ELSE nx_state <= ENTER_OP;
						END IF;
					ELSIF (SW0 = '0' AND SW1 = '1') THEN
					-- Logic for Exponential and Modulo calculation
						IF (bt_eq = '1' and choice='1') THEN
							nx_acc <= std_logic_vector(unsigned(acc) rem unsigned(operand));                   --Exponentiation, acc^operand
							nx_state <= SHOW_RESULT;
						ELSIF (bt_eq = '1'and choice= '0')then
							nx_acc <= std_logic_vector(unsigned(acc) mod unsigned(operand));                   --Modulo
							nx_state <= SHOW_RESULT;
						ELSIF kp_hit = '1' THEN
							nx_operand <= operand(11 DOWNTO 0) & kp_value;
							nx_state <= OP_RELEASE;
						ELSE nx_state <= ENTER_OP;
						END IF;
					END IF;
				WHEN SHOW_RESULT => -- display result of addition
					IF kp_hit = '1' THEN
						nx_acc <= X"000" & kp_value;
						nx_state <= ACC_RELEASE;
					ELSE nx_state <= SHOW_RESULT;
					END IF;
			END CASE;
		END PROCESS;
END Behavioral;