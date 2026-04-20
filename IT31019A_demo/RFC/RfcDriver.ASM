;===========================================================
	.SYNTAX		6502
	.LINKLIST
	.SYMBOLS
;===========================================================
.INCLUDE 	GPL812P01B.inc
.INCLUDE	".\RFC\rfcDefine.inc"
.INCLUDE	".\RFC\rfcCalculate.inc"
.INCLUDE	include\Macro.inc
.INCLUDE	include\Key.inc
; ==================================================================
; Module Name:	RfcDriver.ASM
; Applied Body:	
; Purpose:		temperature/humidity measure function (-50 ~ 100`C / 0 ~ 100%) .
; Programmer:	Jason
; Date:			2011.12.22
; ==================================================================

;.EXTERNAL V_BoundingDigit
.EXTERNAL	F_Temp_C2F_Modul
.EXTERNAL	F_Calculate_Temp
.EXTERNAL	F_Calculate_Hum
Bit0                    EQU     00000001B
Bit1                    EQU     00000010B
Bit2                    EQU     00000100B
Bit3                    EQU     00001000B
Bit4                    EQU     00010000B
Bit5                    EQU     00100000B
Bit6                    EQU     01000000B
Bit7                    EQU     10000000B


C_Digit14			    EQU		14

D_RFC_Disable	.EQU		00000000B
D_RFC_Enable	.EQU		00001000B
D_RFC0_Enable	.EQU		00000001B
D_RFC1_Enable	.EQU		00000010B
D_RFC2_Enable	.EQU		00000100B
D_RFC_Mask		.EQU		00001111B
P_TMB_CNTL		.EQU		P_TIMER_TM1Data_LB
P_TMB_CNTH		.EQU		P_TIMER_TM1Data_HB
;
P_IOC_DIR		.EQU		P_IO_PortC_Dir	
P_IOC_ATT		.EQU		P_IO_PortC_Attrib
P_IOC_DAT		.EQU		P_IO_PortC_Data

.PUBLIC	F_RFC_porccess
.PUBLIC	_F_RFC_porccess
.PUBLIC	R_RFC_States

.PUBLIC	F_RFC_Initial
.PUBLIC	_F_RFC_Initial
.PUBLIC		R_RFCFlag
.PUBLIC		F_Start_RFC
.PUBLIC		F_Stop_RFC
.PUBLIC		R_RFC_Control
.PUBLIC		F_Calculate_Temp_Hum_Proc
.PUBLIC		OF_cnt



.EXTERN		RB_TempDataBCD			
.EXTERN		RB_HumDataBCD	
.EXTERN		TempDataHex
.EXTERN 	HumDataHex
.EXTERN     R_Temp_N_bytes
.PAGE0
OF_cnt:			.DS		1
;---------------------------------------------------------------------	
;RFCDriverRAM		.Section
R_RFC_States	DS	1
;0:Idle
;1:Sensing Ref
;2:Read Ref data and Sensing Sens1	
;3:Read Sens1 data and Sensing Sens2
;4:Read Sens2 data

;Bit3:RFC Data Readay flag
;Bit4:Continue Sensing RFC Data
;Bit5:Accept Disaply RFC Data

R_RFCFlag	.DS		1
RB_RfcInterval	.DS		1

R_RFC_Control	.DS		1
	D_Cal_ready:		.EQU	01H
	D_Cal_ing:		.EQU	02H


R_TM1Data_LB:		.DS		 1
R_TM1Data_HB:		.DS		 1
R_Sample_Count:     .DS      1
R_Temp_Buf1:        .DS      4
R_Temp_Buf2:        .DS      4
R_Temp_Buf3:        .DS      4
R_Hum_Buf1:         .DS      1
R_Hum_Buf2:         .DS      1
R_Hum_Buf3:         .DS      1
.ends

.EXTERN		R_RFC_Disaply_TimeCount
;**********************************************************************
.CODE


F_DischargeRfcIO:

        LDA     #D_RFCDis
        STA     P_RFC_Ctrl

	RTS


	
%SetTimerData   .MACRO  c_data

        LDA     #.LOW.c_data
        STA     P_TIMER_TM1Data_LB
        LDA     #.HIGH.c_data
        AND		#0FH
        STA     P_TIMER_TM1Data_HB

        
	.ENDM
	
;------------------------
F_EnableRfcTimer:
    LDA     #(D_TM1PortC7TM1Clk+0x80)
    STA     P_TIMER_Timer1_Ctrl
	RTS
;------------------------
F_DisableRfcTimer:
	LDA	P_TIMER_Timer1_Ctrl
	AND	#~(D_TM1En)
	STA	P_TIMER_Timer1_Ctrl
	RTS
;------------------------
;F_EnableRFC:
;	LDA		#D_RFCEN
;	STA		P_RFC_Ctrl
;	RTS
;------------------------
F_DisableRFC:
        LDA     #D_RFCDis
        STA     P_RFC_Ctrl
	RTS
;----------------------------------------------------------------------------
F_Timercal:
	
		SEC
		LDA		#0xFF
		SBC		P_TIMER_TM1Data_LB
		STA		R_TM1Data_LB
		LDA		#0x0F
		SBC		P_TIMER_TM1Data_HB
		STA		R_TM1Data_HB
?L_FFF:
		LDA		OF_cnt
		ORA		#0
		BEQ		?L_Calend
		DEC		OF_cnt
		CLC
		LDA		#0xFF
		ADC		R_TM1Data_LB
		STA		R_TM1Data_LB
		LDA		#0x0F
		ADC		R_TM1Data_HB
		STA		R_TM1Data_HB
		JMP		?L_FFF
?L_Calend
	
		RTS
;------------------------

%EnableRR:		.MACRO	
	    LDA		#00000000b
		STA		P_IO_PortC_Attrib		
		LDA		#00000000b	
		STA		P_IO_PortC_Dir
		LDA		#00001111b
		STA		P_IO_PortC_Data		
		LDA		#D_RFC2_PC6+D_RFCEN
		STA		P_RFC_Ctrl
		
	.ENDM
;------------------------
%EnableRT:		.MACRO
    	LDA		#00000000b
		STA		P_IO_PortC_Attrib		
		LDA		#00000000b	
		STA		P_IO_PortC_Dir
		LDA		#00001111b
		STA		P_IO_PortC_Data	
		LDA		#D_RFC0_PC4+D_RFCEN
;		LDA		#D_RFC1_PC5+D_RFCEN
		STA		P_RFC_Ctrl
		
	.ENDM
;------------------------
%EnableRH:		.MACRO
    	LDA		#00000000b
		STA		P_IO_PortC_Attrib		
		LDA		#00000000b	
		STA		P_IO_PortC_Dir
		LDA		#00001111b
		STA		P_IO_PortC_Data	
		LDA		#D_RFC1_PC5+D_RFCEN	
		STA		P_RFC_Ctrl
	.ENDM		


F_RFC_Initial:
_F_RFC_Initial:	

	JSR		F_DischargeRfcIO
	
	LDA		#0
	STA		R_RFCFlag
	STA		R_RFC_States
	STA		R_Sample_Count

	STA		RB_HumDataBCD
	STA		RW_LastTem
	STA		RW_AvgRefValue
	STA		RW_LastTem+1
	STA		RW_AvgRefValue+1
	STA		RB_TempDataBCD
	STA		RB_TempDataBCD+1
	STA		RB_HumDataBCD

	STA		RB_RfcInterval
	;------------------------------------------------
	

	
	LDA		#D_RFC_SensorEn
	STA		R_RFC_States	
	
	RTS
F_Start_RFC:
	LDA		#D_RFC_SensorEn
	STA		R_RFC_States
	LDA		#D_RFC_Enable
	STA		R_RFC_Control
	RTS
F_Stop_RFC:
	LDA		#00h
	STA		R_RFC_States
	LDA		#00h
	STA		R_RFC_Control
	RTS	
; ===========================================================
; Function Name:	F_TempRFC
; Purpose:			Control	temperature	test.
; Parameters:		V_TempTest,P_TMB_CNTL,P_TMB_CNTH,R_CntRef+0,R_CntRef+1,R_CntSen+0,R_CntSen+1
; Return:			V_TempTest,R_CntRef+0,R_CntRef+1,R_CntSen+0,R_CntSen+1
; Destroy:		
; ===========================================================
F_RFC_porccess:
_F_RFC_porccess:
		LDA		R_RFC_Control
		AND		#D_RFC_Enable
		BNE		?L_RFC_Enable_proc
		RTS
?L_RFC_Enable_proc:
;		INC		RB_RfcInterval
        LDA     R_RFC_States
        AND     #0x07			;0x0F ,according Bit[0:3] to select jumping label
        ASL     A
        TAX
        
        LDA     T_RfcStateFunc+1,X
        PHA
        LDA     T_RfcStateFunc,X
        PHA
?L_Exit:
        RTS
        
T_RfcStateFunc:
        DW      F_RFCIDle-1			 ;0
        DW      F_TRefOsc-1          ;1	
        DW      F_TSenOsc-1          ;2
        DW      F_TSen2Osc-1		 ;3
        DW      F_RFC_GetTemper-1     ;D_RfcStatTempCalc	4
; ===========================================================
; Function Name:	F_RFCIDle
; Purpose:			
; Parameters:		
; Return:			
; Destroy:		
; ===========================================================
F_RFCIDle:
		LDA		R_RFC_States
		AND		#D_RFC_SensorEn
		BNE		L_RFCInit?
;        LDA     RB_RfcInterval
;        CMP     #C_MAX_TIME_RFC_INTERVAL
        BEQ     ?L_Exit     ;Time is not up!
L_RFCInit?:        
		LDA		#D_RFC_ScanRef
		STA		R_RFC_States
?L_Exit:
        RTS

; ===========================================================
; Function Name:	F_RFCIDle
; Purpose:			
; Parameters:		
; Return:			
; Destroy:		
; ===========================================================	
F_TRefOsc:				;test frequence	of Rref	
	
	JSR		F_DischargeRfcIO
    %SetTimerData   0x0fff
	JSR	F_EnableRfcTimer
	%EnableRR	

	LDA		R_RFC_States
	AND		#.not.0x07
	ORA		#D_RFC_ScanSen1
	STA		R_RFC_States
	RTS
; ===========================================================
; Function Name:	F_TSenOsc
; Purpose:			
; Parameters:		
; Return:			
; Destroy:		
; ===========================================================
F_TSenOsc:				;frequence of Rref -> R_CntRef

	JSR		F_DisableRfcTimer
	JSR		F_DisableRFC
	JSR		F_Timercal
	
	LDA		R_TM1Data_LB
	STA		RW_RefValue+0
	LDA		R_TM1Data_HB
	STA		RW_RefValue+1
	

	LDA		RW_RefValue+0
	ORA		RW_RefValue+1
	BNE		L_DetectRefPass?
	JMP		L_TempRFC_Fail
L_DetectRefPass?:	
	JSR			F_DischargeRfcIO
    %SetTimerData   0x0FFF
	JSR		F_EnableRfcTimer			;test frequence	of Rsen
	%EnableRT
	LDA		R_RFC_States
	AND		#.not.0x07
	ORA		#D_RFC_ScanSen2
	STA		R_RFC_States
	RTS
; ===========================================================
; Function Name:	F_TSen2Osc
; Purpose:			
; Parameters:		
; Return:			
; Destroy:		
; ===========================================================
F_TSen2Osc:
	JSR		F_DisableRfcTimer
	JSR		F_DisableRFC
	JSR		F_Timercal
	
	LDA		R_TM1Data_LB
	STA		RW_TmpValue+0
	LDA		R_TM1Data_HB
	STA		RW_TmpValue+1
	
	
;	SEC
;	LDA		RW_TmpValue+0
;	SBC		RW_RefValue+0
;	STA		RW_TmpValue+0
;	LDA		RW_TmpValue+1
;	SBC		RW_RefValue+1
;	STA		RW_TmpValue+1	
	
	
		
	
	LDA		RW_TmpValue+0
	ORA		RW_TmpValue+1
	BNE		L_DetectSen1Pass?
	JMP		L_TempRFC_Fail
L_DetectSen1Pass?:
	
	JSR			F_DischargeRfcIO
    %SetTimerData   0x0FFF
	JSR		F_EnableRfcTimer			;test frequence	of Rsen
	%EnableRH
	LDA		R_RFC_States
	AND		#.not.0x07
	ORA		#D_RfcStatTempCalc
	STA		R_RFC_States
	RTS
	
; ===========================================================
; Function Name:	F_UpdateData
; Purpose:			
; Parameters:		
; Return:			
; Destroy:		
; ===========================================================
F_RFC_GetTemper:				;frequence of Rsen -> R_CntSen
	JSR		F_DisableRfcTimer
	JSR		F_DisableRFC
	JSR		F_Timercal

	LDA		#00h
	STA		R_RFC_Control
	
	LDA		R_TM1Data_LB
	STA		RW_HumValue+0
	LDA		R_TM1Data_HB
	STA		RW_HumValue+1

	
	
;	SEC
;	LDA		RW_HumValue+0
;	SBC		RW_RefValue+0
;	STA		RW_HumValue+0
;	LDA		RW_HumValue+1
;	SBC		RW_RefValue+1
;	STA		RW_HumValue+1
	

	
	
	LDA		RW_HumValue+0
	ORA		RW_HumValue+1
	BNE		L_DetectSen2Pass?
	JMP		L_TempRFC_Fail
	
L_DetectSen2Pass?:	

	LDA		RW_RefValue
	STA		RW_AvgRefValue
	STA		R2K_LB
	LDA		RW_RefValue+1
	STA		RW_AvgRefValue+1
	STA		R2K_HB
	;---------------------------------------------

	
;	LDA		R_RFC_Control
	LDA		#D_Cal_ready
	STA		R_RFC_Control	
	
	LDA		R_RFC_States
	AND		#.not.0x07
	ORA		#D_RFC_ScanIdle
	STA		R_RFC_States

	RTS
;================calc================================
F_Calculate_Temp_Hum_Proc:

	LDA		R_RFC_Control
	AND		#D_Cal_ready
	BNE		?L_Calculate_enable

	RTS
?L_Calculate_enable:
	LDA		#00000000b
    STA		P_IO_PortC_Attrib		
    LDA		#00000000b	
    STA		P_IO_PortC_Dir
    LDA		#11111111b
	STA		P_IO_PortC_Data	    ; ‰»Î
        
	LDA		#D_Cal_ing
	STA		R_RFC_Control
	JSR		F_Calculate_Temp
	JSR		F_Calculate_Hum

    LDA     R_Sample_Count
    CMP     #0
    BNE     ?L_Store_2
    JSR     F_Store_Buf1
    JMP     ?L_Next_Sample
?L_Store_2:
    CMP     #1
    BNE     ?L_Store_3
    JSR     F_Store_Buf2
    JMP     ?L_Next_Sample
?L_Store_3:
    JSR     F_Store_Buf3
    JSR     F_Filter_Temp_Hum
    
    JSR		F_Temp_C2F_Modul

    LDA     #0
    STA     R_Sample_Count
    JMP     ?L_Finish_Calc

?L_Next_Sample:
    INC     R_Sample_Count
    LDA     #00h
    STA     R_RFC_Control
    JSR     F_Start_RFC
    RTS

?L_Finish_Calc:
	LDA		#00h
	STA		R_RFC_Control
	
	LDA		R_RFC_States
	AND		#.not.0x07
;	ORA		#(D_RFC_CalculateDone+D_RFC_TempDataReady)
	STA		R_RFC_States
	%bits	R_TimeStatus,AddOthers
	RTS	

L_TempRFC_Fail:
;	LDA		#0x07
;	STA		R_RFC_States
	LDA		R_RFC_States
	AND		#.not.0x07
	STA		R_RFC_States	
	JSR		F_DisableRfcTimer
	JSR		F_DisableRFC
	LDA		#00000000b
    STA		P_IO_PortC_Attrib		
    LDA		#00000000b	
    STA		P_IO_PortC_Dir
    LDA		#11111111b
	STA		P_IO_PortC_Data	    ; ‰»Î	
	RTS

F_Store_Buf1:
    LDA RB_HumDataBCD
    STA R_Hum_Buf1
    LDA R_Temp_N_bytes
    STA R_Temp_Buf1+0
    LDA RW_LastTem+2
    STA R_Temp_Buf1+1
    LDA RW_LastTem+1
    STA R_Temp_Buf1+2
    LDA RW_LastTem
    STA R_Temp_Buf1+3
    RTS

F_Store_Buf2:
    LDA RB_HumDataBCD
    STA R_Hum_Buf2
    LDA R_Temp_N_bytes
    STA R_Temp_Buf2+0
    LDA RW_LastTem+2
    STA R_Temp_Buf2+1
    LDA RW_LastTem+1
    STA R_Temp_Buf2+2
    LDA RW_LastTem
    STA R_Temp_Buf2+3
    RTS

F_Store_Buf3:
    LDA RB_HumDataBCD
    STA R_Hum_Buf3
    LDA R_Temp_N_bytes
    STA R_Temp_Buf3+0
    LDA RW_LastTem+2
    STA R_Temp_Buf3+1
    LDA RW_LastTem+1
    STA R_Temp_Buf3+2
    LDA RW_LastTem
    STA R_Temp_Buf3+3
    RTS

F_Filter_Temp_Hum:
    ; --- Filter Humidity ---
    LDA R_Hum_Buf1
    CMP R_Hum_Buf2
    BCC ?L_Hum_1_LE_2
    LDX R_Hum_Buf1
    LDY R_Hum_Buf2
    STY R_Hum_Buf1
    STX R_Hum_Buf2
?L_Hum_1_LE_2:
    LDA R_Hum_Buf2
    CMP R_Hum_Buf3
    BCC ?L_Hum_2_LE_3
    LDX R_Hum_Buf2
    LDY R_Hum_Buf3
    STY R_Hum_Buf2
    STX R_Hum_Buf3
?L_Hum_2_LE_3:
    LDA R_Hum_Buf1
    CMP R_Hum_Buf2
    BCC ?L_Hum_Sorted
    LDX R_Hum_Buf1
    LDY R_Hum_Buf2
    STY R_Hum_Buf1
    STX R_Hum_Buf2
?L_Hum_Sorted:
    LDA R_Hum_Buf2
    STA RB_HumDataBCD
    
    ; --- Filter Temperature ---
    JSR F_Compare_Buf1_Buf2
    BCC ?L_Temp_1_LE_2
    JSR F_Swap_Buf1_Buf2
?L_Temp_1_LE_2:
    JSR F_Compare_Buf2_Buf3
    BCC ?L_Temp_2_LE_3
    JSR F_Swap_Buf2_Buf3
?L_Temp_2_LE_3:
    JSR F_Compare_Buf1_Buf2
    BCC ?L_Temp_Sorted
    JSR F_Swap_Buf1_Buf2
?L_Temp_Sorted:
    LDA R_Temp_Buf2+0
    STA R_Temp_N_bytes
    LDA R_Temp_Buf2+1
    STA RW_LastTem+2
    LDA R_Temp_Buf2+2
    STA RW_LastTem+1
    LDA R_Temp_Buf2+3
    STA RW_LastTem
    RTS

F_Compare_Buf1_Buf2:
    LDA R_Temp_Buf1
    CMP R_Temp_Buf2
    BNE ?L_Diff_Sign
    LDA R_Temp_Buf1
    BNE ?L_Neg_Case
    JMP F_Compare_Abs_1_2
?L_Neg_Case:
    JSR F_Compare_Abs_1_2
    BCC ?L_Abs1_LT_Abs2
    CLC
    RTS
?L_Abs1_LT_Abs2:
    SEC
    RTS
?L_Diff_Sign:
    LDA R_Temp_Buf1
    CMP #0
    BEQ ?L_Buf1_Pos
    CLC
    RTS
?L_Buf1_Pos:
    SEC
    RTS

F_Compare_Abs_1_2:
    LDA R_Temp_Buf1+1
    CMP R_Temp_Buf2+1
    BNE ?L_Ret
    LDA R_Temp_Buf1+2
    CMP R_Temp_Buf2+2
    BNE ?L_Ret
    LDA R_Temp_Buf1+3
    CMP R_Temp_Buf2+3
?L_Ret:
    RTS

F_Swap_Buf1_Buf2:
    LDX R_Temp_Buf1+0
    LDY R_Temp_Buf2+0
    STY R_Temp_Buf1+0
    STX R_Temp_Buf2+0
    LDX R_Temp_Buf1+1
    LDY R_Temp_Buf2+1
    STY R_Temp_Buf1+1
    STX R_Temp_Buf2+1
    LDX R_Temp_Buf1+2
    LDY R_Temp_Buf2+2
    STY R_Temp_Buf1+2
    STX R_Temp_Buf2+2
    LDX R_Temp_Buf1+3
    LDY R_Temp_Buf2+3
    STY R_Temp_Buf1+3
    STX R_Temp_Buf2+3
    RTS

F_Compare_Buf2_Buf3:
    LDA R_Temp_Buf2
    CMP R_Temp_Buf3
    BNE ?L_Diff_Sign_23
    LDA R_Temp_Buf2
    BNE ?L_Neg_Case_23
    JMP F_Compare_Abs_2_3
?L_Neg_Case_23:
    JSR F_Compare_Abs_2_3
    BCC ?L_Abs2_LT_Abs3
    CLC
    RTS
?L_Abs2_LT_Abs3:
    SEC
    RTS
?L_Diff_Sign_23:
    LDA R_Temp_Buf2
    CMP #0
    BEQ ?L_Buf2_Pos
    CLC
    RTS
?L_Buf2_Pos:
    SEC
    RTS

F_Compare_Abs_2_3:
    LDA R_Temp_Buf2+1
    CMP R_Temp_Buf3+1
    BNE ?L_Ret_23
    LDA R_Temp_Buf2+2
    CMP R_Temp_Buf3+2
    BNE ?L_Ret_23
    LDA R_Temp_Buf2+3
    CMP R_Temp_Buf3+3
?L_Ret_23:
    RTS

F_Swap_Buf2_Buf3:
    LDX R_Temp_Buf2+0
    LDY R_Temp_Buf3+0
    STY R_Temp_Buf2+0
    STX R_Temp_Buf3+0
    LDX R_Temp_Buf2+1
    LDY R_Temp_Buf3+1
    STY R_Temp_Buf2+1
    STX R_Temp_Buf3+1
    LDX R_Temp_Buf2+2
    LDY R_Temp_Buf3+2
    STY R_Temp_Buf2+2
    STX R_Temp_Buf3+2
    LDX R_Temp_Buf2+3
    LDY R_Temp_Buf3+3
    STY R_Temp_Buf2+3
    STX R_Temp_Buf3+3
    RTS

	

	
.ends
