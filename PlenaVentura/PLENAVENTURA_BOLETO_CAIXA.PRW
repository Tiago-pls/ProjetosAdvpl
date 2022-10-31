#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#include 'topconn.ch'




User Function BolVencido()

	IF SE1->E1_SALDO <= 0
		Alert('Apenas titulos com saldo podem gerar Boleto')
		Return
	EndIF

	IF SE1->E1_VENCREA >= dDataBase
		Alert('Apenas titulos vencidos podem gerar Boleto')
		Return
	EndIF

	IF SE1->E1_PORTADO != "104"
		Alert('Apenas titulos da Caixa podem gerar Boleto')
		Return
	EndIF


	SEE->( dbSetOrder(1) )
	SEE->( dbSeek( xFilial("SEE") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA+"R01") )

	SA1->( dbSetOrder(1) )
	SA1->( dbSeek( xFilial("SA1") + SE1->(E1_CLIENTE+E1_LOJA) ) )

	//instancia classe do boleto
	oBoleto := u_BolNewPrinter('104', .T.,,,.F.)

	Private lBolVencido := .T.

	u_RBolCaixa( @oBoleto )

	lBolVencido := .F.

	oBoleto:Preview()

	FreeObj(oBoleto)
	oBoleto := Nil

Return



//User Function BolCaixa(aTitulos,lPreview)
User Function BolCaixa(_pPath,_pArq,_lViewPdf, cTpBol)

	Local oBoleto
	Local cArquivo := ""
	Local lPreview := .T.

	Local cPerg		:= "BOLCAIXA"

	Local cBcoBol	:= ""

//	Local n1



	if _pPath==nil
		CriaSX1(cPerg)
		Pergunte(cPerg,.t.)
	else // Se _pPatch (disco, diretório e nome do arquivo a ser gerado) foi informado, gerar o boleto de SE1 corrente

		mv_par01:=se1->e1_prefixo // Prefixo de
		mv_par02:=se1->e1_prefixo // Prefixo Ate
		mv_par03:=se1->e1_num     // Titulo de
		mv_par04:=se1->e1_num     // Titulo Ate
		mv_par05:=se1->e1_parcela // Parcela De
		mv_par06:=se1->e1_parcela // Parcela Ate
		mv_par07:=se1->e1_tipo    // Tipo De
		mv_par08:=se1->e1_tipo    // Tipo Ate
		mv_par09:=se1->e1_cliente // Cliente de
		mv_par10:=se1->e1_cliente // Cliente Ate
		mv_par11:=se1->e1_loja    // Loja De
		mv_par12:=se1->e1_loja    // Loja Ate
		mv_par13:=se1->e1_vencto  // Vencimento de
		mv_par14:=se1->e1_vencto  // Vencimento ate
		mv_par15:=se1->e1_emissao // Emissao de
		mv_par16:=se1->e1_emissao // Emissao de
		mv_par17:=se1->e1_portado // Banco
		mv_par18:=se1->e1_agedep  // Agencia
		mv_par19:=se1->e1_conta   // Conta
		mv_par20:=""              // Sub-Conta
		mv_par21:=se1->e1_numbor  // Bordero De
		mv_par22:=se1->e1_numbor  // Bordero Ate
		mv_par23:=1               // Segunda Via 1=Sim;2=Nao
		mv_par24:=iif(VALTYPE(cTpBol)="N",cTpBol,Val(cTpBol))

		if _lViewPdf==nil
			_lVewPdf:=.f.
		endif

	endif

	If AllTrim(MV_PAR17) = '104'
		cBcoBol := 'CAIXA'
	ElseIf AllTrim(MV_PAR17) = '399'
		cBcoBol := 'HSBC'
	ElseIf AllTrim(MV_PAR17) = '341'
		cBcoBol := 'ITAU'
	ElseIf AllTrim(MV_PAR17) = '033'
		cBcoBol := 'SANTANDER'
	EndIf

//	alert(cPerg)
//Return

//Static Function BolCaixa1()

	//Busca os titulos para impressão
	BuscaDados()

	DbSelectArea('QAA')
	QAA->(DbGoTop())
	If QAA->(EOF())
		Alert('Não existem dados a serem exibidos!')
		Return
	EndIf

	//instancia classe do boleto
	oBoleto := u_BolNewPrinter('104', .T.,_pPath,_pArq,_lViewPdf)

	IF oBoleto != nil

		//For n1 := 1 to 1 //len(aTitulos)
		While !QAA->(EOF())

			//posiciona no titulo a receber
			SE1->( dbGoTo( QAA->R_E_C_N_O_ ) )

			SEE->( dbSetOrder(1) )
			SEE->( dbSeek( xFilial("SEE") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA+"R01") )

			SA1->( dbSetOrder(1) )
			SA1->( dbSeek( xFilial("SA1") + SE1->(E1_CLIENTE+E1_LOJA) ) )

			If cBcoBol = 'CAIXA'
				// Título não aglutinado, vencido e fora do mês não imprime.
				IF alltrim(SE1->E1_XVINCP) = "" .and. alltrim(SE1->E1_XAGLUT) = "" .and. lastday(SE1->E1_VENCREA) < dDatabase
					Alert("O título '" + alltrim(SE1->E1_NUM) + "' está vencido e fora do mês o boleto não poderá ser impresso!")
					Return
				EndIF
				// Título aglutinado vencido não pode ser impresso.
				IF (alltrim(SE1->E1_XVINCP) <> "" .and. SE1->E1_VENCREA < dDatabase) .or.;
						(SE1->E1_XAGLUT = "1" .and. alltrim(SE1->E1_XTITAGL) = "" .and. SE1->E1_VENCREA < dDatabase)
					Alert("O título '" + alltrim(SE1->E1_NUM) + "' está vencido o boleto não poderá ser impresso!")
					Return
				EndIF

				u_RBolCaixa( @oBoleto )
			ElseIf cBcoBol = 'HSBC'
				u_RBol399( @oBoleto )
			Elseif  cBcoBol = 'ITAU'
				u_RBol341( @oBoleto )
			Elseif  cBcoBol = 'SANTANDER'
				u_RBol033( @oBoleto )
			Else
				Alert('Não existem dados a serem exibidos! Banco selecionado não tem Boleto.')
				Return
			EndIf

			QAA->(DbSkip())
		EndDo
//		Next n1

		//gera PDF
		IF lPreview
			oBoleto:Preview()
		Else
			oBoleto:Print()
		EndIF

		FreeObj(oBoleto)
		oBoleto := Nil
	Else
		Alert('erro ao criar boleto')

	EndIF

Return cArquivo


User Function BolNewPrinter(cBanco, lPreview,_pPath,_pArq,_lViewPdf)

	Local cTempFile := "boleto_" + cBanco +"_"+DtoS(MSDate())+"_"+RetNum(Time())+".pdf"
	Local cDiretorio := "\boletos\"+cBanco+"\"
	Local oBoleto
	Local oSetup

	if _pArq<>nil
		cTempFile :=_pArq
		cDiretorio:=_pPath
		FErase(cDiretorio+cTempFile+".pdf")
		FErase(cDiretorio+cTempFile+".rel")

		oBoleto := FWMSPrinter():New(cTempFile,6, .F., cDiretorio, .T.,,oSetup,,.T.,,,.F.)

		oBoleto:SetResolution(72)
		oBoleto:SetPortrait( )
		oBoleto:SetPaperSize( 9 )
		oBoleto:SetMargin( 20, 20, 20, 20)
	/*
		oSetup := FWPrintSetup():New( PD_ISTOTVSPRINTER + ;
			                              PD_DISABLEPAPERSIZE + ;
			                              PD_DISABLEMARGIN + ;
			                              PD_DISABLEORIENTATION + ;
			                              PD_DISABLEDESTINATION ;
			                              , "Impressão de Boleto")

		oSetup:SetPropert(PD_PRINTTYPE   , 6 ) //PDF
		oSetup:SetPropert(PD_ORIENTATION , 1 ) //retrato
		oSetup:SetPropert(PD_DESTINATION , 2)
		oSetup:SetPropert(PD_MARGIN      , {20,20,20,20})
		oSetup:SetPropert(PD_PAPERSIZE   , 2)
*/
		oBoleto:cPathPDF := cDiretorio
		oBoleto:lViewPDF := _lViewPdf

	else

		IF lPreview
			cDiretorio := GetTempPath()
		Else
			//cria o diretório
			MakeDir("\boletos\")
			MakeDir(cDiretorio)
		EndIF

		//caminho completo do arquivo
		cArquivo := cDiretorio + cTempFile
		IF File(cArquivo)
			FErase(cArquivo)
		EndIF

		oBoleto := FWMSPrinter():New(cTempFile,6, .F., cDiretorio, .T.,,oSetup,,.T.,,,.F.)

		oBoleto:SetResolution(72)
		oBoleto:SetPortrait( )
		oBoleto:SetPaperSize( 9 )
		oBoleto:SetMargin( 20, 20, 20, 20)

		IF lPreview

			oSetup := FWPrintSetup():New( PD_ISTOTVSPRINTER + ;
				PD_DISABLEPAPERSIZE + ;
				PD_DISABLEMARGIN + ;
				PD_DISABLEORIENTATION + ;
				PD_DISABLEDESTINATION ;
				, "Impressão de Boleto")

			//Define saida
			oSetup:SetPropert(PD_PRINTTYPE   , 6 ) //PDF
			oSetup:SetPropert(PD_ORIENTATION , 1 ) //retrato
			oSetup:SetPropert(PD_DESTINATION , 2)
			oSetup:SetPropert(PD_MARGIN      , {20,20,20,20})
			oSetup:SetPropert(PD_PAPERSIZE   , 2)

			IF oSetup:Activate() == PD_OK
				oBoleto:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
				oBoleto:lViewPDF := lPreview
			Else
				oBoleto := nil
			EndIF
		Else
			oBoleto:cPathPDF := cDiretorio
			oBoleto:lViewPDF := lPreview
		EndIF
	endif
Return oBoleto

	#include 'protheus.ch'


	#define __codBanco "399"
	#define __nomBanco "HSBC"

	#define nLarg  (605-35)
	#define nAlt   842


User Function RBolCaixa( oBoleto )

	Local nBloco1	:= 0
	Local nBloco2	:= 260
	Local nBloco3	:= 0

	Local nCol1		:= 025
	Local nCol2		:= 250
	Local nCol3		:= 460

	Local nPont		:= 0

	Local cNomeImg	:=  SUPERGETMV("MV_XNMIMG", .T., "imagem_boleto.jpg") //includo jonatas 050216

	Local i,  nLin, x
	Local cQbEnd

	Private aDadosRM := {}


	Private oCourier06  := TFont():New('Courier New',08,08,,.F.,,,,.T.,.F.,.F.)
	Private oArial06  	:= TFont():New('Arial',06,06,,.F.,,,,.T.,.F.,.F.)
	Private oArial09  	:= TFont():New('Arial',10,10,,.F.,,,,.T.,.F.,.F.)
	Private oArial07  	:= TFont():New('Arial',07,07,,.F.,,,,.T.,.F.,.F.)
	Private oArial07N 	:= TFont():New('Arial',07,07,,.T.,,,,.T.,.F.,.F.)
	Private oArial09N 	:= TFont():New('Arial',10,10,,.T.,,,,.T.,.F.,.F.)
	Private oArial12N 	:= TFont():New('Arial',12,12,,.T.,,,,.T.,.F.,.F.)
	Private oArial14N 	:= TFont():New('Arial',14,14,,.T.,,,,.T.,.F.,.F.)
	Private oArial16N 	:= TFont():New('Arial',16,16,,.T.,,,,.T.,.F.,.F.)
	Private oArial18N 	:= TFont():New('Arial',21,21,,.T.,,,,.T.,.F.,.F.)

	Private lAglutinado := .F.
	Private lVencido 	:= .F.
	Private nJuros := 0
	Private nMulta := 0
	Private dVencimento := SE1->E1_VENCREA
	Private aTipos := {}
	Private nSeguro:= 0
	Private nTaxa :=0
	//calcula o valor dos abatimentos
	Private nValorAbatimentos :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	//calculo valor total
	Private nValorDocumento := Round((((SE1->E1_SALDO+SE1->E1_ACRESC)-SE1->E1_DECRESC)*100)-(nValorAbatimentos*100),0)/100


	//Busca dados RM
	aDadosRM := {}
	u_fFINI055(@aDadosRM, SE1->E1_PREFIXO,SE1->E1_NUM)
	nSeguro := aDadosRM[1][10]
	nTaxa	:= aDadosRM[1][12]
	//********************************************************************************
	// Alteração para impressão de títulos aglutinados - Fernando Nonato  - 04/04/2017
	//********************************************************************************


	// Título aglutinado verificar a origens
	IF SE1->E1_XAGLUT = "1" .and. alltrim(SE1->E1_XTITAGL) = ""
		lAglutinado := .T.
		cQuery := " SELECT * FROM " + RetSqlName("SE1") + " SE1"
		cQuery += " WHERE SE1.E1_FILIAL = '" + SE1->E1_FILIAL 	+ "' "
		//cQuery += " AND SE1.E1_PREFIXO 		= '" + SE1->E1_PREFIXO 	+ "' "
		cQuery += " AND SE1.E1_XTITAGL	   	= '" + SE1->E1_NUM 		+ "' "
		cQuery += " AND SE1.E1_TIPO 		= '" + SE1->E1_TIPO 	+ "' "
		cQuery += " AND SE1.E1_CLIENTE 		= '" + SE1->E1_CLIENTE 	+ "' "
		cQuery += " AND SE1.E1_LOJA 		= '" + SE1->E1_LOJA 	+ "' "
		cQuery += " AND SE1.E1_XAGLUT		='1' "
		cQuery += " AND SE1.D_E_L_E_T_ 		= ' ' ORDER BY E1_VENCREA"

		cQuery := ChangeQuery(cQuery)

		Memowrite("c:\temp\QRY_TIT_ORIGEM.txt",cQuery)

		//Verifica se a area já existe e fecha para ser recriada.
		If (Select("QSE1")) <> 0
			dbselectarea("QSE1")
			QSE1->(dbclosearea())
		EndIf

		TcQuery	cQuery New Alias 'QSE1'

		DbSelectArea('QSE1')
		QSE1->(DbGoTop())

		If QSE1->(EOF())
			Alert('Não existem dados a serem exibidos!')
			Return
		EndIf

		nSeguro 	:= 0
		nTaxa 		:= 0
		nTotParc	:= 0
		While !QSE1->(EOF())
			nTotParc++
			QSE1->(DbSkip())
		EndDo
		QSE1->(DbGoTop())
		nParc := 0
		While !QSE1->(EOF())
			nVlAbat := SomaAbat(QSE1->E1_PREFIXO,QSE1->E1_NUM,QSE1->E1_PARCELA,"R",1,,QSE1->E1_CLIENTE,QSE1->E1_LOJA)
			nVlDoc  := Round((((QSE1->E1_VALOR + QSE1->E1_ACRESC) - QSE1->E1_DECRESC) * 100)-(nVlAbat * 100),0) / 100

			IF stod(QSE1->E1_VENCREA) < SE1->E1_VENCREA //.And. Type('lBolVencido') == 'L' .And. lBolVencido
				lVencido := .T.
				//multa VALOR * 2.00 / 100
				nMulta += round(nVlDoc * QSE1->E1_PORCJUR / 100,2)
				//juros VALOR * 0.033 / 100 * DIAS VENCIDO
				nJuros += round(nVlDoc * QSE1->E1_VALJUR / 100 * (SE1->E1_VENCREA - stod(QSE1->E1_VENCREA)),2)
			EndIF
			//Busca dados RM
			aDadosRM := {}
			u_fFINI055(@aDadosRM, QSE1->E1_PREFIXO,QSE1->E1_NUM)
			nSeguro += aDadosRM[1][10]
			nTaxa	+= aDadosRM[1][12]
			aAdd(aTipos,{strzero(val(aDadosRM[1][1]),3) + "/" + strzero(val(aDadosRM[1][8]),3),;
				alltrim(dtoc(stod(QSE1->E1_VENCREA))) ,nVlDoc - aDadosRM[1][10] - aDadosRM[1][12], aDadosRM[1][7] })
			//nParc++
			//aAdd(aTipos,{strzero(nParc,3) + "/" + if(nTotParc=0,strzero(val(aDadosRM[1][8]),3),strzero(nTotParc,3)),;
				//	alltrim(dtoc(stod(QSE1->E1_VENCREA))) ,nVlDoc - aDadosRM[1][10] - aDadosRM[1][12], aDadosRM[1][7] })
			QSE1->(DbSkip())
		EndDo

	Endif
	if alltrim(SE1->E1_XVINCP) <> ""
		cQuery := " SELECT * FROM " + RetSqlName("SE1") + " SE1"
		cQuery += " WHERE SE1.E1_FILIAL = '" + SE1->E1_FILIAL 	+ "' "
		//cQuery += " AND SE1.E1_PREFIXO 		= '" + SE1->E1_PREFIXO 	+ "' "
		cQuery += " AND SE1.E1_NUM	   		= '" + SE1->E1_XVINCP	+ "' "
		cQuery += " AND SE1.E1_TIPO 		= '" + SE1->E1_TIPO 	+ "' "
		cQuery += " AND SE1.E1_CLIENTE 		= '" + SE1->E1_CLIENTE 	+ "' "
		cQuery += " AND SE1.E1_LOJA 		= '" + SE1->E1_LOJA 	+ "' "
		cQuery += " AND SE1.D_E_L_E_T_ 		= ' ' ORDER BY E1_VENCREA"

		cQuery := ChangeQuery(cQuery)

		Memowrite("c:\temp\QRY_TIT_ORIGEM.txt",cQuery)

		//Verifica se a area já existe e fecha para ser recriada.
		If (Select("QSE1")) <> 0
			dbselectarea("QSE1")
			QSE1->(dbclosearea())
		EndIf

		TcQuery	cQuery New Alias 'QSE1'

		DbSelectArea('QSE1')
		QSE1->(DbGoTop())
		aDadosRM := {}
		u_fFINI055(@aDadosRM, QSE1->E1_PREFIXO,QSE1->E1_NUM)
		nSeguro := aDadosRM[1][10]
		nTaxa  := aDadosRM[1][12]
	endif

	//nosso numero
	Private cNossoNumero := GetNossoNumero()
	Private cLinhaDigitavel := ""
	//codigo de barras
	Private cCodigoBarra := BolCodBar()

	//Private lEnderecoCobranca := !Empty(SA1->A1_ENDCOB) .and. !Empty(SA1->A1_BAIRROC) .and. !Empty(SA1->A1_MUNC) .and. !Empty(SA1->A1_ESTC) .and. !Empty(SA1->A1_CEPC)  alterado jonatas 20160212
	Private lEnderecoCobranca := !Empty(SA1->A1_END) .and. !Empty(SA1->A1_BAIRRO) .and. !Empty(SA1->A1_MUN) .and. !Empty(SA1->A1_EST) .and. !Empty(SA1->A1_CEP)

	Private aInstrucoes := {"","","",""}

	//aInstrucoes[1] := "Receber somente até 15 dias após o vencimento"
	//aInstrucoes[2] := "Mora Diaria de R$ " + Transform(SuperGetMV("MV_TXJUR", .F., 1),"@E 99.99") + "% ao mês (PRO-RATA-DIE)(*) Multa de "  + Transform(SuperGetMV("MV_TXMUL", .F., 2),"@E 99.99") + "%"
	//aInstrucoes[3] := "Pague preferencialmente nas agências da caixa econômica federal"
	//aInstrucoes[4] := "ou casa lotérica até o vencimento."      //Alterado mensagens jonatas paiva 20160212

	IF lAglutinado .or. alltrim(SE1->E1_XVINCP) <> ""
		aInstrucoes[1] := "NÃO RECEBER APÓS O VENCIMENTO."
	Else
		aInstrucoes[1] := "Não receber após o último dia útil do mês."
		aInstrucoes[2] := "Após o vencimento cobrar Juros de 1% ao mês (PRÓ-RATE-DIE)(+) Multa de 2%."
		aInstrucoes[3] := "Pague preferencialmente nas agências da CAIXA ECONÔMICA FEDERAL"
		aInstrucoes[4] := "ou casa lotérica até o vencimento."
	EndIF

	//inicia pagina
	oBoleto:StartPage()

	//logo
	//	oBoleto:SayBitmap(nBloco1+20, nCol3, "\boletos\logos\Logo-RioBonito.jpg", 100, 85) alterado jonatas paiva 05022016
	oBoleto:SayBitmap(nBloco1+05, nCol3, "\boletos\logos\"+cNomeImg, 100, 85)




	oBoleto:Say(nBloco1+=018,nCol1,"Beneficiario",oArial06 )
	oBoleto:Say(nBloco1     ,nCol2,"Agencia/Cod. Beneficiario",oArial06 )

	oBoleto:Say(nBloco1+=008,nCol1,AllTrim(SM0->M0_NOMECOM) ,oArial09 )
	oBoleto:Say(nBloco1     ,nCol2,AllTrim(SEE->EE_AGENCIA) + "/" + AllTrim(SEE->EE_CODEMP) + "-" + Modulo11(AllTrim(SEE->EE_CODEMP)),oArial09N )

	oBoleto:Say(nBloco1+=015,nCol1,"DADOS DO MUTUARIO",oArial12N )
	oBoleto:Say(nBloco1     ,nCol2,"DADOS DO CONTRATO",oArial12N )

	oBoleto:Say(nBloco1+=015,nCol1,"Nome." + alltrim(SA1->A1_NOME),oArial09 )
	oBoleto:Say(nBloco1     ,nCol2,"Empreendimento: " + aDadosRM[1][3],oArial09 )

	//	oBoleto:Say(nBloco1+=015,nCol1,"Endereço. " + AllTrim(IIF(lEnderecoCobranca,SA1->A1_ENDCOB,SA1->A1_END)) + " - " + AllTrim(IIF(lEnderecoCobranca,SA1->A1_BAIRROC,SA1->A1_BAIRRO)),oArial09 ) //alterado jonatas 20160212
	//oBoleto:Say(nBloco1+=015,nCol1,"Endereço. " + AllTrim(IIF(lEnderecoCobranca,SA1->A1_ENDCOB,SA1->A1_END)) + " - " + AllTrim(IIF(lEnderecoCobranca,SA1->A1_BAIRROC,SA1->A1_BAIRRO)),oArial09 ) //alterado jonatas 20160216


	cQbEnd := "Endereço. " + AllTrim(SA1->A1_END) + " - "
	cQbEnd += iif(AllTrim(SA1->A1_COMPLEM)="","", AllTrim(SA1->A1_COMPLEM) + " - ")
	cQbEnd += AllTrim(SA1->A1_BAIRRO)
	nBloco1+= 015
	nBlocoAux := nBloco1
	nLin := mlcount(cQbEnd,43)
	For i := 1 to nLin
		oBoleto:Say(nBlocoAux,nCol1, memoline(cQbEnd,43,i) ,oArial09 )
		nBlocoAux+= 7
		If i = 1
			oBoleto:Say(nBloco1     ,nCol2,"Ala: " + aDadosRM[1][4] + space(3) + "Unidade: " + aDadosRM[1][5] ,oArial09 )
		endif
	Next

	oBoleto:Say(nBlocoAux+=08,nCol1,"Cidade. " + AllTrim(SA1->A1_MUN),oArial09 )
	oBoleto:Say(nBloco1+=015,nCol2,"Contrato: " + aDadosRM[1][2],oArial09 )

//	oBoleto:Say(nBloco1+=015,nCol1,"CEP. " + transform(IIF(lEnderecoCobranca,SA1->A1_CEPC,SA1->A1_CEP),"@R 99999-999"),oArial09 ) //comentado jonatas 20160216
	oBoleto:Say(nBlocoAux+=015,nCol1,"CEP. " + transform(SA1->A1_CEP,"@R 99999-999"),oArial09 )
//	oBoleto:Say(nBloco1     ,nCol2,"Prestação. ",oArial09 ) //comentado jonatas paiva 16022016

	If SA1->A1_PESSOA == 'J'
		oBoleto:Say(nBlocoAux,nCol1+110,"CNPJ. " + transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),oArial09 )
	Else
		oBoleto:Say(nBlocoAux,nCol1+110,"CPF. " + transform(SA1->A1_CGC,"@R 999.999.999-99"),oArial09 )
	EndIf

	//Impressão diferente de acordo com o tipo de pagamento
	//Se pagamento diferente de 2 - Mensalidades, imprimir a descrição, caso contrário, imprimir o número da parcela.
	If aDadosRM[1][6] == '2' //Tipo de Pagamento for igual a mensalidade
		cDescRef := aDadosRM[1][7] //+ " " + aDadosRM[1][1] + "/" + aDadosRM[1][8]
	Else
		cDescRef := aDadosRM[1][7]
	EndIF
	IF !(lAglutinado)
		oBoleto:Say(nBloco1+30 ,nCol2,"Refêrencia da Prestação: " + cDescRef,oArial09 ) //comentado jonatas paiva 16022016
	Endif
	oBoleto:Say(nBloco1+=05     ,nCol3,"Vencimento",oArial12N )

	//oBoleto:Say(nBloco1+=015,nCol2,cRef,oArial09 ) //comentado jonatas paiva 16022016
	oBoleto:Say(nBloco1+=15     ,nCol3,FormDate(dVencimento),oArial12N )

	//oBoleto:Say(nBloco1+=030,nCol1,"Demonstrativo do encargo do mês ",oArial12N ) //comentado jonatas paiva 16022016
	//oBoleto:Say(nBloco1     ,nCol3,"Valor a pagar",oArial12N ) //comentado jonatas paiva 16022016
	oBoleto:Say(nBloco1+=30  ,nCol3,"Valor a pagar",oArial12N )

	//comentado jonatas paiva 16022016
	oBoleto:Say(nBloco1		,nCol1	   ,"     Prestação",oCourier06,,,,1 )
	oBoleto:Say(nBloco1     ,nCol1 + 55,"    Seguro",oCourier06,,,,1 )
	oBoleto:Say(nBloco1     ,nCol1 +110,"Diferenças",oCourier06,,,,1 )
	oBoleto:Say(nBloco1     ,nCol1 +165,"    Acordo",oCourier06,,,,1 )
	oBoleto:Say(nBloco1     ,nCol1 +220,"     Taxas",oCourier06,,,,1 )
	oBoleto:Say(nBloco1     ,nCol1 +275,"Mora/Multa",oCourier06,,,,1 )
	oBoleto:Say(nBloco1     ,nCol1 +335,"         Total",oCourier06,,,,1 )
	//oBoleto:Say(nBloco1     ,nCol1 +390,"Total ",oArial06 )
	// Se o tipo for TXI é para imprimir como TAXA
	// Fernando Nonato - 04/09/2017
	if SE1->E1_TIPO == "TXI"
		nPrestacao 	:= 0
		nTaxas		:= nValorDocumento - nSeguro - SE1->E1_XTAXAS - nTaxa - nMulta - nJuros
	Else
		nPrestacao 	:= nValorDocumento - nSeguro - SE1->E1_XTAXAS - nTaxa- nMulta - nJuros
		nTaxas		:= SE1->E1_XTAXAS + nTaxa
	Endif


	oBoleto:Say(nBloco1+=010,nCol1		,Transform(nPrestacao,"@E 999,999,999.99"),oCourier06,,,,1) // alinha a direita
	oBoleto:Say(nBloco1     ,nCol1 + 55	,Transform(nSeguro,"@E 999,999.99"),oCourier06,,,,1) // alinha a direita
	oBoleto:Say(nBloco1     ,nCol1 +110	,Transform(0.00,"@E 999,999.99"),oCourier06,,,,1) // alinha a direita
	oBoleto:Say(nBloco1     ,nCol1 +165	,Transform(0.00,"@E 999,999.99"),oCourier06,,,,1) // alinha a direita
	oBoleto:Say(nBloco1     ,nCol1 +220	,Transform(nTaxas,"@E 999,999.99"),oCourier06,,,,1) // alinha a direita
	oBoleto:Say(nBloco1     ,nCol1 +275	,Transform(nMulta+nJuros,"@E 999,999.99"),oCourier06,,,,1) // alinha a direita
	oBoleto:Say(nBloco1     ,nCol1 +335	,Transform(nValorDocumento,"@E 999,999,999.99"),oCourier06,,,,1) // alinha a direita

	if SE1->E1_TIPO == "TXI"
		oBoleto:Say(nBloco1+=030,nCol1	   ,SE1->E1_HIST,oCourier06,,,,1 )
	Endif

	nBloco1 := 155
	oBoleto:Say(nBloco1,nCol3,Transform(nValorDocumento,"@E 999,999,999.99"),oArial12N )

	oBoleto:Say(nBloco1+=011,nCol3,"Nosso numero documento",oArial06 )
	//oBoleto:Say(nBloco1+=015,nCol3,TransForm(cNossoNumero,"@R 99 999999999999999 9"),oArial12N )
	oBoleto:Say(nBloco1+=010,nCol3,TransForm(cNossoNumero+Modulo11(cNossoNumero),"@R 99999999999999999-9"),oArial12N )
	IF lAglutinado

		If MV_PAR24 == 1 // Se o boleto for normal
			oBoleto:Say(nBloco1-=010,nCol1     ,"Ref. Prestação ",oArial07N )
			oBoleto:Say(nBloco1     ,nCol1 +105,"Parcela",oArial07N )
			oBoleto:Say(nBloco1     ,nCol1 +205,"Vencimento",oArial07N )
			oBoleto:Say(nBloco1     ,nCol1 +323,"Total",oArial07N )

			for x := 1 to len(aTipos)
				oBoleto:Say(nBloco1+=10 ,nCol1     ,aTipos[x][4],oArial07 )
				oBoleto:Say(nBloco1     ,nCol1 +105,aTipos[x][1],oArial07 )
				oBoleto:Say(nBloco1     ,nCol1 +205,aTipos[x][2],oArial07 )
				oBoleto:Say(nBloco1     ,nCol1 +305,Transform(aTipos[x][3],"@E 999,999,999.99"),oArial07 )
			Next x
		ElseIf MV_PAR24 == 2
			oBoleto:Say(nBloco1+=30,nCol1+30     ,"LIQUIDACAO DE SALDO DEVEDOR",oArial18N  )
		ElseIf MV_PAR24 == 3
			oBoleto:Say(nBloco1+=30,nCol1+30     ,"AMORTIZACAO PARCIAL DE SALDO",oArial18N  )
		ElseIf MV_PAR24 == 4
			oBoleto:Say(nBloco1+=30,nCol1+30     ,"PARCELAS VENCIDAS",oArial18N  )
		Endif
	endif
/*	 //comentado jonatas paiva 05022016
	oBoleto:Say(nBloco1+=20 ,nCol1     ,"IPTU " + SubStr(DTOS(dDataBase),1,4),oArial09 )
	oBoleto:Say(nBloco1     ,nCol1 +205,"001/001 ",oArial09 )
	oBoleto:Say(nBloco1     ,nCol1 +305,"Total ",oArial09 )

	oBoleto:Say(nBloco1+=20 ,nCol1     ,"Pend. Manual " + SubStr(DTOS(dDataBase),1,4),oArial09 )
	oBoleto:Say(nBloco1     ,nCol1 +205,"001/001 ",oArial09 )
	oBoleto:Say(nBloco1     ,nCol1 +305,"Total ",oArial09 )

	If MV_PAR23 = 1
		oBoleto:Say(nBloco1+=20 ,nCol1     ,"Aviso Unico 15 dias atraso " + SubStr(DTOS(dDataBase),1,4),oArial09 )
		oBoleto:Say(nBloco1     ,nCol1 +205,"001/001 ",oArial09 )
		oBoleto:Say(nBloco1     ,nCol1 +305,SuperGetMV("MV_15DIAS", .F., '1,20'),oArial09 )

		oBoleto:Say(nBloco1+=20 ,nCol1     ,"Recibo Consolidado " + SubStr(DTOS(dDataBase),1,4),oArial09 )
		oBoleto:Say(nBloco1     ,nCol1 +205,"001/001 ",oArial09 )
		oBoleto:Say(nBloco1     ,nCol1 +305,TransForm(SuperGetMV("MV_RECCONS", .F., 3.75), "@R 999,99"),oArial09 )
	EndIf
  	//fim comentado
*/
/*//comentado jonatas paiva 16022016
	//COMECO INCLUSAO
	oBoleto:Say(nBloco1+=20 ,nCol1     ,"PRESTACAO" + SubStr(DTOS(dDataBase),1,4),oArial09 )
	oBoleto:Say(nBloco1     ,nCol1 +205,"001/001 ",oArial09 )
	oBoleto:Say(nBloco1     ,nCol1 +305,"Total ",oArial09 )

	oBoleto:Say(nBloco1+=20 ,nCol1     ,"Notificação por títulos e doc " + SubStr(DTOS(dDataBase),1,4),oArial09 )
	oBoleto:Say(nBloco1     ,nCol1 +205,"001/001 ",oArial09 )
	oBoleto:Say(nBloco1     ,nCol1 +305,"Total ",oArial09 )

	oBoleto:Say(nBloco1+=20 ,nCol1     ,"Aviso Único 15 dias atraso " + SubStr(DTOS(dDataBase),1,4),oArial09 )
	oBoleto:Say(nBloco1     ,nCol1 +205,"001/001 ",oArial09 )
	oBoleto:Say(nBloco1     ,nCol1 +305,SuperGetMV("MV_15DIAS", .F., '1,20'),oArial09 )

	oBoleto:Say(nBloco1+=20 ,nCol1     ,"Recibo Consolidado " + SubStr(DTOS(dDataBase),1,4),oArial09 )
	oBoleto:Say(nBloco1     ,nCol1 +205,"001/001 ",oArial09 )
	oBoleto:Say(nBloco1     ,nCol1 +305,TransForm(SuperGetMV("MV_RECCONS", .F., 3.75), "@R 999,99"),oArial09 )
	//FIM INCLUSAO
	*/
	//	oBoleto:Say(355,nCol1,"Evite pagamento em atraso, caso não receba seu boleto retire-o em nosso site",oArial12N )
	//oBoleto:Say(365,nCol1,"www.piemontemoveis.com.br até a data do vencimento.",oArial12N )

	nBloco1 := 0

	//linhas horizontais
	oBoleto:Line(nBloco1+=010,  20,nBloco1, 450 ,,"01")
	oBoleto:Line(nBloco1+=020,  20,nBloco1, 450 ,,"01")
	oBoleto:Line(nBloco1+=015,  20,nBloco1, 450 ,,"01")

	//oBoleto:Line(nBloco1+=060, 247,nBloco1, 450 ,,"01")
	oBoleto:Line(nBloco1+=035, 455,nBloco1, nLarg ,,"01")
	oBoleto:Line(nBloco1+=015, 455,nBloco1, nLarg ,,"01")
	//oBoleto:Line(nBloco1+=015, 247,nBloco1, 450 ,,"01")
	oBoleto:Line(nBloco1+=025,  20,nBloco1, 450 ,,"01")
	oBoleto:Line(nBloco1     , 455,nBloco1, nLarg ,,"01")


	oBoleto:Line(nBloco1+=005,  20,nBloco1, 450 ,,"01")
	oBoleto:Line(nBloco1	 , 455,nBloco1, nLarg ,,"01")
	//oBoleto:Line(nBloco1+=015,  20,nBloco1, 450 ,,"01")
	oBoleto:Line(nBloco1+=015, 455,nBloco1, nLarg ,,"01")
	oBoleto:Line(nBloco1+=020,  20,nBloco1, 450 ,,"01")
	oBoleto:Line(nBloco1	 , 455,nBloco1, nLarg ,,"01")
	oBoleto:Line(nBloco1+=025	 , 455,nBloco1, nLarg ,,"01")

	//oBoleto:Line(nBloco1+=020,  455,nBloco1,nLarg ,,"01")
	//oBoleto:Line(nBloco1+=020,  455,nBloco1,nLarg ,,"01")

	//oBoleto:Line(nBloco1+=120,  20,nBloco1,450 ,,"01")
	oBoleto:Line(nBloco1+=0190,  20,nBloco1,450 ,,"01")

	oBoleto:Say(nBloco1+=015,nCol1 +300,"Autenticação Mecânica - Recibo do Pagador",oArial06 )


	//Pontilhado separador
	For nPont := 10 to nLarg+10 Step 4
		oBoleto:Line(nBloco1+ 015, nPont,nBloco1 + 015, nPont+2,,)
	Next nPont

	nBloco1 := 0

	//linhas vericais
	oBoleto:Line(nBloco1+ 010,020,nBloco1+120,020 ,,"01")
	oBoleto:Line(nBloco1+ 010,247,nBloco1+120,247 ,,"01")
	oBoleto:Line(nBloco1+ 010,450,nBloco1+120,450 ,,"01")

	oBoleto:Line(nBloco1+ 080,455,nBloco1+120,455 ,,"01")
	oBoleto:Line(nBloco1+ 080,nLarg,nBloco1+120,nLarg ,,"01")

	oBoleto:Line(nBloco1+ 125,455  ,nBloco1+185,455 ,,"01")
	oBoleto:Line(nBloco1+ 125,nLarg,nBloco1+185,nLarg ,,"01")

	oBoleto:Line(nBloco1+ 125,020,nBloco1+375,020 ,,"01")
	oBoleto:Line(nBloco1+ 125,450,nBloco1+375,450 ,,"01")

	//oBoleto:Line(nBloco1+ 230,020,nBloco1+375,020 ,,"01")
	//oBoleto:Line(nBloco1+ 230,100,nBloco1+345,100 ,,"01")
	//oBoleto:Line(nBloco1+ 230,200,nBloco1+345,200 ,,"01")
	//oBoleto:Line(nBloco1+ 230,300,nBloco1+345,300 ,,"01")
	//oBoleto:Line(nBloco1+ 230,450,nBloco1+345,450 ,,"01")
	//oBoleto:Line(nBloco1+ 230,450,nBloco1+375,450 ,,"01")


	//Nome do Banco
	//oBoleto:Say(nBloco2+170,25,"CAIXA",oArial12N )
	//logo
	oBoleto:SayBitmap(nBloco2+157, 20, "\boletos\logos\Logo-Caixa.jpg", 75, 20)
	//Line(linha_inicial, coluna_inicial, linha final, coluna final)
	oBoleto:Line( nBloco2+157,  95, nBloco2+177,  95,,"01")
	oBoleto:Line( nBloco2+157, 146, nBloco2+177, 146,,"01")
	oBoleto:Line( nBloco2+177,  20, nBloco2+177,nLarg,,"01")

	//Numero do Banco
	oBoleto:Say(nBloco2+174,99,"104",oArial18N )

	//adiciona mais dois ao depois
	nBloco1 += 3

	//oBoleto:Say(nBloco2+174,150,cCodigoBarra,oArial16N)
	oBoleto:SayAlign(nBloco2+157,150,cLinhaDigitavel,oArial16N,400,,,1)

	ImprimeBloco(oBoleto, nBloco2)

	//oBoleto:Say(480,25,cCodigoBarra,oArial09N)
	//CODIGO DE BARRAS
	//oBoleto:Code128C(485,25,cCodigoBarra, 30 )

	/*
	//BLOCO 3
	nBloco3 := 50
	//Pontilhado separador
	For nPont := 10 to nLarg+10 Step 4
		oBoleto:Line(nBloco3+470, nPont,nBloco3+470, nPont+2,,)
	Next nPont

	//Nome do Banco
	oBoleto:Say(nBloco3+493,25,"HSBC",oArial12N )
	//logo
	oBoleto:SayBitmap(nBloco3+480, 20, "\boletos\logos\logo-banco-399.jpg", 75, 20)
	//Line(linha_inicial, coluna_inicial, linha final, coluna final)
	oBoleto:Line( nBloco3+480,  95, nBloco3+500,  95,,"01")
	oBoleto:Line( nBloco3+480, 146, nBloco3+500, 146,,"01")
	oBoleto:Line( nBloco3+500,  20, nBloco3+500,nLarg,,"01")

	//Numero do Banco
	oBoleto:Say(nBloco3+497,99,"104",oArial18N )
	//linha digitavel
	oBoleto:SayAlign(nBloco3+485,155,cLinhaDigitavel,oArial14,400,,,1)

	ImprimeBloco(oBoleto, nBloco3 + 323 )
	*/


	//Finaliza pagina
	oBoleto:EndPage()

	If MV_PAR24 <> 1
		u_RBolREL(@oBoleto, aTipos)
	Endif
//	RecLock("SE1",.F.)
//	SE1->E1_EMITBOL := "S"
//	MsUnLock("SE1")

Return


Static Function ImprimeBloco(oBoleto, nBloco)

	//bloco 2 linha 1 ->
	oBoleto:Say(nBloco+185,25 ,"Local de Pagamento",oArial06)
	oBoleto:Say(nBloco+197,25 ,"PREFERENCIALMENTE NAS CASAS LOTÉRIAS ATÉ O VALOR LIMITE",oArial09N)

	oBoleto:Say(nBloco+185,425 ,"Vencimento",oArial06)
	oBoleto:SayAlign(nBloco+187,435,FormDate(dVencimento),oArial09N,100,10,,1)

	//bloco 2 linha 2 ->
	oBoleto:Line( nBloco+202,  20, nBloco+202,nLarg,,"01")
	oBoleto:Say(nBloco+210,25 , "Beneficiario",oArial06)
	oBoleto:Say(nBloco+222,25 , SM0->M0_NOMECOM + transform(SM0->M0_CGC,"@R 99.999.999/9999-99") ,oArial09N)

	oBoleto:Say(nBloco+210,425 ,"Agência/Código Beneficiario",oArial06)
	//oBoleto:SayAlign(nBloco+212,435, SEE->EE_AGENCIA +" "+ alltrim(SEE->EE_CONTA),oArial09N,100,10,,1)
	oBoleto:SayAlign(nBloco+212,435,AllTrim(SEE->EE_AGENCIA) + "/" + AllTrim(SEE->EE_CODEMP) + "-" + Modulo11(SEE->EE_CODEMP),oArial09N,100,10,,1 )


	//bloco 2 linha 4 ->
	oBoleto:Line( nBloco+227,  20, nBloco+227,nLarg,,"01")
	oBoleto:Say(nBloco+233,25, "Data do Documento" ,oArial06)
	oBoleto:Say(nBloco+243,25, FormDate(SE1->E1_EMISSAO), oArial09N)

	oBoleto:Line(nBloco+227, 110, nBloco+247,110,,"01")
	oBoleto:Say(nBloco+233,115, "Nro. Documento"                                  ,oArial06)
	oBoleto:Say(nBloco+243,115, SE1->E1_PREFIXO+alltrim(SE1->E1_NUM)+IIF(Empty(SE1->E1_PARCELA),"","/")+SE1->E1_PARCELA ,oArial09N)

	oBoleto:Line(nBloco+227, 232, nBloco+247,232,,"01")
	oBoleto:Say(nBloco+233,237, "Espécie Doc."                                   ,oArial06)
	oBoleto:Say(nBloco+243,237, "DM"										,oArial09N) //Tipo do Titulo

	oBoleto:Line(nBloco+227, 293, nBloco+247,293,,"01")
	oBoleto:Say(nBloco+233,298, "Aceite"                                         ,oArial06)
	oBoleto:Say(nBloco+243,298, "NAO"                                             ,oArial09N)

	oBoleto:Line(nBloco+227, 339, nBloco+247,339,,"01")
	oBoleto:Say(nBloco+233,344, "Data do Processamento"                          ,oArial06)
	oBoleto:Say(nBloco+243,344, FormDate(dDataBase),oArial09N) // Data impressao

	oBoleto:Say(nBloco+233,425 ,"Nosso Número Documento",oArial06)
	//oBoleto:SayAlign(nBloco+234,435,TransForm(cNossoNumero,"@R 99 999999999999999 9"),oArial09N,100,10,,1)
	//oBoleto:Say(nBloco+234,435,TransForm(cNossoNumero,"@R 99 999 999 999 999 999 9"),oArial09N)
	oBoleto:SayAlign(nBloco+234,435,TransForm(cNossoNumero+Modulo11(cNossoNumero),"@R 99999999999999999-9"),oArial09N,100,10,,1)

	//bloco 2 linha 5 ->
	oBoleto:Line( nBloco+247,  20, nBloco+247,nLarg,,"01")
	oBoleto:Say(nBloco+253,25,"Uso do Banco"                                   ,oArial06)
	oBoleto:Say(nBloco+263,25,""                                   ,oArial09N)

	oBoleto:Line(nBloco+247,110, nBloco+267,110,,"01")
	oBoleto:Say(nBloco+253,115 ,"Carteira"                                       ,oArial06)
	oBoleto:Say(nBloco+263,115 ,SEE->EE_CODCART                                  	,oArial09N)

	oBoleto:Line(nBloco+247, 171, nBloco+267,171,,"01")
	oBoleto:Say(nBloco+253,176 ,"Espécie"                                        ,oArial06)
	oBoleto:Say(nBloco+263,176 ,"R$"                                             ,oArial09N)

	oBoleto:Line(nBloco+247, 232, nBloco+267,232,,"01")
	oBoleto:Say(nBloco+253,237,"Quantidade Moeda"                                     ,oArial06)
	oBoleto:Line(nBloco+247,339, nBloco+267,339,,"01")
	oBoleto:Say(nBloco+253,344,"Valor Moeda"                                          ,oArial06)

	oBoleto:Say(nBloco+253,425 ,"(+)Valor do Documento",oArial06)
	IF lVencido
		oBoleto:SayAlign(nBloco+254,435,Transform(nValorDocumento-(nMulta+nJuros),"@E 999,999,999.99"),oArial09N,100,10,,1)
	Else
		oBoleto:SayAlign(nBloco+254,435,Transform(nValorDocumento,"@E 999,999,999.99"),oArial09N,100,10,,1)
	EndIF

	//bloco 2 linha 6 ->ª
	oBoleto:Line( nBloco+267,  20, nBloco+267,nLarg,,"01")
	oBoleto:Say( nBloco+273,25, "INSTRUÇÕES: (TEXTO DE RESPONSABILIDADE DO CEDENTE)" , oArial06)

	oBoleto:Say(nBloco+293,0025,aInstrucoes[1],oArial09N)
	oBoleto:Say(nBloco+303,0025,aInstrucoes[2],oArial09N)
	oBoleto:Say(nBloco+313,0025,aInstrucoes[3],oArial09N)
	oBoleto:Say(nBloco+323,0025,aInstrucoes[4],oArial09N)

	oBoleto:Say(nBloco+273,425,"(-)Desconto/Abatimento",oArial06)

	//bloco 2 linha 7 ->
	oBoleto:Line( nBloco+287,  420, nBloco+287,nLarg,,"01")
	oBoleto:Say(nBloco+293,425,"(-)Outras Deduções",oArial06)

	//bloco 2 linha 8 ->
	oBoleto:Line( nBloco+307,  420, nBloco+307,nLarg,,"01")
	oBoleto:Say(nBloco+313,425,"(+)Mora/Multa",oArial06)
	IF lVencido
		oBoleto:SayAlign(nBloco+314,435,Transform(nMulta,"@E 999,999,999.99"),oArial09N,100,10,,1)
	EndIF

	//bloco 2 linha 9 ->
	oBoleto:Line( nBloco+327,  420, nBloco+327,nLarg,,"01")
	oBoleto:Say(nBloco+333,425,"(+)Outros Acréscimos",oArial06)
	IF lVencido
		oBoleto:SayAlign(nBloco+334,435,Transform(nJuros,"@E 999,999,999.99"),oArial09N,100,10,,1)
	EndIF

	//bloco 2 linha 10 ->
	oBoleto:Line( nBloco+347,  420, nBloco+347,nLarg,,"01")
	oBoleto:Say(nBloco+353,425,"(=)Valor Cobrado",oArial06)
	oBoleto:Line( nBloco+177,  420, nBloco+367,420,,"01")
	IF lVencido
		oBoleto:SayAlign(nBloco+354,435,Transform(nValorDocumento,"@E 999,999,999.99"),oArial12N,100,10,,1)
	EndIF

	//bloco 2 Sacado ->
	oBoleto:Line( nBloco+367,  20, nBloco+367,nLarg,,"01")
	oBoleto:Say(nBloco+376,25 ,"Pagador",oArial06)

	oBoleto:Say(nBloco+376,90 ,alltrim(SA1->A1_NOME) + " (" +SA1->A1_COD+" - "+SA1->A1_LOJA+")",oArial09N)

	IF SA1->A1_PESSOA == "J"
		oBoleto:Say(nBloco+376,420 ," CNPJ: " + transform(SA1->A1_CGC,"@R 99.999.999/9999-99") ,oArial09N)
	Else
		oBoleto:Say(nBloco+376,420 ," CPF: " + transform(SA1->A1_CGC,"@R 999.999.999-99") ,oArial09N)
	EndIF
	//oBoleto:Say(nBloco+386,90 ,IIF(lEnderecoCobranca,SA1->A1_ENDCOB,SA1->A1_END) + " - " + IIF(lEnderecoCobranca,SA1->A1_BAIRROC,SA1->A1_BAIRRO) ,oArial09N) //comentado jonatas 20160216
	oBoleto:Say(nBloco+386,90 ,SA1->A1_END + " - " + SA1->A1_BAIRRO ,oArial09N)
	//oBoleto:Say(nBloco+396,90 ,transform(IIF(lEnderecoCobranca,SA1->A1_CEPC,SA1->A1_CEP),"@R 99999-999")+ " - " + alltrim(IIF(lEnderecoCobranca,SA1->A1_MUNC,SA1->A1_MUN))+"/"+IIF(lEnderecoCobranca,SA1->A1_ESTC,SA1->A1_EST) ,oArial09N) //comentado jonatas 20160216
	oBoleto:Say(nBloco+396,90 ,transform(SA1->A1_CEP,"@R 99999-999")+ " - " + alltrim(SA1->A1_MUN)+"/"+ SA1->A1_EST ,oArial09N)

	//oBoleto:Say(nBloco+386,90 ,IIF(lEnderecoCobranca,SA1->A1_ENDCOB,SA1->A1_END) + " - " + IIF(lEnderecoCobranca,SA1->A1_BAIRROC,SA1->A1_BAIRRO) ,oArial09N)
	//oBoleto:Say(nBloco+396,90 ,transform(IIF(lEnderecoCobranca,SA1->A1_CEPC,SA1->A1_CEP),"@R 99999-999")+ " - " + alltrim(IIF(lEnderecoCobranca,SA1->A1_MUNC,SA1->A1_MUN))+"/"+IIF(lEnderecoCobranca,SA1->A1_ESTC,SA1->A1_EST) ,oArial09N)



	/*
	oBoleto:Say(nBloco+406,430 ,cNossoNumero ,oArial09N)
	*/

	//bloco 2 Sacado - autenticação ->
	oBoleto:Say(nBloco+406, 25, "Sacado/Avalista" , oArial06)
	oBoleto:Line( nBloco+410,  20, nBloco+410,nLarg,,"01")
	oBoleto:Say(nBloco+416,420, "Autenticação Mecânica - Ficha de compensação" , oArial06)

	//CODIGO DE BARRAS
	//oBoleto:Code128C(nBloco + 445,25,cCodigoBarra, 30 )
	//oBoleto:Say(nBloco+440,25, cCodigoBarra , oArial09N)
	//oBoleto:int25(nBloco + 445,25,cCodigoBarra,1,55)

	oBoleto:FWMSBAR("INT25", 56, 1.6, cCodigoBarra, oBoleto,.F.,,,,0.8,.F.,"Arial",NIL,.F.,1,1,.F.)


Return

/*
User Function b399NossoNum()

	//gera nosso numero
	NossoNum()

	RecLock("SE1",.F.)
	SE1->E1_BCOBOL := "399"
	SE1->( MsUnlock() )

Return
*/

Static Function GetNossoNumero()

	//Funcao NossoNum, precisa que as tabelas SE1 e SEE estejam posicionadas,
	//retorna o NN gravado no E1_NUMBCO, com o tamanho do EE_FAXATU
	Local cNossoNum := STRZero(Val(alltrim(myNossoNum())), 15)

	Local cCarteira	:= SuperGetMV("MV_XCTCEF", .F., '14')
	//Local cCarteira	:= SuperGetMV("MV_XCTCEF", .F., '14') //comentado jonatas 20160216
	Local cDigito	:= Modulo11(cCarteira + cNossoNum)

	//Alert(NossoNum())

	//Alert(Right(alltrim(NossoNum()), 15))

	//Alert(cDigito)

	//Alert(SEE->EE_CODIGO)

	/*
	Local aPeso := {5, 4, 3, 2, 7, 6, 5, 4, 3, 2}
	Local n1    := 0
	Local nAux := 0
	Local nBase := 0

	For n1 := 1 To 10
		nAux := Val(SubStr(cNossoNum, n1, 1))
		nBase += nAux * aPeso[n1]
	Next n1
	nAux := nBase % 11

	IF (nAux # 0) .and. (nAux # 1)
		cDigito := Str(11 - nAux, 1)
	EndIF
	*/

Return cCarteira + cNossoNum


Static Function BolCodBar()

	//Local cCarteira := SuperGetMV("MV_XCTCEF", .F., '14') //comentado jonatas 20160216
	Local cCarteira := SuperGetMV("MV_XCTCEF", .F., '14') //'24'  CONDICAO DA PIEMONTE. SE FOR A PRIMEIRA PARCELA, É SINAL DE NEGOCIO, E NAO REGISTRA NO BANCO

	Local cCodigo1 := SEE->EE_CODIGO +; 									//banco 104
	IIF(SE1->E1_MOEDA==1,"9","0")							// 9- Real
	Local cCodigo2 := StrZero((dVencimento - CtoD("07/10/97")), 4) + ;  //Fator de vencimento
	StrZero(nValorDocumento * 100, 10) 					//Valor do titulo
	Local cCodigo3 := AllTrim(SEE->EE_CODEMP) +    ;						//Codigo do convenio
	Modulo11(AllTrim(SEE->EE_CODEMP)) +;					//DV Convenio
	substr(cNossoNumero,3,3) + substr(cCarteira,1,1)+;    //Campo livre + 1-Registrada
	substr(cNossoNumero,6,3) + substr(cCarteira,2,1)+;    //Campo Livre + 4-Beneficiario
	substr(cNossoNumero,9,9) 							    //Restante campo livre

	Local cCodeBar :=""

	cCodigo2 		 :=cCodigo2 + cCodigo3 + Modulo11(cCodigo3)

	cCodebar		 := cCodigo1 + BolDigBar(cCodigo1 + cCodigo2) + cCodigo2

	cLinhaDigitavel  := cCodigo1+ SubSTR(cCodebar,20,5)+BolDigVer(cCodigo1+ SubSTR(cCodebar,20,5))+;
		SubSTR(cCodebar,25,10)+BolDigVer(SubSTR(cCodebar,25,10))+;
		SubSTR(cCodebar,35,10)+BolDigVer(SubSTR(cCodebar,35,10))+;
		SubSTR(cCodebar,5,1)+;
		SubSTR(cCodebar,6,4)+ SubSTR(cCodebar,10,10)
	cLinhaDigitavel  :=	Transform(cLinhaDigitavel, "@R 99999.99999  99999.999999  99999.999999  9  99999999999999")

Return cCodeBar

/*
Static Function BolDigBar(cNumero)

	Local cDigito := "1"
	Local nPeso := 1
	Local n1    := 0
	Local nAux := 0
	Local nBase := 0

	For n1 := Len(cNumero) To 1 Step -1
		nPeso++
		nAux := Val(SubStr(cNumero, n1, 1))
		nBase += nAux * nPeso
		IF nPeso == 9
			nPeso := 1
		EndIF
	Next n1
	nAux := nBase % 11

	If (nAux # 0) .and. (nAux # 1) .and. (nAux # 10)
		cDigito := Str(11 - nAux, 1)
	EndIf


	If ValType(cDigito) = 'N'
		cDigito := Str(cDigito)
	EndIf


Return cDigito
*/

Static Function BolDigBar(cNumero)
	Local L, D, P := 0
	L := Len(cNumero)
	D := 0
	P := 1
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cNumero, L, 1)) * P)
		If P = 9
			P := 1
		Endif
		L := L - 1
	Enddo
	D := 11 - (mod(D,11))


	If (D == 1 .Or. D == 0 .Or. D == 10 .Or. D == 11)
		D := 1
	End

	D := AllTrim(Str(D))

Return(D)

Static Function BolDigVer(cNumero)

	Local cDigito := "0"
	Local nPeso := 2
	Local n1    := 0
	Local nAux := 0
	Local nBase := 0

	For n1 := Len(cNumero) To 1 Step -1
		nAux := Val(SubStr(cNumero, n1, 1))
		nAux *= nPeso
		If nAux > 9
			nAux -= 9
		EndIf
		nBase += nAux
		nPeso := If(nPeso == 1, 2, 1)
	Next

	If nBase < 10
		cDigito := Str(10 - nBase, 1)
	Else
		nAux := nBase % 10
		If !Empty(nAux)
			cDigito := Str(10 - nAux, 1)
		EndIf
	EndIf

Return cDigito


//-----------------------------------------
/*/{Protheus.doc} Modulo11
Processa Modulo11

@author Lucas
@since 10/04/2015
@version 1.0

@param cData, character, Dados para processamento

@return numérico Retorno do processamento

@protected
/*/
//-----------------------------------------
/*Static Function Modulo11(cData)

	LOCAL L, D, P := 0

	L := LEN(cdata)
	D := 0
	P := 1

	WHILE L > 0
		P := P + 1
		D := D + (VAL(SUBSTR(cData, L, 1)) * P)
		IF P = 9
			P := 1
		ENDIF
		L := L - 1
	ENDDO

	D := 11 - (mod(D,11))
	IF (D == 0 .Or. D == 1 .Or. D > 9)
		D := 1
	ENDIF

RETURN(D)
*/

//-----------------------------------------
/*/{Protheus.doc} BuscaDados
Busca dados dos títulos

@author Hugo
@since 10/04/2015
@version 1.0

@return character Variável contendo a query de busca de dados.

@protected
/*/
//-----------------------------------------
static Function BuscaDados()

	Local cQuery := ""

	If (Select("QRY") <> 0)
		dbSelectArea("QRY")
		dbCloseArea()
	Endif

	//If !lNF
	cQuery := " SELECT * FROM " + RetSqlName("SE1") + " SE1"
	cQuery += " WHERE SE1.E1_FILIAL >= '' AND SE1.E1_FILIAL <= 'ZZZZZZ' AND"
//		cQuery += " WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' AND "
	cQuery += " SE1.E1_PREFIXO 	>= '"+MV_PAR01+"' AND SE1.E1_PREFIXO 	<= '"+MV_PAR02+"' AND"
	cQuery += " SE1.E1_NUM	   	>= '"+MV_PAR03+"' AND SE1.E1_NUM 		<= '"+MV_PAR04+"' AND"
	cQuery += " SE1.E1_PARCELA 	>= '"+MV_PAR05+"' AND SE1.E1_PARCELA	<= '"+MV_PAR06+"' AND"
	cQuery += " SE1.E1_TIPO 	>= '"+MV_PAR07+"' AND SE1.E1_TIPO		<= '"+MV_PAR08+"' AND"
	cQuery += " SE1.E1_CLIENTE 	>= '"+MV_PAR09+"' AND SE1.E1_CLIENTE	<= '"+MV_PAR10+"' AND"
	cQuery += " SE1.E1_LOJA 	>= '"+MV_PAR11+"' AND SE1.E1_LOJA		<= '"+MV_PAR12+"' AND"
	cQuery += " SE1.E1_VENCTO 	>= '"+DTOS(MV_PAR13)+"' AND SE1.E1_VENCTO	<= '"+DTOS(MV_PAR14)+"' AND"
	cQuery += " SE1.E1_EMISSAO 	>= '"+DTOS(MV_PAR15)+"' AND SE1.E1_EMISSAO	<= '"+DTOS(MV_PAR16)+"' AND"
	cQuery += " SE1.E1_PORTADO 	=  '"+PADL(MV_PAR17,3,"")+"' AND"
	cQuery += " SE1.E1_AGEDEP 	=  '"+PADL(MV_PAR18,5,"")+"' AND"
	cQuery += " SE1.E1_CONTA 	=  '"+PADL(MV_PAR19,10,"")+"' AND"
	cQuery += " SE1.E1_NUMBOR 	>= '"+MV_PAR21+"' AND SE1.E1_NUMBOR	<= '"+MV_PAR22+"' AND"
	cQuery += " SE1.E1_NUMBOR <> '' AND"
	cQuery += " SE1.E1_SALDO > '0' AND"

	// Ricardo Rocha 12/11/2015 - Regra do TMK
	cQuery+=" E1_SITUACA<>'5' and "

	cQuery += " SE1.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_EMISSAO"

		/*
Else
		cQuery:= " SELECT * FROM "+RetSqlName("SE1")
		cQuery+= " WHERE E1_PREFIXO = '" + MV_PAR01 + "' "
		cQuery+= " AND E1_NUM = '" + MV_PAR03 + "' "
		cQuery+= " AND E1_FILIAL = '"+xFilial("SE1") + "' "
		cQuery+= " AND D_E_L_E_T_ = ' ' "
	If !Empty(MV_PAR09)
			cQuery+= " AND E1_NUMBOR = '" + MV_PAR09 + "' "
			cQuery+= " AND E1_PORTADO = '" + PADL(MV_PAR05,3,"") + "' "
			cQuery+= " AND E1_AGEDEP = '" + PADL(MV_PAR06,5,"") + "' "
			cQuery+= " AND E1_CONTA = '" + PADL(MV_PAR07,10,"") + "' "
	ElseIf !Empty(MV_PAR05)
			cQuery+= " AND E1_PORTADO = '" + MV_PAR13 + "' "
	EndIf                                                                                                                                                     ?
		cQuery+= " ORDER BY E1_NUM,E1_PARCELA "
EndIf
	*/

cQuery := ChangeQuery(cQuery)

Memowrite("c:\temp\QRY_BOL_CAIXA.txt",cQuery)

//Verifica se a area já existe e fecha para ser recriada.
If (Select("QAA")) <> 0
	dbselectarea("QAA")
	QAA->(dbclosearea())
EndIf

TcQuery	cQuery New Alias 'QAA'

DbSelectArea('QAA')
QAA->(DbGoTop())

Return cQuery

User Function fFINI055( aDadosRM, cPrefixo, cTitulo )

//Variaveis
	Local _cSql     := ""
	Local _cSqlRM	:= ""
	Local _cTitulo  := AllTrim(cTitulo)
	Local _cPrefixo := AllTrim(cPrefixo)
	Local cNumVenda	:= ""
	Local cTipoPgto	:= ""
	Local cDescPgto	:= ""
	Local cParcela 	:= ""
	Local cContrato := ""
	Local cEmpreend := ""
	Local cUnidade 	:= ""
	Local cSubUnid 	:= ""
	Local cCCusto	:= ""
	Local cCaract	:= ""
	Local aIDLan 	:= {}
	Local aDados	:= {}
	Local cIdSeg	:= "41"
	Local cIdTx		:= "109"
	Local i 		:= 0

//Query de integração com o RM - Buscar dados do contrato
//Primeira Query - Tabela XXF, buscar de acordo com o título da passado pela SE1
// _cSql := " SELECT "
// _cSql += " XXF_EXTVAL FROM XXF "
// _cSql += " WHERE XXF_FIELD = 'E1_NUM' "
// _cSql += " AND XXF_REFER = 'RM' "
// _cSql += " AND XXF_TABLE = '" + RetSqlName("SE1") +"' "
// _cSql += " AND XXF_INTVAL = '04|" + xFilial("SE1") + "|" + _cPrefixo + "|" + _cTitulo + "||NF' "

	_cSql += "SELECT VALORRM as XXF_EXTVAL "
	_cSql += "FROM RM.GEAIDEPARA "
	_cSql += "WHERE  VALOREXTERNO = '" + cEmpAnt + "|" + xFilial("SE1") + "|" + _cPrefixo + "|" + _cTitulo + "||NF" + "' "
	_cSql += "AND TABELARM = 'FLAN'"

	_cSql := ChangeQuery(_cSql)
	Memowrite("c:\temp\QRY_BOL_CAIXA_XXF.txt",_cSql)

	//Verifica se a area já existe e fecha para ser recriada.
	If (Select("TMP")) <> 0
		dbselectarea("TMP")
		TMP->(dbclosearea())
	EndIf

	TcQuery	_cSql New Alias 'TMP'

	DbSelectArea('TMP')
	TMP->(DbGoTop())

	//Posicao[1] = 04 Posicao[2] = IDLAN
	If !Empty(AllTrim(TMP->XXF_EXTVAL))
		aIDLan := StrToKarr(TMP->XXF_EXTVAL,"|")
	Else
		aadd(aIDLan,{"0"})
		aadd(aIDLan,{"0"})
	EndIf
	//Fecha tabela TMP Temporária
	TMP->(DbCloseArea())

	//Inicia segunda Query - Direto no banco do RM, para consultar os dados do contrato, de acordo com o ID LAN
	//Verifica se a area já existe e fecha para ser recriada.
	If (Select("SRM")) <> 0
		dbselectarea("SRM")
		SRM->(dbclosearea())
	EndIf
	cLinha := SuperGetMv("MV_XIDSEG",.F.,"")
	aDados := Separa(cLinha,";",.T.)
	i := 0
	For i:=1 to Len(aDados)
		If alltrim(aDados[i]) <> ""
			If Substr(aDados[i],1,2) = Substr(cFilAnt,1,2)
				cIdSeg := Substr(aDados[i],4,len(aDados[i])-3)
			Endif
		Endif
	Next i
	cLinha := SuperGetMv("MV_XIDTX",.F.,"")
	aDados := Separa(cLinha,";",.T.)
	i := 0
	For i:=1 to Len(aDados)
		If alltrim(aDados[i]) <> ""
			If Substr(aDados[i],1,2) = Substr(cFilAnt,1,2)
				cIdTx := Substr(aDados[i],4,len(aDados[i])-3)
			Endif
		Endif
	Next i
	_cSqlRM	:= " SELECT "
	_cSqlRM += "	V.NUM_VENDA NUM_VENDA, "
	_cSqlRM	+= "	P.COD_TIPO_PARC TIPO_PAGAMENTO, "
	_cSqlRM	+= "	X.DSC_COMPN DESC_PAGAMENTO, "
	_cSqlRM	+= "	P.NUM_PARC NUM_PARCELA, "
	_cSqlRM	+= "	T.CONTRATO CONTRATO, "
	_cSqlRM	+= "	E.NOMEFANTASIA EMPREENDIMENTO, "
	_cSqlRM	+= "	I.NUM_UNID UNIDADE, "
	_cSqlRM	+= "	I.NUM_SUB_UNID SUB_UNIDADE, "
	_cSqlRM	+= "	E.CODCCUSTO CCUSTO, "
	_cSqlRM	+= "	FSEG.VALOR SEGURO,"
	_cSqlRM	+= "	FTX.VALOR TAXAS,"
	_cSqlRM	+= "	CAR.COD_TIPO_CARAC TIPO_CARAC, "
	_cSqlRM	+= "	P.COD_GRUPO COD_GRUPO, "
	_cSqlRM	+= "	REGCOM.QTD_PARC QTD_PARC"
	_cSqlRM	+= " FROM RM.XVENDA V "
	_cSqlRM	+= " 	LEFT JOIN  RM.XPARCELAPAGAMENTO P ON  V.CODCOLIGADA = P.CODCOLIGADA AND V.NUM_VENDA = P.NUM_VENDA "
	_cSqlRM	+= "	LEFT JOIN RM.XEMPREENDIMENTO E ON E.CODCOLIGADA = V.CODCOLIGADA AND E.COD_PESS_EMPR = V.COD_PESS_EMPR "
	_cSqlRM	+= "	LEFT JOIN RM.XITEMVENDA I ON I.NUM_VENDA = V.NUM_VENDA AND  I.COD_PESS_EMPR = V.COD_PESS_EMPR "
	_cSqlRM += "	LEFT JOIN RM.XCONTRATO T ON T.NUM_CONT = V.NUM_CONT "
	_cSqlRM	+= "  	LEFT JOIN RM.XCOMPONENTE X ON X.COD_COMPN = P.COD_TIPO_PARC "
	_cSqlRM	+= "	LEFT JOIN RM.FLANINTEGRACAO FSEG ON FSEG.IDLAN = P.IDLAN AND FSEG.CODCOLIGADA = P.CODCOLIGADA AND FSEG.IDCAMPO = " + cIdSeg //41 "
	_cSqlRM	+= "	LEFT JOIN RM.FLANINTEGRACAO FTX ON FTX.IDLAN = P.IDLAN AND FTX.CODCOLIGADA = P.CODCOLIGADA AND FTX.IDCAMPO = " + cIdTx //109 "
	_cSqlRM	+= "	LEFT JOIN RM.XCARACTERISTICALOTE CAR ON CAR.COD_PESS_EMPR = I.COD_PESS_EMPR AND CAR.NUM_UNID = I.NUM_UNID AND CAR.NUM_SUB_UNID = I.NUM_SUB_UNID "
	_cSqlRM	+= "	LEFT JOIN RM.XREGRACOMPONENTEVENDA REGCOM ON REGCOM.NUM_VENDA = V.NUM_VENDA AND REGCOM.CODCOLIGADA = V.CODCOLIGADA "
	_cSqlRM	+= "		AND REGCOM.COD_COMPN = X.COD_COMPN AND REGCOM.COD_GRUPO = P.COD_GRUPO "
	_cSqlRM	+= " WHERE "
	_cSqlRM	+= "  	P.IDLAN = '" + IIF(!empty(aIDLan[2]),AllTrim(aIDLan[2]),"0") + "' AND P.CODCOLIGADA = '" + IIF(!empty(aIDLan[1]),AllTrim(aIDLan[1]),"0") + "'" //Numero do ID LAN

	Memowrite("c:\temp\QRY_integra_rm.txt",_cSqlRM)
	TcQuery	_cSqlRM New Alias 'SRM'

	//Seleciona a Tabela Temporaria com os dados do contrato
	DbSelectArea('SRM')
	SRM->(DbGoTop())
	//Alimenta as variaveis. Se não chegar a informação do Select, manda variavel vazia.
	cNumVenda	:= AllTrim(IIF(Empty(cValToChar(SRM->NUM_VENDA)),"",cValToChar(SRM->NUM_VENDA)))
	cTipoPgto	:= AllTrim(IIF(Empty(cValToChar(SRM->TIPO_PAGAMENTO)),"",cValToChar(SRM->TIPO_PAGAMENTO)))
	cDescPgto	:= AllTrim(IIF(Empty(SRM->DESC_PAGAMENTO),"",SRM->DESC_PAGAMENTO))
	cParcela 	:= AllTrim(IIF(Empty(cValToChar(SRM->NUM_PARCELA)),"",cValToChar(SRM->NUM_PARCELA)))
	cContrato 	:= AllTrim(IIF(Empty(cValToChar(SRM->CONTRATO)),"",cValToChar(SRM->CONTRATO)))
	cEmpreend 	:= AllTrim(IIF(Empty(SRM->EMPREENDIMENTO),"",SRM->EMPREENDIMENTO))
	cUnidade 	:= AllTrim(IIF(Empty(SRM->UNIDADE),"",SRM->UNIDADE))
	cSubUnid 	:= AllTrim(IIF(Empty(SRM->SUB_UNIDADE),"",SRM->SUB_UNIDADE))
	cCCusto 	:= AllTrim(IIF(Empty(SRM->CCUSTO),"",SRM->CCUSTO))
	cSeguro 	:= SRM->SEGURO
	cTaxas 		:= SRM->TAXAS
	cCaract		:= alltrim(str(SRM->TIPO_CARAC))
	cCodGrp		:= alltrim(str(SRM->COD_GRUPO))
	cNumParc	:= AllTrim(IIF(Empty(cValToChar(SRM->QTD_PARC)),"",cValToChar(SRM->QTD_PARC)))
	SRM->(DbCloseArea())

	//Busca a quantidade de parcelas do titulo
/*
	If (Select("SRP")) <> 0
		dbselectarea("SRP")
		SRP->(dbclosearea())
	EndIf
	
	

	_cSqlRM2	:= " SELECT MAX(V.NUM_PARC) NUM_PARC  "
	_cSqlRM2	+= " FROM RM.XPARCELAPAGAMENTO V "
	_cSqlRM2	+= " WHERE NUM_VENDA = '" + cNumVenda + "' and COD_GRUPO = '" + cCodGrp + "' "

	TcQuery	_cSqlRM2 New Alias 'SRP'

	DbSelectArea('SRP')
	SRP->(DbGoTop())
		cNumParc	:= AllTrim(IIF(Empty(cValToChar(SRP->NUM_PARC)),"",cValToChar(SRP->NUM_PARC)))
	SRP->(DbCloseArea())
*/
	//Adiciona Valores no Retorno

	aaDD(aDadosRM,{cParcela,cContrato,cEmpreend,cUnidade,cSubUnid,cTipoPgto,cDescPgto,cNumParc,cCCusto,cSeguro,cCaract, cTaxas})

Return aDadosRM

//-----------------------------------------
/*/{Protheus.doc} CriaSX1
Cria grupo de perguntas

@author Hugo
@since 10/04/2015
@version 1.0

@protected
/*/
//-----------------------------------------
Static Function CriaSX1(cPerg)

	_cAlias := Alias()

	xPutSX1(cPerg, "01", "Prefixo de"             , "", "", "mv_ch1" , "C", 03,  0, 0, "G", "", ""   , "", "", "mv_par01", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "02", "Prefixo Ate"            , "", "", "mv_ch2" , "C", 03,  0, 0, "G", "", ""   , "", "", "mv_par02", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "03", "Titulo de"              , "", "", "mv_ch3" , "C", 09,  0, 0, "G", "", "SE1", "", "", "mv_par03", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "04", "Titulo Ate"             , "", "", "mv_ch4" , "C", 09,  0, 0, "G", "", "SE1", "", "", "mv_par04", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "05", "Parcela De"             , "", "", "mv_ch5" , "C", 02,  0, 0, "G", "", ""	, "", "", "mv_par05", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "06", "Parcela Ate"            , "", "", "mv_ch6" , "C", 02,  0, 0, "G", "", ""   , "", "", "mv_par06", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "07", "Tipo De"	             , "", "", "mv_ch7" , "C", 03,  0, 0, "G", "", ""   , "", "", "mv_par07", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "08", "Tipo Ate"  	         , "", "", "mv_ch8" , "C", 03,  0, 0, "G", "", ""   , "", "", "mv_par08", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "09", "Cliente de"             , "", "", "mv_ch9" , "C", 06,  0, 0, "G", "", "SA1", "", "", "mv_par09", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "10", "Cliente Ate"            , "", "", "mv_ch10", "C", 06,  0, 0, "G", "", "SA1", "", "", "mv_par10", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "11", "Loja De"	             , "", "", "mv_ch11", "C", 02,  0, 0, "G", "", ""	, "", "", "mv_par11", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "12", "Loja Ate"	             , "", "", "mv_ch12", "C", 02,  0, 0, "G", "", ""	, "", "", "mv_par12", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "13", "Vencimento de"          , "", "", "mv_ch13", "D", 08,  0, 0, "G", "", ""   , "", "", "mv_par13", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "14", "Vencimento ate"         , "", "", "mv_ch14", "D", 08,  0, 0, "G", "", ""   , "", "", "mv_par14", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "15", "Emissao de"          	 , "", "", "mv_ch15", "D", 08,  0, 0, "G", "", ""   , "", "", "mv_par15", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "16", "Emissao de"          	 , "", "", "mv_ch16", "D", 08,  0, 0, "G", "", ""   , "", "", "mv_par16", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "17", "Banco "          	 	 , "", "", "mv_ch17", "C", 03,  0, 0, "G", "", "SEE", "", "", "mv_par17", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "18", "Agencia"          	 	 , "", "", "mv_ch18", "C", 05,  0, 0, "G", "", ""   , "", "", "mv_par18", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "19", "Conta"           	 	 , "", "", "mv_ch19", "C", 10,  0, 0, "G", "", ""   , "", "", "mv_par19", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "20", "Sub-Conta"          	 , "", "", "mv_ch20", "C", 03,  0, 0, "G", "", ""   , "", "", "mv_par20", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "21", "Bordero De"       	 	 , "", "", "mv_ch21", "C", 06,  0, 0, "G", "", ""   , "", "", "mv_par21", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "22", "Bordero Ate"      	 	 , "", "", "mv_ch22", "C", 06,  0, 0, "G", "", ""   , "", "", "mv_par22", "","","","","","","","","","","","","","","","")
	xPutSX1(cPerg, "23", "Segunda Via"      	 	 , "", "", "mv_ch23", "C", 06,  0, 2, "C", "", ""   , "", "", "mv_par23", "SIM","SIM","SIM","NÃO","NÃO","NÃO","","","","","","","","","","")
	xPutSX1(cPerg, "24", "Tipo de Boleto"      	 	 , "", "", "mv_ch24", "C", 01,  0, 2, "C", "", ""   , "", "", "mv_par24", "NORMAL","NORMAL","NORMAL","LIQ SALDO DEVED","LIQ SALDO DEVED","LIQ SALDO DEVED","AMORT PARC SALD","AMORT PARC SALD","AMORT PARC SALD","PARCELAS VENCIDAS","PARCELAS VENCIDAS","PARCELAS VENCIDAS","","","","")
	dbSelectArea(_cAlias)

Return


Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
		cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
		cF3, cGrpSxg,cPyme,;
		cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
		cDef02,cDefSpa2,cDefEng2,;
		cDef03,cDefSpa3,cDefEng3,;
		cDef04,cDefSpa4,cDefEng4,;
		cDef05,cDefSpa5,cDefEng5,;
		aHelpPor,aHelpEng,aHelpSpa,cHelp)

	LOCAL aArea := GetArea()
	Local cKey
	Local lPort := .f.
	Local lSpa := .f.
	Local lIngl := .f.

	cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."

	cPyme    := Iif( cPyme           == Nil, " ", cPyme          )
	cF3      := Iif( cF3           == NIl, " ", cF3          )
	cGrpSxg := Iif( cGrpSxg     == Nil, " ", cGrpSxg     )
	cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01      )
	cHelp      := Iif( cHelp          == Nil, "" , cHelp          )

	dbSelectArea( "SX1" )
	dbSetOrder( 1 )

// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

	If !( DbSeek( cGrupo + cOrdem ))

		cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

		Reclock( "SX1" , .T. )

		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA With cPerSpa
		Replace X1_PERENG With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid

		Replace X1_VAR01   With cVar01

		Replace X1_F3      With cF3
		Replace X1_GRPSXG With cGrpSxg

		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif

		Replace X1_CNT01   With cCnt01
		If cGSC == "C"               // Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1

			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2

			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3

			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4

			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif

		Replace X1_HELP With cHelp

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

		MsUnlock()
	Else

		lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
		lSpa := ! "?" $ X1_PERSPA .And. ! Empty(SX1->X1_PERSPA)
		lIngl := ! "?" $ X1_PERENG .And. ! Empty(SX1->X1_PERENG)

		If lPort .Or. lSpa .Or. lIngl
			RecLock("SX1",.F.)
			If lPort
				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
			EndIf
			If lSpa
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
			EndIf
			If lIngl
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
			EndIf
			SX1->(MsUnLock())
		EndIf
	Endif

	RestArea( aArea )

Return


static function myNossoNum()

	Local cNumero := ""
	Local nTam := TamSx3("EE_FAXATU")[1]

	While ! MayIUseCode( SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))
		sleep(100)
	EndDO

	// Enquanto nao conseguir criar o semaforo, indica que outro usuario
	// esta tentando gerar o nosso numero.
	cNumero := StrZero(Val(SEE->EE_FAXATU),nTam)

	If Empty(SE1->E1_NUMBCO)

		RecLock("SE1",.F.)
		Replace SE1->E1_NUMBCO With cNumero
		SE1->( MsUnlock( ) )

		RecLock("SEE",.F.)
		Replace SEE->EE_FAXATU With Soma1(cNumero, nTam)
		SEE->( MsUnlock() )

	EndIf

	Leave1Code(SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))
	DbSelectArea("SE1")

return(SE1->E1_NUMBCO)
