# CPE_487_FinalProject

## Teddy Nueva Espana, Sakthi Jayaraman, Jack Jimenez

I pledge my honor that I have abided by the Stevens Honor System

### Project Scope

- Study Lab 4 base code for calculator
- Implement additional features to calculator

### Expected Behavior

    - TBD


- Calculator with two operation buttons that change operations depending on the switches that are toggled.
- Calculator is able to continually do operations using the previous calculation result as the first operand.

### Base operations

- Addition
- Subtraction

- Including two operations required utilizing a signal that determines which button is pressed after the input of the first operand
- within _ENTER_ACC_, an IF statement exists that checks for whether BTNU or BTND is pressed, with the resulting THEN being to set the signal _choice_ to either 1 or 0, respectively, representing which button is pressed.

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
    - Squaring
    - Square Root (Non Restoring)

- Using library _IEEE.NUMERIC_STD.ALL_, the program is able to utilize additional arithmetic operators.
- The additional operators are used in the ENTER_OP case
  - Within each switch toggle IF statement, another IF statement is nested which tests for if the '=' button was pressed and refers to the choice signal, whether BTNU (choice = '1') or BTND (choice = '0') was pressed after the input of the first operand.

#### Implementing Multiplication

- Using the multiplication operator included in _IEEE.NUMERIC_STD.ALL_, the product of multiplying signals _acc_ and _operand_ would cause the product to be a different size than _acc_ , preventing the product from being stored in _acc_
- To remedy this problem, we used the resize function included within _STD_LOGIC_VECTOR_ to resize the product of the multiplication before being stored in _acc_
  
```vhdl
nx_acc <= STD_LOGIC_VECTOR(resize(unsigned(nx_acc)*unsigned(operand), 32));
```

- Doing this creates an issue with how the calculator deals with overflow, leading to certain multiplication cases being incorrect.

### Running Operations

#### Allow the calculator to perform running operations (Continuous operations based on previous computation results)

- Within each operation if statement, if kp_hit = '1' then nx_state is set to _OP_RELEASE_ which then goes to _ENTER_OP_ to check for kp_hit = '1'
- Created additional ELSIF statements in SHOW_RESULT case checking for whether BTNU (choice = '1') or BTND (choice = '0') was pressed after result is shown
- Set final state in _SHOW_RESULT_ case as the _START_OP_ case to begin new operation using the previous result stored in _nx_acc_