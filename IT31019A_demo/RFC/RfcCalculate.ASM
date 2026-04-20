;=======================================================
	.SYNTAX		6502
	.LINKLIST
	.SYMBOLS
;===========================================================
.INCLUDE 	GPL812P01B.inc
.INCLUDE	".\RFC\rfc.inc"
.INCLUDE	".\RFC\rfcDriver.inc"
.INCLUDE	".\RFC\rfcDefine.inc"

.INCLUDE	include\Display.inc


.EXTERNAL	F_Hex_To_BCD
.EXTERNAL	F_BCD_To_Hex
;.EXTERN		TableH0
;.EXTERN		TableH256
;.EXTERN		TableHN50
;.EXTERN		TableM0
;.EXTERN		TableM256
;.EXTERN		TableMN50
;.EXTERN		TableL0
;.EXTERN		TableL256
;.EXTERN		TableLN50
C_Temp_0C:				.EQU		0X006DEA
C_Temp_250C:				.EQU		0X000C84;70C
C_Temp_N10C:			.EQU		0x028B02 	;-40c


C_JZ_4:				.EQU	05H;	04H

.PUBLIC		R_Ftemp4
.PUBLIC		R_Ftemp5
.PUBLIC		R_Ftemp6
.PUBLIC		R_Ftemp7
.PUBLIC		R_Temp_N_bytes

.PUBLIC		RW_RefValue
.PUBLIC		RW_HumValue
.PUBLIC		RW_TmpValue
.PUBLIC		R2K_LB
.PUBLIC		RW_LastTem
.PUBLIC		RW_AvgRefValue
.PUBLIC		R2K_HB
.public		RB_TempDataBCD
.public 	RB_HumDataBCD
.public		TempDataHex
.public 	HumDataHex
Bit0			.EQU		00000001B
C_Digit14			    EQU		14
D_TempSign:            EQU     10000000B;For Temperature high byte operation,
                                    ;1->temperature < 0; 0-> temperature >= 0
	

	
CalculationZRAM .section .page0
.IFNDEF C_CalcuRamStartAddr
C_CalcuRamStartAddr     EQU     $
.ENDIF
R_Calculate_Data0	.DS		1
R_Calculate_Data1	.DS		1
R_Calculate_Data2	.DS		1
R_Calculate_Data3	.DS		1
R_Calculate_Data4	.DS		1
R_Calculate_Data5	.DS		1
R_Calculate_Data6	.DS		1
R_Calculate_Data7	.DS		1
R_Calculate_Data8	.DS		1
R_Calculate_Data9	.DS		1

R_Calculate_Result0	.DS		1
R_Calculate_Result1	.DS		1
R_Calculate_Result2	.DS		1
R_Calculate_Result3	.DS		1
R_Calculate_Result4	.DS		1
R_Calculate_Result5	.DS		1
R_Calculate_Result6	.DS		1
R_Calculate_Result7	.DS		1
R_Calculate_Result8	.DS		1
R_Calculate_Result9	.DS		1

R_Calculate_Temp0	.DS		1
R_Calculate_Temp1   .DS		1
R_Calculate_Temp2	.DS		1
R_Calculate_Temp3   .DS		1
R_Temp_Lram:		.ds		2
R_Index_jmp:		.ds		2
.ENDS	
;---------------------------------------------------------------------	
RFC_Calculate_RAM		.Section
RW_RefValue             DS      2   ;The measured RR-C pulse data
RW_HumValue             DS		2	;Humidity(00.0%~99.9%). 
                                    ;Ex. 12.3%, RW_HumValue=23H, RW_HumValue=01H
RW_TmpValue			    DS		2	;Temperature (-20.0~90.0)
                                    ;Ex. -12.3'C, RW_TmpValue=23H, RW_TmpValue+1=81H
                                    ;MSB of RW_TmpValue+1 is sign flag
;RW_LastHum              DS      2   ;Record last humidity
;_RW_LastHum:		.EQU		RW_LastHum
RW_LastTem              DS      3   ;Record last temperature
_RW_LastTem:		.EQU		RW_LastTem
RW_AvgRefValue		.DS		2
R2K_LB:			.EQU	RW_AvgRefValue
R2K_HB:			.EQU	RW_AvgRefValue+1
;RB_SearchLocBegin       DS      1   ;The begin search location of data table
;RB_SearchLocEnd         DS      1   ;The end search location of data table, and
;                                    ;this location should be not searched
;R_RFC_AverageCout		.DS		1

RB_TempDataBCD			.DS		2
RB_HumDataBCD			.DS		1

Temp_LB:		.DS		1
Temp_MB:		.DS		1
Temp_HB:		.DS		1

TempDataHex			.DS		2
HumDataHex			.DS		1

R_Index_end:		.DS		1
R_Hum_Index:		.DS		1			;div后计算值

R_Hum_data_next0:	.DS		1
R_Hum_data_next1:	.DS		1
R_Hum_data_next2:	.DS		1
Rref_LB:		.DS		1
Rref_HB:		.DS		1
R_Temp_H_bytes:		.DS		1
R_Temp_N_bytes:		.DS		1
;**********************************************************************
R_Ftemp0:	.DS		1	
R_Ftemp1:	.DS		1
R_Ftemp2:	.DS		1
R_Ftemp3:	.DS		1
R_Ftemp4:	.DS		1
R_Ftemp5:	.DS		1
R_Ftemp6:	.DS		1
R_Ftemp7:	.DS		1
RB_LCD_F_Temp_F	.DS		1
RB_LCD_F_Temp_H	.DS		1
RB_LCD_F_Temp_M	.DS		1
RB_LCD_F_Temp_L	.DS		1
RB_Temp_M_BUFF	.DS		1
RB_Temp_L_BUFF	.DS		1
.ends


;----------------------------------------------------------------------------
; Name:	%HumDataRecordDef
; Description: Define data structure for humidity data table
; Input: c_coditionTemper <- temperature
;        c_tableAddrStart <- table start address   
;        c_tablelen       <- data table length
;----------------------------------------------------------------------------
%HumDataRecordDef   .MACRO  c_coditionTemper, c_tableAddrStart, c_tablelen
.IFNDEF HUM_DATARECORD_START
HUM_DATARECORD_START    EQU     $
.ENDIF
        DB      c_coditionTemper    ;The specific temperature condition
        DW      c_tableAddrStart    ;The specific data table start address
        DB      c_tablelen          ;data table length (byte)

.IFNDEF HUM_DATARECORD_SIZE
HUM_DATARECORD_SIZE:    EQU     $ - HUM_DATARECORD_START
.ENDIF
.ENDM

RFC_Hum   .section
    .INCLUDE        humidity3bytes.tab
       .ends
        
RFC_Temp   .section
    .INCLUDE        temperature3bytes.tab
    .ends
   
.PUBLIC	F_Calculate_Temp
.PUBLIC	F_Calculate_Hum
.PUBLIC	F_Temp_C2F_Modul
;RFC_Cal   .section
.CODE
F_ClearCalc_RAM:
	LDA		#0
	STA		R_Calculate_Temp0
	STA		R_Calculate_Temp1
	STA		R_Calculate_Temp2
	STA		R_Calculate_Temp3
	STA		R_Calculate_Data4
	STA		R_Calculate_Data5
	STA		R_Calculate_Data6
	STA		R_Calculate_Data7
	STA		R_Calculate_Data8
	STA		R_Calculate_Data9
	
	STA		R_Calculate_Temp0
	STA		R_Calculate_Temp1
	STA		R_Calculate_Temp2
	STA		R_Calculate_Temp3
	
	STA		R_Calculate_Result0
	STA		R_Calculate_Result1
	STA		R_Calculate_Result2
	STA		R_Calculate_Result3
	STA		R_Calculate_Result4
	STA		R_Calculate_Result5
	STA		R_Calculate_Result6
	STA		R_Calculate_Result7
	STA		R_Calculate_Result8
	STA		R_Calculate_Result9
	RTS	
;========================================================
F_Calculate_Hum:
	JSR		F_ClearCalc_RAM
	
	
	LDA		RW_HumValue
	STA		Temp_LB
	LDA		RW_HumValue+1
	STA		Temp_MB
	
	LDA		RW_AvgRefValue
	STA		Rref_LB
	LDA		RW_AvgRefValue+1
	STA		Rref_HB
;============================	
;Get Ohm = X ohm = ((TempTimer*50Kohm)/ RrefTimer)*2
;============================		

	
	LDA		Rref_LB	;Temp_LB
	STA		R_Calculate_Temp0
	LDA		Rref_HB	;Temp_MB
	STA		R_Calculate_Temp1
	LDA		#00h	;Temp_HB	;yanxiaodu
	STA		R_Calculate_Temp2
	JSR		F_CulXohm
	
	SEC
    LDA     R_Calculate_Result0
    SBC     #0x10
    STA     R_Calculate_Result0
    LDA     R_Calculate_Result1
    SBC     #0x27
    STA     R_Calculate_Result1	
    
	LDA		R_Calculate_Result0
	STA		Temp_LB
	LDA		R_Calculate_Result1
	STA		Temp_MB
	LDA		R_Calculate_Result2
	STA		Temp_HB
;;============================	
;;Check Table Up & Down limit
;;============================
?L_C50:                          ;check < -50

	SEC
	LDA		#.LOW.C_RHUM_MAX                ;follow Table  修改为你自己湿度传感器的最大值阻抗
	SBC		R_Calculate_Result0
	LDA		#.HIGH.C_RHUM_MAX   ;FCH
	SBC		R_Calculate_Result1
	LDA		#.HIGH8.C_RHUM_MAX   ;15H
	SBC		R_Calculate_Result2
	BCS		?L_C200
	LDA		#C_HUM_MIN;50
	STA		Rref_HB
	LDA		#00H;0
	STA		Rref_LB
	LDA		#00H  ;000
	STA		R_Temp_H_bytes
	;00
	JMP		?L_finalTMP
	
?L_C200:                         ;check > 300
	SEC
	LDA		#.LOW.C_RHUM_MIN                ;follow Table	修改为你自己湿度传感器的最小值阻抗
	SBC		R_Calculate_Result0
	LDA		#.HIGH.C_RHUM_MIN   ;FCH
	SBC		R_Calculate_Result1
	LDA		#.HIGH8.C_RHUM_MIN   ;15H
	SBC		R_Calculate_Result2
	BCC		?L_CEnd
	LDA		#00H  ;000
	STA		R_Temp_H_bytes
	LDA		#C_HUM_MAX  ;28H  40°			C8H		;200°
	STA		Rref_HB
	LDA		#00H;0
	STA		Rref_LB

	JMP		?L_finalTMP
?L_CEnd:
	LDA		RW_LastTem+2
	BEQ		?L_Normal_x
?L_Max_temp_humx:
	LDX		#28h
	BNE		?L_search_done
?L_Normal_x:
;====SEARCH  TEMP INDEX=================
	LDX		#FCh		;此处FC配合下面的4个INX 组成X是0 的结果，不可修改。
?L_Search_temp:
	INX
	INX
	INX
	INX
	LDA		RW_LastTem+1
	CMP		T_R_H_BLOCK,X
	BEQ		?L_search_done
	BCS		?L_Search_temp
?L_search_done:
;====找到 温度对应的湿度表格======
	LDA		T_R_H_BLOCK+1,X
	STA		R_Index_jmp
	LDA		T_R_H_BLOCK+2,X
	STA		R_Index_jmp+1
	LDA		T_R_H_BLOCK+3,X			;end
	SEC
	SBC		#01H
	STA		R_Index_end
?L_goon_find:
	TAY
	DEY
	DEY
	LDA		(R_Index_jmp),Y
	CMP		Temp_HB
	BEQ		?L_Check_MB
	BCS		?L_Find
	DEC		R_Index_end
	DEC		R_Index_end
	DEC		R_Index_end
	LDA		R_Index_end
	BMI		?L_Find
	BNE		?L_goon_find
?L_Check_MB:
	INY
	LDA		(R_Index_jmp),Y
	CMP		Temp_MB
	BCS		?L_Find
	BEQ		?L_Check_LB
	DEC		R_Index_end
	DEC		R_Index_end
	DEC		R_Index_end
	LDA		R_Index_end
	BMI		?L_Find
	BNE		?L_goon_find
?L_Check_LB:
	INY
	LDA		(R_Index_jmp),Y
	CMP		Temp_LB
	BCS		?L_Find
	DEC		R_Index_end
	DEC		R_Index_end
	DEC		R_Index_end
	LDA		R_Index_end
	BMI		?L_Find
	BNE		?L_goon_find
	
	
?L_Find:		;R_Index_end 当前阻抗所在，再找出下一组阻抗，进行比较
	LDY		R_Index_end
	LDA		(R_Index_jmp),Y
	STA		R_Calculate_Temp0
	DEY
	LDA		(R_Index_jmp),Y
	STA		R_Calculate_Temp1
	DEY
	LDA		(R_Index_jmp),Y
	STA		R_Calculate_Temp2
	
	LDY		R_Index_end
	INY		
	LDA		(R_Index_jmp),Y
	STA		R_Hum_data_next2
	INY		
	LDA		(R_Index_jmp),Y
	STA		R_Hum_data_next1
	INY	
	LDA		(R_Index_jmp),Y
	STA		R_Hum_data_next0
	
	SEC
	LDA		R_Calculate_Temp0
	SBC		R_Hum_data_next0
	STA		R_Calculate_Data0
	LDA		R_Calculate_Temp1
	SBC		R_Hum_data_next1
	STA		R_Calculate_Data1
	LDA		R_Calculate_Temp2
	SBC		R_Hum_data_next2
	STA		R_Calculate_Data2
	
	
	LDA		#00H
	STA		R_Calculate_Data3
	STA		R_Calculate_Data4
	STA		R_Calculate_Data6
	STA		R_Calculate_Data7
	STA		R_Calculate_Data8
	LDA		#05H		;03H
	STA		R_Calculate_Data5
	JSR		F_CalDiv_UnSign32
	LDA		#00H
	STA		R_Hum_Index
?L_Goon_check:
	CLC
	LDA		R_Hum_data_next0		;Temp_LB
	ADC		R_Calculate_Result0
	STA		R_Hum_data_next0
	LDA		R_Hum_data_next1
	ADC		R_Calculate_Result1
	STA		R_Hum_data_next1
	LDA		R_Hum_data_next2
	ADC		#00H
	STA		R_Hum_data_next2
	
	INC		R_Hum_Index	
	
	LDA		Temp_HB
	CMP		R_Hum_data_next2
	BEQ		?L_MB
	BCS		?L_Goon_check
	BCC		?L_Hum_index_confirm
?L_MB:
	LDA		Temp_MB
	CMP		R_Hum_data_next1
	BEQ		?L_LB
	BCS		?L_Goon_check
	BCC		?L_Hum_index_confirm
?L_LB:
	LDA		Temp_LB
	CMP		R_Hum_data_next0
	BEQ		?L_Hum_index_confirm
	BCS		?L_Goon_check
	
?L_Hum_index_confirm:	
	LDX		R_Index_end
	INX
	STX		R_Calculate_Data0
	LDA		#00H
	STA		R_Calculate_Data1
	STA		R_Calculate_Data5
	LDA		#03H
	STA		R_Calculate_Data4
	JSR		F_CalDiv_UnSign16
	LDA		R_Calculate_Result0
	STA		R_Calculate_Data0
	LDA		#05h	;04H
	STA		R_Calculate_Data4
	
	LDA		#00h
	STA		R_Calculate_Data1
	STA		R_Calculate_Data2
	STA		R_Calculate_Data3
	STA		R_Calculate_Data5
	STA		R_Calculate_Data6
	STA		R_Calculate_Data7
	
	JSR		F_CalMul_UnSign24
	CLC
	LDA		R_Calculate_Result0
	ADC		#C_HUM_MIN
	SEC
	SBC		R_Hum_Index
	STA		RB_HumDataBCD
	STA		Rref_HB
	LDA		#00h
	STA		Rref_LB
	STA		R_Temp_H_bytes

?L_finalTMP:
;============================	
; Find Final Temp & Display
;============================
?L_C_50:
?L_EndTemperCalc:
		JSR		F_F_C_Calc
		STA		RB_HumDataBCD
		RTS
;=========================================================================	
F_Calculate_Temp:
	JSR		F_ClearCalc_RAM
	
	LDA		RW_TmpValue
	STA		Temp_LB
	LDA		RW_TmpValue+1
	STA		Temp_MB
	
	LDA		RW_AvgRefValue
	STA		Rref_LB
	LDA		RW_AvgRefValue+1
	STA		Rref_HB
;============================	
;Get Ohm = X ohm = ((TempTimer*50Kohm)/ RrefTimer)*2
;============================		

	
	LDA		Rref_LB	;Temp_LB
	STA		R_Calculate_Temp0
	LDA		Rref_HB	;Temp_MB
	STA		R_Calculate_Temp1
	LDA		#00h	;Temp_HB	;yanxiaodu
	STA		R_Calculate_Temp2
	JSR		F_CulXohm
	
 	SEC		;减
    LDA     R_Calculate_Result0
    SBC     #0x10
    STA     R_Calculate_Result0
    LDA     R_Calculate_Result1
    SBC     #0x27
    STA     R_Calculate_Result1	


;;============================	
;;Check Table Up & Down limit
;;============================
?L_C50:                          ;check < -50
	LDA		#00H
	STA		R_Temp_N_bytes
	SEC
	LDA		#.LOW.C_Temp_0C                ;follow Table
	SBC		R_Calculate_Result0
	LDA		#.HIGH.C_Temp_0C   ;FCH
	SBC		R_Calculate_Result1
	LDA		#.HIGH8.C_Temp_0C   ;15H
	SBC		R_Calculate_Result2
	BCS		?L_C200
	SEC
	LDA		#.LOW.C_Temp_N10C                ;follow Table
	SBC		R_Calculate_Result0
	LDA		#.HIGH.C_Temp_N10C   ;FCH
	SBC		R_Calculate_Result1
	LDA		#.HIGH8.C_Temp_N10C   ;15H
	SBC		R_Calculate_Result2
	BCS		?L_N50
	
	LDA		#C_TEMPER_NMAX;50			;-50
	STA		Rref_HB
	LDA		#00H;0
	STA		Rref_LB
	LDA		#80H
	STA		R_Temp_N_bytes
	;00
	JMP		?L_finalTMP
	
?L_C200:                         ;check > 300
	SEC
	LDA		#.LOW.C_Temp_250C                ;follow Table
	SBC		R_Calculate_Result0
	LDA		#.HIGH.C_Temp_250C   ;FCH
	SBC		R_Calculate_Result1
	LDA		#.HIGH8.C_Temp_250C   ;15H
	SBC		R_Calculate_Result2
	BCC		?L_CEnd
	LDA		#00H  ;000
	STA		R_Temp_H_bytes
	LDA		#C_TEMPER_MAX  ;28H  40°			C8H		;200°
	STA		Rref_HB
	LDA		#00H;0
	STA		Rref_LB

	JMP		?L_finalTMP
?L_N50:
	LDA		#00H
	STA		Rref_HB
	LDA		#C_TEMPER_NMAX+1			;29h  41
	STA		Rref_LB
	JSR		F_50_1
	JSR		F_A_0
	LDA		R_Calculate_Result0
	BNE		?L_N50Combine0
	LDA		#C_TEMPER_NMAX
	SEC
	SBC		Rref_LB
;	LDA		Rref_LB
	STA		Rref_HB
	LDA		R_Calculate_Result0
	STA		Rref_LB
	LDA		#80H
	STA		R_Temp_N_bytes
	JMP		?L_finalTMP
?L_N50Combine0:	

	STA		Rref_LB
?L_FinalN50:
	SEC
	LDA		#C_TEMPER_NMAX
	SBC		Rref_HB
	STA		Rref_HB
	LDA		#80H
	STA		R_Temp_N_bytes
	LDA		#00H
	STA		R_Temp_H_bytes
	
	JMP		?L_finalTMP
?L_CEnd:
;============================	
;Divid two Table -50~-1, -1~0 ,0~255 ,256~300
;============================	

	LDA		#00H
	STA		Rref_HB
	LDA		#C_TEMPER_MAX+1			;29h  41
	STA		Rref_LB
	JSR		F_0_255
	JSR		F_A_0
	LDA		R_Calculate_Result0
	BNE		?L_Combine0

	LDA		Rref_LB
	STA		Rref_HB

	LDA		R_Calculate_Result0
	STA		Rref_LB
	JMP		?L_Final0
?L_Combine0:	
	SEC
	LDA		#0AH
	SBC		R_Calculate_Result0
	STA		Rref_LB
?L_Final0:
	LDA		#00H
	STA		R_Temp_H_bytes

?L_finalTMP:
	LDA		Rref_HB
	STA		R_Temp_Lram
	LDA		Rref_LB
	STA		R_Temp_Lram+1
;============================	
; Find Final Temp & Display
;============================
?L_C_50:
	;RW_LastTem+1  xx°C
	;RW_LastTem  .xx °C
?L_EndTemperCalc:
		JSR		F_C_Calc
		STX		RW_LastTem+2
		STA		RW_LastTem+1
		STY		RW_LastTem

		RTS
;============================	
; Find C	Temp  单独调用此函数出来的结果会是C模式，任何时候需要格式转化都可以调用
;============================	
F_C_Calc:
	LDA		R_Temp_Lram
	STA		Rref_HB
	LDA		R_Temp_Lram+1
	STA		Rref_LB
	LDA		#00h
	STA		R_Temp_H_bytes
F_F_C_Calc:
	LDA		Rref_HB           ;0x00
	STA		R_Calculate_Data0
	LDA		R_Temp_H_bytes         ;0x01 DEC=256
	STA		R_Calculate_Data1
	LDA		#0AH
	STA		R_Calculate_Data4
	LDA		#00H
	STA		R_Calculate_Data5
	JSR		F_CalDiv_UnSign16
	
	LDA		R_Calculate_Result2  ;6:Remainder
	STA		Rref_HB
	LDA		R_Calculate_Result0
	STA		R_Calculate_Data0
	LDA		#00H
	STA		R_Calculate_Data1
	STA		R_Calculate_Data5
	LDA		#0AH
	STA		R_Calculate_Data4
	JSR		F_CalDiv_UnSign16

		LDA		Rref_HB
		STA		R_Calculate_Data0
		LDA		R_Calculate_Result2
		ROL		A
		ROL		A
		ROL		A
		ROL		A
		AND		#F0H
		ORA		R_Calculate_Data0
		STA		R_Calculate_Data0		;十位个位
		LDY		Rref_LB			;小数点
		LDX		R_Calculate_Result0			;百位
	
	RTS
;============================	
;Find Temp by Table
;============================
;0<-->255 calc process
F_0_255:
	LDA		#D_WDT_Clear
	STA		P_WDT_Flag_Clear
L_255S:	
	CLC
	LDA		Rref_HB
	ADC		Rref_LB
	ROR		A
	STA		R_Calculate_Temp0
	TAX
	
	SEC
	LDA		TableL0,X
	SBC		R_Calculate_Result0
	LDA		TableM0,X
	SBC		R_Calculate_Result1
	LDA		TableH0,X
	SBC		R_Calculate_Result2
	BCC		L_255Downlim
	LDA		R_Calculate_Temp0
	STA		Rref_HB
	JMP		L_255End
L_255Downlim:	
	LDA		R_Calculate_Temp0
	STA		Rref_LB
L_255End:
 	SEC	
	LDA		Rref_LB
	SBC		Rref_HB
	CMP		#01H
	BNE		L_255S
;============================	
;TableH=25,TableL=5,Xohm=9, 
;(Xohm-TableL)=4, (TableH-TableL)=20, 20/10=2, 4/2=2.
;============================
	LDA		#D_WDT_Clear
	STA		P_WDT_Flag_Clear

	LDX		Rref_LB            ;(Xohm-TableL)=4
	LDA		TableL0,X
	STA		R_Calculate_Result3
	LDA		TableM0,X
	STA		R_Calculate_Result4
	LDA		TableH0,X
	STA		R_Calculate_Result5
	
	SEC                          
	LDA		R_Calculate_Result0
	SBC		R_Calculate_Result3
	STA		R_Calculate_Data0
	LDA		R_Calculate_Result1
	SBC		R_Calculate_Result4
	STA		R_Calculate_Data1
	LDA		R_Calculate_Result2
	SBC		R_Calculate_Result5
	STA		R_Calculate_Data2	
	
	LDX		Rref_HB             ;(TableH-TableL)=20
	SEC
	LDA		TableL0,X
	SBC		R_Calculate_Result3
	STA		Temp_LB
	LDA		TableM0,X
	SBC		R_Calculate_Result4
	STA		Temp_MB
	LDA		TableH0,X
	SBC		R_Calculate_Result5
	STA		Temp_HB
	RTS
	
;;============================	
;;Find Temp by Table
;;============================	
;-----------------------------------------
;-50<-->-1 calc process
F_50_1:
	LDA		#D_WDT_Clear
	STA		P_WDT_Flag_Clear

L_50S:	
	CLC
	LDA		Rref_HB
	ADC		Rref_LB
	ROR		A
	STA		R_Calculate_Temp0
	TAX
	
	SEC
	LDA		TableLN50,X
	SBC		R_Calculate_Result0
	LDA		TableMN50,X
	SBC		R_Calculate_Result1
	LDA		TableHN50,X
	SBC		R_Calculate_Result2
	BCC		L_50Downlim
	LDA		R_Calculate_Temp0
	STA		Rref_HB
	JMP		L_50End
L_50Downlim:	
	LDA		R_Calculate_Temp0
	STA		Rref_LB
L_50End:
 	SEC	
	LDA		Rref_LB
	SBC		Rref_HB
	CMP		#01H
	BNE		L_50S
;============================
;TableH=25,TableL=5,Xohm=9, 
;(Xohm-TableL)=4, (TableH-TableL)=20, 20/10=2, 4/2=2.
;============================
	LDA		#D_WDT_Clear
	STA		P_WDT_Flag_Clear

	LDX		Rref_LB            ;(Xohm-TableL)=4
	LDA		TableLN50,X
	STA		R_Calculate_Result3
	LDA		TableMN50,X
	STA		R_Calculate_Result4
	LDA		TableHN50,X
	STA		R_Calculate_Result5	
	
	SEC                          
	LDA		R_Calculate_Result0
	SBC		R_Calculate_Result3
	STA		R_Calculate_Data0
	LDA		R_Calculate_Result1
	SBC		R_Calculate_Result4
	STA		R_Calculate_Data1
	LDA		R_Calculate_Result2
	SBC		R_Calculate_Result5
	STA		R_Calculate_Data2	
	
	LDX		Rref_HB             ;(TableH-TableL)=20
	SEC
	LDA		TableLN50,X
	SBC		R_Calculate_Result3
	STA		Temp_LB
	LDA		TableMN50,X
	SBC		R_Calculate_Result4
	STA		Temp_MB
	LDA		TableHN50,X
	SBC		R_Calculate_Result5
	STA		Temp_HB
	RTS
	
;============================	
;TableH=25,TableL=5,Xohm=9, 
;(Xohm-TableL)=4, (TableH-TableL)=20, 4*10, 40/20=2.
;============================	
F_A_0:
	LDA		#00H                ;4*10=40
	STA		R_Calculate_Data3
	STA		R_Calculate_Data5
	STA		R_Calculate_Data6
	STA		R_Calculate_Data7
	STA		R_Calculate_Data8
	STA		R_Calculate_Data9
	LDA		#0AH
	STA		R_Calculate_Data4
	JSR		F_CalMul_UnSign24
	
	LDA		R_Calculate_Result0 ;40/20=2.
	STA		R_Calculate_Data0
	LDA		R_Calculate_Result1
	STA		R_Calculate_Data1
	LDA		R_Calculate_Result2
	STA		R_Calculate_Data2
	LDA		R_Calculate_Result3
	STA		R_Calculate_Data3
	LDA		R_Calculate_Result4
	STA		R_Calculate_Data4
	
	LDA		Temp_LB
	STA		R_Calculate_Data5
	LDA		Temp_MB
	STA		R_Calculate_Data6
	LDA		Temp_HB
	STA		R_Calculate_Data7
	LDA		#00H
	STA		R_Calculate_Data8
	STA		R_Calculate_Data9
	JSR		F_CalDiv_UnSign32
	RTS
;-----------------------------------------
;-1<-->0 calc process
F_A_0_1:
	LDA		#D_WDT_Clear
	STA		P_WDT_Flag_Clear


	SEC                         ;Xohm-LTable(0)0x045AE0
	LDA		R_Calculate_Result0 ;Xohm
	SBC		#E0H				;0 LTable follow Table
	STA		R_Calculate_Data0
	LDA		R_Calculate_Result1 ;Xohm
	SBC		#5AH				;0 LTable follow Table
	STA		R_Calculate_Data1
	LDA		R_Calculate_Result2 ;Xohm
	SBC		#04H				;0 LTable follow Table
	STA		R_Calculate_Data2	
	

	LDA		#CFH                ;(-1)0x048CAF - (0)0x045AE0 = 0x0031CF follow Table
	STA		Temp_LB				;(HTable(-1)-LTable(0))
	LDA		#31H				; follow Table
	STA		Temp_MB				;(HTable(-1)-LTable(0))
	LDA		#00H				; follow Table
	STA		Temp_HB				;(HTable(-1)-LTable(0))
	JSR		F_A_0
	RTS
;;256<-->xxx calc process	
;F_A_255_256:
;	LDA		#D_WDT_Clear
;	STA		P_WDT_Flag_Clear
;
;
;	SEC                         ;Xohm-LTable(256)0x000883
;	LDA		R_Calculate_Result0 ;Xohm
;	SBC		#83H				;256 LTable follow Table
;	STA		R_Calculate_Data0
;	LDA		R_Calculate_Result1 ;Xohm
;	SBC		#08H				;256 LTable follow Table
;	STA		R_Calculate_Data1
;	LDA		R_Calculate_Result2 ;Xohm
;	SBC		#00H				;256 LTable follow Table
;	STA		R_Calculate_Data2	
;	
;	LDA		#04H                ;(255)0x000887 - (0)0x000883 = 0x000004 follow Table
;	STA		Temp_LB				;(HTable(-1)-LTable(0))
;	LDA		#00H				; follow Table
;	STA		Temp_MB				;(HTable(-1)-LTable(0))
;	LDA		#00H				; follow Table
;	STA		Temp_HB				;(HTable(-1)-LTable(0))
;	JSR		F_A_0
;	RTS

	
	
;===========================
;Cul ohm
;===========================
F_CulXohm:
 	LDA		#.low.(C_VALUE_RR/2)
	STA		R_Calculate_Data0
	LDA		#.high.(C_VALUE_RR/2)
	STA		R_Calculate_Data1
	LDA		#00H
	STA		R_Calculate_Data2
	LDA		R_Calculate_Temp0  ;;Temp_LB
	STA		R_Calculate_Data4
	LDA		R_Calculate_Temp1  ;;Temp_MB
	STA		R_Calculate_Data5
	LDA		R_Calculate_Temp2  ;;Temp_HB
	STA		R_Calculate_Data6
	JSR		F_CalMul_UnSign24
	LDA		R_Calculate_Result0
	STA		R_Calculate_Data0
	LDA		R_Calculate_Result1
	STA		R_Calculate_Data1
	LDA		R_Calculate_Result2
	STA		R_Calculate_Data2
	LDA		R_Calculate_Result3
	STA		R_Calculate_Data3
	LDA		R_Calculate_Result4
	STA		R_Calculate_Data4
	
	LDA		Temp_LB	;Rref_LB
	STA		R_Calculate_Data5
	LDA		Temp_MB	;Rref_HB
	STA		R_Calculate_Data6
	LDA		#00h	;Rref_H8B					;YANXIAODU
	STA		R_Calculate_Data7			;YANXIAODU	
	LDA		#00H
;	STA		R_Calculate_Data7				;YANXIAODU
	STA		R_Calculate_Data8
	STA		R_Calculate_Data9
	JSR		F_CalDiv_UnSign32
;============================	
;*2
;============================	
	CLC
	ROL		R_Calculate_Result0
	ROL		R_Calculate_Result1
	ROL		R_Calculate_Result2	
 	RTS
; =======================================================================================
; Function name : F_CalMul_UnSign24
; Purpose       : Multiplication, Unsigned 16bit multiply Unsigned 16bit
; Parameter     : Multiplicand	:	R_Calculate_Data0 , R_Calculate_Data1 , R_Calculate_Data2
;					Multiplier	:	R_Calculate_Data4 , R_Calculate_Data5 , R_Calculate_Data6
; Return        : product	:	R_Calculate_Result0 , LowByte
;								R_Calculate_Result1 , 
;								R_Calculate_Result2 , 
;								R_Calculate_Result3 , 
;								R_Calculate_Result4 , 
;								R_Calculate_Result5 , HighByte
; Destroy       : A,Y
; ====================================================================================== 		
F_CalMul_UnSign24:
	LDA		#0x00
	STA		R_Calculate_Result5
	STA		R_Calculate_Result4
	STA		R_Calculate_Result3
	LDX		#0x18
	CLC
L_loop1?:	
	ROR		R_Calculate_Result5
	ROR		R_Calculate_Result4
	ROR		R_Calculate_Result3
	ROR		R_Calculate_Data6
	ROR		R_Calculate_Data5
	ROR		R_Calculate_Data4
	BCC		L_NoCarry?	
	CLC
	LDA		R_Calculate_Data0
	ADC		R_Calculate_Result3
	STA		R_Calculate_Result3
	LDA		R_Calculate_Data1
	ADC		R_Calculate_Result4
	STA		R_Calculate_Result4
	LDA		R_Calculate_Data2
	ADC		R_Calculate_Result5
	STA		R_Calculate_Result5
	
L_NoCarry?:	
	DEX
	BNE		L_loop1?	
	ROR		R_Calculate_Result5
	ROR		R_Calculate_Result4
	ROR		R_Calculate_Result3
	ROR		R_Calculate_Data6
	ROR		R_Calculate_Data5
	ROR		R_Calculate_Data4	

	LDA		R_Calculate_Data4
	STA		R_Calculate_Result0
	LDA		R_Calculate_Data5
	STA		R_Calculate_Result1	
	LDA		R_Calculate_Data6
	STA		R_Calculate_Result2	
	RTS	
	
; =======================================================================================
; Function name : F_CalDiv_UnSign32
; Purpose       : Division, Unsigned 32bit divide Unsigned 32bit
; Parameter     : Dividend	:	R_Calculate_Data0 , R_Calculate_Data1 , R_Calculate_Data2 , R_Calculate_Data3 , R_Calculate_Data4
;				  Divesor	:	R_Calculate_Data5 , R_Calculate_Data6 , R_Calculate_Data7 , R_Calculate_Data8 , R_Calculate_Data9
; Return        : Quotient	:	R_Calculate_Result0 , R_Calculate_Result1 , R_Calculate_Result2 , R_Calculate_Result3 ,R_Calculate_Result4
;                 Remainder	:	R_Calculate_Result5 , R_Calculate_Result6 , R_Calculate_Result7 , R_Calculate_Result8 ,R_Calculate_Result9
; Destroy       : A,Y
; ====================================================================================== 			
F_CalDiv_UnSign32:	
	LDA	#0x00
	STA	R_Calculate_Result5
	STA	R_Calculate_Result6
	STA	R_Calculate_Result7
	STA	R_Calculate_Result8
	STA	R_Calculate_Result9
	LDX	#0x28
;L_ChkDivesorHighByte_EquZero?	
	
	LDA	R_Calculate_Data5
	ORA	R_Calculate_Data6
	ORA	R_Calculate_Data7
	ORA	R_Calculate_Data8
	ORA	R_Calculate_Data9
	BNE	L_Divesor_NotZero?
	JMP	L_Divesor_EquZero
	
	LDA	R_Calculate_Data0
	ORA	R_Calculate_Data1
	ORA	R_Calculate_Data2
	ORA	R_Calculate_Data3
	ORA	R_Calculate_Data4
	BNE	L_Divesor_NotZero?
	JMP	L_Divesor_EquZero
	
L_Divesor_NotZero?:
	;==========================================
L_StartUnSign_32Div32?:
	CLC	
	ROL R_Calculate_Data0
	ROL R_Calculate_Data1
	ROL R_Calculate_Data2
	ROL R_Calculate_Data3
	ROL R_Calculate_Data4
	ROL R_Calculate_Result5
	ROL R_Calculate_Result6
	ROL R_Calculate_Result7
	ROL R_Calculate_Result8
	ROL R_Calculate_Result9
	
	SEC
	LDA	R_Calculate_Result5
	SBC	R_Calculate_Data5
	STA	R_Calculate_Temp0
	
	
	LDA	R_Calculate_Result6
	SBC R_Calculate_Data6
	STA	R_Calculate_Temp1
	
	LDA	R_Calculate_Result7
	SBC	R_Calculate_Data7
	STA	R_Calculate_Temp2
	
	LDA	R_Calculate_Result8
	SBC	R_Calculate_Data8
	STA	R_Calculate_Temp3
	
	LDA	R_Calculate_Result9
	SBC	R_Calculate_Data9
	BCC L_next32?
	
	STA	R_Calculate_Result9
	LDA	R_Calculate_Temp0
	STA	R_Calculate_Result5
	LDA	R_Calculate_Temp1
	STA	R_Calculate_Result6
	LDA	R_Calculate_Temp2
	STA	R_Calculate_Result7
	LDA	R_Calculate_Temp3	
	STA	R_Calculate_Result8
	
	CLC
	LDA	#0x01
	ADC	R_Calculate_Data0
	STA	R_Calculate_Data0
	LDA	#0x00
	ADC	R_Calculate_Data1
	STA	R_Calculate_Data1
	LDA	#0x00
	ADC	R_Calculate_Data2
	STA	R_Calculate_Data2
	LDA	#0x00
	ADC	R_Calculate_Data3
	STA	R_Calculate_Data3
	LDA	#0x00
	ADC	R_Calculate_Data4
	STA	R_Calculate_Data4
L_next32?:	
	DEX
	BNE	L_StartUnSign_32Div32?
L_Dividend_EquZero?:
	LDA	R_Calculate_Data0
	STA	R_Calculate_Result0
	LDA	R_Calculate_Data1
	STA	R_Calculate_Result1	
	LDA	R_Calculate_Data2
	STA	R_Calculate_Result2	
	LDA	R_Calculate_Data3
	STA	R_Calculate_Result3
	LDA	R_Calculate_Data4
	STA	R_Calculate_Result4		
	RTS
L_Divesor_EquZero:	

	LDA	#0x00
	STA	R_Calculate_Result0
	STA	R_Calculate_Result1
	STA	R_Calculate_Result2
	STA	R_Calculate_Result3
	STA	R_Calculate_Result4
	RTS		

; =======================================================================================
; Function name : F_CalDiv_UnSign16
; Purpose       : Division, Unsigned 8bit divide Unsigned 8bit
; Parameter     : Dividend	:	R_Calculate_Data0 , R_Calculate_Data1
;				  Divesor	:	R_Calculate_Data4 , R_Calculate_Data5
; Return        : Quotient	:	R_Calculate_Result0(bit0~7) , R_Calculate_Result1(bit8~15)
;                 Remainder	:	R_Calculate_Result2(bit0~7) , R_Calculate_Result3(bit8~15)
; Destroy       : A,Y
; ====================================================================================== 	
F_CalDiv_UnSign16:	
	LDA	#0x00
	STA	R_Calculate_Result0
	STA	R_Calculate_Result1
	STA	R_Calculate_Result2
	STA	R_Calculate_Result3
	LDX	#0x10
;L_ChkDivesorHighByte_EquZero?	
	LDA	R_Calculate_Data5
	BNE	L_ChkDividend_EquZero?

	LDA	R_Calculate_Data4
	BNE L_ChkDividend_EquZero?
	RTS	;Divesor=0 ==> Quotient=0 & Remainder=0
	
L_ChkDividend_EquZero?	
	
	LDA	R_Calculate_Data1
	BNE	L_StartUnSign_16Div16?
	
	LDA	R_Calculate_Data0
	BNE	L_StartUnSign_16Div16?
	RTS	;Dividend=0 ==> Quotient=0 & Remainder=0
		
	;==========================================
L_StartUnSign_16Div16?:
	CLC	
	ROL R_Calculate_Data0
	ROL R_Calculate_Data1
	ROL R_Calculate_Result2
	ROL R_Calculate_Result3
	SEC
	LDA	R_Calculate_Result2
	SBC	R_Calculate_Data4
	STA	R_Calculate_Temp0
	LDA	R_Calculate_Result3
	
	SBC R_Calculate_Data5
	BCC L_NextBit?
	STA	R_Calculate_Result3
	LDA	R_Calculate_Temp0
	STA R_Calculate_Result2
	CLC
	LDA	#0x01
	ADC	R_Calculate_Data0
	STA	R_Calculate_Data0
	LDA	#0x00
	ADC	R_Calculate_Data1
	STA	R_Calculate_Data1
L_NextBit?:	
	DEX
	BNE	L_StartUnSign_16Div16?
	
	LDA	R_Calculate_Data0
	STA	R_Calculate_Result0
	LDA	R_Calculate_Data1
	STA	R_Calculate_Result1		
	RTS


		
;========================================================================================
;;;cf单位数据转换：Fnum=Cnum*18/10+32
;;INPUT:
;;百十位放R_temp1(十进制)进来，个位放R_temp2进来，小数位放R_temp3进来,正负放 R_temp0,0为正。 
;;
;;OUTPUT:
;;百十位放R_temp4进来，个位放R_temp5进来，小数位放R_temp6进来,正负放 R_temp7,0为正。 
		
		
F_Temp_C2F_Modul:
		; LDA		#11H			;百十
		; STA		R_temp1
		; LDA		#04H			;个
		; STA		R_temp2
		; LDA		#06H			;十分位
		; STA		R_temp3
		; LDA		#00H			;符号，0正，1负
		; STA		R_temp0
		LDA		RW_LastTem+1
		JSR		F_ByteHLValue
		STA		R_Ftemp1			;十
		LDA		R_TempBuf
		STA		R_Ftemp2			;个
		LDA		RW_LastTem+0
		AND		#0FH
		STA		R_Ftemp3			;十分位
		LDA		R_Temp_N_bytes
	    STA		R_Ftemp0			;符号

		; CLC
		; ROL		R_temp0
		; ROL		R_temp0
		; ROL		R_temp0
		; ROL		R_temp0
		; ROL		R_temp0
		; ROL		R_temp0
		; ROL		R_temp0
		; LDA		R_temp0
		; AND		#80h
		; STA		R_temp0
		
		
		LDA		R_Ftemp1
		STA		RB_TempDataBCD+1
		AND		#7fh
		ORA		R_Ftemp0
		STA		RB_TempDataBCD+1
		
		CLC
		ROL		R_Ftemp2
		ROL		R_Ftemp2
		ROL		R_Ftemp2
		ROL		R_Ftemp2
		LDA		R_Ftemp2
		ORA		R_Ftemp3
		STA		RB_TempDataBCD
		
;		LDA		RB_TempDataBCD+1		;Yxxx zzzz    Y符号，xxx百zzzz十
;		LDA		RB_TempDataBCD			;aaaa bbbb	aaaa个位，bbbb 十分位
?L_Temp_updata:
	
		;°F
;		LDA		#2h			;temp  °C  X2 X5;°F X2 X3
;		JSR		F_DispFlag

		
; 		LDA		RB_C_F_Status
; 		AND		#D_C_F_Flag
; 		BNE		?L_F_show
; ;====C=======================
; 		RTS
		
; ?L_Show_temp:
	
; 		LDA		RB_Temp_M_BUFF
; 		AND		#0fh
; 		BEQ		?L_KKLL
; 		LDA		RB_Temp_M_BUFF
; 		BNE		?L_NormalKMLL
; ?L_KKLL:
; 		LDA		#AAH
; ?L_NormalKMLL:
; 		LDX		#01d
; ;		JSR		F_Disp_Digital

; ?L_Normal:
			
; 		LDA		RB_Temp_L_BUFF
; 		LDX		#03d
; ;		JSR		F_Disp_Digital
; 		RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
?L_F_show:


		LDA		#00h
		STA		RB_LCD_F_Temp_L
		STA		RB_LCD_F_Temp_H
		STA		RB_LCD_F_Temp_M
		
		LDA		RB_TempDataBCD+1
		AND		#7FH
		STA		RB_LCD_F_Temp_F
		LDX		#18d
		SED
		CLC
?L_ADD_18times:			;*18
		LDA		RB_LCD_F_Temp_L
		ADC		RB_TempDataBCD
		STA		RB_LCD_F_Temp_L
		LDA		RB_LCD_F_Temp_M
		ADC		RB_LCD_F_Temp_F
		STA		RB_LCD_F_Temp_M
		LDA		RB_LCD_F_Temp_H
		ADC		#00h
		STA		RB_LCD_F_Temp_H
		DEX
		BNE		?L_ADD_18times
		LDA		RB_TempDataBCD+1
		AND		#80h
		BNE		?L_NEG_
		LDA		#00h
		STA		R_Ftemp7
		CLC
?L_ADD_3200:
		LDA		RB_LCD_F_Temp_M
		ADC		#32h
		STA		RB_LCD_F_Temp_M
		LDA		RB_LCD_F_Temp_H
		ADC		#00h
		STA		RB_LCD_F_Temp_H
		CLD
		BEQ		?L_Data_change
		BNE		?L_Data_change
?L_NEG_:	
		SEC
?L_3200_SBC:
		LDA		RB_LCD_F_Temp_H
		BNE		?L_NEG_F
		LDA		RB_LCD_F_Temp_M
		CMP		#32h
		BEQ		?L_Check_L
		BCS		?L_M_dayu_32;;;;;M-32
		BCC		?L_M_Xyu_32	;;;;;32-M
	
?L_Check_L:
		LDA		RB_LCD_F_Temp_L
		BEQ		?L_M_dayu_32
		BNE		?L_M_dayu_32
?L_M_dayu_32:
;		LDA		#0h				;col  -
;		JSR		F_DispFlag
		SEC
		LDA		RB_LCD_F_Temp_M
		SBC		#32h
		STA		RB_LCD_F_Temp_M
		JMP		?L_F_neg
?L_M_Xyu_32:
		SEC
		LDA		#00H
		SBC		RB_LCD_F_Temp_L
		STA		RB_LCD_F_Temp_L
		LDA		#32h
		SBC		RB_LCD_F_Temp_M
		STA		RB_LCD_F_Temp_M
		LDA		#00h
		STA		R_Ftemp7
		JMP		?L_Data_change
	
	
?L_NEG_F:
		SEC
		LDA		RB_LCD_F_Temp_L
		SBC		#00h
		STA		RB_LCD_F_Temp_L
		LDA		RB_LCD_F_Temp_M
		SBC		#32H
		STA		RB_LCD_F_Temp_M
		LDA		RB_LCD_F_Temp_H
		SBC		#00H
		STA		RB_LCD_F_Temp_H
?L_F_neg:

		LDA		#01h
		STA		R_Ftemp7
		
		
?L_Data_change:
		CLD
		LDA		RB_LCD_F_Temp_L
		AND		#F0H
		ROR		A
		ROR		A
		ROR		A
		ROR		A
		AND		#0fh
		STA		RB_Temp_L_BUFF
		STA		R_Ftemp6
		LDA		RB_LCD_F_Temp_M
		AND		#0fH
		STA		R_Ftemp5
		ROL		A
		ROL		A
		ROL		A
		ROL		A
		AND		#f0h
		ORA		RB_Temp_L_BUFF
		STA		RB_Temp_L_BUFF
		LDA		RB_LCD_F_Temp_M
		AND		#F0H
		ROR		A
		ROR		A
		ROR		A
		ROR		A
		AND		#0fh
		STA		RB_Temp_M_BUFF
		LDA		RB_LCD_F_Temp_H
		BNE		?L_1

;		LDA		RB_Temp_M_BUFF
;		ORA		#a0H
		LDA		RB_Temp_M_BUFF
		STA		R_Ftemp4
;		JMP		?L_Show_temp
		RTS
?L_1:
		CLC
		ROL		RB_LCD_F_Temp_H
		ROL		RB_LCD_F_Temp_H
		ROL		RB_LCD_F_Temp_H
		ROL		RB_LCD_F_Temp_H
		LDA		RB_LCD_F_Temp_H
		ORA		RB_Temp_M_BUFF
		STA		RB_Temp_M_BUFF
		STA		R_Ftemp4
;		JMP		?L_Show_temp
		RTS
.ends
