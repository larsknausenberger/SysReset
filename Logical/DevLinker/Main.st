(*********************************************************************************
 * Copyright: B&R Industrial Automation GmbH 
 * Author:    knausenbergl 
 * Created:   April 12, 2021/1:55 PM 

Link a file device on the CF user partition (ArEmb) or in the windows temp folder (ArSim), respectively.
Required for file handling.
 *********************************************************************************)

PROGRAM _INIT

	(* for ArSim, create folder structure under "C:/Temp" *)
	IF DiagCpuIsARsim() OR DiagCpuIsSimulated() THEN
		(* link file device in windows temp folder. this file device is only needed for creating subfolders. *)
		fbDevLink.enable := TRUE;
		fbDevLink.pDevice := ADR(FILE_DEVICE_TEMP);
		fbDevLink.pParam := ADR('/DEVICE=C:/Temp/');
		fbDevLink();
		
		(* create directory "SysReset" in windows temp folder *)
		fbDirCreate.enable := TRUE;
		fbDirCreate.pDevice := ADR(FILE_DEVICE_TEMP);
		fbDirCreate.pName := ADR('SysReset');
		fbDirCreate();
		
		(* unlink temporary file device, it is no longer needed *)
		fbDevUnlink.enable := TRUE;
		fbDevUnlink.handle := fbDevLink.handle;
		fbDevUnlink();
	END_IF
	
	(* link FILE_DEVICE_LOCAL, which is used for data storage by other tasks *)
	fbDevLink.enable := TRUE;
	fbDevLink.pDevice := ADR(FILE_DEVICE_LOCAL);
	IF DiagCpuIsARsim() OR DiagCpuIsSimulated() THEN
		fbDevLink.pParam := ADR('/DEVICE=C:/Temp/SysReset');
	ELSE
		fbDevLink.pParam := ADR('/DEVICE=F:/');
	END_IF
	fbDevLink();
	
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _EXIT

	fbDevUnlink.enable := TRUE;
	fbDevUnlink.handle := fbDevLink.handle;
	fbDevUnlink();
	
END_PROGRAM

