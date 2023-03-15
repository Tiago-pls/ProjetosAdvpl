#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*__________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  FA070TIT   - Autor - Tiago Santos      - Data -02.02.23   ---
--+----------+---------------------------------------------------------------
---Descri--o -   PE    para atualizar o limite de crédito do Integrador   ---
--+-----------------------------------------------------------------------+--
--+-----------------------------------------------------------------------+--
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/

user function FA070CA2
Local aArea := GetArea()
if !Empty(SE1->E1_XINTEGR )
    aDados:= {}

	Aadd(aDados, Left(SE1->E1_XINTEGR,TamSx3("C5_CLIENTE")[1]))
	Aadd(aDados, Right(SE1->E1_XINTEGR,TamSx3("C5_LOJACLI")[1]))
	Aadd(aDados,'C') // Cancelamento Baixa
	Aadd(aDados, SE1->E1_VALOR)
	// Grava Histórico Limite Integrador
	u_AtuLimCr(aDados) 
Endif
RestArea(aArea)
Return
