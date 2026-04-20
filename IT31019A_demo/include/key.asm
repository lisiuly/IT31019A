;==========================================
.SYNTAX 6502
.LINKLIST
.SYMBOLS
;==========================================
; Include file area
;==========================================
.INCLUDE 	GPL812P01B.inc
.INCLUDE	"GPL812P01B_LCM_Driver\GPL812P01B_LCM_Driver.inc"
.INCLUDE	"LCD\GPL812P01B_LCD.inc"
.INCLUDE	include\Project.inc
.INCLUDE	include\Macro.inc
;.INCLUDE	include\user.inc
;.INCLUDE	include\rtc.inc
.INCLUDE	include\Display.inc
;.INCLUDE	I2C\D_I2C.inc
;.INCLUDE	include\GXHTV4.inc
;==========================================
; External declare area
;==========================================          
		

;==========================================
; Public declare area
;==========================================	
.PUBLIC	        R_KeyValue 
.PUBLIC	        R_DebounceCnt
.PUBLIC			R_LongKeyTime
.PUBLIC			R_KeyFlag
	
.PUBLIC		R_OtherFlag		
;.PUBLIC		R_SpecFlag
.PUBLIC		R_HumLevel

.PUBLIC	R_NormTemp		;默认温度值
.PUBLIC	R_NormTempF		;默认温度值	
.PUBLIC	R_NormHum		;默认湿度值	


.PUBLIC		R_TimeStatus
;==========================================
.PUBLIC	        F_KeyScan
;.PUBLIC			F_2HzAutoBack
.PUBLIC		Light_JudgeOff
;==========================================
;Variable RAM declare area
;==========================================
.PAGE0	
;UserRFC	.section
R_KeyTemp			ds		1
R_KeyValue			ds		1

R_OldKeyValue		ds		1
D_CFKey	equ	0x20	;Bit5

R_DebounceCnt		ds		1
C_KeyDebounce		equ		4

R_LongKeyTime		ds		1
C_LongKey2Sec		equ		128;255
C_FastAdd			equ		18		;1秒加8次

R_KeyFlag			ds		1	;
D_KeyFastAdd		equ		0x01
D_LongKey			equ		0x02
D_KeyRelDis			equ		0x04
D_KeyToneEn			equ		0x08
D_Alarming			equ		0x10
D_LCDOFF			equ		0x20
D_LVD_ON			equ		0x40
	
R_OtherFlag		ds		1
D_BLight	equ	D_Bit0		;背光标志
D_CF		equ	D_Bit1		;CF切换
D_MaxValue	equ	D_Bit2		;最大值
D_MinValue	equ	D_Bit3		;最小值
D_BLinhtOn	equ	D_Bit4		;背光功能开启
D_NegFlag	equ	D_Bit5		;负号标志

;R_SpecFlag	ds	1
;D_OverMax	equ	D_Bit0
;D_OverMin	equ	D_Bit1

R_HumLevel	ds	1
D_Dry		equ	0x01
D_Mid1		equ	0x02
D_Comf		equ	0x04
D_Mid2		equ	0x08
D_Wet		equ	0x10
D_NoArrow	equ	0x20
R_NormTemp	ds	2	;默认温度值
R_NormTempF	ds	2	;默认温度值
R_NormHum	ds	2	;默认湿度值
R_AutoBack	ds	1

R_TimeStatus		ds	1
AddOthers		equ		0x01

R_BLightTime		ds	1
.ENDS

;=====================================================
.CODE
;------------------------------------------
F_KeyScan:

		LDA		P_IO_PortD_Data		;
;		EOR		#D_Bit5;(D_Bit2+D_Bit3+D_Bit5)
		AND		#D_CFKey;(D_MaxMinKey+D_ClearKey+D_CFKey)
		BEQ		Exit_KeyScan

		STA	R_KeyTemp
		CMP	R_KeyValue
		BEQ	CheckKeyDebounce
		
 		LDA	R_KeyTemp
 		STA	R_KeyValue
 		LDA	#C_KeyDebounce
 		STA	R_DebounceCnt
 ;		%bitr	R_KeyFlag,D_KeyRelDis
		CLI
		RTS
		
Exit_KeyScan:
 		%btst	R_KeyFlag,(D_KeyRelDis+D_KeyFastAdd),?L_ClearKeyFlag
 		LDA		R_OldKeyValue
 		BEQ		?L_ClearKeyFlag
 		CMP		#D_CFKey
		BNE		$+5
 		JMP		Enable_CFKey
 	?L_ClearKeyFlag:		
 		LDA	#00
 		STA	R_OldKeyValue
 		STA	R_KeyValue
 		STA	R_LongKeyTime
 		LDA	#C_KeyDebounce
 		STA	R_DebounceCnt
 		%bitr	R_KeyFlag,(D_LongKey+D_KeyRelDis+D_KeyFastAdd)
 		RTS
		
 CheckKeyDebounce:
 		LDA	R_DebounceCnt	;键消抖时间到，才进入键功能。
 		BEQ	Key_Process		
		RTS				
 Key_Process:
		LDA	R_KeyValue
 		CMP	R_OldKeyValue
 		BNE	$+5
 		JMP	Hold_Key

 Enable_Key:
; 		LDA	#C_LongKey2Sec
; 		STA	R_LongKeyTime				;长按2秒开始计时
 		LDA		R_KeyValue
 		STA		R_OldKeyValue
 	?Exit:
 		RTS	
		
		
Hold_Key:		
 		RTS
		
; ;================================================================
 F_UpdataKey:
		%bits	R_KeyFlag,D_KeyRelDis	;置松键标志		
		%bits	R_TimeStatus,AddOthers
			
 		RTS

	Light_JudgeOff:
		%btsf	R_OtherFlag,D_BLight,?Exit
		DEC		R_BLightTime
		BNE		?Exit
	?OFF:
		%bitr	R_OtherFlag,D_BLight
; 		LDA		P_IO_PortD_Data
;		AND		#~D_Bit7;
 ;		STA		P_IO_PortD_Data	
		LDA		#00101100b		
		STA		P_IO_PortD_Data	 		
		?Exit:
			RTS
F_JudgeBLightOnOff:
		%bits	R_OtherFlag,D_BLight
		LDA		#0x0a
		STA		R_BLightTime			;赋值背光时长
;		LDA		P_IO_PortD_Data
;		ORA		#D_Bit7
; 		STA		P_IO_PortD_Data	
		LDA		#10101100b		
		STA		P_IO_PortD_Data				
 	?Exit:
		RTS		
		
Enable_CFKey:
 	%btst	R_KeyFlag,D_KeyRelDis,?Exit
		JSR		F_UpdataKey
 		JSR		F_JudgeBLightOnOff		
		LDA		R_OtherFlag
		EOR		#D_CF
 		STA		R_OtherFlag
 	?Exit:
		
		RTS

		

		
.END
	
	
	
		
		