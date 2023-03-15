#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+------------------+---------------------------------------------------------+
!Tipo              ! WebService                                              !
!Módulo            ! Protheus x Fluig                                        !
!Cliente	       ! Plenaventura                                            !
!Data de Criacao   ! 27/01/2022                                              !
!Autor             ! Anderson José Zelenski - SMSTI                          !
+------------------+---------------------------------------------------------+
!                           MANUTENCAO                                       !
+---------+-----------------+------------------------------------------------+
!Data     ! Consultor		! Descricao                                      !
+---------+-----------------+------------------------------------------------+
!         !          		! 											     !
+---------+-----------------+-----------------------------------------------*/

// WebService FluigProtheus
WSSERVICE FluigProtheus DESCRIPTION 'Fluig x Protheus - Workflow'
	WSDATA oAprovacao		AS oAprovacao
	
	WSDATA Empresa			AS String
	WSDATA Filial			AS String
	WSDATA Status			AS String
	WSDATA SCRRecno			AS String
	
	WSMETHOD AprovWFPC		DESCRIPTION 'Aprovar Workflow de Pedido de Compras/Contratos'
	WSMETHOD LiberarPC		DESCRIPTION 'Liberar Pedido de Compras'
	WSMETHOD LiberarCT		DESCRIPTION 'Liberar Contratos'
	WSMETHOD LiberarOR		DESCRIPTION 'Liberar Orçamentos'
ENDWSSERVICE

// Estrutura de Aprovação
WSSTRUCT oAprovacao
	WSDATA Pedido			AS String
	WSDATA Nivel			AS String
	WSDATA Acao				AS String 
	WSDATA Grupo			AS String optional
	WSDATA ItemGrupo		AS String optional
	WSDATA Login			AS String optional
	WSDATA SCRRecno			AS String
	WSDATA Comentario		AS String optional 
ENDWSSTRUCT

/*/{Protheus.doc} AprovWFPC
Aprova o item da alçada do Pedido de Compras
@author Anderson José Zelenski
@since 27/01/2022
/*/

WSMETHOD AprovWFPC WSRECEIVE Empresa, Filial, oAprovacao WSSEND Status WSSERVICE FluigProtheus
	Local lError 	:= .T.
	Local nAcao 	:= 4
	Local cAprovador:= ""
	Local cUsuario	:= ""
	Local cModulo := 'COM'
	Local cTabs := 'SC7,SCR'

	// Reset a Ambiente
	Reset Environment
	
	// Abre o ambiente
	If Select("SX2") <= 0
		RpcSetType(3)
		Prepare Environment EMPRESA ::Empresa FILIAL ::Filial MODULO cModulo Tables cTabs
	EndIf
    
	conout("Aprovar Pedido")
	
	BEGIN TRANSACTION
		
		SCR->(DbGoTo(Val(oAprovacao['SCRRecno'])))
		cFilAnt 	:= SCR->CR_FILIAL
		cTipo		:= SCR->CR_TIPO
		cPedido 	:= SCR->CR_NUM
		cAprovador	:= SCR->CR_APROV
		cUsuario	:= SCR->CR_USER
		cNivel		:= SCR->CR_NIVEL
		
		conout("Ação: "+oAprovacao['Acao'])
		conout("Tipo: "+SCR->CR_TIPO)
		
		If oAprovacao['Acao'] == "A"
			MaAlcDoc({SCR->CR_NUM, SCR->CR_TIPO, SCR->CR_TOTAL, cAprovador, cUsuario, SCR->CR_GRUPO,,,,,oAprovacao['Comentario']},dDataBase,nAcao,,,SCR->CR_ITGRP)
		ElseIf oAprovacao['Acao'] == "R"
			nAcao 	:= 6
		
			MaAlcDoc({SCR->CR_NUM, SCR->CR_TIPO, SCR->CR_TOTAL, cAprovador, cUsuario, SCR->CR_GRUPO,,,,,oAprovacao['Comentario']},dDataBase,nAcao,,,SCR->CR_ITGRP)

			// Caso haja uma reprovação do Contrato
			If SCR->CR_TIPO == "CT"
				// Posiciona no Contrato
				CN9->(DbSetOrder(1))
				CN9->(DbSeek(xFilial("CN9")+AllTrim(SCR->CR_NUM)))
				
				// Percorre os Itens do Contrato
				While !CN9->(EoF()) .And. CN9->CN9_FILIAL+AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA) == xFilial("CN9")+AllTrim(SCR->CR_NUM)
					
					// Marca os itens do contrato como rejeitado
					RecLock("CN9", .F.)
						CN9->CN9_SITUAC := "11"
					CN9->(MsUnlock())
				
					CN9->(DbSkip())
				EndDo 
			EndIf
		EndIf
		
		conout("Login Aprovador: "+oAprovacao['Login'])
		
		// Valida se foi aprovado por um usuario alternativo
		SAK->(DbSetOrder(4)) //AK_FILIAL+AK_Login
		If SAK->(DbSeek(xFilial("SAK")+oAprovacao['Login']))
			If cUsuario != SAK->AK_USER
				SCR->(DbSetOrder(1)) //CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
				SCR->(DbGoTop())
				SCR->(DbSeek(cFilAnt+cTipo+cPedido+cNivel))
				
				While !SCR->(EoF()) .And. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM+SCR->CR_NIVEL == cFilAnt+cTipo+cPedido+cNivel
					RecLock("SCR", .F.)
						SCR->CR_LIBAPRO := SAK->AK_COD
						SCR->CR_USERLIB := SAK->AK_USER
					SCR->(MsUnlock())
					
					SCR->(DbSkip())
				EndDo 
				
			EndIf
		EndIf
		
		lError := .F.
		
		::Status := "OK"
		
	END TRANSACTION

	If lError
		cMens := "Erro ao aprovaro alçada SCR"
		conout('[' + DToC(Date()) + " " + Time() + "] Aprovar SCR > " + cMens)
		SetSoapFault("Erro", cMens)		 			
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} LiberarPC
Libera Pedido de Compras
@author Anderson José Zelenski
@since 27/01/2022
/*/

WSMETHOD LiberarPC WSRECEIVE Empresa, Filial, SCRRecno WSSEND Status WSSERVICE FluigProtheus
	Local lError 	:= .T.
	Local cModulo := 'COM'
	Local cTabs := 'SC7,SCR'

	// Reset a Ambiente
	Reset Environment
	
	// Abre o ambiente
	If Select("SX2") <= 0
		RpcSetType(3)
		Prepare Environment EMPRESA ::Empresa FILIAL ::Filial MODULO cModulo Tables cTabs
	EndIf

	conout("Liberar Pedido")
	
	BEGIN TRANSACTION
		
		// Posiciona na Alçada
		SCR->(DbGoTo(Val(::SCRRecno)))
		cFilAnt := SCR->CR_FILIAL

		// Posiciona no Pedido de Compras
		SC7->(DbSetOrder(1))
		SC7->(DbSeek(xFilial("SC7")+AllTrim(SCR->CR_NUM)))
		
		// Percorre os Itens do Pedido de Compras
		While !SC7->(EoF()) .And. SC7->C7_FILIAL+AllTrim(SC7->C7_NUM) == xFilial("SC7")+AllTrim(SCR->CR_NUM)
			
			// Libera o Item de acordo com o Centro de Custo da alçada aprovada
			RecLock("SC7", .F.)
				SC7->C7_CONAPRO := "L"
			SC7->(MsUnlock())
		
			SC7->(DbSkip())
		EndDo 
		
		lError := .F.
		
		::Status := "OK"
		
	END TRANSACTION

	If lError
		cMens := "Erro ao liberar pedido de compras"
		conout('[' + DToC(Date()) + " " + Time() + "] Liberar PC > " + cMens)
		SetSoapFault("Erro", cMens)		 			
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} LiberarCT
Libera Contrato
@author Anderson José Zelenski
@since 15/07/2022
/*/

WSMETHOD LiberarCT WSRECEIVE Empresa, Filial, SCRRecno WSSEND Status WSSERVICE FluigProtheus
	Local lError 	:= .T.
	Local cModulo := 'COM'
	Local cTabs := 'CN9,SCR'

	// Reset a Ambiente
	Reset Environment
	
	// Abre o ambiente
	If Select("SX2") <= 0
		RpcSetType(3)
		Prepare Environment EMPRESA ::Empresa FILIAL ::Filial MODULO cModulo Tables cTabs
	EndIf

	conout("Liberar Contrato")
	
	BEGIN TRANSACTION
		
		// Posiciona na Alçada
		SCR->(DbGoTo(Val(::SCRRecno)))
		cFilAnt := SCR->CR_FILIAL

		// Posiciona no Contrato
		CN9->(DbSetOrder(1))
		CN9->(DbSeek(xFilial("CN9")+AllTrim(SCR->CR_NUM)))
		
		conout("Contrato: "+CN9->CN9_FILIAL+AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA)+" == "+xFilial("CN9")+AllTrim(SCR->CR_NUM))

		// Percorre os Itens do Contrato
		While !CN9->(EoF()) .And. CN9->CN9_FILIAL+AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA) == xFilial("CN9")+AllTrim(SCR->CR_NUM)
			
			// Altera a situação do Contrato para Vigente
			RecLock("CN9", .F.)
				CN9->CN9_SITUAC := "05"
			CN9->(MsUnlock())
		
			CN9->(DbSkip())
		EndDo 
		
		lError := .F.
		
		::Status := "OK"
		
	END TRANSACTION

	If lError
		cMens := "Erro ao liberar contrato"
		conout('[' + DToC(Date()) + " " + Time() + "] Liberar CT > " + cMens)
		SetSoapFault("Erro", cMens)		 			
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} LiberarOR
Libera Contrato
@author Tiago Santos
@since 15/03/2023
/*/

WSMETHOD LiberarOR WSRECEIVE Empresa, Filial, SUARecno WSSEND Status WSSERVICE FluigProtheus
	Local lError 	:= .T.
	Local cModulo := 'TMK'
	Local cTabs := 'SUA'

	// Reset a Ambiente
	Reset Environment
	
	// Abre o ambiente
	If Select("SX2") <= 0
		RpcSetType(3)
		Prepare Environment EMPRESA ::Empresa FILIAL ::Filial MODULO cModulo Tables cTabs
	EndIf

	conout("Liberar Orcamentos")
	
	BEGIN TRANSACTION
		
		// Posiciona no Orçamento
		SUA->(DbGoTo(Val(::SUARecno)))
		
		conout("Orçamento: "+SUA->UA_FILIAL + ' - ' + SUA->UA_NUM)
			
		// Altera a situação do Orçamento
		if	RecLock("SUA", .F.)
				SUA->UA_XBLOQOR := "N" // ou ' '
			SUA->(MsUnlock())
		Endif		
		lError := .F.		
		::Status := "OK"
		
	END TRANSACTION

	If lError
		cMens := "Erro ao liberar Orçamento"
		conout('[' + DToC(Date()) + " " + Time() + "] Liberar OR > " + cMens)
		SetSoapFault("Erro", cMens)		 			
		Return .F.
	EndIf

Return .T.
