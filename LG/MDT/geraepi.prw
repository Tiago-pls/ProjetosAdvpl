#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#include 'tbiconn.ch'
#include "RWMAKE.CH"
#include 'parmtype.ch'
#Define ENTER  ''
User function IMPPEI()
                     
Local cTitulo   := "Selecione o arquivo a ser importado..."
Local nMascpad  := 0                        
Local cDirini   := "\"
Local nOpcoes   := GETF_LOCALHARD
Local lArvore   := .F. /*.T. = apresenta o ?rvore do servidor || .F. = n?o apresenta*/   
Local lSalvar   := .F. /*.T. = Salva || .F. = Abre*/
                                                                            
cArq := cGetFile( '*.csv|*.csv' , cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)

If !File(cArq)
	MsgStop("O arquivo  nao foi encontrado. A importacao sera abortada!","[AEST901] - ATENCAO")
	Return
EndIf 
   
MsAguarde({|| ProcArq(cArq)}, "Aguarde...", "Processando Registros...")

Return

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  ProcArq    ¦ Autor ¦ Tiago Santos        ¦ Data ¦16.10.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Processa o arquivo selecionado                 		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

static function ProcArq(cArq)  

FT_FUSE(cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()        

aDados := {}     

lPrim := .T.
nQtd := 0
While !FT_FEOF()
 
	IncProc("Lendo arquivo texto..." + cValToChar(nQtd))
 
	cLinha := FT_FREADLN()
    cLinha := U_TrataCar(cLinha)
	If lPrim
		lPrim := .F.
	Else  		  
		nQtd += IMPSST( Separa( cLinha,";",.T.))                                                  
	EndIf
		
	FT_FSKIP()
EndDo

MSGALERT( "Foram importados " + cValtoChar(nQtd) + " registros", "Importacao" ) 
Return                    


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  gravaBH     ¦ Autor ¦ Tiago Santos      ¦ Data ¦16.10.21  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Gravacao Banco de Horas                		              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

static function IMPSST( aDados)

Local nImp    := 0
local cNome   := Upper(Substr(cArq, RAt( "\" , cArq) +1, len(cArq) ))
Local cFil := FWFilial()

DO CASE 

    CASE "EPIFOR" $ cNome
        if select("SB1") ==0
            DbSelectArea("SB1")
        Endif

        SB1->(dbSetOrder(1))
        SB1->( dbGotop())
        cEPI := Alltrim(aDados[2])
        if SB1->( DbSeek( xFilial("SB1") + cEPI ))
           /* if RecLock("TN3",.T.)
                TN3->TN3_CODEPI := cEPI
                TN3->TN3_FORNEC := '005011'
                TN3->TN3_LOJA   := '01'
                TN3->TN3_NUMCAP := Alltrim(aDados[5])
                TN3->TN3_DTVENC := Stod(right(Alltrim(aDados[6]),4) +  SubStr(aDados[6],4,2) + Left(adados[6],2))
                TN3->TN3_DURABI := val(aDados[8])
                TN3->TN3_INDEVO := '1'
                TN3->TN3_PERMAN := val(aDados[8])
                TN3->TN3_TPDURA := 'G'
                TN3->TN3_GENERI := '1' // verificar
                MsUnLock("TN3")
            Endif  */

            aGHE := Separa (StrTran(adados[10],' ',''), ",",.T.)
            for nCont :=1 to len(aGHE)
                TIK->( dbSetOrder(1))
                TIK->( DbGotop())

                if ! TIK->( DbSeek( cFil + aGHE[nCont] + cEPI))

                    if RecLock("TIK",.T.)
                        TIK->TIK_FILIAL := cFil
                        TIK->TIK_TAREFA := aGHE[nCont]
                        TIK->TIK_EPI    := cEPI
                        MsUnLock("TIK")
                    Endif 
                Endif 
            nEXT nCont
        Endif
    OTHERWISE
ENDCASE

nImp ++
return nImp



user function GeraREPI()

cQuery := " select TN0_NUMRIS, TN0_CODTAR, TN0_AGENTE, TIK_EPI from TN0020 TN0 "
cQuery += " inner join TIK020 TIK on TN0_CODTAR = TIK_TAREFA Where TN0_FILIAL in('04','02') and TN0.D_E_L_E_T_ =' '"

if select("XML") > 0
    XML->( dbcloseArea())
Endif

if select("TNX") > 0
    TNX->( dbcloseArea())
Endif


TcQuery cQuery New Alias "XML" 
DbSelectArea("TNX")
TNX->(dbSetOrder(1))
While XML->( !EOF())

    If !TNX->( DbSeek(xFilial("TNX") + XML->TN0_NUMRIS + XML->TIK_EPI))
        if RecLock("TNX",.T.)
            TNX->TNX_FILIAL := xFilial("TNX")
            TNX->TNX_NUMRIS := XML->TN0_NUMRIS
            TNX->TNX_EPI    := XML->TIK_EPI
            TNX->TNX_AGENTE := XML->TN0_AGENTE
            MsUnLock("TNX")
        Endif 
    endif
    XML->(DbSkip())
Enddo
return


user function GeraTNF()


cQuery := "select TN0_FILIAL, TN0_NUMRIS, TN0_CODTAR"
cQuery += ", TIK_EPI , TN6_MAT, TN3_FORNEC, TN3_LOJA, TN3_NUMCAP, TN3_DTVENC, RA_CODFUNC from "+ RetSqlName("TN0")
cQuery += " TN0 inner join TIK020 TIK on TN0_CODTAR = TIK_TAREFA and TN0_FILIAL = TIK_FILIAL"
cQuery += " inner join TN6020 TN6 on TN0_FILIAL = TN6_FILIAL and TN0_CODTAR = TN6_CODTAR"
cQuery += " inner join TN3020 TN3 on TIK_EPI = TN3_CODEPI"
cQuery += " inner join SRA020 SRA on TN0_FILIAL = RA_FILIAL and TN6_MAT = RA_MAT"
cQuery += " Where TN0_FILIAL ='02' and TN0.D_E_L_E_T_ =' ' and TIK.D_E_L_E_T_ =' ' and TN6.D_E_L_E_T_ =' '"
cQuery += " and TN3_FORNEC ='005011' and TN3_DTVENC >='20211201'"
cQuery += " order by 2"

if select("XML") > 0
    XML->( dbcloseArea())
Endif

TcQuery cQuery New Alias "XML" 

if select("TNF") == 0
    DbSelectArea("TNF")
Endif

TNF->(dbSetOrder(1)) //TNF_FILIAL+TNF_FORNEC+TNF_LOJA+TNF_CODEPI+TNF_NUMCAP+TNF_MAT+DTOS(TNF_DTENTR)+TNF_HRENTR       

While XML->( !EOF())

    TNF->(dbGotop())
    if ! TNF->(Dbseek(XML->(TN0_FILIAL + TN3_FORNEC + TN3_LOJA + TIK_EPI + TN3_NUMCAP + TN6_MAT +'20211013')))
        if RecLock("TNF",.T.)
            TNF->TNF_FILIAL := XML->TN0_FILIAL
            TNF->TNF_FORNEC := XML->TN3_FORNEC
            TNF->TNF_LOJA   := XML->TN3_LOJA
            TNF->TNF_CODEPI := XML->TIK_EPI
            TNF->TNF_MAT    := XML->TN6_MAT
            TNF->TNF_DTENTR := ddatabase
            TNF->TNF_HRENTR := '09:39:35'
            TNF->TNF_QTDENT := 1
            TNF->TNF_CODFUN := XML->RA_CODFUNC
            TNF->TNF_INDDEV := '2'
            TNF->TNF_NUMCAP := XML->TN3_NUMCAP
            TNF->TNF_EPIEFI := '1'

            MsUnLock("TNF")
        Endif 
    Endif

    XML->( Dbskip())
Enddo
return


