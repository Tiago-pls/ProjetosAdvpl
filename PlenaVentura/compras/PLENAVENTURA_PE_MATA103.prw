#include 'protheus.ch'
#include 'fileio.ch'

/*/{Protheus.doc} MA103BUT
O Ponto de Entrada MA103BUT, chamado a partir do código-fonte MATA103.PRW, permite ao usuário adicionar opções na barra de menus EnchoiceBar.


@author Rafael Ricardo Vieceli
@since 03/07/2015
@version 1.0
@return aBotoes, array, Lista com os botoes
@see http://tdn.totvs.com/pages/releaseview.action?pageId=102269141
@history 12/09/2019, Rafael Ricardo Vieceli, Nova opção nos botões na enchoice para Nota em PDF

27/09/2023 - Tiago Santos
/*/
User Function MA103BUT()

	Local aBotoes := {}
  	Local lEdit
    Local nAba
    Local oCampo
    Public __cCamNovo := ""
	//Criado para apresentar ou nao a tela customizada da condicao de pagamento.
	IF cEmpAnt $ GetMv( "MV_xCCOND" , .F.)

		//exceto para inclusao
		IF !INCLUI
			//adiciona opção para visualização da mensagem da nota
			IF SF1->( FieldPos("F1_OBSADL") ) != 0
				aAdd(aBotoes,{"BUDGET",  {|| M103Infos() },"Observações na Nota","Observações na Nota" })
			EndIF
		EndIF

		If l103Class

			if (SF1->F1_COND != cCondicao)
				cCondicao := SF1->F1_COND
				Eval(bRefresh,6)
			endif

		EndIf

	EndIf

	IF ! INCLUI
		aAdd(aBotoes, {"",{|| u_PDFA050Attach() },"Nota fiscal em PDF","Nota fiscal em PDF"})
	EndIF
Return aBotoes


/*/{Protheus.doc} MTA103MNU
Ponto de entrada utilizado para inserir novas opções no array aRotina

@author Rafael Ricardo Vieceli
@since 12/09/2019
@version 1.0
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6085783
/*/
user function MTA103MNU()

	aAdd(aRotina, { "Nota fiscal em PDF"	,"u_PDFA050Attach", 0 , 2, 0, nil})

return


//------------------------------------------------------------
// P.E que atualiza o grid das duplicatas
//------------------------------------------------------------
User Function a103CND2()

	Local a103CND2   := ParamIXB // Array com as informacoes padroes da aba duplicatas
	Local nCont      := 1
	Local nTotalZK1  := 0
	Local nTotalGrid := 0
	Local nRatear	   := 0
	Local lRPadrao   := .F.
	Local aArea 	   := getarea()

	//Condicao de pagamento é a mesma da Nota Fiscal
	IF cCondicao == SF1->F1_COND

		ZK1->( dbSetOrder(1) )
		ZK1->(dbgotop())
		ZK1->( dbSeek( xFilial("ZK1") + SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO) ) )

		//------------------------------------------
		//loop pra pegar valor total vindo da ZK1
		//------------------------------------------
		While !ZK1->( Eof() ) .And. ZK1->(ZK1_FILIAL+ZK1_CHAVE) == xFilial("ZK1") + SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)

			IF len(a103CND2) >= nCont
				nTotalZK1  += ZK1->ZK1_VALOR
				nTotalGrid += a103CND2[nCont][2]
				nCont ++
			EndIF
			ZK1->( dbSkip() )
		EndDO

		//verifica se tem produtos com imposto e divide o valor por parcela.
		if nTotalGrid > nTotalZK1
			//valor total dos impostos
			nRatear := (nTotalGrid - nTotalZK1) / len(a103CND2)
		EndIf

		nCont := 1
		ZK1->(dbgotop())
		ZK1->( dbSeek( xFilial("ZK1") + SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO) ) )

		//------------------------------------------
		//loop para atualizar o grid das duplicatas
		//------------------------------------------
		//loop na tabela ZK1 com as informacoes gravadas na Pre Nota
		While !ZK1->( Eof() ) .And. ZK1->(ZK1_FILIAL+ZK1_CHAVE) == xFilial("ZK1") + SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)

			//Se Array das duplicatas for maior que a variavel entra no if
			If len(a103CND2) >= nCont
				//atualizado data de vencimento
				a103CND2[nCont][1] := ZK1->ZK1_VENC

				//verifico se o valor total na NF é igual ao que foi gravado na Pre Nota.
				If nTotalZK1 == nTotalGrid
					a103CND2[nCont][2] := ZK1->ZK1_VALOR
				Else
					//acrescento valor do imposto
					a103CND2[nCont][2] := ZK1->ZK1_VALOR + nRatear

				EndIF
			EndIF
			nCont ++
			ZK1->( dbSkip() )
		EndDO

	EndIF

	//oGetDad:OBrowse:Refresh()
	//oGrid:aCols := aCols
	//oGrid:Refresh()

	Restarea(aArea)

Return a103CND2

/**********************************************************************************************************************************/
/** Ponto de Entrada MT100GE2                                                                 			 							   **/
/** O ponto de entrada MT100GE2(Complementa a Gravação dos Títulos Financeiros a Pagar) tem por objetivo levar os rateios do     **/
/** modulo compras para o financeiro utilizando o conceito de multiplas naturezas (gravando nas tabelas SEV e SEZ).			       **/
/** Chamado no final do documento de Entrada.																								   **/
/**																																				   **/
/** Data: 16/10/2015                                                                                              					**/
/** Totvs                                                                                                 		 					**/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                        		 			**/
/**********************************************************************************************************************************/
/* 03/07/2015  | Rafael Ricardo Vieceli         | Complementar a gravação na tabela dos títulos financeiros a pagar.              */
/**********************************************************************************************************************************/
/* 16/10/2015  | Reinaldo Maurício Santos       | Criação da rotina/procedimento.                                     				**/
/**********************************************************************************************************************************/

User Function MT100GE2()

	Local nOpc 		:= PARAMIXB[2] //Retorna a opcao selecionada
	Local aAreaSDE					//area da tabela SDE
	Local aAreaSEV					//area da tabela SEV
	Local aAreaSEZ					//area da tabela SEZ
	Local nItemSD1					//Verifica de mudou de Item
	Local cLinItem 	:= 1			//Numero de Linhas
	Local aTitulos 	:= {}			//Array com informacoes para gravar na SEZ
	Local x							//Variavel complementar
	Local ladd 		:= .F.			//Grava ou Nao no Array
	Local nValor
	Local nChavSD1

	Local areasd1:= sd1->(getarea())
	Local areasc7:= sc7->(getarea())
	Local _data :=""

	RecLock("SE2",.F.)
		SE2->E2_NATUREZ := SF1->F1_ZNATURE
	SE2->( MsUnLock())

	IF SF1->( FieldPos("F1_OBSADL") ) != 0 .And. SE2->( FieldPos("E2_OBSADL") ) != 0
		//se tiver mensagem
		IF !Empty(SF1->F1_OBSADL)
			//grava no titulo a pagar
			RecLock("SE2",.F.)
			SE2->E2_OBSADL := SF1->F1_OBSADL
			SE2->( MsUnLock())
		EndIF
	EndIF
    //if isincallstack("MATA103")
   //     SE2->E2_NATUREZ:= __cCamNovo //SF1->F1_ZNATURE
   // endif
	// Atualizar C7_DATPRF com F1_DTDIGIT
	SD1->(dbsetorder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	_cKeySD1:=xfilial("SD1")+sf1->(f1_doc+f1_serie+f1_fornece+f1_loja)
	_data:=sf1->f1_dtdigit
	SC7->(dbsetorder(1))
	SD1->(dbseek(_cKeySD1,.f.))

	do while SD1->(!eof() .and. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA==_cKeySd1)
		if SC7->(dbseek(xfilial()+SD1->(d1_pedido+d1_itempc),.f.))
			reclock("SC7",.F.)
			SC7->c7_datprf := _data
			SC7->(msunlock())
			SC7->(dbskip())
		endif
		SD1->(dbskip())
	enddo

	SD1->(restarea(areasd1))
	SC7->(restarea(areasc7))

//------------------------------------FIM Rafael Inicio Reinaldo
/* Tiago Santos*/

 if SF1->( FieldPos("F1_ZNATURE") ) != 0 .and. ISINCALLSTACK( "MATA100" )
	SE2->E2_NATUREZ := SF1->F1_ZNATURE
 Endif
	If nOpc == 1 //.. inclusao

		//verifica se a empresa logada esta contida no parametro
		IF cEmpAnt $ SuperGetMv( "MV_xRATEIO" , .F.) .And. MV_MULNATP

			aAreaSDE := GetArea("SDE")
			aAreaSEV := GetArea("SEV")
			aAreaSEZ := GetArea("SEZ")

			//------------------------------------------------------------------
			// Verifico se o Documento de Entrada tem Rateio por centro de custo
			//------------------------------------------------------------------

			// seta ordem
			SDE->(DbSetOrder(1))//DE_FILIAL+DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF+DE_ITEM
			SDE->(DbGoTop())

			// Posiciona na tabela SDE se existir Rateio por Centro de Custo
			If SDE->(DbSeek( xFilial("SDE") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ))

				//informo que tera multiplas naturezas
				SE2->E2_MULTNAT := "1"

				//-------------------------------------------------------------
				// GRAVANDO NA SEV = MÚLTIPLAS NATUREZAS POR TÍTULO (CABECALHO)
				//-------------------------------------------------------------

				SEV->(dbSelectArea("SEV")) 	//Seleciona tabela SEV
				SEV->(dbSetOrder(1))			//Seta Ordem

				RecLock("SEV",.T.)	//Abre gravacao T = Inclusao

				SEV->EV_FILIAL	:= SE2->E2_FILIAL
				SEV->EV_PREFIXO  	:= SE2->E2_PREFIXO  // Busca da Serie documento de Entrada
				SEV->EV_NUM		:= SE2->E2_NUM
				SEV->EV_PARCELA	:= SE2->E2_PARCELA
				SEV->EV_CLIFOR	:= SE2->E2_FORNECE
				SEV->EV_LOJA		:= SE2->E2_LOJA
				SEV->EV_TIPO		:= SE2->E2_TIPO
				SEV->EV_VALOR		:= SE2->E2_VALOR
				SEV->EV_RECPAG	:= "P" 				//IRA GRAVAR TITULOS A RECEBER
				SEV->EV_PERC		:= 1					//PERCENTUAL DIVIDIDO POR NATUREZA
				SEV->EV_RATEICC	:= "1"					//RATEIO POR CENTOR DE CUSTO 1= SIM
				SEV->EV_IDENT		:= "1"					//IDENTIFICADOR
				SEV->EV_NATUREZ	:= SE2->E2_NATUREZ   //Posicione("SED",1,xFilial("SED")+ SE2->E2_NATUREZ,"ED_DESCRIC")//RETORNA DESCRICAO DA NATUREZA


				SD1->(DbSelectArea("SD1"))//Seleciono tabela dos itens da Nota
				SD1->(DbSetOrder(1))		 //Seta Ordem
				SD1->(DbGoTop())
				SD1->(DbSeek(xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)) ) //Posiciono na Nota Fiscal

				SDE->(DbSelectArea("SDE"))//Seleciono tabela dos itens do rateio
				SDE->(DbSetOrder(1))		 //Seta Ordem
				SDE->(DbGoTop())
				SDE->(DbSeek( xFilial("SDE") + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ITEM ))//Posiciono nos itens da Nota

				//-----------------------------------------------------
				// Validacoes antes da gravacao - armazenando em array
				//-----------------------------------------------------
				nChavSD1 := SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

				//Loop enquanto item da Nota for igual ao item do Rateio
				WHILE SDE->DE_FILIAL + SDE->DE_DOC + SDE->DE_SERIE + SDE->DE_FORNECE + SDE->DE_LOJA == nChavSD1

					//variavel recebe item  do rateio
					nItemSD1 := SDE->DE_ITEMNF

					//Se array for vazio entra no if, sempre vai entrar na primeira vez
					if len(aTitulos) == 0
						//adicionando informacoes no array aTitulos (Centro de Custo/ Percentual / Item)
						AADD(aTitulos,{SDE->DE_CC,((SE2->E2_VALOR / 100) * SDE->DE_PERC ),SD1->D1_ITEM})
					Else
						//Ordena os elementos de um array
						ASORT(aTitulos)
						//Loop no array
						for x := 1 to len(aTitulos)
							//centro de custo do array é igual ao centro de custo do rateio corrente?
							if (aTitulos[x][1] ==  SDE->DE_CC)
								//Variavel recebe percentual
								Valor 	 := Round(((SDE->DE_PERC * SE2->E2_VALOR) / 100), 2 )
								//array recebe o valor da variavel com o percentual, acrescentando se necessario
								aTitulos[x][2] += Valor
								//variavel logica recebe Verdadeiro
								ladd := .T.
							EndIF
						Next

						IF !ladd // Se variavel for Falsa entra no if
							//adicionando informacoes no array aTitulos (Centro de Custo/ Percentual / Item)
							AADD(aTitulos,{SDE->DE_CC,((SE2->E2_VALOR / 100) * SDE->DE_PERC ),SD1->D1_ITEM})
							//variavel logica recebe Falso
							ladd := .F.
						EndiF
					EndIf

					SDE->(dbSkip()) // avanca um registro na tabela SDE

					//Variavel é diferente do campo Item da SDE corrente
					If nItemSD1 <> SDE->DE_ITEMNF
						//verifica se ainda é o mesmo Dcumento
						If 	SD1->D1_DOC == SDE->DE_DOC
							SD1->(dbSkip())//avanca no registro da SD1
							cLinItem++ //variavel recebe + 1
						EndIf
						//Else
						//cLinItem++ //variavel recebe + 1
					EndIf

				ENDDO

				SDE->(DbGoTop())
				//Posiciona na tabela SDE de acordo com a Nota
				SDE->(DbSeek( xFilial("SDE") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ))

				//-----------------------------------------------------
				// GRAVANDO NA SEZ = DISTRIB DE NATUREZAS EM CC (ITENS)
				//-----------------------------------------------------

				SEZ->(dbSelectArea("SEZ"))	//Seleciona tabela SEZ
				SEZ->(dbSetOrder(1))			//Seta Ordem

				//Loop no array que contem as informacoes que serao gravadas na tabela SEZ
				for x := 1 to len(aTitulos)

					RecLock("SEZ",.T.) //Abre gravacao T = Inclusao

					SEZ->EZ_FILIAL	:= SDE->DE_FILIAL
					SEZ->EZ_PREFIXO  	:= SDE->DE_SERIE
					SEZ->EZ_NUM		:= SDE->DE_DOC
					SEZ->EZ_CLIFOR	:= SDE->DE_FORNECE
					SEZ->EZ_LOJA		:= SDE->DE_LOJA
					SEZ->EZ_VALOR		:= NoRound((aTitulos[x][2] / cLinItem),2)  // Valor dividido pelo numero de itens do documento (NoRound = Nao arredonda)
					SEZ->EZ_CCUSTO 	:= aTitulos[x][1]							// centro de custo
					SEZ->EZ_PERC		:= (((aTitulos[x][2] / cLinItem) * 100) / SE2->E2_VALOR) / 100 // Percentual de acordo com itens e valor do docuemnto

					SEZ->EZ_TIPO		:= SEV->EV_TIPO	 	// VINDO DA SEV
					SEZ->EZ_NATUREZ	:= SEV->EV_NATUREZ	// VINDO DA SEV
					SEZ->EZ_RECPAG	:= SEV->EV_RECPAG		// VINDO DA SEV
					SEZ->EZ_PARCELA	:= SEV->EV_PARCELA  	// VINDO DA SEV
					SEZ->EZ_LA			:= SEV->EV_LA			// VINDO DA SEV
					SEZ->EZ_IDENT		:= SEV->EV_IDENT		// VINDO DA SEV
					SEZ->EZ_SEQ		:= SEV->EV_SEQ		//sequencia da baixa
					SEZ->EZ_SITUACA	:= SEV->EV_SITUACA	//situacao do registro

					SEZ->(MsUnlock()) //libera registro
					SDE->(dbSkip())  // avanca no registro da SDE

				Next

				SEV->(MsUnlock()) //libera registro

				//Caso nao tenha rateio
			Else
				u_GravEvEz(aTitulos,cLinItem)
			EndIf

			RestArea(aAreaSDE)//Libera area
			RestArea(aAreaSEV)//Libera area
			RestArea(aAreaSEZ)//Libera area

		EndIf

	EndIf

Return Nil


//--------------------------------------
User Function GravEvEz(aTitulos,cLinItem)

	Local x
	Local cLinItem  := 0
	Local nValTotal := SF1->F1_VALBRUT
	Local nCond	  := SF1->F1_COND
	Local dDtEmissa := SF1->F1_EMISSAO
	Local aFator	  := {}
	Local _nVez

	aAreaSE2 := GetArea("SE2")
	aAreaSD1 := GetArea("SD1")

	SE2->E2_MULTNAT := "1" //informo que tera multiplas naturezas

	//-------------------------------------------------------------
	// GRAVANDO NA SEV = MÚLTIPLAS NATUREZAS POR TÍTULO (CABECALHO)
	//-------------------------------------------------------------

	SEV->(dbSelectArea("SEV")) 	//Seleciona tabela SEV
	SEV->(dbSetOrder(1))			//Seta Ordem

	RecLock("SEV",.T.)	//Abre gravacao T = Inclusao

	SEV->EV_FILIAL	:= SE2->E2_FILIAL
	SEV->EV_PREFIXO  	:= SE2->E2_PREFIXO  // Busca da Serie documento de Entrada
	SEV->EV_NUM		:= SE2->E2_NUM
	SEV->EV_PARCELA	:= SE2->E2_PARCELA
	SEV->EV_CLIFOR	:= SE2->E2_FORNECE
	SEV->EV_LOJA		:= SE2->E2_LOJA
	SEV->EV_TIPO		:= SE2->E2_TIPO
	SEV->EV_VALOR		:= SE2->E2_VALOR
	SEV->EV_RECPAG	:= "P" 				//IRA GRAVAR TITULOS A RECEBER
	SEV->EV_PERC		:= 1					//PERCENTUAL DIVIDIDO POR NATUREZA
	SEV->EV_RATEICC	:= "1"					//RATEIO POR CENTOR DE CUSTO 1= SIM
	SEV->EV_IDENT		:= "1"					//IDENTIFICADOR
	SEV->EV_NATUREZ	:= SE2->E2_NATUREZ   //Posicione("SED",1,xFilial("SED")+ SE2->E2_NATUREZ,"ED_DESCRIC")//RETORNA DESCRICAO DA NATUREZA

	SEV->(MsUnlock()) //libera registro

	SD1->(DbSelectArea("SD1"))//Seleciono tabela dos itens da Nota
	SD1->(DbSetOrder(1))		 //Seta Ordem
	SD1->(DbGoTop())
	SD1->(DbSeek(xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)) ) //Posiciono na Nota Fiscal

	SEZ->(dbSelectArea("SEZ"))	//Seleciona tabela SEZ
	SEZ->(dbSetOrder(1))		//Seta Ordem

	//Armazena em variavel o documento
	//nDocNf := SD1->FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA
	nDocNf := SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

	//Loop enquanto item da Nota for igual ao item do Rateio
	WHILE SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == nDocNf

		_nPosic := ascan(aFator,{|_vAux|_vAux[1] == SD1->D1_CC})

		if _nPosic==0
			AADD(aFator,{SD1->D1_CC,0})
			_nPosic:=len(aFator)
		endif

		aFator[_nPosic,2] += (((SD1->D1_TOTAL + SD1->D1_ICMSRET + SD1->D1_VALIPI) - SD1->D1_VALDESC) / nValTotal)

		SD1->(dbSkip())  // avanca no registro da SD1

	EndDo

	SD1->(DbGoTop())
	SD1->(DbSeek(xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)) ) //Posiciono na Nota Fiscal

	_nValorQFalta:= SEV->EV_VALOR

	for _nVez:=1 to len(aFator)

		RecLock("SEZ",.T.) //Abre gravacao T = Inclusao

		SEZ->EZ_FILIAL	:= SF1->F1_FILIAL
		SEZ->EZ_PREFIXO  	:= SF1->F1_PREFIXO
		SEZ->EZ_NUM		:= SF1->F1_DOC
		SEZ->EZ_CLIFOR	:= SF1->F1_FORNECE
		SEZ->EZ_LOJA		:= SF1->F1_LOJA
		if _nVez == len(aFator)
			SEZ->EZ_VALOR := _NvALORqfALTA
		else
			SEZ->EZ_VALOR := Round(SEV->EV_VALOR * aFator[_nVez][2],TamSx3("EZ_VALOR")[2])
			_nValorQFalta -= SEZ->EZ_VALOR
		endif
		SEZ->EZ_CCUSTO 	:= aFator[_nVez][1]
		SEZ->EZ_PERC		:= aFator[_nVez][2]
		SEZ->EZ_TIPO		:= SEV->EV_TIPO	 	// VINDO DA SEV
		SEZ->EZ_NATUREZ	:= SEV->EV_NATUREZ	// VINDO DA SEV
		SEZ->EZ_RECPAG	:= SEV->EV_RECPAG		// VINDO DA SEV
		SEZ->EZ_PARCELA	:= SEV->EV_PARCELA  	// VINDO DA SEV
		SEZ->EZ_LA			:= SEV->EV_LA			// VINDO DA SEV
		SEZ->EZ_IDENT		:= SEV->EV_IDENT		// VINDO DA SEV
		SEZ->EZ_SEQ		:= SEV->EV_SEQ		// sequencia da baixa
		SEZ->EZ_SITUACA	:= SEV->EV_SITUACA	// situacao do registro

		SEZ->(MsUnlock()) //libera registro

	next

	SEZ->(MsUnlock()) //libera registro

	RestArea(aAreaSE2)//Libera area
	RestArea(aAreaSD1)//Libera area

Return

/*/{Protheus.doc} M103Infos
Função para mostrar o Observação da Nota no Documento de Entrada

@author Rafael Ricardo Vieceli
@since 03/07/2015
@version 1.0
/*/
Static Function M103Infos()

	Local cObservaoAdicional := SF1->F1_OBSADL

	Local oDlg
	Local oObs

	DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 TO 240,500 PIXEL

	@ 15,20   SAY "Observação" SIZE 73, 8 OF oDlg PIXEL
	@ 25,20   GET oObs Var cObservaoAdicional MEMO VALID !Empty(cCondicaoPagamento) SIZE 210,60 OF oDlg PIXEL
	oObs:lReadOnly := .T.

	DEFINE SBUTTON FROM 95, 205 When .T. TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} MT103AFN
Ponto de Entrada que define o código de base e o número do item do ativo imobilizado,
 permitindo utilizar os dados do projeto como base.
@author Fernando Nonato
@since 28/11/2015
@version 1.0
@return ${aRetorno}, ${Retorna o numero seguencial do Ativo padronizado}
@see http://tdn.totvs.com/display/public/mp/MT103AFN+-+Utiliza+dados+de+ativo+fixo
/*/
User Function MT103AFN()

	Local aParamAFN  := Paramixb[1] //Dados do projeto
	Local cAtuaATF   := Paramixb[2] //Atualiza ativo:  "S"-Sim / "N"-Nao
	Local cDesItATF  := Paramixb[3] //Desmembra itens ativo:  "1"-Sim / "2"-Nao
	Local lTipoDes   := Paramixb[4] //".F." Desmembra itens / ".T." Desmembra codigo base
	Local cAtuAtivo	 := SuperGetMv("BL_ATUATV",.F.,"N")
	Local cGrupoAtv	 := SuperGetMv("BL_GRPATV",.F.,"") // Grupo que representa ativo fixo
	Local aRetorno 	 := {"",""}
	Local nTamBase 	 := TamSX3("N3_CBASE")[1]
	Local cItem		 := "0001"
	IF cAtuaATF == "S"
		If cAtuAtivo == "S"	// Gera ativo a partir do pedido de venda

			cGeraFrota 	:= Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1__GRFRT")
			cGrupo	 	:= Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_GRUPO")
			If cGeraFrota == "S"
				cSeq	:= GetMv("BL_NUMFROT") // Codigo numerico
				cCodigo := "F" + cSeq
				PutMv("BL_NUMFROT",SOMA1(strzero(val(cSeq),len(cSeq) )))

			Elseif cGrupo $ cGrupoAtv
				cSeq	:= GetMv("BL_NUMATV") // Codigo numerico
				cCodigo := cSeq
				PutMv("BL_NUMATV",SOMA1(strzero(val(cSeq),len(cSeq) )))
			Else
				cCodigo := substr(SD1->D1_COD,1, nTamBase)
				cItem   := strzero(val(SD1->D1_ITEM),4)
			Endif
			aRetorno[1] := cCodigo
			aRetorno[2] := cItem
		/*
		SN1->( dbSetOrder(1) )
			While SN1->( dbSeek( xFilial("SN1") + aRetorno[1] ) )
			ConfirmSX8()
			aRetorno[1] := GetSXENum("SN1","N1_CBASE")
			EndDO
		*/
		Else
			aRetorno := nil
		EndIF
	Else
		aRetorno := nil
	Endif

Return aRetorno

/*/{Protheus.doc} MT100GRV
(Está localizado na função a103Grava responsável pela gravação da Nota Fiscal.
Executado antes de iniciar o processo de gravação / exclusão de Nota de Entrada.)
@author Rei
@since 26/10/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function MT100GRV()

	Local lExp01 := PARAMIXB[1]  //Informa se é exclusão.
	Local lExp02 := .T. 		 //Informa se a nota pode ou não ser gravada/excluída.

//Abre tabela SA2, seta ordem de busca, procura e posiciona no fornecedor
	SA2->(dbSelectArea("SA2"))
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2") + SF1->(CA100FOR + CLOJA ))) // CA100FOR = Fornecedor selecionado, CLOJA = Loja selecionada

//Verifica se Fornecedor esta atualizado pelo Fiscal (1= Sim, 2= Nao)
	If SA2->A2_XFORATU == "2"

		MsgAlert("Fornecedor desatualizado, não será possível salvar o documento!"+ CRLF + ;
			"Informe o departamento Fiscal.")
		lExp02 := .F. // Retorna falso nao permitindo salvar o documento.

	EndIf

Return lExp02

//---------------------------------------------------EVAL PASSA 1 AQUI
//--http://tdn.totvs.com/display/public/mp/A103VCTO
//O ponto de entrada A103VCTO será utilizado para manipular as informações do array aColsSE2 utilizado
//na geração dos títulos financeiros (Tabela SA2) no momento da inclusão do documento de entrada (MATA103).
//---------------------------------------------------
User Function A103VCTO
	Local aVencto 		:= {} //Array com os vencimentos e valores para geração dos títulos.
	Local aPELinhas 	:= PARAMIXB[1] //Array - Array com os títulos (aColsSE2)
	Local nPEValor 		:= PARAMIXB[2] //2 - Numérico - Valor do Título
	Local cPECondicao 	:= PARAMIXB[3] //3 - Caracter - Condição de Pagamento
	Local nPEValIPI 	:= PARAMIXB[4] //Numérico - Valor do IPI
	Local dPEDEmissao 	:= PARAMIXB[5] //Data - Data de Emissão
	Local nPEValSol 	:= PARAMIXB[6] //Numérico - Valor do Solidário

	Local nCont      	:= 0
	Local nTotalZK1  	:= 0
	Local nTotalGrid 	:= 0
	Local nRatear	 	:= 0
	Local lRPadrao   	:= .F.
	Local aArea 	   	:= getarea()

	//Condicao de pagamento é a mesma da Nota Fiscal
	IF cCondicao == SF1->F1_COND

		ZK1->( dbSetOrder(1) )
		ZK1->(dbgotop())
		ZK1->( dbSeek( xFilial("ZK1") + SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO) ) )

		//------------------------------------------
		//loop pra pegar valor total vindo da ZK1
		//------------------------------------------
		While !ZK1->( Eof() ) .And. ZK1->(ZK1_FILIAL+ZK1_CHAVE) == xFilial("ZK1") + SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)

			nTotalZK1  += ZK1->ZK1_VALOR

			nCont ++
			ZK1->( dbSkip() )
		EndDO
		nTotalGrid := nPEValor + nPEValIPI
		//verifica se tem produtos com imposto e divide o valor por parcela.
		if nTotalGrid > nTotalZK1
			//valor total dos impostos
			nRatear := (nTotalGrid - nTotalZK1) / nCont
		EndIf

		ZK1->(dbgotop())
		ZK1->( dbSeek( xFilial("ZK1") + SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO) ) )

		//------------------------------------------
		//loop para atualizar o grid das duplicatas
		//------------------------------------------
		//loop na tabela ZK1 com as informacoes gravadas na Pre Nota
		While !ZK1->( Eof() ) .And. ZK1->(ZK1_FILIAL+ZK1_CHAVE) == xFilial("ZK1") + SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)

			//atualizado data de vencimento
			aadd(aVencto,{stod(dtos(ZK1->ZK1_VENC)),ZK1->ZK1_VALOR + nRatear})

			ZK1->( dbSkip() )
		EndDO

	Endif
	//aVencto := {}

Return aVencto //Array com os vencimentos para geração dos títulos.


//----------------------------------------------------EVAL PASSA 3 AQUI
//O ponto de entrada: MT103DUP, permite manter ou não o Acols com as datas de vencimentos e
//valores de duplicatas quando for efetuada a confirmação para a gravação da nota fiscal.
//As validações dos Acols, deverá ser retornada através do Ponto de Entrada que poderá utilizar
//os parâmetros enviados para tais validações.As validações existentes nos parâmetros:
//MV_CONFDUP, MV_LIMPAG e MV_LIMREC continuam inalteradas e funcionando normalmente.
//---------------------------------------------------
User Function MT103DUP

	Local aDupAtu	:=ParamIxb[1]
	Local aDupNew	:=ParamIxb[2]
	Local lRet		:=.F. 			//Mantel o Acols de Duplicatas com os valores Atuais.T. = Sim.F. = Não

Return lRet



/*/{Protheus.doc} MT103TPC
Ponto de entrada usado pra validação do Rateio do Projeto

@author Rafael Ricardo Vieceli
@since 17/11/2016
@version undefined

@type function
/*/
User Function MT103TPC()

	//Valida se utiliza o parametro MV_INTPMS e se possui integração TOP x PROTHEUS
	IF IntePms() .And. IsIntegTop(,.T.)
		//se não estiver deletado
		IF ! aCols[n][Len(aHeader)+1]
			u_VldRatAFN(n)
		EndIF
	EndIF

Return ParamIXB[1]


/*/{Protheus.doc} MT103FIN
Ponto de entrada usado pra validação do Rateio do Projeto

@author Rafael Ricardo Vieceli
@since 17/11/2016
@version undefined

@type function
/*/
User Function MT103FIN()

	Local lRetorno := ParamIXB[3]
	Local nItens

	//Valida se utiliza o parametro MV_INTPMS e se possui integração TOP x PROTHEUS
	IF IntePms() .And. IsIntegTop(,.T.)
		//percorre os itens da prenota
		For nItens := 1 To Len(aCols)
			//se não estiver deletado
			IF ! aCols[nItens][Len(aHeader)+1]
				IF ! u_VldRatAFN(nItens)
					lRetorno := .F.
				EndIF
			EndIF
		Next nItens
	EndIF

Return lRetorno


/*/{Protheus.doc} MT100AGR
	Após a Inclusão da Nota Fiscal de  Entrada, porém fora da Transação.
	@type  Function
	@author ugusto Ribeiro
	@since 27/04/2012 
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function MT100AGR()
Local lImpNFE := GetMv("MV_XMLIMP",.F.,.F.)    
    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Utiliza sistema de importacao de XML ? ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF  lImpNFE
	fAltStXML()
ENDIF 
	
Return




/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fAltStXMLºAutor  ³ Augusto Ribeiro	 º Data ³  27/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ IMPORTA NF-e | Altera status no painel de arquivos         º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fAltStXML()
Local aArea := GetArea()
Local aAreaZ10 := {}
Local aAreaZ17 := {}
Local lAtuLegZ10 := .F.
Local lAtuLegZ17 := .F.                        
Local nRec := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclusao de Nota Fiscal ou Classificacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF INCLUI .OR. ALTERA
	
	aAreaZ10	:= Z10->(GetArea())
	

	DBSELECTAREA("Z10")
	Z10->(DBSETORDER(1))	//| Z10_FILIAL, Z10_CHVNFE
	IF Z10->(DBSEEK(XFILIAL("Z10")+SF1->F1_CHVNFE,.F.))
		lAtuLegZ10 := .T.
		nRec := Z10->(RECNO())
	ENDIF

	Z10->(DBSETORDER(2)) 
	IF Z10->(DBSEEK(XFILIAL("Z10")+SF1->(F1_DOC+F1_SERIE)+POSICIONE("SA2",1,xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA),"A2_CGC"),.F.))
		lAtuLegZ10 := .T.
		nRec := Z10->(RECNO())
	ELSEIF Z10->(DBSEEK(XFILIAL("Z10")+PADR(RIGHT(SF1->F1_DOC,6),TAMSX3("Z10_NUMNFE")[1])+SF1->F1_SERIE+POSICIONE("SA2",1,xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA),"A2_CGC"),.F.))
		lAtuLegZ10 := .T.
		nRec := Z10->(RECNO())
	ENDIF   

	IF lAtuLegZ10
		Z10->(DBGOTO( nRec ))
		RECLOCK("Z10",.F.)
			Z10->Z10_STATUS	:= "5"		
		MSUNLOCK()
	ENDIF

	If AliasInDic("Z17")
		aAreaZ17	:= Z17->(GetArea())
		DBSELECTAREA("Z17")
		Z17->(DBSETORDER(1)) 
		IF Z17->(DBSEEK(XFILIAL("Z17")+SF1->F1_DOC+PADR(SF1->F1_SERIE,TAMSX3("Z17_SERIE")[1])+POSICIONE("SA2",1,xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA),"A2_CGC"),.F.))
			lAtuLegZ17 := .T.
			nRec := Z17->(RECNO())
		ELSEIF Z17->(DBSEEK(XFILIAL("Z17")+PADR(RIGHT(SF1->F1_DOC,6),TAMSX3("Z17_NFE")[1])+SF1->F1_SERIE+POSICIONE("SA2",1,xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA),"A2_CGC"),.F.))
			lAtuLegZ17 := .T.
			nRec := Z17->(RECNO())
		ENDIF				

		IF lAtuLegZ17
			Z17->(DBGOTO( nRec ))
			RECLOCK("Z17",.F.)
				Z17->Z17_STATUS	:= "4"		
			MSUNLOCK()
			//Atualiza Status
			cCnpjEmp := U_fGetCNPJ(AllTrim(SM0->M0_CODIGO),AllTrim(SM0->M0_CODFIL))
			U_CP01MFST(cCnpjEmp, Z17->Z17_NFE, "CLASSIFICADA", "NFSE", Z17->Z17_CGC,Z17->Z17_DATA)
		ENDIF

		RestArea(aAreaZ17)

	Endif
		
	RestArea(aAreaZ10)	
		
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclusao da Nota ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ELSEIF !INCLUI .AND. !ALTERA
		
	aAreaZ10	:= Z10->(GetArea())

	DBSELECTAREA("Z10")
	Z10->(DBSETORDER(1))	//| Z10_FILIAL, Z10_CHVNFE
	IF Z10->(DBSEEK(XFILIAL("Z10")+SF1->F1_CHVNFE,.F.))
		lAtuLegZ10 := .T.
		nRec := Z10->(RECNO())
	ENDIF

	Z10->(DBSETORDER(2)) 
	IF Z10->(DBSEEK(XFILIAL("Z10")+SF1->(F1_DOC+F1_SERIE)+POSICIONE("SA2",1,xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA),"A2_CGC"),.F.))
		lAtuLegZ10 := .T.
		nRec := Z10->(RECNO())
	ELSEIF Z10->(DBSEEK(XFILIAL("Z10")+PADR(RIGHT(SF1->F1_DOC,6),TAMSX3("Z10_NUMNFE")[1])+SF1->F1_SERIE+POSICIONE("SA2",1,xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA),"A2_CGC"),.F.))
		lAtuLegZ10 := .T.
		nRec := Z10->(RECNO())
	ENDIF 

	IF lAtuLegZ10
		Z10->(DBGOTO(nRec))
		RECLOCK("Z10",.F.)
			If IsInCallStack("a140estcla")
				Z10->Z10_STATUS	:= "2"		
			Else	
				Z10->Z10_STATUS	:= "1"		
			Endif
		Z10->(MSUNLOCK())
		/*----------------------------------------
			30/04/2019 - Jonatas Oliveira - Compila
			Atualiza Motor Fiscal
		------------------------------------------*/
		//Atualiza Status
		cCnpjEmp := U_fGetCNPJ(AllTrim(Z10->Z10_CODEMP),AllTrim(Z10->Z10_CODFIL))
		U_CP01MFST(cCnpjEmp, Z10->Z10_CHVNFE, "INTEGRADO", IIF( ALLTRIM(Z10->Z10_TIPARQ) == "C", "CTE", "NFE" ))				
	ENDIF

	If AliasInDic("Z17")
		aAreaZ17	:= Z17->(GetArea())

		DBSELECTAREA("Z17")
		Z17->(DBSETORDER(1)) 
		IF Z17->(DBSEEK(XFILIAL("Z17")+SF1->F1_DOC+PADR(SF1->F1_SERIE,TAMSX3("Z17_SERIE")[1])+POSICIONE("SA2",1,xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA),"A2_CGC"),.F.))
			lAtuLegZ17 := .T.
			nRec := Z17->(RECNO())
		ELSEIF Z17->(DBSEEK(XFILIAL("Z17")+PADR(RIGHT(SF1->F1_DOC,6),TAMSX3("Z17_NFE")[1])+SF1->F1_SERIE+POSICIONE("SA2",1,xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA),"A2_CGC"),.F.))
			lAtuLegZ17 := .T.
			nRec := Z17->(RECNO())
		ENDIF	

		IF lAtuLegZ17
			cCnpjEmp := U_fGetCNPJ(AllTrim(SM0->M0_CODIGO),AllTrim(SM0->M0_CODFIL))
			Z17->(DBGOTO(nRec))
			RECLOCK("Z17",.F.)
				If IsInCallStack("a140estcla")
					Z17->Z17_STATUS	:= "2"
					//Atualiza Status
					U_CP01MFST(cCnpjEmp, Z17->Z17_NFE, "NOTA CLASSIFICADA", "NFSE", Z17->Z17_CGC,Z17->Z17_DATA)
				Else
					Z17->Z17_STATUS	:= "1"
					//Atualiza Status
					U_CP01MFST(cCnpjEmp, Z17->Z17_NFE, "INTEGRADA", "NFSE", Z17->Z17_CGC,Z17->Z17_DATA)
				Endif		
			MSUNLOCK()			
		ENDIF

		RestArea(aAreaZ17)	
	Endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Remove campo SYP caso exista dados  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !EMPTY(SF1->F1_XCNFOBS)
		MSMM(SF1->F1_XCNFOBS,,,,2,,,"SF1","F1_XCNFOBS")
	ENDIF
			
	RestArea(aAreaZ10)	

ENDIF 

RestArea(aArea)
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MTCOLSE2 ºAutor  ³ Augusto Ribeiro	 º Data ³  08/05/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Manipula os dados do aCols de títulos a pagar.             º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MTCOLSE2()
Local aRet := ParamIxb[1]
Local lImpNFE := GetMv("MV_XMLIMP",.F.,.F.)    
Local aArea		:= GetArea()    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Utiliza sistema de importacao de XML ? ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF  lImpNFE 
	IF TYPE("lTitNFeAuto") == "L" .AND. TYPE("aTitNf_S") == "A".AND. !EMPTY(SF1->F1_CHVNFE)
		IF lTitNFeAuto .AND. LEN(aTitNf_S) > 0
			aRet	:= fGeraTit(aRet)
		ENDIF
	ENDIF
ENDIF 
                                
RestArea(aArea)
Return(aRet)                                                         



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fGeraTit º Autor ³ Augusto Ribeiro	 º Data ³  08/05/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Manipula a geracao de titulos a pagar conforme XML         º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGeraTit(aTitulo)
Local aRet 	:= aTitulo  
Local aOrig	:= aTitulo
Local cParc	:= "A"
Local aAreaZ13, nI   


DBSELECTAREA("Z13")
aAreaZ13	:= Z13->(GetArea())
Z13->(DBSETORDER(1))

IF Z13->(DBSEEK(XFILIAL("Z13")+SF1->F1_CHVNFE+"E")) 
	aRet	:= {}   
              
	nI	:= 0
	WHILE Z13->(!EOF()) .AND.  Z13->Z13_CHVNFE == SF1->F1_CHVNFE .AND. Z13->Z13_TIPARQ == "E"
	        
	  	nI++
		aadd(aRet, aClone(aOrig[1]))
		
		//| 1 PARCELA
		//| 2 VENCIMENTO
		//| 3 VALOR
		aRet[nI,1]	:= cParc
		aRet[nI,2]	:= Z13->Z13_DTVENC
		aRet[nI,3]	:= Z13->Z13_VALOR		
         
		cParc := SOMA1(cParc)
		Z13->(DBSKIP())
	ENDDO
ENDIF                


RestArea(aAreaZ13)
Return(aRet)


User Function SF1100I()
    Local aArea := GetArea()
    //Se a variável pública existir
    If Type("__cCamNovo") != "U"
        //Grava o conteúdo na SF1
        RecLock("SF1", .F.)
            SF1->F1_ZNATURE := __cCamNovo
        SF1->(MsUnlock())
    EndIf
    RestArea(aArea)
Return


User Function MT103MNT()
Local aHeadSev := PARAMIXB[1]
Local aColsSev := PARAMIXB[2]
///  carga do aColsSev ///
Return aColsSev    

user function MT103NTZ()          
Local ExpC1 := ParamIxb[1]     // Rotina do usuário para geração das Pré-Requisições.
IF SF1->( FieldPos("F1_ZNATURE") ) != 0
	ExpC1 :=  SF1->F1_ZNATURE
Endif

if Empty(ExpC1) // não encontrou, então procurar na tabela de pedidos
	ExpC1 := SC7->C7_ZNATURE
endif
Return ExpC1 


user function MT103NAT()
Local lRet := .T.
Local cNat := PARAMIXB

if Empty(Alltrim(cNat)) .or. ! ExistCPO("SED", cNat)
	lRet := .F.
elseif SF1->( FieldPos("F1_ZNATURE") ) != 0 
 	RECLOCK( "SF1", .F. )
		SF1->F1_ZNATURE := cNat
	SF1->(MSUNLOCK())
 Endif

return lRet


USER FUNCTION MT103MSD
Local lExc:=.F.
RECLOCK( "SF1", .F. )
	SF1->F1_ZNATURE := SC7->C7_ZNATURE
SF1->(MSUNLOCK())

Return lExc
