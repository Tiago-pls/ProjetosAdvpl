/**********************************************************************************************************************************/
/** User function RCOM001                       	                                                                 		 		   **/
/** Relatorio que tem como funcao mostrar todas as Notas e Pre Notas lancadas no sistema        										**/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                          		 		**/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                     		 		**/
/**********************************************************************************************************************************/
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'

user function RCOM001()

	local oReport
	local cPerg  := 'RPLENAX001'
	local cAlias := getNextAlias()

	criaSx1(cPerg)
	Pergunte(cPerg, .F.)

	oReport := reportDef(cAlias, cPerg)
	oReport:printDialog()

return

/**********************************************************************************************************************************/
/** User function ReportPrint                       	                                                                 		 		**/
/** Rotina para montagem dos dados do relatório. 		                                         										**/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                          		 		**/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                     		 		**/
/**********************************************************************************************************************************/
Static Function ReportPrint(oReport,cAlias)

	local oSecao1 	:= oReport:Section(1)
	Local cForCli		:= ""
	Local cComprador := ""


	BEGINSQL ALIAS cAlias

	SELECT F1_FILIAL, F1_DTDIGIT, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_VALBRUT,F1_TIPO, F1_P1VENC, F1_PREFIXO, F1_IRRF, F1_VALPIS, F1_VALCOFI, F1_VALCSLL
	FROM %Table:SF1% SF
	     WHERE F1_FILIAL = %xFilial:SF1% 
		     AND F1_DOC >= %exp:MV_PAR01%
		     AND F1_DOC <= %exp:MV_PAR02%
		     AND F1_DTDIGIT	>= %Exp:MV_PAR03%
		     AND F1_DTDIGIT	<= %Exp:MV_PAR04%
		     AND F1_FORNECE	>= %Exp:MV_PAR05%
		     AND F1_FORNECE	<= %Exp:MV_PAR06%
		     AND F1_P1VENC	>= %Exp:MV_PAR07%
		     AND F1_P1VENC	<= %Exp:MV_PAR08%
		     AND %NotDel%
	ENDSQL

	oSecao1:EndQuery()

	TcSetField((cAlias),"F1_P1VENC","D")

	(cAlias)->(dbGoTop())
	nQtdReg := 0
	Count to nQtdReg
	(cAlias)->(dbGoTop())
	oReport:SetMeter(nQtdReg)
	//TCSetField("QRY","F1_DTDIGIT","D",8,0) 
	oSecao1:init()
	While !(cAlias)->(Eof())

		oSecao1:Cell("F1_FILIAL"	):SetValue((cAlias)->F1_FILIAL)
		oSecao1:Cell("F1_DTDIGIT"	):SetValue(sTod((cAlias)->F1_DTDIGIT))
		oSecao1:Cell("F1_DOC"		):SetValue((cAlias)->F1_DOC)
		oSecao1:Cell("F1_SERIE"		):SetValue((cAlias)->F1_SERIE)
		oSecao1:Cell("F1_FORNECE"	):SetValue((cAlias)->F1_FORNECE)
		oSecao1:Cell("F1_LOJA"		):SetValue((cAlias)->F1_LOJA)
		If (cAlias)->F1_TIPO $ ('BD')
			cForCli := Posicione("SA1",1,xFilial("SA1")+(cAlias)->F1_FORNECE+(cAlias)->F1_LOJA,"A1_NOME")
			cComprador := ""
		Else
			cForCli := Posicione("SA2",1,xFilial("SA2")+(cAlias)->F1_FORNECE+(cAlias)->F1_LOJA,"A2_NOME")

			SD1->( dbSetOrder(1) )
			SD1->( dbSeek((cAlias)->F1_FILIAL + (cAlias)->F1_DOC + (cAlias)->F1_SERIE + (cAlias)->F1_FORNECE + (cAlias)->F1_LOJA) )

			SC7->( dbSetOrder(1) )
			SC7->( dbSeek(SD1->D1_FILIAL + SD1->D1_PEDIDO + SD1->D1_ITEMPC) )

			SY1->( DbSetOrder(3) )
			SY1->( DbSeek( xFilial('SY1') + SC7->C7_USER ) )

			cComprador := SY1->Y1_NOME
		EndIf
		nValorLiq :=(cAlias)->( F1_VALBRUT - F1_IRRF - F1_VALPIS - F1_VALCOFI - F1_VALCSLL)
		oSecao1:Cell("NOME"):SetValue(cForCli)
		oSecao1:Cell("F1_VALBRUT"):SetValue((cAlias)->F1_VALBRUT)
		oSecao1:Cell("LIQUIDO"):SetValue(nValorLiq)
		//oSecao1:Cell("F1_P1VENC"):SetValue((cAlias)->F1_P1VENC)

		cQuery := " select E2_VENCREA, E2_VALOR from " + RetSqlName("SE2") + " SE2"
		cQuery += " Where D_E_L_E_T_ =' ' and  E2_FILIAL = '"+(cAlias)->F1_FILIAL+"' and E2_NUM =  '" +(cAlias)->F1_DOC+"' "
		cQuery += " and E2_TIPO ='NF' and E2_FORNECE = '" + (cAlias)->F1_FORNECE +"' and E2_LOJA ='" +(cAlias)->F1_LOJA+ "'"
		if select("QRY") <> 0
			DbCloseArea("QRY")
		Endif
		TcQuery cQuery New Alias "QRY" 
		if alltrim((cAlias)->F1_DOC) ='23394'
			cTst :=""
		Endif
		nCont :=1
		//TcSetField("QRY","E2_VENCREA","D",8,0)
		While QRY->(!EOF())	.and. nCont<=10
			cVenc  := "P"+cValtoChar(nCont)+"VENC"
			cData  :=SubStr(QRY->E2_VENCREA,7,2)+'/'+SubStr(QRY->E2_VENCREA,5,2)+'/'+SubStr(QRY->E2_VENCREA,1,4)
			oSecao1:Cell(cVenc):SetValue(cData)
			cValor  := "V"+cValtoChar(nCont)+"VENC"
			oSecao1:Cell(cValor):SetValue(QRY->E2_VALOR)
			nCont +=1
			QRY->( dbSkip())
		Enddo

		oSecao1:PrintLine()
		(cAlias)->(dbSkip())
		oReport:IncMeter()

	EndDo
	oSecao1:Finish()
return

/**********************************************************************************************************************************/
/** User function ReportDef                       	                                                                 		 		**/
/** Função para criação da estrutura do relatório. 		                                         										**/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                          		 		**/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                     		 		**/
/**********************************************************************************************************************************/
Static Function ReportDef(cAlias,cPerg)

	local cTitle  := "Relatório de Notas"
	local cHelp   := "Permite gerar relatório de Notas."
	local oReport
	local oSection1

	oReport := TReport():New('REL_NOTAS',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)
	oReport:SetLandscape(.T.)

	//Primeira seção
	oSection1 := TRSection():New(oReport,"Notas",{"SF1"})

	TRCell():New(oSection1,"F1_FILIAL"	, "SF1", "Filial")
	TRCell():New(oSection1,"F1_DTDIGIT" , "SF1", "Dt Digitacao")
	TRCell():New(oSection1,"F1_DOC"		, "SF1", "Documento")
	TRCell():New(oSection1,"F1_SERIE"	, "SF1", "Serie")
	TRCell():New(oSection1,"F1_FORNECE" , "SF1", "Fornecedor")
	TRCell():New(oSection1,"F1_LOJA"	, "SF1", "Loja")
	TRCell():New(oSection1,"NOME"		, "SF1", "Nome",,40)
	TRCell():New(oSection1,"F1_VALBRUT" , "SF1", "Valor Bruto")
	TRCell():New(oSection1,"LIQUIDO"    , "SE2", "Valor Liquido")
	TRCell():New(oSection1,"Y1_NOME"    , "SY1", "Comprador")
		TRCell():New(oSection1,"P1VENC"     , "SF1", "1º Vencimento")
	TRCell():New(oSection1,"V1VENC"     , "SF1", "Valor")
	TRCell():New(oSection1,"P2VENC"     , "QRY", "2º Vencimento")
	TRCell():New(oSection1,"V2VENC"     , "QRY", "Valor")
	TRCell():New(oSection1,"P3VENC"     , "SF1", "3º Vencimento")
	TRCell():New(oSection1,"V3VENC"     , "SF1", "Valor")
	TRCell():New(oSection1,"P4VENC"     , "SF1", "4º Vencimento")
	TRCell():New(oSection1,"V4VENC"     , "SF1", "Valor")
	TRCell():New(oSection1,"P5VENC"     , "SF1", "5º Vencimento")
	TRCell():New(oSection1,"V5VENC"     , "SF1", "Valor")
	TRCell():New(oSection1,"P6VENC"     , "SF1", "6º Vencimento")
	TRCell():New(oSection1,"V6VENC"     , "SF1", "Valor")
	TRCell():New(oSection1,"P7VENC"     , "SF1", "7º Vencimento")
	TRCell():New(oSection1,"V7VENC"     , "SF1", "Valor")
	TRCell():New(oSection1,"P8VENC"     , "SF1", "8º Vencimento")
	TRCell():New(oSection1,"V8VENC"     , "SF1", "Valor")
	TRCell():New(oSection1,"P9VENC"     , "SF1", "9º Vencimento")
	TRCell():New(oSection1,"V9VENC"     , "SF1", "Valor")
	TRCell():New(oSection1,"P10VENC"    , "SF1","10º Vencimento")
	TRCell():New(oSection1,"V10VENC"    , "SF1", "Valor")
	
	TRFunction():New(oSection1:Cell("F1_DOC"),,"COUNT",,"QUANTIDADE",,,.F.,.T.,.F.,oSection1)
	TRFunction():New(oSection1:Cell("F1_VALBRUT"),,"SUM",,"VALOR TOTAL",,,.F.,.T.,.F.,oSection1)


Return(oReport)

/**********************************************************************************************************************************/
/** User function criaSX1                       	                                                                 		 		**/
/** Função para criação das perguntas (se não existirem)  		                                         										**/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                          		 		**/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                     		 		**/
/**********************************************************************************************************************************/
static function criaSX1(cPerg)

	CheckSx1(cPerg, '01', 'Documento De?' 		, '', '', 'mv_ch1', 'C', 6, 0, 0, 'G', '', 'SF1', '', '', 'mv_par01')
	CheckSx1(cPerg, '02', 'Documento Ate?'		, '', '', 'mv_ch2', 'C', 6, 0, 0, 'G', '', 'SF1', '', '', 'mv_par02')
	CheckSx1(cPerg, '03', 'Dt Digitacao De?'    , '', '', 'mv_ch3', 'D', tamSx3("F1_DTDIGIT")[1], 0, 0, 'G', '', '', '', '', 'mv_par03')
	CheckSx1(cPerg, '04', 'Dt Digitacao Ate?'  	, '', '', 'mv_ch4', 'D', tamSx3("F1_DTDIGIT")[1], 0, 0, 'G', '', '', '', '', 'mv_par04')
	CheckSx1(cPerg, '05', 'Fornecedor De?' 		, '', '', 'mv_ch5', 'C', 6, 0, 0, 'G', '', 'A2A', '', '', 'mv_par05')
	CheckSx1(cPerg, '06', 'Fornecedor Ate?'		, '', '', 'mv_ch6', 'C', 6, 0, 0, 'G', '', 'A2A', '', '', 'mv_par06')
	CheckSx1(cPerg, '07', '1º Vencimento De?'	, '', '', 'mv_ch7', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par07')
	CheckSx1(cPerg, '08', '1º Vencimento Ate?', '', '', 'mv_ch8', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par08')

return
