#Include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"   

User function SegEmp()   
      
Local nValSeg	:= 0
Local nValFunc	:= 0   
Local nValEmpr  := 0

	nValFunc	:= (FBUSCAPD("431","V",,)) * -1        

	If nValFunc > 0	     
		nValSeg		:= SRA->RA_SALARIO  * M_SEGEMPRE //* 36 * 0.0002958	
		nValEmpr	:= nValSeg - nValFunc	
	   //	FGERAVERBA("757",nValEmpr,,,,,,,,,.T.,) 
		FGERAVERBA("757",nValEmpr,0,CSEMANA,SRA->RA_CC,,"C",,,DDATA_PGTO,.T.,,,,,,,,DDATAREF)
	EndIf
	
Return
