(*********************************************************************************
 * Copyright: B&R Industrial Automation GmbH 
 * Author:    knausenbergl 
 * Created:   January 18, 2021/11:20 AM 

This task initiates a controlled shutdown of the PLC if either of the following conditions applies:
1. Drop in 24VDC supply, running on buffered 24VDC supply. (Only applies if buffered 24VDC is used.)
2. Shutdown command triggered, e.g. by visualization.

This task does not ensure file consistency in the case of a shutdown. Any active write operations to files are
aborted by the shutdown. To ensure file consistency, use BR data modules or delay shutdown until all write
operations have been completed.
 *********************************************************************************)


PROGRAM _INIT

	TOF_Vdc24Ok.PT	:= VDC24_OK_OFF_DELAY;
	
END_PROGRAM

PROGRAM _CYCLIC
	
	TOF_Vdc24Ok(IN := diVdc24Ok);			//off-delay for "24VDC OK" signal to filter short drops in 24VDC power supply
	F_TRIG_Vdc24Ok(CLK := TOF_Vdc24Ok.Q);	//falling edge of filtered "24VDC OK" signal

	(* 24VDC failure or command "start shutdown"? *)
	IF F_TRIG_Vdc24Ok.Q OR iCmdShutdown THEN
		iCmdShutdown	:= FALSE;					//reset visu command
		SYSreset(enable := TRUE, mode := 16#11);	//start shutdown in mode 0x11: WARMSTART (no restart, only shutdown, waits for "power off", in connection with UPS)
	END_IF
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

