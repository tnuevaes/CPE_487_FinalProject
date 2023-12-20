# CPE_487_FinalProject

## Teddy Nueva Espana, Sakthi Jayaraman, Jack Jimenez

I pledge my honor that I have abided by the Stevens Honor System

### Project Scope

- Study Lab 4 base code for calculator
- Implement additional features to calculator

## Expected Behavior

  - Calculator with two operation buttons that change operations depending on the switches that are toggled.
  - Calculator is able to continually do operations using the previous calculation result as the first operand.

### Base operations

  - Addition
  - Subtraction

### Slide Switch Toggle

#### Use slide switches to toggle between addition and subtraction operations

    - Switch 0
      - BTNU = Addition Operation
      - BTND = Subtraction Operation
    - Switch 1
      - BTNU = Multiplication Operation
      - BTND = Division Operation
    - Switch 2
      - BTNU = Exponentiation Operation
      - BTND = Modulo Operation 

This is utilized in the ENTER_OP case where an IF statement was included to test which switches were toggled.

### Additional operations

#### _After research on the topic of exponentiation in VHDL, it was found that there are certain difficulties with the operation of exponentiation such that including a function to achieve this operation would not allow the program to synthesize unless the number being exponentiated and the exponent were predetermined at synthesis_

    - Multiplication
    - Division
    - Modulo
    - Remainder

- Using library IEEE.NUMERIC_STD.ALL, the program is able to utilize additional arithmetic operators.
- The additional operators are used in the ENTER_OP case
  - Within each switch toggle IF statement, another IF statement is nested which tests for if the '=' button was pressed and checks whether BTNU (choice = '1') or BTND (choice = '0') was pressed after the input of the first operand. 

### Running Operations

#### Allow the calculator to perform running operations (Continuous operations based on previous computation results)

- Within each operation if statement, if kp_hit = '1' then nx_state is set to OP_RELEASE which then goes to ENTER_OP to check for kp_hit = '1'
- Created additional ELSIF statements in SHOW_RESULT case checking for whether BTNU (choice = '1') or BTND (choice = '0') was pressed after result is shown
- Set final state in SHOW_RESULT case as the START_OP case to begin new operation using the previous result stored in nx_acc