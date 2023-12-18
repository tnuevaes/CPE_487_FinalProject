IF (bt_eq = '1' and choice='1') THEN
	nx_acc <= acc ** operand;                   --Exponentiation, acc^operand
	nx_state <= SHOW_RESULT;

IF (bt_eq = '1' and choice='1') THEN
	nx_acc <= acc mod operand;                   --Modulo
	nx_state <= SHOW_RESULT;