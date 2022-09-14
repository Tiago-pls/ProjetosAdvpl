#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#INCLUDE "TOTVS.CH"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  GPE_P        ¦ Autor ¦ Tiago Santos      ¦ Data ¦02.03.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Geração das verbas de provisões PLR na folha de pagamento ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
user function GPE_P
local aArea := GetArea()
local nAvos :=0
Local nIndice := SRA->RA_PLINDCE * SRA->RA_SALARIO
Local dCompetencia := Stod( cPeriodo + "01")

dDataInicio := Stod( SubStr( cPeriodo,1,4) + '0101')
dAdmissao := SRA->RA_ADMISSA

if dAdmissao < dDataInicio
    nAvos := Month(dCompetencia)
elseif Day(dAdmissao)>=16
    nAvos := Month(dCompetencia) - Month(dAdmissao)
endif
if MOnth(dCompetencia) = 1 // janeiro
    fDelPd("855")
endif

If nAvos > 0
	FGERAVERBA("856", (nIndice / 12) * nAvos ,nAvos,CSEMANA,SRA->RA_CC,,"G",,,DDATA_PGTO,.T.,,,,,,,,DDATAREF)
    FGERAVERBA("857", fBuscaPD("856,855") ,nAvos,CSEMANA,SRA->RA_CC,,"G",,,DDATA_PGTO,.T.,,,,,,,,DDATAREF)
Endif
RestArea(aArea)
Return
