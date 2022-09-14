#include 'protheus.ch'
#include "fwmvcdef.ch"
#include "fwprintsetup.ch"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} MCnt010
Rotina para impressão de nota de debito

@author Rafael Ricardo Vieceli
@since 12/2015
@version 1.0
/*/
User Function MCnt010()

	Local cPerg := "MCNT010"
	Local oBrowse

	Local aParams := {}

	//cria as perguntas
	//CriaSX1(cPerg)

	//fica em loop a pergunta até o usuario cancelar
	While Pergunte(cPerg, .T.)

		aParams := {mv_par01,mv_par02,mv_par03}

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( "SF2" )
		oBrowse:SetDescription( "Fatura de Débito de Locação de Bens Móveis" )
		oBrowse:SetMenuDef( "PLENAVENTURA_MCNT010" )
		//apenas de produto
		oBrowse:SetFilterDefault( "F2_SERIE == '" + aParams[1] + "' " + ;
			" .AND. F2_DOC >= '" + aParams[2] + "' " + ;
			" .AND. F2_DOC <= '" + aParams[3] + "' " )

		oBrowse:Activate()

	EndDO

Return


/*/{Protheus.doc} MenuDef
Cria as opções do menu na rotina

@author Rafael Ricardo Vieceli
@since 12/2015
@version 1.0
@return aRot, array, Opções do menu da rotina
/*/
Static Function MenuDef()

	Local aRot := {}

	Add Option aRot Title 'Gerar PDF' Action 'u_MCnt010Print' Operation 6 Access 0

Return aRot



/*/{Protheus.doc} MCnt010Print
Função responsavel pela geração do PDF

@author Rafael Ricardo Vieceli
@since 12/2015
@version 1.0
@param cAlias, character, Alias da tabela
@param nReg, numérico, Registro posicionado
@param nOpc, numérico, Opção selecionado no menu
/*/
User Function MCnt010Print(cAlias,nReg,nOpc)

	Local oNota
	Local cArquivo := ""

	Private cMensObs := ""
	Private oDlg

	//instancia classe do boleto
	oNota := NewPrinter(@cArquivo)


	IF oNota != Nil

		//inicia impressao da pagina
		oNota:StartPage()

		SA1->( dbSetOrder(1) )
		SA1->( dbSeek( xFilial("SA1") + SF2->(F2_CLIENTE+F2_LOJA) ) )

		//posiciona nos itens da nota
		SD2->( dbSetOrder(3) )
		SD2->( dbSeek( cChaveSF2 := xFilial("SD2") + SF2->(F2_DOC+F2_SERIE) ) )

		//posiciona na TES
		SF4->( dbSetOrder(1) )
		SF4->( dbSeek( xFilial("SF4") + SD2->D2_TES ) )

		//posiciona no pedido
		SC5->( dbSetOrder(1) )
		SC5->( dbSeek( xFilial("SC5") + SD2->D2_PEDIDO ) )

		CND->( dbSetOrder(4) )
		CND->( dbSeek( xFilial("CND") + SC5->C5_MDNUMED ) )

		//posiciona no titulo (é pre ser sempre apenas 1)
		SE1->( dbSetOrder(2) )
		SE1->( dbSeek( xFilial("SE1") + SF2->(F2_CLIENTE+F2_LOJA+F2_PREFIXO+SF2->F2_DUPL) ) )

		// ******************************************* //
		// Busca Informações da Obs. na Descrição da Nota, exibindo tela para
		// Edição / Inclusão de informação - Gilson Lima 13/04/2016

		cMensObs := mensagem(SC5->C5_XMENNF)

		// ******************************************* //

		Layout(oNota)

		//finaliza impressao da pagina
		oNota:EndPage()

		//gera o PDF
		//oNota:Preview()
		oNota:Print()

		//limpa o objeto
		FreeObj(oNota)
		oNota := Nil

		if cEmpAnt <> '04'
			//assina o arquivo
			MSGRun("Assinando arquivo PDF de Nota de Débito","Processando...", {|| ;
				Sign(cArquivo) })
		Endif

	EndIF

Return


static function mensagem(cMensagem)

	Local oDlg
	Local oObs

	default cMensagem := ''

	DEFINE MSDIALOG oDlg TITLE 'Mensagem Observação Descrição Fatura' From 0,0 TO 240,500 PIXEL

	@ 10,10   SAY "Observação a ser impressa na Descrição Fatura:" SIZE 200, 8 OF oDlg PIXEL
	@ 20,10   GET oObs Var cMensagem MEMO SIZE 230,80 OF oDlg PIXEL

	DEFINE SBUTTON FROM 105, 214 When .T. TYPE 1 ACTION (oDlg:End()) ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

return cMensagem



/*/{Protheus.doc} NewPrinter
Configuração do PDF

@author Rafael Ricardo Vieceli
@since 10/12/2015
@version 1.0
@param cArquivo, character, caminho do arquivo atualizado via referencia
@return oNota, objecto, Objeto de relatório
/*/
Static Function NewPrinter(cArquivo)

	Local cPerg := "MCNT010C"

	Local cTempFile := "fatura_de_debito_" + StrTran(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)," ","")+DtoS(MSDate())+RetNum(Time())+".pdf"
	Local cDiretorio := ""//GetTempPath()

	Local oNota
	Local oSetup

	Local aPergs := {}
	Local lEmp04 := Iif( cEmpAnt <> '04', .T. , .F.)
	aAdd(aPergs,{1,"Salvar na Pasta?"     ,Space(99),"@!","ExistDir(mv_par01)" ,"HSSDIR",,99,.T.})
	aAdd(aPergs,{1,"Certificado A1 .PFX"  ,Space(99),"@N","File(mv_par02)"     ,"DIR"   ,,99,lEmp04})
	aAdd(aPergs,{8,"Senha do Certificado" ,Space(20),,"NaoVazio()"         ,        ,,20,lEmp04})


	IF ParamBox(aPergs, "Informe Diretório, Certificado e Senha",,,,,,,,,.T.,.T.)

		cDiretorio := alltrim(mv_par01) + IIF( Right(alltrim(mv_par01),1) == "\","","\")

		//caminho completo do arquivo
		cArquivo := cDiretorio + cTempFile
		IF File(cArquivo)
			FErase(cArquivo)
		EndIF

		oNota := FWMSPrinter():New(cTempFile,6, .F., cDiretorio, .T.,,oSetup,,.T.,,,.F.)

		oNota:SetResolution(72)
		oNota:SetPortrait( )
		oNota:SetPaperSize( 9 )
		oNota:SetMargin( 20, 20, 20, 20)

		oNota:cPathPDF := cDiretorio
		oNota:lViewPDF := .F.

	EndIF

Return oNota




/*/{Protheus.doc} Layout
Monta o layout do relatório

@author Rafael Ricardo Vieceli
@since 12/2015
@version 1.0
@param oNota, objeto, Objeto do relatório
/*/
Static Function Layout(oNota)

	Local oArial09   := tFont():New("Arial",09,09,nil,.F.,nil,nil,,.T.,.F.)
	Local oArial10   := tFont():New("Arial",10,10,nil,.F.,nil,nil,,.T.,.F.)
	Local oArial12   := tFont():New("Arial",11,9,nil,.F.,nil,nil,,.T.,.F.)
	Local oArial14   := tFont():New("Arial",13,10,nil,.F.,nil,nil,,.T.,.F.)
	Local oArial06N  := tFont():New("Arial",06,06,nil,.T.,nil,nil,,.T.,.F.)
	Local oArial09U  := tFont():New("Arial",09,09,nil,.T.,nil,nil,,.T.,.T.,.F.)
	Local oArial09N  := tFont():New("Arial",09,09,nil,.T.,nil,nil,,.T.,.F.)
	Local oArial12N  := tFont():New("Arial",12,12,nil,.T.,nil,nil,,.T.,.F.)
	Local oArial14N  := tFont():New("Arial",14,14,nil,.T.,nil,nil,,.T.,.F.)
	Local oArial14NI := tFont():New("Arial",14,14,nil,.T.,nil,nil,,.T.,.F.,.T.)
	Local oArial18N  := tFont():New("Arial",18,18,nil,.T.,nil,nil,,.T.,.F.)


	Local oBrush := TBrush():New( , rgb(224,224,224) )

	Local n1

	Local lLocacao := Iif( !Empty(SC5->C5_MDNUMED), .T.,.F.)
	//logo
	oNota:SayAlign( A4ToRow(21), A4ToCol(6), "EMITENTE", oArial14NI,200,,,0)

	oNota:SayBitmap( A4ToRow(26), A4ToCol(6), GetMV("PV_NLONLOG",,"\system\logo_nf_debito_" + cFilAnt + ".jpg"), A4ToRow(60), A4ToRow(20) )

	oNota:SayAlign( A4ToRow(49), A4ToCol(6), SM0->M0_NOMECOM, oArial09N,200,,,0)

	//dados de emitente
	oNota:SayAlign( A4ToRow(21), A4ToCol(73), SM0->M0_ENDCOB, oArial09,200,,,0)
	oNota:SayAlign( A4ToRow(25), A4ToCol(73), "BAIRRO: " + SM0->M0_BAIRCOB, oArial09,200,,,0)
	oNota:SayAlign( A4ToRow(29), A4ToCol(73), alltrim(SM0->M0_CIDCOB) + "" + SM0->M0_ESTCOB, oArial09,200,,,0)
	oNota:SayAlign( A4ToRow(33), A4ToCol(73), "CEP: " + TransForm(SM0->M0_CEPCOB,"@R 99999-999"), oArial09,200,,,0)
	oNota:SayAlign( A4ToRow(37), A4ToCol(73), "Telefones:", oArial09,200,,,0)
	oNota:SayAlign( A4ToRow(41), A4ToCol(73), SM0->M0_TEL, oArial09,200,,,0)
	oNota:SayAlign( A4ToRow(45), A4ToCol(73), "0800-645-0099", oArial09,200,,,0)
	oNota:SayAlign( A4ToRow(49), A4ToCol(73), SUPERGETMV("FS_ENDWEB", .T., ""), oArial09U,200,,,0)

	//titulo
	if lLocacao
		cTipo  := "FATURA DE DÉBITO DE"
		ctipo2 :="LOCAÇÃO DE BENS MÓVEIS"
	else
		cTipo := "FATURA DE DÉBITO"
		cTipo2 :=""
	Endif
	oNota:SayAlign( A4ToRow(29), A4ToCol(112), cTipo, oArial12N,200,,,0)
	
	oNota:SayAlign( A4ToRow(34), A4ToCol(112), cTipo2 , oArial12N,200,,,0)
	

	//numero da fatura
	oNota:Box( A4ToCol(20), A4ToRow(170), A4ToRow(31), A4ToCol(204) ,"01")
	oNota:SayAlign( A4ToRow(20.5), A4ToCol(171), "Nº", oArial09N,200,,,0)
	oNota:SayAlign( A4ToRow(23), A4ToCol(170), alltrim(SF2->F2_DOC), oArial18N,95,,,2)

	//cnpj do do emitente
	oNota:Box( A4ToRow(41), A4ToCol(111), A4ToRow(54), A4ToCol(167) ,"01")
	oNota:SayAlign( A4ToRow(41.5), A4ToCol(112), "CNPJ", oArial09N,200,,,0)
	oNota:SayAlign( A4ToRow(47), A4ToCol(116), TransForm(SM0->M0_CGC,"@R 99.999.999/9999-99"), oArial18N,200,,,0)

	


	If lLocacao
		//VIA
		oNota:Box( A4ToRow(41), A4ToCol(170), A4ToRow(57), A4ToCol(204) ,"01")
		oNota:SayAlign( A4ToRow(45), A4ToCol(170), "1ª VIA" , oArial12N,95,,,2)
		oNota:SayAlign( A4ToRow(50), A4ToCol(170), "CLIENTE" , oArial12N,95,,,2)
		//natureza da operação/cfop
		oNota:Box( A4ToRow(54), A4ToCol(5), A4ToRow(66), A4ToCol(112) ,"01")
		oNota:SayAlign( A4ToRow(54.5), A4ToCol(6), "NATUREZA OPERAÇÃO", oArial09N,200,,,0)
		oNota:SayAlign( A4ToRow(54.5), A4ToCol(85), "CFOP", oArial09N,200,,,0)
		oNota:SayAlign( A4ToRow(60), A4ToCol(8), SF4->F4_FINALID, oArial14,200,,,0)
		oNota:SayAlign( A4ToRow(60), A4ToCol(87), SD2->D2_CF, oArial14,200,,,0)
	
		//inscrição municipal
		oNota:Box( A4ToRow(54), A4ToCol(111), A4ToRow(66), A4ToCol(167) ,"01")
		oNota:SayAlign( A4ToRow(54.5), A4ToCol(112), "INSCRIÇÃO MUNICIPAL", oArial09N,200,,,0)
		oNota:SayAlign( A4ToRow(59), A4ToCol(116), SM0->M0_INSCM, oArial18N,200,,,0)
	else
		//oNota:Box( A4ToRow(31), A4ToCol(170), A4ToRow(54), A4ToCol(204) ,"01")
		oNota:Box( A4ToRow(31), A4ToCol(170), A4ToRow(40), A4ToCol(204) ,"01")
		oNota:SayAlign( A4ToRow(34), A4ToCol(170), "SERIE: " + SF2->F2_SERIE, oArial12N,95,,,2)		
	Endif

	//BLOCO DESTINATARIO
	oNota:SayAlign( A4ToRow(66), A4ToCol(6), "DESTINATÁRIO", oArial14NI,200,,,0)

	//nome/razao social
	oNota:Box( A4ToRow(71), A4ToCol(5), A4ToRow(82), A4ToCol(122) ,"01")
	oNota:SayAlign( A4ToRow(71.5), A4ToCol(6), "NOME/RAZÃO SOCIAL", oArial09N,200,,,0)
	oNota:SayAlign( A4ToRow(77), A4ToCol(6), SA1->A1_NOME, oArial14,200,,,0)

	//CNPJ/CPF
	oNota:Box( A4ToRow(71), A4ToCol(121), A4ToRow(82), A4ToCol(167) ,"01")
	oNota:SayAlign( A4ToRow(71.5), A4ToCol(122), "CNPJ/CPF", oArial09N,200,,,0)
	oNota:SayAlign( A4ToRow(77), A4ToCol(124), TransForm(SA1->A1_CGC,IIF(SA1->A1_PESSOA=="J","@R 99.999.999/9999-99","@R 999.999.999-99")), oArial14,200,,,0)

	//Endereço
	oNota:Box( A4ToRow(82), A4ToCol(5), A4ToRow(93), A4ToCol(141) ,"01")
	oNota:SayAlign( A4ToRow(82.5), A4ToCol(6), "ENDEREÇO", oArial09N,200,,,0)
	oNota:SayAlign( A4ToRow(88), A4ToCol(6), SA1->A1_END, oArial14,200,,,0)

	//CEP
	oNota:Box( A4ToRow(82), A4ToCol(140), A4ToRow(93), A4ToCol(167) ,"01")
	oNota:SayAlign( A4ToRow(82.5), A4ToCol(141), "CEP", oArial09N,200,,,0)
	oNota:SayAlign( A4ToRow(88), A4ToCol(143), TransForm(SA1->A1_CEP,"@R 99999-999"), oArial14,200,,,0)

	//BAIRRO
	oNota:Box( A4ToRow(93), A4ToCol(5), A4ToRow(104), A4ToCol(47) ,"01")
	oNota:SayAlign( A4ToRow(93.5), A4ToCol(6), "BAIRRO", oArial09N,200,,,0)
	oNota:SayAlign( A4ToRow(99), A4ToCol(6), SA1->A1_BAIRRO, oArial14,200,,,0)

	//MUNICIPIO
	oNota:Box( A4ToRow(93), A4ToCol(46), A4ToRow(104), A4ToCol(85) ,"01")
	oNota:SayAlign( A4ToRow(93.5), A4ToCol(47), "MUNICÍPIO", oArial09N,200,,,0)
	oNota:SayAlign( A4ToRow(99), A4ToCol(47), SA1->A1_MUN, oArial14,200,,,0)

	//ESTADO
	oNota:Box( A4ToRow(93), A4ToCol(84), A4ToRow(104), A4ToCol(95) ,"01")
	oNota:SayAlign( A4ToRow(93.5), A4ToCol(85), "UF", oArial09N,200,,,0)
	oNota:SayAlign( A4ToRow(99), A4ToCol(85), SA1->A1_EST, oArial14,200,,,0)

	//FONE
	oNota:Box( A4ToRow(93), A4ToCol(94), A4ToRow(104), A4ToCol(167) ,"01")
	oNota:SayAlign( A4ToRow(93.5), A4ToCol(95), "E-MAIL", oArial09N,200,,,0)
	oNota:SayAlign( A4ToRow(99), A4ToCol(95), First(SA1->A1_EMAIL," ;"), oArial14,200,,,0)

	//data emissao e saida
	oNota:Box( A4ToRow(71), A4ToCol(170), A4ToRow(82), A4ToCol(204) ,"01")
	oNota:SayAlign( A4ToRow(71.5), A4ToCol(171), "DATA DA EMISSÃO", oArial09N,200,,,0)
	oNota:SayAlign( A4ToRow(77), A4ToCol(170), FormDate(SF2->F2_EMISSAO) , oArial14,95,,,2)

	oNota:Box( A4ToRow(82), A4ToCol(170), A4ToRow(93), A4ToCol(204) ,"01")
	oNota:SayAlign( A4ToRow(82.5), A4ToCol(171), "DATA SAÍDA/ENTRADA", oArial09N,200,,,0)
	oNota:SayAlign( A4ToRow(88), A4ToCol(170), FormDate(MsDate()) , oArial14,95,,,2)

	oNota:Box( A4ToRow(93), A4ToCol(170), A4ToRow(104), A4ToCol(204) ,"01")
	oNota:SayAlign( A4ToRow(93.5), A4ToCol(171), "HORA DA SAÍDA", oArial09N,200,,,0)
	oNota:SayAlign( A4ToRow(99), A4ToCol(170), Time() , oArial14,95,,,2)


	cTipo := iif(lLocacao,"FORNECIMENTOS","REEMBOLSO")
	cTipo2 := iif(lLocacao,"VALOR DA LOCAÇÃO","VALOR")
	cTipo3 := iif(lLocacao,"LOCAÇÃO DE EQUIPAMENTO","MANUTENÇÃO USO INADEQUADO")


	//BLOCO PRODUTOS
	oNota:SayAlign( A4ToRow(104), A4ToCol(6), cTipo, oArial14NI,200,,,0)
	//coloca fundo cinza
	oNota:FillRect({ A4ToRow(109), A4ToCol(5), A4ToRow(114), A4ToCol(204)  },oBrush)
	//e monta com line, porque box sobrepoew o fundo cinza
	oNota:Line( A4ToRow(109), A4ToCol(5), A4ToRow(109), A4ToCol(204) ,,"01")
	oNota:Line( A4ToRow(109), A4ToCol(5), A4ToRow(114), A4ToCol(5) ,,"01")
	oNota:SayAlign( A4ToRow(110), A4ToCol(6), "DESCRIÇÃO", oArial09N,200,,,0)
	oNota:Line( A4ToRow(109), A4ToCol(167), A4ToRow(114), A4ToCol(167) ,,"01")
	oNota:SayAlign( A4ToRow(110), A4ToCol(168), cTipo2, oArial09N,200,,,0)
	oNota:Line( A4ToRow(109), A4ToCol(204), A4ToRow(114), A4ToCol(204) ,,"01")	
	oNota:Box( A4ToRow(114), A4ToCol(5), A4ToRow(162+60), A4ToCol(167) ,"01")
	//oNota:SayAlign( A4ToRow(116), A4ToCol(8), cTipo3, oArial14,300,,,0)


	//oNota:SayAlign( A4ToRow(124), A4ToCol(8), CND->CND_OBS, oArial12,A4ToCol(160),A4ToRow(100),,0)
	//oNota:SayAlign( A4ToRow(124), A4ToCol(8), cMensObs, oArial12,A4ToCol(160),A4ToRow(300),,0)
	oNota:SayAlign( A4ToRow(124), A4ToCol(8), cMensObs, oArial14,A4ToCol(160),A4ToRow(300),,0)

	oNota:Box( A4ToRow(114), A4ToCol(167), A4ToRow(162+60), A4ToCol(204) ,"01")
	oNota:SayAlign( A4ToRow(116), A4ToCol(168), TransForm(SF2->F2_VALBRUT,PesqPict("SF2","F2_VALBRUT")), oArial14,A4ToCol(30),,,1)
	oNota:Line( A4ToRow(151+60), A4ToCol(167), A4ToRow(151+60), A4ToCol(204) ,,"01")
	oNota:SayAlign( A4ToRow(151.5+60), A4ToCol(168), "TOTAL", oArial09N,200,,,0)
	oNota:SayAlign( A4ToRow(156+60), A4ToCol(168), TransForm(SF2->F2_VALBRUT,PesqPict("SF2","F2_VALBRUT")), oArial14N,A4ToCol(30),,,1)


	//BLOCO OBSERVAÇÕES
	oNota:SayAlign( A4ToRow(162.5+60), A4ToCol(6), "OBSERVAÇÕES", oArial14NI,200,,,0)
	oNota:Box( A4ToRow(168+60), A4ToCol(5), A4ToRow(199+60), A4ToCol(95) ,"01")
	IF ! Empty(SE1->E1_VENCTO)
		oNota:SayAlign( A4ToRow(169+60), A4ToCol(6), "VENCIMENTO: " + FormDate(SE1->E1_VENCTO), oArial09N,200,,,0)
	EndIF

	IF ! Empty(SC5->C5_MDCONTR)
		oNota:SayAlign( A4ToRow(179+60), A4ToCol(6), "CONTRATO: " + SC5->C5_MDCONTR, oArial09N,200,,,0)
	EndIF

	oNota:SayAlign( A4ToRow(191+60), A4ToCol(8), "CASO NÃO RECEBA O BOLETO, FAVOR ENTRAR EM CONTATO", oArial09,250,,,0)
	oNota:SayAlign( A4ToRow(195+60), A4ToCol(6), "COM O DEPARTAMENTO FINANCEIRO NO FONE " + GetMV("PV_NLOCFON",,"(41) 3094-2213"), oArial09,250,,,0)

	oNota:Box( A4ToRow(168+60), A4ToCol(95), A4ToRow(199+60), A4ToCol(204) ,"01")
	oNota:SayAlign( A4ToRow(168.5+60), A4ToCol(96), "ASSINATURA DIGITAL", oArial09N,200,,,0)

	For n1 := 5 to 203
		oNota:Say( A4ToRow(207+60), A4ToCol(n1), ".", oArial09,,,,0)
	Next n1

	if lLocacao
		//coloca fundo cinza
		oNota:FillRect({ A4ToRow(209+60), A4ToCol(5), A4ToRow(214+60), A4ToCol(204)  },oBrush)
		oNota:FillRect({ A4ToRow(214+60), A4ToCol(147), A4ToRow(225+60), A4ToCol(204)  },oBrush)
		//e monta com line, porque box sobrepoew o fundo cinza
		oNota:Line( A4ToRow(209+60), A4ToCol(5), A4ToRow(209+60), A4ToCol(204) ,,"01") //horizontal
		oNota:SayAlign( A4ToRow(210.5+60), A4ToCol(6), "RECEBEMOS DE " + alltrim(SM0->M0_NOMECOM) + ", AS LOCAÇÕES CONSTANTES NESTA FATURA DE BEBITO DE LOCAÇÃO DE BENS MOVEIS." , oArial06N,500,,,0)
		oNota:Line( A4ToRow(209+60), A4ToCol(5), A4ToRow(225+60), A4ToCol(5) ,,"01") //vertical
		oNota:SayAlign( A4ToRow(214.5+60), A4ToCol(6), "DATA DO RECEBIMENTO", oArial09N,200,,,0)
		oNota:Line( A4ToRow(209+60), A4ToCol(204), A4ToRow(225+60), A4ToCol(204) ,,"01") //vertical
		oNota:Line( A4ToRow(214+60), A4ToCol(5), A4ToRow(214+60), A4ToCol(204) ,,"01") //horizontal
		oNota:Line( A4ToRow(214+60), A4ToCol(47), A4ToRow(225+60), A4ToCol(47) ,,"01") //vertical
		oNota:SayAlign( A4ToRow(214.5+60), A4ToCol(48), "ASSINATURA", oArial09N,200,,,0)
		oNota:Line( A4ToRow(214+60), A4ToCol(147), A4ToRow(225+60), A4ToCol(147) ,,"01") //vertical
		oNota:SayAlign( A4ToRow(214.5+60), A4ToCol(148), "FATURA DE BEBITO DE LOCAÇÃO DE BENS MOVEIS." , oArial06N,500,,,0)
		oNota:SayAlign( A4ToRow(219+60), A4ToCol(160), "Nº", oArial12N,200,,,0)
		oNota:SayAlign( A4ToRow(219+60), A4ToCol(175), SF2->F2_DOC, oArial12,200,,,0)
		oNota:Line( A4ToRow(225+60), A4ToCol(5), A4ToRow(225+60), A4ToCol(204) ,,"01") //horizontal
	Endif

Return


Static Function A4ToCol(nMilimitro)
//largura da pagina * largula em milimitros / largura da pagina A4 em mm
Return Round(595 * (nMilimitro / 210), 0)

Static Function A4ToRow(nMilimitro)
//altura da pagina * altura em milimitros / altura da pagina A4 em mm
Return Round(842 * (nMilimitro / 297), 0)



/*/{Protheus.doc} CriaSX1
Cria/Atualiza as perguntas para a rotina

@author Rafael Ricardo Vieceli
@since 12/2015
@version 1.0
@param cPerg, character, Codigo da pergunta
/*/
/*Static Function CriaSX1(cPerg)

	PutSX1(cPerg,"01","Serie de"        ,"","","mv_ch01","C",03,0,0,"G","","","","","mv_par01")
	PutSX1(cPerg,"02","Documento de"    ,"","","mv_ch02","C",09,0,0,"G","","","","","mv_par02")
	PutSX1(cPerg,"03","Documento ate"   ,"","","mv_ch03","C",09,0,0,"G","","","","","mv_par03")

Return */


Static Function Sign(cArquivo)

	Local nVezes := 0
	Local cRemoteLocation := GetClientDir()

	Local cBatFile := "sign-"+cValToChar(ThreadID())+".bat"
	Local cLogFile := "log-"+cValToChar(ThreadID())+".txt"
	Local cSignedFile := StrTran(SubStr(cArquivo,rAt("\",cArquivo)+1),".pdf","_signed.pdf")
	Local cFileLocation := SubStr(cArquivo,1,rAt("\",cArquivo))

	Local cPassword := alltrim(mv_par03)

	//pasta Sync
	cRemoteLocation += IIF( Right(cRemoteLocation,1) == "\","","\") + "SignPDF\"

	//copia o programa do server para o remote
	Processa({||SyncJSignPDF()})

	//espera terminar de gerar o PDF
	sleep(5000)
	While ! File(cArquivo) .And. nVezes <= 15
		Sleep(1000)
		nVezes++
	EndDO

	//se passou 15 segundos e não gerou o PDF, deu algo errado
	IF nVezes > 15
		Aviso("Atenção", "Arquivo PDF não encontrado para assinatura. Tente novamente", {"Sair"}, 1)
		Return
	EndIF

	//nunca vai acontecer, mas se tentar assinar um arquivo já assinado (mesmo nome)
	IF File(cFileLocation + cSignedFile)
		//exclui
		fErase(cFileLocation + cSignedFile)
	EndIF

	//gera o .BAT com instrução de assinatura
	//foi feito isso para poder capturar o resultado da assinatura
	MemoWrite(cRemoteLocation+cBatFile,'java -jar JSignPdf.jar -kst PKCS12  -ksf "'+alltrim(mv_par02)+'" -ksp '+cPassword+' -V "'+cArquivo+'" -llx 281 -lly 185 -urx 575 -ury 125 -d "'+cFileLocation+'"')

	//se não encontrar o BAT, alguma coisa deu errado
	IF ! File( cRemoteLocation + cBatFile)
		Aviso("Atenção", "Não foi possivel gerar o arquivo BAT para assinatura. Tente novamente", {"Sair"}, 1)
		Return
	EndIF

	//assina
	//WinExec abriu o DOS, shellExecute não
	//WinExec( cRemoteLocation + cBatFile + " > " + cRemoteLocation + cLogFile )
	shellExecute("Open", cRemoteLocation + cBatFile, " > " + cRemoteLocation + cLogFile, cRemoteLocation, 0)

	nVezes := 0
	//espera terminar de gerar o PDF
	sleep(5000)
	While ! File(cFileLocation + cSignedFile) .And. nVezes <= 15
		Sleep(1000)
		nVezes++
	EndDO

	//exclui o BAT
	fErase( cRemoteLocation + cBatFile )

	//se passou 15 segundos e não gerou o PDF, deu algo errado
	IF nVezes > 15
		Aviso("Atenção", "Arquivo PDF assinatura não encontrado. Tente novamente ou assine manualmente." +CRLF+CRLF+StrTran(MemoRead(cRemoteLocation+cLogFile),"-ksp "+cPassword,"-ksp "+replicate("*",len(cPassword))), {"Sair"}, 3)
		fErase(cRemoteLocation + cLogFile)
		Return
	EndIF

	//exclui o arquivo original
	fErase( cArquivo)

	//gerou o arquivo assinado
	IF Aviso("Resultado", "Arquivo PDF assinado com sucesso." + CRLF+CRLF+ StrTran(MemoRead(cRemoteLocation+cLogFile),"-ksp "+cPassword,"-ksp "+replicate("*",len(cPassword))), {"Abrir","Sair"}, 3) == 1
		ShellExecute("open", cFileLocation + cSignedFile, "", "", 1)
	EndIF
	//exclui o log
	fErase(cRemoteLocation + cLogFile)

Return


Static Function SyncJSignPDF()
	Local n1
	Local cRemoteLocation := GetClientDir()
	Local cServerLocation := "\SignPDF\"
	Local aFiles := {;
		"conf\conf.properties",;
		"conf\pkcs11.cfg",;
		"lib\bcprov-jdk15-146.jar",;
		"lib\commons-cli-1.2.jar",;
		"lib\commons-io-2.1.jar",;
		"lib\commons-lang3-3.1.jar",;
		"lib\jsignpdf-itxt-1.6.1.jar",;
		"lib\log4j-1.2.16.jar",;
		"JSignPdf.jar"}

	//pasta Sync
	cRemoteLocation += IIF( Right(cRemoteLocation,1) == "\","","\") + "SignPDF\"

	//cria as pastas dentro do remote
	MakeDir(cRemoteLocation)
	MakeDir(cRemoteLocation+"conf")
	MakeDir(cRemoteLocation+"lib")

	ProcRegua(len(aFiles))

	For n1 := 1 to len(aFiles)
		IncProc(aFiles[n1])
		IF ! File(cRemoteLocation + aFiles[n1])
			__CopyFile( cServerLocation + aFiles[n1], cRemoteLocation + aFiles[n1] )
		EndIF
	Next n1

Return


Static Function First(cString,cSeparador)

	Local aSeparado := StrTokArr(cString, cSeparador)
	Local cRetorno := ""

	IF len(aSeparado) != 0
		cRetorno := aSeparado[1]
	EndIF

Return cRetorno
