//#INCLUDE "rptdef.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#include 'topconn.ch'

//User Function BolCaixa(aTitulos,lPreview)
//https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwia6-ax5v-BAxVRHrkGHU7AC7EQwqsBegQICRAG&url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DwUvgAa5Ksng&usg=AOvVaw2scCfb7-fFX2MFuh8nDbqT&opi=89978449

User Function BolBrad(_pPath,_pArq,_lViewPdf, cTpBol)

	Local oBoleto
	Local cArquivo := ""
	Local lPreview := .T.

	Local cPerg		:= "BolBrad"

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

	If AllTrim(MV_PAR17) = '237'
		cBcoBol := 'BRADESCO'
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
	oBoleto := u_BolNewBra('237', .T.,_pPath,_pArq,_lViewPdf)

	IF oBoleto != nil

		While !QAA->(EOF())

			//posiciona no titulo a receber
			SE1->( dbGoTo( QAA->R_E_C_N_O_ ) )

			SEE->( dbSetOrder(1) )
			SEE->( dbSeek( xFilial("SEE") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA + mv_par20) )

			SA1->( dbSetOrder(1) )
			SA1->( dbSeek( xFilial("SA1") + SE1->(E1_CLIENTE+E1_LOJA) ) )

			If cBcoBol = 'BRADESCO'
				u_RBolBradesco( @oBoleto )
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


User Function BolNewBra(cBanco, lPreview,_pPath,_pArq,_lViewPdf)

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


#define __codBanco "237"
#define __nomBanco "Bradesco"

#define nLarg  (605-35)
#define nAlt   842


User Function RBolBradesco( oBoleto )

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
	Private oArial09  	:= TFont():New('Arial',10,10,,.F.,,,,.T.,.F.,.F.)
	Private oArial07  	:= TFont():New('Arial',07,07,,.F.,,,,.T.,.F.,.F.)
	Private oArial07N 	:= TFont():New('Arial',07,07,,.T.,,,,.T.,.F.,.F.)
	Private oArial09N 	:= TFont():New('Arial',10,10,,.T.,,,,.T.,.F.,.F.)
	Private oArial12N 	:= TFont():New('Arial',12,12,,.T.,,,,.T.,.F.,.F.)
	Private oArial14N 	:= TFont():New('Arial',14,14,,.T.,,,,.T.,.F.,.F.)
	Private oArial16N 	:= TFont():New('Arial',16,16,,.T.,,,,.T.,.F.,.F.)
	Private oArial18N 	:= TFont():New('Arial',21,21,,.T.,,,,.T.,.F.,.F.)


//Busca dados RM
	aDadosRM := {}
    //u_fFINI055(@aDadosRM, SE1->E1_PREFIXO,SE1->E1_NUM)
	nSeguro := 0 // aDadosRM[1][10]
	nTaxa	:= 0 //aDadosRM[1][12]
	//********************************************************************************
	// Alteração para impressão de títulos aglutinados - Fernando Nonato  - 04/04/2017
	//*******************************************************************************

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
	cNossoNumero := substr(SE1->E1_NUMBCO,1,11) + "-" + substr(SE1->E1_NUMBCO,12,1)
	cCodigoBarra 	:= BolCodBar()
	cLinhaDigitavel := BolLinhaDigitavel()



	IF lAglutinado 
		aInstrucoes[1] := "NÃO RECEBER APÓS O VENCIMENTO."
	Else
		aInstrucoes[1] := "Não receber após o último dia útil do mês."
		aInstrucoes[2] := "Após o vencimento cobrar Juros de 1% ao mês (PRÓ-RATE-DIE)(+) Multa de 2%."
		aInstrucoes[3] := "Pague preferencialmente nas agências do BRADESCO"
		aInstrucoes[4] := ""
	EndIF

	//inicia pagina
	oBoleto:StartPage()

	//logo
   //	oBoleto:SayBitmap(nBloco1+20, nCol3, "\boletos\logos\Logo-RioBonito.jpg", 100, 85) alterado jonatas paiva 05022016
	oBoleto:SayBitmap(nBloco1+05, nCol3, "\boletos\logos\"+cNomeImg, 100, 85)

	oBoleto:Say(nBloco1+=018,nCol1,"Beneficiario",oArial06 )
	oBoleto:Say(nBloco1     ,nCol2,"Agencia/Cod. Beneficiario",oArial06 )

	oBoleto:Say(nBloco1+=008,nCol1,AllTrim(SM0->M0_NOMECOM) ,oArial09 )
	//oBoleto:Say(nBloco1     ,nCol2,AllTrim(SEE->EE_AGENCIA) + "/" + AllTrim(SEE->EE_CODEMP) + "-" + Modulo11(AllTrim(SEE->EE_CODEMP)),oArial09N )
	oBoleto:Say(nBloco1     ,nCol2,AllTrim(cDdCta),oArial09N )

	oBoleto:Say(nBloco1+=015,nCol1,"DADOS DO MUTUARIO",oArial12N )
	oBoleto:Say(nBloco1     ,nCol2,"DADOS DO CONTRATO",oArial12N )

	oBoleto:Say(nBloco1+=015,nCol1,"Nome." + alltrim(SA1->A1_NOME),oArial09 )
	oBoleto:Say(nBloco1     ,nCol2,"Empreendimento: " ,oArial09 )

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
    		oBoleto:Say(nBloco1     ,nCol2,+ space(3) + "Unidade: " ,oArial09 )
    	endif
  	Next

	oBoleto:Say(nBlocoAux+=08,nCol1,"Cidade. " + AllTrim(SA1->A1_MUN),oArial09 )
	oBoleto:Say(nBloco1+=015,nCol2,"Contrato: ",oArial09 )

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
	cDescRef :=''
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
	nPrestacao := nValorDocumento - nSeguro -  nTaxa - nMulta - nJuros
	nTaxas := 0
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
	oBoleto:Say(nBloco1+=010,nCol3,TransForm(cNossoNumero,"@R 99999999999999999-9"),oArial12N )
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
	//logo
	oBoleto:SayBitmap(nBloco2+157, 20, "\boletos\logos\Logo-Bradesco.jpg", 75, 20)
	//Line(linha_inicial, coluna_inicial, linha final, coluna final)
	oBoleto:Line( nBloco2+157,  95, nBloco2+177,  95,,"01")
	oBoleto:Line( nBloco2+157, 146, nBloco2+177, 146,,"01")
	oBoleto:Line( nBloco2+177,  20, nBloco2+177,nLarg,,"01")

	//Numero do Banco
	oBoleto:Say(nBloco2+174,99,"237",oArial18N )

	//adiciona mais dois ao depois
	nBloco1 += 3

	//oBoleto:Say(nBloco2+174,150,cCodigoBarra,oArial16N)
	oBoleto:SayAlign(nBloco2+157,150,cLinhaDigitavel,oArial16N,400,,,1)

	ImprimeBloco(oBoleto, nBloco2)

	//Finaliza pagina
	oBoleto:EndPage()

	If MV_PAR24 <> 1
		u_RBolREL(@oBoleto, aTipos)
	Endif

Return


Static Function ImprimeBloco(oBoleto, nBloco)

	//bloco 2 linha 1 ->
	oBoleto:Say(nBloco+185,25 ,"Local de Pagamento",oArial06)
	oBoleto:Say(nBloco+197,25 ,"Pag�vel preferencialmente na Rede Bradesco ou Bradesco Expresso",oArial09N)

	oBoleto:Say(nBloco+185,425 ,"Vencimento",oArial06)
	oBoleto:SayAlign(nBloco+187,435,FormDate(SE1->E1_VENCREA),oArial09N,100,10,,1)

	//bloco 2 linha 2 ->
	oBoleto:Line( nBloco+202,  20, nBloco+202,nLarg,,"01")
	oBoleto:Say(nBloco+210,25 , "Beneficiario",oArial06)
	oBoleto:Say(nBloco+222,25 , SM0->M0_NOMECOM + transform(SM0->M0_CGC,"@R 99.999.999/9999-99") ,oArial09N)

	oBoleto:Say(nBloco+210,425 ,"Ag�ncia/C�digo Beneficiario",oArial06)
	//oBoleto:SayAlign(nBloco+212,435,AllTrim(SEE->EE_AGENCIA) + "/" + AllTrim(SEE->EE_CODEMP) + "-" + Modulo11(SEE->EE_CODEMP),oArial09N,100,10,,1 )
	oBoleto:SayAlign(nBloco+212,435,AllTrim(cDdCta),oArial09N,100,10,,1 )


	//bloco 2 linha 4 ->
	oBoleto:Line( nBloco+227,  20, nBloco+227,nLarg,,"01")
	oBoleto:Say(nBloco+233,25, "Data do Documento" ,oArial06)
	oBoleto:Say(nBloco+243,25, FormDate(SE1->E1_EMISSAO), oArial09N)

	oBoleto:Line(nBloco+227, 110, nBloco+247,110,,"01")
	oBoleto:Say(nBloco+233,115, "Nro. Documento"                                  ,oArial06)
	oBoleto:Say(nBloco+243,115, SE1->E1_PREFIXO+alltrim(SE1->E1_NUM)+IIF(Empty(SE1->E1_PARCELA),"","/")+SE1->E1_PARCELA ,oArial09N)

	oBoleto:Line(nBloco+227, 232, nBloco+247,232,,"01")
	oBoleto:Say(nBloco+233,237, "Esp�cie Doc."                                   ,oArial06)
	oBoleto:Say(nBloco+243,237, "DM"										,oArial09N) //Tipo do Titulo

	oBoleto:Line(nBloco+227, 293, nBloco+247,293,,"01")
	oBoleto:Say(nBloco+233,298, "Aceite"                                         ,oArial06)
	oBoleto:Say(nBloco+243,298, "NAO"                                             ,oArial09N)

	oBoleto:Line(nBloco+227, 339, nBloco+247,339,,"01")
	oBoleto:Say(nBloco+233,344, "Data do Processamento"                          ,oArial06)
	oBoleto:Say(nBloco+243,344, FormDate(dDataBase),oArial09N) // Data impressao

	oBoleto:Say(nBloco+233,425 ,"Nosso N�mero Documento",oArial06)
	//oBoleto:SayAlign(nBloco+234,435,TransForm(cNossoNumero,"@R 99 999999999999999 9"),oArial09N,100,10,,1)
	//oBoleto:Say(nBloco+234,435,TransForm(cNossoNumero,"@R 99 999 999 999 999 999 9"),oArial09N)
	oBoleto:SayAlign(nBloco+234,435, alltrim(SEE->EE_CODCART) + "/" + cNossoNumero,oArial09N,100,10,,1)

	//bloco 2 linha 5 ->
	oBoleto:Line( nBloco+247,  20, nBloco+247,nLarg,,"01")
	oBoleto:Say(nBloco+253,25,"Uso do Banco"                                   ,oArial06)
	oBoleto:Say(nBloco+263,25,""                                   ,oArial09N)

	oBoleto:Line(nBloco+247,110, nBloco+267,110,,"01")
	oBoleto:Say(nBloco+253,115 ,"Carteira"                                       ,oArial06)
	oBoleto:Say(nBloco+263,115 ,SEE->EE_CODCART                                  	,oArial09N)

	oBoleto:Line(nBloco+247, 171, nBloco+267,171,,"01")
	oBoleto:Say(nBloco+253,176 ,"Esp�cie"                                        ,oArial06)
	oBoleto:Say(nBloco+263,176 ,"R$"                                             ,oArial09N)

	oBoleto:Line(nBloco+247, 232, nBloco+267,232,,"01")
	oBoleto:Say(nBloco+253,237,"Quantidade Moeda"                                     ,oArial06)
	oBoleto:Line(nBloco+247,339, nBloco+267,339,,"01")
	oBoleto:Say(nBloco+253,344,"Valor Moeda"                                          ,oArial06)

	oBoleto:Say(nBloco+253,425 ,"(+)Valor do Documento",oArial06)
	oBoleto:SayAlign(nBloco+254,435,Transform(nValorDocumento,"@E 999,999,999.99"),oArial09N,100,10,,1)


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

	oBoleto:Say(nBloco+406, 25, "Sacado/Avalista" , oArial06)
	oBoleto:Line( nBloco+410,  20, nBloco+410,nLarg,,"01")
	oBoleto:Say(nBloco+416,420, "Autenticação Mecânica - Ficha de compensação" , oArial06)

	//CODIGO DE BARRAS
	oBoleto:FWMSBAR("INT25" ,61.25,1.7, cCodigoBarra ,oBoleto,.F.,,.T.,0.02,1,.F.,"Arial",NIL,.F.,2,2,.F.)
Return

Static Function GetNossoNumero()

	//Funcao NossoNum, precisa que as tabelas SE1 e SEE estejam posicionadas,
	//retorna o NN gravado no E1_NUMBCO, com o tamanho do EE_FAXATU
	Local cNossoNum := ""

	While ! MayIUseCode( SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))
		sleep(100)
	EndDO

	// Gerar nosso número banco.
	If Empty(SE1->E1_NUMBCO)
		IF !Empty(SEE->EE_FAXATU)
			cNossoNum := strzero(val(SEE->EE_FAXATU)+1,len(SEE->EE_FAXATU))
		else
			Aviso("Atenção","Tabela Parâmetros dos Bancos (EE_FAXATU) não configurada!",{"Sair"}, 2)
			Return
		EndIF
		IF !Empty(cNossoNum)
			IF RecLock("SEE",.F.)
				SEE->EE_FAXATU := cNossoNum
				SEE->(MsUnlock())
			EndIF
			cNossoNum := nnBradesco(cNossoNum)

			IF RecLock("SE1",.F.)
				SE1->E1_NUMBCO := cNossoNum
				SE1->(MsUnlock())
			EndIF
		EndIF
	Endif

	Leave1Code(SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))

Return cNossoNum

/*/{Protheus.doc} nnBradesco
(Gera nosso número Bradesco)
@author administrador
@since 06/01/2016
@version 1.0
@param cNossoNum, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function nnBradesco(cNossoNum)
Local cNN := strzero(val(cNossoNum),11)
cNN := cNN + Modulo11Brad(alltrim(SEE->EE_CODCART) + cNN)
Return(cNN)

Static Function Modulo11Brad(cNN)
Local cDigNN := "" // Digito nosso número
Local nNossoNum := cNN
nSoma1 := val(subs(nNossoNum,01,1))*2
nSoma2 := val(subs(nNossoNum,02,1))*7
nSoma3 := val(subs(nNossoNum,03,1))*6
nSoma4 := val(subs(nNossoNum,04,1))*5
nSoma5 := val(subs(nNossoNum,05,1))*4
nSoma6 := val(subs(nNossoNum,06,1))*3
nSoma7 := val(subs(nNossoNum,07,1))*2
nSoma8 := val(subs(nNossoNum,08,1))*7
nSoma9 := val(subs(nNossoNum,09,1))*6
nSomaA := val(subs(nNossoNum,10,1))*5
nSomaB := val(subs(nNossoNum,11,1))*4
nSomaC := val(subs(nNossoNum,12,1))*3
nSomaD := val(subs(nNossoNum,13,1))*2

nResto := mod((nSoma1+nSoma2+nSoma3+nSoma4+nSoma5+nSoma6+nSoma7+;
nSoma8+nSoma9+nSomaA+nSomaB+nSomaC+nSomaD),11)

cDigNN := iif(nResto == 1, "P", iif(nResto == 0 , "0", strzero(11-nResto,1)))


Return (cDigNN)

Static Function BolCodBar()

	Local cCodigo := ""
	Local dFator := CTOD("07/10/1997")

	/*
	- Posicoes fixas padrao Banco Central
	Posicao  Tam       Descricao
	01 a 03   03   Codigo de Compensacao do Banco (237)
	04 a 04   01   Codigo da Moeda (Real => 9, Outras => 0)
	05 a 05   01   Digito verificador do codigo de barras
	06 a 19   14   Valor Nominal do Documento sem ponto

	- Campo Livre Padrao Bradesco
	Posicao  Tam       Descricao
	20 a 23   03   Agencia Cedente sem digito verificador
	24 a 25   02   Carteira
	25 A 36   11   Nosso Numero sem digito verificador
	37 A 43   07   Conta Cedente sem digiro verificador
	44 A 44   01   Zero
	*/

	cCodigo := ""
	// Pos 01 a 03 - Identificacao do Banco
	cCodigo += "237"
	// Pos 04 a 04 - Moeda
	cCodigo += "9"
	// Pos 06 a 09 - Fator de vencimento
	cCodigo += Str((SE1->E1_VENCTO - dFator),4)
	// Pos 10 a 19 - Valor
	cCodigo += StrZero(Int(nValorDocumento*100),10)
	// Pos 20 a 23 - Agencia
	cCodigo += alltrim(SEE->EE_AGENCIA) //substr(SEE->EE_AGENCIA,1,4)
	// Pos 24 a 25 - Carteira
	cCodigo +=alltrim(SEE->EE_CODCART)
	// Pos 26 a 36 - Nosso Numero
	cCodigo += SubStr(cNossoNumero,1,11)
	// Pos 37 a 43 - Conta do Cedente
	cCodigo += StrZero(val(alltrim(SEE->EE_CONTA)),7)
	// Pos 44 a 44 - Zeros
	cCodigo += "0"

	// Monta codigo de barras com digito verificador
	cCodigo := Subs(cCodigo,1,4) + BolDigitoBarra(cCodigo) + Subs(cCodigo,5,43)

Return cCodigo


Static Function BolDigitoBarra(cCodigo)

	Local nDigitoBarra := ""

	Local nCnt   := 0
	Local nPeso  := 2
	Local n1     := 1
	Local nResto := 0

	For n1 := Len(cCodigo) To 1 Step -1
		nCnt  := nCnt + Val(SubStr(cCodigo,n1,1))*nPeso
		nPeso := nPeso+1
		If nPeso > 9
			nPeso := 2
		EndIf
	Next n1

	nResto := (nCnt%11)

	nResto := 11-nResto

	IF nResto == 0 .Or. nResto == 1 .Or. nResto > 9
		nDigitoBarra := "1"
	Else
		nDigitoBarra := Str(nResto,1)
	EndIF

Return nDigitoBarra


Static Function BolLinhaDigitavel()

	Local cLinha := ""
	Local cCodigo := ""

	/*
	Primeiro Campo
	Posicao  Tam       Descricao
	01 a 03   03   Codigo de Compensacao do Banco (237)
	04 a 04   01   Codigo da Moeda (Real => 9, Outras => 0)
	05 a 09   05   Pos 1 a 5 do campo Livre(Pos 1 a 4 Dig Agencia + Pos 1 Dig Carteira)
	10 a 10   01   Digito Auto Correcao (DAC) do primeiro campo
	Segundo Campo
	11 a 20   10   Pos 6 a 15 do campo Livre(Pos 2 Dig Carteira + Pos 1 a 9 Nosso Num)
	21 a 21   01   Digito Auto Correcao (DAC) do segundo campo
	Terceiro Campo
	22 a 31   10   Pos 16 a 25 do campo Livre(Pos 10 a 11 Nosso Num + Pos 1 a 8 Conta Corrente + "0")
	32 a 32   01   Digito Auto Correcao (DAC) do terceiro campo
	Quarto Campo
	33 a 33   01   Digito Verificador do codigo de barras
	Quinto Campo
	34 a 37   04   Fator de Vencimento
	38 a 47   10   Valor
	*/

	// Calculo do Primeiro Campo
	cCodigo := ""
	cCodigo := Subs(cCodigoBarra,1,4)+Subs(cCodigoBarra,20,5)
	// Calculo do digito do Primeiro Campo
	cLinha += Subs(cCodigo,1,5)+"."+Subs(cCodigo,6,4)+alltrim(str(BolDigLinha(2,cCodigo)))

	// Insere espaco
	cLinha += " "

	// Calculo do Segundo Campo
	cCodigo := ""
	cCodigo := Subs(cCodigoBarra,25,10)
	// Calculo do digito do Segundo Campo
	cLinha += Subs(cCodigo,1,5)+"."+Subs(cCodigo,6,5)+Alltrim(Str(BolDigLinha(1,cCodigo)))

	// Insere espaco
	cLinha += " "

	// Calculo do Terceiro Campo
	cCodigo := ""
	cCodigo := Subs(cCodigoBarra,35,10)
	// Calculo do digito do Terceiro Campo
	cLinha += Subs(cCodigo,1,5)+"."+Subs(cCodigo,6,5)+Alltrim(Str(BolDigLinha(1,cCodigo)))

	// Insere espaco
	cLinha += " "

	// Calculo do Quarto Campo
	cCodigo := ""
	cCodigo := Subs(cCodigoBarra,5,1)
	cLinha += cCodigo

	// Insere espaco
	cLinha += " "

	// Calculo do Quinto Campo
	cCodigo := ""
	cCodigo := Subs(cCodigoBarra,6,4)+Subs(cCodigoBarra,10,10)
	cLinha += cCodigo

Return cLinha


Static Function BolDigLinha(nCnt,cCodigo)

	Local n1        := 1
	Local nAuxiliar := 0
	Local nInteiro  := 0
	Local nDigito   := 0

	For n1 := 1 to Len(cCodigo)
		nAuxiliar := Val(Substr(cCodigo,n1,1)) * nCnt
		If nAuxiliar >= 10
			nAuxiliar:= (Val(Substr(Str(nAuxiliar,2),1,1))+Val(Substr(Str(nAuxiliar,2),2,1)))
		Endif

		nCnt += 1
		If nCnt > 2
			nCnt := 1
		Endif
		nDigito += nAuxiliar

	Next n1

	IF (nDigito%10) > 0
		nInteiro    := Int(nDigito/10) + 1
	Else
		nInteiro    := Int(nDigito/10)
	EndIF

	nInteiro    := nInteiro * 10
	nDigito := nInteiro - nDigito

Return nDigito





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

	cQuery := ChangeQuery(cQuery)

	Memowrite("c:\temp\QRY_BOL_BRADESCO.txt",cQuery)

	//Verifica se a area já existe e fecha para ser recriada.
	If (Select("QAA")) <> 0
		dbselectarea("QAA")
		QAA->(dbclosearea())
	EndIf

	TcQuery	cQuery New Alias 'QAA'

	DbSelectArea('QAA')
	QAA->(DbGoTop())

Return cQuery
