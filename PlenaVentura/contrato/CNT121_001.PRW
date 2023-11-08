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

	If CN9->(DbSeek(xFilial("CN9") + cCodCTR))//Posicionar na CN9 para realizar a inclusão
		oModel := FWLoadModel("CNTA121")

/*
			oModel:SetValue("CXNDETAIL","CXN_CHECK"	, .T.)//Marcar a planilha(nesse caso apenas uma)			
			oModel:GetModel('CNEDETAIL'):GoLine(1)
			oModel:SetValue( 'CNEDETAIL' , 'CNE_QUANT' 	, 1)			
			
*/
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		If(oModel:CanActivate())
			oModel:Activate()
			oModel:SetValue("CNDMASTER","CND_CONTRA"	,CN9->CN9_NUMERO)
			oModel:SetValue("CNDMASTER","CND_RCCOMP"	,"1")//Selecionar competência

			oModel:SetValue("CXNDETAIL","CXN_CHECK"	, .T.)//Marcar a planilha(nesse caso apenas uma)
			// teste informando multiplos itens 
			oModel:GetModel('CNEDETAIL'):GoLine(1)
			oModel:GetModel('CNEDETAIL'):LoadValue('CNE_ITEM', '01')//Adiciona um item a planilha
			oModel:SetValue( 'CNEDETAIL' , 'CNE_PRODUT'	, 'F2040')
			oModel:SetValue( 'CNEDETAIL' , 'CNE_QUANT' 	, 1)
			
			oModel:GetModel('CNEDETAIL'):GoLine(2)
			oModel:GetModel('CNEDETAIL'):LoadValue('CNE_ITEM', '02')//Adiciona um item a planilha
			oModel:SetValue( 'CNEDETAIL' , 'CNE_PRODUT'	, 'F2043')
			oModel:SetValue( 'CNEDETAIL' , 'CNE_QUANT' 	, 1)
			
			oModel:GetModel('CNEDETAIL'):GoLine(3)
			oModel:GetModel('CNEDETAIL'):LoadValue('CNE_ITEM', '03')//Adiciona um item a planilha
			oModel:SetValue( 'CNEDETAIL' , 'CNE_PRODUT'	, 'F2030')
			oModel:SetValue( 'CNEDETAIL' , 'CNE_QUANT' 	, 1)

				//oModel:SetValue( 'CNEDETAIL' , 'CNE_VLUNIT' , 2334.60 )

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
			//lRet := CN121Encerr(.T.) //Realiza o encerramento da medição
		EndIf
	EndIf
Return lRet
