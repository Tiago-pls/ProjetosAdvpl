#include 'protheus.ch'
#include "fwbrowse.ch"

#define __cUserJob "job"
#define __cPassJob "msexecauto"


User Function MCnt260()

	Local cPerg := "MCNT260"



	Private itens := 1
	Private campos := 2


	Private aContratos := {}
	Private oMark

	//CriaSX1(cPerg)

	While Ask(cPerg)

		Procs()

	EndDO

Return

static function Procs
	//busca os contratos aptos a gerar medi��o
		Local oModal
	Local n1

	Local oColumn
	Local aColumns := {}

		MSGRun("Buscando contratos aptos a gerar medi��o",,{|| aContratos := GetContratos() })

		oModal	:= FWDialogModal():New()
		oModal:SetEscClose(.T.)
		oModal:setTitle("Selecione os contratos para gera��o de medi��o")
		oModal:enableAllClient()
		oModal:createDialog()

		oMark := FWBROWSE():New()
		oMark:SetOwner(oModal:getPanelMain())
		oMark:SetDataArray()
		//colunas de marca��o
		oMark:AddMarkColumns({|| IIF( aContratos[itens][oMark:nAt][1], "CHECKED" , "UNCHECKED" ) }, {|| Mark(1) }, {|| MarkAll(1) }) //gera medi��o
		oMark:AddMarkColumns({|| IIF( aContratos[itens][oMark:nAt][2], "PEDIDO"  , "UNCHECKED" ) }, {|| Mark(2) }, {|| MarkAll(2) }) //encerra medi��o
		oMark:AddMarkColumns({|| IIF( aContratos[itens][oMark:nAt][3], "CSAIMG32", "UNCHECKED" ) }, {|| Mark(3) }, {|| MarkAll(3) }) //bonifica��o
		oMark:SetDescription( "Contratos aptos entre " + FormDate(mv_par01) + " � " + FormDate(mv_par02) )
		oMark:SetArray(aContratos[itens])
		oMark:SetEditCell(.T., {|lCancel,oBrowse| ValidaBonus(lCancel,oBrowse) })
		//oMark:SetPreEditCell({|| .T. })

		For n1 := 4 to len(aContratos[campos])
			//posiciona pelo campo na SX3
			SX3->( dbSetOrder(2) )
			SX3->( dbSeek( aContratos[campos][n1] ) )
			//se encontrar o campo
			IF SX3->( Found() )
				//adiciona no browser
				//ADD COLUMN oColumn DATA &("{|| aContratos[itens][oMark:At()]["+cValToChar(n1)+"] }") TYPE SX3->X3_TIPO PICTURE SX3->X3_PICTURE TITLE X3TITULO() SIZE SX3->X3_TAMANHO DECIMAL SX3->X3_DECIMAL HEADERCLICK�{�||�.T.�} OF oMark

				//cria a columa
				oColumn := FWBrwColumn():New()
				oColumn:SetData(&("{|| aContratos[itens][oMark:At()]["+cValToChar(n1)+"] }"))
				oColumn:SetTitle(X3TITULO())
				oColumn:SetType(GetSx3Cache(aContratos[campos][n1],'X3_TIPO'))
				oColumn:SetSize(GetSx3Cache(aContratos[campos][n1],'X3_TAMANHO'))
				oColumn:SetDecimal(GetSx3Cache(aContratos[campos][n1],'X3_DECIMAL'))
				oColumn:SetPicture(GetSx3Cache(aContratos[campos][n1],'X3_PICTURE'))
				oColumn:SetAlign( IIF(GetSx3Cache(aContratos[campos][n1],'X3_TIPO') == "N",COLUMN_ALIGN_RIGHT,IIF(GetSx3Cache(aContratos[campos][n1],'X3_TIPO')== "D",COLUMN_ALIGN_CENTER,COLUMN_ALIGN_LEFT)) )

				IF aContratos[campos][n1] == "CN9_BONUS"
					oColumn:SetEdit(.T.)
					oColumn:SetReadVar("M->CN9_BONUS")
				EndIF

				aAdd(aColumns, oColumn)

			EndIF
		Next n1
		//adiciona as colunas
		oMark:SetColumns(aColumns)


		//ativa o markbrowser
		oMark:Activate()

		//adicina botoes
		//Filtro

		oModal:addButtons({{"","Filtrar",{|| Processa( {|| Filtrar("MCNT260F") })}, "Clique aqui para Sair",,.T.,.T.}})

		oModal:addButtons({{"","Gerar Medi��o",{|| Processa( {|| MCnt260Exec() }), oModal:Deactivate() }, "Clique aqui para gerar as medi��es",,.T.,.T.}})
		oModal:addButtons({{"","Sair",{|| oModal:Deactivate() }, "Clique aqui para Sair",,.T.,.T.}})

		//ativa o tela
		oModal:Activate()
return




Static function Ask(cPergunta)
    Local lRet:= Pergunte(cPergunta,.T.)
return lRet

Static Function ValidaBonus(lCancel,oBrowse)

	Local lValido := .T.

	IF ! lCancel

		IF M->CN9_BONUS < 0
			lValido := .F.
		EndIF

		IF lValido
			aContratos[itens][oBrowse:nAt][aScan(aContratos[campos],{|x| x == "CN9_BONUS" })] := M->CN9_BONUS
		EndIF

	EndIF
	//atualiza browse
	//oBrowse:LineRefresh()

Return lValido

Static Function Mark(nColumn)

	IF nColumn == 1
		aContratos[itens][oMark:nAt][nColumn] := ! aContratos[itens][oMark:nAt][nColumn]
		IF ! aContratos[itens][oMark:nAt][nColumn]
			aContratos[itens][oMark:nAt][2] := .F.
			aContratos[itens][oMark:nAt][3] := .F.
		EndIF
	ElseIF aContratos[itens][oMark:nAt][1]
		aContratos[itens][oMark:nAt][nColumn] := ! aContratos[itens][oMark:nAt][nColumn]
	EndIF

	//atualiza browse
	oMark:LineRefresh()

Return


Static Function MarkAll(nColumn)

	Local n1

	For n1 := 1 to len(aContratos[itens])
		IF nColumn == 1
			aContratos[itens][n1][nColumn] := ! aContratos[itens][n1][nColumn]
			IF ! aContratos[itens][n1][nColumn]
				aContratos[itens][n1][2] := .F.
				aContratos[itens][n1][3] := .F.
			EndIF
		ElseIF aContratos[itens][n1][1]
			aContratos[itens][n1][nColumn] := ! aContratos[itens][n1][nColumn]
		EndIF
	Next n1

	//atualiza browse
	oMark:Refresh(.T.)

Return


Static Function MCnt260Exec()

	Local n1
	Local cResult := ""

	Local cMensagem := {}

	//pesquisa o usuario pelo login
	PSWOrder(2)
	//faz o decode e faz a busca
	PSWSeek(__cUserJob, .T.)

	IF ! PSWName(__cPassJob)
		Aviso("Aten��o", "Usu�rio 'job' n�o encontrado, n�o � possivel gerar as medi��es.", {"Sair"}, 1,,,"fwskin_error_ico")
		Return
	EndIF

	ProcRegua(len(aContratos[itens]))

	//varre todos os itens
	For n1 := 1 to len(aContratos[itens])
		//se estiver marcado
		IF aContratos[itens][n1][1]

			IncProc("Gerando medi��o para o contratos")

			//Joga o retorno do
			cResult += StartJob("u_MCnt260Job",GetEnvServer(),.T.,cEmpAnt,cFilAnt,__CUSERID,aContratos[itens][n1],aContratos[campos])

		EndIF

		CNF->( dbSkip() )
	Next n1


	//resultado da sincroniza��o
	IF !Empty(cResult)
		Aviso("Medi��o",cResult,{"Sair"},3)
	EndIF

Return


User Function MCnt260Job(__cEmpresa, __cFilial, cCodUser, aContrato, aCampos)

	Local aCnta120Cab := {}
	Local aCnta120Itens := {}

	Local cNumeroMedicao := {}
	Local cResult := ""

	Local nSaldoQuebrado := 0

	//Seta job para nao consumir licensas
	RPCSetType(3)

	//Seta job para empresa filial desejada
	RPCSetEnv(__cEmpresa,__cFilial,__cUserJob,__cPassJob,"GCT","CNTA120")

	//posiciona no contrato
	CN9->( dbSetOrder(1) )
	CN9->( dbSeek( xFilial("CNF") + aContrato[pos('CN9_NUMERO',aCampos)] + aContrato[pos('CN9_REVISA',aCampos)] ) )

	//posiciona no cronograma
	CNF->( dbSetOrder(2) )
	CNF->( dbSeek( xFilial("CNF") + CN9->(CN9_NUMERO+CN9_REVISA) + aContrato[pos('CNF_NUMERO',aCampos)] + aContrato[pos('CNF_COMPET',aCampos)] ) )

	CNA->( dbSetOrder(1) )
	CNA->( dbSeek( xFilial("CNA") + CNF->(CNF_CONTRA+CNF_REVISA+CNF_NUMPLA) ) )

	SA1->( dbSetOrder(1) )
	SA1->( dbSeek( xFilial("SA1") + CNA->(CNA_CLIENT+CNA_LOJACL) ) )

	cResult := "Contrato: " + alltrim(CN9->CN9_NUMERO) + "  Planilha: " + CNA->CNA_NUMERO + CRLF
	cResult += " - Cliente: " + SA1->(A1_COD+"/"+A1_LOJA+" "+alltrim(A1_NOME)) + CRLF


	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.

	aCnta120Cab := {}
	aCnta120Itens := {}

	cNumeroMedicao := CN130NumMd()
	aAdd(aCnta120Cab,{ "CND_CONTRA", CNF->CNF_CONTRA, Nil})
	aAdd(aCnta120Cab,{ "CND_REVISA", CNF->CNF_REVISA, Nil})
	aAdd(aCnta120Cab,{ "CND_COMPET", CNF->CNF_COMPET, Nil})
	aAdd(aCnta120Cab,{ "CND_NUMERO", CNF->CNF_NUMPLA, Nil})
	aAdd(aCnta120Cab,{ "CND_NUMMED", cNumeroMedicao ,Nil})
	aAdd(aCnta120Cab,{ "CND_PARCEL", CNF->CNF_PARCEL, Nil})
	aAdd(aCnta120Cab,{ "CND_MOEDA"  , CN9->CN9_MOEDA ,NIL})


	CNB->( dbSetOrder(1) )
	CNB->( dbSeek( xFilial("CNB") + CNF->(CNF_CONTRA+CNF_REVISA+CNF_NUMPLA) ) )

	While !CNB->( Eof() ) .And. CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO) == xFilial("CNB") + CNF->(CNF_CONTRA+CNF_REVISA+CNF_NUMPLA)

		IF CNB->CNB_SLDMED > 0

			aAdd( aCnta120Itens, {})
			aAdd( aTail(aCnta120Itens), {"CNE_ITEM"  , CNB->CNB_ITEM  , Nil})
			aAdd( aTail(aCnta120Itens), {"CNE_PRODUT", CNB->CNB_PRODUT, Nil})
			aAdd( aTail(aCnta120Itens), {"CNE_VLUNIT", CNB->CNB_VLUNIT, Nil})

			//pega saldo quebrado de substitui��o
			nSaldoQuebrado := CNB->CNB_SLDMED - int(CNB->CNB_SLDMED)
			//se saldo for igual a zero. pega 1
			IF nSaldoQuebrado  == 0
				aAdd( aTail(aCnta120Itens), {"CNE_QUANT" , 1              , Nil})
				aAdd( aTail(aCnta120Itens), {"CNE_VLTOT" , CNB->CNB_VLUNIT, Nil})
			Else
				//sen�o pega o quebrado
				aAdd( aTail(aCnta120Itens), {"CNE_QUANT" , nSaldoQuebrado, Nil})
				aAdd( aTail(aCnta120Itens), {"CNE_VLTOT" , A410Arred(nSaldoQuebrado*CNB->CNB_VLUNIT,"CNE_VLTOT"), Nil})
			EndIF
			aAdd( aTail(aCnta120Itens), {"CNE_TS"    , CNB->CNB_TS    , Nil})
			aAdd( aTail(aCnta120Itens), {"CNE_PEDTIT", CNB->CNB_PEDTIT, Nil})
		EndIF
		CNB->( dbSkip() )
	EndDO

	IF len(aCnta120Itens) != 0

		//rotina autimatica para gerar medi��o
		Cnta120(aCnta120Cab,aCnta120Itens,3,.F.)

		IF lMsErroAuto
			cResult += " - Erro na gera��o da medi��o:"+CRLF
			cResult +=  GetMsErroAuto()
		Else
			cResult += " - Medi��o " + CND->CND_NUMMED + " gerada com sucesso."+CRLF

			IF aContrato[3] .And. aContrato[pos('CN9_BONUS',aCampos)] > 0
				RecLock( "CNR", .T. )
				CNR->CNR_FILIAL := xFilial( "CNR" )
				CNR->CNR_NUMMED := CND->CND_NUMMED
				CNR->CNR_CONTRA := CND->CND_CONTRA
				CNR->CNR_TIPO   := "1" //multa... acresce valor na medicao
				CNR->CNR_DESCRI := "BONIFICA��O POR DISPONIBILIDADE " + cValToChar(aContrato[pos('CN9_BONUS',aCampos)]) + "%"
				CNR->CNR_VALOR  := A410Arred(CNF->CNF_VLPREV * aContrato[pos('CN9_BONUS',aCampos)] / 100,"CNR_VALOR")
				CNR->CNR_MODO   := '2' //manual
				CNR->CNR_FLGPED := '1' //interfere no pedido
				CNR->( MsUnlock() )

				cResult += " - Bonifica��o por disponibilidade " + cValToChar(aContrato[pos('CN9_BONUS',aCampos)]) + "% ("+cValToChar(CNR->CNR_VALOR)+") gerada com sucesso."+CRLF
			EndIF

			IF aContrato[2]
				Cnta120(aCnta120Cab,aCnta120Itens,6,.F.)
				IF lMsErroAuto
					cResult += " - Erro no encerramento da medi��o:"+CRLF
					cResult +=  GetMsErroAuto()
				Else
					cResult += " - Medi��o encerrada com sucesso com pedido " + CND->CND_PEDIDO + "."+CRLF
				EndIF
			EndIF
		EndIF
	EndIF
	cResult += CRLF

Return cResult


/*
Static Function Pos(cCampo)
Return aScan(aContratos[campos],{|x| x == cCampo })
*/
Static Function Pos(cCampo,aCampos)
Return aScan(aCampos,{|x| x == cCampo })


Static Function CriaSX1(cPerg)

	PutSx1(cPerg,'01','Data de?'     ,'','','mv_ch1','D',8,0,0,'G','','','','','mv_par01',"","","","","","","","","","","","","","","","",{"Data inicial para filtrar o cronograma","","",""})
	PutSx1(cPerg,'02','Data at�?'    ,'','','mv_ch2','D',8,0,0,'G','','','','','mv_par02',"","","","","","","","","","","","","","","","",{"Data final para filtrar o cronograma","","",""})
	PutSx1(cPerg,'03','Contrato de?' ,'','','mv_ch3','C',15,0,0,'G','','','','','mv_par03',"","","","","","","","","","","","","","","","",{"Contrato de ","","",""})
	PutSx1(cPerg,'04','Contrato at�?','','','mv_ch4','C',15,0,0,'G','','','','','mv_par04',"","","","","","","","","","","","","","","","",{"Contrato Ate","","",""})

Return


Static Function GetContratos()

	Local n1
	Local cAlias := GetNextAlias()

	Local aItens := {}
	Local aCampos := {"MARK1","MARK2","MARK3"}
	Local nCont :=1
	Local cCont1 :=""
	Local cCont2 :=""
	Local aContrato1 := separa(Alltrim(MV_PAR03),',')
	Local aContrato2 := separa(Alltrim(MV_PAR04),',')
	For nCont := 1 to Len(aContrato1) 
		if nCont  <> 1
			cCont1 += "'"
		Endif
		cCont1 += aContrato1[nCont] +"',"
	Next nCont
	cCont1 := Left(cCont1, len(cCont1) -2 )
	cCont1 += ""

	For nCont := 1 to Len(aContrato2) 
		if nCont  <> 1
			cCont2 += "'"
		Endif
		cCont2 += aContrato1[nCont] +"',"
	Next nCont
	cCont2 := Left(cCont2, len(cCont2) -2 )
	cCont2 += ""

	BeginSQL Alias cAlias
		%noparser%

		column CNF_PRUMED as date
		column CNF_DTVENC as date

		select
		CN9.CN9_NUMERO, CN9.CN9_REVISA, CN9_BONUS,
		SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME,
		CNF.CNF_NUMERO, CNF.CNF_NUMPLA, CNF.CNF_PARCEL, CNF.CNF_COMPET, CNF.CNF_VLPREV, CNF.CNF_VLREAL, CNF.CNF_SALDO, CNF.CNF_PRUMED, CNF.CNF_DTVENC

		from %table:CN9% CN9

		inner join %table:CNF% CNF
		on  CNF.CNF_FILIAL = %xFilial:CNF%
		and CNF.CNF_CONTRA = CN9.CN9_NUMERO
		and CNF.CNF_REVISA = CN9.CN9_REVISA
		and CNF.CNF_PRUMED >= %exp: mv_par01 %
		and CNF.CNF_PRUMED <= %exp: mv_par02 %
		and CNF.CNF_VLREAL = 0
		and CNF.D_E_L_E_T_ = ' '

		inner join %table:CNA% CNA
		on  CNA.CNA_FILIAL = %xFilial:CNA%
		and CNA.CNA_CONTRA = CN9.CN9_NUMERO
		and CNA.CNA_REVISA = CN9.CN9_REVISA
		and CNA.CNA_NUMERO = CNF.CNF_NUMPLA
		and CNA.D_E_L_E_T_ = ' '

		inner join %table:SA1% SA1
		on  SA1.A1_FILIAL  = %xFilial:SA1%
		and SA1.A1_COD     = CNA.CNA_CLIENT
		and SA1.A1_LOJA    = CNA.CNA_LOJACL
		and SA1.D_E_L_E_T_ = ' '

		where
		CN9.CN9_FILIAL = %xFilial:CN9%
		and CN9.CN9_SITUAC = '05'
		and CN9.CN9_ESPCTR = '2'
		and CN9.D_E_L_E_T_ = ' '
		//and CNA.CNA_CONTRA >= %exp: mv_par03 %
		and CNA.CNA_CONTRA in (%exp: cCont1 %)
		//and CNA.CNA_CONTRA <= %exp: mv_par04 %
		

	EndSQL

	//pega todos os campos da query
	For n1 := 1 to (cAlias)->( FCount() )
		aAdd( aCampos, FieldName(n1) )
	Next n1

	While !(cAlias)->( Eof() )

		aAdd( aItens, {} )
		//campos de marca��o
		aAdd( aTail(aItens), .F. ) //marca��o gera medi��o
		aAdd( aTail(aItens), .F. ) //marca��o encerrar
		aAdd( aTail(aItens), .F. ) //marca��o para incluir bonifica��o de 3%
		//adiciona os campos da query
		For n1 := 4 to len(aCampos)
			aAdd( aTail(aItens), (cAlias)->&(aCampos[n1]) )
		Next n1

		(cAlias)->( dbSkip() )
	EndDO


Return {aItens, aCampos}


/*/{Protheus.doc} GetMsErroAuto
Fun��o para tratar erro do execAuto, gravando em disco e retornando.

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@return cLog, caractere, Erro do execAuto
/*/
Static Function GetMsErroAuto()

	Local aErro := GetAutoGRLog()
	Local cError := ""
	Local n1

	//percorre o erro do execAuto
	For n1 := 1 to len(aErro)
		cError += aErro[n1] + CRLF
	Next n1

Return cError



static function Filtrar( cPerg)
 Pergunte(cPerg,.T.)
 Procs()
return
