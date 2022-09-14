#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#include 'tbiconn.ch'
#include "RWMAKE.CH"
#include 'parmtype.ch'
#Define ENTER  ''
User function Imp2200()
                     
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

dbCloseArea("TM4")
DO CASE 
    CASE "EXAMES" $ cNome
        cCodExame:= left( StrTran( aDados[2],"-",""), TamSx3("TM4_EXAME")	[1])
        if select("TM4") ==0
            DbSelectArea("TM4")
        Endif
        TM4->( dbSetOrder(1))
        TM4->( DbGotop())
        If ! TM4->( DbSeek(cFil +  cCodExame ))
            Begin transaction 
                if RecLock("TM4",.T.)
                    TM4->TM4_FILIAL     := cFil
                    TM4->TM4_EXAME      := cCodExame
                    TM4->TM4_NOMEXA     := Upper( NOaCento(Alltrim(aDados[3])))
                    TM4->TM4_INDRES     := Alltrim(aDados[4])
                    TM4->TM4_ADMISS     := iif( left( Upper( alltrim(adados[5])),1)== "S","1","2")
                    TM4->TM4_DEMISS     := iif( left( Upper( alltrim(adados[6])),1)== "S","1","2")
                    TM4->TM4_RETORN     := iif( left( Upper( alltrim(adados[7])),1)== "S","1","2")
                    MsUnLock("TM4")
                endif      
            END TRANSACTION
        endif
    CASE "EXAFOR" $ cNome
        if select("TMD") ==0
            DbSelectArea("TMD")
        Endif
        TMD->( dbSetOrder(1))
        TMD->( DbGotop())
        cExame := alltrim(aDados[2])
        cForn  := Strzero(val(Alltrim(aDados[3])),6)
        cLoja  := Strzero(val(Alltrim(aDados[4])),2)
        
         If ! TMD->( DbSeek(cFil +  cForn+  cLoja+ cExame ))
            Begin transaction 
                if RecLock("TMD",.T.)
                    TMD->TMD_FILIAL  := cFil
                    TMD->TMD_FORNEC  := cForn
                    TMD->TMD_LOJA    := cLoja
                    TMD->TMD_EXAME   := cExame
                    MsUnLock("TMD")
                Endif
            END TRANSACTION
         Endif

    CASE "EXAFUN" $ cNome
         if select("TM5") ==0
            DbSelectArea("TM5")
        Endif 
        if select("TM0") ==0
            DbSelectArea("TM0")
        Endif
        if select("TMD") ==0
            DbSelectArea("TMD")
        Endif
        TM0->(dbSetOrder(3))    //TM0_FILFUN+TM0_MAT+TM0_NUMDEP 
        TM0->( dbGotop())
        if TM0->( DbSeek(cFil + Alltrim(aDados[2])))
            nNumFic :=TM0->TM0_NUMFIC    
            cCCTM0 :=TM0->TM0_CC    
            cCodfun :=TM0->TM0_CODFUN    
            TM5->( dbSetOrder(6)) //TM5_FILIAL+TM5_NUMFIC+TM5_EXAME+DTOS(TM5_DTPROG)    
            TM5->( DbGotop())
            aExames := Separa (StrTran(adados[3],' ',''), ",",.T.)
            for nCont :=1 to len(aExames)
                TMD->( dbSetOrder(2))
                TMD->( DbGotop())
                
                If ! TM5->( DbSeek(cFil +  nNumFic + aExames[nCont]))
                    Begin transaction 
                        if RecLock("TM5",.T.)
                            TM5->TM5_MAT    := adados[2]
                            TM5->TM5_FILFUN := cFil
                            TM5->TM5_NUMFIC := nNumFic
                            TM5->TM5_EXAME  := aExames[nCont]
                            TM5->TM5_DTPROG := Stod( Right(adados[5],4) + SubStr(adados[5],4,2)+ SubStr(adados[5],1,2))
                            TM5->TM5_DTRESU := Stod( Right(adados[5],4) + SubStr(adados[5],4,2)+ SubStr(adados[5],1,2))
                            TM5->TM5_ORIGEX := '2'
                            TM5->TM5_CODRES := Alltrim(adados[4])
                            TM5->TM5_INDRES := '1'
                            TM5->TM5_NATEXA := '2' // verificar
                            TM5->TM5_CC     := cCCTM0
                            TM5->TM5_CODFUN := cCodFun

                            MsUnLock("TM5")
                        Endif
                    END TRANSACTION
                endif
            nEXT nCont

        Endif


        
    OTHERWISE
ENDCASE

nImp ++
return nImp


static function RetCTT()
aRet := {}
if select("CTT") == 0
    DbSelectArea("CTT")
Endif
CTT->( DbSetOrder(1))
CTT->( Dbgotop())

While CTT->( ! EOF())
    if CTT->CTT_BLOQ <> '1' .and. CTT->CTT_CLASSE ='2' // analitico e não bloqueado
        Aadd(aRet,Alltrim(CTT->CTT_CUSTO))
    Endif
    CTT->( DbSkip())
Enddo
return aRet
