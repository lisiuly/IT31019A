.external		F_Start_RFC
.external		F_Stop_RFC
.external		F_RFC_Initial
.external		F_RFC_porccess
.external		R_RFC_Control
	D_Cal_ready:		.EQU	01H
	D_Cal_ing:		.EQU	02H
	D_RFC_Enable:	.EQU		00001000B
.external		F_Calculate_Temp_Hum_Proc
.EXTERN		RB_TempDataBCD			
.EXTERN		RB_HumDataBCD	
.EXTERN		TempDataHex
.EXTERN 	HumDataHex
.extern		R_RFC_States

