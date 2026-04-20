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
; Program Name: GPL812P01B_LCD.asm
; Applied body: GPL812P01B
; Programmer  : Neo Chuang
; Description : LCD Driver code
; History version
; Rev #     Date       Who      Comments
; -----  -----------  ------    --------------------------------------------
; 1.0     2018/03/28  NeoChuang    Oringinal Version
;==========================================================================


;==================================================================================
; Include file area
;==================================================================================
.INCLUDE 	GPL812P01B.inc
.INCLUDE	"GPL812P01B_LCM_Driver\GPL812P01B_LCM_Driver.inc"
.INCLUDE	"LCD_Define.inc"

;==================================================================================
;Constant Define Area
;==================================================================================

;==================================================================================
; Function External declare area
;==================================================================================

;==================================================================================
; Variable Public area
;==================================================================================
.PUBLIC	LCD_DPRAM_Ptr
.PUBLIC	LCD_DPRAM_Buffer
.PUBLIC	LCD_RAM_Ptr
;==================================================================================
; Variable RAM declare area
;==================================================================================
LCD_ZRAM:    .SECTION      .PAGE0
LCD_DPRAM_Ptr		.DS		2
LCD_RAM_Ptr			.DS		2
.ENDS
LCD_NRAM:    .SECTION
LCD_DPRAM_Buffer	.DS		D_LCDDataSize
.ENDS


;=============================================                                  
.public F_LCD_Clear
.public _F_LCD_Clear

.public F_LCD_Intital
.public _F_LCD_Intital

.public F_LCD_Close
.public _F_LCD_Close
.public	F_LCD_PutRAMToDPRAM
.public	_F_LCD_PutRAMToDPRAM

;=============================================       
LCD_Code:    .SECTION


; =======================================================================================
; Function name : F_LCD_Intital
; Purpose       : VLCD=VDD ,1/3 bias , 1/4 Duty 
;				PB[3:0] as segment output
;				PC[7:5] as common  output
;				PB[6:0] as segment output
; Parameter     : 
; Return        : 
; Destroy       : A,X,Y 
; ======================================================================================  
F_LCD_Intital:
_F_LCD_Intital:
		.if	(GPL812P01Bx_Mode=EV_Simualtion)
			LDA		#P_LCD_Ctrl		;Register
			LDY		#D_LCD_Setting						
			JSR		F_LCM_Write_OneReg		;P_LCD_Ctrl=#D_LCD_Setting
			;--------------------------------------------------------------	
			LDA		#.LOW.LCM_Data_Buffer
			STA		LCM_Buffer_Ptr	
			LDA		#.high.LCM_Data_Buffer
			STA		LCM_Buffer_Ptr+1
			LDY		#0x00			
			;------------------------------------------
			LDA		#P_IOB_LCDPORT_Ctrl
			STA		(LCM_Buffer_Ptr),Y
			INY			
			LDA		#D_LCD_PortB_Ctrl
			STA		(LCM_Buffer_Ptr),Y
			INY			
			;-------------------------------------------------
			LDA		#P_IOB_SEGCOM_Ctrl	
			STA		(LCM_Buffer_Ptr),Y
			INY			
			LDA		#D_LCD_PortB_COMSEG
			STA		(LCM_Buffer_Ptr),Y
			INY
			;--------------------------------------------------------------			
			LDA		#P_IOC_LCDPORT_Ctrl	
			STA		(LCM_Buffer_Ptr),Y
			INY			
			LDA		#D_LCD_PortC_Ctrl
			STA		(LCM_Buffer_Ptr),Y			
			INY	
			LDA		#P_IOC_SEGCOM_Ctrl	
			STA		(LCM_Buffer_Ptr),Y
			INY			
			LDA		#D_LCD_PortC_COMSEG
			STA		(LCM_Buffer_Ptr),Y	
			INY
			;-------------------------------------------------
			LDA		#P_IOA_LCDPORT_Ctrl
			STA		(LCM_Buffer_Ptr),Y
			INY			
			LDA		#D_LCD_PortA_Ctrl
			STA		(LCM_Buffer_Ptr),Y
			INY			
			;-------------------------------------------------			
			LDA		#P_IOA_SEGCOM_Ctrl
			STA		(LCM_Buffer_Ptr),Y
			INY			
			LDA		#D_LCD_PortA_COMSEG
			STA		(LCM_Buffer_Ptr),Y
			INY			
			;-------------------------------------------------
			LDA		#P_IOD_LCDPORT_Ctrl
			STA		(LCM_Buffer_Ptr),Y
			INY			
			LDA		#D_LCD_PortD_Ctrl
			STA		(LCM_Buffer_Ptr),Y
			INY			
			;-------------------------------------------------			
			TYA
			STA		R_LCM_DataLength		
			JSR		F_LCM_Write_NReg	;address:LCM_Data_Buffer	
	.else
			
		LDA		#D_LCD_Setting
		STA		P_LCD_Ctrl
		
		LDA		#D_LCD_PortB_Ctrl
		STA		P_IOB_LCDPORT_Ctrl
		LDA		#D_LCD_PortB_COMSEG
		STA		P_IOB_SEGCOM_Ctrl
		
		LDA		#D_LCD_PortC_Ctrl
		STA		P_IOC_LCDPORT_Ctrl
		LDA		#D_LCD_PortC_COMSEG
		STA		P_IOC_SEGCOM_Ctrl
		
		LDA		#D_LCD_PortA_Ctrl
		STA		P_IOA_LCDPORT_Ctrl
		LDA		#D_LCD_PortA_COMSEG
		STA		P_IOA_SEGCOM_Ctrl

		LDA		#D_LCD_PortD_Ctrl
		STA		P_IOD_LCDPORT_Ctrl		
	.endif	
			RTS	

; =======================================================================================
; Function name : F_LCD_Close
; Purpose       : LCD interface Close
; Parameter     : 
; Return        : 
; Destroy       : A 
; ======================================================================================   
F_LCD_Close:
_F_LCD_Close:
		.if	(GPL812P01Bx_Mode=EV_Simualtion)
			LDA		#P_LCD_Ctrl
			LDY		#D_LCDMode_DisplayOff		
			JSR		F_LCM_Write_OneReg
		.ELSE
			LDA		#D_LCDMode_DisplayOff
			STA		P_LCD_Ctrl
		.ENDIF
			RTS	
; =======================================================================================
; Function name : F_LCD_Clear
; Purpose       : Clear LCD DPRAM
; Parameter     : A:LCD data
; Return        : 
; Destroy       : A,Y 
; ======================================================================================  
F_LCD_Clear:	
_F_LCD_Clear:
	TAX
	LDA		#.LOW.LCD_DPRAM_Buffer
	STA		LCD_DPRAM_Ptr	
	LDA		#.high.LCD_DPRAM_Buffer
	STA		LCD_DPRAM_Ptr+1
	LDY		#0x00
	TXA
L_Clear?:	
	STA		(LCD_DPRAM_Ptr),Y
	INY
	CPY		#D_LCDDataSize		
	BNE		L_Clear?
	JSR		F_LCD_PutRAMToDPRAM		

	RTS


; =======================================================================================
; Function name : F_LCD_PutRAMToDPRAM
; Purpose       : Put RAM Buffer to DPRAM(0x50~0x5F)
; Parameter     : 
; Return        : 
; Destroy       : A,X,Y 
; ======================================================================================  
F_LCD_PutRAMToDPRAM:	
_F_LCD_PutRAMToDPRAM:	
	.if	(GPL812P01Bx_Mode=EV_Simualtion)
		LDA		#.LOW.LCD_DPRAM_Buffer
		STA		LCM_Buffer_Ptr	
		LDA		#.high.LCD_DPRAM_Buffer
		STA		LCM_Buffer_Ptr+1
		JSR		F_LCM_Write_LCDData
	.else
;		LDA		#.LOW.D_LCD_Address
;		STA		LCD_DPRAM_Ptr	
;		LDA		#.high.D_LCD_Address
;		STA		LCD_DPRAM_Ptr+1
		
;		LDA		#.LOW.LCD_DPRAM_Buffer
;		STA		LCD_RAM_Ptr	
;		LDA		#.high.LCD_DPRAM_Buffer
;		STA		LCD_RAM_Ptr+1	
;		
;		LDY		#0x00
;		LDX		#0x00
;	L_loop?:	
;		LDA		(LCD_RAM_Ptr),Y
;		STA		(LCD_DPRAM_Ptr,X)
;		INY
;		INC		LCD_DPRAM_Ptr
;		CPY		#D_LCDDataSize
;		BNE		L_loop?
		.endif	
	RTS	
.ends
