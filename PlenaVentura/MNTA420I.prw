#include 'protheus.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA420I
Ponto de entrada para adicionar botão na rotina MNTA420

@author	Hamilton Soldati
@since	26/04/19

@sample MNTA420I()

@return aRot      , Array  , Array com a opção a ser adicionado ao menudef
/*/
//---------------------------------------------------------------------------------------------------
User Function MNTA420I()

	Local aRot := aClone(ParamIXB[1])
	Aadd(aRot,{"Alterar Serviço", "U_fAltSer" , 0 , 4 , 0 ,.F.})  // Função para alterar o código do serviço
	Aadd(aRot,{"Alterar Centro de Custo", "U_BRA002" , 0 , 4 , 0 ,.F.})  // Função para alterar o código do centro de custo
   aAdd( aRot, { "TESTE NG", "U_TesteMNT", 0, 4 } )
Return aRot

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fAltSer
Função para permitir alterar o código do serviço em O.S. corretiva

@author	Hamilton Soldati
@since	26/04/19

@sample fAltSer()

@return null
/*/
//---------------------------------------------------------------------------------------------------
User Function fAltSer()

	Local oDlg 		:= Nil
	Local oPanel	:= Nil
	Local cCodSer	:= Space(6)
	
	If Empty(STJ->TJ_TIPORET) 
	
		oDlg := FWDialogModal():New()
		oDlg:SetBackground(.T.)	 	// .T. -> escurece o fundo da janela
		oDlg:SetTitle("Alteração de Serviço") // "Alteração de Serviço"
		oDlg:SetEscClose(.F.)		//permite fechar a tela com o ESC	
		oDlg:SetSize(100,200)
		oDlg:EnableFormBar(.T.)
		oDlg:CreateDialog() //cria a janela (cria os paineis)
		oPanel := oDlg:getPanelMain()
	
		oDlg:createFormBar()//cria barra de botoes
		
		@ 10,008 Say OemToAnsi("Serv. Atual") Size 47,07 Of oPanel Pixel // Label - "Serv. Atual"
		@ 10,050 Say OemToAnsi(STJ->TJ_SERVICO) Size 47,07 Of oPanel Pixel  // Código do serviço atual
		
		@ 10,090 Say OemToAnsi(Posicione("ST4",1,xFilial("ST4") + STJ->TJ_SERVICO,"T4_NOME")) Size 90,08 Of oPanel Pixel  // Nome Serviço Atual
		
		@ 30,008 Say OemToAnsi("Serv. Novo") Size 47,07 Of oPanel Pixel  // Label - "Serv. Novo"
		@ 30,050 MsGet cCodSer Size 38,08 Of oPanel Pixel Picture '@!' F3 "ST3" Valid fChkSer(cCodSer) HASBUTTON // Código do Novo Serviço 
		
		@ 30,090 MsGet oNomSer Var  Posicione("ST4",1,xFilial("ST4") + cCodSer,"T4_NOME") Of oPanel Pixel Picture '@!' When .F.  Size 90,08 // Nome do Novo Serviço 
	
	    oDlg:AddButton( 'Confirmar'	,{|| fVldTudo(cCodSer) .and. oDlg:Deactivate()}, 'Confirmar' , , .T., .F., .T., ) // Botão para Confirmar
	    oDlg:AddButton( 'Cancelar'	,{|| oDlg:Deactivate()}, 'Cancelar' ,, .T., .F., .T., ) // Botão para Cancelar
		
		oDlg:activate()	
	Else
		MsgStop("A O.S. selecionada já possui insumos consumidos (reportados).")	
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fChkSer
Função para validar o código do serviço
Permitir apenas corretivos e que não seja relacioando a conserto ou reforma de pneus.
Não permitir tambem serviço bloqueado.

@author	Hamilton Soldati
@since	26/04/19
@param  cCodSer, Caractere, Código do serviço atual

@sample fChkSer()

@return lRet, Lógico, Caso .T. permite a alteração do código do serviço, caso .F. não permitir a alteração.
/*/
//---------------------------------------------------------------------------------------------------
Static Function fChkSer (cCodSer)

	Local lRet 		:= .T.
	Local cSerefor  := Alltrim(GETMV("MV_NGSEREF"))
	Local cSercons  := Alltrim(GETMV("MV_NGSECON"))
		
	If !Empty(cCodSer)
		If Alltrim(cCodSer) == Alltrim(cSerefor) .or. Alltrim(cCodSer) == Alltrim(cSercons)
			MsgStop("Serviço destinado apenas para reforma ou conserto de pneus.")
			lRet	:= .F.	
		ElseIf !ST4->(DbSeek(xFilial('ST4') + cCodSer))
			Help(" ",1,"SERVICONAOEXIST")
			lRet	:= .F.
		ElseIf NGFUNCRPO("NGSERVBLOQ",.F.)  .And.  !NGSERVBLOQ(cCodSer)
			lRet	:= .F.
		ElseIf !STE->(DbSeek(xFilial('STE') + ST4->T4_TIPOMAN))
			Help(" ",1,"TIPONAOEXIST")
			lRet	:= .F.
		ElseIf STE->TE_CARACTE != "C"
			Help(" ",1,"SERVNAOCORRET")
			lRet	:= .F.
		EndIf	
	EndIf
			
Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fAtuSer
Função para permitir alterar o código do serviço em O.S. corretiva

@author	Hamilton Soldati
@since	26/04/19
@param  cCodSer, Caractere, Código do serviço atual

@sample fAtuSer()

@return .T., Lógico, Caso .T. permite a alteração do código do serviço, caso .F. não permitir a alteração.
/*/
//---------------------------------------------------------------------------------------------------
Static Function fAtuSer (cCodSer)

	RecLock("STJ",.F.)
	STJ->TJ_SERVICO := cCodSer
	MsUnlock("STJ")
	MsgInfo("Código da ordem de serviço atualizado.")

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fVldTudo
Função para permitir validar todos os dados informados antes de gravar

@author	Hamilton Soldati
@since	26/04/19
@param  cCodSer, Caractere, Código do serviço atual

@sample fVldTudo()

@return .T., Lógico, Caso .T. permite a alteração do código do serviço, caso .F. não permitir a alteração.
/*/
//---------------------------------------------------------------------------------------------------
Static Function fVldTudo( cCodSer )

	Local lRet := .T.
	
	// Validação do serviço
	If Empty(cCodSer)
		MsgInfo("O novo serviço não foi informado")
		lRet	:= .F.
	ElseIf !Empty(cCodSer) .and. (lRet := fChkSer (cCodSer))
		fAtuSer (cCodSer)
	EndIf

Return lRet


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BRA002
Tela para alterar centro de custo da ordem de serviço corretiva

@author	Maria Elisandra de Paula
@since 08/10/2019

@return nil
/*/
//---------------------------------------------------------------------------------------------------
User Function BRA002()

	Local oDlg    
	Local oPanel
	Local cNomeCC := NGSEEK("CTT", STJ->TJ_CCUSTO, 1, "CTT_DESC01" )

	M->TJ_CCUSTO  := Space( TamSx3( 'TJ_CCUSTO' )[1] )
	M->TJ_NOMCUST := Space( TamSx3( 'TJ_NOMCUST' )[1] )

	oDlg := FWDialogModal():New()
	oDlg:SetBackground(.T.)	 	// .T. -> escurece o fundo da janela
	oDlg:SetTitle("Alteração de Centro de Custo")
	oDlg:SetEscClose(.F.)		//permite fechar a tela com o ESC	
	oDlg:SetSize(100,200)
	oDlg:EnableFormBar(.T.)
	oDlg:CreateDialog() //cria a janela (cria os paineis)
	oPanel := oDlg:getPanelMain()

	oDlg:createFormBar()//cria barra de botoes

	@ 10,08 Say "CC. Atual" Size 47,07 Of oPanel Pixel
	@ 10,35 MsGet STJ->TJ_CCUSTO Picture "@!" size 60,07 When .F. Of oPanel Pixel
	@ 10,100 MsGet cNomeCC Picture "@!" size 90,07 When .F. Of oPanel Pixel

	@ 30,08 Say "C.C Novo" Size 40,07 Of oPanel Pixel
	@ 30,35 MsGet M->TJ_CCUSTO Valid Vazio() .Or. fVldCC( M->TJ_CCUSTO ) Size 60,07 Of oPanel Pixel Picture '@!' F3 "CTT" HASBUTTON
	@ 30,100 MsGet M->TJ_NOMCUST Picture "@!" size 90,07 When .F. Of oPanel Pixel

	oDlg:AddButton( 'Salvar', {|| fGravaCC( M->TJ_CCUSTO ) .And. oDlg:Deactivate()}, 'Salvar' ,, .T., .F., .T., )
	oDlg:AddButton( 'Cancelar', {|| oDlg:Deactivate()}, 'Cancelar' ,, .T., .F., .T., )
	
	oDlg:Activate()	

Return

//-------------------------------------
/*/{Protheus.doc} fVldCC
Valida centro de custo
@author	Maria Elisandra de Paula
@since 15/10/2019
@return boolean
/*/
//-------------------------------------
Static Function fVldCC( cCCusto )

	Local lRet := .F.

	If ExistCpo( "CTT", cCCusto )
		lRet := .T.
		M->TJ_NOMCUST := NGSEEK("CTT", cCCusto, 1, "CTT_DESC01" )
	Else
		M->TJ_NOMCUST := Space( TamSx3( 'TJ_NOMCUST' )[1] )
	EndIf

Return lRet

//-------------------------------------
/*/{Protheus.doc} fGravaCC
Grava centro de custo
@author	Maria Elisandra de Paula
@since 15/10/2019
@return boolean
/*/
//-------------------------------------
Static Function fGravaCC( cCCusto )

	Local lRet := .F.

	If fVldCC( cCCusto )
		
		lRet := .T.

		RecLock( "STJ", .F. )
		STJ->TJ_CCUSTO := cCCusto
		MsUnLock()

	EndIf

Return lRet

