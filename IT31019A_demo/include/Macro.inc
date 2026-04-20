;==========================================
; Constant define area
;==========================================
D_DebounceTime	        EQU    0x03     ;7.8125ms*3=23.4735ms    消抖时间  ;128Hz
D_LongKeyTime	        EQU    255      ;7.8125ms*255=2s 
D_TenSecond             EQU    20       ;0.5s*20=10s
D_OneMinute             EQU    120      ;0.5s*120=60s ;在设置模式下,若1MIN无Key按下,自动保存退出,显示正常时间
	


C_SramAddrStart		    EQU	    80H		;SRAM start address
C_SramAddrEnd   		EQU		FFH		;GPL11B SRAM end address
C_DPRAMAddrStart		EQU		50H		;DPRAM start address
C_DPRAMAddrEnd   		EQU		5FH		;GPL812P02A DPRAM end address


D_SetHour				equ		04H
D_SetMinute				equ		05H

D_30SecLightOn					equ		60
C_10Sec					equ		21			;20/2=10sec 	
	
D_Bit0					equ		01H
D_Bit1					equ		02H
D_Bit2					equ		04H
D_Bit3					equ		08H
D_Bit4					equ		10H
D_Bit5					equ		20H
D_Bit6					equ		40H
D_Bit7					equ		80H
;;============================================================================
;Macro Name: %M_ClearWatchDog
;Purpose: Clear Watchdog
;Destroy: A
;;============================================================================
%M_ClearWatchDog:		.MACRO 
	LDA		#D_WDT_Clear
	STA		P_WDT_Flag_Clear
	.ENDM

;==========================================
; Macro Name:	%FillSram
; Description:	Fill data to SRAM $80 ~ $fF
; Input:		mData
;==========================================
%RAM_Init:		.MACRO	
		LDy		#0
		LDA		#0	
?L_FillRAMLOOP:	
		STA		$80,y
		INy
		CPy		#128
		BCC		?L_FillRAMLOOP
.ENDM


%RAM2_Init:		.macro
	
		LDX		#00		
		LDA		#00
	?Loop:
		STA		$01C0,x
		INX
		CPX		#64
		BCC		?Loop		
.endm



%GotoSleep:		.MACRO
				LDA		#D_SYS_Sleep
				STA		P_SYSTEM_Ctrl				; Enter Sleep Mode
				NOP
				NOP
				NOP
				.ENDM
;;============================================================================
;Macro Name: %M_DisAllInt
;Purpose: Disable all interrupt 
;Destroy: A
;;============================================================================
%M_DisAllInt:		.MACRO

	LDA	#00H
	STA	P_INT_Ctrl0
	LDA	#FFH	
	STA	P_INT_Clear0
	
	LDA	#00H
	STA	P_INT_Ctrl1
	LDA	#FFH
	STA	P_INT_Clear1

	LDA	#00H
	STA	P_INT_Ctrl2
	LDA	#FFH
	STA	P_INT_Clear2
	
	.ENDM
;;============================================================================
;Macro Name: %DisableLCD
;Purpose: Disable LCD
;Destroy: A
;;============================================================================
%DisableLCD:		.MACRO
	
	LDA	#D_LCDMode_DisplayOff
	STA	P_LCD_Ctrl
	.ENDM
;-----------------------------------------------------------------------------
; Macro Name:	%M_InitLCD
; Description:	Initialize LCD configuration after power on
;-----------------------------------------------------------------------------	
%M_InitLCD:		.MACRO
    LDA		#D_LCDMode_Normal+D_LCDSetting_3Bias_4Duty+D_LCDGreenMode_En
;	LDA		#(D_LCDMode_Normal+D_LCDSetting_3Bias_4Duty)
	STA		P_LCD_Ctrl		;1/4duty,1/3bias,normal scan

	.ENDM
;-----------------------------------------------------------------------------
; Macro Name:	%FillLcdDpram
; Description:	Fill LCD DPRAM $50 ~$5F
;-----------------------------------------------------------------------------
%FillLcdDpram	.MACRO	mData
		
		%M_ClearWatchDog
		LDX		#00H
		LDA     mData
?L_ClrDpramLoop:
		STA		$50,X
		INX
		CPX		#10H
		BNE		?L_ClrDpramLoop	

	.ENDM
;-----------------------------------------------------------------------------
; Macro Name:	%M_PushAll
; Description:	Push
;-----------------------------------------------------------------------------		
%M_PushAll:		.MACRO
		PHP
		PHA
		TXA
		PHA
		TYA
		PHA
			.ENDM
;-----------------------------------------------------------------------------
; Macro Name:	%M_PopAll
; Description:	Pop
;-----------------------------------------------------------------------------	
%M_PopAll:		.MACRO
		PLA
		TAY
		PLA
		TAX
		PLA
		PLP
			.ENDM	

;----------------------------------------------------------
;/***********************************************/
;         i.L=1 
%bits:   .MACRO   i,L             ;BYTE i;  
          lda     i               ;ex.  
          ora     #L              ;  %bits 10H,_BIT0  ;  10H.0=1
          sta     i               ;
         .ENDM    

;/***********************************************/
;         i.L=0
%bitr:   .MACRO   i,L             ;BYTE i;  
          lda     i               ;ex.  
          and     #.NOT.L         ;  %bitr 10H,_BIT0;  10H.0=0
          sta     i
         .ENDM    

;/***********************************************/
;         if(i.L==1) goto N
%btst:   .MACRO   i,L,N           ;BYTE i;  
          lda     i               ;ex.   
          and     #L              ;  %btst 10H,_BIT0,N
          bne     N               ;  if(10H.0=1) goto N 
         .ENDM    
                                  
;/***********************************************/
;         if(i.L==0) goto N
%btsf:   .MACRO   i,L,N           ;BYTE i;    
          lda     i               ;ex.   
          and     #L              ;  %btsf 10H,_BIT0,N
          beq     N               ;  if(10H.0=0) goto N 
         .ENDM    

;/***********************************************/
%F_IO_Intital:	.macro
		LDA		#00000000b
		STA		P_IO_PortA_Attrib	
		LDA		#00000000b		;PA0~PA7 as lcd segment
		STA		P_IO_PortA_Dir
		LDA		#11111111b
		STA		P_IO_PortA_Data
		
		LDA		#00000000b
		STA		P_IO_PortB_Attrib		
		LDA		#00000000b	
		STA		P_IO_PortB_Dir
		LDA		#00001111b
		STA		P_IO_PortB_Data
		
		LDA		#00000000b
		STA		P_IO_PortC_Attrib		
		LDA		#00000000b	
		STA		P_IO_PortC_Dir
		LDA		#11111111b
		STA		P_IO_PortC_Data	
		
		LDA		#00000000b
		STA		P_IO_PortD_Attrib		
		LDA		#10000000b		;PD2,3,5 as input low,PD7,output LOW
		STA		P_IO_PortD_Dir
		LDA		#00101100b
		STA		P_IO_PortD_Data
.endm
;/***********************************************/
%F_INT_Intital:	.macro
		LDA		#D_TBL2Hz+D_TBH128Hz
		STA		P_TIMER_TimeBase_Sel
		LDA		#ffh
		STA		P_INT_Clear0
		STA		P_INT_Clear1
		
		LDA		#D_TBL_INT_En+D_TBH_INT_En
		STA		P_INT_Ctrl1
		
;		LDA	#FFH
;		STA	P_INT_Clear0	
;		STA	P_INT_Clear1

;		LDA	#D_TM0O_INT_En
;		LDA		#00
;		STA P_INT_Ctrl0
		
;		LDA	#(D_TM0En+D_TM0FoscDiv4)
;		STA	P_TIMER_Timer0_Ctrl
;		LDA	#250					;timer0 as buzzer output freq.
;		STA	P_TIMER_TM0Data_LB
;		LDA	#(D_TBL2Hz+D_TBH128Hz)	;
;		STA	P_TIMER_TimeBase_Sel
		
;		LDA	#(D_TBL_INT_En+D_TBH_INT_En)
;		STA	P_INT_Ctrl1	
.ENDM

%EnRedrawFlag:		.macro
	
;		%bits	R_TimeStatus,AddOthers
		%bits	R_DispUpdate,D_NumberUpdate
					.endm

%R_TempPlus:		.macro	i,l
			lda		i
			sta		l
			lda		i+1
			sta		l+1
			lda		i+2
			sta		l+2
			.endm
%R_TempRestor:		.macro	i,l
			lda		l
			sta		i
			lda		l+1
			sta		i+1
			lda		l+2
			sta		i+2
			.endm

%ClearAllNumber:	.MACRO
			LDX		#T_D1
			JSR		F_NoDisplayBit
			LDX		#T_D2
			JSR		F_NoDisplayBit
			LDX		#T_D3
			JSR		F_NoDisplayBit
			LDX		#T_D4
			JSR		F_NoDisplayBit
			LDX		#T_D5
			JSR		F_NoDisplayBit
			LDX		#T_D6
			JSR		F_NoDisplayBit

	.ENDM
		
%M_Power_GreenMode:	.MACRO

	LDA		#D_IO_GreenEn
	STA		P_IO_Green_Ctrl
	LDA		#D_GreenEn
	STA		P_SYSTEM_Green_Ctrl

			
			
.ENDM
;/***********************************************/
