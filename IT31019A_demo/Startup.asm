;==================================================================================
; The information contained herein is the exclusive property of
; Generalplus Technology Co. And shall not be distributed, reproduced,
; or disclosed in whole in part without prior written permission.
;       (C) COPYRIGHT 2012   Generalplus TECHNOLOGY CO.                            
;                   ALL RIGHTS RESERVED
; The entire notice above must be reproduced on all authorized copies.
;==================================================================================
;==================================================================================
; Name                  : Startup.asm
; Applied Body          : GPL812P01A
; Programmer            : 
; Description           : 
; History version       : 
;==================================================================================

;==========================================
; Compiler parameter define
;==========================================
.SYNTAX 6502
.LINKLIST
.SYMBOLS

;==========================================
; Constant define area
;==========================================




;==========================================
; Include file area
;==========================================
.INCLUDE 	GPL812P01B.inc
.INCLUDE	"GPL812P01B_LCM_Driver\GPL812P01B_LCM_Driver.inc"
.INCLUDE	"LCD\GPL812P01B_LCD.inc"
;.INCLUDE	include\user.inc
.INCLUDE	include\Macro.inc
.INCLUDE	include\Key.inc
;.INCLUDE	include\rtc.inc
.INCLUDE	include\Display.inc
.INCLUDE		RFC\RFC_user.inc
;.INCLUDE		RFC\RFC_Define.inc
;.INCLUDE	RFC\RFC_user.inc
;.INCLUDE	RFC\RfcDriver.inc
;.INCLUDE	RFC\rfcCalculate.inc
;.INCLUDE	RFC\rfcDefine.inc
;==========================================
ModeSelect_EVorOTP: .section
.if	(GPL812P01Bx_Mode=OTP_BurnIn)	;fix the address 0xFFF7 to check EV or OTP
.DB	0x01		;1:For OTP		
.endif
.if	(GPL812P01Bx_Mode=EV_Simualtion)	;fix the address 0xFFF7 to check EV or OTP
.DB	0x02		;2:For EV		
.endif
;==========================================
; External declare area
;==========================================
.public		R_2Hz
;.PUBLIC		R_500ms
;.PUBLIC		R_1KHz
C_RFC_Interval			.equ		60
;==========================================
; Public declare area
;==========================================
.PUBLIC V_RESET

.EXTERNAL	OF_cnt
;==========================================
;Variable RAM declare area
;==========================================
.PAGE0
R_2Hz		ds	1
RB_RFC_Interval:		.DS		1
;R_1KHz		ds	1
D_InWithCAP				.equ	0x01
;==========================================
; code starting 
;==========================================
.CODE
V_RESET:
		SEI
		LDX		#0xFF	;nitial stack pointer at 0x1FF 
		TXS
		LDA		P_WAKEUP_Flag
		TAX
        LDA		#00
		STA		P_WAKEUP_Ctrl    ;clear wakeup flag	
		TXA		
		AND		#D_TBLWFC_En
		BEQ		$+5
		JMP		L_2Hz_WakeUp		
		TXA
		AND		#D_KEYWFC_En
		BEQ		$+5
		JMP		Key_WakeUp
		JMP		Power_On_Reset		
Power_On_Reset:	
		LDA		#D_32768En	;+D_InWithCAP)
		STA		P_CLK_32768_En		
		
		%M_Power_GreenMode		;Set P_IO_Green_Ctrl, P_SYSTEM_Green_Ctrl Enable.
		%RAM_Init
		%RAM2_Init
		%F_INT_Intital
		%F_IO_Intital
		.if	(GPL812P01Bx_Mode=EV_Simualtion)
		JSR		F_LCM_Enable
		.endif
		JSR		F_LCD_Intital		;Initial LCD	
		CLI	
		LDA		#0xFF
		JSR		F_LCD_Clear	
		JSR		F_LCD_PutRAMToDPRAM
		JSR		F_Start_RFC	
		JSR		F_JudegOption
		%FillLcdDpram	#FFH
		LDA		#00
		STA		R_2Hz
		%bits	R_TimeStatus,AddOthers

	Loop:
		%M_ClearWatchDog
	    SEI                     ; 关中断，防止冲突
  	    LDA     P_INT_Clear0    ; 读中断标志位
 	    AND     #D_TM1O_Clr     ; 检查 Timer1 是否溢出
 	    BEQ     ?L_No_Overflow
  	    INC     OF_cnt          ; 如果溢出，计数器+1
 	    LDA     #D_TM1O_Clr     ; 清除溢出标志
  	    STA     P_INT_Clear0
?L_No_Overflow:
   		CLI                     ; 开中断		
		JSR		F_Calculate_Temp_Hum_Proc
		LDA		R_2Hz
		CMP		#04H
		BCC		Loop
		LDA		#0x00
		JSR		F_LCD_Clear			;LCD DPRAM Clear
		%FillLcdDpram	#00H
		NOP
		JMP		Main_Loop
		
L_2Hz_WakeUp:	
		LDA		#D_TBL_Clr		;2Hz
		STA		P_INT_Clear1
		%M_ClearWatchDog
		LDA		#00
		STA		R_2Hz
;		JSR		F_RealTimeClock
		JSR		Light_JudgeOff	;背光
		%bits	R_TimeStatus,AddOthers	
		INC		RB_RFC_Interval
		LDA		RB_RFC_Interval
		CMP		#C_RFC_Interval
		BCC		?L_Not_Start_RFC
		LDA		#00h
		STA		RB_RFC_Interval
		JSR		F_Start_RFC		
?L_Not_Start_RFC:	
	
		JMP		Main_Loop
	
Key_WakeUp:
		CLI
		NOP	
		
Main_Loop:
		
		%M_ClearWatchDog

	    SEI                     ; 关中断，防止冲突
  	    LDA     P_INT_Clear0    ; 读中断标志位
 	    AND     #D_TM1O_Clr     ; 检查 Timer1 是否溢出
 	    BEQ     ?L_No_Overflow
  	    INC     OF_cnt          ; 如果溢出，计数器+1
 	    LDA     #D_TM1O_Clr     ; 清除溢出标志
  	    STA     P_INT_Clear0
?L_No_Overflow:
   		CLI                     ; 开中断		
		
		JSR		F_KeyScan
		JSR		F_Calculate_Temp_Hum_Proc
		JSR		F_Display
		JSR		F_LCD_PutRAMToDPRAM
		
		LDA		R_2Hz
		BNE		L_2Hz_WakeUp
		
		LDA		R_KeyValue
		BNE		Main_Loop
		LDA		R_RFC_States	;	;温湿度计算
		BNE		Main_Loop	
	Check_Sleep:
		
		SEI
		SleepHlat:
		LDA	#0x20
		STA	P_IO_PortD_WakeUpEN	
		LDA	P_IO_PortD_Data		;latch  
		NOP
		NOP
		LDA	#(D_KeyEn+D_TBLEn)	
		STA	P_WAKEUP_Ctrl
		%GotoSleep
		NOP
		NOP
		JMP	V_RESET

F_JudegOption:
		LDA		P_IO_PortD_Data
		AND		#D_Bit3
		BEQ		?L_Exit
		%bits	R_OtherFlag,D_CF
		LDA		#10001000b	
		STA		P_IO_PortD_Dir	
		LDA		#00101100b		
		STA		P_IO_PortD_Data			
	?L_Exit:
		RTS
		
;=======================================================================================

		


.END
