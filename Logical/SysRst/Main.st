(*********************************************************************************
 * Copyright: B&R Industrial Automation GmbH 
 * Author:    knausenbergl 
 * Created:   January 18, 2021/11:20 AM 

This task initiates a controlled shutdown of the PLC if either of the following conditions applies:
1. Drop in 24VDC supply, running on buffered 24VDC supply. (Only applies if buffered 24VDC is used.)
2. Shutdown command triggered, e.g. by visualization.

This task ensures file consistency in the case of a shutdown. This is done via the use of
semaphores. Any task accessing the file system must acquire a semaphore. The shutdown only
starts if the semaphore is no longer in use.
 *********************************************************************************)


PROGRAM _INIT
	
	(* create semaphore for detecting usage of file system *)
	fbSemCreate.enable		:= TRUE;
	fbSemCreate.maxCount	:= SEM_MAX_COUNT;
	fbSemCreate.initCount	:= fbSemCreate.maxCount;
	fbSemCreate();
	oSemIdent	:= fbSemCreate.ident;

	TOF_Vdc24Ok.PT	:= VDC24_OK_OFF_DELAY;
	
END_PROGRAM

PROGRAM _CYCLIC
	
	TOF_Vdc24Ok(IN := diVdc24Ok);			//off-delay for "24VDC OK" signal to filter short drops in 24VDC power supply
	F_TRIG_Vdc24Ok(CLK := TOF_Vdc24Ok.Q);	//falling edge of filtered "24VDC OK" signal
	
	(* check if file system is busy *)
	fbSemGetInfo.enable	:= TRUE;
	fbSemGetInfo.ident	:= fbSemCreate.ident;
	fbSemGetInfo();
	FileSystemBusy	:= (fbSemGetInfo.maxCount <> fbSemGetInfo.curCount);
	
	(* state machine *)
	CASE State OF
		(* initial state after boot *)
		STATE_INIT:
			State := STATE_IDLE;
		
		(* idle, waiting for event *)		
		STATE_IDLE:
			IF (F_TRIG_Vdc24Ok.Q OR iCmdShutdown) THEN
				iCmdShutdown	:= FALSE;
				State := STATE_AWAIT_FILESYS;
			END_IF
		
		(* wait for file system to finish *)
		STATE_AWAIT_FILESYS:
			IF NOT FileSystemBusy THEN
				State := STATE_SHUTDOWN;
			END_IF 
		
		(* shutdown *)
		STATE_SHUTDOWN:
			SYSreset(enable := TRUE, mode := 16#11);	//start shutdown in mode 0x11: WARMSTART (no restart, only shutdown, waits for "power off", in connection with UPS)
		
	END_CASE
	
	(* set outputs depending on current state *)
	CASE State OF
		STATE_AWAIT_FILESYS, STATE_SHUTDOWN:
			oFileSystemLocked := TRUE;
		ELSE
			oFileSystemLocked := FALSE;
	END_CASE
	
END_PROGRAM

PROGRAM _EXIT
	
	fbSemDelete.enable	:= TRUE;
	fbSemDelete.ident	:= fbSemCreate.ident;
	fbSemDelete();
	 
END_PROGRAM

