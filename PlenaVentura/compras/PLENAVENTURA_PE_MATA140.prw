#include 'protheus.ch'

/*/{Protheus.doc} MA140BUT
LOCALIZAÇÃO : Function Ma140Bar() responsável pela inclusão de botões.
EM QUE PONTO : É chamado no momento da definicao dos botoes padrao do recebimento.

@author Rafael Ricardo Vieceli
@since 03/07/2015
@version 1.0
@return aBotoes, array, Lista com os botoes
@see http://tdn.totvs.com/pages/releaseview.action?pageId=6085354
@history 12/09/2019, Rafael Ricardo Vieceli, Nova opção nos botões na enchoice para Nota em PDF
/*/
User Function MA140BUT()

	Local aBotoes := {}

	//exceto para inclusao
	IF !INCLUI
		//adiciona opção para visualização da mensagem da nota
		IF SF1->( FieldPos("F1_OBSADL") ) != 0

			//Criado para apresentar ou nao a tela customizada da condicao de pagamento.
			IF cEmpAnt $ GetMv( "MV_xCCOND" , .F.)
				aAdd(aBotoes,{"BUDGET",  {|| M140CondInfo() },"Cond. Pagto/Observação","Cond. Pagto/Observação" })
			EndIF
		EndIF
	EndIF

	IF ! INCLUI
		aAdd(aBotoes, {"",{|| u_PDFA050Attach()},"Nota fiscal em PDF","Nota fiscal em PDF"})
	EndIF


Return aBotoes


/*/{Protheus.doc} MTA140MNU
Adicionar botões ao Menu Principal através do array aRotina.

@author Rafael Ricardo Vieceli
@since 12/09/2019
@version 1.0
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6085799
/*/
user function MTA140MNU()

	aAdd(aRotina, { "Nota fiscal em PDF"	,"u_PDFA050Attach"	, 0 , 2, 0, nil})
    aAdd(aRotina, { 'Etiqueta Entrada'		,'u_xcom900a(3)'		, 0 , 5, 0, NIL})
    // aAdd(aRotina, { 'Etiqueta Produto'		,'u_xcom900b(2)'	, 0 , 5, 0, NIL})

return


/*/{Protheus.doc} SF1140I
LOCALIZAÇÃO: Function Ma140Grava() - Responsável por atualizar um Pré-Documento de Entrada e seus anexos.
EM QUE PONTO: Ponto de Entrada utilizado na atualização do cabeçalho do Pré-Documento de Entrada.

@author Rafael Ricardo Vieceli
@since 03/07/2015
@version 1.0
@see http://tdn.totvs.com/pages/releaseview.action?pageId=6085617
/*/
User Function SF1140I()


	//se for inclusao
	IF INCLUI
		//mostra tela para informar condição de pagamento e observação.
		IF SF1->( FieldPos("F1_OBSADL") ) != 0

			//Criado para apresentar ou nao a tela customizada da condicao de pagamento.
			IF cEmpAnt $ GetMv( "MV_xCCOND" , .F.)

				M140CondInfo()
			EndIF
		EndIF
	EndIF

Return

/*/{Protheus.doc} SD1140E
(Ponto de Entrada utilizada para Excluir informacoes da tabela ZK1 - Condicao de pagamento)
@author Rei
@since 23/09/2015
@version 1.0
@see (http://tdn.totvs.com/display/public/mp/SD1140E)
/*/
User Function SD1140E()

	ZK1->( dbSetOrder(1) )
	ZK1->( dbSeek( xFilial("ZK1") + SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO) ) )

	While !ZK1->( Eof() ) .And. ZK1->(ZK1_FILIAL+ZK1_CHAVE) == xFilial("ZK1") + SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)

		RecLock("ZK1",.F.)
		ZK1->( dbDelete() )
		ZK1->( MsUnLock())

		ZK1->( dbSkip() )
	EndDO

Return


/*/{Protheus.doc} M140CondInfo
Função para mostrar/alterar a Observação e a Condição de Pagamento da Nota no Documento de Entrada

@author Rafael Ricardo Vieceli
@since 03/07/2015
@version 1.0
/*/
Static Function M140CondInfo()

	Local cCondicaoPagamento := SF1->F1_COND
	Local cObservaoAdicional := SF1->F1_OBSADL
	Local lOk 			:= .F.
	Local oDlgCustom
	Local oObs
	Local cSeek  		:= xFilial( "ZK1" ) + SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)
	Local cWhile 		:= "ZK1->ZK1_FILIAL + ZK1->ZK1_CHAVE"
	Local aObjects   	:= {}
	Local aSize      	:= MsAdvSize( .F. )
	Local aNoFields 	:= {"ZK1_CHAVE"}
	Local aSaveGrid 	:= {aCols,aHeader}
	Local aHeadZK1 	:= {}
	Local aColZK1 	:= {}
	Local aParcsOld 	:= {}
	Local n1
	Local nValTotal  	:= 0
	Local lData		:= .T.
	Local dData		:= DDATABASE
	Local nTotalNF	:= 0

	Private oParcs

	if Empty(cObservaoAdicional)
		SD1->(dbSetOrder(1))
		SC7->(dbSetOrder(1))
		if SD1->(dbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
			While SD1->(!Eof()) .and. SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA
				if SC7->(dbSeek(xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC))
					//if ! Upper(AllTrim(SC7->C7_OBS)) $ Upper(cObservaoAdicional)
					//	if !Empty(cObservaoAdicional)
					//		cObservaoAdicional+= ";"
					//	Endif
					//	cObservaoAdicional+= AllTrim(SC7->C7_OBS)
					//Endif

					if !Empty(SC7->C7_OBS)
						cObservaoAdicional:= AllTrim(SC7->C7_OBS)
						Exit
					Endif
				Endif
				SD1->(dbSkip())
			Enddo
		Endif
	Endif


	//monta aHeadZK1 e aColZK1
	FillGetDados(4,"ZK1",1,cSeek,{|| &cWhile },,aNoFields,,,,,,@aHeadZK1,@aColZK1,,,,)

	DEFINE MSDIALOG oDlgCustom TITLE cCadastro From 0,0 TO 350,500 PIXEL

	@ 10,20   SAY "Condição de Pagamento" SIZE 73, 8 OF oDlgCustom PIXEL
	@ 20,20   MSGET cCondicaoPagamento PICTURE PesqPict("SF1","F1_COND") F3 "SE4" VALID ExistCPO("SE4", cCondicaoPagamento) SIZE 20,9 OF oDlgCustom When INCLUI .Or. ALTERA PIXEL

	@ 20, 50 Button "Gerar"  Size 32, 9 Pixel Action AtualizaParcelas(cCondicaoPagamento, @oParcs, @aParcsOld)   Of oDlgCustom

	oParcs  := MsNewGetDados():New(010,100,70,230,IIF(INCLUI .Or. ALTERA,GD_UPDATE,0),"AllwaysTrue","AllwaysTrue",/*inicpos*/,,/*freeze*/,120,"AllwaysTrue",/*superdel*/,/*delok*/,oDlgCustom,aHeadZK1,aColZK1)

	@ 70,20   SAY "Observação" SIZE 73, 8 OF oDlgCustom PIXEL
	@ 80,20   GET oObs Var cObservaoAdicional MEMO VALID !Empty(cCondicaoPagamento) SIZE 210,60 OF oDlgCustom PIXEL
	//apenas na inclusao e na alteração podera alterar
	IF !(ALTERA .Or. INCLUI)
		//não sendo o caso, desabilita edição no memo
		oObs:lReadOnly := .T.
	EndIF

	DEFINE SBUTTON FROM 150, 175 When .T. TYPE 1 ACTION (aColZK1 := oParcs:aCols, aHeadZK1 := oParcs:aHeader,oDlgCustom:End(),lOk:=.T.) ENABLE OF oDlgCustom
	DEFINE SBUTTON FROM 150, 205 When .T. TYPE 2 ACTION (oDlgCustom:End()) ENABLE OF oDlgCustom

	ACTIVATE MSDIALOG oDlgCustom CENTERED

	//se confirmar e for alteração ou inclusao
	IF lOk .And. ( ALTERA .Or. INCLUI )

		nValTotal := 0
		nTotalNF  := 0

		//loop para retornar o valor total digitado
		For n1 := 1 to len(aColZK1)

			nValTotal  += aColZK1[n1][3]  //valor itens
			dData 		:= aColZK1[n1][2] //Data digitada

			//Valida se a data digitada é menor que a data base do sistema
			if  dData < dDataBase
				//muda variavel logica
				lData := .F.
			Endif

		Next n1

		//Retonar valor total da NF com Impostos/frete etc
		nTotalNF := u_VALTOTNF()

		//compara valor total do documento igual ao digitado? e se a variavel logica ficou FALSA (Data digitada menor que Data Base)
		//If nTotalNF == nValTotal .and. lData

		//se a data digitada for acima da data base do sistema entra no if
		If lData

			//grava os dados na nota
			RecLock("SF1",.F.)
			SF1->F1_COND   := cCondicaoPagamento
			SF1->F1_OBSADL := cObservaoAdicional
			SF1->F1_MENNOTA:= substr(cObservaoAdicional,1,len(SF1->F1_MENNOTA))
			if SF1->(FieldPos('F1_P1VENC')) > 0 .and. len(aColZK1) > 0
				SF1->F1_P1VENC   := aColZK1[1][2]
			endif
			SF1->( MsUnLock() )

			For n1 := 1 to len(aParcsOld)
				ZK1->( dbGoTo( aParcsOld[n1] ) )
				RecLock("ZK1",.F.)
				ZK1->( dbDelete() )
				ZK1->( MsUnLock())
			Next n1

			For n1 := 1 to len(aColZK1)
				ZK1->( dbSetOrder(1) )
				ZK1->( dbSeek( cSeek + aColZK1[n1][1] ) )

				RecLock("ZK1", !ZK1->(Found()))
				ZK1->ZK1_FILIAL := xFilial("ZK1")
				ZK1->ZK1_CHAVE  := SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)
				ZK1->ZK1_PARC   := aColZK1[n1][1]
				ZK1->ZK1_VENC   := aColZK1[n1][2]
				ZK1->ZK1_VALOR  := aColZK1[n1][3]
				//ZK1->ZK1_USER   := aColZK1[n1][4]
				ZK1->( MsUnLock())
			Next n1

		Else
			if !lData
				MsgAlert( 'Data das parcelas não podem ser menor que a data base do sistema!')

			Else
				//Retirado esta validacao pois o valor das parcelas podem vir com imposto imbutido.
				/*MsgAlert( 'Problema: Total digitado nos itens não confere com valor total da NF.' + CRLF + CRLF +;
			         	   'Nota:     ' + cValToChar(nTotalNF) + CRLF +;
			         	   'Digitado: ' + cValToChar(nValTotal) + CRLF + CRLF +;
			         	   'Solução:  Verifique o valor digitado. ', 'TOTVS' )*/
			EndIF

			M140CondInfo()
		EndIF
	EndIF

	aCols := aSaveGrid[1]
	aHeader := aSaveGrid[2]

Return

/*/{Protheus.doc} AtualizaParcelas
(long_description)
@author Rei
@since 16/03/2016
@version 1.0
@param cCondicao, character, (Descrição do parâmetro)
@param oGrid, objeto, (Descrição do parâmetro)
@param aParcsOld, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function AtualizaParcelas(cCondicao, oGrid, aParcsOld)

	Local nValTotal 	:= A140Total[3] //VALTOTNF()
	Local aParcelas 	:= Condicao(nValTotal, cCondicao,,dDatabase)
	Local n1
	Local n2
	Local cParcela 	:= IIF(Len(aParcelas)>1,SuperGetMV("MV_1DUP")," ")

	//Local nValTotal 	:= ALLTRIM(STR(u_VALTOTNF() * 10,14,2)) //Valor Total do Pedido (Nota-se a140Total[2] e a140Total[3]) //STR para vir com pontos
	Local nZK1_PARC  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZK1_PARC"} ) //Pega a posicao do campo
	Local nZK1_VENC  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZK1_VENC"} ) //Pega a posicao do campo
	Local nZK1_VALOR 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZK1_VALOR"} ) //Pega a posicao do campo

	For n1 := 1 to len(aCols)
		IF GDFieldGet('ZK1_REC_WT',n1) != 0
			aAdd(aParcsOld,GDFieldGet('ZK1_REC_WT',n1))
		EndiF
	Next n1
	aCols := {}

	For n1 := 1 to len(aParcelas)
		aAdd( aCols, Array(len(aHeader)+1) )
		For n2 := 1 To Len(aHeader)
			IF IsHeadRec(aHeader[n2][2])
				aCols[len(aCols)][n2] := 0
			ElseIF IsHeadAlias(aHeader[n2][2])
				aCols[len(aCols)][n2] := "ZK1"
			Else
				aCols[len(aCols)][n2] := CriaVar(aHeader[n2,2],.F.)
			EndIF
		Next n2

		aCols[len(aCols)][len(aHeader)+1] := .F.

		aCols[n1][nZK1_PARC]  := cParcela //posicao 1
		aCols[n1][nZK1_VENC]  := aParcelas[n1][1]	//posicao 2
		aCols[n1][nZK1_VALOR] := aParcelas[n1][2] //ALLTRIM(TransForm(aParcelas[n1][2],"@E 999,999.99"))
		//aCols[n1][4]  		 := cUserName //posicao 4

		cParcela := MaParcela(cParcela)
	Next n1

	oGrid:aCols := aCols
	oGrid:Refresh()


Return .T.

/*/{Protheus.doc} MT140LOK
(MT140LOK - Valida informações no pré-documento de entrada)
@author Rei
@since 26/10/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function MT140LOK()

	Local lRet	:= ParamIXB[1] // Retorna .T. se todos os dados estiverem OK

//Abre tabela SA2, seta ordem de busca, procura e posiciona no fornecedor
	SA2->(dbSelectArea("SA2"))
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2") + SF1->(CA100FOR + CLOJA ))) // CA100FOR = Fornecedor selecionado, CLOJA = Loja selecionada

//Verifica se Fornecedor esta atualizado pelo Fiscal (1= Sim, 2= Nao)
	If SA2->A2_XFORATU == "2"

		MsgAlert("Fornecedor desatualizado, não será possível salvar o documento!"+ CRLF + ;
			"Informe o departamento Fiscal.")
		lRet := .F. // Retorna falso nao permitindo salvar o documento.

	EndIf


Return lRet

/*/{Protheus.doc} VALTOTNF
(Funcao tem por objetivo retornar o valor total da NF com seus respectivos impostos/fretes etc)
@author Rei
@since 09/03/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function VALTOTNF()

	Local nValNF 	 := 0
	Local aAreaSF1 := GetArea("SF1")
	Local aAreaSD1 := GetArea("SD1")
	Local aAreaSC7 := GetArea("SC7")

	//Selecionando Tabelas
	dbSelectArea("SF1")
	SF1->(dbsetorder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	SF1->(dbgotop())

	dbSelectArea("SD1")
	SD1->(dbsetorder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	SD1->(dbgotop())

	dbSelectArea("SC7")
	SC7->(dbsetorder(1)) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
	SC7->(dbgotop())

	If SF1->(DbSeek( xFilial("SF1")+ CNFISCAL + CSERIE + CA100FOR + CLOJA + CTIPO))
		If SD1->(DbSeek( xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA )))
			If SC7->(DbSeek( xFilial("SC7")+ SD1->D1_PEDIDO))

				//Chave com Filial mais o numero do Pedido.
				cChave := SC7->(C7_FILIAL + C7_NUM)

				//Loop nos itens
				WHILE SC7->(C7_FILIAL + C7_NUM) = cChave

					//acrescento valor total dos itens
					//nValNF += SC7->(C7_TOTAL - C7_VLDESC + C7_SEGURO + C7_DESPESA + C7_VALFRE + C7_VALIPI)
					//SEM VALOR DOS IMPOSTOS
					nValNF += SC7->(C7_TOTAL - C7_VLDESC + C7_SEGURO + C7_DESPESA + C7_VALFRE)

					//pulo registro
					SC7->(dbskip())
				EndDo
			EndIf
		EndIf
	EndIf

	//Libero areas
	RestArea(aAreaSF1)
	RestArea(aAreaSD1)
	RestArea(aAreaSC7)

//Retorno valor total da NF com Impostos/frete etc
Return nValNF



/*/{Protheus.doc} MT140TOK
Ponto de entrada usado pra validação do Rateio do Projeto

@author Rafael Ricardo Vieceli
@since 17/11/2016
@version undefined

@type function
/*/
User Function MT140TOK()

	Local lRetorno := ParamIXB[1]
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



/*/{Protheus.doc} VldRatAFN
Função usada pra validação do Rateio do Projeto
chamada pelo PEs: MT140TOK (pre-nota), MT103TPC e MT103FIN (documento de entrada)

@author Rafael Ricardo Vieceli
@since 17/11/2016
@version undefined
@param nItem, numeric, descricao
@type function
/*/
User Function VldRatAFN(nItem)

	Local lRetorno := .T.
	Local nRateio, nLinhas
	Local nQuantidade := 0

	Local nDiferenca  := 0
	Local nAjuste     := val('0.' + strzero(1, tamSX3('AFN_QUANT')[2])) * -1
	Local nPercentual

	memowrite('C:\temp\',VarInfo('aRatAFN',aRatAFN,,.F.,.F.))

	//percorre os itens do rateio
	For nRateio := 1 To Len(aRatAFN)
		//para cada item da nota
		IF aRatAFN[nRateio][1] == aCols[nItem][GdFieldPos("D1_ITEM")]
			//e percore os itens rateados
			For nLinhas := 1 To Len(aRatAFN[nRateio][2])
				//se não estiver deletado
				IF ! aRatAFN[nRateio][2][nLinhas][Len(aRatAFN[nRateio][2][nLinhas])]
					//soma a quantidade rateada
					nQuantidade += aRatAFN[nRateio][2][nLinhas][3]
				EndIF
			Next nLinhas
		EndIF
	Next nRateio

	//Somente valida se tiver rateio de projeto
	IF Len(aRatAFN) > 0 .and. nQuantidade > 0 //.and. ALLTRIM(SC7->C7_ORIGEM) ="MSGEAI"
		IF aCols[nItem][GdFieldPos("D1_QUANT")] != nQuantidade
			IF Aviso('Rateio de Projeto',i18n(;
					"A quantidade informada no item: #1 é diferente da informada no rateio de projeto" + CRLF + ;
					"Quantidade no item: #2" + CRLF + ;
					"Quantidade no rateio do projeto: #3" + CRLF + CRLF + " Deseja ajustar manualmente ou ajustar a diferença automaticamente?", {aCols[nItem][GdFieldPos("D1_ITEM")], aCols[nItem,GdFieldPos("D1_QUANT")], nQuantidade}),{'Manualmente','Automatico'},2) == 1
				lRetorno := .F.
			Else

				//percorre os itens do rateio
				For nRateio := 1 To Len(aRatAFN)
					//para cada item da nota
					IF aRatAFN[nRateio][1] == aCols[nItem][GdFieldPos("D1_ITEM")]

						nPercentual := aCols[nItem,GdFieldPos("D1_QUANT")] / nQuantidade
						nQuantidade := 0

						//e percore os itens rateados
						For nLinhas := len(aRatAFN[nRateio][2]) to 1 step -1
							//se não estiver deletado
							IF ! aRatAFN[nRateio][2][nLinhas][Len(aRatAFN[nRateio][2][nLinhas])] .And. aRatAFN[nRateio][2][nLinhas][3] != 0

								//soma a quantidade rateada
								aRatAFN[nRateio][2][nLinhas][3] := round( aRatAFN[nRateio][2][nLinhas][3] * nPercentual, tamSX3('AFN_QUANT')[2])
								nQuantidade += aRatAFN[nRateio][2][nLinhas][3]

							EndIF
						Next nLinhas

						//pega a diferença.... quantidade AFN menos quantidade ITEM
						nDiferenca := (nQuantidade - aCols[nItem,GdFieldPos("D1_QUANT")])
						IF nDiferenca < 0
							nAjuste *= -1
						EndIF

						While nDiferenca != 0
							//e percore os itens rateados
							For nLinhas := len(aRatAFN[nRateio][2]) to 1 step -1
								//se não estiver deletado
								IF ! aRatAFN[nRateio][2][nLinhas][Len(aRatAFN[nRateio][2][nLinhas])] .And. aRatAFN[nRateio][2][nLinhas][3] != 0

									//soma a quantidade rateada
									aRatAFN[nRateio][2][nLinhas][3] += nAjuste
									nDiferenca += nAjuste

									IF nDiferenca == 0
										exit
									EndIF
								EndIF
							Next nLinhas
						EndDO

					EndIF
				Next nRateio
			EndIF
		EndIF
	EndIF

Return lRetorno


/*/{Protheus.doc} MT140SAI
LOCALIZAÇÃO : Function A140NFiscal() - Responsável por controlar a interface de um pre-documento de entrada.
EM QUE PONTO : Ponto de entrada disparado antes do retorno da rotina ao browse.
Dessa forma, a tabela SF1 pode ser reposicionada antes do retorno ao browse.
@type function
@author Mario L. B. Faria
@since 15/10/2022
/*/
User Function MT140SAI()

	Local cTipo	:= ParamIxb[06]
	Local nOk	:= ParamIxb[07]		//1 == Ok | 0 == Cancela

	//Verifica Itens Reservados 
	If nOk == 1
		If  cTipo == "N"
			If U_AEST101X()
				FwMsgRun(, { || U_AEST101A(ParamIxb) }, "Aguarde...", "Processando Etiquetas...")
			EndIf

			//Inclusão
			If ParamIxb[01] = 3
				//Verifica parametro de filiais para execução
				If U_AEST101F()

					cConfFis := ''

					BeginSQL Alias "TMPSA2"
						SELECT A2_CONFFIS
						  FROM %Table:SA2% SA2
						 WHERE SA2.A2_FILIAL = %xFilial:SA2%
						   AND SA2.A2_COD    = %Exp:SF1->F1_FORNECE%
						   AND SA2.A2_LOJA   = %Exp:SF1->F1_LOJA%
						   AND SA2.%NotDel%
					EndSQL

					If ! TMPSA2->(Eof())
						cConfFis := TMPSA2->A2_CONFFIS
					EndIf

					TMPSA2->(DBCLOSEAREA())

					If cConfFis = '1'
						//Em Conferencia
						RecLock("SF1",.F.)
						SF1->F1_STATCON := "0"
						SF1->(MsUnlock())
					ElseIf cConfFis = '0' .Or. cConfFis = '3'
						//Conferido
						RecLock("SF1",.F.)
						SF1->F1_STATCON := "1"
						SF1->(MsUnlock())
					EndIf
				Else
					//Conferido
					RecLock("SF1",.F.)
					SF1->F1_STATCON := "1"
					SF1->(MsUnlock())
				EndIf
			EndIf

		EndIf

		If  cTipo == "D"
			If U_AEST101X() 
				//AJusta status de conferencia
				RecLock("SF1",.F.)
				SF1->F1_STATCON := "0"
				SF1->(MsUnlock())			
			EndIf
		EndIf

	EndIf

Return
