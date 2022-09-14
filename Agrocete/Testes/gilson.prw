/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina	                                    			 !
!Módulo            ! Compras				          	                     !
!Descrição         ! Contas x Aprovadores Específicos						 !
!Cliente	       ! Comfrio											     !
!Nome              ! CFCOMA72	                                             !
!Data de Criacao   ! 26/06/2017												 !
!Autor             ! Gilson Lima		                                     !
+------------------+---------------------------------------------------------+
!   						   MANUTENCAO        						     !
+---------+-----------------+------------------------------------------------+
!Data     ! Consultor		! Descricao                                      !
+---------+-----------------+------------------------------------------------+
!         !          		! 											     !
+---------+-----------------+-----------------------------------------------*/
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
Static cTitulo := "Contas x Aprovadores Específicos"
 
/*/{Protheus.doc} CFCOMA72
Rotina de manutenção de Contas x Aprovadores Específicos
@author Gilson Lima
@since 27/06/2017
@version P11.R8
@type function
/*/
User Function CFCOMA72()
    
	Local aArea   := GetArea()
	Local oBrowse
	Local cFunBkp := FunName()

	SetFunName("CFCOMA72")

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZD4")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("CFCOMA72_MVC")
	oBrowse:DisableDetails()
	
	oBrowse:Activate()

	SetFunName(cFunBkp)
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} MenuDef
Gera menu da rotina
@author Gilson Lima
@since 27/06/2017
@version P11.R8
@type function
/*/
Static Function MenuDef()

	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.CFCOMA72_MVC' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.CFCOMA72_MVC' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.CFCOMA72_MVC' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.CFCOMA72_MVC' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	
Return aRot

/*/{Protheus.doc} ModelDef
Gera modelo de dados da rotina
@author Gilson Lima
@since 27/06/2017
@version P11.R8
@type function
/*/
Static Function ModelDef()

	Local oModel   := Nil
	Local oStTmp   := FWFormModelStruct():New()
	Local oStFilho := FWFormStruct(1, 'ZD4')
	Local bVldPos  := {|| u_VldZD4Tab()}
	Local bVldCom  := {|| u_ZD4Save()}
	Local aZD4Rel  := {}
	Local aTrigger := CreateTrigger('ZD3_GRUPO')

	// Gatilho
	oStTmp:AddTrigger( ;
		aTrigger[1] , ; // [01] Id do campo de origem
		aTrigger[2] , ; // [02] Id do campo de destino
		aTrigger[3] , ; // [03] Bloco de codigo de validação da execução do gatilho
		aTrigger[4] )   // [04] Bloco de codigo de execução do gatilho		

	//Adiciona a tabela temporária
	oStTmp:AddTable('ZD4', {'ZD4_FILIAL', 'ZD4_CONTA', 'ZD4_DCONTA'}, "Cabecalho ZD4")

	//Adiciona o campo de Filial
	oStTmp:AddField(;
		"Filial",;																					// [01]  C   Titulo do campo
		"Filial",;																					// [02]  C   ToolTip do campo
		"ZD4_FILIAL",;																				// [03]  C   Id do Field
		"C",;																						// [04]  C   Tipo do campo
		TamSX3("ZD4_FILIAL")[1],;																	// [05]  N   Tamanho do campo
		0,;																							// [06]  N   Decimal do campo
		Nil,;																						// [07]  B   Code-block de validacao do campo
		Nil,;																						// [08]  B   Code-block de validacao When do campo
		{},;																						// [09]  A   Lista de valores permitido do campo
		.F.,;																						// [10]  L   Indica se o campo tem preenchimento obrigatorio
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,ZD4->ZD4_FILIAL,FWxFilial('ZD4'))" ),;	// [11]  B   Code-block de inicializacao do campo
		.T.,;																						// [12]  L   Indica se trata-se de um campo chave
		.F.,;																						// [13]  L   Indica se o campo pode receber valor em uma operacao de update.
		.F.)																						// [14]  L   Indica se o campo e virtual

	//Adiciona o campo de Codigo da Conta
	oStTmp:AddField(;
		"Conta",;																					// [01]  C   Titulo do campo
		"Conta Contabil",;																			// [02]  C   ToolTip do campo
		"ZD4_CONTA",;																				// [03]  C   Id do Field
		"C",;																						// [04]  C   Tipo do campo
		TamSX3("ZD4_CONTA")[1],;																	// [05]  N   Tamanho do campo
		0,;																							// [06]  N   Decimal do campo
		Nil,;																						// [07]  B   Code-block de validacao do campo
		Nil,;																						// [08]  B   Code-block de validacao When do campo
		{},;																						// [09]  A   Lista de valores permitido do campo
		.T.,;																						// [10]  L   Indica se o campo tem preenchimento obrigatorio
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,ZD4->ZD4_CONTA,'')" ),;					// [11]  B   Code-block de inicializacao do campo
		.T.,;																						// [12]  L   Indica se trata-se de um campo chave
		.T.,;																						// [13]  L   Indica se o campo pode receber valor em uma operacao de update.
		.F.)																						// [14]  L   Indica se o campo e virtual

	//Adiciona o campo de Descricao
	oStTmp:AddField(;
		"Descricao",;																				// [01]  C   Titulo do campo
		"Descricao",;																				// [02]  C   ToolTip do campo
		"ZD4_DCONTA",;																				// [03]  C   Id do Field
		"C",;																						// [04]  C   Tipo do campo
		TamSX3("ZD4_DCONTA")[1],;																	// [05]  N   Tamanho do campo
		0,;																							// [06]  N   Decimal do campo
		Nil,;																						// [07]  B   Code-block de validacao do campo
		Nil,;																						// [08]  B   Code-block de validacao When do campo
		{},;																						// [09]  A   Lista de valores permitido do campo
		.F.,;																						// [10]  L   Indica se o campo tem preenchimento obrigatorio
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,POSICIONE('CT1',1,FWxFilial('CT1')+ZD4->ZD4_CONTA,'CT1_DESC01'),'')" ),;				// [11]  B   Code-block de inicializacao do campo
		.F.,;																						// [12]  L   Indica se trata-se de um campo chave
		.F.,;																						// [13]  L   Indica se o campo pode receber valor em uma operacao de update.
		.T.)																						// [14]  L   Indica se o campo e virtual

	//Setando as propriedades na grid, o inicializador da Filial e Tabela, para nao dar mensagem de coluna vazia
	oStFilho:SetProperty('ZD4_FILIAL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
	oStFilho:SetProperty('ZD4_CONTA' , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
	oStFilho:SetProperty('ZD4_DCONTA', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
	oStFilho:SetProperty('ZD4_NAPROV', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'UsrFullName(ZD4->ZD4_APROV)'))

	//Criando o FormModel, adicionando o Cabecalho e Grid
	oModel := MPFormModel():New("ZD4Model", , bVldPos, bVldCom)
	oModel:AddFields("FORMCAB",/*cOwner*/,oStTmp)
	oModel:AddGrid('ZD4DETAIL','FORMCAB',oStFilho)

	//Adiciona o relacionamento de Filho, Pai
	aAdd(aZD4Rel, {'ZD4_FILIAL', 'IIF(!INCLUI, ZD4->ZD4_FILIAL, FWxFilial("ZD4"))'} )
	aAdd(aZD4Rel, {'ZD4_CONTA' , 'IIF(!INCLUI, ZD4->ZD4_CONTA,  "")'} )

	//Criando o relacionamento
	oModel:SetRelation('ZD4DETAIL', aZD4Rel, ZD4->(IndexKey(1)))

	//Setando o campo unico da grid para nao ter repeticao
	//oModel:GetModel('ZD4DETAIL'):SetUniqueLine({"ZD4->ZD4_APROV"})

	//Setando outras informacoes do Modelo de Dados
	oModel:SetDescription("Modelo de Dados do Cadastro " + cTitulo)
	oModel:SetPrimaryKey({})
	oModel:GetModel("FORMCAB"):SetDescription("Formulario do Cadastro " + cTitulo)

Return oModel

/*/{Protheus.doc} ViewDef
Gera View da Rotina
@author Gilson Lima
@since 27/06/2017
@version P11.R8
@type function
/*/
Static Function ViewDef()
    
	Local oModel     := FWLoadModel("CFCOMA72_MVC")
	Local oStTmp     := FWFormViewStruct():New()
	Local oStFilho   := FWFormStruct(2, 'ZD4')
	Local oView      := Nil

	//Adicionando o campo Chave para ser exibido
	oStTmp:AddField(;
		"ZD4_CONTA",;				// [01]  C   Nome do Campo
		"01",;						// [02]  C   Ordem
		"Conta",;					// [03]  C   Titulo do campo
		X3Descric('ZD4_CONTA'),;	// [04]  C   Descricao do campo
		Nil,;						// [05]  A   Array com Help
		"C",;						// [06]  C   Tipo do campo
		X3Picture("ZD4_CONTA"),;	// [07]  C   Picture
		Nil,;						// [08]  B   Bloco de PictTre Var
		'CT1',;						// [09]  C   Consulta F3
		IIF(INCLUI, .T., .F.),;		// [10]  L   Indica se o campo e alteravel
		Nil,;						// [11]  C   Pasta do campo
		Nil,;						// [12]  C   Agrupamento do campo
		Nil,;						// [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;						// [14]  N   Tamanho maximo da maior opcao do combo
		Nil,;						// [15]  C   Inicializador de Browse
		Nil,;						// [16]  L   Indica se o campo e virtual
		Nil,;						// [17]  C   Picture Variavel
		Nil)						// [18]  L   Indica pulo de linha apos o campo

	oStTmp:AddField(;
		"ZD4_DCONTA",;				// [01]  C   Nome do Campo
		"02",;						// [02]  C   Ordem
		"Descricao",;				// [03]  C   Titulo do campo
		X3Descric('ZD4_DCONTA'),;	// [04]  C   Descricao do campo
		Nil,;						// [05]  A   Array com Help
		"C",;						// [06]  C   Tipo do campo
		X3Picture("ZD4_DCONTA"),;	// [07]  C   Picture
		Nil,;						// [08]  B   Bloco de PictTre Var
		Nil,;						// [09]  C   Consulta F3
		.F.,;						// [10]  L   Indica se o campo e alteravel
		Nil,;						// [11]  C   Pasta do campo
		Nil,;						// [12]  C   Agrupamento do campo
		Nil,;						// [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;						// [14]  N   Tamanho maximo da maior opcao do combo
		Nil,;						// [15]  C   Inicializador de Browse
		Nil,;						// [16]  L   Indica se o campo e virtual
		Nil,;						// [17]  C   Picture Variavel
		Nil)						// [18]  L   Indica pulo de linha apos o campo
     
	//Criando a view que sera o retorno da funcao e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB", oStTmp, "FORMCAB")
	oView:AddGrid('VIEW_ZD4',oStFilho,'ZD4DETAIL')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',15)
	oView:CreateHorizontalBox('GRID',85)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_ZD4','GRID')

	//Habilitando titulo
	oView:EnableTitleView('VIEW_CAB','Cabecalho - ' + cTitulo)
	oView:EnableTitleView('VIEW_ZD4','Itens - ' + cTitulo)

	//Tratativa padrao para fechar a tela
	oView:SetCloseOnOk({||.T.})

	//Remove os campos de Filial e Tabela da Grid
	oStFilho:RemoveField('ZD4_FILIAL')
	oStFilho:RemoveField('ZD4_CONTA')
	oStFilho:RemoveField('ZD4_DCONTA')
    
Return oView

/*/{Protheus.doc} VldZD4Tab
Valida ao confirmar inclusao/alteracao
@author Gilson Lima
@since 27/06/2017
@version P11.R8
@type function
/*/
User Function VldZD4Tab()
    
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local oModelDad	:= FWModelActive()
	Local cFilZD4	:= oModelDad:GetValue('FORMCAB', 'ZD4_FILIAL')
	Local cConta	:= oModelDad:GetValue('FORMCAB', 'ZD4_CONTA')
	Local nOpc		:= oModelDad:GetOperation()

	//Se for Inclusao
	If nOpc == MODEL_OPERATION_INSERT
		
		DbSelectArea('ZD4')
		ZD4->(DbSetOrder(2)) // 2 - ZD4_FILIAL + ZD4_CONTA + ZD4_APROV

		//Se conseguir posicionar, tabela ja existe
		If ZD4->(DbSeek(cFilZD4 + cConta))
			Aviso('Atenção', 'Esse código de conta já está cadastrado!', {'OK'}, 02)
			lRet := .F.
		EndIf
	EndIf
     
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} ZD4Save
Rotina de gravacao
@author Gilson Lima
@since 27/06/2017
@version P11.R8
@type function
/*/
User Function ZD4Save()
    
	Local aArea			:= GetArea()
	Local lRet			:= .T.
	
	Local oModelDad		:= FWModelActive()
	Local cFilZD4		:= oModelDad:GetValue('FORMCAB', 'ZD4_FILIAL')
	Local cConta		:= oModelDad:GetValue('FORMCAB', 'ZD4_CONTA')
	Local nOpc			:= oModelDad:GetOperation()
	Local oModelGrid	:= oModelDad:GetModel('ZD4DETAIL')
	
	Local aHeadAux		:= oModelGrid:aHeader
	Local aColsAux		:= oModelGrid:aCols

	Local nPosAprov		:= aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZD4_APROV")})
	Local nPosNivel		:= aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZD4_NIVEL")})
	Local nPosLimDe		:= aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZD4_LIMDE")})
	Local nPosLimAte	:= aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZD4_LIMATE")})

	Local n1
     
	DbSelectArea('ZD4')
	ZD4->(DbSetOrder(2)) // 2 - ZD4_FILIAL + ZD4_CONTA + ZD4_APROV

	//Se for Inclusao
	If nOpc == MODEL_OPERATION_INSERT

        //Percorre as linhas da grid
		For n1 := 1 To Len(aColsAux)

			//Se a linha nao estiver excluida, inclui o registro
			If !aColsAux[n1][Len(aHeadAux)+1]
				
				RecLock('ZD4', .T.)

				ZD4->ZD4_FILIAL	:= cFilZD4
				ZD4->ZD4_CONTA	:= cConta
				ZD4->ZD4_APROV	:= aColsAux[n1][nPosAprov]
				ZD4->ZD4_NIVEL	:= aColsAux[n1][nPosNivel]
				ZD4->ZD4_LIMDE	:= aColsAux[n1][nPosLimDe]
				ZD4->ZD4_LIMATE	:= aColsAux[n1][nPosLimAte]

				ZD4->(MsUnlock())
			EndIf
			
		Next n1
         
    //Se for Alteracao
    ElseIf nOpc == MODEL_OPERATION_UPDATE
    
    	// Limpa ZD4
    	ZD4->(dbGoTop())
    	If ZD4->(DbSeek(cFilZD4 + cConta))
    		While ZD4->(!Eof()) .And. ZD4->(ZD4_FILIAL + ZD4_CONTA) == cFilZD4 + cConta
    		
    			RecLock('ZD4',.F.)
    			
    				ZD4->(DbDelete())
    			
    			ZD4->(MsUnLock())
    		
    			ZD4->(dbSkip())
    		EndDo
    	EndIf
         
        // Percorre o acols
        For n1 := 1 To Len(aColsAux)

            //Se a linha estiver excluída
            If !aColsAux[n1][Len(aHeadAux)+1]

                RecLock('ZD4', .T.)
                
	                ZD4->ZD4_FILIAL	:= cFilZD4
	                ZD4->ZD4_CONTA 	:= cConta                 
	                ZD4->ZD4_APROV	:= aColsAux[n1][nPosAprov]
					ZD4->ZD4_NIVEL	:= aColsAux[n1][nPosNivel]
					ZD4->ZD4_LIMDE	:= aColsAux[n1][nPosLimDe]
					ZD4->ZD4_LIMATE	:= aColsAux[n1][nPosLimAte]
                
                ZD4->(MsUnlock())
            EndIf
        Next

	//Se for Exclusao
	ElseIf nOpc == MODEL_OPERATION_DELETE

		//Percorre a grid
		For n1 := 1 To Len(aColsAux)
			//Se conseguir posicionar, exclui o registro
			If ZD4->(DbSeek(cFilZD4 + cConta + aColsAux[n1][nPosAprov]))
				RecLock('ZD4', .F.)
				ZD4->(DbDelete())
				ZD4->(MsUnlock())
			EndIf
		Next
    EndIf

	//Se nao for inclusao, volta o INCLUI para .T. (bug ao utilizar a Exclusao, antes da Inclusao)
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} CreateTrigger
Cria array com dados para a Trigger - Gatilho
@author Gilson Lima
@since 27/06/2017
@version P11.R8
@return aAux, Array com dados para inclusão da trigger
@type function
/*/
Static Function CreateTrigger()
	
	Local aAux := FwStruTrigger(;
		"ZD4_CONTA" ,; 					// Campo Dominio
		"ZD4_DCONTA" ,; 				// Campo de Contradominio
		"POSICIONE('CT1',1,FWxFilial('CT1')+ZD4_CONTA,'CT1_DESC01')",; 		// Regra de Preenchimento
		.F. ,; 							// Se posicionara ou nao antes da execucao do gatilhos
		"" ,; 							// Alias da tabela a ser posicionada
		0 ,; 							// Ordem da tabela a ser posicionada
		"" ,; 							// Chave de busca da tabela a ser posicionada
		NIL ,; 							// Condicao para execucao do gatilho
		"01" ) 							// Sequencia do gatilho (usado para identificacao no caso de erro)   

Return aAux
