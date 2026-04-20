.IFNDEF _LCD_Setting_inc_
_LCD_Setting_inc_:    .EQU    1

;==================================================================================
; The information contained herein is the exclusive property of
; Generalplus Technology Co. And shall not be distributed, reproduced,
; or disclosed in whole in part without prior written permission.
;       (C) COPYRIGHT 2009   Generalplus TECHNOLOGY CO.                            
;                   ALL RIGHTS RESERVED
; The entire notice above must be reproduced on all authorized copies.
;==================================================================================
;==================================================================================
; Name                  : GPL812P01B_LCD.inc
; Applied Body          : GPL81P01A Series
; Programmer            : 
; Description           : 
; History version       : v1.0.0
; 1.0.0     2017/01/08  Neo    first issue
;==================================================================================
.extern F_LCD_Intital		;Initial LCD
.extern F_LCD_Close			;Disable LCD	
.extern F_LCD_Clear			;Clear LCD DPRAM data
.extern	F_LCD_PutRAMToDPRAM	;Put RAM Buffer to DPRAM

.extern LCD_DPRAM_Buffer
.extern	.PAGE0 LCD_RAM_Ptr
.ENDIF
  