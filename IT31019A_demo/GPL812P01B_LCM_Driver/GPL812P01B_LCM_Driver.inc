.IFNDEF _GPL812P01B_LCM_Driver_inc_
_GPL812P01B_LCM_Driver_inc_:    .EQU    1
.if	(GPL812P01Bx_Mode=EV_Simualtion)
; =======================================================================================
; Function name : F_LCM_Enable
; Purpose       : Enable LCM Driver ,Setting Data/CLK pin as Output Low
; Parameter     : 
; Return        : 
; Destroy       : A 
; ======================================================================================  
.extern		F_LCM_Enable
; =======================================================================================
; Function name : F_LCM_Write_OneReg
; Purpose       : 
; Parameter     : A:Address Y:Data
; Return        : None ; Check sum = length(=2) + address + data
; Destroy       : A,X
; ======================================================================================
.extern		F_LCM_Write_OneReg
; =======================================================================================
; Function name : F_LCM_Write_NReg
; Purpose       : 
; Parameter     : LCM_Buffer_Ptr
; Return        : None ; Check sum = R_LCM_DataLength + address1 + data1 + 
;                       	          address2 + data2 + ....  + addressN + dataN
; Destroy       : A,Y,X
; ======================================================================================
.extern		F_LCM_Write_NReg
; =======================================================================================
; Function name : F_LCM_Write_LCDData
; Purpose       : 
; Parameter     : LCM_Buffer_Ptr
; Return        : None ; Check sum = N + (0x50~0x50+N)
; Destroy       : A,X,Y 
; ======================================================================================
.extern		F_LCM_Write_LCDData

.external	.PAGE0	LCM_Buffer_Ptr ;LCM data buffer address

.extern		LCM_Data_Buffer		;Max Size is acording R_LCM_DataLength+3
.extern		R_LCM_DataLength	;record LCM Command of DataLength

.extern    R_128Hz_Count

.endif
.endif
