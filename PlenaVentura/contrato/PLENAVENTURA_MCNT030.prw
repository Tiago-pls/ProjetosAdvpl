#include "protheus.ch"
#include "msole.ch"

/*/{Protheus.doc} MCnt020
Geração de contrato via Word

@author Rafael Ricardo Vieceli
@since 10/12/2015
@version 1.0
/*/
User Function MCnt030()

	Local cPergunta := "MCNT020A"

	//abre tela de perguntas
	While Ask(cPergunta)

		CN9->( dbSetOrder(1) )
		CN9->( dbSeek( xFilial("CN9") + mv_par04 + mv_par05 ) )

		IF CN9->( Found() )

			//verifica se exist o arquivo template E diretório destino
			IF File(mv_par01) .And. ExistDir(mv_par03)
				//gera o arquivo WORD ou PDF a partir do template
				MsgRun( "Gerando documento com MS WORD...", "Aguarde", {|| ;
				GeraWord(alltrim(mv_par01),alltrim(mv_par03),mv_par02==1) })
			Else
				Aviso('Atenção','Template ou pasta destino não existe, verifique.', {'Sair'}, 2)
			EndIF
		Else
			Aviso('Atenção','Contrato ' +mv_par04+ "/" + mv_par05 + 'não encontrato.', {'Sair'}, 2)
		EndIF

	EndDO
Return

Static function Ask(cPergunta)
    Local lRet:= Pergunte(cPergunta,.T.)
return lRet

Static Function GeraWord(cLayout,cSalvarEm,lPDF)

	Local oWord

	Local wdFormatPDF := 17

	Local cChaveAC8 := ""

	Local cNomeDoc := ""

	Local nLinha := 0

	Local nValorUniTotal := 0
	Local nValorTotal := 0

	Local n1
	
	Local cItensDesc := ""
	Local cItensCond := ""
	Local cItensCDia := ""
	Local cItensExce := ""
	Local cEquipamentos := alltrim(MV_PAR06) // equipamentos selecionados
	Local aEquip :={}

	for nCont :=1 to len(cEquipamentos) Step 3
		aadd(aEquip, SubStr( cEquipamentos , nCont , 3 ))
	next nCont 
	cMensObs := mensagem('')
	//Abre o link com o word
	oWord := OLE_CreateLink()

	OLE_NewFile( oWord, cLayout)
	OLE_SetProperty( oWord, oleWdVisible, .F. )

	//campos da empresa
	OLE_SetDocumentVar( oWord, 'M0_CODIGO'  , SM0->M0_CODIGO )
	OLE_SetDocumentVar( oWord, 'M0_CODFIL'  , SM0->M0_CODFIL )
	OLE_SetDocumentVar( oWord, 'M0_FILIAL'  , SM0->M0_FILIAL )
	OLE_SetDocumentVar( oWord, 'M0_NOME'    , SM0->M0_NOME )
	OLE_SetDocumentVar( oWord, 'M0_NOMECOM' , SM0->M0_NOMECOM )
	OLE_SetDocumentVar( oWord, 'M0_ENDCOB'  , SM0->M0_ENDCOB )
	OLE_SetDocumentVar( oWord, 'M0_CIDCOB'  , SM0->M0_CIDCOB )
	OLE_SetDocumentVar( oWord, 'M0_ESTCOB'  , SM0->M0_ESTCOB )
	OLE_SetDocumentVar( oWord, 'M0_BAIRCOB' , SM0->M0_BAIRCOB )
	OLE_SetDocumentVar( oWord, 'M0_COMPCOB' , SM0->M0_COMPCOB )
	OLE_SetDocumentVar( oWord, 'M0_CEPCOB'  , transform(SM0->M0_CEPCOB,'@R 99999-999') )
	OLE_SetDocumentVar( oWord, 'M0_CGC'     , transform(SM0->M0_CGC,'@R 99.999.999/9999-99') )
	OLE_SetDocumentVar( oWord, 'M0_INSCM'   , SM0->M0_INSCM )
	OLE_SetDocumentVar( oWord, 'M0_TEL'     , SM0->M0_TEL )
	OLE_SetDocumentVar( oWord, 'M0_FAX'     , SM0->M0_FAX )

	//Posiciona na revisao atual do contrato
	CN9->( dbSetOrder(1) )
	CN9->( dbSeek( xFilial("CN9") + CN9->CN9_NUMERO + "ZZZ",.T.) )
	CN9->( dbSkip(-1) )

	//nome do arquivo destino
	cNomeDoc  := "contrato_"+TiraBarras(alltrim(CN9->CN9_NUMERO))+"_"+TiraBarras(FormDate(Date()),"-")+"_"+TiraBarras(Time(),"-")

	//coloca barra no final, caso não tenha
	cSalvarEm := IIf( Right( AllTrim( cSalvarEm ), 1 ) <> "\", PadR( AllTrim( cSalvarEm ) + "\", Len( cSalvarEm ) ), cSalvarEm )

	CNC->( dbSetOrder(3) )
	CNC->( dbSeek( xFilial("CNC") + CN9->(CN9_NUMERO+CN9_REVISA) ) )

	//posiciona no cliente do contrato
	SA1->( dbSetOrder(1) )
	SA1->( dbSeek( xFilial("SA1") + CNC->(CNC_CLIENT+CNC_LOJACL) ) )

	//posiciona no cliente do contrato
	CNU->( dbSetOrder(1) )
	CNU->( dbSeek( xFilial("CNU") + CN9->CN9_NUMERO ) )

	//posiciona no vendedor do contrato
	SA3->( dbSetOrder(1) )
	SA3->( dbSeek( xFilial("SA3") + CNU->CNU_CODVD ) )

	//posiciona na condição de pagamento
	SE4->( dbSetOrder(1) )
	SE4->( dbSeek( xFilial("SE4") + CN9->CN9_CONDPG ) )

	//posiciona no tipo de contrato
	CN1->( dbSetOrder(1) )
	CN1->( dbSeek( xFilial("CN1") + CN9->CN9_TPCTO ) )

	//campos de contrato
	OLE_SetDocumentVar( oWord, 'CN9_NUM'   , CN9->CN9_NUMERO )
	OLE_SetDocumentVar( oWord, 'CN9_REVISA'   , CN9->CN9_REVISA )
	OLE_SetDocumentVar( oWord, 'CN9_DTINIC'   , FormDate(CN9->CN9_DTINIC) )
	OLE_SetDocumentVar( oWord, 'CN9_DTINIC_EXTENSO'   , DataExtenso(CN9->CN9_DTINIC) )
	OLE_SetDocumentVar( oWord, 'CN9_DTASSI'   , FormDate(CN9->CN9_DTASSI) )
	OLE_SetDocumentVar( oWord, 'CN9_DTASSI_EXTENSO'   , DataExtenso(CN9->CN9_DTASSI) )
	OLE_SetDocumentVar( oWord, 'CN9_DTFIM'    , FormDate(CN9->CN9_DTFIM) )
	OLE_SetDocumentVar( oWord, 'CN9_VIGE'     , IIF(CN9->CN9_UNVIGE$"123",cValToChar(CN9->CN9_VIGE),"") )
	OLE_SetDocumentVar( oWord, 'CN9_UNVIGE'   , GetOpcao("CN9_UNVIGE",CN9->CN9_UNVIGE) )
	OLE_SetDocumentVar( oWord, 'vigencia_diffInMonths'  , cValToChar(DateDiffMonth(CN9->CN9_DTINIC,CN9->CN9_DTFIM)) )
	OLE_SetDocumentVar( oWord, 'vigencia_diffInDays'   , cValtoChar(DateDiffMonth(CN9->CN9_DTINIC,CN9->CN9_DTFIM)*30) )

	OLE_SetDocumentVar( oWord, 'DDATABASE'         , FormDate(dDataBase) )
	OLE_SetDocumentVar( oWord, 'DDATABASE_EXTENSO' , DataExtenso(dDataBase) )
	OLE_SetDocumentVar( oWord, 'FUNCAODATE'        , FormDate(Date()) )
	OLE_SetDocumentVar( oWord, 'FUNCAODATE_EXTENSO', DataExtenso(Date()) )

	//campo de descrição de pagamento
	OLE_SetDocumentVar( oWord, 'E4_DESCRI'    , SE4->E4_DESCRI )

	//campo de cliente
	OLE_SetDocumentVar( oWord, 'A1_NOME'    , SA1->A1_NOME )
	OLE_SetDocumentVar( oWord, 'A1_NREDUZ'  , SA1->A1_NREDUZ )
	OLE_SetDocumentVar( oWord, 'A1_END'     , SA1->A1_END )
	OLE_SetDocumentVar( oWord, 'A1_CEP'     , transform(SA1->A1_CEP,'@R 99999-999') )
	OLE_SetDocumentVar( oWord, 'A1_MUN'     , SA1->A1_MUN )
	OLE_SetDocumentVar( oWord, 'A1_EST'     , SA1->A1_EST )
	OLE_SetDocumentVar( oWord, 'A1_DDD'     , SA1->A1_DDD )
	OLE_SetDocumentVar( oWord, 'A1_TEL'     , SA1->A1_TEL )
	OLE_SetDocumentVar( oWord, 'A1_FAX'     , SA1->A1_FAX )
	OLE_SetDocumentVar( oWord, 'A1_CGC'     , TransForm(SA1->A1_CGC,IIF(SA1->A1_PESSOA=="F","@R 999.999.999-99","@R 99.999.999/9999-99")) )
	OLE_SetDocumentVar( oWord, 'A1_INSCR'   , SA1->A1_INSCR )
	OLE_SetDocumentVar( oWord, 'A1_INSCRM'  , SA1->A1_INSCRM )
	OLE_SetDocumentVar( oWord, 'A1_EMAIL'   , SA1->A1_EMAIL )
	OLE_SetDocumentVar( oWord, 'A1_CONTATO' , SA1->A1_CONTATO )
	OLE_SetDocumentVar( oWord, 'A1_HPAGE'  	, SA1->A1_HPAGE )

	SYA->( dbSetOrder(1) )
	SYA->( dbSeek( xFilial("SYA") + SA1->A1_PAIS ) )

	//campos de cadastro de paises
	OLE_SetDocumentVar( oWord, 'A1_PAISDES'  , alltrim(SYA->YA_DESCR) )

	//campos de cadastro de vendedor
	OLE_SetDocumentVar( oWord, 'A3_NOME'   , SA3->A3_NOME )
	OLE_SetDocumentVar( oWord, 'A3_NREDUZ' , SA3->A3_NREDUZ )

	//posiciona nos contatos relacionados com o cliente
	AC8->( dbSetOrder(2) )
	AC8->( dbSeek( cChaveAC8 := xFilial("AC8") + "SA1" + xFilial("SA1") +PadR(SA1->(A1_COD+A1_LOJA),25)  ) )

	nLinha := 0

	//percore todos, procurando por cada responsavel
	While !AC8->( Eof() ) .And. AC8->(AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT) == cChaveAC8
		//se for responsavel legal
		IF AC8->AC8_LEGAL == "S"
		 	nLinha++
			Responsavel(oWord,nLinha)
		EndIF
		AC8->( dbSkip() )
	EndDO

	//se não achou algum, preenche com dados "em branco"
	For n1 := nLinha to 2
		Responsavel(oWord,n1,.T.)
	Next

	//posiciona na planilha (terá apenas uma)
	CNA->( dbSetOrder(1) )
	CNA->( dbSeek( xFilial("CNA") + CN9->(CN9_NUMERO+CN9_REVISA) ) )

	//posiciona no tipo de planilha
	CNL->( dbSetOrder(1) )
	CNL->( dbSeek( xFilial("CNL") + CNA->CNA_TIPPLA ) )

	//posiciona no primeiro item da planilha (terá apenas uma)
	CNB->( dbSetOrder(1) )
	CNB->( dbSeek( xFilial("CNB") + CNA->(CNA_CONTRA+CNA_REVISA+CNA_NUMERO) ) )

	//campsos do cabeçalho da planilha
	OLE_SetDocumentVar( oWord, 'CNA_VLTOT'         , transform(CNA->CNA_VLTOT,PesqPict("CNA","CNA_VLTOT")) )
	OLE_SetDocumentVar( oWord, 'CNA_VLTOT_EXTENSO' , Extenso(CNA->CNA_VLTOT ,.F.,CN9->CN9_MOEDA,,"1",.T.,.F.) )

	nLinha := 0

	While !CNB->( Eof() ) .And. CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO) == CNA->(CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO)
		IF CNB->CNB_SUBST  != 'S' .And. Empty(CNB->CNB_ITMDST) .and. ( Empty(aEquip) .or. aScan(aEquip,CNB->CNB_ITEM) >0)
			SB5->( dbSetOrder(1) )
			SB5->( dbSeek( xFilial("SB5") + CNB->CNB_PRODUT ) )
			nLinha++
			OLE_SetDocumentVar( oWord, 'ITEM1' + cValToChar(nLinha), CNB->CNB_ITEM )
			OLE_SetDocumentVar( oWord, 'ITEM2' + cValToChar(nLinha), alltrim(CNB->CNB_PRODUT) + '-'+Alltrim(CNB->CNB_DESCRI ))
			nValorUniTotal += CNB->CNB_VLUNIT
			nValorTotal    += CNB->CNB_VLTOT
		EndIF

		CNB->( dbSkip() )
	EndDO

	OLE_SetDocumentVar( oWord, 'QtdePro', cValToChar(nLinha))
	OLE_ExecuteMacro( oWord, "tabItens")
	OLE_SetDocumentVar( oWord, 'ContratoObjeto',  MSMM(CN9->CN9_CODOBJ) )
	OLE_SetDocumentVar( oWord, 'OBJ',  cMensObs) 

	OLE_UpdateFields( oWord )
	OLE_SaveAsFile( oWord, cSalvarEm + cNomeDoc + '.doc',,,.F.,oleWdFormatDocument )

	IF lPDF
		OLE_SaveAsFile( oWord, cSalvarEm + cNomeDoc + '.pdf',,,.F.,wdFormatPDF)		

		if MSGYESNO( 'Deseja assinar documento ?', 'Atenção' )
			MSGRun("Assinando arquivo RESUMO","Processando...", {|| ;
				u_Sign(cSalvarEm + cNomeDoc + '.pdf') })

		Endif
		IF File(cSalvarEm + cNomeDoc + '.pdf')
			ferase(cSalvarEm + cNomeDoc + '.doc')
		EndIF
	EndIF

	OLE_CloseFile( oWord )
	OLE_CloseLink( oWord )

	//salva o documento no banco de conhecimento
	SaveOnDocuments(cSalvarEm+cNomeDoc+IIF(lPDF,".pdf",".doc"))

Return

Static Function Responsavel(oWord, nLinha, lVazio)

	default lVazio := .F.

	IF !lVazio
		SU5->( dbSetOrder(1) )
		SU5->( dbSeek( xFilial("SU5") + AC8->AC8_CODCON ) )
	EndIF

	//campos do contato
	OLE_SetDocumentVar( oWord, 'U5_CONTAT'+"_"+cValToChar(nLinha)  , IIF( lVazio, "", SU5->U5_CONTAT) )
	OLE_SetDocumentVar( oWord, 'U5_RG'+"_"+cValToChar(nLinha)      , IIF( lVazio, "", SU5->U5_RG) )
	OLE_SetDocumentVar( oWord, 'U5_CPF'+"_"+cValToChar(nLinha)     , IIF( lVazio, "", SU5->U5_CPF) )
	OLE_SetDocumentVar( oWord, 'U5_EMAIL'+"_"+cValToChar(nLinha)   , IIF( lVazio, "", SU5->U5_EMAIL) )

Return

Static Function TiraBarras(cString,cPor)

	default cPor := ""

	cString := StrTran(cString,"\",cPor)
	cString := StrTran(cString,"/",cPor)
	cString := StrTran(cString,":",cPor)
	cString := StrTran(cString,"*",cPor)
	cString := StrTran(cString,"?",cPor)
	cString := StrTran(cString,"<",cPor)
	cString := StrTran(cString,">",cPor)
	cString := StrTran(cString,"|",cPor)
	cString := StrTran(cString,".",cPor)

Return cString

Static Function SaveOnDocuments(cDocumento)

	Local lRet := .F.

	Local cFile := ""
	Local cExten := ""

	Begin Transaction

	//valida e cria tipo de documento
	TipoDocumento("AUT")

	RecLock("CNK",.T.)
	CNK->CNK_FILIAL := xFilial("CNK")
	CNK->CNK_CODIGO := GetSX8Num('CNK','CNK_CODIGO')
	CNK->CNK_DESCRI := "IMPRESSAO DE CONTRATOS WORD   "
	CNK->CNK_CONTRA := CN9->CN9_NUMERO
	CNK->CNK_TPDOC  := "AUT"
	CNK->CNK_DTEMIS := dDataBase
	CNK->CNK_DTVALI := CN9->CN9_DTFIM
	CNK->CNK_OBS    := "INCLUSAO AUTOMATICA           "
	CNK->( MsUnLock() )
	//confirma uso da numeração
	ConfirmSX8()

	//copia para o banco de conhecimento
	MsgRun( "Salvando documento no Banco Conhecimento", "Aguarde", {|| ;
		lRet := Ft340CpyObj( cDocumento ) })

	//copia o arquivo para o servidor
	IF lRet

		//pega o nome do arquivo e a extenção
		SplitPath( cDocumento,,, @cFile, @cExten )

		//grava Bancos de Conhecimentos
		RecLock("ACB",.T.)
		ACB->ACB_FILIAL := xFilial("ACB")
		ACB->ACB_CODOBJ := GetSX8Num( "ACB", "ACB_CODOBJ" )
		ACB->ACB_OBJETO := Left(Upper( cFile + cExten ), TamSX3("ACB_OBJETO")[1])
		ACB->ACB_DESCRI := "CONTRATO "+alltrim(CN9->CN9_NUMERO)+" - SALVO AUTOMATICAMENTE AO GERAR ARQUIVO WORD/PDF"
		ACB->( MsUnlock() )
		//confirma uso da numeração
		ConfirmSx8()

		//grava na Relação de Objetos x Entidades
		RecLock("AC9",.T.)
		AC9->AC9_FILIAL := xFilial("AC9")
		AC9->AC9_ENTIDA := "CNK"
		AC9->AC9_FILENT := xFilial("CNK")
		AC9->AC9_CODENT := CNK->CNK_CODIGO
		AC9->AC9_CODOBJ := ACB->ACB_CODOBJ
		AC9->( MsUnlock() )
	Else
		//se não conseguiu subir o arquivo
		DisarmTransaction()
	EndIF

	End Transaction

Return

Static Function TipoDocumento(cCodigo)

	//procura pelo tipo
	CN5->( dbSetOrder(1) )
	CN5->( dbSeek( xFilial("CN5") + cCodigo ) )

	//se não encontrar
	IF !CN5->( Found() )
		//cria o tipo
		RecLock("CN5",.T.)
		CN5->CN5_FILIAL := xFilial("CN5")
		CN5->CN5_CODIGO := cCodigo
		CN5->CN5_DESCRI := "INCLUSAO AUTOMATICA WORD"
		CN5->CN5_IMPGCT := "2"
		CN5->CN5_IMPFIN := "2"
		CN5->CN5_MODULO := "GCT"
		CN5->CN5_EMAIL  := "2"
		CN5->( MsUnLock() )
	EndIF

Return

Static Function GetOpcao(cCampo,cOpcao)

	Local aSaveArea := GetArea("SX3")
	Local aOpcoes := {}

	Local cRetorno := ""

	Local n1

	//busca o campo
	SX3->( dbSetOrder(2) )
	SX3->( dbSeek(cCampo) )

	//se existir
	IF SX3->( Found() )
		aOpcoes := RetSx3Box(X3CBox(),,,GetSx3Cache(cCampo,'X3_TAMANHO'))
		For n1 := 1 to len(aOpcoes)
			IF aOpcoes[n1][2] == cOpcao
				cRetorno := aOpcoes[n1][3]
			EndIF
		Next n1
	EndIF

	RestArea(aSaveArea)

Return cRetorno

Static Function DataExtenso(dData)

	Local cReturn := ""

	default dData := dDataBase

	cReturn += cValToChar(Day(dData))
	cReturn += " de "
	cReturn += MesExtenso(dData)
	cReturn += " de "
	cReturn += cValToChar(Year(dData))

Return cReturn


static function mensagem(cMensagem)

	Local oDlg
	Local oObs
	default cMensagem := ''
	DEFINE MSDIALOG oDlg TITLE 'Mensagem Observação resumo contrato' From 0,0 TO 240,500 PIXEL
	@ 10,10   SAY "Observação a ser impressa no resumo do contrato" SIZE 200, 8 OF oDlg PIXEL
	@ 20,10   GET oObs Var cMensagem MEMO SIZE 230,80 OF oDlg PIXEL
	DEFINE SBUTTON FROM 105, 214 When .T. TYPE 1 ACTION (oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED
return cMensagem
