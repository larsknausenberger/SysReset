
{REDUND_ERROR} FUNCTION_BLOCK UaSYSReset (*OPC UA method wrapper for SYSReset*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Mode : USINT;
		Delay : TIME;
	END_VAR
	VAR
		State : USINT;
		State_1 : USINT;
		UaSrv_MethodOperate_0 : UaSrv_MethodOperate;
		FirstCycleInState : BOOL;
		TON_Delay : TON;
	END_VAR
END_FUNCTION_BLOCK
