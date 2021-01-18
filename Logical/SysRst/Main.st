
PROGRAM _INIT

	TOF_Vdc24Ok.PT	:= T#0.05s;	//delay shutdown
	
END_PROGRAM

PROGRAM _CYCLIC
	
	TOF_Vdc24Ok(IN := diVdc24Ok);
	F_TRIG_Vdc24Ok(CLK := TOF_Vdc24Ok.Q);

	(* shut down if 24VDC fails *)
	IF F_TRIG_Vdc24Ok.Q THEN
		SYSreset(enable := TRUE, mode := 16#11);
	END_IF
	
	(* OPC UA method processing *)
	UaSYSReset_0();
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

