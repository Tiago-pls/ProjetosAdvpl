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

user function ImpRatfol()
                     
Local cTitulo   := "Selecione o Diretorio para Importar Rateio Folha..."
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
PRIVATE lMsErroAuto := .F. 
FT_FUSE(cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()        

aDados := {}     

lPrim := .T.
nCont := 0
While !FT_FEOF()
 
	IncProc("Lendo arquivo texto..." + cValToChar(nCont))
 
	cLinha := FT_FREADLN()
    
	If lPrim
		lPrim := .F.
	Else  
		nCont ++  		
		AADD(aDados,Separa(cLinha,";",.T.))	                                                    
	EndIf
		
	FT_FSKIP()
EndDo

cZ39_Filial := CriaVar("Z39_FILIAL")
cZ39_Num    := CriaVar("Z39_NUM")
cZ39_Funcio := CriaVar("Z39_FUNCIO")
cZ39_Vigenc := CriaVar("Z39_VIGENC")
cZ39_DtInic := CriaVar("Z39_DTINIC")
cZ39_DataFi := CriaVar("Z39_DATAFI")

cZ40_Filial := CriaVar("Z40_FILIAL")
cZ40_Num    := CriaVar("Z40_NUM")
cZ40_Funcio := CriaVar("Z40_FUNCIO")
cZ40_SEQ    := CriaVar("Z40_SEQ")
cZ40_CC     := CriaVar("Z40_CC")
cZ40_PERCRA := CriaVar("Z40_PERCRA")
cZ40_DIRECI := CriaVar("Z40_DIRECI")

cMat := " "
nConta:=0
for nCont := 1 to len(aDados)
	// se for primeiro registro ou contas diferentes
	if !Empty(cMat) .and. cMat <> aDados[nCont,2]
		nConta+= gravaZ39(xCab,aAutoItens)
	endif
	
	cFil := StrZero( Val(aDados[nCont,1]),2)
	dDat := Stod(Substr( aDados[nCont,3],7,4) + Substr( aDados[nCont,3],4,2) + Substr( aDados[nCont,3],1,2))
	// se for primeiro registro ou Matriculas
	if Empty(cMat) .or. cMat <> aDados[nCont,2]

		cCod := GetSXENum("Z39","Z39_NUM")
		aAutoItens :={}

		// inserir os valores a serem gravados no cabe?alho
		xCab := { {cZ39_Filial , cFil ,NIL}              ,;
		{cZ39_Num    , cCod ,NIL}                        ,;
		{cZ39_Funcio , StrZero( val( aDados[nCont,2]), 6) ,NIL},;
		{cZ39_Vigenc , 'S' ,NIL}                         ,;
		{cZ39_DtInic , dDat ,NIL}                         ,;
		{cZ39_DataFi , ' ' ,NIL}} 
	endif

	aAdd(aAutoItens,{ {'Z40_FILIAL' , cFil , NIL}       ,;
	{'Z40_NUM'    , cCod, NIL}                          ,;
	{'Z40_FUNCIO' , StrZero( val(aDados[nCont,2]), 6)  , NIL},;
	{'Z40_SEQ'    , StrZero( nCont,2), NIL}             ,;
	{'Z40_CC'     , AllTrim( aDados[nCont,4]) , NIL}    ,;
	{'Z40_DIRECI' , AllTrim( aDados[nCont,6]) , NIL}    ,;
	{'Z40_PERCRA' , Val( aDados[nCont,5]), NIL} }        ) 

	cMat := aDados[nCont,2]
Next nCont
// grava o ultimo registro
nConta+= gravaZ39(xCab,aAutoItens)

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


static function gravaZ39(xCab,aAutoItens)

Local nImp := 0
Local lGrav := .T.
Local nCont := 0
Local aDados :={}

// verificar se ha registros para a matrícula encontrada
// se houver, alterar, se não incluir
cChave := xCab[1,2] + xCab[3,2]
AtuZ39( cChave)

Begin transaction 
	if RecLock("Z39",.T.)
		Z39->Z39_FILIAL  	:= xCab[1,2]
		Z39->Z39_NUM		:= xCab[2,2]
		Z39->Z39_VIGENC		:= xCab[4,2]
		Z39->Z39_FUNCIO		:= xCab[3,2]
		Z39->Z39_DTINIC		:= xCab[5,2]	
		Aadd(aDados,{"Z39_FILIAL",""              , xCab[1,2]})
		Aadd(aDados,{"Z39_NUM",   ""              , xCab[2,2]})
		Aadd(aDados,{"Z39_VIGENC",""              , xCab[4,2]})
		Aadd(aDados,{"Z39_FUNCIO",""              , xCab[3,2]})
		Aadd(aDados,{"Z39_DTINIC",Stod('  /  /  '), xCab[5,2]})

		u_GravaLog(2, aDados, "F")		// inclusao	
	MsUnLock("Z39")
		ConfirmSX8()
	else
		RollbackSx8()
		lGrav := .F.
	endif

	for nCont :=1 to len(aAutoItens) 
		RecLock("Z40",.T.)
			Z40->Z40_FILIAL  	:= xCab[1,2]
			Z40->Z40_NUM		:= xCab[2,2]
			Z40->Z40_FUNCIO		:= xCab[3,2]
			Z40->Z40_CC   	    := aAutoItens[nCont,5,2]
			Z40->Z40_PERCRA   	:= aAutoItens[nCont,7,2]
			Z40->Z40_DIRECI   	:= Upper(aAutoItens[nCont,6,2])
			Z40->Z40_ATIVAC   	:= "S"
			Z40->Z40_SEQ     	:= aAutoItens[nCont,4,2]
		MsUnLock("Z40")
			aCampos:={}
			Aadd(aCampos,{"Z40_FILIAL","", xCab[1,2]})
			Aadd(aCampos,{"Z40_NUM",   "", xCab[2,2]})
			aadd(aCampos,{"Z40_FUNCIO","", xCab[3,2]})
			Aadd(aCampos,{"Z40_CC",    "", aAutoItens[nCont,5,2]})
			aadd(aCampos,{"Z40_PERCRA",0,  aAutoItens[nCont,7,2]})
			aadd(aCampos,{"Z40_DIRECI","", Upper(aAutoItens[nCont,6,2])})
			Aadd(aCampos,{"Z40_ATIVAC","", "S"})
			u_GravaLog(2, aCampos,"F")

	Next nCont
	nImp ++
END TRANSACTION
return nImp

static function AtuZ39(cChave)
if select("Z39")==0
	DbSelectArea("Z39")
Endif

Z39->( DbSetOrder(2)) // Filial + MAtricula
Z39->( DbGotop())

if Z39->( dbSeek(cChave))
	// enquanto houver registros para o funcionario, deverá informar como inativo
	While Z39->(Z39_FILIAL + Z39_FUNCIO) = cChave
		RecLock("Z39",.F.)
			Z39->Z39_VIGENC := "N"
			Z39->Z39_DATAFI := dDataBase

		MsUnlock("Z39")
		Z39->(DbSkip())
	enddo
Endif
return

