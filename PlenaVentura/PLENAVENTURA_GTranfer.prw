#include "protheus.ch"

/**
  Adicionar u_GTransfer() na validação de usuario dos campo C6_PRODUTO e C6_TES
  Adicionar u_VTransfer() na validação de usuário do campo C6_PRCVEN
*/

user function GTransfer(lGatilho)

	local cProduto      := getValue('C6_PRODUTO')
	local cLocal        := getValue('C6_LOCAL')
	local nPrecoTransfer:= GdFieldGet("C6_PRCVEN")

	local cCliente  := M->C5_CLIENT
	local cLoja     := M->C5_LOJACLI

	local nCustoMedio   := 0
	local nAliqIcms     := 0

    Local nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
	Local nPPrcVen	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
    Local nPValor   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
	Local lCalcImp  := GetNewPar("PL_IMPTRF",'S') == 'S'

	Local xRet:= .t.

	Default lGatilho:= .f.

	if isTransfer() .or. GDFIELDGET("C6_OPER",N) $ GetNewPar("BL_TESCM","XXX")
		SB1->( dbSetOrder(1) )
		if SB1->( dbSeek(xFilial('SB1') + cProduto ) )

			SB2->( dbSetOrder(1) )
			if SB2->( dbSeek(xFilial('SB2') + cProduto + cLocal) )

				SA1->( dbSetOrder(1) )
				if SA1->( dbSeek(xFilial('SA1') + cCliente + cLoja) )

					nCustoMedio := SB2->B2_CM1

                    dbSelectArea("SF7")
                    
                    Set Filter to &("@ F7_FILIAL = '"+xFilial("SF7")+"' AND F7_GRTRIB = '"+SB1->B1_GRTRIB+"' AND F7_GRPCLI = '"+SA1->A1_GRPTRIB+"' AND F7_ORIGEM = '"+SB1->B1_ORIGEM+"'")

					aExcecao := ExcecFis(SB1->B1_GRTRIB, SA1->A1_GRPTRIB)

                    Set Filter To

					If lCalcImp .and. isTransfer()
						nAliqIcms := aExcecao[2]
						if nAliqIcms ==0
							MSGALERT( ' Valor 0 de ICMS, favor verificar se esta correto' ,'Atencao')
						Endif
						nPrecoTransfer := Round(( nCustoMedio ) / (1 - ( nAliqIcms / 100 )), 2)
					Else
						nPrecoTransfer := Round(nCustoMedio,2)
					Endif

					if nPrecoTransfer > 0 
						aCols[n,nPPrcVen] := nPrecoTransfer
                        A410MultT('C6_PRCVEN', nPrecoTransfer)
                        aCols[n,nPValor]  := a410Arred(aCols[n,nPPrcVen] * aCols[n,nPQtdVen],"C6_VALOR")
					endif
				else
                    conout("[GTransfer] - Erro posicionar produtos "+cCliente + cLoja)    
                Endif
			else
				conout("[GTransfer] - Erro posicionar produtos "+cProduto + cLocal)
			Endif
		else
			conout("[GTransfer] - Erro posicionar produtos "+cProduto)
		Endif
	else
        conout("[GTransfer] - Não é tranferência TES:"+getValue('C6_TES'))
    endif

	if lGatilho
		xRet:= nPrecoTransfer
	Endif

return xRet

user function VTransfer()

	local istransfer := isTransfer()

	If IsInCallStack("MATA310") .or.IsInCallStack("MATA311")
		isTransfer:= .f.
	Else
		if istransfer .and. !AllTrim(ReadVar()) $ "M->C6_TES#M->C6_OPER"
			Help('',1,'TRANSFERENCIA',,'Não é permitido alterar o valor unitário para pedido de transferencia. '+ ReadVar(),4)
		else
            istransfer:= .f.
        endif
	endif

return !istransfer



static function getValue(cField)

	if ReadVar() == "M->"+cField
		return &(ReadVar())
	endif

return GDFieldGet(cField)



static function isTransfer()

	local cTES := getValue('C6_TES')
	//local cCliente := M->C5_CLIENT
	//local cLoja := M->C5_LOJACLI
	local cTipo := M->C5_TIPO

	if cTipo != "N"
		return .F.
	endif

	SF4->( dbSetOrder(1) )
	SF4->( dbSeek(xFilial('SF4') + cTES ) )

	if SF4->F4_TRANFIL != '1'
		return .F.
	endif

return .T.

//Função para controle de versão do fonte no gatilho C6_OPER e C6_TES
User Function xGTransf

Return .t.
