#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#INCLUDE "TOTVS.CH"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  TestSelec    ¦ Autor ¦ Tiago Santos      ¦ Data ¦02.02.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Testa a seleção dos modelos a serem gerados em PDF        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
user Function Compensacao ( cComp)
local aTabel_ := {}
Local cRet := ""
fCarrTab(@aTabel_,"U003")  

for ncont :=1 to len (aTabel_)
    if aTabel_[nCont, 5] = cComp
        cRet := Alltrim(aTabel_[nCont, 6])
    Endif
Next nCont

Return  cRet
