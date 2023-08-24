#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

user function VB418
aArea := GetArea()

SRK->(dbSetOrder(3))//RK_FILIAL+RK_MAT+RK_PERINI+RK_NUMPAGO
SRK->(dbGotop())
if SRK->( DbSeek(SRA->RA_FILIAL + SRA->RA_MAT + cPeriodo))
    if SRK->RK_PD ='418'
        fDelpd("418")
    Endif
Endif
RestArea(aArea)
return
