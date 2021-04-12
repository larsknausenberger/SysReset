(*********************************************************************************
 * Copyright: B&R Industrial Automation GmbH 
 * Author:    knausenbergl 
 * Created:   April 12, 2021/1:55 PM 

This task creates a file 'HelloWorld.txt' and writes to it. When writing, this task acquires
a semaphore, thereby blocking any shutdown in SysRst. The shutdown is delayed until all
writing operations are complete.
A writing command is issued by setting iCmdWrite to TRUE.
 *********************************************************************************)

PROGRAM _INIT
	
	FileDevice := FILE_DEVICE_LOCAL;
	FileName := 'HelloWorld.txt';
	WriteData := 'HelloWorld$n';

	(* create a file (in case it does not already exist) *)
	fbFileCreate.enable := TRUE;
	fbFileCreate.pDevice := ADR(FileDevice);
	fbFileCreate.pFile := ADR(FileName);
	fbFileCreate();
	
	(* close the file opened by FileCreate *)
	fbFileClose.enable := TRUE;
	fbFileClose.ident := fbFileCreate.ident;
	fbFileClose();
	
END_PROGRAM

PROGRAM _CYCLIC

	(* main state machine *)
	CASE State OF
		
		(* inital state after boot *)
		STATE_INIT:
			State := STATE_IDLE;
		
		(* idle, waiting for command *)
		STATE_IDLE, STATE_ERROR:
			IF iCmdWrite AND NOT iFileSystemLocked THEN
				iCmdWrite := FALSE;
				(* acquire semaphore before writing *)
				IF (SemAcquire(iSemIdent) = ERR_OK) THEN
					State := STATE_OPENING;
				ELSE
					State := STATE_ERROR;
				END_IF
			END_IF
		
		(* opening file *)
		STATE_OPENING:
			fbFileOpen.enable := TRUE;
			fbFileOpen.mode := fiWRITE_ONLY;
			fbFileOpen.pDevice := ADR(FileDevice);
			fbFileOpen.pFile := ADR(FileName);
			fbFileOpen();
		
			CASE fbFileOpen.status OF
				ERR_FUB_BUSY:
					// pass
				ERR_OK:
					State := STATE_WRITING;
				ELSE
					SemRelease(iSemIdent);
					State := STATE_ERROR;
			END_CASE
		
		(* writing to file *)
		STATE_WRITING:
			fbFileWrite.enable := TRUE;
			fbFileWrite.ident := fbFileOpen.ident;
			fbFileWrite.len := LEN(WriteData);
			fbFileWrite.offset := fbFileOpen.filelen;
			fbFileWrite.pSrc := ADR(WriteData);
			fbFileWrite();
		
			CASE fbFileWrite.status OF
				ERR_FUB_BUSY:
					// pass
				ERR_OK:
					State := STATE_CLOSING;
				ELSE
					State := STATE_CLOSING_ERROR;
			END_CASE
		
		(* closing file (also after error) *)
		STATE_CLOSING, STATE_CLOSING_ERROR:
			fbFileClose.enable := TRUE;
			fbFileClose.ident := fbFileOpen.ident;
			fbFileClose();
			
			CASE fbFileClose.status OF
				ERR_FUB_BUSY:
					// pass
				ERR_OK:
					SemRelease(iSemIdent);
					IF State = STATE_CLOSING THEN
						State := STATE_IDLE;
					ELSE
						State := STATE_ERROR;
					END_IF
				ELSE
					SemRelease(iSemIdent);
					State := STATE_ERROR;
			END_CASE
		
	END_CASE
	
END_PROGRAM

PROGRAM _EXIT

	fbFileClose.enable := TRUE;
	fbFileClose.ident := fbFileOpen.ident;
	fbFileClose();
	
END_PROGRAM

