#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  ValProp    ¦ Autor ¦ Tiago Santos        ¦ Data ¦24.03.22 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Recalculo dos valores vale alimentação proporcionais      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
user function ValProp
cData := ''
lCalcula := .F.
nCont := 0
aRCG := RCG->( GetArea())
aRCF := RCF->( GetArea())

if cPeriodo == AnoMes(SRA->RA_ADMISSA)
    cData := DtoS(SRA->RA_ADMISSA)
    lCalcula := .T.
Elseif cPeriodo == AnoMes(SRA->RA_DEMISSA)
    cData := DtoS(SRA->RA_DEMISSA)
    lCalcula := .T.
endif
if lCalcula
    RCF->(  DbSetOrder(1))
    RCF->( DbGotop())
    RCF->( dbSeek(SRA->RA_FILIAL + cPeriodo))
    nDiastrab := RCF->RCF_DIATRA

    RCG->( dbSetOrder(2))
    RCG->( dbgotop())
    RCG->( DbSeek(SRA->RA_FILIAL + cProcesso + cPeriodo + cSemana + Space(3) + '@@@' + cData))
    //RCG_FILIAL+RCG_PROCES+RCG_PER+RCG_SEMANA+RCG_ROTEIR+RCG_TNOTRA+DTOS(RCG_DIAMES)
    While RCG->RCG_PER == cPeriodo
        if RCG->RCG_VALIM =='1'
            nCont +=1
        endif
        RCG->( DbSkip())
    Enddo
    nValor:= fBuscaPD("693")
    nValor := nValor / nDiastrab * nCont 
    fDelPd("693")
    FGERAVERBA("693", nValor  , 0 ,CSEMANA,SRA->RA_CC,,"R",,,DDATA_PGTO,.F.,,,,,,,,DDATAREF)
    
Endif
Return
