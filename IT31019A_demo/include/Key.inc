
;=====================================================
;			RAM Define
;=====================================================

.extern	        R_KeyValue 
.extern	        R_DebounceCnt
.extern			R_LongKeyTime

.extern			R_LCDOffTime
C_LCDOff		equ		60

.extern			R_KeyFlag
D_KeyFastAdd		equ		0x01
D_LongKey			equ		0x02
D_KeyRelDis			equ		0x04
D_KeyToneEn			equ		0x08
D_Alarming			equ		0x10
D_LCDOFF			equ		0x20
D_LVD_ON			equ		0x40
	
.EXTERN		R_OtherFlag		
D_BLight	equ	D_Bit0		;背光标志
D_CF		equ	D_Bit1		;CF切换
D_MaxValue	equ	D_Bit2		;最大值
D_MinValue	equ	D_Bit3		;最小值
D_BLinhtOn	equ	D_Bit4		;背光功能开启
D_NegFlag	equ	D_Bit5		;负号标志	

.EXTERN		R_SpecFlag
D_OverMax	equ	D_Bit0
D_OverMin	equ	D_Bit1
		
.EXTERN		R_HumLevel	
D_Dry		equ	0x01	;dry
D_Mid1		equ	0x02	;Middle1
D_Comf		equ	0x04	;comfort
D_Mid2		equ	0x08	;middle2
D_Wet		equ	0x10	;wet
D_NoArrow	equ	0x20
;==========================================================
;			Module Define
;==========================================================

.EXTERN	    F_KeyScan
.EXTERN		F_PlayKeyTone
.EXTERN		F_CheckAlarmTone
.EXTERN		F_2HzAutoBack

.EXTERN		F_Delay
.EXTERN		F_ReadI2CData
.EXTERN		F_WriteCounterData

.EXTERN		F_OpenData

.EXTERN		F_LoadLCDOnTime

.EXTERN	R_NormTemp		;默认温度值
.EXTERN	R_NormTempF		;默认温度值
.EXTERN	R_NormHum		;默认湿度值	
;====================================================
.EXTERN		R_TimeStatus	
AddOthers		equ		0x01
.EXTERN		Light_JudgeOff
