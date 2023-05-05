
#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! AxCadZZZ                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Markup por Estado                                       !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                            !
+------------------+---------------------------------------------------------!
!Data              ! 13/02/2023                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/
user function TK271BOK 
Local aArea := GetArea()
Local nCont :=1
Local aCardData :={}
Local aRecnoSUA 	:= {}
Local lIntFluig := .F.
Local cBloqOrc :='N'
if FWCodEmp() =='09'

	nPos := aScan(aHeader, {|x| AllTrim(x[2])=="UB_DESC"})
    For nCont := 1 to Len(aCols)
		if !aCols[nCont , Len(aCols[nCont])]
			if acols[nCont][nPos] > SU0->U0_XLIMDES
				// limite maior que o configurado no grupo de atendimentos
				lIntFluig := .T.
				cBloqOrc :="S"			
			Endif
		Endif
	Next nCont
	M->UA_XBLOQOR := cBloqOrc
	if lIntFluig
		//UsrRetMail(RetCodUsr()) testar com email do usuario
		cData := Substr(dtos(ddatabase),7,2) + '/' + Substr(dtos(ddatabase),5,2) + '/'+ Substr(dtos(ddatabase),1,4)
		
		//UsrRetMail(RetCodUsr())  - Solicitante
		aAdd(aCardData,{'emailSolicitante', "marcelo.rosa@plenaventura.com.br"})

		//UsrRetMail( SU7->U7_XAPROVA)  - Aprovador
		aAdd(aCardData,{'emailAprovador', "marcelo.rosa@plenaventura.com.br"})
		aAdd(aCardData,{'txtAtendimento', M->UA_NUM})
		aAdd(aCardData,{'txtCliente', M->UA_CLIENTE})
		aAdd(aCardData,{'txtLoja', M->UA_LOJA})
		aAdd(aCardData,{'txtEmpresa', FWCodEmp()})
		aAdd(aCardData,{'txtFilial', FwCodFil()})
		aAdd(aCardData,{'txtRecno',  cValToChar(M->(RECNO()+1))})
		aAdd(aCardData,{'txtDataSolicitacao', cData})
		aAdd(aCardData,{'txtContato', M->UA_CODCONT})
		aAdd(aCardData,{'txtNomeContato', M->UA_DESCNT})
		aAdd(aCardData,{'txtOperador', M->UA_OPERADO})
		aAdd(aCardData,{'docNome', 'Emp: '+ FWCodEmp() + " Fil: " + FwCodFil() +" Orc: " + M->UA_NUM })
		aAdd(aCardData,{'txtNomeOperador', UsrFullName(RetCodUsr())})
		aAdd(aCardData,{'txtCondicao', M->UA_CONDPG})
		aAdd(aCardData,{'txtCondicaoDescricao', posicione("SE4",1, xFilial("SE4") + M->UA_CONDPG, 'E4_DESCRI')})
		aAdd(aCardData,{'txtTabela', M->UA_TABELA})
		aAdd(aCardData,{'txtOperacao', '2'})    
		aAdd(aCardData,{'numQuestionamentos', '0'})    
		aAdd(aCardData,{'numAtividade', '0'})    
		cUserComp := GetLogFlg(Alltrim('000034')) // utilizar o usuario logado
		aAdd(aCardData,{'codSolicitante', cUserComp})    // solicitante
		//aAdd(aCardData,{'codAprovador',   GetLogFlg(Alltrim('000034'))})    // U7_XAPROV  aprovador
		aAdd(aCardData,{'codAprovador',   cUserComp})    // U7_XAPROV  aprovador
		for nCont :=1 to len(acols)
			if !aCols[nCont , Len(aCols[nCont])]
				
				cStatus := iif( acols[nCont][nPos] > SU0->U0_XLIMDES, 'Desconto maior que o permitido',' ')
					// limite maior que o configurado no grupo de atendimentos
				/*
				if nCont == 1
					cStatus :="V"
				else
					cStatus :="F"
				endif*/
				nPosItem    := aScan(aHeader,{|x| AllTrim(x[2])=="UB_ITEM"})
				nPosProd    := aScan(aHeader,{|x| AllTrim(x[2])=="UB_PRODUTO"})
				nPosQtd     := aScan(aHeader,{|x| AllTrim(x[2])=="UB_QUANT"})
				nPosVlr     := aScan(aHeader,{|x| AllTrim(x[2])=="UB_VRUNIT"})
				nPosVlrItem := aScan(aHeader,{|x| AllTrim(x[2])=="UB_VLRITEM"})
				nPosDesc    := aScan(aHeader,{|x| AllTrim(x[2])=="UB_DESC"})
				nPosValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="UB_VALDESC"})
				aAdd(aCardData,{'txtItem___'+cvaltochar(nCont), acols[nCont, nPosItem]})
				aAdd(aCardData,{'txtProduto___'+cvaltochar(nCont), Alltrim(acols[nCont, nPosProd]) +' - '+Alltrim( posicione('SB1',1,xFilial('SB1')+acols[nCont, nPosProd],'B1_DESC') )})
				aAdd(aCardData,{'txtQuantidades___'+cvaltochar(nCont), cValtoChar(acols[nCont, nPosQtd])})
				aAdd(aCardData,{'txtPrecoUnit___'+cvaltochar(nCont), PadR(TransForm(acols[nCont, nPosVlr],'@E 999,999,999.99'),15)})
				aAdd(aCardData,{'txtVlrItem___'+cvaltochar(nCont),PadR(TransForm(acols[nCont, nPosVlrItem ],'@E 999,999,999.99'),15)})
				aAdd(aCardData,{'txtDesconto___'+cvaltochar(nCont), PadR(TransForm(acols[nCont, nPosDesc],'@E 999,999,999.99'),15)})
				aAdd(aCardData,{'txtVlrDesc___'+cvaltochar(nCont), PadR(TransForm(acols[nCont, nPosValDesc],'@E 999,999,999.99'),15)})
				aAdd(aCardData,{'txtItemTotal___'+cvaltochar(nCont), PadR(TransForm(acols[nCont, nPosVlrItem ],'@E 999,999,999.99'),15)})
				aAdd(aCardData,{'txtStatus___'+cvaltochar(nCont), cStatus})
			Endif
		Next nCont
		//GeraFluig(aCardData, aRecnoSUA, cUserComp)
	Endif
Endif
RestArea(aArea)
return



/*
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++-----------------------------------------------------------------------------++
++ Função    | GeraFluig | Autor  | Anderson Jose Zelenski | Data | 02/06/2020 ++
++-----------------------------------------------------------------------------++
++ Descrição | Gerar no Fluig a Solicitação do WF de Pedidos de Compras        ++
++-----------------------------------------------------------------------------++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/
Static Function GeraFluig(aCardData, aRecnoSUA, cFluigMatr)
Local cFluigUsr 	:= AllTrim(GetMv("MV_FLGUSER"))
Local cFluigPss		:= AllTrim(GetMv("MV_FLGPASS"))
Local nCompany		:= 1
Local oFluigWrk
Local oObjAnxArr
Local oObjItArr
Local oObjItem
Local oObjLeagId
Local oObjAnexos
Local oObjAppoin
Local oObjRetorno
Local oObjRetItem
Local aItens	:= {}
Local cComments	:= ""
Local cProcess	:= "WFPLiberacaoOrcamento" 
Local lmanagerMode := .T.
Local lComplete := .T.
//Local cHoje		:= DtoC(Date())+" - "+Time()
Local nI		:= 1
Local cIdProcess:= ""

	conout("cFluigUsr: "+cFluigUsr)
	conout("cFluigPss: "+cFluigPss)

	// Inicia o Objeto do WebService com o Processo a ser iniciado no Fluig
	oFluigWrk := WSECMWorkflowEngineService():New()

	// Cria o Objeto com os anexos 
	oObjAnxArr := WsClassNew("ECMWorkflowEngineService_processAttachmentDtoArray")
	
	// Cria o objeto com os array dos itens
	oObjItArr := WsClassNew("ECMWorkflowEngineService_keyValueDtoArray")

	// Percorre o array pra montar os objetos
	For nI := 1 To Len(aCardData)
		oObjItem := WsClassNew("ECMWorkflowEngineService_keyValueDto")
	
		oObjItem:ckey := aCardData[nI,1]
		oObjItem:cvalue := aCardData[nI,2]
		
		aAdd(aItens, oObjItem)
	Next
				
	// Adiciona o array de Itens no Objeto
	oObjItArr:oWSitem := aItens
	oFluigWrk:oWSstartProcessClassiccardData := oObjItArr
				
	// Inicia o Processo no Fluig
	If oFluigWrk:startProcessClassic(cFluigUsr, cFluigPss, nCompany, cProcess, 0, oObjLeagId, cComments, cFluigMatr, lComplete, oObjAnexos, oObjItArr, oObjAppoin, lmanagerMode)
		
		oObjRetorno := WsClassNew("ECMWorkflowEngineService_keyValueDtoArray")
		oObjRetorno := oFluigWrk:OWSSTARTPROCESSCLASSICRESULT
		
		oObjRetItem := WsClassNew("ECMWorkflowEngineService_keyValueDto")
		oObjRetItem := oObjRetorno:oWSitem[1]
		if oObjRetItem:cKey == "ERROR"
			conout("Erro Integração com o Fluig ")
			conout("Erro: "+oObjRetItem:cValue)
		Else
			oObjRetItem := oObjRetorno:oWSitem[6]
			cIdProcess := oObjRetItem:cValue
			
            //Gravar o ID Fluig
			//For nI := 1 To Len(aRecnoSUB)
			/*	SUA->(DbGoTo(aRecnoSUA[nI]))
				RecLock("SUA",.F.)
					SUA->UA_FLUIG := cIdProcess
				SUB->(MsUnlock())*/
		//	Next
		
			conout("idProcess "+cIdProcess)
		EndIf
	Else
		MsgAlert("Processo não integrado com o Fluig")
	EndIf

Return



/*
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++-----------------------------------------------------------------------------++
++ Função    | GetLogFlg | Autor  | Anderson Jose Zelenski | Data | 30/01/2022 ++
++-----------------------------------------------------------------------------++
++ Descrição | Consulta o login no Fluig                                       ++
++-----------------------------------------------------------------------------++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

Static function GetLogFlg(cLogin)
	//Local cFluigUsr 	:= AllTrim(GetMv("MV_FLGUSER"))
	//Local cFluigPss		:= AllTrim(GetMv("MV_FLGPASS"))
	Local cFluigUsr 	:= 'totvs'
	Local cFluigPss		:= 'Empi@32@'
	Local nCompany		:= 1
	Local cEmail 		:= AllTrim(UsrRetMail(cLogin))
	Local cLogFluig		:= ''

	conout("cFluigUsr: "+cFluigUsr)
	conout("cFluigPss: "+cFluigPss)

	// Inicia o Objeto do WebService com o Processo a ser iniciado no Fluig  getColleaguesMail
	oFluigUsu := WSECMColleagueService():New()
	
	// Inicia o Processo no Fluig
	If oFluigUsu:getColleaguesMail(cFluigUsr, cFluigPss, nCompany, cEmail)
		
		oObjRetorno := WsClassNew("ECMColleagueService_colleagueDtoArray")
		oObjRetorno := oFluigUsu:oWSgetColleaguesMailresult
		
		oObjRetItem := WsClassNew("ECMColleagueService_colleagueDto")
		oObjRetItem := oObjRetorno:oWSitem[1]
		if !Empty(oObjRetItem:cLogin) 
			oObjRetItem := oObjRetorno:oWSitem[1]
			cLogFluig := oObjRetItem:cColleagueId
		
			conout("cLogFluig "+cLogFluig)
		else
			conout("Erro e-mail ")
			cLogFluig := AllTrim(GetMv("MV_FLGMATR"))
		EndIf
	Else
		conout("Processo não integrado com o Fluig")
	EndIf

Return cLogFluig
