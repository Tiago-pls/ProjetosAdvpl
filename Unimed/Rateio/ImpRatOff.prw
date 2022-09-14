#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  IMPMEDCO     ¦ Autor ¦ Tiago Santos      ¦ Data ¦26.12.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Importa??o Cadastros de Medicos Cooperados TAF 		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

user function ImpRatOff()
                     
Local cTitulo   := "Selecione o Diretorio para Importar Rateio Off line..."
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
¦¦¦Fun??o    ¦  ProcArq    ¦ Autor ¦ Tiago Santos        ¦ Data ¦18.09.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Processa o arquivo selecionado                 		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

static function ProcArq(cArq)  
Local nOpcA

Local aAutoItens := {}
Local xCab 
Local nCont := 0
PRIVATE lMsErroAuto := .F. 
FT_FUSE(cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()        

aDados := {}     

lPrim := .T.

While !FT_FEOF()
 
	IncProc("Lendo arquivo texto..." + cValToChar(nCont))
 
	cLinha := FT_FREADLN()
    
	If lPrim
		lPrim := .F.
	Else 
		if !Empty(cLinha )
			nCont ++  		
			AADD(aDados,Separa(cLinha,";",.T.))	                                                    
		endif
	EndIf
		
	FT_FSKIP()
EndDo

// montagem das variaveis para execauto
cCtq_Rateio := CriaVar("CTQ_RATEIO")
cCtq_Desc := CriaVar("CTQ_DESC")
cCtq_Tipo := CriaVar("CTQ_TIPO")
cCtq_CtPar := CriaVar("CTQ_CTPAR")
cCtq_CCPar := CriaVar("CTQ_CCPAR")
cCtq_ItPar := CriaVar("CTQ_ITPAR")
cCtq_ClPar := CriaVar("CTQ_CLPAR")
cCtq_CtOri := CriaVar("CTQ_CTORI")
cCtq_CCOri := CriaVar("CTQ_CCORI")
cCtq_ItOri := CriaVar("CTQ_ITORI")
cCtq_ClOri := CriaVar("CTQ_CLORI")
nCtq_PerBas := CriaVar("CTQ_PERBAS")
cCtq_MSBLQL := '0' 

cConta := " "
cSeq :=''
nConta:=0
for nCont := 1 to len(aDados)

	// se for primeiro registro ou contas diferentes
	if !Empty(cSeq) .and. cSeq <> aDados[nCont,1]
		nConta+= gravaCTQ(xCab,aAutoItens)
	endif
	
	// se for primeiro registro ou contas diferentes
	if Empty(cSeq) .or. cSeq <> aDados[nCont,1]

		cCod := GetSXENum("CTQ","CTQ_RATEIO")
		aAutoItens :={}

		xCab := { {cCtq_Rateio , cCod ,NIL},;
		{cCtq_Desc ,'RATEIO OFF LINE' ,NIL},;
		{cCtq_Tipo ,'1' ,NIL},;
		{cCtq_CtPar ,' ' ,NIL},;
		{cCtq_CcPar ,' ' ,NIL},;
		{cCtq_ItPar ,' ' ,NIL},;
		{cCtq_ClPar ,' ' ,NIL},;
		{cCtq_CtOri , alltrim( aDados[nCont,4]) ,NIL},;
		{cCtq_CCOri , Alltrim( aDados[nCont,2]) ,NIL},;
		{cCtq_ItOri ,' ' ,NIL},;
		{cCtq_ClOri ,' ' ,NIL},;
		{nCtq_PerBas ,100 ,NIL},;
		{cCtq_MSBLQL ,'2' ,NIL} } 
	endif

	aAdd(aAutoItens,{ {'CTQ_FILIAL' ,'01' , NIL},;
	{'CTQ_CTORI' , alltrim( aDados[nCont,4]) , NIL},;
	{'CTQ_CCORI' , alltrim( aDados[nCont,2]) , NIL},;
	{'CTQ_ITORI' ,'', NIL},;
	{'CTQ_CLORI' ,'' , NIL},;
	{'CTQ_CTPAR' ,'' , NIL},;
	{'CTQ_CCPAR' ,'' , NIL},;
	{'CTQ_ITPAR' ,'' , NIL},;
	{'CTQ_CLPAR' ,'' , NIL},;
	{'CTQ_SEQUEN' , StrZero(nCont,3) , NIL},;
	{'CTQ_CTCPAR' ,alltrim( aDados[nCont,5]) , NIL},;
	{'CTQ_CCCPAR' ,alltrim( aDados[nCont,3]) , NIL},;
	{'CTQ_ITCPAR' ,'' , NIL},;
	{'CTQ_CLCPAR' ,'' , NIL},;
	{'CTQ_UM' ,'UN' , NIL},;
	{'CTQ_VALOR' ,0 , NIL},;
	{'CTQ_PERCEN' ,val(Strtran(aDados[nCont,6], ",",".")), NIL},;
	{'CTQ_FORMUL' ,'1' , NIL},;
	{'CTQ_INTERC' ,'2', NIL} } ) 


	cSeq := aDados[nCont,1]
Next nCont
// grava o ultimo registro
nConta+= gravaCTQ(xCab,aAutoItens)

MSGALERT( "Foram importados " + cValtoChar(nConta) + " registros", "Importacao" ) 
Return                    


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  GravaCTQ     ¦ Autor ¦ Tiago Santos      ¦ Data ¦26.12.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Gravacao rateio Off line                    		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/


static function gravaCTQ(xCab,aAutoItens)
Local _lOk := .T.
Local nConta := 0
Public cRateio :=""
MSExecAuto( {|X,Y,Z| CTBA270(X,Y,Z)} ,xCab ,aAutoItens, 3) 
If lMsErroAuto <> Nil
	If !lMsErroAuto
		_lOk := .T.
		CTQ->(ConfirmSX8())
		If !IsBlind()
			nConta ++
			Aadd( aAutoItens[1], { 'CTQ_RATEIO', xCab[1,2],''})
			cRateio :=  xCab[1,2]
			GravaLog(aAutoItens)
		EndIf
	Else
		_lOk := .F.
		If !IsBlind()
			MostraErro()
			MsgAlert('Erro na inclusao!')
			CTQ->( RollbackSx8())
		Endif
	EndIf
EndIf
return nConta


static function GravaLog(aAutoItens)
Local aDados :={}
Local nSeq  :=1
Local nConta :=0
For nConta :=1 to Len(aAutoItens) // linhas do arquivo

	For nCampos := 1 to len(aAutoItens[nConta])
		if ! Empty(aAutoItens[nConta, nCampos,2])
			Aadd(aDados,{ aAutoItens[nConta,nCampos,1],"" , aAutoItens[nConta,nCampos,2]})
		endif
	Next nCampos
Next nConta
u_GravaLog(2, aDados, "C")		// inclusao	
return
