	.IFDEF		GPL812_SERIES

;---------------------------------
GPL812P01Bx		.EQU		1
;---------------------------------

.IFNDEF GPL812PX_Body_inc
GPL812PX_Body_inc:   .EQU    1
;==================================================================================
; The information contained herein is the exclusive property of
; Generalplus Technology Co. And shall not be distributed, reproduced,
; or disclosed in whole in part without prior written permission.
;       (C) COPYRIGHT 2012   Generalplus TECHNOLOGY CO.                            
;                   ALL RIGHTS RESERVED
; The entire notice above must be reproduced on all authorized copies.
;==================================================================================
;==================================================================================
; Program Name: GPL812PX series register declare
; Applied body: GPL812PX series
; Programmer  : 
; Description : 
;             : 
; History version
; Rev #       Date          Who            Comments
; -------  -----------    --------         ----------------------------------------
; 1.0       2012-05-07     CharissaHsu	Oringinal Version
; 1.1		2012/06/25     CharissaHsu	Add User Rom Checksum Macro
; 1.2       2014/08/20     Ken Liu		Add Body:GPL81202A,GPL81201A
; 1.3       2018/01/19     Neo Chuang   Add Body:GPL812P01A
; 1.4       2018/08/07     Neo Chuang   Add Body:GPL812P01B
;==================================================================================
;==================================================================================


		.IFNDEF	GPL812P01Bx
			GPL812P01Bx: 	.EQU		0
		.ENDIF

 	 
.IF (GPL812P01Bx)
GPL812PX		.EQU		1
.ENDIF
	.IFDEF	GPL812PX
		.PAGE0
  
;=================  INT/NMI Register  ================
P_SRAM_Ctrl:							.EQU    $3F    
      
;===================  IO Register  ===================
P_IO_Green_Ctrl:						.EQU    $11			; IO Green mode selection register
	D_IO_GreenEn:								.EQU	   00100000B	
	D_IO_GreenDis:							.EQU	   00000000B
	
P_IO_PortA_Dir							.EQU    $0B
P_IO_PortA_Attrib:						.EQU    $03
P_IO_PortA_Data:						.EQU    $07
P_IO_PortA_Buffer:						.EQU    $0C
P_IOA_LCDPORT_Ctrl:						.EQU    $4A			;PA[7:0]=SEG13:6
P_IOA_SEGCOM_Ctrl:						.EQU    $48
	D_PortA6_COM6:						.EQU    01000000B
	D_PortA7_COM7:						.EQU    10000000B

P_IO_PortB_Dir:							.EQU    $00
P_IO_PortB_Attrib:						.EQU    $04
P_IO_PortB_Data:						.EQU    $08
P_IO_PortB_Buffer:						.EQU    $0D
P_IO_PortB_Strobe_En:				 	.EQU    $2D

P_IOB_LCDPORT_Ctrl:						.EQU    $4B			;PB[3:0]SEG5:2
P_IOB_SEGCOM_Ctrl:						.EQU    $49
	D_PortB0_COM0:						.EQU    00000001B
	D_PortB1_COM1:						.EQU    00000010B
	D_PortB2_COM2:						.EQU    00000100B
	D_PortB3_COM3:						.EQU    00001000B	

P_IO_PortC_Dir:							.EQU    $01
P_IO_PortC_Attrib:						.EQU    $05
P_IO_PortC_Data:						.EQU    $09
P_IO_PortC_Buffer:						.EQU    $0E
P_IO_PortC_Strobe_En:					.EQU    $2E
P_IOC_LCDPORT_Ctrl:						.EQU    $4C		;PC[7:0]=SEG[5:2] ,PC[1:0]=SEG[15:14]
P_IOC_SEGCOM_Ctrl						.EQU    $34
	D_PortC0_COM5:						.EQU    00000001B
	D_PortC1_COM4:						.EQU    00000010B
	D_PortC4_COM3:						.EQU    00010000B
	D_PortC5_COM2:						.EQU    00100000B
	D_PortC6_COM1:						.EQU    01000000B
	D_PortC7_COM0:						.EQU    10000000B

P_IO_PortD_Dir:							.EQU    $02
P_IO_PortD_Attrib:						.EQU    $06
P_IO_PortD_Data:						.EQU    $0A
P_IO_PortD_Buffer:						.EQU    $0F
P_IO_PortD_Strobe_En:					.EQU    $2F
P_IOD_LCDPORT_Ctrl:						.EQU    $35
	D_PortD2_SEG1:						.EQU    00000100B
	D_PortD3_SEG0:						.EQU    00001000B
;===================  System Register  ===================
P_SYSTEM_Ctrl:							.EQU    $12						; System sleep source.
	D_SYS_Sleep:						.EQU	10101010B				; System goes to sleep bit.
P_SYSTEM_Green_Ctrl:         			.EQU    $17                     ; System Green mode selection register.
	D_GreenDis:							.EQU	00000000B
	D_GreenEn:							.EQU	01000000B
;===============   Watch Dog Register  ===============
P_WDT_Flag_Clear:						.EQU	$20
	D_WDT_Clear:						.EQU	10101010B

;=================  INT/NMI Register  ================
P_INT_Ctrl0:							.EQU    $13							; Interrupt control.
	D_INT_Ctrl0_Dis:						.EQU	  00000000B				; bit[7,5] must be fill '0'
	D_CPUDiv2MHz_INT_En:          			.EQU	  00000001B				; Fosc divided 2097152 interrupt enabled bit.
	D_CPUDiv32KHz_INT_En:           		.EQU	  00000010B				; Fosc divided 32768 interrupt enabled bit.
	D_CPUDiv4KHz_INT_En:					.EQU	  00000100B				; Fosc divided 4096 interrupt enabled bit.
	D_CPUDiv1KHz_INT_En:					.EQU	  00001000B				; Fosc divided 1024 interrupt enabled bit.
	D_TM1O_INT_En:          				.EQU	  00010000B				; Timer1 overflow interrupt enabled bit.
	D_TM0O_INT_En:          				.EQU	  01000000B				; Timer0 overflow interrupt enabled bit.
	
P_INT_Clear0:							.EQU    $14							; Interrupt Flag. Write 1 to clear interrupt flag.
	D_2MHz_Clr:								.EQU	  00000001B				; Fosc divided 2M interrupt flag bit.
	D_32KHz_Clr:							.EQU	  00000010B				; Fosc divided 32K interrupt flag bit.
	D_4KHz_Clr:          			 	 	.EQU	  00000100B				; Fosc divided 4K interrupt flag bit.
	D_1KHz_Clr:          			 	 	.EQU	  00001000B				; Fosc divided 1K interrupt flag bit.
	D_TM1O_Clr:          			 	 	.EQU	  00010000B				; Timer1 overflow interrupt flag bit.
	D_TM0O_Clr:          			 	 	.EQU	  01000000B				; Timer0 overflow interrupt flag bit.

P_INT_Ctrl1:         				    .EQU    $15							; Interrupt control.
	D_INT_Ctrl1_Dis:					  	.EQU	  00000000B	
	D_TBL_INT_En:          		  			.EQU	  00010000B				; 32K Time Base low frequency interrupt	enable bit.
	D_TBH_INT_En:          		  			.EQU	  00100000B				; 32K Time Base high frequency interrupt enable bit.
	
P_INT_Clear1:         				    .EQU    $16							; Interrupt Flag. Write 1 to clear interrupt flag.								
	D_TBL_Clr:								.EQU	  00010000B				; 32K Time Base high frequency interrupt flag bit.
	D_TBH_Clr:								.EQU	  00100000B				; 32K Time Base high frequency interrupt flag bit.	


P_INT_Ctrl2:         				    .EQU    $18							; Interrupt control.
	D_INT_Ctrl2_Dis:					  	.EQU	  00000000B				; bit[7,5] must be fill '0'
	D_EXT_INT0:								.EQU	  00000001B				; External interrupt 1 enabled bit.
	D_EXT_INT1:								.EQU	  00000010B				; External interrupt 0 enabled bit.
	
P_INT_Clear2:         				    .EQU    $19							; Interrupt flag.
	D_PB0_Clr:								.EQU		00000001B			; External interrupt 0 flag bit.
	D_PB1_Clr:								.EQU		00000010B			; External interrupt 1 flag bit.


P_RFC_Ctrl:         				   	.EQU    $1E							; RFC function control
	D_RFC0_PC4:								.EQU		00000001B			; RFC selecttion bit 0
	D_RFC1_PC5:								.EQU		00000010B			; RFC selecttion bit 1
	D_RFC2_PC6:								.EQU		00000100B			; RFC selecttion bit 2
	D_RFCEN:								.EQU		00001000B			; RFC function enable bit
	D_RFCDis:								.EQU		00000000B
	

;=================  Timer Register  ==================
P_TIMER_Timer0_Ctrl:					 .EQU   $21								; Timer0 control.
	D_TM0Fosc:								.EQU		00000000B				; Fosc/1 as Timer0 clock.
	D_TM0FoscDiv2:							.EQU		00010000B				; Fosc/2 as Timer0 clock.
	D_TM0FoscDiv4:							.EQU		00100000B				; Fosc/4 as Timer0 clock.
	D_TM0FoscDiv16:							.EQU		00110000B				; Fosc/16 as Timer0 clock.
	D_TM0En:								.EQU		10000000B				; Timer0 Enable Selected function is Enabled.
	D_TM0Dis:								.EQU		00000000B				; Timer0 Enable Selected function is Disabled.

P_TIMER_Timer1_Ctrl:         			 .EQU   $22								; Timer1 control. bit0 must be fill '0'
	D_TM1Fosc:								.EQU		00000000B				; Fosc/1 as Timer1 clock.
	D_TM1FoscDiv4:							.EQU		00010000B				; Fosc/4 as Timer1 clock.
	D_TM1FoscDiv64:							.EQU		00100000B				; Fosc/64 as Timer1 clock.
	C_TM1CLK_TM0OF:							.EQU		00110000B				; clock source use Timer0 clock over flow.
	D_TM1PortC7TM1Clk:						.EQU		01000000B				; Timer1 clock source from IO selection. (RFC using)
	D_TM1En:								.EQU		10000000B				; Timer1 Enable Selected function is Enabled.
	D_TM1Dis:								.EQU		00000000B				; Timer1 Enable Selected function is Disabled.	

P_TIMER_TM0Data_LB:         			 .EQU   $23								; Write 8-bit	counter rgister in 8-bit Timer0. 
																				
P_TIMER_TM1Data_LB:         			 .EQU   $25								; Write low 8-bit counter register in 12-bit Timer1.(W)
P_TIMER_TM1Data_HB:         			 .EQU   $26								; Write high 4-bit counter register in 12-bit Timer1.(W)

P_CLK_32768_En:         				 .EQU   $2A
	D_32768En:								.EQU		10000000B
	D_32768Dis:								.EQU		00000000B	;bit[5,2:0] msut be fill '0'
P_TIMER_TimeBase_Sel:					.EQU   $2B
	D_32kStr_T2sec:							.EQU		00000000B	
	D_32kStr_T4sec:							.EQU		00010000B
	D_TBL2Hz:								.EQU		00000000B	
	D_TBL4Hz:								.EQU		00001000B
	D_TBL8Hz:								.EQU		00000100B
	D_TBL16Hz:								.EQU		00001100B
	D_TBH128Hz:								.EQU		00000000B
	D_TBH256Hz:								.EQU		00000010B
	D_TBH512Hz:								.EQU		00000001B
	D_TBH1KHz:								.EQU		00000011B
P_IO_Strobe_En:							.EQU   $2C                        
 	D_StrobeDis:							.EQU		00000000B              
  	D_StrobeEn:								.EQU		00000001B               
                

;==============  Sleep/Wakeup Register  ==============
P_WAKEUP_Ctrl:         		 			.EQU   $30   
	D_KeyDis:								.EQU		00000000B
	D_KeyEn:								.EQU		00000001B
	D_TBLEn:								.EQU		00000010B
	D_TBLDis:								.EQU		00000000B
	D_TBHEn:								.EQU		00001000B
	D_TBHDis:								.EQU		00000000B

P_WAKEUP_Flag:         		 			.EQU   $31   
	D_KEYWFC_En:							.EQU		00000001B
	D_KEYWFC_Dis:							.EQU		00000000B
	D_TBLWFC_En:							.EQU		00000010B
	D_TBLWFC_Dis:							.EQU		00000000B
	D_TBHWFC_En:							.EQU		00001000B
	D_TBHWFC_Dis:							.EQU		00000000B
		
P_IO_PortB_WakeUpEN:						.EQU   $37 	
P_IO_PortC_WakeUpEN:						.EQU   $38   
P_IO_PortD_WakeUpEN:						.EQU   $39   

;==============  LCD Register  ==============
P_LCD_Ctrl:					       		.EQU   $32	

	D_LCDGreenMode_Dis:						.EQU		10010000B
	D_LCDGreenMode_En:						.EQU		10000000B

	D_LCDMode_Normal:						.EQU		00000000B
	D_LCDMode_AllOn:						.EQU		00000001B
	D_LCDMode_AllOff:						.EQU		00000010B
	D_LCDMode_DisplayOff:					.EQU		00000011B
	
	D_LCDSetting_3Bias_4Duty:				.EQU		00000000B
	D_LCDSetting_3Bias_5Duty:				.EQU		00000100B
	D_LCDSetting_3Bias_6Duty:				.EQU		00001000B
	D_LCDSetting_4Bias_8Duty:				.EQU		00001100B	
	
	D_LCD_VLCD2_5V:							.EQU		00000000B
	D_LCD_VLCD2_4V:							.EQU		00100000B	
	D_LCD_VLCD2_8V:							.EQU		01000000B	
	D_LCD_VLCDVDD:							.EQU		01100000B	
	
;==============  LVD function Register  ==============   
P_LVD_Ctrl:					         	.EQU   $33  

	D_LVDS_2_7V:							.EQU		01000000B
	D_LVDS_2_1V:							.EQU		00000000B
	D_LVDS_2_4V:							.EQU		00100000B
	D_LVD_En:								.EQU		10000000B
	D_LVD_Dis:								.EQU		00000000B
;==============  PWM function Register  ==============	
P_PWM_IO_Ctrl:				.EQU    $11				
	D_TX_En:								.EQU		00000000B
	D_IO_En:									.EQU		00100000B
	D_Driving_50mA:						.EQU		00000000B
	D_Driving_100mA:					.EQU		00001000B
	D_Driving_200mA:					.EQU		00010000B
	D_Driving_400mA:					.EQU		00011000B
P_PWM_EN:         				.EQU    $17
	D_PWMEn:								.EQU		00000000B
	D_PWMDis:								.EQU		01000000B	
;**********************************************************************
;ROM Checksum
;**********************************************************************

D_Bank0UserRomStartAddr:		.EQU	0xE000		;0xE000 ~ 0xFFFF: User ROM Code

D_Bank0UserRomEndAddr:			.EQU	0xFFF6		;0xFFF7 ~ 0xFFF9 are reserved for Generalplus used
D_NMIandResetVectorStartAddr:	.EQU	0xFFFA		
D_NMIandResetVectorEndAddr:		.EQU	0xFFFF


; ========================================================================================
; Macro Name	: M_UserRomChecksum
; Parameters	: None
; Return Value	: R_ChecksumResult: bit[7:0]
;				: R_ChecksumResult + 1: bit[15:8]
;				: R_ChecksumResult + 2: bit[23:16]
;				: R_ChecksumResult + 3: bit[31:24]
; Description	: Calculate user ROM area code checksum
; Destroy		: A, Y
; Example		: %M_UserRomChecksum	R_ChecksumAddrPtr, R_ChecksumResult
; ========================================================================================	
%M_UserRomChecksum:	.MACRO	R_ChecksumAddrPtr, R_ChecksumResult
	LDA		#0
	STA		R_ChecksumResult					;Result Byte0
	STA		R_ChecksumResult + 1				;Result Byte1
	STA		R_ChecksumResult + 2				;Result Byte2
	STA		R_ChecksumResult + 3				;Result Byte3
;=================== Bank 0 ==================================================	
	LDA		#.HIGH.D_Bank0UserRomStartAddr
	STA		R_ChecksumAddrPtr + 1				; Start High Byte
	LDA		#.LOW.D_Bank0UserRomStartAddr
	STA		R_ChecksumAddrPtr					;Start Low Byte
	LDY		#0
L_ChecksumLoop1?
	LDA		#D_WDT_Clear
	STA		P_WDT_Flag_Clear	
	CLC
	LDA		(R_ChecksumAddrPtr),Y
	ADC		R_ChecksumResult					;Result Low Byte
	STA		R_ChecksumResult					;Result Low Byte
	BCC		L_CheckAddress1?
	INC		R_ChecksumResult + 1				;Result Byte1
	BNE		L_CheckAddress1?
	INC		R_ChecksumResult + 2				;Result Byte3
	BNE		L_CheckAddress1?
	INC		R_ChecksumResult + 3				;Result Byte4
		
L_CheckAddress1?:
	LDA		R_ChecksumAddrPtr + 1				;Address Pointer HB
	CMP		#.HIGH.D_Bank0UserRomEndAddr		;End High Byte
	BNE		L_IncreaseAdd1?
	
	LDA		R_ChecksumAddrPtr					;Address Pointer LB
	CMP		#.LOW.D_Bank0UserRomEndAddr			;End Low Byte
	BEQ		L_ExitRomSum1?
	
L_IncreaseAdd1?:
	INC		R_ChecksumAddrPtr					;Address Pointer LB
	BNE		L_ChecksumLoop1?
	INC		R_ChecksumAddrPtr + 1				;Address Pointer HB
	JMP		L_ChecksumLoop1?	
		
L_ExitRomSum1?:	
;===================NMI & Reset Vector==================================================		
	LDA		#.HIGH.D_NMIandResetVectorStartAddr
	STA		R_ChecksumAddrPtr + 1				; Start High Byte
	LDA		#.LOW.D_NMIandResetVectorStartAddr
	STA		R_ChecksumAddrPtr				;Start Low Byte
		
L_ChecksumLoop2?
	LDA		#D_WDT_Clear
	STA		P_WDT_Flag_Clear
	CLC
	LDA		(R_ChecksumAddrPtr),Y
	ADC		R_ChecksumResult					;Result Low Byte
	STA		R_ChecksumResult					;Result Low Byte
	BCC		L_CheckAddress2?
	INC		R_ChecksumResult + 1				;Result Byte2
	BNE		L_CheckAddress2?
	INC		R_ChecksumResult + 2				;Result Byte3
	BNE		L_CheckAddress2?
	INC		R_ChecksumResult + 3				;Result Byte4
		
L_CheckAddress2?:
	LDA		R_ChecksumAddrPtr + 1				;Address Pointer HB
	CMP		#.HIGH.D_NMIandResetVectorEndAddr	;End High Byte
	BNE		L_IncreaseAdd2?
	
	LDA		R_ChecksumAddrPtr					;Address Pointer LB
	CMP		#.LOW.D_NMIandResetVectorEndAddr	;End Low Byte
	BEQ		L_EndChecksum?
	
L_IncreaseAdd2?:
	INC		R_ChecksumAddrPtr					;Address Pointer LB
	BNE		L_ChecksumLoop2?
	INC		R_ChecksumAddrPtr + 1				;Address Pointer HB
	JMP		L_ChecksumLoop2?	
	
L_EndChecksum?:

	.ENDM

EV_Simualtion		.EQU	0
OTP_BurnIn			.EQU	1
GPL812P01Bx_Mode	.EQU	OTP_BurnIn

	
			.ENDIF
			.ENDIF
	.ENDIF
