#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "TOTVS.ch"
#Include "TbiConn.ch"
#Include "RwMake.ch"

User Function CNT121_001()
	Local oModel	:= Nil
	Local cCodCTR	:= "2021000040"
	Local cNumMed	:= ""
	Local aMsgDeErro:= {}
	Local lRet		:= .F.
	Local nXi
	Local cMensagem := ""

	PREPARE ENVIRONMENT EMPRESA "26" FILIAL "260101"// MODULO "GCT"

	CN9->(DbSetOrder(1))

	If CN9->(DbSeek(xFilial("CN9") + cCodCTR))//Posicionar na CN9 para realizar a inclus�o
		oModel := FWLoadModel("CNTA121")
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		If(oModel:CanActivate())
			oModel:Activate()
			oModel:SetValue("CNDMASTER","CND_CONTRA"	,CN9->CN9_NUMERO)
			oModel:SetValue("CNDMASTER","CND_RCCOMP"	,"1")//Selecionar compet�ncia

			oModel:SetValue("CXNDETAIL","CXN_CHECK"	, .T.)//Marcar a planilha(nesse caso apenas uma)
// tratar o item 004,005 e 006 
			For nI := 1 to 3 //len(aCtrItens)					
        	    oModel:GetModel('CNEDETAIL'):GoLine(nI) //Posiciona na linha desejada				
				oModel:GetModel('CNEDETAIL'):LoadValue('CNE_ITEM', Strzero(nI,2))//Adiciona um item a planilha
				oModel:SetValue('CNEDETAIL', 'CNE_PRODUT' , iif(nI == 1, 'F2040',iif(nI == 2, 'F2043','F2030') ) )
				oModel:SetValue('CNEDETAIL', 'CNE_QUANT'  , 1)     
			Next n1 

			If (oModel:VldData()) /*Valida o modelo como um todo*/
				oModel:CommitData()
			EndIf
		EndIf

		If(oModel:HasErrorMessage())
			aMsgDeErro := oModel:GetErrorMessage()
			cMensagem := "Erro SIGAUTO MODELO MVC."
			cMensagem += "Exemplo TOTVS link: https://tdn.engpro.totvs.com.br/display/public/PROT/Utilizando+o+modelo+do+CNTA121"
			For nXi := 1 To Len(aMsgDeErro)
				If(aMsgDeErro[nXi] <> Nil)
					cMensagem += IIf(ValType(aMsgDeErro[nXi])<> "C", AllTrim(Str(aMsgDeErro[nXi])), AllTrim(aMsgDeErro[nXi]))
				EndIf
			Next nXi
			MsgInfo(cMensagem)
		Else
			cNumMed := CND->CND_NUMMED
			oModel:DeActivate()
			//lRet := CN121Encerr(.T.) //Realiza o encerramento da medi��o
		EndIf
	EndIf
Return lRet
