;==================================================================================
; The information contained herein is the exclusive property of
; Generalplus Technology Co. And shall not be distributed, reproduced,
; or disclosed in whole in part without prior written permission.
;       (C) COPYRIGHT 2010   Generalplus TECHNOLOGY CO.                            
;                   ALL RIGHTS RESERVED
; The entire notice above must be reproduced on all authorized copies.
;==================================================================================
;==================================================================================
; Name                  : Startup.asm
; Applied Body          : GPL833F
; Programmer            : Neo
; Description           : RFC App Code For C or ASM Code
; History version       : V1.00 2016 01/18
;==================================================================================

;==========================================
; Compiler parameter define
;==========================================
.SYNTAX 6502
.LINKLIST
.SYMBOLS
;==========================================
; Include file area
;==========================================
.INCLUDE	".\RFC\RFCDriver.inc"
.INCLUDE	".\RFC\rfcCalculate.inc"
;==========================================
; Constant define area
;==========================================
;==========================================
; External declare area
;==========================================


;==========================================
;Variable RAM declare area
;==========================================
;.PUBLIC	F_CopyTmpValueToLast
;.PUBLIC	F_CopyTmpValueToAux
;.PUBLIC	F_CopyHumValueToLast
;.PUBLIC	F_CopyHumValueToAux
;.PUBLIC	F_CopyRefValueToAux
;.PUBLIC	F_Copy_Answer_Aux
;.PUBLIC	F_Copy_Aux_Input
;.PUBLIC	F_IfRAnswerZero	
.PAGE0

;==========================================
; code starting 
;==========================================
;RFC .section
;;============================================================================
;;Function Name:	F_CopyTmpValueToLast
;;Description:	Copy RW_TemValue into RW_LastTem
;;Destroy:		A
;;Stack Depth:   2
;;============================================================================
;F_CopyTmpValueToLast:
;
;        LDA     RW_TmpValue
;        STA     RW_LastTem
;        LDA     RW_TmpValue+1
;        STA     RW_LastTem+1
;        
;        RTS
;
;;============================================================================
;;Function Name:	F_CopyTmpValueToAux
;;Description:	
;;Destroy:		A
;;Stack Depth:   2
;;============================================================================
;F_CopyTmpValueToAux:
;
;        LDA     RW_TmpValue
;        STA     R_Aux
;        LDA     RW_TmpValue+1
;        STA     R_Aux+1
;        LDA     #0
;        STA     R_Aux+2
;        RTS
;
;;============================================================================
;;Function Name:	F_CopyHumValueToLast
;;Description:	Copy RW_HumValue into RW_LastHum
;;Destroy:		A
;;Stack Depth:   2
;;============================================================================
;F_CopyHumValueToLast:
;
;        LDA     RW_HumValue
;        STA     RW_LastHum
;        ;LDA     RW_HumValue+1
;        ;STA     RW_LastHum+1
;
;        RTS
;
;;============================================================================
;;Function Name:	F_CopyHumValueToAux
;;Description:	
;;Destroy:		A
;;Stack Depth:   2
;;============================================================================
;F_CopyHumValueToAux:
;
;        LDA     RW_HumValue
;        STA     R_Aux
;        LDA     RW_HumValue+1
;        STA     R_Aux+1
;        LDA     #0
;        STA     R_Aux+2
;        RTS
;
;;============================================================================
;;Function Name:	F_CopyRefValueToAux
;;Description:	
;;Destroy:		A
;;Stack Depth:   2
;;============================================================================
;F_CopyRefValueToAux:
;        
;        LDA     RW_RefValue
;        STA     R_Aux
;        LDA     RW_RefValue+1
;        STA     R_Aux+1
;        LDA     #0
;        STA     R_Aux+2
;        RTS
;
;;======================================================================
F_Copy_Answer_Aux:
;        LDA     R_Answer+7
;        STA     R_Aux+7
;        LDA     R_Answer+6
;        STA     R_Aux+6
;        LDA     R_Answer+5
;        STA     R_Aux+5
;        LDA     R_Answer+4
;        STA     R_Aux+4
;        LDA     R_Answer+3
;        STA     R_Aux+3
;        LDA     R_Answer+2
;        STA     R_Aux+2
;        LDA     R_Answer+1
;        STA     R_Aux+1
;        LDA     R_Answer
;        STA     R_Aux
        RTS
;;======================================================================
F_Copy_Aux_Input: 
;        LDA     R_Aux+7
;        STA     R_Input+7
;        LDA     R_Aux+6
;        STA     R_Input+6
;        LDA     R_Aux+5
;        STA     R_Input+5
;        LDA     R_Aux+4
;        STA     R_Input+4
;        LDA     R_Aux+3
;        STA     R_Input+3
;        LDA     R_Aux+2
;        STA     R_Input+2
;        LDA     R_Aux+1
;        STA     R_Input+1
;        LDA     R_Aux
;        STA     R_Input
        RTS
;;;======================================================================
;;;Function name:        F_IfRAnswerZero
;;;Purpose:              check R_Answer if 0
;;;Input parameters:     R_Answer
;;;Output parameters:    a,bne:not zero;beq:is zero
;;;======================================================================
;F_IfRAnswerZero:
;		lda		R_Answer
;		ora		R_Answer+1
;		ora		R_Answer+2
;		ora		R_Answer+3
;		ora		R_Answer+4
;		ora		R_Answer+5
;		ora		R_Answer+6
;        RTS	
        
;T_BCD2Hex_Ten:
;	DB	0,10,20,30,40,50,60,70,80,90
;	
;T_BCD2Hex_Hundred:
;	DW	0,100,200,300,400,500,600,700,800,900
;	
;T_BCD2Hex_Thousand:	
;	DW	0,1000,2000,3000,4000,5000,6000,7000,8000,9000
;	
	

.END

