/**********************************************************************************************************************************/
/** Ponto de Entrada MT100TOK                                                                 			 						**/
/**																																**/
/** Este Ponto de Entrada é executado antes da gravacao da Nota e tem por obejtivo validar os itens Digitados.					**/
/** Tem por funcao de validar se existe Centro de Custo nos seguintes itens:													**/
/** - Itens da Nota (Linha a Linha)																								**/
/** - No Rateio																									                **/
/**																																**/
/** Data: 30/11/2015                                                                                              				**/
/** Totvs                                                                                                 		 				**/
/**********************************************************************************************************************************/
/** Data       | Responsável              | Descrição                                                        		 			**/
/**********************************************************************************************************************************/
/** 30/11/2015 | Reinaldo Maurício Santos | Criação da rotina/procedimento.                                     				**/
/**********************************************************************************************************************************/
/** 17/08/2016 | Reinaldo Maurício Santos | Alteracao, para entrar na rotina caso seja APENAS tipo N , antes estava diferente de D**/
/**********************************************************************************************************************************/
/** 19/08/2016 | Reinaldo Maurício Santos | Alteracao, incluido novas validacoes na classificacao por TES          				 **/
/**********************************************************************************************************************************/
#include 'totvs.ch'
#include "rwmake.ch"

User Function MT100TOK()

	Local _lRet := .T.
	Local _nVez
	Local PedItem
	Local cLine
	Local cTES

	SF4->(dbSelectArea(1))
	SF4->(DbSetOrder(1))//F4_FILIAL + F4_CODIGO

	//So entra se NF for do tipo Normal
	If cTipo = 'N'

		//nao for rotina SPEDNFE
		if !ISINCALLSTACK("SPEDNFE") .and. !ISINCALLSTACK("MATA920")

			//verifica se a empresa logada esta contida no parametro
			IF cEmpAnt $ SuperGetMv("MV_xRATEIO" ,.F.,'04')

				For _nVez:=1 to len(aCols)

					//Verifica se a linha NÃO foi deletada e se dentro do Acols NÃO Existe o Centro de Custo
					if !aCols[_nVez][len(aCols[1])].and.empty(u__rCampo(_nVez,"D1_CC"))

						//Verifica se a linha NÃO foi deletada e se dentro do Acols NÃO Existe Pedido de Compra
						if !aCols[_nVez][len(aCols[1])].and.empty(u__rCampo(_nVez,"D1_PEDIDO"))

							_lRet:=.f.
							exit
						Else
							//Busca numero e Item do Pedido de Compra
							PedItem := (u__rCampo(_nVez,"D1_PEDIDO") + u__rCampo(_nVez,"D1_ITEMPC"))

							//Seleciona Tabela SCH
							SCH->(dbSelectArea(1))
							SCH->(DbSetOrder(1))

							//Verifica se NAO Existe o Pedido + Item
							If !SCH->(DbSeek( xFilial("SCH") + PedItem))

								//Se nao houver Rateio
								if LEN(ABACKCOLSSDE) < 1

									_lRet:=.f.
									exit
									//Se rateio foi digitado e Excluido
								ElseIf LEN(ABACKCOLSSDE[_nVez][2]) < 1

									_lRet:=.f.
									exit

								EndIf
							EndIf
						EndIf
					EndIf
				Next

				If !_lRet

					//Faco uma nova validacao pela TES
					For _nVez:=1 to len(aCols)

						cTES := u__rCampo(_nVez,"D1_TES")

						If SF4->(DbSeek(xFilial("SF4") + cTES,.T. ))

							//Se a TES nao gerar duplicata
							If SF4->F4_DUPLIC = 'N'
								_lRet:=.T.
								Exit
							EndIf

							//Se a TES atualiza Ativo
							IF SF4->F4_ATUATF = 'S'
								_lRet:=.T.
								Exit
							EndIf

							//Se a Filial for diferente da Piemont e Cantu
							If !cEmpAnt $ '04/08'
								IF SF4->F4_ESTOQUE = 'S'
									_lRet:=.T.
									Exit
								EndIf
							EndIf
						EndIf
					Next

					If !_lRet

						If Alltrim(Funname()) <> "MATA310"

							MsgInfo('Nao encontrado um dos seguintes itens: ' + CRLF + CRLF +;
								'-Centro de Custo (Item ou Rateio)' + CRLF +;
								'-Pedido de Compra (Relacionado a NF)' + CRLF + CRLF +;
								' Ou a TES nao atende aos requisitos (Duplitacas(S) / Estoque(N) / Ativo(N)).', 'TOTVS' )
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf


	if _lRet .and. alreadyExists()
		_lRet := .F.
	endif
	if (SF1->F1_ZNATURE <> SC7->C7_ZNATURE) .and. _lRet
		If ! MsgYesNo( "Natureza Fin Diferente na informada no Pedido, deseja prosseguir?","Natureza Financeira")
			_lRet := .F.

		Endif
	Endif
Return _lRet

static function alreadyExists()

	Local cAlias := getNextAlias()
	//Local exclude := IIF(l103Class, SF1->(recno()), 0)
	Local exists := .F.
	Local key
	if ISINCALLSTACK("MATA920")
		private l103Class := .F.
	Endif
	exclude := IIF(l103Class, SF1->(recno()), 0)
	if type('aNfeDanfe') == 'A' .and. len(aNfeDanfe) >= 13
		key := aNFEDanfe[13]
	endif
	if empty(key)
		return .F.
endif

	BEGINSQL ALIAS cAlias
		select F1_CHVNFE, F1_DOC, F1_SERIE
		from %table:SF1%
		where
				F1_FILIAL = %xFilial:SF1%
		and F1_CHVNFE = %Exp:key%
		and R_E_C_N_O_ <> %Exp:exclude%
		and D_E_L_E_T_ = ' '
	ENDSQL

	if !empty((cAlias)->F1_CHVNFE)
		Help(" ",1,"HELP","ERRO NF","Chave NFE esta vinculada em outra nota ("+(cAlias)->F1_DOC+"/"+(cAlias)->F1_SERIE+").",3,1)
		exists := .T.
	endif

	(cAlias)->( dbCloseArea() )

return exists

//------------------------------------------------------------------------
// Retorna o valor atual de um campo em edicao no acols
user Function _rCampo(_nItem,_cCampo)

	local _xValor,_nPosic
	_cCampo:=alltrim(upper(_cCampo))
	// Verifica se nao é ele mesmo que está sendo digitado no momento
	if _cCampo$upper(readvar()).and.N==_nItem
		_xValor:=readVar()
		_xValor:=&(_xValor)
	else
		_nPosic:=aScan(aHeader,{|x|Alltrim(upper(x[2])) == alltrim(upper(_cCampo))})
		if _nPosic==0
			//MSGBOX alterado para MSGINFO 02/12/2016
			MsgInfo("u__rCampo: Campo "+_cCampo+" nao localizado no acols atual")

		else
			_xValor  := aCols[_nItem,_nPosic]
		endif
	endif

return _xValor

//TESTAR SO SE FOR ESTORNO
/*
User Function A140Exc()

Local ExpL1 := .T.

// Rotina de usuário.
	If nOpc == 2 //.. Exclusao
	
		dbSelectArea("SEZ") 	//Seleciona tabela SEV
		dbSetOrder(1)			//EZ_FILIAL+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_CCUSTO										                      
		
		//verifica se é uma alteração no produto
		if SEZ->(DbSeek(xFilial("SEZ")+ E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO,.T.))

			// altera registro
			RecLock("SEZ",.F.)
			SEZ->(DbDelete()) // Efetua a exclusão lógica do registro posicionado.
			MsUnLock() 		// Confirma e finaliza a operação
		endif
	
	EndIf

Return ExpL1
*/
