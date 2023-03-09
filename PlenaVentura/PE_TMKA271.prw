
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
Local aRecnoSCR 	:= {}
//if INCLUI

    // verificar o limite para o operador
    // U7_XGRUPO
    // ZZY_DESC/
    // SUA->UA_OPERADO
    aAdd(aCardData,{'emailSolicitante', "marcelo.rosa@plenaventura.com.br"})
    aAdd(aCardData,{'emailAprovador', "marcelo.rosa@plenaventura.com.br"})
    aAdd(aCardData,{'txtAtendimento', SUA->UA_NUM})
    aAdd(aCardData,{'txtCliente', SUA->UA_CLIENTE})
    aAdd(aCardData,{'txtLoja', SUA->UA_LOJA})
    aAdd(aCardData,{'txtEmpresa', '09'})
    aAdd(aCardData,{'txtDataSolicitacao', '13/02/2023'})
    aAdd(aCardData,{'txtContato', SUA->UA_CODCONT})
    aAdd(aCardData,{'txtNomeContato', SUA->UA_DESCNT})
    aAdd(aCardData,{'txtOperador', SUA->UA_OPERADO})
    aAdd(aCardData,{'docNome', 'OC: empre + solicitacao'})
    //aAdd(aCardData,{'txtNomeOperador', SUA->UA_DESCOPE})
    aAdd(aCardData,{'txtNomeOperador', "Tiago Santos"})
    aAdd(aCardData,{'txtCondicao', SUA->UA_CONDPG})
    aAdd(aCardData,{'txtCondicaoDescricao', 'A VISTA'})
    aAdd(aCardData,{'txtTabela', SUA->UA_TABELA})
    aAdd(aCardData,{'txtOperacao', '2'})    
    cUserComp := GetLogFlg(Alltrim('000034'))
    aAdd(aCardData,{'codSolicitante', cUserComp})    // solicitante
    aAdd(aCardData,{'codAprovador',   GetLogFlg(Alltrim('000034'))})    // aprovador
    for nCont :=1 to len(acols)
        //aCols[nCont,nPos]
        if nCont == 1
            cStatus :="V"
        else
            cStatus :="F"
        endif
        // Monta a Tracker com os aprovadores
         
         //nPos := aScan(aHeader,{|x| AllTrim(x[2])=="UB_DESC"}) // posição Deconto
		
        aAdd(aCardData,{'txtItem___'+cvaltochar(nCont), acols[nCont, aScan(aHeader,{|x| AllTrim(x[2])=="UB_ITEM"})]})
		aAdd(aCardData,{'txtProduto___'+cvaltochar(nCont), acols[nCont, aScan(aHeader,{|x| AllTrim(x[2])=="UB_PRODUTO"})]})
		aAdd(aCardData,{'txtQuantidade___'+cvaltochar(nCont), acols[nCont, aScan(aHeader,{|x| AllTrim(x[2])=="UB_QUANT"})]})
		aAdd(aCardData,{'txtPrecoUnit___'+cvaltochar(nCont), acols[nCont, aScan(aHeader,{|x| AllTrim(x[2])=="UB_VRUNIT"})]})
		aAdd(aCardData,{'txtVlrItem___'+cvaltochar(nCont),acols[nCont, aScan(aHeader,{|x| AllTrim(x[2])=="UB_VLRITEM"})]})
		aAdd(aCardData,{'txtDesconto___'+cvaltochar(nCont), acols[nCont, aScan(aHeader,{|x| AllTrim(x[2])=="UB_DESC"})]})
		aAdd(aCardData,{'txtVlrDesc___'+cvaltochar(nCont), acols[nCont, aScan(aHeader,{|x| AllTrim(x[2])=="UB_VALDESC"})]})
		aAdd(aCardData,{'txtItemTotal___'+cvaltochar(nCont), '0'})
		aAdd(aCardData,{'txtStatus___'+cvaltochar(nCont), cStatus})
		
    Next nCont

    //GeraFluig(aCardData, aRecnoSCR, cUserComp )
//endif
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
Static Function GeraFluig(aCardData, aRecnoSCR, cFluigMatr)
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
			/*
            Gravar 
			For nI := 1 To Len(aRecnoSUB)
				SUB->(DbGoTo(aRecnoSUB[nI]))
				RecLock("SUB",.F.)
					SUB->UB_FLUIG := cIdProcess
				SUB->(MsUnlock())
			Next
		*/
			conout("idProcess "+cIdProcess)
		EndIf
	Else
		conout("Processo não integrado com o Fluig")
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
	Local cFluigUsr 	:= AllTrim(GetMv("MV_FLGUSER"))
	Local cFluigPss		:= AllTrim(GetMv("MV_FLGPASS"))
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
