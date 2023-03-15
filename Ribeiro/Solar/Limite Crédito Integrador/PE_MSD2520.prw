#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*__________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  MSD2460   - Autor - Tiago Santos      - Data -02.02.23   ---
--+----------+---------------------------------------------------------------
---Descri--o -  atualização dos campos do integrador na nota fiscal       ---
--+-----------------------------------------------------------------------+--
--+-----------------------------------------------------------------------+--
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/

user function MS520DEL
Local aArea := GetArea()
if !Empty(SD2->D2_XINTEGR)
    aDados:= {}

	Aadd(aDados, Left(SE1->E1_XINTEGR,TamSx3("C5_CLIENTE")[1]))
	Aadd(aDados, Right(SE1->E1_XINTEGR,TamSx3("C5_LOJACLI")[1]))
	Aadd(aDados,'N') // Cancelamento Nota Fiscal
	Aadd(aDados, SE1->E1_VALOR)
	// Grava Histórico Limite Integrador
	u_AtuLimCr(aDados) 

Endif
RestArea(aArea)
Return
