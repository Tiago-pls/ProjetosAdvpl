#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  IMPRHO       ¦ Autor ¦ Tiago Santos      ¦ Data ¦23.09.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Importação eventos Cooparticipação           		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

user function IMPRHO()
                     
Local cTitulo   := "Selecione o Diretorio para Importar Cooparticipação..."
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
¦¦¦Fun??o    ¦  ProcArq    ¦ Autor ¦ Tiago Santos        ¦ Data ¦23.09.20 ¦¦¦
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
    
	If lPrim
		lPrim := .F.
	Else  		  
		nQtd += gravaBH( Separa( cLinha,";",.T.))                                                  
	EndIf
		
	FT_FSKIP()
EndDo

MSGALERT( "Foram importados " + cValtoChar(nQtd) + " registros", "Importacao" ) 
Return                    


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  gravaBH     ¦ Autor ¦ Tiago Santos      ¦ Data ¦22.09.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Gravacao Banco de Horas                		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

static function gravaBH( aDados)

Local nImp := 0

if select("RHO") == 0 
    DbSelectArea("RHO")
Endif

if select("SRA") == 0 
    DbSelectArea("SRA")
Endif

cFil := StrZero(val(aDados[1]),2)
cMat := StrZero(val(aDados[2]),6)
cCodForn := StrZero(val(aDados[3]),3)
cPD := StrZero(val(aDados[4]),3)
nValor := val( StrTran(adados[5], ",", "."))
cData := subStr(adados[6],7,4) + SubStr(adados[6],4,2) + SubStr(adados[6],1,2)

SRA->( DbSetOrder(1))
SRA->( DbSeek( cFil + cMat ))
cCPF := SRA->RA_CIC

RHO->( DbSetOrder(1)) // RHO_FILIAL + RHO_MAT + DTOS(RHO_DTOCOR) + RHO_TPFORN + RHO_CODFOR + RHO_ORIGEM + RHO_PD + RHO_COMPPG
RHO->( Dbgotop()) // 1 - 1 

if  RHO->( DbSeek( cFil + cMat + cData + "1" + cCodForn + "1" + cPD +  SubStr(cData,1,6 )))
    // verificar se ha registros para a matrícula encontrada
    // se houver, alterar, se não incluir

    Begin transaction 
        if RecLock("RHO",.F.)
            RHO->RHO_VLRFUN     := nValor
            MsUnLock("RHO")
        endif      
    END TRANSACTION

else
     Begin transaction 
        if RecLock("RHO",.T.)
            RHO->RHO_FILIAL  	:= cFil
            RHO->RHO_MAT		:= cMat
            RHO->RHO_DTOCOR		:= Stod( cData)
            RHO->RHO_ORIGEM	    := "1"
            RHO->RHO_TPFORN	    := "1"
            RHO->RHO_CODFOR	    := cCodForn
            RHO->RHO_TPLAN	    := "1"
            RHO->RHO_PD	        := cPd
            RHO->RHO_VLRFUN     := nValor
            RHO->RHO_COMPPG     := AnoMes(Stod( cData))
            RHO->RHO_CPF        := cCPF

       
            
            MsUnLock("RHO")            
        endif      
    END TRANSACTION   

endif
nImp ++
return nImp
