#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#include 'tbiconn.ch'
#include "RWMAKE.CH"
#include 'parmtype.ch'

user function GeraAmbTar()

cQuery := 'select  distinct TN0_FILIAL, TN0_CODAMB, TN0_CODTAR'
cQuery += ' from ' + RetSqlName('TN0') +" TN0 Where D_E_L_E_T_ =' '"

if select("QRY") > 0
    XML->( dbcloseArea())
Endif

TcQuery cQuery New Alias "QRY" 


if select("TOT") == 0
    DbSelectArea("TOT")
Endif
TOT->( DbOrderNickName("AMBGHE"))

while ! QRY->( EOF())
    TOT->( dbgotop())
    if !TOT->( dbseek( QRY->(TN0_FILIAL + TN0_CODAMB +TN0_CODTAR)))
        if RecLock("TOT",.T.)
            TOT->TOT_FILIAL := QRY->TN0_FILIAL
            TOT->TOT_CODAMB := QRY->TN0_CODAMB
            TOT->TOT_TAREFA := QRY->TN0_CODTAR
        Endif
    Endif
    QRY->( dbskip())
Enddo
Return

user function GeraEPI()
local cQuery:="select TIK_FILIAL, TIK_TAREFA, TIK_EPI , TN6_MAT, RA_CODFUNC from "+ RetSqlName("TIK") +" TIK"
cQuery += " Inner join "+RetSqlName("TN6") + " TN6 on TIK_FILIAL= TN6_FILIAL and TIK_TAREFA = TN6_CODTAR"
cQuery += " Inner join "+RetSqlName("SRA") + " SRA on TIK_FILIAL= RA_FILIAL and TN6_MAT = RA_MAT"
cQuery += " where TIK.D_E_L_E_T_ =' ' and TN6.D_E_L_E_T_ =' ' and SRA.D_E_L_E_T_ =' '"
if select("QRY") > 0
    QRY->( dbcloseArea())
Endif

TcQuery cQuery New Alias "QRY" 

if select("TN3") == 0
    DbSelectArea("TN3")
Endif
TN3->( DbSetorder(2)) // Filial + EPI

if select("TNF") == 0
    DbSelectArea("TNF")
Endif
TNF->( DbSetorder(3)) // Filial + Mat + EPI

While QRY->( ! EOF())
    if TN3->( dbSeek ( xFilial("TN3") + QRY->TIK_EPI))
        cFornec := TN3->TN3_FORNEC
        cLoja   := TN3->TN3_LOJA
        cMat    := QRY->TN6_MAT
        cNumCAP := TN3->TN3_NUMCAP
        dDtVenc := TN3->TN3_DTVENC
        dDtReci := Stod("20211013")
        nQtdEnt := 1
        cHrEntr :="08:00:00"
        cCodFun := QRY->RA_CODFUNC
        cIndDev := '2'
        TNF->(dbgotop())
        if ! TNF->( Dbseek(QRY->(TIK_FILIAL + TN6_MAT + TIK_EPI)))
            if RecLock("TN7",.T.)
                TNF->TNF_FILIAL := QRY->TIK_FILIAL
                TNF->TNF_FORNEC := cFornec
                TNF->TNF_LOJA   := cLoja
                TNF->TNF_CODEPI := QRY->TIK_EPI
                TNF->TNF_MAT    := QRY->TN6_MAT
                TNF->TNF_DTENTR := dDtReci
                TNF->TNF_HRENTR := cHrEntr
                TNF->TNF_QTDENT := nQtdEnt
                TNF->TNF_DTRECI := dDtReci
                TNF->TNF_CODFUN := cCodFun
            Endif    
        Endif
    Endif

    QRY->( Dbskip())
End
Return
