
(* OPC UA method wrapper for SYSReset *)
FUNCTION_BLOCK UaSYSReset
	
	(* set flag when entering new state *)
	FirstCycleInState	:= (State <> State_1);
	State_1	:= State;
	
	(* state-machine *)
	CASE State OF
		
		(* idle *)
		0, 255:
			State	:= 1;
		
		(* check if method is called *)	
		1:
			IF FirstCycleInState THEN
				UaSrv_MethodOperate_0.Action := UaMoa_CheckIsCalled;
				UaSrv_MethodOperate_0(Execute := FALSE);
				UaSrv_MethodOperate_0.MethodName	:= 'SysReset';
				UaSrv_MethodOperate_0.Execute		:= TRUE;
			END_IF
			
			UaSrv_MethodOperate_0();
			IF UaSrv_MethodOperate_0.Done THEN
				IF UaSrv_MethodOperate_0.IsCalled THEN
					State	:= 2;
				ELSE
					State	:= 0;
				END_IF
			ELSIF UaSrv_MethodOperate_0.Error THEN
				State	:= 255;
			END_IF
		
		(* confirm method call *)
		2:
			IF FirstCycleInState THEN
				UaSrv_MethodOperate_0.Action := UaMoa_Finished;
				UaSrv_MethodOperate_0(Execute := FALSE);
				UaSrv_MethodOperate_0.Execute		:= TRUE;
			END_IF
		
			UaSrv_MethodOperate_0();
			IF UaSrv_MethodOperate_0.Done THEN
				State	:= 3;
			ELSIF UaSrv_MethodOperate_0.Error THEN
				State	:= 255;
			END_IF
		
		(* delay SYSreset *)
		3:
			IF FirstCycleInState THEN
				TON_Delay(IN := FALSE);
				TON_Delay.PT	:= Delay;
				TON_Delay.IN	:= TRUE;
			END_IF
			
			TON_Delay();
			IF TON_Delay.Q THEN
				State	:= 4;
			END_IF
		
		(* call SYSreset *)
		4:
			SYSreset(enable := TRUE, mode := Mode);
			State	:= 0;
		
	END_CASE
	
END_FUNCTION_BLOCK
