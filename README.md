# CPE_487_FinalProject

## Teddy Nueva Espana, Sakthi Jayaraman, Jack Jimenez

I pledge my honor that I have abided by the Stevens Honor System

### Project Scope

- Study Lab 4 base code for calculator
- Implement additional features to calculator

### Expected Behavior

- Calculator with two operation buttons that change operations depending on the switches that are toggled.
- Calculator is able to continually do operations using the previous calculation result as the first operand.

### Necessary Equipment

- Nexys A7-100T board
- 16-button keypad module (Pmod KYPD)

### Base operations
![image](https://github.com/tnuevaes/CPE_487_FinalProject/assets/78048229/cd6e9173-8d46-484b-9138-54759675cd5c)
Utilizing the already made FSM from Lab 4 we modified the model to perform run on operations by listensing for the bt_plus and bt_sub inputs in the Show_Result stage.
With this, the logic to reset the acc value was subverted and we were able to continuosly perform operations

- Files Modified:
  - Hexcalc.vhd

#### Addition

- Using the given addition code, the addition being done is hexadecimal addition

```vhdl
IF (SW0 = '0' AND SW1 = '0') THEN
    IF (bt_eq = '1' and choice='1') THEN
      nx_acc <= std_logic_vector(unsigned(acc) + unsigned(operand));
      nx_state <= SHOW_RESULT;
```

- Doing addition involves the conversion of the input values from hex to decimal, adding the decimal values, to produce a decimal result
  - i.e. 5 + 7 = **C** (12)
  - 25 + 6 = **2b** (37 (25 in dec) + 6 = 43 (2b in dec))
  - 295 + 15 = **2AA** (661 (295 in dec) + 21(15 in dec) = 682 (2aa in dec))
  - 3999 + 5 = **399E** (14745 + 5 = 14750 (399E in dec))
- The values are input as hex values, converted to decimal, added as decimal, and displayed as hex

#### Subtraction

- Using the given subtraction code, the subtraction being done is hexadecimal subtraction

```vhdl
ELSIF (bt_eq = '1'and choice= '0')then
  nx_acc <= std_logic_vector(unsigned(acc) - unsigned(operand));                                        
  nx_state <= SHOW_RESULT;
```

- Doing subtraction involves the conversion of the input values from hex to decimal, subtracting the decimal values, to produce a decimal result
  - i.e. 22 - 3 = 1F
  - 53 - 5 = **4E** (83 (_53 in dec_) - 5 = 78(4E in dec))

#### Multiple Ops

- Including two operations utilizes a signal determining which button is pressed after the input of the first operand
- within _ENTER_ACC_, an IF statement exists that checks for whether BTNU or BTND is pressed, with the resulting THEN being to set the signal _choice_ to either 1 or 0, respectively, representing which button is pressed.

### Slide Switch Toggle

#### Use slide switches to toggle between combinations of operations

    - Switch 0 off, Switch 1 off
      - BTNU = Addition Operation
      - BTND = Subtraction Operation
    - Switch 0 on, Switch 1 off
      - BTNU = Multiplication Operation
      - BTND = Division Operation
    - Switch 0 off, Switch 1 on
      - BTNU = Exponentiation Operation
      - BTND = Modulo Operation

This is utilized in the ENTER_OP case where an IF statement was included to test which switches were toggled.

### Additional operations

#### _After research on the topic of exponentiation in VHDL, it was found that there are certain difficulties with the operation of exponentiation such that including a function to achieve this operation would not allow the program to synthesize unless the number being exponentiated and the exponent were predetermined at synthesis. Additionally, the squaring and square root functions could not be implemented due to the nature of multiplication within vhdl_

    - Multiplication
    - Division
    - Modulo
    - Remainder
    - Squaring
    - Square Root (Non Restoring)

- Using library _IEEE.NUMERIC_STD.ALL_, the program is able to utilize additional arithmetic operators.
- The additional operators are used in the ENTER_OP case
  - Within each switch toggle IF statement, another IF statement is nested which tests for if the '=' button was pressed and refers to the choice signal, whether BTNU (choice = '1') or BTND (choice = '0') was pressed after the input of the first operand.

#### Multiplication

- Using the multiplication operator included in _IEEE.NUMERIC_STD.ALL_, the product of multiplying signals _acc_ and _operand_ would cause the product to be a different size than _acc_ , preventing the product from being stored in _acc_
- To remedy this problem, we used the resize function included within _STD_LOGIC_VECTOR_ to resize the product of the multiplication before being stored in _acc_
  
```vhdl
ELSIF (SW0 = '1' AND SW1 = '0') THEN
        -- Logic for Multiplication and Division SW0 ON
          IF (bt_eq = '1' and choice='1') THEN
            nx_acc <= std_logic_vector(resize(unsigned(acc) * unsigned(operand),nx_acc'length));
            nx_state <= SHOW_RESULT;
```

- Implementing multiplication involves the * operand which does multiplication in the same way as previous operations.
  - Doing multiplication involves the conversion of the input values from hex to decimal, multiplying  the decimal values, to produce a decimal result
    - i.e. 25 * 2 = **4A** (37 (25 in dec)* 2 = 74 (*4A** in dec))
    - 38 * 17 = **508** (56 (38 in dec) * 23 (17 in dec) = 1288 (508 in dec))

#### Division

- Implementing division involves the / operand which does multiplication in the same way as previous operations.

```vhdl
ELSIF (SW0 = '1' AND SW1 = '0') THEN
-- Logic for Multiplication and Division SW0 ON
  IF (bt_eq = '1' and choice='1') THEN
    nx_acc <= std_logic_vector(resize(unsigned(acc) * unsigned(operand),nx_acc'length));
    nx_state <= SHOW_RESULT;
  ELSIF (bt_eq = '1'and choice= '0')then
    nx_acc <= std_logic_vector(unsigned(acc) / unsigned(operand));                                         
    nx_state <= SHOW_RESULT;
  ELSIF kp_hit = '1' THEN
    nx_operand <= operand(27 DOWNTO 0) & kp_value;
    nx_state <= OP_RELEASE;
  ELSE nx_state <= ENTER_OP;
  END IF;
```

- Doing multiplication involves the conversion of the input values from hex to decimal, multiplying  the decimal values, to produce a decimal result
  - i.e. 25 / 2 = **12** (37 (25 in dec) / 2 = 74 (**12** in dec))
  - 45 / 5 = **d** (69 / 5 = 13 (**d**  in dec))
- Our division implementation truncates results that involve decimal points
- Because of this function we implemented modulo and remainder to check a division operation for remainders.

#### Modulo / Remainder

- Implementing Modulo and Remainder involves the MOD and REM operand respectively which finds the remainder of a division of two hexadecimal numbers

```vhdl
ELSIF (SW0 = '0' AND SW1 = '1') THEN
        -- Logic for Remainder and Modulo calculation SW1 ON
          IF (bt_eq = '1' and choice='1') THEN
            nx_acc <= std_logic_vector(unsigned(acc) rem unsigned(operand));          --remainder
            nx_state <= SHOW_RESULT;                                              
          ELSIF (bt_eq = '1'and choice= '0')then
            nx_acc <= std_logic_vector(unsigned(acc) mod unsigned(operand));           --Modulo
            nx_state <= SHOW_RESULT;             
          ELSIF kp_hit = '1' THEN
            nx_operand <= operand(27 DOWNTO 0) & kp_value;
            nx_state <= OP_RELEASE;
          ELSE nx_state <= ENTER_OP;
          END IF;
```

- Doing modulo and remainder involves the conversion of the input values from hex to decimal, multiplying  the decimal values, to produce a decimal result
  - i.e. 23 mod 5 = **0** (35 (23 in dec) / 5 = 7, no rem )
  - 34 rem 8 = **4** (52 (34 in dec)/ 8 = 6.5, rem = 4)

### Running Operations

#### Allow the calculator to perform running operations (Continuous operations based on previous computation results)

- Within each operation if statement, if kp_hit = '1' then nx_state is set to _OP_RELEASE_ which then goes to _ENTER_OP_ to check for kp_hit = '1'
- Created additional ELSIF statements in SHOW_RESULT case checking for whether BTNU (choice = '1') or BTND (choice = '0') was pressed after result is shown
- Set final state in _SHOW_RESULT_ case as the _START_OP_ case to begin new operation using the previous result stored in _nx_acc_

```vhdl
WHEN SHOW_RESULT => -- display result of addition
  IF kp_hit = '1' THEN
    nx_acc <= X"0000000" & kp_value;
    nx_state <= ACC_RELEASE;
    -- Change nx_state to OP_RELEASE which then goes to ENTER_OP to check for kp_hit 1
  ELSIF bt_plus = '1' THEN
    choice <= '1';
    nx_state <= START_OP;
  ELSIF bt_sub = '1' THEN
    choice <= '0';
    nx_state <= START_OP; 
  ELSE nx_state <= SHOW_RESULT;
```


### Project Summary

- At first, this project seemed to be a simple set of modifications to the existing lab 4 calculator. After actually trying to implement the functions we wanted, we realized that the process is signifcantly more involved. Once we figured out that the calculator would be doing all of the operations in hexadecimal, it made understanding the code much easier.
- Everyone in the group had significant contributions to the overall project. All members contributed to the implementation of switch functions and additional operations. Teddy was responsible for managing the github repository,compiling the code and error checking all of the functions to ensure proper function of the project because only one board was available to our group.
- The project timeline began with researching what functions other calculators may have and what operations are feasible and implementable into a vhdl project. During the research phase, it was found that there were certain operations such as exponentiation that would simply be unsynthesizable without defining the input values at the time of synthesis. This meant that exponentiation would not be able to be included in the project. Other issues came with making sure that the newly implemented calculator functions worked properly such as the multiplication needing to be resized to fit the calculator. Moving forward, a potential function that could be implemented would be converting and displaying decimal calculations. We encountered issues in the forms of understanding the method of calculation that produced the results on the calculator display. Understanding the hexadecimal calculator proved to be crucial to the development of our project. When doing error checking on the functions, after understanding the methods of calculation set by the code, the project seemed to work as intended.
