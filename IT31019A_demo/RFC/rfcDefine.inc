;==================================================================================
; The information contained herein is the exclusive property of
; Generalplus Technology Co. And shall not be distributed, reproduced,
; or disclosed in whole in part without prior written permission.
;       (C) COPYRIGHT 2010   Generalplus TECHNOLOGY CO.                            
;                   ALL RIGHTS RESERVED
; The entire notice above must be reproduced on all authorized copies.
;==================================================================================
;==================================================================================
; Name                  : rfcDefine.inc
; Applied Body          : GPL872X
; Programmer            : KenLiu
; Description           : This file is define some definition on GPL872X RFC library.
;						  This is for GPL872X RFC code used , user need include this file.
; History version       : V1.0
;==================================================================================
;==================================================================================
;Constant Definition
;==================================================================================
INVALID_INDEX_BLOCK			EQU     FFH ;Define the invalid block index of data table
C_MAX_TIME_RFC_INTERVAL		EQU     2	;N*16Hz
                                    ;The interval time is counted in 2Hz int/wakeup
C_VALUE_RR              EQU     0X2710		 ;Rref = 10.0kohm   ???????????
C_TEMPER_MIN            EQU     0x00+0x00   ;0'C		???????????
;C_TEMPER_MAX            EQU     0xFA          ;250.0'C		;250?? ???????????
C_TEMPER_MAX            EQU     0x46         ;70.0'C		;99?? ???????????

;C_TEMPER_NMAX            EQU     0x0A          ;-10.0'C		;-10?? ???????????
C_TEMPER_NMAX            EQU     0x28          ;-40.0'C		;-40?? ???????????

C_HUM_MIN               EQU     0x14            ;20%
;C_HUM_Chan               EQU     0x35           ;20%
;C_HUM_MAX               EQU     0x5c            ;92%
C_HUM_MAX               EQU     0x5A           ;90%

C_RESISTOR_IO_INTER_33  EQU     0x0295;0x0207;0x0207;0x0207          ;IO internal resistance is 207ohm (3.3v)

C_RESISTOR_RR_BCD	  EQU     0x2729          ;IO internal resistance is 207ohm (3.3v)

;==========================================
; Include file area
;==========================================

;RFC1,RFC2 SELECT CHANNEL
RFC_CHANNEL_1             EQU     0   ;RFC1
RFC_CHANNEL_2             EQU     1   ;RFC2

CFG_RFC_CH                EQU     RFC_CHANNEL_1

.IFNDEF CFG_RFC_CH
CFG_RFC_CH                EQU     RFC_CHANNEL_1
.ENDIF

;R_RFC_States
;Bit0~2 for state machine
D_RFC_ScanIdle			.EQU		0
D_RFC_ScanRef			.EQU		1
D_RFC_ScanSen1			.EQU		2		;Read Ref data & Scan Sensor1
D_RFC_ScanSen2			.EQU		3		;Read Sensor1 data & Scan Sensor2
D_RfcStatTempCalc		.EQU		4		;Read Sensor2 data
D_RfcStatHumCalc		.EQU		5
;---------------------------------------------------
D_RFC_ScanDataReady		.EQU		00001000B		;Bit3
D_RFC_ContinueSacn		.EQU		00010000B		;Bit4
D_RFC_CalculateDone		.EQU		00100000B		;Bit5
D_RFC_TempDataReady		.EQU		01000000B		;Bit6
D_RFC_SensorEn			.EQU		10000000B		;Bit6

;0:Idle
;1:Sensing Ref
;2:Read Ref data and Sensing Sens1	
;3:Read Sens1 data and Sensing Sens2
;4:Read Sens2 data

;Bit3:RFC Data Readay flag
;Bit4:Continue Sensing RFC Data
;Bit5:Accept Disaply RFC Data
;==========================================
; External declare area
;==========================================
;==========================================
; Public declare area
;==========================================@
C_MaxDigital		equ	12
C_DotPoint			equ	C_MaxDigital/2
C_MaxDotNumber		equ	C_MaxDigital-1
C_MaxDigitByte		equ	(C_MaxDigital/2)-1
C_MaxDecDigitByte		equ	 C_MaxDigitByte-1
C_PointMask			equ	0fh










