#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"   

/*/{Protheus.doc} ExistFunc
//TODO Funcao validar funcionario informado
@author Tiago Santos
@since 23/03/2020
@type function
justes para gera??o na vers?o 12.1.25
/*/

User Function ExistFunc(_cFuncional)
	Local _lRetorno := .T.
	SRA->(DbSetOrder(1)) //Filial + Cod. Verba
	If SRA->(DbSeek(xFilial("SRA")+_cFuncional,.F.))

		If SRA->RA_SITFOLH $ ("D/T/A")
			MsgBox("Funcionario Inativo!","Atencao","ALERT")	      	
			_lRetorno := .F.
		else

			// verificar se ha rateio ativo para este funcionario
			aZ39Area := Z39->( GetArea())
				Z39->( DbSetORder(2)) // Filial + Matricula + Vigencia
				if Z39->( dbSeek(xFilial("Z39") + _cFuncional + "S" ))
					MsgBox("Funcionario Possui Rateio Vigente!","Atencao","ALERT")	      	
					_lRetorno := .F.
				else
					_cNome  := Alltrim(SRA->RA_NOME	)
					_nSalario := SRA->RA_SALARIO
					_lRetorno := .T.
				Endif
			RestArea(aZ39Area)


		Endif
	Else  
		MsgBox("Funcionario Inexistente!","Atencao","ALERT")	      	
		_lRetorno := .F.
	EndIf
Return(_lRetorno)


/*/{Protheus.doc} FimVigencia
//TODO FFuncao para tratar o fim da vigencia do Rateio do funcionario
@author Tiago Santos
@since 23/03/2020
@type function
justes para gera??o na vers?o 12.1.25
/*/
user function FimVigencia(_dDtIni,_dDtFim)
local lRet := .T.
if ! empty(_dDtFim)
	if _dDtFim < _dDtIni
		MSGALERT( "Data Fim de Vigencia Menor que a data inicio", "Atencao" )
		Return(.F.)
	endif
	If !MsgBox("Confirma Fim de Vigencia? ","Confirmacao","YESNO")          
		Return(.F.)
	EndIf
	_cVigencia := "N"
Else
	_cVigencia := "S"
Endif
Return lRet

/*/{Protheus.doc} IniVigencia
//TODO Funcao para tratar o fim da vigencia do Rateio do funcionario
@author Tiago Santos
@since 23/03/2020
@type function
justes para gera??o na vers?o 12.1.25
/*/

user function IniVigencia(_dDtIni)
local lRet := .T.
if empty(_dDtIni)
		MSGALERT( "Inicio de Vigencia nao Informado", "Atencao" )
		Return(.F.)
	endif
Return lRet


/*/{Protheus.doc} ValUser
//TODO Funcao validar usuario logado, para liberacao ou nao dos acessos
@author Tiago Santos
@since 25/03/2020
@type function
justes para gera??o na vers?o 12.1.25
/*/
user function ValUser(cUser)

Return iif (cUser $ GetMV("MV_RATFOL"), .T., .F.)

/*/{Protheus.doc} ValUser
//TODO Funcao validar usuario logado, para liberacao ou nao dos acessos
@author Tiago Santos
@since 25/03/2020
@type function
justes para gera??o na vers?o 12.1.25
/*/
user function GravaLog(_iOpcao, aCampos, cTipo)
Local nCont:= 0
Local cCampo :=""
local aArea:= GetArea()

if select("Z41") == 0
	DbSelectarea("Z41")
Endif

Begin Transaction
	for nCont :=1 to len(aCampos)
		cCampoP := u_RetCamGrv(aCampos[nCont,3])
		cCampoD := substr(cCampoP,1, len(cCampoP) -1) + "D"
		if (aCampos[nCont,1] =="CTQ_VALOR") .or. (aCampos[nCont,1] =="CTQ_PERCEN")
			aCampos[nCont,2] := Val(aCampos[nCont,2])
		Endif
		RecLock("Z41",.T.)
			Z41->Z41_FILIAL  	:= iif( empty(Z39->Z39_FILIAL), Z40->Z40_FILIAL, Z39->Z39_FILIAL)
			Z41->Z41_NUM		:= iif( cTipo <>"F", cRateio,iif(empty(Z39->Z39_NUM), Z40->Z40_NUM, Z39->Z39_NUM ))
			Z41->Z41_CAMPO		:= aCampos[nCont,1] // campo alterado
			Z41->Z41_DTGRAV		:= dDataBase  // data alteracao
			Z41->Z41_HRGRAV		:= alltrim(Time())  // data alteracao
			Z41->Z41_TPGRAV		:= _iOpcao  // data alteracao
			Z41->Z41_TIPO		:= cTipo  // data alteracao
			Z41->Z41_USUARI		:= RetCodUsr( )  // data alteracao
			Z41->Z41_NOME		:= UsrFullName( )   // data alteracao
			&cCampoD             := aCampos[nCont,2] // valor anterior
			&cCampoP             := aCampos[nCont,3] // valor anterior
		MsUnLock("Z41") 
	Next

end transaction 
RestArea(aArea)
Return 

/*/{Protheus.doc} ValUser
//TODO Funcao validar usuario logado, para liberacao ou nao dos acessos
@author Tiago Santos
@since 25/03/2020
@type function
justes para gera??o na vers?o 12.1.25
/*/
user function RetCamGrv(cCampo)
local cRet := ""
DO CASE
    CASE valtype(cCampo)=="C"
		cRet:= "Z41->Z41_TEXTOP"
    CASE valtype(cCampo)=="D"
		cRet:= "Z41->Z41_DATAP"
    CASE valtype(cCampo)=="N"
		cRet:= "Z41->Z41_NUMERP"
endcase
return cRet

/*/{Protheus.doc} CompArrays
//TODO Funcao validar usuario logado, para liberacao ou nao dos acessos
@author Tiago Santos
@since 25/03/2020
@type function
justes para gera??o na vers?o 12.1.25
/*/
user function CompArrays(aCamposZ40, aCols)
local aRet := {}
local nCont :=1
local nI :=1
Local lSkip:= .F.
Local nLenAcols :=0

for nCont := 1 to len(aCols)
	lSkip := .F.
	lFound :=.F.
	If !aCols[nCont, Len(aCols[1])]
		nLenAcols ++
		For nI:=1 to len(aCamposZ40)
			if lSkip
				Exit
			Endif

			//if aCols[nCont,1] == aCamposZ40[nI,1] 
			cSeq := Strzero(nCont,2)
			if cSeq == aCamposZ40[nI,1] 
				DO CASE
					CASE aCols[nCont,2] <> aCamposZ40[nI,2]  // Centro de Custo
						Aadd(aRet,{"Z40_CC", aCamposZ40[nI,2] ,aCols[nCont,2]})
					
					CASE aCols[nCont,4] <> aCamposZ40[nI,3]  // Percentual
						Aadd(aRet,{"Z40_PERCRA", aCamposZ40[nI,3] ,aCols[nCont,4]})
									
					CASE aCols[nCont,5] <> aCamposZ40[nI,4]  // Direcionador
						Aadd(aRet,{"Z40_DIRECI", aCamposZ40[nI,4] ,aCols[nCont,5]})
									
					CASE aCols[nCont,6] <> aCamposZ40[nI,5]  // Ativo
						Aadd(aRet,{"Z40_ATIVAC", aCamposZ40[nI,5] ,aCols[nCont,6]})					
				End Case
				lSkip := .T.

			elseif  nCont > len(aCamposZ40)// se n?o achar o registro ? novo
				Aadd(aRet,{"Z40_FILIAL" ,"", xFilial("Z40")})
				Aadd(aRet,{"Z40_CC"     ,"", aCols[nCont,2]})
				Aadd(aRet,{"Z40_PERCRA" ,0 , aCols[nCont,4]})
				Aadd(aRet,{"Z40_DIRECI" ,"", aCols[nCont,5]})
				Aadd(aRet,{"Z40_ATIVAC" ,"", aCols[nCont,6]})
				lSkip := .T.
			Endif

		next nI
	endif
Next nCont
// Apos varrer todo aCols, verificar se houve exclus?o Len(acols) < Len(aCamposZ40)
if nLenAcols < len(aCamposZ40)
aExcluir:={}
	
	For nCont := len(aCamposZ40) - nLenAcols to len(aCamposZ40)
		// gravar registros deletados

		Aadd(aExcluir,{"Z40_FILIAL" ,aCamposZ40[nCont,1], " "})
		Aadd(aExcluir,{"Z40_CC"     ,aCamposZ40[nCont,2], " "})
		Aadd(aExcluir,{"Z40_PERCRA" ,aCamposZ40[nCont,3], 0})
		Aadd(aExcluir,{"Z40_DIRECI" ,aCamposZ40[nCont,4], " "})
		Aadd(aExcluir,{"Z40_ATIVAC" ,aCamposZ40[nCont,5], " "})

	next nCont
		u_GravaLog(4, aExcluir)
Endif

return aRet
