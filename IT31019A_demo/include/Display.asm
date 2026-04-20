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
.INCLUDE	include\Key.inc
;.INCLUDE	include\rtc.inc
.INCLUDE	RFC\RFC.inc
.INCLUDE	RFC\rfcCalculate.inc
; ;==========================================
; ; External declare area
; ;==========================================

.EXTERN		R_Ftemp4
.EXTERN		R_Ftemp5
.EXTERN		R_Ftemp6
.EXTERN		R_Ftemp7
.EXTERN		R_Temp_N_bytes

; .EXTERNAL	LCD_DPRAM_Buffer
; ;==========================================
; ; Public declare area
; ;==========================================
;.PUBLIC         F_ClrLcdDpram
;.PUBLIC         F_ClrPage0SRAM
;.PUBLIC         F_ClrSRAM
.PUBLIC			F_Display
;.PUBLIC			F_CheckWakeLEDInc
.PUBLIC			R_TempBuf
; ;==========================================
; ;Variable RAM declare area
; ;========================================== 
 .PAGE0
R_Temp0			ds	1
R_Temp1			ds	1
R_Temp2			ds	1
R_Temp3			ds	1
R_Temp4			ds	1
R_Temp5			ds	1
R_TempBuf	    	ds	1
TempData		ds	2
HumData			ds	2

R_H100		ds		1
.ENDS
; ;==============================================================================
.CODE
; ;==============================================================================
 F_Display:							;显示时间
		

F_DisplayAllMode:		
		%btsf	R_TimeStatus,AddOthers,?NoDisplayAllLCD				
	?DisplayAll:
		%bitr	R_TimeStatus,AddOthers
		JSR		F_JudgeDispCF
		JSR		F_DisplayTemperaute
		JSR		F_DisplayHumidity
		JSR		F_DispCurrentHum
		JSR		Display_Weather
		RTS
		
	?NoDisplayAllLCD:

 		RTS
		
;;==========================================================	
;;计算温湿度
;;==========================================================  
;L_CalcuRFC:	
		;==========================================================
		; Update Temperature Data for Display
		; RW_LastTem+1 (Packed BCD): Tens (High Nibble) | Units (Low Nibble)
		; RW_LastTem   (Decimal):    Decimal Digit (Might be >9, need limit)
		; Target: TempData+0 (Tens), TempData+1 (Units | Decimal)
		;==========================================================
;		LDA		RW_LastTem+1	; Load Integer Part (Already Packed BCD)
;		JSR		F_ByteHLValue	; A = Tens (High->Low), R_TempBuf = Units (Low Nibble)
;		STA		TempData+0		; Store Tens Digit
;		
;		LDA		R_TempBuf		; Load Units Digit
;		JSR		F_ByteLHValue	; Move Units to High Nibble (A = Units << 4)
;		STA		R_TempBuf		; Save Units(High Nibble)
		
		; Process Decimal Part
;		LDA		RW_LastTem		; Load Decimal Part
;		CMP		#10				; Check if > 9
;		BCC		?L_DecOK		; If < 10, jump
;		LDA		#9				; Else, limit to 9
;?L_DecOK:
;		ORA		R_TempBuf		; Combine with Units(High Nibble)
;		STA		TempData+1		; Store Units.Decimal
		
		;==========================================================
		; Update Humidity Data for Display
		; RB_HumDataBCD (Packed BCD): Tens (High Nibble) | Units (Low Nibble)
		; Target: HumData+0 (Packed BCD)
		;==========================================================
;		LDA		RB_HumDataBCD
;		STA		HumData+0		; Store Humidity Value
		
;		RTS
			
;================================================================
F_DisplayTemperaute:
		LDA		R_OtherFlag
		AND		#D_CF
		BEQ		F_DisplayTemperauteC
		JMP		F_DisplayTemperauteF

F_DisplayTemperauteC:
		LDX		#T_THIcon
		JSR		F_NoDisplayBit	
		; %btst	R_OtherFlag,D_MaxValue,?L_DispMaxTemp
		; %btst	R_OtherFlag,D_MinValue,?L_DispMinTemp
?L_DispNormTemp:
		LDA		R_Temp_N_bytes
		BNE		F_DispNorm
	L_DisTemp_0_70:	
		LDX		#T_DP
		JSR		F_DisplayBit
		LDA		RW_LastTem+0			;小数位
		AND		#0FH
		TAX
		LDY		#2
		JSR		F_DispTheSevenSegChar	;显示高位
		LDA		RW_LastTem+1			;十位个位
		JSR		F_ByteHLValue
		
		BNE		?L_NotNULL	
		LDA		#11H		
	?L_NotNULL:			
		TAX
		LDY		#0
		JSR		F_DispTheSevenSegChar
		LDX		R_TempBuf
		LDY		#1
		JSR		F_DispTheSevenSegChar
		RTS
		
	F_DispNorm:
		LDX		#0x0f
		LDY		#0
		JSR		F_DispTheSevenSegChar
		LDA		RW_LastTem+1
		AND		#0xf0
		BEQ		?L_DisTemp_N09
		LDX		#T_DP
		JSR		F_NoDisplayBit		
		LDA		RW_LastTem+1			;十位个位
		JSR		F_ByteHLValue
		TAX
		LDY		#1
		JSR		F_DispTheSevenSegChar
		LDX		R_TempBuf
		LDY		#2
		JSR		F_DispTheSevenSegChar		
		
	?L_NoDispNorm:
		RTS	
	?L_DisTemp_N09:	
		LDX		#T_DP
		JSR		F_DisplayBit
		LDA		RW_LastTem+0			;小数位
		AND		#0FH
		TAX
		LDY		#2
		JSR		F_DispTheSevenSegChar	;显示高位
		LDA		RW_LastTem+1			;十位个位
		JSR		F_ByteHLValue
;		TAX
;		LDY		#0
;		JSR		F_DispTheSevenSegChar
		LDX		R_TempBuf
		LDY		#1
		JSR		F_DispTheSevenSegChar
		RTS	
; ?L_DispMaxTemp:
; 		LDA		R_MaxTemp+1
; 		AND		#0FH
; 		TAX
; 		LDY		#0
; 		JSR		F_DispTheSevenSegChar	;显示高位
; 		LDA		R_MaxTemp+0
; 		JSR		F_ByteHLValue
; 		TAX
; 		LDY		#1
; 		JSR		F_DispTheSevenSegChar
; 		LDX		R_TempBuf
; 		LDY		#2
; 		JSR		F_DispTheSevenSegChar
; 		RTS
; ?L_DispMinTemp:
; 		LDA		R_MinTemp+1
; 		AND		#0FH
; 		TAX
; 		LDY		#0
; 		JSR		F_DispTheSevenSegChar	;显示高位
; 		LDA		R_MinTemp+0
; 		JSR		F_ByteHLValue
; 		TAX
; 		LDY		#1
; 		JSR		F_DispTheSevenSegChar
; 		LDX		R_TempBuf
; 		LDY		#2
; 		JSR		F_DispTheSevenSegChar
; 		RTS
		
		
F_DisplayTemperauteF:
		; %btst	R_OtherFlag,D_MaxValue,?L_DispMaxTemp
		; %btst	R_OtherFlag,D_MinValue,?L_DispMinTemp
?L_DispNormTemp:
		LDA		R_Ftemp7
		BEQ		?L_NoDispNorm
		
		; --- 负数公共处理 ---
		LDX		#T_THIcon
		JSR		F_NoDisplayBit			;不显示百位

		LDX		#0x0f
		LDY		#0
		JSR		F_DispTheSevenSegChar	;位置0：显示负号
		
		LDA		R_Ftemp4
		AND		#0FH
		BEQ		?L_NegSmall				;如果十位为0，跳转显示小数(-9.9~-0.1)

		; --- 大负数处理 (≤ -10) ---
		LDX		#T_DP
		JSR		F_NoDisplayBit			;不显示小数点
		
		LDA		R_Ftemp4
		AND		#0FH
		TAX
		LDY		#1
		JSR		F_DispTheSevenSegChar	;位置1：显示十位
		
		LDA		R_Ftemp5
		AND		#0FH
		TAX
		LDY		#2
		JSR		F_DispTheSevenSegChar	;位置2：显示个位
		RTS

	?L_NegSmall:
		; --- 小负数处理 (> -10) ---
		LDX		#T_DP
		JSR		F_DisplayBit			;显示小数点
		
		LDA		R_Ftemp5
		AND		#0FH
		TAX
		LDY		#1
		JSR		F_DispTheSevenSegChar	;位置1：显示个位
		
		LDA		R_Ftemp6
		AND		#0FH
		TAX
		LDY		#2
		JSR		F_DispTheSevenSegChar	;位置2：显示小数位
		RTS

	?L_NoDispNorm:
		LDX		#T_DP
		JSR		F_DisplayBit
		LDA		R_Ftemp4
		AND		#F0H
		BEQ		?L_NoDisM	
		LDA		#01
		STA		R_H100
		LDX		#T_THIcon		;是否显示百位
		JSR		F_DisplayBit
		JMP		?L_Disten
		?L_NoDisM:	
		LDX		#T_THIcon
		JSR		F_NoDisplayBit
		LDA		#00
		STA		R_H100
		
		?L_Disten:	;显示十位
		LDA		R_Ftemp4
		AND		#0FH
		BNE		?L_Next	
		LDA		R_H100
		BNE		?L_1
		LDA		#11H
		?L_Next:
		TAX
		LDY		#0
		JSR		F_DispTheSevenSegChar	;显示高位
		LDA		R_Ftemp5
		AND		#0FH		
		TAX
		LDY		#1
		JSR		F_DispTheSevenSegChar
		LDA		R_Ftemp6
		AND		#0FH		
		TAX
		LDY		#2
		JSR		F_DispTheSevenSegChar
		RTS
		?L_1:
		LDA		R_Ftemp4
		AND		#0FH
		JMP		?L_Next	
			
				
;================================================================
F_DisplayHumidity:

?L_DispNormHum:
		LDA		RB_HumDataBCD+0
		CMP		#0x90
		BCC		?DispHum
		BEQ		?DispHum
		LDA		#0x90
	?DispHum:	
		JSR		F_ByteHLValue
		
		BNE		?L_NotNULL	
		LDA		#01H
		TAX
		LDY		#3
		JSR		F_DispTheSevenSegChar
		LDX		#00H
		LDY		#4
		JSR		F_DispTheSevenSegChar
		RTS		
	?L_NotNULL:	
	
		TAX
		LDY		#3
		JSR		F_DispTheSevenSegChar
		LDX		R_TempBuf
		LDY		#4
		JSR		F_DispTheSevenSegChar
		RTS
;================================================================
F_DispTHIcon:
		LDX		#T_THIcon
		JSR		F_DisplayBit
		RTS
F_JudgeDispCF:
		LDA		R_OtherFlag
		AND		#D_CF
		BNE		?DispF
	?DispC:
		JMP		F_DispTC
	?DispF:
		JMP		F_DispTF		

F_DispTC:
		LDX		#T_TC
		JSR		F_DisplayBit
		LDX		#T_TF
		JSR		F_NoDisplayBit
		RTS
F_DispTF:
		LDX		#T_TF
		JSR		F_DisplayBit
		LDX		#T_TC
		JSR		F_DisplayBit
		RTS			

;================================================================
F_DispCurrentHum:
	;	JSR		F_NoDispFeel
 		LDA		RB_HumDataBCD
 		CMP		#0x41		;41
 		BCS		$+5
 		JMP		F_DisplayDry
 		CMP		#0x70		;70
 		BCS		$+5
 		JMP		F_DisplayComf
 		JMP		F_DisplayWet
		RTS
		
		
F_DisplayDry:					;干燥
		LDX		#T_Comf
		JSR		F_NoDisplayBit
		LDX		#T_Wed
		JSR		F_NoDisplayBit
		LDX		#T_Dry
		JSR		F_DisplayBit
		RTS
		
F_DisplayComf:					;舒适
		LDX		#T_Dry
		JSR		F_NoDisplayBit
		LDX		#T_Comf
		JSR		F_DisplayBit
		LDX		#T_Wed
		JSR		F_NoDisplayBit
		RTS
		
F_DisplayWet:					;潮湿
		LDX		#T_Dry
		JSR		F_NoDisplayBit
		LDX		#T_Comf
		JSR		F_NoDisplayBit
		LDX		#T_Wed
		JSR		F_DisplayBit
		RTS		
F_NoDispFeel:	
		LDX		#T_Dry
		JSR		F_NoDisplayBit
		LDX		#T_Comf
		JSR		F_NoDisplayBit
		LDX		#T_Wed
		JSR		F_NoDisplayBit
		RTS
		
Display_Weather:
		LDA		RB_HumDataBCD 
		CMP		#0x41      
		BCC		?SUNNY    
		CMP		#0x65    
		BCC		?CLOUDY   
		CMP		#0x75   
		BCC		?CLOUD		
		JMP		?RAINY    
	?SUNNY:
		LDX		#T_Sun
		JSR		F_DisplayBit
		LDX		#T_rain
		JSR		F_NoDisplayBit
		LDX		#T_Cloud
		JSR		F_NoDisplayBit			
		RTS
	?CLOUDY:
		LDX		#T_Sun
		JSR		F_DisplayBit
		LDX		#T_Cloud
		JSR		F_DisplayBit
		LDX		#T_rain
		JSR		F_NoDisplayBit
		RTS
	?CLOUD:
		LDX		#T_Sun
		JSR		F_NoDisplayBit
		LDX		#T_Cloud
		JSR		F_DisplayBit
		LDX		#T_rain
		JSR		F_NoDisplayBit
		RTS		
	?RAINY:	
		LDX		#T_rain
		JSR		F_DisplayBit
		LDX		#T_Cloud
		JSR		F_DisplayBit
		LDX		#T_Sun
		JSR		F_NoDisplayBit
		RTS
	?No:	
		LDX		#T_rain
		JSR		F_NoDisplayBit
		LDX		#T_Cloud
		JSR		F_NoDisplayBit
		LDX		#T_Sun
		JSR		F_NoDisplayBit
		RTS
		
; ;----------------------------------------------
; F_DispAllOFF:
; 		LDA		#0x00
; 		JSR		F_LCD_Clear			;LCD DPRAM Clear
; 		%FillLcdDpram	#00H
; 		RTS
;----------------------------------------------	
.PUBLIC		F_ByteHLValue
F_ByteHLValue:					;高四位移到低4位
			TAX
			AND	#0FH
			STA	R_TempBuf
			TXA
			ROR	A
			ROR	A
			ROR	A
			ROR	A
			AND	#0FH
			RTS
;-------------------------------
.PUBLIC		F_ByteLHValue
F_ByteLHValue:					;低4位移到高4位
			STA	R_TempBuf
			AND	#0FH
			ROL	A
			ROL	A
			ROL	A
			ROL	A
			AND	#F0H
			RTS
			
; ;==========================================================	

F_DispTheSevenSegChar:
		LDA	T_SevenSegCharBitMapTab,X
	F_DisplaySevenIcon:					;取得显示点的序列的起始地址
		STA	R_Temp1								;R_Temp1存放字符的位映射
		TYA
		ASL	A		; A<128
		TAX
		LDA	T_SevenSegCharPosIndexTab,X
		STA	R_Temp3
		LDA	T_SevenSegCharPosIndexTab+1,X	;取字符的显示映射表的地址
		STA	R_Temp4
	;------
	;dot start addr:R_Temp3,R_Temp4. disp byte:R_Temp1.
	;F_DispByte:
		LDA	#7
		STA	R_Temp2
	L_DispByte_1:
		LDX	#0
		LDA	(R_Temp3,X)
		STA	R_Temp0
		INC	R_Temp3
		BNE	L_DispByte_1_0
		INC	R_Temp4
	L_DispByte_1_0:
		LDA	(R_Temp3,X)
		INC	R_Temp3
		BNE	L_DispByte_1_1
		INC	R_Temp4
	L_DispByte_1_1:
		LDX	R_Temp0
		ROR	R_Temp1
		BCS	L_DispByte_1_1_1
	L_DispByte_1_1_0:
		STA	R_Temp0
	.if	(GPL812P01Bx_Mode=EV_Simualtion)
		LDA	LCD_DPRAM_Buffer,x		;$50,X
		ORA	R_Temp0
		EOR	R_Temp0
		STA	LCD_DPRAM_Buffer,x			;	$50,X
	.ELSE
		LDA	$50,X
		ORA	R_Temp0
		EOR	R_Temp0
		STA	$50,X
	.ENDIF	
		DEC	R_Temp2
		BNE	L_DispByte_1
		RTS
	L_DispByte_1_1_1:
		STA	R_Temp0
	.if	(GPL812P01Bx_Mode=EV_Simualtion)	
		LDA	LCD_DPRAM_Buffer,x		;$50,X
		ORA	R_Temp0
		STA	LCD_DPRAM_Buffer,x		;$50,X
	.ELSE
		LDA	$50,X
		ORA	R_Temp0
		STA	$50,X
	.ENDIF				
		DEC	R_Temp2
		BNE	L_DispByte_1
		RTS
;=============================
;input x
;=============================
F_DisplayBit:
		LDA	T_ICON,x
		STA	R_Temp0
		inx
		LDA	T_ICON,x
		STA	R_Temp1
		LDX	R_Temp0
	.if	(GPL812P01Bx_Mode=EV_Simualtion)	
		LDA	LCD_DPRAM_Buffer,x		;$50,X
		ORA	R_Temp1
		STA	LCD_DPRAM_Buffer,x		;$50,X
	.ELSE
		LDA	$50,X
		ORA	R_Temp1
		STA	$50,X
	.ENDIF				
		RTS
;=============================
;input x
;=============================
F_NoDisplayBit:
		LDA	T_ICON,x
		STA	R_Temp0
		inx
		LDA	T_ICON,x
		EOR	#FFH
		STA	R_Temp1
		LDX	R_Temp0
	.if	(GPL812P01Bx_Mode=EV_Simualtion)	
		LDA	LCD_DPRAM_Buffer,x		;$50,X
		and	R_Temp1
		STA	LCD_DPRAM_Buffer,x		;$50,X
	.ELSE
		LDA	$50,X
		and	R_Temp1
		STA	$50,X
	.ENDIF				
		RTS		
;=========================================================================
;==========================================
C_Com0MinByteNum	EQU	00h	;00H
C_Com1MinByteNum	EQU	02h	;02H
C_Com2MinByteNum	EQU	04H
C_Com3MinByteNum	EQU	06H
C_Com4MinByteNum	EQU	08H
;C_Com5MinByteNum	EQU	0AH

;C_Com0MinByteNum	EQU	0Ah	;00H
;C_Com1MinByteNum	EQU	08h	;02H
;C_Com2MinByteNum	EQU	06H
;C_Com3MinByteNum	EQU	04H
;C_Com4MinByteNum	EQU	02H
;C_Com5MinByteNum	EQU	00H

;Seg00	EQU	00
;Seg01	EQU	01
;Seg02	EQU	02
;Seg03	EQU	03
;Seg04	EQU	04
;Seg05	EQU	05
;Seg06	EQU	06
;Seg07	EQU	07
;Seg08	EQU	08
;Seg09	EQU	09
;Seg10	EQU	10
;Seg11	EQU	11
;Seg12	EQU	12
;Seg13	EQU	13
;Seg14	EQU	14
;Seg15	EQU	15
;
;C_Seg15	EQU	10000000B
;C_Seg14	EQU	01000000B
;C_Seg13	EQU	00100000B
;C_Seg12	EQU	00010000B
;C_Seg11	EQU	00001000B
;C_Seg10	EQU	00000100B
;C_Seg09	EQU	00000010B
;C_Seg08	EQU	00000001B
;C_Seg07	EQU	10000000B
;C_Seg06	EQU	01000000B
;C_Seg05	EQU	00100000B
;C_Seg04	EQU	00010000B
;C_Seg03	EQU	00001000B
;C_Seg02	EQU	00000100B
;C_Seg01	EQU	00000010B
;C_Seg00	EQU	00000001B
;

;----------------------------------
.if	   GPL812P01Bx_Mode	
Seg00	EQU	14
Seg01	EQU	13
Seg02	EQU	12
Seg03	EQU	11
Seg04	EQU	10
Seg05	EQU	09
Seg06	EQU	08
Seg07	EQU	07
Seg08	EQU	06

C_Seg00	EQU		01000000B	; C_Seg14
C_Seg01	EQU		00100000B	; C_Seg13
C_Seg02	EQU		00010000B	; C_Seg12	
C_Seg03	EQU		00001000B	; C_Seg11
C_Seg04	EQU		00000100B	; C_Seg10
C_Seg05	EQU		00000010B	; C_Seg09	
C_Seg06	EQU		00000001B	; C_Seg08
C_Seg07	EQU		10000000B	; C_Seg07
C_Seg08	EQU		01000000B	; C_Seg06

.ELSE

Seg00	EQU	06
Seg01	EQU	07
Seg02	EQU	08
Seg03	EQU	09
Seg04	EQU	10
Seg05	EQU	11
Seg06	EQU	12
Seg07	EQU	13
Seg08	EQU	14

C_Seg00	EQU		01000000B	; C_Seg06
C_Seg01	EQU		10000000B	; C_Seg07
C_Seg02	EQU		00000001B	; C_Seg08	
C_Seg03	EQU		00000010B	; C_Seg09
C_Seg04	EQU		00000100B	; C_Seg10
C_Seg05	EQU		00001000B	; C_Seg11	
C_Seg06	EQU		00010000B	; C_Seg12
C_Seg07	EQU		00100000B	; C_Seg13
C_Seg08	EQU		01000000B	; C_Seg14
;Seg00	EQU	11
;Seg01	EQU	12
;Seg02	EQU	14               
;Seg03	EQU	13
;Seg04	EQU	06
;Seg05	EQU	07
;Seg06	EQU	08
;Seg07	EQU	09
;Seg08	EQU	10

;C_Seg00	EQU		00001000B	;C_Seg11  
;C_Seg01	EQU		00010000B	;C_Seg12   
;C_Seg02	EQU		01000000B	;C_Seg14  	
;C_Seg03	EQU		00100000B	;C_Seg13   
;C_Seg04	EQU		01000000B	;C_Seg06   ;
;C_Seg05	EQU		10000000B	;C_Seg07	
;C_Seg06	EQU		00000001B	;C_Seg08
;C_Seg07	EQU		00000010B	;C_Seg09
;C_Seg08	EQU		00000100B	;C_Seg10
.ENDIF

;======================================================
;.CODE
;------------------------------
;C_NotDispThisDigital	EQU	0AH
;==============================
T_SevenSegCharPosIndexTab:
	DW	T_Digital1DispTab   ;1		;Temp2
	DW	T_Digital2DispTab   ;2		;Temp3
	DW	T_Digital3DispTab   ;3		;Temp4
	DW	T_Digital4DispTab   ;4		;Hum1
	DW	T_Digital5DispTab   ;5		;Hum2
;	DW	T_Digital6DispTab   ;6		;MinL
;	DW	T_Digital7DispTab   ;7		;MinL
;=======================
T_SevenSegCharBitMapTab:
;	       0,         1,       2,        3,        4
	DB	00111111B,00000110B,01011011B,01001111B,01100110B
;	       5,         6,       7,        8,        9
	DB	01101101B,01111101B,00000111B,01111111B,01101111B
;	      A-"A"     B-"b"     C-"C"    D-'L'       E-'E'      
	DB	01110111B,01111100B,00111001B,00111000B,01111001B
;		F;'-"Dash"	10-"r"	11"NULL"
	DB	01000000B,01010000B,00000000B
;---
;format:byte index;mask bit
;---
; ================================
	;实际LCD
;.comment	
; ================================
; ================================
T_Digital1DispTab:   ;;0 temp2
	DB	C_Com1MinByteNum+Seg00/8,C_Seg00 ;a
	DB	C_Com1MinByteNum+Seg01/8,C_Seg01 ;b
	DB	C_Com3MinByteNum+Seg01/8,C_Seg01 ;c
	DB	C_Com4MinByteNum+Seg00/8,C_Seg00 ;d
	DB	C_Com3MinByteNum+Seg00/8,C_Seg00 ;e
	DB	C_Com2MinByteNum+Seg00/8,C_Seg00 ;f 
	DB	C_Com2MinByteNum+Seg01/8,C_Seg01 ;g
T_Digital1DispTabEnd:                 
; ================================
T_Digital2DispTab:   ;;1 Temp3
	DB	C_Com0MinByteNum+Seg02/8,C_Seg02 ;a
	DB	C_Com1MinByteNum+Seg02/8,C_Seg02 ;b
	DB	C_Com3MinByteNum+Seg02/8,C_Seg02 ;c
	DB	C_Com4MinByteNum+Seg02/8,C_Seg02 ;d
	DB	C_Com4MinByteNum+Seg01/8,C_Seg01 ;e
	DB	C_Com0MinByteNum+Seg01/8,C_Seg01 ;f 
	DB	C_Com2MinByteNum+Seg02/8,C_Seg02 ;g
T_Digital2DispTabEnd:                 
; ================================
T_Digital3DispTab:   ;;2 Temp4
	DB	C_Com1MinByteNum+Seg03/8,C_Seg03 ;a
	DB	C_Com2MinByteNum+Seg04/8,C_Seg04 ;b
	DB	C_Com4MinByteNum+Seg04/8,C_Seg04 ;c
	DB	C_Com4MinByteNum+Seg03/8,C_Seg03 ;d
	DB	C_Com3MinByteNum+Seg03/8,C_Seg03 ;e
	DB	C_Com2MinByteNum+Seg03/8,C_Seg03 ;f 
	DB	C_Com3MinByteNum+Seg04/8,C_Seg04 ;g
T_Digital3DispTabEnd:                 

; ================================
T_Digital4DispTab:   ;;3 Hum1
	DB	C_Com1MinByteNum+Seg07/8,C_Seg07 ;a
	DB	C_Com2MinByteNum+Seg07/8,C_Seg07 ;b
	DB	C_Com3MinByteNum+Seg07/8,C_Seg07 ;c
	DB	C_Com4MinByteNum+Seg07/8,C_Seg07 ;d
	DB	C_Com4MinByteNum+Seg08/8,C_Seg08 ;e
	DB	C_Com2MinByteNum+Seg08/8,C_Seg08 ;f 
	DB	C_Com3MinByteNum+Seg08/8,C_Seg08 ;g
T_Digital4DispTabEnd:                 
; ================================
	              
; ================================
T_Digital5DispTab:   ;;4 Hum2
	DB	C_Com1MinByteNum+Seg06/8,C_Seg06 ;a
	DB	C_Com2MinByteNum+Seg05/8,C_Seg05 ;b
	DB	C_Com4MinByteNum+Seg05/8,C_Seg05 ;c
	DB	C_Com4MinByteNum+Seg06/8,C_Seg06 ;d
	DB	C_Com3MinByteNum+Seg06/8,C_Seg06 ;e
	DB	C_Com2MinByteNum+Seg06/8,C_Seg06 ;f 
	DB	C_Com3MinByteNum+Seg05/8,C_Seg05 ;g
T_Digital5DispTabEnd:      	
; ================================
;T_Digital6DispTab:   ;;3 Time secL
;	DB	C_Com1MinByteNum+Seg09/8,C_Seg09 ;a
;	DB	C_Com2MinByteNum+Seg10/8,C_Seg10 ;b
;	DB	C_Com4MinByteNum+Seg10/8,C_Seg10 ;c
;	DB	C_Com4MinByteNum+Seg09/8,C_Seg09 ;d
;	DB	C_Com3MinByteNum+Seg09/8,C_Seg09 ;e
;	DB	C_Com2MinByteNum+Seg09/8,C_Seg09 ;f 
;	DB	C_Com3MinByteNum+Seg10/8,C_Seg10 ;g
;T_Digital6DispTabEnd:                
; ================================
; ================================
T_ICON:

T_THIcon	EQU	$-T_ICON
	DB	C_Com0MinByteNum+Seg00/8,C_Seg00	;temp1
T_Dry	EQU	$-T_ICON						;干燥
	DB	C_Com0MinByteNum+Seg05/8,C_Seg05
T_Comf	EQU	$-T_ICON						;舒适
	DB	C_Com1MinByteNum+Seg05/8,C_Seg05
T_Wed	EQU	$-T_ICON						;潮湿
	DB	C_Com0MinByteNum+Seg06/8,C_Seg06
T_TC	EQU	$-T_ICON
	DB	C_Com0MinByteNum+Seg04/8,C_Seg04 ;
T_TF	EQU	$-T_ICON
	DB	C_Com1MinByteNum+Seg04/8,C_Seg04 ;	
T_DP	EQU	$-T_ICON
	DB	C_Com0MinByteNum+Seg03/8,C_Seg03 ;	小数点	
T_rain	EQU	$-T_ICON
	DB	C_Com1MinByteNum+Seg08/8,C_Seg08 ;雨
T_Cloud	EQU	$-T_ICON
	DB	C_Com0MinByteNum+Seg07/8,C_Seg07 ;云
T_Sun	EQU	$-T_ICON
	DB	C_Com0MinByteNum+Seg08/8,C_Seg08 ;太阳
		
;T_Max	EQU	$-T_ICON
;	DB	C_Com0MinByteNum+Seg02/8,C_Seg02;
;T_Min	EQU	$-T_ICON
;	DB	C_Com0MinByteNum+Seg07/8,C_Seg07 ;	
		
		
.END
;*************************************************************************  	
 	