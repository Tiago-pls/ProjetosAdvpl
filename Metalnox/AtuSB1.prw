//#INCLUDE "RWMAKE.CH"
#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! AtuSB1                                                  !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o       ! Rotina para cadastro de Tipos de Alteções Salariais   !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                      !
+------------------+---------------------------------------------------------!
!Data              ! 14/09/2022                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/

user function AtuSB1

Local cTitulo   := "Selecione o Diretorio para Importar Banco de Horas..."
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
return

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
		nQtd += gravaSB1( Separa( cLinha,";",.T.))                                                  
	EndIf
	FT_FSKIP()
EndDo
return

static function gravaSB1( aDados)

Local nImp := 0
if select("SB1") == 0 
    DbSelectArea("SB1")
Endif

if SB1->( DbSeek(aDados[1]+ aDados[2] ))
    Begin transaction 
        if RecLock("SB1",.F.)
            SB1->B1_DESC_I    := alltrim( aDados[3])
            MsUnLock("SB1")
        endif      
    END TRANSACTION
return nImp
