;==================================================================================
; The information contained herein is the exclusive property of
; Generalplus Technology Co. And shall not be distributed, reproduced,
; or disclosed in whole in part without prior written permission.
;       (C) COPYRIGHT 2012   Generalplus TECHNOLOGY CO.                            
;                   ALL RIGHTS RESERVED
; The entire notice above must be reproduced on all authorized copies.
;==================================================================================
;==================================================================================
; Name                  : INT_VEC.asm
; Applied Body          : GPL812PX
; Programmer            : 
; Description           : Interrupt vector declare and service routine
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
.INCLUDE	include\Project.inc
.INCLUDE	include\Macro.inc
.INCLUDE	include\Key.inc
;.INCLUDE	include\rtc.inc
;.INCLUDE	include\user.inc
.INCLUDE		RFC\RFC_user.inc
;==========================================
; External declare area
;==========================================
.EXTERNAL V_RESET


;==========================================
; Public declare area
;==========================================



;==========================================
;Variable RAM declare area
;==========================================
.PAGE0

RB_128HZTO2HZ_temp:		.ds		1
;==========================================
; code starting 
;==========================================
.CODE


;==========================================
; IRQ INTERRUPT SERVICE ROUTINE
;==========================================
V_IRQ: 
	%M_PushAll
  	.if	(GPL812P01Bx_Mode=EV_Simualtion)
		LDA		P_INT_Clear1
		AND		#D_TBH_INT_En
		BEQ		L_ExitEVBINT
		
		LDA		P_INT_Ctrl1
		AND		#D_TBH_INT_En
		BEQ		L_ExitEVBINT
		
		
		LDA		#D_TBH_INT_En
		STA		P_INT_Clear1
		
		INC		R_128Hz_Count
		
		LDA		R_DebounceCnt
		BEQ		?Check_temp
		DEC		R_DebounceCnt		;按键消抖
	?Check_temp:		
		
		INC		RB_128HZTO2HZ_temp
		
		LDA		RB_128HZTO2HZ_temp
		CMP		#08H
		BCC		L_ExitEVBINT
		
		LDA		#00H
		STA		RB_128HZTO2HZ_temp
		
	
		JSR		F_RFC_porccess
		
		
		
		
	L_ExitEVBINT:
	.ELSE
		LDA		P_INT_Clear1
		AND		#D_TBH_INT_En
		BEQ		L_ExitotpINT
		
		LDA		P_INT_Ctrl1
		AND		#D_TBH_INT_En
		BEQ		L_ExitotpINT		
		
		LDA		#D_TBH_INT_En
		STA		P_INT_Clear1
		
		LDA		R_DebounceCnt
		BEQ		?Check_temp
		DEC		R_DebounceCnt		;按键消抖
	?Check_temp:		
		
		INC		RB_128HZTO2HZ_temp
		
		LDA		RB_128HZTO2HZ_temp
		CMP		#08H
		BCC		L_ExitotpINT
		
		LDA		#00H
		STA		RB_128HZTO2HZ_temp
		
	
		JSR		F_RFC_porccess

		
	L_ExitotpINT:
	
	.endif  
	
		LDA		P_INT_Clear1
		AND		#D_TBL_INT_En
		BEQ		L_ExitINT
		
		LDA		P_INT_Ctrl1
		AND		#D_TBL_INT_En
		BEQ		L_ExitINT
		
		
		LDA		#D_TBL_INT_En
		STA		P_INT_Clear1

		
		INC		R_2Hz

	L_ExitINT:	
;---------------------------------------------------------------		
;?L_CheckKeyToneTime:	;增加按键音时长检测
		
;	?Check_TBL:					;2Hz INT
;		LDA	P_INT_Clear1
;		AND	#D_TBL_Clr
;		BEQ	?Exit_Int
;		STA	P_INT_Clear1		;clear int flag
;		INC	R_2Hz

;	?Exit_Int:	
		%M_PopAll  
		RTI
    
;==========================================
; NMI INTERRUPT SERVICE ROUTINE
;==========================================
V_NMI:
    
    
RTI

;==========================================
; Vector declare
;==========================================
VECTOR: .SECTION     
    DW  V_NMI               ; Non-mask interrupt vector
    DW  V_RESET             ; Reset vector
    DW  V_IRQ               ; interrupt vector
        .ENDS

.END

