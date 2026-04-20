.IFNDEF _LCD_Define_inc_
_LCD_Define_inc_:    .EQU    1

;==================================================================================
; The information contained herein is the exclusive property of
; Generalplus Technology Co. And shall not be distributed, reproduced,
; or disclosed in whole in part without prior written permission.
;       (C) COPYRIGHT 2009   Generalplus TECHNOLOGY CO.                            
;                   ALL RIGHTS RESERVED
; The entire notice above must be reproduced on all authorized copies.
;==================================================================================
;==================================================================================
; Name                  : LCD_Define.inc
; Applied Body          : 
; Programmer            : 
; Description           : 
; History version       : v1.0.0
; 1.0.0     2017/01/08  Neo    first issue
;==================================================================================
D_LCD_Address			.EQU	0x0050
D_SegNum				.EQU	16				;Max value = 16		,4x16,6x14,8x12
D_ComNum				.EQU	5				;Max value = 8
D_LCDDataSize			.EQU	D_ComNum*2		;LCD RAM Buffer Size
;---------------------------------------------------------------------------------------------
D_LCD_VLCD					.EQU	D_LCD_VLCDVDD
									;D_LCD_VLCDVDD	
									;D_LCD_VLCD2_5V
									;D_LCD_VLCD2_4V
									;D_LCD_VLCD2_8V
D_LCD_BiasDuty				.EQU	D_LCDSetting_3Bias_5Duty
									;D_LCDSetting_3Bias_5Duty
									;D_LCDSetting_3Bias_6Duty
									;D_LCDSetting_4Bias_8Duty
D_LCD_GreenMode				.EQU	D_LCDGreenMode_En
									;D_LCDGreenMode_Dis

D_LCD_Setting				.EQU	D_LCD_VLCD+D_LCD_BiasDuty+D_LCD_GreenMode
; ---------------------- PA0~7=Seg6~13 ----------------------
D_LCD_PortA_Ctrl       .EQU    11111111B    ; 
D_LCD_PortA_COMSEG     .EQU    00000000B    ; PA7~6=Seg13~12

; ---------------------- PortBPB0~3=Com0~3 ----------------------
D_LCD_PortB_Ctrl       .EQU    00001111B    ; 
D_LCD_PortB_COMSEG     .EQU    00001111B    ; PB3~0=Com3~0

; ---------------------- PortCC0=Seg14 ----------------------
D_LCD_PortC_Ctrl       .EQU    00000011B    ;
D_LCD_PortC_COMSEG     .EQU    00000010B    ; PC1=Com4

; ---------------------- PortD---------------------
D_LCD_PortD_Ctrl       .EQU    00000000B    ; PDΪIO

;D_LCD_PortA_Ctrl			.EQU	11111111B		;set PA[7:0] as LCD function
;D_LCD_PortA_COMSEG			.EQU	00000000B		;Set PA[7:6] as segment output
;D_LCD_PortB_Ctrl			.EQU	00001111B		;Set PB[3:0] as LCD function
;D_LCD_PortB_COMSEG			.EQU	00000000B		;Set PB[3:0] as segment output
;D_LCD_PortC_Ctrl			.EQU	11100000B		;Set PortC[7:5] as LCD function
;D_LCD_PortC_COMSEG			.EQU    11100000B		;Set PC[7:5] as common  output 
;D_LCD_PortD_Ctrl			.EQU	00000000B		;set PD[3:2] as normal IO	

.ENDIF
  
