#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  ImpHrsProj   ¦ Autor ¦ Tiago Santos      ¦ Data ¦15.08.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Importação dos valores de custos dos funcionarios         ¦¦¦
¦¦¦Descri??o ¦  para o campo AE8_VALOR                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
user function IMPMEDCO()
                     
Local cTitulo   := "Selecione o diretório para importação ... "
Local nMascpad  := 0                        
Local cDirini   := "\"
Local nOpcoes   := GETF_LOCALHARD
Local lArvore   := .F. /*.T. = apresenta o ï¿½rvore do servidor || .F. = nï¿½o apresenta*/   
Local lSalvar   := .F. /*.T. = Salva || .F. = Abre*/
                                                                            
cArq := cGetFile( '*.csv|*.csv' , cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)

If !File(cArq)
	MsgStop("O arquivo  não foi encontrado. A importação será abortada!","[AEST901] - ATENCAO")
	Return
EndIf       
   
MsAguarde({|| ProcArq(cArq)}, "Aguarde...", "Processando Registros...")


Return

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  ProcArq      ¦ Autor ¦ Tiago Santos      ¦ Data ¦15.08.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Processamento do arquivo                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
static function ProcArq(cArq)  
              
FT_FUSE(cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()        

aDados := {}     

lPrim := .T.
nCont := 0

if select("AE8")== 0 
	DbSelectArea("AE8")
Endif                  

AE8->( dbSetOrder(2)) // Filial + descrição

nQtd := 0

While !FT_FEOF()
 
	IncProc("Lendo arquivo texto..." + cValToChar(nCont))
 
	cLinha := FT_FREADLN()
    
	If lPrim
		lPrim := .F.
	Else  
		nCont ++
		AADD(aDados,Separa(cLinha,";",.T.))	                                                    
		MsProcTxt( Alltrim (aDados[nCont , 7 ] ))	
		AE8->(dbGotop())
		cChave := aDados[nCont , 2] + Alltrim(aDados[nCont , 7 ])
		
		if AE8->( DbSeek( cChave)  )
			GravaAE8(Atail( aDados[nCont] ))
			nQtd ++
		endif
		
	EndIf

	FT_FSKIP()
EndDo
                          
MSGALERT( "Foram importados " + cValtoChar(nQtd) + " registros", "Importacao" ) 
	
Return

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  GravaAE8      ¦ Autor ¦ Tiago Santos      ¦ Data ¦15.08.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Processamento do arquivo                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

static Function GravaAE8(nValor)         
BEGIN TRANSACTION       

	
	if RecLock("AE8", .F.)	
		AE8->AE8_CUSFIX    :=  val(STRTRAN(nValor, ",", "."))
		MsUnLock() // Confirma e finaliza a operaï¿½ï¿½o
	Endif
	
END TRANSACTION                                              
Return
