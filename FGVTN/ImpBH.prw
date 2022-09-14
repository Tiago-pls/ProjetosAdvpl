#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  IMPBH        ¦ Autor ¦ Tiago Santos      ¦ Data ¦22.09.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Importação eventos Banco de Horas - SPI     		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

user function IMPBH()
                     
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
   
MsAguarde({|| lRet := ProcArq(cArq)}, "Aguarde...", "Processando Registros...")


Return lRet

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  ProcArq    ¦ Autor ¦ Tiago Santos        ¦ Data ¦18.09.19 ¦¦¦
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

if select("SPI") == 0 
    DbSelectArea("SPI")
Endif

if select("SRA") == 0 
    DbSelectArea("SRA")
Endif
SRA->( DbSetOrder(1))
SRA->( DbSeek("01"+ StrZero(val(aDados[2]),6)))
cCC := SRA->RA_CC

cMat := StrZero(val(aDados[2]),6)
cPD := StrZero(val(aDados[4]),3)
cData := subStr(adados[3],7,4) + SubStr(adados[3],4,2) + SubStr(adados[3],1,2)
SPI->( DbSetOrder(1)) // PI_FILIAL+PI_MAT+PI_PD+Dtos(PI_DATA)
SPI->( Dbgotop())

if  SPI->( DbSeek( "01"+cMat + cPD + cData))
    // verificar se ha registros para a matrícula encontrada
    // se houver, alterar, se não incluir

    Begin transaction 
        if RecLock("SPI",.F.)
            SPI->PI_QUANT	    := val( aDados[5])
            SPI->PI_QUANTV	    := val( aDados[5])
            MsUnLock("SPI")
        endif      
    END TRANSACTION

else
     Begin transaction 
        if RecLock("SPI",.T.)
            SPI->PI_FILIAL  	:= "01"
            SPI->PI_MAT		:= cMat
            SPI->PI_DATA		:= Stod( cData)
            SPI->PI_PD	        := cPD
            SPI->PI_CC		    := cCC
            SPI->PI_QUANT	    := val( aDados[5])
            SPI->PI_QUANTV	    := val( aDados[5])
            SPI->PI_FLAG	    := "I"
            MsUnLock("SPI")            
        endif      
    END TRANSACTION   

endif
nImp ++
return nImp
