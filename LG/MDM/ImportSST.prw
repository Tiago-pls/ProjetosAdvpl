#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#include 'tbiconn.ch'
#include "RWMAKE.CH"
#include 'parmtype.ch'
#Define ENTER  ''
User function ImpSST()
                     
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

dbCloseArea("TN5")
DO CASE 
    CASE "AMBIENTES" $ cNome
        cCodAmb:= left( StrTran( aDados[2],"-",""), TamSx3("TNE_CODAMB")	[1])
        if select("TNE") ==0
            DbSelectArea("TNE")
        Endif
        TNE->( dbSetOrder(1))
        TNE->( DbGotop())
        If ! TNE->( DbSeek(cFil +  cCodAmb ))
            Begin transaction 
                if RecLock("TNE",.T.)
                    TNE->TNE_FILIAL     := cFil
                    TNE->TNE_CODAMB     := cCodAmb
                    TNE->TNE_NOME       := Upper( NOaCento(Alltrim(aDados[3])))
                    TNE->TNE_LOCAMB     := '1' // Estabelecimento empregador
                    TNE->TNE_TPINS      := '1' // CNPJ
                    TNE->TNE_NRINS      := FWArrFilAtu()[18] // CNPJ Filial
                    MsUnLock("TNE")
                endif      
               /* if alltrim(adados[4])=='*'
                    aCC := RetCTT()
                else
                    aCC := Separa (StrTran(adados[4],' ',''), ",",.T.)
                Endif
               
                if select("TOQ") ==0
                    DbSelectArea("TOQ")
                Endif
                TOQ->( dbSetOrder(1))
                TOQ->( DbGotop())
                
                For nCont :=1 to len(aCC)
                    
                    if RecLock("TOQ",.T.)
                        TOQ->TOQ_FILIAL := cFil
                        TOQ->TOQ_CODAMB := cCodAmb
                        TOQ->TOQ_CC     := aCC[nCont]
                        MsUnLock("TOQ")
                    Endif 
                Next nCont
                 */
            END TRANSACTION
        endif
    CASE "FONTES" $ cNome
        if select("TN7") ==0
            DbSelectArea("TN7")
        Endif
        TN7->( dbSetOrder(1))
        TN7->( DbGotop())
        cCodFonte :=aDados[2]
         If ! TN7->( DbSeek(cFil +  cCodFonte ))
            Begin transaction 
                if RecLock("TN7",.T.)
                    TN7->TN7_FILIAL  := cFil
                    TN7->TN7_FONTE   := cCodFonte
                    TN7->TN7_NOMFON := Alltrim(upper(adados[3]))
                    MsUnLock("TN7")
                Endif
            END TRANSACTION
         Endif
    CASE "PRODQUI" $ cNome
         if select("TJB") ==0
            DbSelectArea("TJB")
        Endif
        TJB->( dbSetOrder(1))
        TJB->( DbGotop())
        cProd:= Alltrim(aDados[2])
        If ! TJB->( DbSeek(cFil +  cProd ))
            Begin transaction 
                if RecLock("TJB",.T.)
                    TJB->TJB_FILIAL := cFil
                    TJB->TJB_CODPRO := cProd
                    MsUnLock("TJB")
                    //TJB->TJB_MCARAC := Alltrim(NOaCento(ADados[3]))
                   // TJB->TJB_MPRCAT := Alltrim(NOaCento(ADados[4]))
                    //TJB->TJB_MESTOQ := Alltrim(NOaCento(ADados[5]))
                    //TJB->TJB_MDESCA := Alltrim(NOaCento(ADados[6]))
                    //msmm(, 80,,Alltrim(NOaCento(ADados[3])),1,,,"TJB","TJB_MCARAC")

                    aEPI := Separa (StrTran(adados[4],' ',''), ",",.T.)
                    if select("TJ9") ==0
                        DbSelectArea("TJ9")
                    Endif
                    TJ9->( dbSetOrder(1))
                    TJ9->( DbGotop())
                    
                    For nCont :=1 to len(aEPI)
                        
                        if RecLock("TJ9",.T.)
                            TJ9->TJ9_FILIAL := cFil
                            TJ9->TJ9_CODPRO := cProd
                            TJ9->TJ9_CODEPI := aEPI[nCont]
                            MsUnLock("TJ9")
                        Endif 
                    Next nCont
                    
                Endif
            END TRANSACTION
        Endif
    CASE "AGENTES" $ cNome
         if select("TMA") ==0
            DbSelectArea("TMA")
        Endif
        TMA->( dbSetOrder(1))
        TMA->( DbGotop())
        cAgente:= Alltrim(aDados[2])
        If ! TMA->( DbSeek(cFil +  cAgente ))
            Begin transaction 
                if RecLock("TMA",.T.)
                    TMA->TMA_FILIAL := cFil
                    TMA->TMA_AGENTE := cAgente
                    TMA->TMA_NOMAGE := Upper(Alltrim(aDados[3]))
                    TMA->TMA_GRISCO := alltrim(adados[4])
                    TMA->TMA_PROPAG := upper(alltrim(adados[6]))
                    TMA->TMA_AVALIA := upper(alltrim(adados[9]))
                    TMA->TMA_ESOC   := upper(alltrim(adados[8]))
                    MsUnLock("TMA")
                Endif

            END TRANSACTION
        endif
    CASE "CADGHE" $ cNome
     if select("TN5") ==0
            DbSelectArea("TN5")
        Endif
        TN5->( dbSetOrder(1))
        TN5->( DbGotop())
        cGHE:= left(alltrim(aDados[2]),6)
        If ! TN5->( DbSeek(cFil +  cGHE ))
            Begin transaction 
                if RecLock("TN5",.T.)
                    TN5->TN5_FILIAL := cFil
                    TN5->TN5_CODTAR := cGHE
                    TN5->TN5_NOMTAR := Upper(Alltrim(aDados[3]))
                    MsUnLock("TN5")
                Endif
            END TRANSACTION
            if len(adados) > 3
                aEPI := Separa (StrTran(adados[4],' ',''), ",",.T.)
                if select("TIK") ==0
                    DbSelectArea("TIK")
                Endif
                TIK->( dbSetOrder(1))
                TIK->( DbGotop())
                For nCont :=1 to len(aEPI)      
                    if ! TIK->( DbSeek( cFil + cGHE + aEPI[nCont]))      

                        if RecLock("TIK",.T.)
                            TIK->TIK_FILIAL := cFil
                            TIK->TIK_TAREFA := cGHE
                            TIK->TIK_EPI := aEPI[nCont]
                            MsUnLock("TIK")
                        Endif 
                    Endif
                Next nCont
            endif
        endif
     CASE "GHEFUN" $ cNome
        if select("TN6") ==0
            DbSelectArea("TN6")
        Endif
        TN6->( dbSetOrder(1))
        TN6->( DbGotop())
        cGHE:= left(alltrim(aDados[2]),6)
        cMat := Strzero(val(Alltrim(aDados[3])),6)
        cData := Strtran(aDados[5],'/','')
        cData := Right(cData,4) + SubStr(cData,3,2)+ SubStr(cData,1,2)
        If ! TN6->( DbSeek(cFil +  cGHE + cMat))
            Begin transaction 
                if RecLock("TN6",.T.)
                    TN6->TN6_FILIAL := cFil
                    TN6->TN6_CODTAR := cGHE
                    TN6->TN6_MAT    := cMat
                    TN6->TN6_DTINIC := sTod(cData)
                    MsUnLock("TN6")
                Endif
            END TRANSACTION
        Endif
     CASE "RISCOS" $ cNome
        if select("TN0") ==0
            DbSelectArea("TN0")
        Endif
        TN0->( dbSetOrder(1))
        TN0->( DbGotop())
        cData := Strtran(aDados[2],'/','')
        cData := Right(cData,2) + SubStr(cData,3,2)+ SubStr(cData,1,2)
        
        cAgente := Alltrim(aDados[3])
        cFonteGe:= Alltrim(aDados[4])
        cGHE:= left(alltrim(aDados[6]),6)
        nQtd := val(Alltrim(aDados[7]))
        cMapa :=  Alltrim(aDados[9])
        cAmbiente := left( StrTran( aDados[10],"-",""), TamSx3("TNE_CODAMB")	[1])
        cTenica := Upper(alltrim(adados[11]))
        cEPC    := iif( left( Upper( alltrim(adados[12])),1)== "S","1","2")
        cEPI    := iif( left( Upper( alltrim(adados[13])),1)== "S","1","2")
        cAposen := iif( left( Upper( alltrim(adados[14])),1)== "S","1","2")
        cCatRis := alltrim(aDados[15])
        cIndExp := alltrim(aDados[16])
        Begin transaction 
            if RecLock("TN0",.T.)
                TN0->TN0_FILIAL := cFil 
                TN0->TN0_NUMRIS := GetSxeNum("TN0","TN0_NUMRIS")
                TN0->TN0_DTRECO := sTod("20211013")
                TN0->TN0_AGENTE := cAgente
                TN0->TN0_FONTE  := cFonteGe
                TN0->TN0_CC     := '*' // todos CC
                TN0->TN0_CODFUN := '*' // todos CC
                TN0->TN0_DEPTO  := '*' // todos CC
                TN0->TN0_QTAGEN := nQtd
                TN0->TN0_LISASO := '3' // ASO e PPP
                TN0->TN0_GRAU   := '2' // ASO e PPP
                TN0->TN0_MAPRIS := '2' // ASO e PPP
                TN0->TN0_CODAMB := cAmbiente
                TN0->TN0_CODTAR := cGHE
                TN0->TN0_TECUTI := cTenica
                TN0->TN0_EPC    := cEPC
                TN0->TN0_NECEPI := cEPI
                TN0->TN0_APOESP := cAposen            
                TN0->TN0_CATRIS := cCatRis            
                TN0->TN0_INDEXP := cIndExp         
                ConfirmSX8()
            else
                RollbackSx8() 
            MsUnLock("TN0")
            Endif
        if select("TOT") ==0
            DbSelectArea("TN0")
        Endif

        END TRANSACTION
        
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
