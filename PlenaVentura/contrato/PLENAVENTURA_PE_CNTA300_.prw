#include 'protheus.ch'
#INCLUDE 'TOPCONN.CH'
#include 'tbiconn.ch'
#include 'fwmvcdef.ch'


/*/{Protheus.doc} MATA300
Ponto de entrada MVC para rotina de Manutenção de Contratos

@author Rafael Ricardo Vieceli
@since 18/11/2015
@version 1.0
@return xRetorno, undefined, Retorno conforme o fonte do MVC
@see http://tdn.totvs.com/display/public/mp/Pontos+de+Entrada+para+fontes+Advpl+desenvolvidos+utilizando+o+conceito+MVC;jsessionid=CDDA42241C748D6E57EE66DA81EC99A5
/*/
User Function CNTA300()

	//Objeto do formulário ou do modelo, conforme o caso.
	Local oModel  //ParamIXB[1]
	//ID do local de execução do ponto de entrada
	Local cIdPonto //ParamIXB[2]
	//ID do formulário
	Local cIdModel //ParamIXB[3]

	Local xRetorno := .T.

	IF ! Empty(ParamIXB)

		oModel   := ParamIXB[1]
		cIdPonto := ParamIXB[2]
		cIdModel := ParamIXB[3]

/*
		ConOut(Time() + " >>>>>> " +cIdPonto + " -> " + cIdModel + ;
			IIF(len(ParamIXB)>3," -> " + AllToChar(ParamIXB[4]),"") + ;
			IIF(len(ParamIXB)>4," -> " + AllToChar(ParamIXB[5]),"") + ;
			IIF(len(ParamIXB)>5," -> " + AllToChar(ParamIXB[6]),"") + ;
			IIF(len(ParamIXB)>6," -> " + AllToChar(ParamIXB[7]),"") + ;
			IIF(len(ParamIXB)>7," -> " + AllToChar(ParamIXB[8]),""))
*/

		IF cIdPonto == "MODELVLDACTIVE"
			//após preenchimento do produto, puxa centro de custo
			oModel:GetModel('CNBDETAIL'):GetStruct():AddTrigger('CNB_PRODUT','CNB_CC',{|| .T.}, {|oModel| M->CN9_CC }, "")
			//após auto preecimento da data prevista de medição, atualiza data prevista para vencimento
			oModel:GetModel('CNFDETAIL'):GetStruct():AddTrigger('CNF_PRUMED','CNF_DTVENC',{|| .T.}, {|oModel| CNFDtVenc(oModel) }, "")

			//Apenas para venda
			IF CNTGetFun() == "CNTA301"
				//gatilho sem retorno, tudo acontece na validação do gatilho
				oModel:GetModel('CNCDETAIL'):GetStruct():AddTrigger('CNC_CLIENT','CNC_CLIENT',{|o| PreencheVendedor(o) }, {|| }, "")
			EndIF
		ElseIF cIdPonto $ "MODELCANCEL#MODELCOMMITNTTS"
			//Apenas para venda
			IF CNTGetFun() == "CNTA301"
				UnLockByName(cEmpAnt+cFilAnt+Alltrim(M->CN9_NUMERO),.T.,.T.,.T.)
			EndIF

			IF cIdPonto == "MODELCOMMITNTTS"
				//se veio da rotina de aprovação de revisão
				IF IsInCallStack("CN300Aprov")
					//envia e-mail de retorno
					u_MailC100(.T.)
				EndIF

				// Valida se é Contrato de Compras
				If FwFldGet("CN9_ESPCTR") == '1' 
					// Realizada a integração com o Fluig
					IniciarFluig(FwFldGet("CN9_NUMERO"), FwFldGet("CN9_REVISA"), FwFldGet("CN9_SITUAC"))

				EndIf

			EndIF

		ElseIF cIdPonto == "FORMPRE"
			//nos itens da planilhas
			IF cIdModel == "CNBDETAIL"
				//na alteração de campo
				IF ParamIXB[5] == "SETVALUE"
					//campo quandidade
					IF ParamIXB[6] == "CNB_QUANT"
						//se for revisão
						IF IsInCallStack("CN300Rev")
							xRetorno := ValidaSubstituicao(oModel)
						EndIF
					EndIF
				EndIF
			EndIF

		ElseIF cIdPonto == "FORMPOS"
			//na validaçaõ do cabeçalho
			IF cIdModel == "CN9MASTER"
				//se veio da rotina de aprovação de revisão
				IF IsInCallStack("CN300Aprov")
					xRetorno := RevValidaAtivo()

					//envia e-mail de retorno
					u_MailC100(.T.)
				EndIF
			EndIF
		//após gravar
		ElseIF cIdPonto == 'MODELCOMMITTTS'
			//correção erro release 12.1.33. Leoberto/SMS
			If !IsInCallStack("CN100CANCE")
			//se o campo CN9_NOMCLI (nome do cliente) existir na CN9
			IF CN9->(FieldPos("CN9_NOMCLI")) != 0
				//grava o codigo/loja nome do cliente no contrato
				RecLock("CN9",.F.)
				CN9->CN9_NOMCLI := oModel:GetModel("CNCDETAIL"):GetValue("CNC_CLIENT")+"/"+;
				                   oModel:GetModel("CNCDETAIL"):GetValue("CNC_LOJACL")+" "+;
				                   oModel:GetModel("CNCDETAIL"):GetValue("CNC_NOMECL")
				CN9->( MsUnLock())
			EndIF
			Endif

		ElseIF cIdPonto == "BUTTONBAR"
			xRetorno := {}
			If cIdModel = "CNTA300" .and. IsInCallStack("CN300Rev")
				aadd(xRetorno, {'Alterar Vencimento Cronograma', 'Alterar Vencimento', { || u_fAltVCNF(FWModelActive()) }, 'Alterar Vencimento' }) 
			Endif
		Endif

	EndIF

Return xRetorno


Static Function PreencheVendedor(oModelCliente)

	Local oModel := FWModelActive()
	Local oModelVendedor := oModel:GetModel("CNUDETAIL")
	Local n1 := 0

	Local lNaoTem := .T.

	//se cliente e loja forem preenchidos
	IF ! Empty(FWFldGet("CNC_CLIENT")) .And. ! Empty(FWFldGet("CNC_LOJACL"))
		//percorre as linhas do vendedor
		For n1 := 1 to oModelVendedor:Length()
			oModelVendedor:GoLine(n1)
			//se a linha não estiver deletada
			IF ! oModelVendedor:IsDeleted()
				lNaoTem := .F.

				//posiciona no cliente
				SA1->( dbSetOrder(1) )
				SA1->( dbSeek( xFilial("SA1") + FWFldGet("CNC_CLIENT") + FWFldGet("CNC_LOJACL") ) )

				IF ! Empty(SA1->A1_VEND)
					//e se
					IF Empty(FWFldGet("CNU_CODVD", n1))
						oModelVendedor:SetValue("CNU_CODVD" , SA1->A1_VEND)
						oModelVendedor:SetValue("CNU_PERCCM", IIF(SA1->A1_COMIS==0,1,SA1->A1_COMIS))
					ElseIF FWFldGet("CNU_CODVD", n1) != SA1->A1_VEND
						IF Aviso("Vendedor", "O vendedor padrão do cliente é diferente do informado no contrato, deseja atualizar?", {"Sim","Não"}, 1) == 1
							oModelVendedor:SetValue("CNU_CODVD" , SA1->A1_VEND)
							oModelVendedor:SetValue("CNU_PERCCM", IIF(SA1->A1_COMIS==0,1,SA1->A1_COMIS))
						EndIF
					EndIF
				Else
					Aviso("Vendedor", "O cliente informado não possui vendedor padrão, informa o vendedor manualmente", {"Sair"}, 1)
				EndIF
			EndIF
		Next n1 := 1
	EndIF

	IF lNaoTem

		//posiciona no cliente
		SA1->( dbSetOrder(1) )
		SA1->( dbSeek( xFilial("SA1") + FWFldGet("CNC_CLIENT") + FWFldGet("CNC_LOJACL") ) )

		IF ! Empty(SA1->A1_VEND)
			n1 := oModelVendedor:Length()
			IF oModelVendedor:AddLine() > n1
				oModelVendedor:SetValue("CNU_CODVD" , SA1->A1_VEND)
				oModelVendedor:SetValue("CNU_PERCCM", IIF(SA1->A1_COMIS==0,1,SA1->A1_COMIS))
			EndIF
		EndIF
	EndIF

Return .F.


Static Function ValidaSubstituicao(oModel)

	Local lPermite := .T.

	IF int(FwFldGet("CNB_QUANT")) < int(FwFldGet("CNB_QTDMED"))
		Help('',1,'BRASLIFT-SUBST',,'Não é permitido colocar uma quantidade menor que a quantidade já medida',4)
		lPermite := .F.
	ElseIF FwFldGet("CNB_SUBST") != "S" .And. int(FwFldGet("CNB_QUANT")) == int(FwFldGet("CNB_QTDMED"))
		IF Aviso("Substituição", "Você está substituindo ou retirando o equipamento do contrato?", {"Sim", "Não"}, 1) == 1
			IF oModel:GetValue("CNB_SUBST") != "S"
				oModel:LoadValue("CNB_OFICIN","")
			EndIF
			oModel:LoadValue("CNB_SUBST","S")
		EndIF
	ElseIF FwFldGet("CNB_SUBST") == "S" .And. int(FwFldGet("CNB_QUANT")) > int(FwFldGet("CNB_QTDMED"))
		IF Aviso("Substituição", "Você está reativando o equipamento no contrato?", {"Sim", "Não"}, 1) == 1
			IF oModel:GetValue("CNB_SUBST") != "S"
				oModel:LoadValue("CNB_OFICIN","")
			EndIF
			oModel:LoadValue("CNB_SUBST","N")
		EndIF
	EndIF

Return lPermite


/*/{Protheus.doc} CN9CCValid
Função para atualizar os itens das planilhas com o centro de custo do cabeçalho

@author Rafael Ricardo Viecei
@since 19/11/2015
@version 1.0
@return true, retorno para validação
/*/
User Function CN9CCValid()

	Local nPlan
	Local nItens

	Local oModel    := FWModelActive()

	Local oModelCNA := oModel:GetModel("CNADETAIL")
	Local oModelCNB := oModel:GetModel("CNBDETAIL")

	Local aSaveLines	:= FWSaveRows()

	For nPlan := 1 to oModelCNA:Length()
		oModelCNA:GoLine(nPlan)

		For nItens := 1 to oModelCNB:Length()
			oModelCNB:GoLine(nItens)
			oModelCNB:SetValue('CNB_CC', FwFldGet("CN9_CC") )
		Next nItens
	Next nPlan

	FWRestRows(aSaveLines)

Return .T.



/*/{Protheus.doc} CNBProdutValid
Validação no produto da planilha para não deixar repetir quando for de ativo

@author Rafael Ricardo Vieceli
@since 23/11/2015
@version 1.0
@param cProduto, character, Codigo do produto para validação
@param lAvisa, lógico, aviso ou trava
@return lValid, lógico, se o produção é valido
/*/
User Function CNBProdutValid(cProduto, cThis, lAvisa, cRevisao)

	Local lValido := .T.
	Local cAlias := GetNextAlias()

	Local cWhereRevisa := "%%"

	Local lEncontrou := .F.

	default lAvisa := .T.


	IF lAvisa
		cThis := FwFldGet("CN9_NUMERO")+FwFldGet("CNA_NUMERO")+FwFldGet("CNB_ITEM")
	EndIF

	//isso é para quando for REVISÃO, para desconsiderar a revisão antiga vigente
	IF ! Empty(cRevisao)
		cWhereRevisa := "%(CNB.CNB_CONTRA <> '" + PadR(cThis,15) + "' or CNB.CNB_REVISA = '" + cRevisao + "') and%"
	EndIF

	SB1->( dbSetOrder(1) )
	SB1->( dbSeek( xFilial("SB1") + cProduto ) )

	IF SB1->( Found() ) .And. ! Empty(SB1->B1_GRUPO) .And. alltrim(SB1->B1_GRUPO) $ GetMV("PN_GRPATF",,"")

		SN1->( dbSetOrder(1) )
		SN1->( dbSeek( xFilial("SN1") + PadR(cProduto, TamSX3("N1_CBASE")[1]) ) )

		While !SN1->( Eof() ) .And. SN1->(N1_FILIAL+N1_CBASE) == xFilial("SN1") + PadR(cProduto,TamSX3("N1_CBASE")[1]) .And. ! lEncontrou

			IF SN1->N1_STATUS <> '4'

				lEncontrou := .T.

				SN3->( dbSetOrder(1) )
				SN3->( dbSeek( xFilial("SN3") + SN1->(N1_CBASE+N1_ITEM) ) )

				//não baixado
				IF SN3->N3_BAIXA == '0'

					BeginSQL Alias cAlias
						%noparser%

						select CN9_NUMERO, CN9_REVISA, CN9_SITUAC, CNB_ITEM
						from %table:CNB% CNB

							inner join %table:CN9% CN9
							on  CN9.CN9_FILIAL = %xFilial:CN9%
							and CN9.CN9_NUMERO = CNB.CNB_CONTRA
							and CN9.CN9_REVISA = CNB.CNB_REVISA
							and CN9.CN9_SITUAC in ('02','03','04','05','07')
							and CN9.D_E_L_E_T_ = ' '

						where
						    CNB.CNB_FILIAL = %xFilial:CNB%
						and CNB.CNB_PRODUT = %Exp: cProduto %
						and concat(concat(CN9_NUMERO,CNB_NUMERO),CNB.CNB_ITEM) <> %exp: cThis %
						and %Exp: cWhereRevisa %
						    CNB.CNB_SUBST <> 'S'
						and CNB.CNB_ITMDST = '   '
						and CNB.D_E_L_E_T_ = ' '
					EndSQL

					IF ! (cAlias)->( Eof() )
					 	Help('',1,'BRASLIFT-ATIVO ' + cThis,,'Produto '+alltrim(cProduto)+' está vinculado ao contrato '+alltrim((cAlias)->CN9_NUMERO)+'revisao: ' +alltrim((cAlias)->CN9_REVISA)+' item '+(cAlias)->CNB_ITEM+'.',4)
						//IF ! lAvisa Tiago Santos
							// sistema não estava gerando a mensagem de falha na validação do produto 
							lValido := .F.
						//EndIF
					EndIF

					dbSelectArea(cAlias)
					dbCloseArea()

					Exit
				Else
				 	Help('',1,'BRASLIFT-ATIVO',,'Produto '+alltrim(cProduto)+' do bem Ativo/item '+alltrim(SN1->(N1_CBASE+N1_ITEM))+' está baixado, não poderá ser usado.',4)
					lValido := .F.
				EndIF
			EndIF

			SN1->( dbSkip() )
		EndDO

		IF ! lEncontrou .and. FwFldGet("CN9_ESPCTR") =='2'// venda 
		 	Help('',1,'BRASLIFT-ATIVO',,'Produto '+alltrim(cProduto)+' não está cadastrado no ativo.',4)
			lValido := .F.
		EndIF

	EndIF

Return lValido


/*/{Protheus.doc} CNFDtVenc
Atualiza data prevista de vencimento conforma data prevista de medição e condição de pagamento do contrato.

@author Rafael Ricardo Vieceli
@since 23/11/2015
@version 1.0
@param oModel, objeto, Modelo MVC
@return dVenciento, date, nova data prevista para vencimento
/*/
Static Function CNFDtVenc(oModel)

	Local aCondicao := {}
	Local dVencimento := FwFldGet("CNF_DTVENC")

	IF ! Empty(M->CN9_CONDPG)

		IF IsInCallStack("CN300MkCrg") .Or. Aviso("Atenção","Deseja atualizar a data de vencimento conforme a nova data prevista para medição?",{"Sobrepor","Manter"},1) == 1
			aCondicao := Condicao(FwFldGet("CNF_VLPREV"),M->CN9_CONDPG,,M->CNF_PRUMED)

			IF len(aCondicao) != 0 .And. ! Empty(aCondicao[1][1])
				dVencimento := aCondicao[1][1]
			EndIF
		EndIF
	EndIF

Return dVencimento


/*/{Protheus.doc} CN9NumIniPad
Inicializador padrão para o campo CN9_NUMERO na empresa Braslift
Para contrato de venda, pegar Ano + sequencial (9 digitos) dentro do ano. 2015000000001.
Para contrato de compra continua pelo padrão

Atenção: para não pegar o mesmo numero, uso semaforo, travando aqui e destravando no PE MVC CNTA300.

@author Rafael Ricardo Vieceli
@since 26/11/2015
@version 1.0
@return ${return}, ${return_description}
/*/
User Function CN9NumIniPad()

	Local cAno     := cValToChar(Year(dDataBase))
	Local cProximo := cAno + PadL("1",6,"0")

	Local aArea := GetArea("CN9")

	//Apenas para venda
	IF CNTGetFun() == "CNTA301" .And. ! IsInCallStack("CN300Rev")

		CN9->( dbSetOrder(1) )
		//posiciona no registro após o ultimo
		CN9->( dbSeek( xFilial("CN9") + PadR(cAno, 6, "Z"), .T.  ) )
		//depois volta pro ultimo
		CN9->( dbSkip(-1) )

		//quase igual
		//compara se o inicio do conteudo do campo (2015000000001) é igual ao ano (2015)
		//exemplo: no SQL usando like 'H%'
		IF CN9->CN9_NUMERO = cAno
			cProximo := Soma1(alltrim(CN9->CN9_NUMERO))
		EndIF

		//reserva o numero (empresa+filial+numero) para outro usuario não pegar o mesmo numero e dar erro
		While !LockByName(cEmpAnt+cFilAnt+cProximo,.T.,.T.,.T.)
			//enquanto não conseguir reservar, vai pegando o proximo
			cProximo := Soma1(cProximo)
		EndDO

	Else
		//para Compras, faz pelo SXE
		cProximo := GetSXENum("CN9","CN9_NUMERO")
	EndIF

	RestArea(aArea)

Return cProximo


Static Function RevValidaAtivo()

	Local lRetorno := .T.

	//posiciona na planilha
	CNA->( dbSetOrder(1) )
	CNA->( dbSeek( xFilial("CNA") + CN9->(CN9_NUMERO+CN9_REVISA) ) )

	//e percorre todas do contrato
	While ! CNA->( Eof() ) .And. CNA->(CNA_FILIAL+CNA_CONTRA+CNA_REVISA) == xFilial("CNA") + CN9->(CN9_NUMERO+CN9_REVISA)

		//prosiciona no primeiro item da planilha
		CNB->( dbSetOrder(1) )
		CNB->( dbSeek( xFilial("CNB") + CNA->(CNA_CONTRA+CNA_REVISA+CNA_NUMERO) ) )

		//e percorre todos os itens da planilha
		While ! CNB->( Eof() ) .And. CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO) == xFilial("CNB") + CNA->(CNA_CONTRA+CNA_REVISA+CNA_NUMERO)
			//se o produto estiver ativo (não substituido ou revisado) e se estiver em outro contrato
			IF u_CNBAtivo() .And. ! u_CNBProdutValid(CNB->CNB_PRODUT,CN9->CN9_NUMERO+CNB->(CNB_NUMERO+CNB_ITEM),.F.,CN9->CN9_REVISA)
				lRetorno := .F.
			EndIF

			CNB->( dbSkip() )
		EndDO

		CNA->( dbSkip() )
	EndDO


Return lRetorno



User Function CNBAtivo(cAliasCNB)

	default cAliasCNB := "CNB"

Return (cAliasCNB)->CNB_SUBST != 'S' .And. (cAliasCNB)->CNB_ITMDST == '   '


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦  fAltVCNF ¦ Autor ¦ Lucilene Mendes       ¦ Data ¦12.03.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Ajusta o vencimento das parcelas do cronograma financeiro ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/ 
User Function fAltVCNF(oModel)

Local oModel := FWModelActive()
Local oModelCNF := oModel:GetModel("CNFDETAIL")
Local oModelCNA := oModel:GetModel("CNADETAIL")
Local oModelCNV := oModel:GetModel("CNVDETAIL")
Local oModelCCNF:= oModel:GetModel("CALC_CNF")
Local aPropCNF	:= GetPropMdl(oModelCNF)
Local aSaveLines:= FWSaveRows(oModel)
Local aPergs 	:= {}
Local aRetaRet 		:= {}
Local aNewParc 	:= {}
Local aRealizado:= {} 
Local cNumCronog:= ""
Local nMontante	:= 0
Local nSaldoAnt	:= 0
Local n1 := 0
Local nVlrPlan	:= oModelCNA:GetValue("CNA_VLTOT")
Local nSldPlan	:= oModelCNA:GetValue("CNA_SALDO")
Local nSldDist	:= oModelCNA:GetValue("CNA_SADIST")
Local i	:= 0
Local y	:= 0

For n1 := 1 to oModelCNF:Length()
	oModelCNF:GoLine(n1)
	//salva as linhas realizado
	IF !oModelCNF:IsDeleted() .and. FWFldGet("CNF_VLREAL", n1) > 0
		aLinha:= {}
		For i:=1 to Len(oModelCNF:aHeader)
			aAdd(aLinha,FwFldGet(oModelCNF:aHeader[i,2],n1))
		Next
		aAdd(aRealizado,aLinha)
		If FWFldGet("CNF_SALDO", n1) > 0
			nSaldoAnt+= FWFldGet("CNF_SALDO", n1)
		Endif
	Endif
	
	//Armazena número do cronograma para atualizar depois nas novas parcelas
	If Empty(cNumCronog)
		cNumCronog:= FwFldGet("CNF_NUMERO")
	Endif

	oModelCNF:DeleteLine(,.T.)

Next	

//Altera o valor para calcular sobre o saldo da planilha
oModelCNA:GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.T.})
oModelCNA:GetStruct():SetProperty('CNA_SADIST',MODEL_FIELD_WHEN,{||.T.})
oModelCNA:SetValue("CNA_VLTOT",oModelCNA:GetValue("CNA_SALDO") - nSaldoAnt)

//Salva o valor do montante do cronograma
nMontante:= oModelCCNF:GetValue('CNF_CALC')


If !CN300AddCrg()
	FWRestRows(aSaveLines)

	//Recupera as linhas deletadas
	For n1 := 1 to oModelCNF:Length()
		oModelCNF:GoLine(n1)
		oModelCNF:UnDeleteLine()
	Next

	//Rtorna o valor original da planilha
	oModelCNA:SetValue("CNA_VLTOT",nVlrPlan)
	oModelCNA:SetValue("CNA_SALDO",nSldPlan)
	oModelCNA:SetValue("CNA_SADIST",nSldDist)
	oModelCNA:GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.F.})
	oModelCNA:GetStruct():SetProperty('CNA_SADIST',MODEL_FIELD_WHEN,{||.F.})
	
	Return
Endif	

//Rtorna o valor original da planilha
oModelCNA:SetValue("CNA_VLTOT",nVlrPlan)
oModelCNA:SetValue("CNA_SALDO",nSldPlan)

//Salva as novas parcelas
For n1 := 1 to oModelCNF:Length()
	oModelCNF:GoLine(n1)
	//salva as linhas sem saldo
	If !oModelCNF:IsDeleted()
		aLinha:= {}
		For i:=1 to Len(oModelCNF:aHeader)
			aAdd(aLinha,FwFldGet(oModelCNF:aHeader[i,2],n1))
		Next
		aAdd(aRealizado,aLinha)
	Endif
	oModelCNF:DeleteLine(.T.,.T.)
Next

//Libera a inclusão de nova linha
oModelCNF:SetNoInsertLine(.F.)

//Limpa o grid
CNTA300DlMd(oModelCNF,"CNF_PARCEL")
//oModelCNF:ClearData(.F., .F.)  

//Cria o grid com as parcelas realizadas + novas
For y:= 1 to Len(aRealizado)
	If y > 1 //Grid com 1ª linha em branco
		oModelCNF:AddLine()
	Endif	
	
	For i:=1 to Len(oModelCNF:aHeader)
		//Libera o campo para edição
		oModelCNF:GetStruct():SetProperty(oModelCNF:aHeader[i,2],MODEL_FIELD_WHEN,{||.T.})

		If oModelCNF:aHeader[i,2] == "CNF_PARCEL"
			oModelCNF:LoadValue(oModelCNF:aHeader[i,2],StrZero(y,2))
		Elseif oModelCNF:aHeader[i,2] == "CNF_NUMERO"
			oModelCNF:LoadValue(oModelCNF:aHeader[i,2],cNumCronog)
		Else
			oModelCNF:LoadValue(oModelCNF:aHeader[i,2],aRealizado[y,i])
		Endif
	Next
Next

oModelCNA:SetValue("CNA_SADIST",nSldDist)
oModelCNA:GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.F.})
oModelCNA:GetStruct():SetProperty('CNA_SADIST',MODEL_FIELD_WHEN,{||.F.})

//Bloqueia a inclusão de nova linha
oModelCNF:SetNoInsertLine(.T.)

//Atualiza o montante do cronograma
oModelCCNF:LoadValue('CNF_CALC',nMontante)

Return



/*
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++-----------------------------------------------------------------------------++
++ Função    | MT120FIM | Autor  | Anderson Jose Zelenski  | Data | 20/01/2022 ++
++-----------------------------------------------------------------------------++
++ Descrição | Iniciar a solicitação no Fluig                                  ++
++-----------------------------------------------------------------------------++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/


Static Function IniciarFluig(cContrato, cRevisao, cSituacao)

Local lRet		:= .T.

Local aCardBase	:= {}
Local aCardData	:= {}
Local cQryTracke:= ""
Local cQryItens := ""
Local aRecnoSCR := {}

Local cItemAprov := '0'
Local nItemAprov := 0
Local cItem 	:= '0'
Local nItem 	:= 0
Local cUserComp := ""
Local cVigencia	:= ""

// Em Aprovação
If cSituacao == "04"
	// Localiza o Contrato
	CN9->(DbSetOrder(1))
	CN9->(DbSeek(xFilial("CN9")+cContrato+cRevisao))

	// Localiza o Tipo do Contrato
	CN1->(DbSetOrder(1)) 
	CN1->(DbSeek(xFilial("CN1")+CN9->CN9_TPCTO+CN9->CN9_ESPCTR))

	// Valida se possui grupo de aprovação no Tipo do Contrato
	If !Empty(CN1->CN1_GRPSIT)

		// Localiza a Planilha
		CNA->(DbSetOrder(3)) // CNA_FILIAL+CNA_CONTRA+CNA_REVISA
		CNA->(DbSeek(xFilial("CNA")+cContrato+cRevisao))
		
		// Localiza o Fornecedor
		SA2->(DbSetOrder(1))
		SA2->(DbSeek(xFilial("SA2")+CNA->CNA_FORNEC+CNA->CNA_LJFORN))

		aAdd(aCardBase,{'txtEmpresa',Alltrim(FWEmpName(FWGrpCompany()))})
		aAdd(aCardBase,{'txtEmpresaCodigo',FWGrpCompany()})
		aAdd(aCardBase,{'txtFilial',Alltrim(FWFilialName())})
		aAdd(aCardBase,{'txtFilialCodigo',FWCodFil()})

		aAdd(aCardBase,{'txtContratoTipo', CN1->CN1_DESCRI})
		aAdd(aCardBase,{'txtContratoNumero', AllTrim(CN9->CN9_NUMERO)})
		aAdd(aCardBase,{'txtContratoRevisao', AllTrim(CN9->CN9_REVISA)})
		aAdd(aCardBase,{'txtContratoValor', Alltrim(Transform(CN9->CN9_VLATU,PesqPict('CN9','CN9_VLATU')))})
		
		If CN9->CN9_UNVIGE == '1' // Dias
			cVigencia := cValToChar(CN9->CN9_VIGE)+" Dias"
		ElseIf CN9->CN9_UNVIGE == '2' // Meses
			cVigencia := cValToChar(CN9->CN9_VIGE)+" Meses"
		ElseIf CN9->CN9_UNVIGE == '3' // Anos
			cVigencia := cValToChar(CN9->CN9_VIGE)+" Anos"
		ElseIf CN9->CN9_UNVIGE == '4' // Indeterminada
			cVigencia := "Indeterminada"
		EndIf

		aAdd(aCardBase,{'txtVigencia', cVigencia })
		
		aAdd(aCardBase,{'txtDataInicial', " "+DtoC(CN9->CN9_DTINIC)})
		aAdd(aCardBase,{'txtDataFinal', " "+DtoC(CN9->CN9_DTFIM)})
		
		aAdd(aCardBase,{'txtFornCodigo', Alltrim(SA2->A2_COD)})
		aAdd(aCardBase,{'txtFornLoja', Alltrim(SA2->A2_LOJA)})
		aAdd(aCardBase,{'txtFornecedorNome', Alltrim(SA2->A2_NOME)})
		aAdd(aCardBase,{'txtFornRazaoSocial', Alltrim(SA2->A2_NOME)})
		aAdd(aCardBase,{'txtCNPJ', Alltrim(Transform(SA2->A2_CGC,PesqPict('SA2','A2_CGC')))})
		
		aAdd(aCardBase,{'txtEndereco', Alltrim(SA2->A2_END)})
		aAdd(aCardBase,{'txtCEP', Alltrim(Transform(SA2->A2_CEP,PesqPict('SA2','A2_CEP')))})
		aAdd(aCardBase,{'txtBairro', Alltrim(SA2->A2_BAIRRO)})
		aAdd(aCardBase,{'txtCidade', Alltrim(SA2->A2_MUN)})
		aAdd(aCardBase,{'txtUF', Alltrim(SA2->A2_EST)})
		
		aAdd(aCardBase,{'txtComplemento',Alltrim(SA2->A2_COMPLEM)})
		aAdd(aCardBase,{'txtInscMunicipal',Alltrim(SA2->A2_INSCRM)})
		aAdd(aCardBase,{'txtInscEstadual',Alltrim(SA2->A2_INSCR)})
		
		aAdd(aCardBase,{'txtContato', Alltrim(SA2->A2_CONTATO)})
		aAdd(aCardBase,{'txtEmailContato', Alltrim(SA2->A2_EMAIL)})
		aAdd(aCardBase,{'txtDDD', Alltrim(SA2->A2_DDD)})
		aAdd(aCardBase,{'txtTelefone', Alltrim(SA2->A2_TEL)})
		
		aAdd(aCardBase,{'txtCondicaoDescricao', Alltrim(Posicione("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_DESCRI"))})
		aAdd(aCardBase,{'contratoStatus', 'P'})

		cUserComp := GetLogFlg(Alltrim(RetCodUsr()))
		
		// Separa as alçadas por grupo de aprovação.
		cQryTracke := " SELECT CR_GRUPO AS GRUPO, CR_ITGRP AS ITEMGRP, CR_TIPO AS TIPO, DBL_CC AS CUSTO, CR_NIVEL AS NIVEL, CR_USER AS USUARIO, CR_APROV AS APROVADOR, AK_NOME AS NOME, AK_LOGIN AS LOGIN, CR_TOTAL AS TOTAL, SCR.R_E_C_N_O_ AS RECNOSCR"
		cQryTracke += " FROM "+RetSqlName("SCR")+" SCR "
		cQryTracke += "		LEFT JOIN "+RetSqlName("DBL")+" DBL ON DBL.DBL_FILIAL = '"+xFilial("DBL")+"' AND DBL_GRUPO = CR_GRUPO AND DBL.D_E_L_E_T_ = ' ' "
		cQryTracke += "		LEFT JOIN "+RetSqlName("SAK")+" SAK ON SAK.AK_FILIAL = '"+xFilial("SAK")+"' AND SAK.AK_COD = SCR.CR_APROV AND SAK.AK_USER = SCR.CR_USER AND SAK.D_E_L_E_T_ = ' ' "
		cQryTracke += " WHERE SCR.CR_FILIAL = '"+xFilial("SCR")+"' "
		cQryTracke += "		AND SCR.CR_NUM = '"+cContrato+cRevisao+"' "
		cQryTracke += "		AND SCR.CR_TIPO IN ('CT') "
		cQryTracke += " 	AND SCR.D_E_L_E_T_ = ' ' "
		cQryTracke += " UNION "
		cQryTracke += " SELECT CR_GRUPO AS GRUPO, CR_ITGRP AS ITEMGRP, CR_TIPO AS TIPO, DBL_CC AS CUSTO, CR_NIVEL AS NIVEL, CR_USER AS USUARIO, CR_APROV AS APROVADOR, AK_NOME AS NOME, AK_LOGIN AS LOGIN, CR_TOTAL AS TOTAL, SCR.R_E_C_N_O_ AS RECNOSCR"
		cQryTracke += " FROM "+RetSqlName("SCR")+" SCR "
		cQryTracke += "		LEFT JOIN "+RetSqlName("DBL")+" DBL ON DBL.DBL_FILIAL = '"+xFilial("DBL")+"' AND DBL_GRUPO = CR_GRUPO AND DBL_ITEM = CR_ITGRP AND DBL.D_E_L_E_T_ = ' ' "
		cQryTracke += "		LEFT JOIN "+RetSqlName("SAK")+" SAK ON SAK.AK_FILIAL = '"+xFilial("SAK")+"' AND SAK.AK_COD = SCR.CR_APROV AND SAK.AK_USER = SCR.CR_USER AND SAK.D_E_L_E_T_ = ' ' "
		cQryTracke += " WHERE SCR.CR_FILIAL = '"+xFilial("SCR")+"' "
		cQryTracke += "		AND SCR.CR_NUM = '"+cContrato+cRevisao+"' "
		cQryTracke += "		AND SCR.CR_TIPO IN ('CT') "
		cQryTracke += " 	AND SCR.D_E_L_E_T_ = ' ' "
		cQryTracke += " ORDER BY 1, 2, 5, 6  "

		//conout(cQryTracke)

		If Select('QRY') <> 0
			DbSelectArea('QRY')
			DbCloseArea()
		Endif

		TCQUERY cQryTracke NEW ALIAS "QRY"
		
		cGrpAprov 	:= ""
		cItemAprov 	:= '0'
		aRecnoSCR 	:= {}
		
		While !QRY->(Eof())
			// Valida 
			If cGrpAprov <> QRY->GRUPO+QRY->ITEMGRP
				// Valida se possui mais do que 1 grupo para gerar a solicitação
				If !Empty(cGrpAprov)
					// Salva o Numero de Itens do Contrato
					aAdd(aCardData,{'numItens', cItem})
					
					// Salva o Numero de Aprovadores
					aAdd(aCardData,{'aprovNum', cItemAprov})
					
					// Chama a função para gerar a solicitação no Fluig
					GeraFluig(aCardData, aRecnoSCR, cUserComp)
					
				EndIf
				
				// Salva o array base dos dados do Contrato
				aCardData := AClone(aCardBase)
				//aCardData := aCardBase
				aRecnoSCR := {}
				
				// Monta os itens do Contrato de acordo com o Centro de Custo
				cQryItens := " SELECT CNB_NUMERO AS PLANILHA, CNB_ITEM AS ITEM, CNB_PRODUT AS PRODUTO, CNB_DESCRI AS DESCRICAO, CNB_UM AS UM, "
				cQryItens += 	" CNF_PARCEL AS PARCELA, CNF_COMPET AS COMPETENCIA, CNF_DTVENC AS VENCIMENTO, CNF_VLPREV AS VALOR" 
				cQryItens += " FROM "+RetSqlName("CNB")+" CNB "
				cQryItens += "	INNER JOIN "+RetSqlName("CNF")+" CNF ON CNF.CNF_FILIAL = '"+xFilial("CNF")+"' AND CNF.CNF_CONTRA = CNB.CNB_CONTRA AND CNF.CNF_REVISA = CNB.CNB_REVISA AND CNF.CNF_NUMPLA = CNB.CNB_NUMERO AND CNF.D_E_L_E_T_ = ' ' "
				cQryItens += " WHERE CNB.CNB_FILIAL = '"+xFilial("CNB")+"'"
				cQryItens += 	" AND CNB.CNB_CONTRA = '"+cContrato+"' "
				cQryItens += 	" AND CNB.CNB_REVISA = '"+cRevisao+"' "
				cQryItens += 	" AND CNB.D_E_L_E_T_ = ' ' "
				cQryItens += " ORDER BY CNB_NUMERO, CNB_ITEM, CNF_PARCEL " 
				
				If Select('QRYITEM') <> 0
					DbSelectArea('QRYITEM')
					DbCloseArea()
				EndIf
				
				TCQUERY cQryItens NEW ALIAS "QRYITEM"
				
				nItem 		:= 0
				cItem		:= Alltrim(Str(nItem))

				While !QRYITEM->(Eof())
					
					nItem++
					cItem	:= Alltrim(Str(nItem))
					
					aAdd(aCardData,{'txtPlanilha___'+cItem,QRYITEM->PLANILHA})
					aAdd(aCardData,{'txtItem___'+cItem,QRYITEM->ITEM})
					aAdd(aCardData,{'txtProduto___'+cItem, Alltrim(QRYITEM->PRODUTO)+' - '+Alltrim(QRYITEM->DESCRICAO)})
					aAdd(aCardData,{'txtParcela___'+cItem, Alltrim(QRYITEM->PARCELA)})
					aAdd(aCardData,{'txtCompetencia___'+cItem, Alltrim(QRYITEM->COMPETENCIA)})
					aAdd(aCardData,{'txtVencimento___'+cItem, " "+DtoC(Stod(Alltrim(QRYITEM->VENCIMENTO)))})
					aAdd(aCardData,{'txtItemValor___'+cItem, PadR(TransForm(QRYITEM->VALOR,'@E 999,999,999.99'),15)})
			
					QRYITEM->(DbSkip())
				EndDo
		
				nItemAprov := 0
				cItemAprov	:= Alltrim(Str(nItemAprov))
			
				// Salva o Grupo
				cGrpAprov := QRY->GRUPO+QRY->ITEMGRP
			EndIf
			
			nItemAprov++
			cItemAprov	:= Alltrim(Str(nItemAprov))
			
			// Monta a Tracker com os aprovadores
			aAdd(aCardData,{'txtAprNivel___'+cItemAprov, QRY->NIVEL})
			aAdd(aCardData,{'txtAprNome___'+cItemAprov, Alltrim(QRY->NOME)})
			aAdd(aCardData,{'txtAprLogin___'+cItemAprov, GetLogFlg(Alltrim(QRY->USUARIO))})  
			aAdd(aCardData,{'txtAprGrupo___'+cItemAprov, QRY->GRUPO})
			aAdd(aCardData,{'txtAprItemGrp___'+cItemAprov, QRY->ITEMGRP})
			aAdd(aCardData,{'txtAprStatus___'+cItemAprov, 'Pendente'})
			aAdd(aCardData,{'txtAprRecno___'+cItemAprov, AllTrim(Str(QRY->RECNOSCR))})
			
			// Salva o Recno da Alçada 
			aAdd(aRecnoSCR, QRY->RECNOSCR)

			QRY->(DbSkip())
		EndDo
		
		// Valida se possui mais do que 1 grupo para gerar a solicitação
		If !Empty(cGrpAprov)
			// Salva o Numero de Itens do Contrato
			aAdd(aCardData,{'numItens', cItem})
			
			// Salva o Numero de Aprovadores
			aAdd(aCardData,{'aprovNum', cItemAprov})
			
			// Chama a função para gerar a solicitação no Fluig
			GeraFluig(aCardData, aRecnoSCR, cUserComp)
		EndIf

		QRY->(DBCloseArea())
	EndIf
else
	// Valida se precisa cancelar a alçada
	ValCancFluig(cContrato, cRevisao)
EndIf

Return lRet

/*
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++-----------------------------------------------------------------------------++
++ Função    | GeraFluig | Autor  | Anderson Jose Zelenski | Data | 15/07/2022 ++
++-----------------------------------------------------------------------------++
++ Descrição | Gerar no Fluig a Solicitação do WF de Contratos                 ++
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
Local cProcess	:= "WFContratos" 
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
			
			For nI := 1 To Len(aRecnoSCR)
				SCR->(DbGoTo(aRecnoSCR[nI]))
				RecLock("SCR",.F.)
					SCR->CR_FLUIG := cIdProcess
				SCR->(MsUnlock())
			Next
		
			conout("idProcess "+cIdProcess)
		EndIf
	Else
		conout("Processo não integrado com o Fluig")
	EndIf

Return

/*
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++-----------------------------------------------------------------------------++
++ Função    | GetLogFlg | Autor  | Anderson Jose Zelenski | Data | 15/07/2022 ++
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

/*
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++-----------------------------------------------------------------------------++
++ Função    | ValCancFluig | Autor | Anderson Jose Zelenski | Data | 15/07/22 ++
++-----------------------------------------------------------------------------++
++ Descrição | Valida se possui solicitação no Fluig para Cancelar             ++
++-----------------------------------------------------------------------------++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

Static Function ValCancFluig(cContrato, cRevisao)
Local cQry		:= ""

	// Busca os códigos das solicitações do Fluig
	cQry := " SELECT DISTINCT CR_FLUIG AS IDFLUIG "
	cQry += " FROM "+RetSqlName("SCR")+" SCR "
	cQry += " WHERE SCR.CR_FILIAL = '"+xFilial("SCR")+"' "
	cQry += "		AND SCR.CR_NUM = '"+cContrato+cRevisao+"' "
	cQry += "		AND SCR.CR_TIPO IN ('CT') "
	cQry += " 	AND SCR.D_E_L_E_T_ = ' ' "
	cQry += " ORDER BY 1 "
	
	If Select('QRY') <> 0
	DbSelectArea('QRY')
		DbCloseArea()
	Endif
	
	TCQUERY cQry NEW ALIAS "QRY"
	
	While !QRY->(Eof())
		// Chama a função para cancelar a solicitação no Fluig
		if !Empty(QRY->IDFLUIG)
			CancelaFluig(Val(AllTrim(QRY->IDFLUIG)), "Contrato alterado")
		EndIf
		
		QRY->(DbSkip())
	EndDo

Return .T.

/*
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++-----------------------------------------------------------------------------++
++ Função    | CancelaFluig | Autor | Anderson Jose Zelenski | Data | 30/01/22 ++
++-----------------------------------------------------------------------------++
++ Descrição | Cancela no Fluig a Solicitação do WF de Contratos               ++
++-----------------------------------------------------------------------------++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

Static Function CancelaFluig(nIdFluig, cComentario)
Local cFluigUsr 	:= AllTrim(GetMv("MV_FLGUSER"))
Local cFluigPss		:= AllTrim(GetMv("MV_FLGPASS"))
Local cFluigMatr 	:= AllTrim(GetMv("MV_FLGMATR"))
Local nCompany		:= 1
Local oFluigWrk
Local cRetorno		:= ""

	// Inicia o Objeto do WebService com o Processo a ser iniciado no Fluig
	oFluigWrk := WSECMWorkflowEngineService():New()
	
	// Cancela o Processo no Fluig
	If oFluigWrk:cancelInstance(cFluigUsr, cFluigPss, nCompany, nIdFluig, cFluigMatr, cComentario)
		cRetorno := oFluigWrk:cresult
		conout("Cancelamento Fluig: "+cRetorno)
	Else
		conout("Processo não integrado com o Fluig")
	EndIf

Return
