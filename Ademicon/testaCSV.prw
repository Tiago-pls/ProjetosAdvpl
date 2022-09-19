user function VerCSV

                  
Local cTitulo   := "Selecione o Diretorio para Importar Cooparticipação..."
Local nMascpad  := 0                        
Local cDirini   := "\"
Local nOpcoes   := GETF_LOCALHARD
Local lArvore   := .F. /*.T. = apresenta o ?rvore do servidor || .F. = n?o apresenta*/   
Local lSalvar   := .F. /*.T. = Salva || .F. = Abre*/
                                                                            
cArq := cGetFile( '*.txt|*.txt' , cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)

If !File(cArq)
	MsgStop("O arquivo  nao foi encontrado. A importacao sera abortada!","[AEST901] - ATENCAO")
	Return
EndIf       
   
MsAguarde({|| ProcArq1(cArq)}, "Aguarde...", "Processando Registros...")

Return


static function ProcArq1(cArq)  

FT_FUSE(cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()           

lPrim := .T.
nQtd := 0
cLog := ""
While !FT_FEOF()
 
	IncProc("Lendo arquivo texto..." + cValToChar(nQtd))
 
	cLinha := FT_FREADLN()
    
	If lPrim
		lPrim := .F.
	Else  		  
		lAchou := ISS( cLinha )
	EndIf
	FT_FSKIP()
EndDo

Return    

static function VerCsv(aDados)
local nCont 
//adados arquivo ademilar - de referência     


    Begin Transaction
        RecLock('ZZ1', .T.)
            ZZ1_CNPJ  := adados[2]
            ZZ1_NOME  := adados[3]
            ZZ1_REF   :=  adados[4]
            ZZ1_DATA  :=  Strtran(adados[5],'/','')            
            ZZ1_VALOR  :=  val(Strtran(adados[6],',','.')  )
            ZZ1_TIPO  :=  adados[8]
        ZZ1->(MsUnlock())         
    //Finalizando controle de transações
    End Transaction

Return



static function ISS(cLinha)
local nCont 
//adados arquivo ademilar - de referência     

if SubStr( cLinha,76,14) =='00000000000000'
    cCNPJ := SubStr(cLinha,90,11)
else
    cCNPJ := SubStr(cLinha,76,14)
Endif
    Begin Transaction
        RecLock('ZZ2', .T.)
            ZZ2_CNPJ  := cCNPJ
            ZZ2_NOME  := SubStr(cLinha,101,40)
            ZZ2_DATA  := SubStr(cLinha,2,8)
            ZZ2_VALOR := val( SubStr(cLinha,36,15)) /100
            ZZ2_TIPO  := iif(SubStr( cLinha,76,14)=='00000000000000','07' ,'04')
        ZZ2->(MsUnlock())         
    //Finalizando controle de transações
    End Transaction

Return
