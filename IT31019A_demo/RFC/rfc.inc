;==================================================================================
; The information contained herein is the exclusive property of
; Generalplus Technology Co. And shall not be distributed, reproduced,
; or disclosed in whole in part without prior written permission.
;       (C) COPYRIGHT 2010   Generalplus TECHNOLOGY CO.                            
;                   ALL RIGHTS RESERVED
; The entire notice above must be reproduced on all authorized copies.
;==================================================================================
;==================================================================================
; Name                  : rfc.inc
; Applied Body          : GPL872X
; Programmer            : KenLiu
; Description           : RFC Function Code include file.
; History version       : V1.0
;==================================================================================

;==========================================
; Constant define area
;==========================================




;==========================================
; Include file area
;==========================================



;==========================================
; External declare area
;==========================================
.EXTERNAL	F_CopyTmpValueToLast
.EXTERNAL	F_CopyTmpValueToAux
.EXTERNAL	F_CopyHumValueToLast
.EXTERNAL	F_CopyHumValueToAux
.EXTERNAL	F_CopyRefValueToAux
.EXTERNAL	F_Copy_Answer_Aux
.EXTERNAL	F_Copy_Aux_Input
.EXTERNAL	F_IfRAnswerZero	
.EXTERNAL	.PAGE0	RB_LCD_Show0
.EXTERNAL	.PAGE0	RB_LCD_Show1
.EXTERNAL	.PAGE0		RB_RR_Data
.EXTERNAL	.PAGE0		RB_RT_Data
.EXTERNAL	.PAGE0		RB_RH_Data
