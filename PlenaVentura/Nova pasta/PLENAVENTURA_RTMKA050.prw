#include 'protheus.ch'
#include "fwprintsetup.ch"
#include 'rptdef.ch'

#define ALIGN_LEFT   0
#define ALIGN_RIGHT  1
#define ALIGN_CENTER 2

/*/{Protheus.doc} RTMKA050
Rotina para impressão de Orçamento de PDF
COPIADO O MESMO RELATÓRIO RCRM050 QUE FOI DESENVOLVIDO PELO RAFAEL VIACELI E ADAPTADO
PARA USO DAS TABELA DO TELEVENDAS. O LAYOUT NÃO FOI ALTERADO
@author Fernando Nonato
@since 05/08/2016
@version 1.0

/*/
User Function RTMKA050()

	Local oPDF
	Local lPreview := .F.

	//IF ADY->ADY_ENTIDA != '1'
	//	Aviso("Atenção", "Impressão disponivel apenas para Cliente, pois não é possivel fazer calculo de impostos com Prospect.", {"Sair"}, 1)
	//	Return
	//EndIF

	IF SUA->UA_OPER != '2'
		Aviso("Atenção", "Impressão disponivel apenas para a operação orçamento.", {"Sair"}, 1)
		Return
	EndIF


	oPDF := NewPrinter(@lPreview)


	IF oPDF != Nil

		//inicia impressao da pagina
		oPDF:StartPage()

		//posiciona no cliente
		SA1->( dbSetOrder(1) )
		SA1->( dbSeek( xFilial("SA1") + SUA->(UA_CLIENTE+UA_LOJA) ) )

		//posiciona no vendedor
		SA3->( dbSetOrder(1) )
		SA3->( dbSeek( xFilial("SA3") + SUA->UA_VEND ) )

		//posiciona na condição de pagamento
		SE4->( dbSetOrder(1) )
		SE4->( dbSeek( xFilial("SE4") + SUA->UA_CONDPG ) )

		//posiciona no primeiro item da proposta
		SUB->( dbSetOrder(1) )
		SUB->( dbSeek( xFilial("SUB") + SUA->UA_NUM ) )

		Layout(oPDF)

		//finaliza impressao da pagina
		oPDF:EndPage()

		//gera o PDF
		IF oPDF:nDevice == IMP_PDF
			oPDF:Preview()
		EndIF

		//limpa o objeto
		FreeObj(oPDF)
		oPDF := Nil

	EndIF

Return



/*/{Protheus.doc} NewPrinter
Configuração do PDF

@author Fernando Nonato
@since 05/08/2016
@version 1.0
@return oPDF, objecto, Objeto de relatório
/*/
Static Function NewPrinter(lPreview)

	Local cDiretorio := "C:\temp"
	Local cTempFile := "orcamento_" + SUA->UA_NUM +"_"+DtoS(MSDate())+"_"+RetNum(Time())+".pdf"

	Local oPDF
	Local oSetup


	oPDF := FWMSPrinter():New(cTempFile, IMP_PDF, .F., , .T.)

	oPDF:SetResolution(72)
	oPDF:SetLandscape()
	oPDF:SetPaperSize(DMPAPER_A4)
	oPDF:SetMargin( 20, 20, 20, 20)

	oSetup := FWPrintSetup():New( PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN + PD_DISABLEORIENTATION, "Impressão de Orçamento")

	//Define saida
	oSetup:SetPropert(PD_PRINTTYPE   , IMP_PDF ) //PDF
	oSetup:SetPropert(PD_ORIENTATION , LANDSCAPE ) //paisagem
	oSetup:SetPropert(PD_DESTINATION , AMB_CLIENT )
	oSetup:SetPropert(PD_MARGIN      , {20,20,20,20})
	oSetup:SetPropert(PD_PAPERSIZE   , DMPAPER_A4)

	IF oSetup:Activate() == PD_OK

		IF oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
			oPDF:nDevice  := IMP_SPOOL
			oPDF:cPrinter := oSetup:aOptions[PD_VALUETYPE]
		ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
			oPDF:nDevice  := IMP_PDF
			oPDF:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
			lPreview := .T.
		EndIF

	Else
		oPDF := nil
	EndIF


Return oPDF

/*/{Protheus.doc} Layout
Monta o layout do relatório

@author Fernando Nonato
@since 19/02/2016
@version 1.0
@param oPDF, objeto, Objeto do relatório
/*/
Static Function Layout(oPDF)

	Local oFont := TFont():New('Arial',,10,,.F.)


	Local n1, n2

	Local aQuebra := {}

	Local nAux

	Local nLinha := 0

	Local aTotais := {{11,""},{13,""},{14,""},{15,""}}

	Local aDados := {}


	nLinha := ImpCabecalho(oPDF, .T.)
	Cabecalho(oPDF, @nLinha)

	//busca os itens da proposta
	aDados := GetProposta(@aTotais)

	For n1 := 1 to len(aDados)
		aQuebra := CalcQuebra(aDados[n1], oFont)
		For n2 := 1 to len(aQuebra)

			IF A4ToRow(190) <= nLinha
				nLinha := Continua(@oPDF, nLinha)
				Cabecalho(oPDF, @nLinha)
			EndIF

			//aqui quebra pagina
			ImpreItem(oPDF, @nLinha, aQuebra[n2], oFont, Mod(n1,2)==0 )

		Next n2
	Next n1

	Total(oPDF, @nLinha, aTotais)

	ImpRodape(oPDF, @nLinha)

Return


Static Function A4ToCol(nMilimitro)
	//largura da pagina * largula em milimitros / largura da pagina A4 em mm
Return Round(842 * (nMilimitro / 297), 0) - 10

Static Function A4ToRow(nMilimitro)
	//altura da pagina * altura em milimitros / altura da pagina A4 em mm
Return Round(595 * (nMilimitro / 210), 0)


Static Function MakePhone(cTelefone, cDDD)

	Local cDDDTelefone := ""

	default cDDD := ""

	cTelefone := RetNum(cTelefone)
	cDDD := RetNum(cDDD)

	//se o numero do telefone é maior que 9 (considerando o 9 digito) e o DDD vazio
	//quer dizer que telefone e DDD estão na mesma string
	IF len(cTelefone) > 9 .And. Empty(cDDD) .And. ! SubStr(cTelefone,14) $ "0300 0500 0800 0900"
		//se começar com 0
		IF Substr(cTelefone,1,1) == "0"
			//pega 3 digitos o DDD
			cDDD  := SubStr(cTelefone,1,3)
			cTelefone := SubStr(cTelefone,4)
		Else
			//senao pega do 2
			cDDD  := SubStr(cTelefone,1,2)
			cTelefone := SubStr(cTelefone,3)
		EndIF
	EndIF

	IF ! Empty(cDDD) .And. ! Empty(cTelefone)
		cDDDTelefone += "("+cDDD+") "
	EndIF

	IF ! Empty(cTelefone)
		cDDDTelefone += Transform(cTelefone,"@R " + Replicate("9",len(cTelefone)-4) + "-9999")
	EndIF

Return cDDDTelefone




Static Function ImpreItem(oPDF, nLinEmMilimetros, aDados, oFonte, lFundo )

	Local aEstrutura := Estrutura()
	Local aColunas := EstruturaToPrint(aEstrutura)

	Local n1

	Default oFonte := TFont():New('Arial',,10,,.F.)

	IF valtype(lFundo) == "L" .And. lFundo
		Fundo(@oPDF, nLinEmMilimetros)
	EndIF

	For n1 := 1 to Len(aColunas)
		//impressão da linha
		oPDF:SayAlign( nLinEmMilimetros+1, aColunas[n1][1], alltrim(aDados[n1]), oFonte, aColunas[n1][2],,, aEstrutura[n1][2])
	Next n1

	//pula linha
	nLinEmMilimetros += 12

Return




Static Function Cabecalho(oPDF, nLinEmMilimetros)

	Local aEstrutura := Estrutura()
	Local aColunas := EstruturaToPrint(aEstrutura)
	Local oArial10   := TFont():New('Arial',,10,,.T.)

	Local n1

	oPDF:FillRect( {nLinEmMilimetros,A4ToCol(5),nLinEmMilimetros+12,A4ToCol(295)}, TBrush():New( , rgb(50,50,50) ) )

	For n1 := 1 to Len(aColunas)
		//impressão da linha
		oPDF:SayAlign( nLinEmMilimetros, aColunas[n1][1], alltrim(aEstrutura[n1][3]), oArial10, aColunas[n1][2],, CLR_WHITE, aEstrutura[n1][2])
	Next n1

	//pula linha
	nLinEmMilimetros += 12

Return


Static Function Total(oPDF, nLinEmMilimetros, aTotais)

	Local aEstrutura := Estrutura()
	Local aColunas := EstruturaToPrint(aEstrutura)
	Local oArial10   := TFont():New('Arial',,10,,.T.)

	Local n1

	oPDF:FillRect( {nLinEmMilimetros,A4ToCol(5),nLinEmMilimetros+12,A4ToCol(295)}, TBrush():New( , rgb(50,50,50) ) )

	For n1 := 1 to Len(aTotais)
		//impressão da linha
		oPDF:SayAlign( nLinEmMilimetros, aColunas[aTotais[n1][1]][1]-20, aTotais[n1][2], oArial10, aColunas[aTotais[n1][1]][2]+20,, CLR_WHITE, aEstrutura[aTotais[n1][1]][2])
	Next n1

	//pula linha
	nLinEmMilimetros += 12

Return



Static Function Estrutura()

	Local aEstrutura := {}

	//aAdd(aEstrutura,{TAMANHO,ALINHAMENTO,CONTEUDO})
	aAdd(aEstrutura,{  4, ALIGN_CENTER, "#"})
	//aAdd(aEstrutura,{  8, ALIGN_LEFT  , "Marca"})
	aAdd(aEstrutura,{ 15, ALIGN_LEFT  , "Código"})
	aAdd(aEstrutura,{ 30, ALIGN_LEFT  , "Descrição"})
	aAdd(aEstrutura,{  4, ALIGN_CENTER, "UM"})
	aAdd(aEstrutura,{  8, ALIGN_CENTER, "NCM"})
	aAdd(aEstrutura,{  8, ALIGN_RIGHT , "Quant."})
	aAdd(aEstrutura,{ 10, ALIGN_RIGHT , "Vlr. Unit."})
	aAdd(aEstrutura,{ 10, ALIGN_RIGHT , "Vlr. Total"})
	aAdd(aEstrutura,{  8, ALIGN_CENTER, "Entrega"})
	aAdd(aEstrutura,{  6, ALIGN_RIGHT , "% IPI"})
	aAdd(aEstrutura,{ 10, ALIGN_RIGHT , "Vlr. IPI"})
	aAdd(aEstrutura,{  7, ALIGN_RIGHT , "% ICMS"})
	aAdd(aEstrutura,{  8, ALIGN_RIGHT , "Vlr. ICMS"})
	aAdd(aEstrutura,{  8, ALIGN_RIGHT , "ICMS ST"})
	aAdd(aEstrutura,{ 10, ALIGN_RIGHT , "Total"})
	aAdd(aEstrutura,{ 10, ALIGN_CENTER, "It.Cliente"})

Return aEstrutura

Static Function Fundo( oPDF, nLinEmMilimetros)
	Local oBrush := TBrush():New( , RGB(205,205,205))

	oPDF:FillRect( {nLinEmMilimetros,A4ToCol(5),nLinEmMilimetros+12,A4ToCol(295)}, oBrush )   //Fundo cinza

Return


Static Function EstruturaToPrint(aEstrutura)

	Local nLarguraPagina := A4ToCol(295)
	Local nColunaInicial :=  A4ToCol(5)
	Local nColuna := A4ToCol(5)

	Local nTamanhoColunas := 0

	Local nColMin := 0

	Local nLarguraColuna := 0

	Local aColunas := {}

	Local n1

	//total da coluna
	aEval( aEstrutura, {|x| nTamanhoColunas += x[1]})

	For n1 := 1 to Len(aEstrutura)
		//calcula a largura da coluna
		nLarguraColuna := (( nLarguraPagina - nColunaInicial)*( aEstrutura[n1][1] / nTamanhoColunas ))

		aAdd(aColunas,{ nColuna, nLarguraColuna })

		nColuna += (nLarguraPagina- nColunaInicial)*( aEstrutura[n1][1] / nTamanhoColunas )

	Next n1

Return aColunas


Static Function CalcQuebra(aDados, oFont)

	Local aColunas  := EstruturaToPrint(Estrutura())

	Local nMax := 1

	Local aResult := {}

	Local n1, n2

	For n1 := 1 to len(aColunas)
		aDados[n1] := Quebra(alltrim(aDados[n1]), aColunas[n1][2], oFont)
		IF valtype(aDados[n1]) == "A"
			nMax := Max(nMax,len(aDados[n1]))
		EndIF
	Next n1

	IF nMax == 1
		Return {aDados}
	EndIF

	For n1 := 1 to nMax
		aAdd(aResult,{})
		For n2 := 1 to len(aDados)
			IF n1 == 1 .And. valtype(aDados[n2]) == "C"
				aAdd(aTail(aResult),aDados[n2])
			ElseIF valtype(aDados[n2]) == "A" .And. n1 <= len(aDados[n2])
				aAdd(aTail(aResult),aDados[n2][n1])
			Else
				aAdd(aTail(aResult),"")
			EndIF
		Next n2
	Next n1

Return aResult


Static Function Quebra(cTexto, nLarguraColuna, oFont)

	Local nLarguraTexto := FontWidth(cTexto, oFont)

	Local aLinhas := {}
	Local xResult := ""

	Local aPalavras := {}

	Local n1, n2

	Local lContinua := .T.

	//se a largura da coluna for maior que do texto
	//cabe
	IF nLarguraColuna >= nLarguraTexto
		Return cTexto
	Else
		//senão, quebramos a coluna
		//isso é complexo, porque não é quebra por numero de caracteres é sim pela largura em pixels

		//1º Primeiro, separamos todas as paravras, por espaço
		aPalavras := Separa(cTexto, " ", .F.)
		xResult := ""

		For n1 := 1 to len(aPalavras)

			IF nLarguraColuna >=  FontWidth(xResult + aPalavras[n1], oFont)
				xResult := alltrim(xResult + " " + aPalavras[n1])
			Else
				//se a palavra for maior que o campo
				IF Empty(xResult)
					xResult := aPalavras[n1]
					lContinua := .T.
					//brebra em qualquer lugar
					For n2 := len(xResult) to 1 step -1
						//vai tirando os caracteres do final até que caiba
						IF lContinua .And. nLarguraColuna >= FontWidth( SubStr(xResult,1,n2), oFont)
							//pega a parte que cabe e coluna na linha
							aAdd(aLinhas, SubStr(xResult,1,n2))
							//agora pega o resta do texto
							xResult := SubStr(xResult,n2+1)
							//se o resto cabe, sai fora
							IF nLarguraColuna >= FontWidth( xResult, oFont)
								lContinua := .F.
							EndIF
						EndIF
					Next n2
				Else
					aAdd(aLinhas, xResult)
					xResult := aPalavras[n1]
				EndIF
			EndIF

		Next n1
		aAdd(aLinhas, xResult)

	EndIF

Return aLinhas

Static Function FontWidth(cTexto,oFont)
	Local nIndice := 1.87
	Local oFontSize:= FWFontSize():New()
	Local nWidth := oFontSize:GetTextWidth( cTexto, oFont:Name, oFont:nWidth, oFont:Bold, oFont:Italic ) / nIndice
Return nWidth


Static Function ImpCabecalho(oPDF, lFirst)

	Local oArial10   := tFont():New("Arial",10,10,nil,.F.,nil,nil,,.T.,.F.)
	Local oArial10N  := tFont():New("Arial",10,10,nil,.T.,nil,nil,,.T.,.F.)
	Local oArial12N  := tFont():New("Arial",12,12,nil,.T.,nil,nil,,.T.,.F.)
	Local oArial14N  := tFont():New("Arial",14,14,nil,.T.,nil,nil,,.T.,.F.)

	Local nLin := A4ToRow(30)

	Local cEquipamento := ""

	default lFirst := .F.

	//logo
	oPDF:SayBitmap( A4ToRow(10), A4ToCol(5), GetMV("PV_NLONLOG",,"\system\logo_nf_debito_" + cFilAnt + ".jpg"), A4ToRow(60), A4ToRow(20) )

	//dados de emitente
	oPDF:SayAlign( A4ToRow(10), A4ToCol(80), SM0->M0_NOMECOM, oArial14N,400,,,ALIGN_LEFT)

	//dados de emitente
	oPDF:SayAlign( A4ToRow(15), A4ToCol(80), alltrim(SM0->M0_ENDCOB) + " - " + SM0->M0_BAIRCOB, oArial10,400,,,ALIGN_LEFT)
	oPDF:SayAlign( A4ToRow(19), A4ToCol(80), alltrim(SM0->M0_CIDCOB) + " - " + SM0->M0_ESTCOB + " - " + TransForm(SM0->M0_CEPCOB,"@R 99999-999"), oArial10,400,,,ALIGN_LEFT)
	oPDF:SayAlign( A4ToRow(23), A4ToCol(80), TransForm(SM0->M0_CGC,"@R 99.999.999/9999-99") , oArial10,200,,,ALIGN_LEFT)

	oPDF:SayAlign( A4ToRow(19), A4ToCol(140), MakePhone(SM0->M0_TEL), oArial10,200,,,ALIGN_LEFT)
	oPDF:SayAlign( A4ToRow(23), A4ToCol(140), "0800 645 0099", oArial10,200,,,ALIGN_LEFT)

	//numero do orçamento
	oPDF:SayAlign( A4ToRow(11), A4ToCol(265), "ORÇAMENTO Nº",oArial10 ,80,,,ALIGN_CENTER)
	oPDF:SayAlign( A4ToRow(15), A4ToCol(265), SUA->UA_NUM ,oArial14N,80,,,ALIGN_CENTER)

	oPDF:SayAlign( A4ToRow(23), A4ToCol(265), FormDate(SUA->UA_EMISSAO),oArial10 ,80,,,ALIGN_CENTER)


	IF lFirst
		//linha entre emitente e cliente
		oPDF:Line( A4ToRow(28), A4ToCol(5), A4ToRow(28), A4ToCol(295) ,,"01")

		//LADO ESQUERDO (INFORMAÇÕES DO CLIENTE)
		//razão social do cliente
		oPDF:SayAlign( A4ToRow(30), A4ToCol(5), "Cliente:", oArial10,100,,,ALIGN_LEFT)
		oPDF:SayAlign( A4ToRow(29.5), A4ToCol(20), SA1->A1_NOME , oArial12N,400,,,ALIGN_LEFT)
		oPDF:SayAlign( A4ToRow(30), A4ToCol(30) + FontWidth(alltrim(SA1->A1_NOME),oArial12N) , "(" + SA1->(A1_COD + "/" + A1_LOJA) + ")" , oArial10,100,,,ALIGN_LEFT)

		//endereco
		oPDF:SayAlign( A4ToRow(35), A4ToCol(5), "Endereço:", oArial10,100,,,ALIGN_LEFT)
		oPDF:SayAlign( A4ToRow(35), A4ToCol(20), alltrim(SA1->A1_END) + " - " + SA1->A1_BAIRRO, oArial10,400,,,ALIGN_LEFT)
		oPDF:SayAlign( A4ToRow(39), A4ToCol(20), alltrim(SA1->A1_MUN) + " - " + SA1->A1_EST + " - " + TransForm(SA1->A1_CEP,"@R 99999-999"), oArial10,400,,,ALIGN_LEFT)

		//cnpj
		oPDF:SayAlign( A4ToRow(43), A4ToCol(5), "CNPJ:", oArial10,100,,,ALIGN_LEFT)
		oPDF:SayAlign( A4ToRow(43), A4ToCol(20), TransForm(SA1->A1_CGC,IIF(SA1->A1_PESSOA=="J","@R 99.999.999/9999-99","@R 999.999.999-99")) , oArial10,200,,,ALIGN_LEFT)
		//Inscrição estadual
		oPDF:SayAlign( A4ToRow(47), A4ToCol(5), "Insc.Est.:", oArial10,100,,,ALIGN_LEFT)
		oPDF:SayAlign( A4ToRow(47), A4ToCol(20), SA1->A1_INSCR, oArial10,200,,,ALIGN_LEFT)

		//telefones
		oPDF:SayAlign( A4ToRow(39), A4ToCol(095), "Telefone:", oArial10,100,,,ALIGN_LEFT)
		oPDF:SayAlign( A4ToRow(39), A4ToCol(110), MakePhone(SA1->A1_TEL,SA1->A1_DDD), oArial10,200,,,ALIGN_LEFT)
		nAux := 43
		IF ! Empty( MakePhone(SA1->A1_FAX,SA1->A1_DDD) )
			oPDF:SayAlign( A4ToRow(nAux), A4ToCol(095), "Fax:", oArial10,100,,,ALIGN_LEFT)
			oPDF:SayAlign( A4ToRow(nAux), A4ToCol(110), MakePhone(SA1->A1_FAX,SA1->A1_DDD), oArial10,200,,,ALIGN_LEFT)
			nAux := 47
		EndIF
		//contato
		IF ! Empty( SA1->A1_CONTATO )
			oPDF:SayAlign( A4ToRow(nAux), A4ToCol(095), "Contato:", oArial10,100,,,ALIGN_LEFT)
			oPDF:SayAlign( A4ToRow(nAux), A4ToCol(110), SA1->A1_CONTATO, oArial10N,200,,,ALIGN_LEFT)
		EndIF

		//LADO DIREITO (INFORMAÇÕES DA PROPOSTA)

		//condição de pagamento
		oPDF:SayAlign( A4ToRow(30), A4ToCol(160), "Condição Pagto:", oArial10,100,,,ALIGN_LEFT)
		oPDF:SayAlign( A4ToRow(30), A4ToCol(182), SE4->E4_DESCRI, oArial10,500,,,ALIGN_LEFT)

		//moeda
		oPDF:SayAlign( A4ToRow(30), A4ToCol(210), "Moeda:", oArial10,100,,,ALIGN_LEFT)
		oPDF:SayAlign( A4ToRow(30), A4ToCol(222), GetMv("MV_MOEDA" +cValToChar(1),,"REAL"), oArial10,500,,,ALIGN_LEFT)

		IF SUA->( FieldPos("UA_XPEDCL") ) != 0 .And. ! Empty(SUA->UA_XPEDCL)
			//pedido do cliente
			oPDF:SayAlign( A4ToRow(30), A4ToCol(240), "Pedido Cliente:", oArial10,100,,,ALIGN_LEFT)
			oPDF:SayAlign( A4ToRow(30), A4ToCol(260), SUA->UA_XPEDCL , oArial10,500,,,ALIGN_LEFT)
		EndIF

		//tipo de frete
		IF SUA->( FieldPos("UA_TPFRETE") ) != 0 .And. ! Empty(SUA->UA_TPFRETE)
			oPDF:SayAlign( A4ToRow(34), A4ToCol(160), "Tipo de Frete:", oArial10,100,,,ALIGN_LEFT)
			oPDF:SayAlign( A4ToRow(34), A4ToCol(182), GetOpcao("UA_TPFRETE", UA_TPFRETE), oArial10,500,,,ALIGN_LEFT)
		EndIF

		IF SUA->( FieldPos("UA_TRANSP") ) != 0 .And. ! Empty(SUA->UA_TRANSP)
			SA4->( dbSetOrder(1) )
			SA4->( dbSeek( xFilial("SA4") + SUA->UA_TRANSP ) )

			IF SA4->( Found() )

				//transportadora
				oPDF:SayAlign( A4ToRow(34), A4ToCol(210), "Transportadora: ", oArial10,100,,,ALIGN_LEFT)
				oPDF:SayAlign( A4ToRow(34), A4ToCol(232), SA4->A4_NOME, oArial10,500,,,ALIGN_LEFT)
			EndIF
		EndIF

		//vendedor
		oPDF:SayAlign( A4ToRow(38), A4ToCol(160), "Vendedor:", oArial10,100,,,ALIGN_LEFT)
		oPDF:SayAlign( A4ToRow(38), A4ToCol(175), alltrim(SA3->A3_NOME) + IIF( ! Empty(SA3->A3_EMAIL) , " (" + alltrim(SA3->A3_EMAIL) + ")" , "" ), oArial10,500,,,ALIGN_LEFT)


		cEquipamento := ""

		//Equipamento
		IF SUA->( FieldPOS("UA_XEQUIP") ) != 0 .And. ! Empty(SUA->UA_XEQUIP)
			cEquipamento += "Equipamento: " + alltrim(SUA->UA_XEQUIP) + "    "
		EndIF
		//Numero Serie
		IF SUA->( FieldPOS("UA_XSERIE") ) != 0 .And. ! Empty(SUA->UA_XSERIE)
			cEquipamento += "Núm.Série: " + alltrim(SUA->UA_XSERIE) + "    "
		EndIF
		//Horimetro
		IF SUA->( FieldPOS("UA_XHORI") ) != 0 .And. ! Empty(SUA->UA_XHORI)
			cEquipamento += "Horímetro: " + allToChar(SUA->UA_XHORI) + "    "
		EndIF

		IF ! Empty(cEquipamento)
			oPDF:SayAlign( A4ToRow(43), A4ToCol(160), cEquipamento, oArial10,600,,,ALIGN_LEFT)
		EndIF

		//Setor
		IF SUA->( FieldPOS("UA_XSETOR") ) != 0 .And. ! Empty(SUA->UA_XSETOR)
			oPDF:SayAlign( A4ToRow(47), A4ToCol(160), "Setor: " + alltrim(SUA->UA_XSETOR), oArial10,200,,,ALIGN_LEFT)
		EndIF

		nLin := A4ToRow(52)
	EndIF

Return nLin


Static Function ImpRodape(oPDF, nLin)

	Local cTexto := ""

	Local aLinhas := {}
	Local oFont := TFont():New('Arial',,10,,.F.)

	cTexto += "DISPONIBILIDADE: devido a eventuais acontecimentos, como por exemplo, greves de alfândega brasileira, configurações em canais vermelho/amarelo "
	cTexto += "ou quaisquer motivos relacionados ao transporte e fornecedores, a " + alltrim(SM0->M0_NOMECOM) + " isenta-se das responsabilidades por atrasos na "
	cTexto += "entrega, comprometendo-se a comunicar antecipadamente, os responsáveis pelos pedidos de compras. "

	cTexto += "PREÇOS: os preços mencionados são válidos por cinco dias e serão ou não ajustados à época do faturamento, conforme o câmbio vigente. Os preços "
	cTexto += "estão sujeitos a ajustes, caso haja alteração na política tributária vigente. Caso ocorram mudanças na lista de preços oficial da " + alltrim(SM0->M0_NOMECOM) + ", "
	cTexto += "ordenados pela matriz, os mesmos serão aplicados a esta cotação. Os valores dos impostos podem variar de acordo com a classificação fiscal (NCM)."


    If !Empty(SUA->UA_CODOBS) .and. GetNewPar("MV_OBSORCT",'N') = 'S'
        cTexto += chr(13)+chr(10)+"OBSERVAÇÕES: "+MSMM(SUA->UA_CODOBS,,,,3)
    Endif

	nLin+=12
	oPDF:SayAlign( nLin, A4ToCol(5), cTexto, oFont,A4ToCol(293),A4ToRow(30),,ALIGN_LEFT)

Return


Static Function Continua(oPDF,nLin)
	Local oArial10   := TFont():New('Arial',,10,,.T.)

	oPDF:FillRect( {nLin, A4ToCol(5), nLin+12, A4ToCol(295)}, TBrush():New( , rgb(50,50,50) ) )
	oPDF:SayAlign( nLin, A4ToCol(260), "Continua...", oArial10, A4ToCol(35),, CLR_WHITE, ALIGN_RIGHT)
	oPDF:EndPage()
	oPDF:StartPage()

Return ImpCabecalho(oPDF, .F.)



Static Function GetProposta(aTotais)

	Local aDados := {}

	Local n1

	MaFisEnd()
	MaFisIni(;
		SA1->A1_COD,;  // 1-Codigo Cliente/Fornecedor
		SA1->A1_LOJA,; // 2-Loja do Cliente/Fornecedor
		"C",;	       // 3-C:Cliente , F:Fornecedor
		"N",;          // 4-Tipo da NF
		SA1->A1_TIPO,; // 5-Tipo do Cliente/Fornecedor
		,;             // 6-Relacao de Impostos que suportados no arquivo
		,;             // 7-Tipo de complemento
		,;             // 8-Permite Incluir Impostos no Rodape .T./.F.
		,;             // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
		)              // 10-Nome da rotina que esta utilizando a funcao

	While !SUB->( Eof() ) .And. SUB->(UB_FILIAL+UB_NUM) == SUA->(UA_FILIAL+UA_NUM)

		MaFisAdd(;
			SUB->UB_PRODUTO,; // 1-Codigo do Produto ( Obrigatorio )
			SUB->UB_TES,;    // 2-Codigo do TES ( Opcional )
			SUB->UB_QUANT,; // 3-Quantidade ( Obrigatorio )
			SUB->UB_VRUNIT,; // 4-Preco Unitario ( Obrigatorio )
			0,;               // 5-Valor do Desconto ( Opcional )
			"",;              // 6-Numero da NF Original ( Devolucao/Benef )
			"",;              // 7-Serie da NF Original ( Devolucao/Benef )
			0,;               // 8-RecNo da NF Original no arq SD1/SD2
			0,;               // 9-Valor do Frete do Item ( Opcional )
			0,;               // 10-Valor da Despesa do item ( Opcional )
			0,;               // 11-Valor do Seguro do item ( Opcional )
			0,;               // 12-Valor do Frete Autonomo ( Opcional )
			SUB->UB_VLRITEM,;  // 13-Valor da Mercadoria ( Obrigatorio )
			0,;               // 14-Valor da Embalagem ( Opiconal )
			0,;               // 15-RecNo do SB1
			0)                // 16-RecNo do SF4

		//posiciona no produto
		SB1->( dbSetOrder(1) )
		SB1->( dbSeek( xFilial("SB1") + SUB->UB_PRODUTO ) )

		//posiciona no complemento do produto
		SB5->( dbSetOrder(1) )
		SB5->( dbSeek( xFilial("SB5") + SUB->UB_PRODUTO ) )

		aAdd(aDados,{})
		aAdd(aTail(aDados), SUB->UB_ITEM ) //#1 item
		aAdd(aTail(aDados), SUB->UB_PRODUTO ) //#2 produto
		aAdd(aTail(aDados), ( SB5->( Found() ), SB5->B5_CEME, SUB->UB_XDESCRI) ) //#3 descrição
		aAdd(aTail(aDados), SB1->B1_UM ) //#4 unidade de medida
		aAdd(aTail(aDados), SB1->B1_POSIPI ) //#5 NCM
		aAdd(aTail(aDados), TransForm(SUB->UB_QUANT,PesqPict("SUB","UB_QUANT") ) ) //#6 quantidade
		aAdd(aTail(aDados), TransForm(SUB->UB_VRUNIT,PesqPict("SUB","UB_VLRITEM") ) ) //#7 valor unitario
		aAdd(aTail(aDados), TransForm(SUB->UB_VLRITEM,PesqPict("SUB","UB_VLRITEM") ) ) //#8 valor total
		aAdd(aTail(aDados), IIF( SUB->( FieldPOS("UB_XENT") ) !=0, DiaPlural(SUB->UB_XENT),'') ) //#9 previsão de entrega
		aAdd(aTail(aDados), "" ) //#10 percentual IPI
		aAdd(aTail(aDados), "" ) //#11 Valor IPI
		aAdd(aTail(aDados), "" ) //#12 percentual ICMS
		aAdd(aTail(aDados), "" ) //#13 Valor ICMS
		aAdd(aTail(aDados), "" ) //#14 ICMS ST
		aAdd(aTail(aDados), "" ) //#15 TOTAL
		aAdd(aTail(aDados), IIF( SUB->( FieldPos("UB_NUMPCOM") ) != 0, SUB->UB_NUMPCOM, "" ) ) //#16 OBSERVAÇÃO

		SUB->( dbSkip() )
	EndDO

	For n1 := 1 to len(aDados)
		aDados[n1][10] := TransForm(MaFisRet(n1,"IT_ALIQIPI"),"@E 999.99") //#10 percentual IPI
		aDados[n1][11] := TransForm(MaFisRet(n1,"IT_VALIPI" ),"@E 999,999,999.99") //#11 Valor IPI
		aDados[n1][12] := TransForm(MaFisRet(n1,"IT_ALIQICM"),"@E 999.99") //#12 percentual ICMS
		aDados[n1][13] := TransForm(MaFisRet(n1,"IT_VALICM" ),"@E 999,999,999.99") //#13 Valor ICMS
		aDados[n1][14] := TransForm(MaFisRet(n1,"IT_VALSOL" ),"@E 999,999,999.99") //#14 ICMS ST
		aDados[n1][15] := TransForm(MaFisRet(n1,"IT_TOTAL"  ),"@E 999,999,999.99") //#15 TOTAL
	Next n1


	aTotais[1][2] := TransForm(MaFisRet(,"NF_VALIPI" ),"@E 999,999,999.99")
	aTotais[2][2] := TransForm(MaFisRet(,"NF_VALICM" ),"@E 999,999,999.99")
	aTotais[3][2] := TransForm(MaFisRet(,"NF_VALSOL" ),"@E 999,999,999.99")
	aTotais[4][2] := TransForm(MaFisRet(,"NF_TOTAL"  ),"@E 999,999,999.99")

	MaFisEnd()

Return aDados

Static Function DiaPlural(nDias)
Return cValtoChar(nDias) + ' dia' + IIF(nDias>1,'s','')


Static Function GetOpcao(cCampo,cOpcao)

	Local aSaveArea := GetArea("SX3")
	Local aOpcoes := {}

	Local cRetorno := cOpcao

	Local n1

	//busca o campo
	SX3->( dbSetOrder(2) )
	SX3->( dbSeek(cCampo) )

	//se existir
	IF SX3->( Found() )
		aOpcoes := RetSx3Box(X3CBox(),,,SX3->X3_TAMANHO)
		For n1 := 1 to len(aOpcoes)
			IF aOpcoes[n1][2] == cOpcao
				cRetorno := aOpcoes[n1][3]
			EndIF
		Next n1
	EndIF

	RestArea(aSaveArea)

Return cRetorno
