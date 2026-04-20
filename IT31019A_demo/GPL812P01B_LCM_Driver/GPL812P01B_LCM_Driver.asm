				.SYNTAX 6502
                .LINKLIST
                .SYMBOLS
                
;==================================================================================
; The information contained herein is the exclusive property of
; Generalplus Technology Co. And shall !be distributed, reproduced,
; or disclosed in whole in part without prior written permission.
;       (C) COPYRIGHT 2010   Generalplus TECHNOLOGY CO.                            
;                   ALL RIGHTS RESERVED
; The entire notice above must be reproduced on all authorized copies.
;==================================================================================
;==========================================================================
; Program Name: LCM_Driver.asm
; Applied body: GPL812P01B
; Programmer  : Neo
; Description : LCM Driver Code for GPL812V00A (Tx data to GPL812P01B)
; History version
; Rev #     Date       Who      Comments
; -----  -----------  ------    --------------------------------------------
; 1.0     2018/01/26  NeoChuang    Oringinal Version
;==========================================================================

;==================================================================================
; Include file area
;==================================================================================
.INCLUDE 	GPL812P01B.inc
.INCLUDE	"LCD\LCD_Define.inc"
;==================================================================================
;LCM Hardware Configuration Define Area
;==================================================================================
D_LCM_Port_Dir		.EQU    P_IO_PortD_Dir
D_LCM_Port_Attrib	.EQU	P_IO_PortD_Attrib	
D_LCM_Port_Buffer	.EQU    P_IO_PortD_Buffer
D_LCM_Port_Data		.EQU	P_IO_PortD_Data	

D_LCM_DataPin		.EQU	0x80	;PD7	PC.7
D_LCM_CLKPin		.EQU	0x04	;PD2	0x40	;PC.6

;==================================================================================
;LCM Driver Constant Define Area
;==================================================================================
;LCM Protocol data format is Header(1Byte)+ DataLength(1Byte) + Data(NByte) + CheckSum(1Byte) 
;Max. Data Length is 37
;register Command format is Register address + Register Data
;LCD data Command format is directly fill DPRAM data , DPRAM address is started from 0x50

D_LCM_DataCMD_Header	.EQU		0x80		;Header Command for register data
D_LCM_LCDCMD_Header		.EQU		0x81		;Header Command for LCD data
D_LCM_DataOneCMD_Len	.EQU		0x02
D_LCM_MaxDataLen		.EQU		16			;define max data length ;Max:37
;==================================================================================
; Function External declare area
;==================================================================================


;==================================================================================
; Function Public area
;==================================================================================

.if	(GPL812P01Bx_Mode=EV_Simualtion)	
.public		F_LCM_Enable
.public		F_LCM_Write_OneReg
.public		F_LCM_Write_NReg
.public		F_LCM_Write_LCDData

.public		_F_LCM_Enable
.public		_F_LCM_Write_OneReg
.public		_F_LCM_Write_NReg
.public		_F_LCM_Write_LCDData

.endif
;==================================================================================
; Variable Public area
;==================================================================================

.if	(GPL812P01Bx_Mode=EV_Simualtion)
.public		LCM_Buffer_Ptr
.public		LCM_Data_Buffer
.public		R_LCM_DataLength
.public		R_LCM_Temp
.public		_LCM_Buffer_Ptr
.public		_LCM_Data_Buffer
.public		_R_LCM_DataLength
.public		_R_LCM_Temp
.public    R_128Hz_Count
.public    _R_128Hz_Count
.endif
;==================================================================================
; Variable RAM declare area
;==================================================================================
LCM_Driver_ZRAM:    .SECTION      .PAGE0
.if	(GPL812P01Bx_Mode=EV_Simualtion)	
LCM_Buffer_Ptr		.DS		2					;LCM data buffer address
_LCM_Buffer_Ptr		.EQU	LCM_Buffer_Ptr	
.endif
.ENDS
LCM_Driver_NRAM:    .SECTION
.if	(GPL812P01Bx_Mode=EV_Simualtion)	

LCM_Data_Buffer			.DS		D_LCM_MaxDataLen+3		;Max Size is acording R_LCM_DataLength+3 
_LCM_Data_Buffer		.EQU	LCM_Data_Buffer	
R_LCM_Address			.DS		1				;record LCM Command of register address
R_LCM_Data				.DS		1				;record LCM Command of register data
R_LCM_CheckSum			.DS		1				;record LCM Command of check sum
R_LCM_DataLength		.DS		1				;record LCM Command of DataLength
_R_LCM_DataLength		.EQU	R_LCM_DataLength
R_LCM_Temp				.DS		1				;
_R_LCM_Temp				.EQU	R_LCM_Temp	
R_128Hz_Count			.DS		1
_R_128Hz_Count			.EQU	R_128Hz_Count
.endif

.ENDS

LCM_Driver_Code:    .SECTION
.if	(GPL812P01Bx_Mode=EV_Simualtion)

; =======================================================================================
; Function name : F_LCM_Enable
; Purpose       : Enable LCM Driver ,Setting Data/CLK pin as Output Low
; Parameter     : 
; Return        : 
; Destroy       : A 
; ======================================================================================   	
F_LCM_Enable:
_F_LCM_Enable:
	LDA		D_LCM_Port_Dir
	AND		#.NOT.(D_LCM_CLKPin+D_LCM_DataPin)
	STA		D_LCM_Port_Dir
	;Setting Data/CLK pin as Output Low
	LDA		D_LCM_Port_Buffer
	AND		#.NOT.(D_LCM_CLKPin+D_LCM_DataPin)
	STA		D_LCM_Port_Data
	
	LDA		D_LCM_Port_Dir
	ORA		#(D_LCM_CLKPin+D_LCM_DataPin)
	STA		D_LCM_Port_Dir
		
	LDA		D_LCM_Port_Attrib
	AND		#.NOT.(D_LCM_CLKPin+D_LCM_DataPin)
	STA		D_LCM_Port_Attrib
	
	LDA		P_INT_Ctrl1
	ORA		#D_TBH_INT_En
	STA		P_INT_Ctrl1
	LDA		#D_TBH_INT_En
	STA		P_INT_Clear1
	LDA		#0x00
	STA		R_128Hz_Count
	
	CLI	
	RTS

; =======================================================================================
; Function name : F_LCM_CMDEnd
; Purpose       : LCM Command End 
; Parameter     : 
; Return        : 
; Destroy       : A 
; ======================================================================================   	
F_LCM_CMDEnd:
_F_LCM_CMDEnd:  
	JSR		F_LCM_DataLow
	JSR		F_LCM_ClkLow
	RTS    
  ; ====================================================================================
; Function name : F_LCM_ClkHigh
; Purpose       : LCM Clock pin set  High
; Parameter     : 
; Return        : 
; Destroy       : A 
; ======================================================================================   	
F_LCM_ClkHigh:	
	LDA		#D_LCM_CLKPin
	ORA		D_LCM_Port_Buffer
	STA		D_LCM_Port_Data
	RTS
	
; =======================================================================================
; Function name : F_LCM_ClkLow
; Purpose       : LCM Clock pin set Low
; Parameter     : 
; Return        : 
; Destroy       : A 
; ======================================================================================   	
F_LCM_ClkLow:	
	LDA		#.Not.D_LCM_CLKPin
	AND		D_LCM_Port_Buffer
	STA		D_LCM_Port_Data
	RTS
	

; =======================================================================================
; Function name : F_LCM_DataHigh
; Purpose       : LCM Data pin set High
; Parameter     : 
; Return        : 
; Destroy       : A 
; ======================================================================================   		
F_LCM_DataHigh:
	LDA		#D_LCM_DataPin
	ORA		D_LCM_Port_Buffer
	STA		D_LCM_Port_Data
	RTS
	
; =======================================================================================
; Function name : F_LCM_DataLow
; Purpose       : LCM Data pin set Low
; Parameter     : 
; Return        : 
; Destroy       : A 
; ======================================================================================   			
F_LCM_DataLow:
	LDA		#.Not.D_LCM_DataPin
	AND		D_LCM_Port_Buffer
	STA		D_LCM_Port_Data
	RTS	  
	
  
; =======================================================================================
; Function name : F_LCM_TX_Data
; Purpose       : LCM Tx One Byte
; Parameter     : Acc=TX DATA
; Return        : 
; Destroy       : A,X 
; ======================================================================================          
F_LCM_TX_Data:
	STA		R_LCM_Temp
	LDX		#0x08
L_TxData?:	;;HighByte First
	NOP		;Delay
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	JSR		F_LCM_ClkLow	
	CLC
	ROL		R_LCM_Temp
	BCC		L_LCM_TxLow?
L_LCM_TxHigh?:	
	LDA		#D_LCM_DataPin
	ORA		D_LCM_Port_Buffer
	STA		D_LCM_Port_Data
	JMP		L_CheckNext?
L_LCM_TxLow?:
	LDA		#.NOT.D_LCM_DataPin
	AND		D_LCM_Port_Buffer
	STA		D_LCM_Port_Data
L_CheckNext?:
	JSR		F_LCM_ClkHigh		
	DEX
	BNE		L_TxData?
	JSR		F_LCM_ClkLow
	
	RTS		
; =======================================================================================
; Function name : F_LCM_Write_OneReg
; Purpose       : 
; Parameter     : A:Address Y:Data
; Return        : None ; Check sum = length(=2) + address + data
; Destroy       : A,X
; ======================================================================================
F_LCM_Write_OneReg:
_F_LCM_Write_OneReg:
	STA		R_LCM_Address
	STY		R_LCM_Data
	
	JSR		F_LCM_WaitReady
	;Claculate Check Sum : Length + address + Data
	LDA		#0x02	;Length Fix 2
	STA		R_LCM_CheckSum
	CLC
	LDA		R_LCM_Address	
	ADC		R_LCM_CheckSum
	STA		R_LCM_CheckSum
	CLC
	LDA		R_LCM_Data
	ADC		R_LCM_CheckSum
	STA		R_LCM_CheckSum
	;------------------------------------------------
	LDA		#D_LCM_DataCMD_Header
	JSR		F_LCM_TX_Data

	LDA		#D_LCM_DataOneCMD_Len
	JSR		F_LCM_TX_Data	
	
	LDA		R_LCM_Address
	JSR		F_LCM_TX_Data
	LDA		R_LCM_Data
	JSR		F_LCM_TX_Data
	LDA		R_LCM_CheckSum
	JSR		F_LCM_TX_Data
	
	
	JSR		F_LCM_CMDEnd
	JSR		F_LCM_Delay
	RTS	
; =======================================================================================
; Function name : F_LCM_Write_NReg
; Purpose       : 
; Parameter     : LCM_Buffer_Ptr
; Return        : None ; Check sum = R_LCM_DataLength + address1 + data1 + 
;                       	          address2 + data2 + ....  + addressN + dataN
; Destroy       : A,Y,X
; ======================================================================================
F_LCM_Write_NReg:
_F_LCM_Write_NReg:
	JSR		F_LCM_WaitReady
	;Calculate Check Sum
	LDA		R_LCM_DataLength	
	STA		R_LCM_Temp
	STA		R_LCM_CheckSum		
    LDY     #0
L_CalculateCheckSum?:    
	LDA     (LCM_Buffer_Ptr),Y
	CLC
	ADC		R_LCM_CheckSum
	STA		R_LCM_CheckSum
	INY
	CPY		R_LCM_DataLength
	BCC		L_CalculateCheckSum?
	;----------------------------

	LDA		#D_LCM_DataCMD_Header
	JSR		F_LCM_TX_Data		
	LDA		R_LCM_DataLength
	JSR		F_LCM_TX_Data
	
    LDY     #0	
L_UpdateRegData?:
	LDA     (LCM_Buffer_Ptr),Y	
	JSR		F_LCM_TX_Data
	INY
	DEC		R_LCM_DataLength
	BNE		L_UpdateRegData?
	
	LDA		R_LCM_CheckSum
	JSR		F_LCM_TX_Data	
	
	JSR		F_LCM_CMDEnd
	JSR		F_LCM_Delay
	RTS	
	
	
; =======================================================================================
; Function name : F_LCM_Write_LCDData
; Purpose       : 
; Parameter     : LCM_Buffer_Ptr
; Return        : None ; Check sum = N + 0x50~(0x50x+N)
; Destroy       : A,X,Y 
; ======================================================================================
F_LCM_Write_LCDData:
_F_LCM_Write_LCDData:
	JSR		F_LCM_WaitReady
	
	LDA		#D_LCDDataSize
	STA		R_LCM_DataLength
	STA		R_LCM_CheckSum
    LDY     #0
L_CalculateCheckSum?:    
	LDA     (LCM_Buffer_Ptr),Y
	CLC
	ADC		R_LCM_CheckSum
	STA		R_LCM_CheckSum
	INY
	CPY		R_LCM_DataLength
	BCC		L_CalculateCheckSum?
	;----------------------------
	LDA		#D_LCM_LCDCMD_Header
	JSR		F_LCM_TX_Data	
	LDA		R_LCM_DataLength
	JSR		F_LCM_TX_Data
    LDY     #0	
L_UpdateAgain?:
	LDA     (LCM_Buffer_Ptr),Y	
	JSR		F_LCM_TX_Data
	INY
	DEC		R_LCM_DataLength
	BNE		L_UpdateAgain?
	
	LDA		R_LCM_CheckSum
	JSR		F_LCM_TX_Data
	
	JSR		F_LCM_CMDEnd	
	
	JSR		F_LCM_Delay
	RTS	

	
; =======================================================================================
; Function name : F_LCM_WaitReady
; Purpose       : 
; Parameter     : 
; Return        : None ; 
; Destroy       : A 
; ======================================================================================
F_LCM_WaitReady:	
	
	LDA		D_LCM_Port_Dir	;Set Data Pin Is Input Low , CLK pin is Output Low
	AND		#.not.D_LCM_DataPin
	ORA		#D_LCM_CLKPin
	STA		D_LCM_Port_Dir
	
	LDA		D_LCM_Port_Buffer		
	AND		#.not.D_LCM_CLKPin
	STA		D_LCM_Port_Data
	
	;---------------------

	LDA		D_LCM_Port_Buffer		
	ORA		#D_LCM_CLKPin
	STA		D_LCM_Port_Data	
	
	JSR		DelayUS
	
	LDA		D_LCM_Port_Buffer		
	AND		#.not.D_LCM_CLKPin
	STA		D_LCM_Port_Data	
	;---------------------
	LDA		#0x00
	STA		R_128Hz_Count
L_Wait_DataPinHigh?	
	LDA		R_128Hz_Count
	BNE		F_LCM_WaitReady
	LDA		#0xAA
	STA		P_WDT_Flag_Clear
	
	LDA		D_LCM_Port_Data
	AND		#D_LCM_DataPin
	BEQ		L_Wait_DataPinHigh?
	
	JSR		DelayUS
	
	LDA		D_LCM_Port_Buffer		;CLK High
	ORA		#D_LCM_CLKPin
	STA		D_LCM_Port_Data
	
	JSR		DelayUS
	
	LDA		D_LCM_Port_Buffer
	AND		#.NOT.D_LCM_CLKPin	;CLK Low
	STA		D_LCM_Port_Data
	
	JSR		DelayUS

	LDA		D_LCM_Port_Buffer		
	AND		#.not.(D_LCM_DataPin+D_LCM_CLKPin)
	STA		D_LCM_Port_Data
	
	LDA		D_LCM_Port_Dir	;Set Data Pin / CLK pin   is Output Low
	ORA		#(D_LCM_DataPin+D_LCM_CLKPin)
	STA		D_LCM_Port_Dir
	
	JSR		DelayUS
	
	RTS	
; =======================================================================================
; Function name : DelayUS
; Purpose       : 
; Parameter     : 
; Return        : None ; 
; Destroy       : A 
; ======================================================================================	
DelayUS:	
	LDX		#0x20
L_Loop1?:
	DEX	
	BNE		L_Loop1?
	RTS
	
F_LCM_Delay:	
	LDX	#0x50
L_delayloop?:	
	DEX	
	BNE	L_delayloop?
	RTS
.endif
.ends
