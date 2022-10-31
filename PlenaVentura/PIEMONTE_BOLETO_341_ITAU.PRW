#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#include 'topconn.ch'

//User Function BolCaixa(aTitulos,lPreview)
User Function BolItau(_pPath,_pArq,_lViewPdf, cTpBol)

	Local oBoleto
	Local cArquivo := ""
	Local lPreview := .T.

	Local cPerg		:= "BolItau"

	Local cBcoBol	:= ""

//	Local n1



	if _pPath==nil
	    //CriaSX1(cPerg)
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
		mv_par24:=Val(cTpBol)

		if _lViewPdf==nil
		   _lVewPdf:=.f.
		endif

	endif

	If AllTrim(MV_PAR17) = '341'
		cBcoBol := 'ITAU'
	EndIf
	//Busca os titulos para impressão
	BuscaDados()

	DbSelectArea('QAA')
	QAA->(DbGoTop())
	If QAA->(EOF())
		Alert('Não existem dados a serem exibidos!')
		Return
	EndIf

	//instancia classe do boleto
	oBoleto := u_BolNewIta('341', .T.,_pPath,_pArq,_lViewPdf)

	IF oBoleto != nil

		While !QAA->(EOF())

			//posiciona no titulo a receber
			SE1->( dbGoTo( QAA->R_E_C_N_O_ ) )

			SEE->( dbSetOrder(1) )
			SEE->( dbSeek( xFilial("SEE") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA + mv_par20) )

			SA1->( dbSetOrder(1) )
			SA1->( dbSeek( xFilial("SA1") + SE1->(E1_CLIENTE+E1_LOJA) ) )

			If cBcoBol = 'ITAU'
				u_RBolItau( @oBoleto )
			Else
				Alert('Não existem dados a serem exibidos! Banco selecionado não tem Boleto.')
				Return
			EndIf

			QAA->(DbSkip())
		EndDo

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


User Function BolNewIta(cBanco, lPreview,_pPath,_pArq,_lViewPdf)

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


#define __codBanco "341"
#define __nomBanco "Itau"

#define nLarg  (605-35)
#define nAlt   842


User Function RBolItau( oBoleto )

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

	Private lAglutinado := .F.
	Private lVencido 	:= .F.
	Private nJuros := 0
	Private nMulta := 0
	Private dVencimento := SE1->E1_VENCREA
	Private aTipos 	:= {}
	Private nSeguro	:= 0
	Private nTaxa	:= 0

	Private oCourier06  := TFont():New('Courier New',08,08,,.F.,,,,.T.,.F.,.F.)
	Private oArial06  	:= TFont():New('Arial',06,06,,.F.,,,,.T.,.F.,.F.)
	Private oArial10  	:= TFont():New('Arial',10,10,,.F.,,,,.T.,.F.,.F.)
	Private oArial07  	:= TFont():New('Arial',07,07,,.F.,,,,.T.,.F.,.F.)
	Private oArial07N 	:= TFont():New('Arial',07,07,,.T.,,,,.T.,.F.,.F.)
	Private oArial09  	:= TFont():New('Arial',10,10,,.F.,,,,.T.,.F.,.F.)
	Private oArial09N 	:= TFont():New('Arial',09,09,,.T.,,,,.T.,.F.,.F.)
	Private oArial10N 	:= TFont():New('Arial',10,10,,.T.,,,,.T.,.F.,.F.)
	Private oArial12N 	:= TFont():New('Arial',12,12,,.T.,,,,.T.,.F.,.F.)
	Private oArial14N 	:= TFont():New('Arial',14,14,,.T.,,,,.T.,.F.,.F.)
	Private oArial16N 	:= TFont():New('Arial',16,16,,.T.,,,,.T.,.F.,.F.)
	Private oArial18N 	:= TFont():New('Arial',21,21,,.T.,,,,.T.,.F.,.F.)

	



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

		nSeguro := 0
		nTaxa 	:= 0
		nTotParc	:= 0
		While !QSE1->(EOF())
			nTotParc++
			QSE1->(DbSkip())
		EndDo
		QSE1->(DbGoTop())
		//nParc := 0
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
		cQuery += " AND SE1.E1_PREFIXO 		= '" + SE1->E1_PREFIXO 	+ "' "
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
		nTaxa   := aDadosRM[1][12]
	endif


	//calcula o valor dos abatimentos
	Private nValorAbatimentos :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	//calculo valor total
	Private nValorDocumento := Round((((SE1->E1_SALDO+SE1->E1_ACRESC)-SE1->E1_DECRESC)*100)-(nValorAbatimentos*100),0)/100

	Private cAge	:= iif(alltrim(SEE->EE_AGEOFI) ="", alltrim(SEE->EE_AGENCIA),alltrim(SEE->EE_AGEOFI))
	Private cDvAge 	:= iif(alltrim(SEE->EE_DVAGOFI)="", SEE->EE_DVAGE,SEE->EE_DVAGOFI)
	Private cCta	:= iif(alltrim(SEE->EE_CTAOFI)="", alltrim(SEE->EE_CONTA),alltrim(SEE->EE_CTAOFI))
	Private cDvCta 	:= iif(alltrim(SEE->EE_DVCTOFI)="", SEE->EE_DVCTA,SEE->EE_DVCTOFI)
	Private cDdCta	:= cAge+iif(alltrim(cDvAge)="","","-")+alltrim(cDvAge)+"/"+cCta+iif(alltrim(cDvCta)="","","-")+cDvCta

	//nosso numero
	Private cNossoNumero := ""
	Private cCodigoBarra 	:= ""
	Private cLinhaDigitavel := ""
	Private lEnderecoCobranca := !Empty(SA1->A1_END) .and. !Empty(SA1->A1_BAIRRO) .and. !Empty(SA1->A1_MUN) .and. !Empty(SA1->A1_EST) .and. !Empty(SA1->A1_CEP)

	Private aInstrucoes := {"","","",""}
	GetNossoNumero()
	cNossoNumero := alltrim(SEE->EE_CODCART) + "/" + Strzero(val(SE1->E1_NUMBCO),8) + "-" + alltrim(Str(nnItau(Strzero(val(SE1->E1_NUMBCO),8))))
	cCodigoBarra 	:= BolCodBar()


	IF lAglutinado .or. alltrim(SE1->E1_XVINCP) <> ""
		aInstrucoes[1] := "NÃO RECEBER APÓS O VENCIMENTO."
	Else
		aInstrucoes[1] := "Não receber após o último dia útil do mês."
		//aInstrucoes[2] := "Após o vencimento cobrar Juros de 1% ao mês (PRÓ-RATE-DIE)(+) Multa de 2%."
		aInstrucoes[2] := "Pague preferencialmente nas agências do ITAU"
		aInstrucoes[3] := ""
		aInstrucoes[4] := ""
	EndIF

	//inicia pagina
	oBoleto:StartPage()

	//logo
   //	oBoleto:SayBitmap(nBloco1+20, nCol3, "\boletos\logos\Logo-RioBonito.jpg", 100, 85) alterado jonatas paiva 05022016
	oBoleto:SayBitmap(nBloco1+05, nCol3, "\boletos\logos\"+cNomeImg, 100, 85)




	oBoleto:Say(nBloco1+=018,nCol1,"Beneficiario",oArial06 )
	oBoleto:Say(nBloco1     ,nCol2,"Agencia/Cod. Beneficiario",oArial06 )

	oBoleto:Say(nBloco1+=008,nCol1,AllTrim(SM0->M0_NOMECOM) ,oArial10 )
	//oBoleto:Say(nBloco1     ,nCol2,AllTrim(SEE->EE_AGENCIA) + "/" + AllTrim(SEE->EE_CODEMP) + "-" + Modulo11(AllTrim(SEE->EE_CODEMP)),oArial10N )
	oBoleto:Say(nBloco1     ,nCol2,AllTrim(cDdCta),oArial10N )

	oBoleto:Say(nBloco1+=015,nCol1,"DADOS DO MUTUARIO",oArial12N )
	oBoleto:Say(nBloco1     ,nCol2,"DADOS DO CONTRATO",oArial12N )

	oBoleto:Say(nBloco1+=015,nCol1,"Nome." + alltrim(SA1->A1_NOME),oArial10 )
	oBoleto:Say(nBloco1     ,nCol2,"Empreendimento: " + aDadosRM[1][3],oArial10 )

  //	oBoleto:Say(nBloco1+=015,nCol1,"Endereço. " + AllTrim(IIF(lEnderecoCobranca,SA1->A1_ENDCOB,SA1->A1_END)) + " - " + AllTrim(IIF(lEnderecoCobranca,SA1->A1_BAIRROC,SA1->A1_BAIRRO)),oArial10 ) //alterado jonatas 20160212
	//oBoleto:Say(nBloco1+=015,nCol1,"Endereço. " + AllTrim(IIF(lEnderecoCobranca,SA1->A1_ENDCOB,SA1->A1_END)) + " - " + AllTrim(IIF(lEnderecoCobranca,SA1->A1_BAIRROC,SA1->A1_BAIRRO)),oArial10 ) //alterado jonatas 20160216


 	cQbEnd := "Endereço. " + AllTrim(SA1->A1_END) + " - "
 	cQbEnd += iif(AllTrim(SA1->A1_COMPLEM)="","", AllTrim(SA1->A1_COMPLEM) + " - ")
 	cQbEnd += AllTrim(SA1->A1_BAIRRO)
 	nBloco1+= 015
 	nBlocoAux := nBloco1
  	nLin := mlcount(cQbEnd,43)
  	For i := 1 to nLin
    	oBoleto:Say(nBlocoAux,nCol1, memoline(cQbEnd,43,i) ,oArial10 )
    	nBlocoAux+= 7
    	If i = 1
    		oBoleto:Say(nBloco1     ,nCol2,"Ala: " + aDadosRM[1][4] + space(3) + "Unidade: " + aDadosRM[1][5] ,oArial10 )
    	endif
  	Next

	oBoleto:Say(nBlocoAux+=08,nCol1,"Cidade. " + AllTrim(SA1->A1_MUN),oArial10 )
	oBoleto:Say(nBloco1+=015,nCol2,"Contrato: " + aDadosRM[1][2],oArial10 )

//	oBoleto:Say(nBloco1+=015,nCol1,"CEP. " + transform(IIF(lEnderecoCobranca,SA1->A1_CEPC,SA1->A1_CEP),"@R 99999-999"),oArial10 ) //comentado jonatas 20160216
	oBoleto:Say(nBlocoAux+=015,nCol1,"CEP. " + transform(SA1->A1_CEP,"@R 99999-999"),oArial10 )
//	oBoleto:Say(nBloco1     ,nCol2,"Prestação. ",oArial10 ) //comentado jonatas paiva 16022016

	If SA1->A1_PESSOA == 'J'
		oBoleto:Say(nBlocoAux,nCol1+110,"CNPJ. " + transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),oArial10 )
	Else
		oBoleto:Say(nBlocoAux,nCol1+110,"CPF. " + transform(SA1->A1_CGC,"@R 999.999.999-99"),oArial10 )
	EndIf

	//Impressão diferente de acordo com o tipo de pagamento
	//Se pagamento diferente de 2 - Mensalidades, imprimir a descrição, caso contrário, imprimir o número da parcela.
	If aDadosRM[1][6] == '2' //Tipo de Pagamento for igual a mensalidade
		cDescRef := aDadosRM[1][7] //+ " " + aDadosRM[1][1] + "/" + aDadosRM[1][8]
	Else
		cDescRef := aDadosRM[1][7]
	EndIF
	IF !(lAglutinado)
		oBoleto:Say(nBloco1+30 ,nCol2,"Refêrencia da Prestação: " + cDescRef,oArial10 ) //comentado jonatas paiva 16022016
	Endif

	oBoleto:Say(nBloco1+=05     ,nCol3,"Vencimento",oArial12N )

	//oBoleto:Say(nBloco1+=015,nCol2,cRef,oArial10 ) //comentado jonatas paiva 16022016
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

	if cEmpAnt == '04'
		nPrestacao := nValorDocumento - nSeguro - SE1->E1_XTAXAS - nTaxa - nMulta - nJuros
		nTaxas := SE1->E1_XTAXAS + nTaxa
	ELSE
		nPrestacao := nValorDocumento - nSeguro - nTaxa - nMulta - nJuros
		nTaxas := nTaxa
	Endif
	oBoleto:Say(nBloco1+=010,nCol1		,Transform(nPrestacao,"@E 999,999,999.99"),oCourier06,,,,1) // alinha a direita
	oBoleto:Say(nBloco1     ,nCol1 + 55	,Transform(nSeguro,"@E 999,999.99"),oCourier06,,,,1) // alinha a direita
	oBoleto:Say(nBloco1     ,nCol1 +110	,Transform(0.00,"@E 999,999.99"),oCourier06,,,,1) // alinha a direita
	oBoleto:Say(nBloco1     ,nCol1 +165	,Transform(0.00,"@E 999,999.99"),oCourier06,,,,1) // alinha a direita
	oBoleto:Say(nBloco1     ,nCol1 +220	,Transform(nTaxas,"@E 999,999.99"),oCourier06,,,,1) // alinha a direita
	oBoleto:Say(nBloco1     ,nCol1 +275	,Transform(nMulta+nJuros,"@E 999,999.99"),oCourier06,,,,1) // alinha a direita
	oBoleto:Say(nBloco1     ,nCol1 +335	,Transform(nValorDocumento,"@E 999,999,999.99"),oCourier06,,,,1) // alinha a direita


	nBloco1 := 155
	oBoleto:Say(nBloco1,nCol3,Transform(nValorDocumento,"@E 999,999,999.99"),oArial12N )

	oBoleto:Say(nBloco1+=011,nCol3,"Nosso numero documento",oArial06 )
	//oBoleto:Say(nBloco1+=015,nCol3,TransForm(cNossoNumero,"@R 99 999999999999999 9"),oArial12N )
	oBoleto:Say(nBloco1+=010,nCol3,cNossoNumero,oArial12N )
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
	oBoleto:Say(nBloco1+=20 ,nCol1     ,"IPTU " + SubStr(DTOS(dDataBase),1,4),oArial10 )
	oBoleto:Say(nBloco1     ,nCol1 +205,"001/001 ",oArial10 )
	oBoleto:Say(nBloco1     ,nCol1 +305,"Total ",oArial10 )

	oBoleto:Say(nBloco1+=20 ,nCol1     ,"Pend. Manual " + SubStr(DTOS(dDataBase),1,4),oArial10 )
	oBoleto:Say(nBloco1     ,nCol1 +205,"001/001 ",oArial10 )
	oBoleto:Say(nBloco1     ,nCol1 +305,"Total ",oArial10 )

	If MV_PAR23 = 1
		oBoleto:Say(nBloco1+=20 ,nCol1     ,"Aviso Unico 15 dias atraso " + SubStr(DTOS(dDataBase),1,4),oArial10 )
		oBoleto:Say(nBloco1     ,nCol1 +205,"001/001 ",oArial10 )
		oBoleto:Say(nBloco1     ,nCol1 +305,SuperGetMV("MV_15DIAS", .F., '1,20'),oArial10 )

		oBoleto:Say(nBloco1+=20 ,nCol1     ,"Recibo Consolidado " + SubStr(DTOS(dDataBase),1,4),oArial10 )
		oBoleto:Say(nBloco1     ,nCol1 +205,"001/001 ",oArial10 )
		oBoleto:Say(nBloco1     ,nCol1 +305,TransForm(SuperGetMV("MV_RECCONS", .F., 3.75), "@R 999,99"),oArial10 )
	EndIf
  	//fim comentado
*/
/*//comentado jonatas paiva 16022016
	//COMECO INCLUSAO
	oBoleto:Say(nBloco1+=20 ,nCol1     ,"PRESTACAO" + SubStr(DTOS(dDataBase),1,4),oArial10 )
	oBoleto:Say(nBloco1     ,nCol1 +205,"001/001 ",oArial10 )
	oBoleto:Say(nBloco1     ,nCol1 +305,"Total ",oArial10 )

	oBoleto:Say(nBloco1+=20 ,nCol1     ,"Notificação por títulos e doc " + SubStr(DTOS(dDataBase),1,4),oArial10 )
	oBoleto:Say(nBloco1     ,nCol1 +205,"001/001 ",oArial10 )
	oBoleto:Say(nBloco1     ,nCol1 +305,"Total ",oArial10 )

	oBoleto:Say(nBloco1+=20 ,nCol1     ,"Aviso Único 15 dias atraso " + SubStr(DTOS(dDataBase),1,4),oArial10 )
	oBoleto:Say(nBloco1     ,nCol1 +205,"001/001 ",oArial10 )
	oBoleto:Say(nBloco1     ,nCol1 +305,SuperGetMV("MV_15DIAS", .F., '1,20'),oArial10 )

	oBoleto:Say(nBloco1+=20 ,nCol1     ,"Recibo Consolidado " + SubStr(DTOS(dDataBase),1,4),oArial10 )
	oBoleto:Say(nBloco1     ,nCol1 +205,"001/001 ",oArial10 )
	oBoleto:Say(nBloco1     ,nCol1 +305,TransForm(SuperGetMV("MV_RECCONS", .F., 3.75), "@R 999,99"),oArial10 )
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
	oBoleto:SayBitmap(nBloco2+157, 20, "\boletos\logos\logo-banco-341.jpg", 75, 20)
	//Line(linha_inicial, coluna_inicial, linha final, coluna final)
	oBoleto:Line( nBloco2+157,  95, nBloco2+177,  95,,"01")
	oBoleto:Line( nBloco2+157, 146, nBloco2+177, 146,,"01")
	oBoleto:Line( nBloco2+177,  20, nBloco2+177,nLarg,,"01")

	//Numero do Banco
	oBoleto:Say(nBloco2+174,99,"341-7",oArial18N )

	//adiciona mais dois ao depois
	nBloco1 += 3

	//oBoleto:Say(nBloco2+174,150,cCodigoBarra,oArial16N)
	oBoleto:SayAlign(nBloco2+157,150,cLinhaDigitavel,oArial16N,400,,,1)

	ImprimeBloco(oBoleto, nBloco2)

	//oBoleto:Say(480,25,cCodigoBarra,oArial10N)
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


Return


Static Function ImprimeBloco(oBoleto, nBloco)

	//bloco 2 linha 1 ->
	oBoleto:Say(nBloco+185,25 ,"Local de Pagamento",oArial06)
	oBoleto:Say(nBloco+192,25 ,"Até o vencimento, preferencialmente no Itau",oArial09N)
	oBoleto:Say(nBloco+200,25 ,"Após o vencimento, somente no Itau",oArial09N)

	oBoleto:Say(nBloco+185,425 ,"Vencimento",oArial06)
	oBoleto:SayAlign(nBloco+187,435,FormDate(SE1->E1_VENCREA),oArial10N,100,10,,1)

	//bloco 2 linha 2 ->
	oBoleto:Line( nBloco+202,  20, nBloco+202,nLarg,,"01")
	oBoleto:Say(nBloco+208,25 , "Beneficiario",oArial06)
	oBoleto:Say(nBloco+215,25 , SM0->M0_NOMECOM + transform(SM0->M0_CGC,"@R 99.999.999/9999-99") ,oArial09N)
	oBoleto:Say(nBloco+222,25 , Alltrim(SM0->M0_ENDCOB)+" "+ Alltrim(SM0->M0_BAIRCOB)+" - "+Alltrim(SM0->M0_CIDCOB)+" /"+Alltrim(SM0->M0_ESTCOB) + " CEP: " + Alltrim(SM0->M0_CEPCOB) ,oArial09N)

	oBoleto:Say(nBloco+210,425 ,"Agência/Código Beneficiario",oArial06)
	//oBoleto:SayAlign(nBloco+212,435,AllTrim(SEE->EE_AGENCIA) + "/" + AllTrim(SEE->EE_CODEMP) + "-" + Modulo11(SEE->EE_CODEMP),oArial10N,100,10,,1 )
	oBoleto:SayAlign(nBloco+212,435,AllTrim(cDdCta),oArial10N,100,10,,1 )


	//bloco 2 linha 4 ->
	oBoleto:Line( nBloco+227,  20, nBloco+227,nLarg,,"01")
	oBoleto:Say(nBloco+233,25, "Data do Documento" ,oArial06)
	oBoleto:Say(nBloco+243,25, FormDate(SE1->E1_EMISSAO), oArial10N)

	oBoleto:Line(nBloco+227, 110, nBloco+247,110,,"01")
	oBoleto:Say(nBloco+233,115, "Nro. Documento"                                  ,oArial06)
	oBoleto:Say(nBloco+243,115, SE1->E1_PREFIXO+alltrim(SE1->E1_NUM)+IIF(Empty(SE1->E1_PARCELA),"","/")+SE1->E1_PARCELA ,oArial10N)

	oBoleto:Line(nBloco+227, 232, nBloco+247,232,,"01")
	oBoleto:Say(nBloco+233,237, "Espécie Doc."                                   ,oArial06)
	oBoleto:Say(nBloco+243,237, "DM"										,oArial10N) //Tipo do Titulo

	oBoleto:Line(nBloco+227, 293, nBloco+247,293,,"01")
	oBoleto:Say(nBloco+233,298, "Aceite"                                         ,oArial06)
	oBoleto:Say(nBloco+243,298, "NAO"                                             ,oArial10N)

	oBoleto:Line(nBloco+227, 339, nBloco+247,339,,"01")
	oBoleto:Say(nBloco+233,344, "Data do Processamento"                          ,oArial06)
	oBoleto:Say(nBloco+243,344, FormDate(dDataBase),oArial10N) // Data impressao

	oBoleto:Say(nBloco+233,425 ,"Nosso Número Documento",oArial06)
	//oBoleto:SayAlign(nBloco+234,435,TransForm(cNossoNumero,"@R 99 999999999999999 9"),oArial10N,100,10,,1)
	//oBoleto:Say(nBloco+234,435,TransForm(cNossoNumero,"@R 99 999 999 999 999 999 9"),oArial10N)
	oBoleto:SayAlign(nBloco+234,435, cNossoNumero,oArial10N,100,10,,1)

	//bloco 2 linha 5 ->
	oBoleto:Line( nBloco+247,  20, nBloco+247,nLarg,,"01")
	oBoleto:Say(nBloco+253,25,"Uso do Banco"                                   ,oArial06)
	oBoleto:Say(nBloco+263,25,""                                   ,oArial10N)

	oBoleto:Line(nBloco+247,110, nBloco+267,110,,"01")
	oBoleto:Say(nBloco+253,115 ,"Carteira"                                       ,oArial06)
	oBoleto:Say(nBloco+263,115 ,SEE->EE_CODCART                                  	,oArial10N)

	oBoleto:Line(nBloco+247, 171, nBloco+267,171,,"01")
	oBoleto:Say(nBloco+253,176 ,"Espécie"                                        ,oArial06)
	oBoleto:Say(nBloco+263,176 ,"R$"                                             ,oArial10N)

	oBoleto:Line(nBloco+247, 232, nBloco+267,232,,"01")
	oBoleto:Say(nBloco+253,237,"Quantidade Moeda"                                     ,oArial06)
	oBoleto:Line(nBloco+247,339, nBloco+267,339,,"01")
	oBoleto:Say(nBloco+253,344,"Valor Moeda"                                          ,oArial06)

	oBoleto:Say(nBloco+253,425 ,"(+)Valor do Documento",oArial06)
	oBoleto:SayAlign(nBloco+254,435,Transform(nValorDocumento,"@E 999,999,999.99"),oArial10N,100,10,,1)


	//bloco 2 linha 6 ->ª
	oBoleto:Line( nBloco+267,  20, nBloco+267,nLarg,,"01")
	oBoleto:Say( nBloco+273,25, "INSTRUÇÕES: (TEXTO DE RESPONSABILIDADE DO CEDENTE)" , oArial06)

	oBoleto:Say(nBloco+293,0025,aInstrucoes[1],oArial10N)
	oBoleto:Say(nBloco+303,0025,aInstrucoes[2],oArial10N)
	oBoleto:Say(nBloco+313,0025,aInstrucoes[3],oArial10N)
	oBoleto:Say(nBloco+323,0025,aInstrucoes[4],oArial10N)

	oBoleto:Say(nBloco+273,425,"(-)Desconto/Abatimento",oArial06)

	//bloco 2 linha 7 ->
	oBoleto:Line( nBloco+287,  420, nBloco+287,nLarg,,"01")
	oBoleto:Say(nBloco+293,425,"(-)Outras Deduções",oArial06)

	//bloco 2 linha 8 ->
	oBoleto:Line( nBloco+307,  420, nBloco+307,nLarg,,"01")
	oBoleto:Say(nBloco+313,425,"(+)Mora/Multa",oArial06)

	//bloco 2 linha 9 ->
	oBoleto:Line( nBloco+327,  420, nBloco+327,nLarg,,"01")
	oBoleto:Say(nBloco+333,425,"(+)Outros Acréscimos",oArial06)

	//bloco 2 linha 10 ->
	oBoleto:Line( nBloco+347,  420, nBloco+347,nLarg,,"01")
	oBoleto:Say(nBloco+353,425,"(=)Valor Cobrado",oArial06)
	oBoleto:Line( nBloco+177,  420, nBloco+367,420,,"01")

	//bloco 2 Sacado ->
	oBoleto:Line( nBloco+367,  20, nBloco+367,nLarg,,"01")
	oBoleto:Say(nBloco+376,25 ,"Pagador",oArial06)

	oBoleto:Say(nBloco+376,90 ,alltrim(SA1->A1_NOME) + " (" +SA1->A1_COD+" - "+SA1->A1_LOJA+")",oArial10N)

	IF SA1->A1_PESSOA == "J"
		oBoleto:Say(nBloco+376,420 ," CNPJ: " + transform(SA1->A1_CGC,"@R 99.999.999/9999-99") ,oArial10N)
	Else
		oBoleto:Say(nBloco+376,420 ," CPF: " + transform(SA1->A1_CGC,"@R 999.999.999-99") ,oArial10N)
	EndIF
	//oBoleto:Say(nBloco+386,90 ,IIF(lEnderecoCobranca,SA1->A1_ENDCOB,SA1->A1_END) + " - " + IIF(lEnderecoCobranca,SA1->A1_BAIRROC,SA1->A1_BAIRRO) ,oArial10N) //comentado jonatas 20160216
	oBoleto:Say(nBloco+386,90 ,SA1->A1_END + " - " + SA1->A1_BAIRRO ,oArial10N)
	//oBoleto:Say(nBloco+396,90 ,transform(IIF(lEnderecoCobranca,SA1->A1_CEPC,SA1->A1_CEP),"@R 99999-999")+ " - " + alltrim(IIF(lEnderecoCobranca,SA1->A1_MUNC,SA1->A1_MUN))+"/"+IIF(lEnderecoCobranca,SA1->A1_ESTC,SA1->A1_EST) ,oArial10N) //comentado jonatas 20160216
	oBoleto:Say(nBloco+396,90 ,transform(SA1->A1_CEP,"@R 99999-999")+ " - " + alltrim(SA1->A1_MUN)+"/"+ SA1->A1_EST ,oArial10N)

	//oBoleto:Say(nBloco+386,90 ,IIF(lEnderecoCobranca,SA1->A1_ENDCOB,SA1->A1_END) + " - " + IIF(lEnderecoCobranca,SA1->A1_BAIRROC,SA1->A1_BAIRRO) ,oArial10N)
	//oBoleto:Say(nBloco+396,90 ,transform(IIF(lEnderecoCobranca,SA1->A1_CEPC,SA1->A1_CEP),"@R 99999-999")+ " - " + alltrim(IIF(lEnderecoCobranca,SA1->A1_MUNC,SA1->A1_MUN))+"/"+IIF(lEnderecoCobranca,SA1->A1_ESTC,SA1->A1_EST) ,oArial10N)



	/*
	oBoleto:Say(nBloco+406,430 ,cNossoNumero ,oArial10N)
	*/

	//bloco 2 Sacado - autenticação ->
	oBoleto:Say(nBloco+406, 25, "Sacado/Avalista" , oArial06)
	oBoleto:Line( nBloco+410,  20, nBloco+410,nLarg,,"01")
	oBoleto:Say(nBloco+416,420, "Autenticação Mecânica - Ficha de compensação" , oArial06)

	//CODIGO DE BARRAS
	//oBoleto:Code128C(nBloco + 445,25,cCodigoBarra, 30 )
	//oBoleto:Say(nBloco+440,25, cCodigoBarra , oArial10N)
	//oBoleto:int25(nBloco + 445,25,cCodigoBarra,1,55)

//	oBoleto:FWMSBAR("INT25", 56, 1.6, cCodigoBarra, oBoleto,.F.,,,,0.8,.F.,"Arial",NIL,.F.,1,1,.F.)
	oBoleto:FWMSBAR("INT25" ,61.25,1.7, cCodigoBarra ,oBoleto,.F.,,.T.,0.02,1,.F.,"Arial",NIL,.F.,2,2,.F.)


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

	Local cNossoNum := '' //Right(alltrim(NossoNum()), 06)

	While ! MayIUseCode( SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))
		sleep(100)
	EndDO

	// Gerar nosso número banco.
	If Empty(SE1->E1_NUMBCO)
		IF !Empty(SEE->EE_FAXATU)
			cNossoNum := strzero(val(SEE->EE_FAXATU) + 1,8)
		else
			Aviso("Atenção","Tabela Parâmetros dos Bancos (EE_FAXATU) não configurada!",{"Sair"}, 2)
			Return
		EndIF
		IF !Empty(cNossoNum)
			IF RecLock("SEE",.F.)
				SEE->EE_FAXATU := cNossoNum
				SEE->(MsUnlock())
			EndIF

			// Gravando sem o dígito da conta.
			IF RecLock("SE1",.F.)
				SE1->E1_NUMBCO := cNossoNum
				SE1->(MsUnlock())
			EndIF

		EndIF
	Endif

	Leave1Code(SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))

Return cNossoNum



Static Function BolCodBar()

	Local cValorFinal := StrZero(Round(nValorDocumento*100,0),10)
	Local nDigVerNN   := alltrim(Str(nnItau(substr(SE1->E1_NUMBCO,1,8))))
	Local nDigVerCB   := 0
	Local cCodigo     := ''
	Local cAuxiliar   := ''
	Local cFator      := StrZero( SE1->E1_VENCTO - CtoD("07/10/97"),4)

	Local cCarteira   := SEE->EE_CODCART

	Local cAgencia    := iif(alltrim(SEE->EE_AGEOFI) ="", alltrim(SEE->EE_AGENCIA),alltrim(SEE->EE_AGEOFI))
	Local cConta      := iif(alltrim(SEE->EE_CTAOFI)="", alltrim(SEE->EE_CONTA),alltrim(SEE->EE_CTAOFI))
	Local cDvCta 	  := iif(alltrim(SEE->EE_DVCTOFI)="", SEE->EE_DVCTA,SEE->EE_DVCTOFI)
	cConta := alltrim(cConta) + alltrim(cDvCta)
	//	 Definicao do CODIGO DE BARRAS
	cAuxiliar:= SEE->EE_CODIGO + "9" + cFator +  cValorFinal + cCarteira + alltrim(SE1->E1_NUMBCO)+ alltrim(nDigVerNN) + cAgencia + cConta + '000'
	nDigVerCB := modulo11(cAuxiliar)
	cCodigo   := SubStr(cAuxiliar, 1, 4) + alltrim(str(nDigVerCB)) + SubStr(cAuxiliar,5,39)

	//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
	//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
	//	AAABC.CCDDX		DDDDD.DDFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV
	// 	CAMPO 1:
	//	AAA	= Codigo do banco na Camara de Compensacao
	//	  B = Codigo da moeda, sempre 9
	//	CCC = Codigo da Carteira de Cobranca
	//	 DD = Dois primeiros digitos no nosso numero
	//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	cAuxiliar    := SEE->EE_CODIGO + "9" + cCarteira + SubStr(alltrim(SE1->E1_NUMBCO),1,2)
	cLinhaDigitavel   := SubStr(cAuxiliar, 1, 5) + '.' + SubStr(cAuxiliar, 6, 4) + alltrim(str(modulo10(cAuxiliar))) + '  '

	// 	CAMPO 2:
	//	DDDDDD = Restante do Nosso Numero
	//	     E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
	//	   FFF = Tres primeiros numeros que identificam a agencia
	//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	cAuxiliar := Substr(alltrim(SE1->E1_NUMBCO),3,6) + Alltrim(nDigVerNN)+ Subs(cAgencia,1,3)
	cLinhaDigitavel +=  SubStr(cAuxiliar,1,5) + '.' + SubStr(cAuxiliar,6,5)  + alltrim(str(modulo10(cAuxiliar))) + ' '

	// 	CAMPO 3:
	//	     F = Restante do numero que identifica a agencia
	//	GGGGGG = Numero da Conta + DAC da mesma
	//	   HHH = Zeros (Nao utilizado)
	//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	cAuxiliar    := Subs(cAgencia,4,1) + Subs(cConta,1,4) +  Subs(cConta,5,2) +'000'
	cLinhaDigitavel   := cLinhaDigitavel + Subs(cAgencia,4,1) + Subs(cConta,1,4) +'.'+ Subs(cConta,5,2) +'000'+ alltrim(str(Modulo10(cAuxiliar)))
	//	CAMPO 4:
	//	     K = DAC do Codigo de Barras
	cLinhaDigitavel   := cLinhaDigitavel + ' ' + AllTrim(Str(nDigVerCB)) + '  '

	// 	CAMPO 5:
	//	      UUUU = Fator de Vencimento
	//	VVVVVVVVVV = Valor do Titulo
	cLinhaDigitavel   := cLinhaDigitavel + cFator + StrZero(Round(nValorDocumento * 100,0),14-Len(cFator))

Return cCodigo


Static Function Modulo10(cData)
	Local L,D,P := 0
	Local B     := .F.
	L := Len(cData)
	B := .T.
	D := 0
	While L > 0
		P := val(SubStr(cData, L, 1))
		IF (B)
			P := P * 2
			IF P > 9
				P := P - 9
			EndIF
		EndIF
		D := D + P
		L := L - 1
		B := !B
	EndDO
	D := 10 - (Mod(D,10))
	IF D = 10
		D := 0
	EndIF
Return(D)



Static Function Modulo11(cData)
	Local L, D, P := 0
	L := Len(cdata)
	D := 0
	P := 1
	While L > 0
		P := P + 1
		D := D + (val(SubStr(cData, L, 1)) * P)
		IF P = 9
			P := 1
		EndIF
		L := L - 1
	EndDO
	D := 11 - (mod(D,11))
	IF (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	EndIF
Return(D)


/*/{Protheus.doc} nnItau
(Gera nosso número Itaú)
@author Fernando Nonato
@since 23/03/2017
@version 1.0
/*/

Static Function nnItau(cNossoNum)
Local cNN 	:= Strzero(val(cNossoNum),8)
//Local cAge	:= SUBSTR(SEE->EE_AGENCIA,1,4)
//Local cCta	:= substr(SEE->EE_CONTA,1,5)

cNN := Modulo10Itau(cAge + cCta + alltrim(SEE->EE_CODCART) + cNN)
Return(cNN)

Static Function Modulo10Itau(cNN)
	LOCAL L,D,P := 0
	LOCAL B     := .F.
	L := Len(cNN)
	B := .T.
	D := 0
	While L > 0
		P := Val(SubStr(cNN, L, 1))
		If (B)
			P := P * 2
			If P > 9
				P := P - 9
			End
		End
		D := D + P
		L := L - 1
		B := !B
	End
	D := 10 - (Mod(D,10))
	If D = 10
		D := 0
	End
Return(D)




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
		cQuery += " SE1.E1_VENCTO 	>= '"+DTOS(MV_PAR13)+"' AND SE1.E1_CLIENTE	<= '"+DTOS(MV_PAR14)+"' AND"
		cQuery += " SE1.E1_EMISSAO 	>= '"+DTOS(MV_PAR15)+"' AND SE1.E1_CLIENTE	<= '"+DTOS(MV_PAR16)+"' AND"
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


//-----------------------------------------
/*/{Protheus.doc} CriaSX1
Cria grupo de perguntas

@author Hugo
@since 10/04/2015
@version 1.0

@protected
/*/
//-----------------------------------------
/*Static Function CriaSX1(cPerg)

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
	xPutSX1(cPerg, "24", "Tipo de Boleto"      	 	 , "", "", "mv_ch24", "C", 01,  0, 2, "C", "", ""   , "", "", "mv_par24", "NORMAL","NORMAL","NORMAL","LIQUIDACAO DE SALDO DEVEDOR","LIQUIDACAO DE SALDO DEVEDOR","LIQUIDACAO DE SALDO DEVEDOR","AMORTIZACAO PARCIAL DE SALDO","AMORTIZACAO PARCIAL DE SALDO","AMORTIZACAO PARCIAL DE SALDO","PARCELAS VENCIDAS","PARCELAS VENCIDAS","PARCELAS VENCIDAS","","","","")

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

Return */
