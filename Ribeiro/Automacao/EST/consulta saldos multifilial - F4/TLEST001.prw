#INCLUDE "PROTHEUS.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funçao    ³MaViewSB2  ³ Autor ³ Edson Maricate       ³ Data ³23.11.2000 ³±±
±±³ alteração: Joao Edenilson Lopes                     ³ Data ³06.07.2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria uma tela de consulta com os saldos atuais               ³±±
±±³alteração ³visualizar saldos atuais de todas as filiais                 ³±±
±±³este programa é chamado pelo ponto de entrada MTVIEWB2.prw              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MaViewSB2(ExpC1,ExpC2,ExpC3)							   	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Produto                                     ³±±
±±³          ³ExpC2: Filial de Consulta                                    ³±±
±±³          ³ExpC3: Local (almox.)de Consulta (OPC) DEFAULT = ""          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Materiais                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function TLEST001(cProduto,cFilCon,cAlmox)

Local aArea 	:= GetArea()
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSB2	:= SB2->(GetArea())
Local aAreaSM0	:= SM0->(GetArea())
Local _aViewB2	:= {}
Local aStruSB2  := {}
Local oCursor	:= LoadBitMap(GetResources(),"LBNO")
Local nQAClass :=0
Local nX        := 0
Local cFilialSB2:= xFilial("SB2")
Local cFilialSB1:= xFilial("SB1")
Local lViewSB2  := .T.
Local nAtIni    := 1
Local _nFilial := SM0-> M0_CODFIL

Private cNomeArmazem:= ""
Private nTotDisp	:= 0
Private nTotExecDisp:=0
Private nSaldo	:= 0
Private nQtPV		:= 0
Private nQemp		:= 0
Private nSalpedi	:= 0
Private nReserva	:= 0
Private nQempSA	:= 0
Private nSaldoSB2 :=0
Private nQtdTerc  :=0
Private nQtdNEmTerc:=0
Private nSldTerc :=0
Private nQEmpN :=0
Private nVirtual:= 0
Private oDlgProd

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a filial de pesquisa do saldo                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cFilCon)
	If !Empty(cFilialSB2)
		cFilialSB2 := cFilCon
	EndIf
	If !Empty(cFilialSB1)
		cFilialSB1 := cFilCon
	EndIf
	dbSelectArea("SM0")
	dbSetOrder(1)
	MsSeek(cEmpAnt+cFilCon)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o cadastro de produtos                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB1")
//dbSetOrder(1)
//If MsSeek(cFilialSB1+cProduto) .And. lViewSB2
//If dbSeek(xFilial("SB1")+SB1->B1_COD) .And.lViewSB2

nVolta1:= .t.
If TcSrvType() != "AS/400"
	cCursor  := "TLEST001"
	lQuery   := .T.
	aStruSB2 := SB2->(dbStruct())
	
	cQuery := ""
	cQuery += "SELECT * FROM "+RetSqlName("SB2")+" WHERE "
	//cQuery += "B2_FILIAL='"+cFilialSB2+"' AND "
	cQuery += "B2_COD='"+SB1->B1_COD+"' AND "
	//cQuery += "B2_STATUS <> '2' AND "
	cQuery += "D_E_L_E_T_ <> '*' "
	cQuery += "ORDER BY B2_LOCAL "
	
	cQuery := ChangeQuery(cQuery)
	
	SB2->(dbCommit())
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursor,.T.,.T.)
	
	//For nX := 1 To Len(aStruSB2)
		//If aStruSB2[nX][2]<>"C"
		//	TcSetField(cCursor,aStruSB2[nX][1],aStruSB2[nX][2],aStruSB2[nX][3],aStruSB2[nX][4])
		//EndIf
	//Next nX
	
	dbSelectArea(cCursor)
	While ( !Eof() )
		nSaldoSB2:=SaldoSB2(,,,,,cCursor)
		
		aAdd(_aViewB2,{TransForm((cCursor)->B2_FILIAL,PesqPict("SB2","B2_FILIAL")),;
		TransForm((cCursor)->B2_LOCAL,PesqPict("SB2","B2_LOCAL")),;
		TransForm(nSaldoSB2,PesqPict("SB2","B2_QATU")),;
		TransForm((cCursor)->B2_QATU,PesqPict("SB2","B2_QATU")),;
		TransForm((cCursor)->B2_QPEDVEN,PesqPict("SB2","B2_QPEDVEN")),;
		TransForm((cCursor)->B2_QEMP,PesqPict("SB2","B2_QEMP")),;
		TransForm((cCursor)->B2_SALPEDI,PesqPict("SB2","B2_SALPEDI")),;
		TransForm((cCursor)->B2_QEMPSA,PesqPict("SB2","B2_QEMPSA")),;
		TransForm((cCursor)->B2_RESERVA,PesqPict("SB2","B2_RESERVA")),;
		TransForm((cCursor)->B2_QTNP,PesqPict("SB2","B2_QTNP")),;
		TransForm((cCursor)->B2_QNPT,PesqPict("SB2","B2_QNPT")),;
		TransForm((cCursor)->B2_QTER,PesqPict("SB2","B2_QTER")),;
		TransForm((cCursor)->B2_QEMPN,PesqPict("SB2","B2_QEMPN")),;
		TransForm((cCursor)->B2_QACLASS,PesqPict("SB2","B2_QACLASS"))})
		
		If !Empty(cAlmox) .And. cAlmox == (cCursor)->B2_LOCAL
			nAtIni := Len(_aViewB2)
		EndIf
		
		If nVolta1
			cNomeArmazem:= "Armazém: "+(cCursor)->B2_LOCAL+" - "+Posicione("SX5",1,xFilial("SX5")+"AM"+(cCursor)->B2_LOCAL,"X5_DESCRI")
			nTotDisp	+= nSaldoSB2
			nSaldo		+= (cCursor)->B2_QATU
			nQtPV		+= (cCursor)->B2_QPEDVEN
			nQemp		+= (cCursor)->B2_QEMP
			nSalpedi	+= (cCursor)->B2_SALPEDI
			nReserva	+= (cCursor)->B2_RESERVA
			nQempSA		+= (cCursor)->B2_QEMPSA
			nQtdTerc	+= (cCursor)->B2_QTNP
			nQtdNEmTerc	+= (cCursor)->B2_QNPT
			nSldTerc	+= (cCursor)->B2_QTER
			nQEmpN		+= (cCursor)->B2_QEMPN
			nQAClass	+= (cCursor)->B2_QACLASS
			nVirtual    += ((cCursor)->B2_QATU+(cCursor)->B2_SALPEDI-((cCursor)->B2_QPEDVEN+(cCursor)->B2_RESERVA))
			nVolta1:= .f.
		Endif
		dbSelectArea(cCursor)
		dbSkip()
	EndDo
	If lQuery
		dbSelectArea(cCursor)
		dbSelectArea("SB2")
	EndIf
EndIf

If !Empty(_aViewB2)
	
	//Sigamat.emp
	dbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	SM0->(DbGoTop())
	
	cTmp := ""
	
	//Verifica se o código empresa é "01", e salvo-o em um arquivo Temporário
	While !SM0->( Eof() )
		
		If SM0->M0_CODIGO == cEmpAnt
			cTmp += allTrim("Filial"+"-"+SM0->M0_CODFIL +"/"+ SM0->M0_FILIAL) + Space(20)
			SM0->(DbSkip())
		EndIf
		
		If SM0->M0_CODIGO == cEmpAnt
			cTmp += allTrim("Filial"+"-"+SM0->M0_CODFIL +"/"+ SM0->M0_FILIAL) + char(10)
		Endif
		SM0->(DbSkip())
		
	Enddo
	
	//Monta o grid com as informações de saldo de estoque
	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
	DEFINE MSDIALOG oDlgProd FROM 000,000  TO 560,600 TITLE 'Saldos em Estoque' Of oMainWnd PIXEL //"Saldos em Estoque"
	//linhas divisórias
	@ 008,004 To 009,296 Label "" of oDlgProd PIXEL
	@ 045,004 To 046,296 Label "" of oDlgProd PIXEL
	@ 163,004 To 164,296 Label "" of oDlgProd PIXEL
	oListBox := TWBrowse():New( 60,2,297,89,,{'Filial','Local','Qtd disponivel','Sld.Atual','Pedido de Vendas','Estoque Liberado','Qtd. Prevista Entrada','Qtd.Empenhada S.A.','Qtd. Reservada',RetTitle("B2_QTNP"),RetTitle("B2_QNPT"),RetTitle("B2_QTER"),RetTitle("B2_QEMPN"),RetTitle("B2_QACLASS")},{17,17,55,55,55,55,55,55,55},oDlgProd,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	//seta o array
	oListBox:SetArray(_aViewB2)
	oListBox:bLine := { || _aViewB2[oListBox:nAT]}
	oListBox:nAt   := Max(1,nAtIni)
	// Evento de clique no cabeçalho da browse
	//oListBox:blClick := {|| alert('blClicked') }
	//oListBox:bHeaderClick := {|| alert('bHeaderClick') }
	oListBox:bLDblClick := {|| EST001Atu(oListBox:nAt),oDlgProd:refresh(),	oDlgProd:CtrlRefresh() }
	// Evento de duplo click na celula
	//oBrowse:bLDblClick   := {|| alert('bLDblClick') }
	
	//imprime codigos e nome das filiais
	cTmp
	_nLin := 15
	
	@ _nLin,010 SAY cTmp Of oDlgProd PIXEL SIZE 700,900 FONT oBold //" Nome Da Empresa e Filiais "
	
	_nLin := _nLin + 10
	
	//Monta tela embaixo do grid onde totaliza os saldos das filiais
	@ 050,010 SAY Alltrim(cProduto)+SB1->B1_DESC Of oDlgProd PIXEL SIZE 245,009 FONT oBold
	@ 154,010 SAY oget1 var cNomeArmazem Of oDlgProd PIXEL SIZE 150 ,9 FONT oBold  //"TOTAL "
	@ 001,010 SAY 'Filiais' Of oDlgProd PIXEL SIZE 30 ,9 FONT oBold  //"TOTAL "
	
	@ 170,007 SAY 'Quantidade disponivel' of oDlgProd PIXEL //"Quantidade Disponivel    "
	@ 169,075 MsGet oget2 var nTotDisp Picture PesqPict("SB2","B2_QATU") of oDlgProd PIXEL SIZE 070,009 When .F.
	
	@ 170,155 SAY 'quantidade Empenhada' of oDlgProd PIXEL //"Quantidade Empenhada "
	@ 169,223 MsGet oget3 var nQemp Picture PesqPict("SB2","B2_QEMP") of oDlgProd PIXEL SIZE 070,009 When .F.
	
	@ 185,007 SAY 'Saldo Atual' of oDlgProd PIXEL //"Saldo Atual   "
	@ 184,075 MsGet oget4 var nSaldo Picture PesqPict("SB2","B2_QATU") of oDlgProd PIXEL SIZE 070,009 When .F.
	
	@ 185,155 SAY 'Qtd. Entrada Prevista' of oDlgProd PIXEL //"Qtd. Entrada Prevista"
	@ 184,223 MsGet oget5 var nSalPedi Picture PesqPict("SB2","B2_SALPEDI") of oDlgProd PIXEL SIZE 070,009 When .F.
	
	@ 200,007 SAY 'Pedido de Vendas' of oDlgProd PIXEL //"Qtd. Pedido de Vendas  "
	@ 199,075 MsGet oget6 var nQtPv Picture PesqPict("SB2","B2_QPEDVEN") of oDlgProd PIXEL SIZE 070,009 When .F.
	
	@ 200,155 SAY 'Estoque Liberado' of oDlgProd PIXEL //"Qtd. Reservada  "
	@ 199,223 MsGet oget7 var nReserva Picture PesqPict("SB2","B2_RESERVA") of oDlgProd PIXEL SIZE 070,009 When .F.
	
	@ 215,007 SAY 'Qtd. Empenhada S.A.' of oDlgProd PIXEL //"Qtd. Empenhada S.A."
	@ 214,075 MsGet oget8 var nQEmpSA Picture PesqPict("SB2","B2_QEMPSA") of oDlgProd PIXEL SIZE 070,009 When .F.
	
	@ 215,155 SAY RetTitle("B2_QTNP") of oDlgProd PIXEL
	@ 214,223 MsGet oget9 var nQtdTerc Picture PesqPict("SB2","B2_QTNP") of oDlgProd PIXEL SIZE 070,009 When .F.
	
	@ 230,007 SAY RetTitle("B2_QNPT") of oDlgProd PIXEL
	@ 229,075 MsGet oget10 var nQtdNEmTerc Picture PesqPict("SB2","B2_QNPT") of oDlgProd PIXEL SIZE 070,009 When .F.
	
	@ 230,155 SAY RetTitle("B2_QTER") of oDlgProd PIXEL
	@ 229,223 MsGet oget11 var nSldTerc Picture PesqPict("SB2","B2_QTER") of oDlgProd PIXEL SIZE 070,009 When .F.
	
	@ 245,007 SAY RetTitle("B2_QEMPN") of oDlgProd PIXEL
	@ 244,075 MsGet oget12 var nQEmpN Picture PesqPict("SB2","B2_QEMPN") of oDlgProd PIXEL SIZE 070,009 When .F.
	
	@ 245,155 SAY RetTitle("B2_QACLASS") of oDlgProd PIXEL
	@ 244,223 MsGet oget13 var nQAClass Picture PesqPict("SB2","B2_QACLASS") of oDlgProd PIXEL SIZE 070,009 When .F.
	
	@ 260,007 SAY "Sld Virtual (SR+PC-PV)" of oDlgProd PIXEL
	@ 259,075 MsGet oget14 var nVirtual Picture PesqPict("SB2","B2_QEMPN") of oDlgProd PIXEL SIZE 070,009 When .F.
	
	@ 265,244  BUTTON 'Voltar' SIZE 045,010  FONT oDlgProd:oFont ACTION (oDlgProd:End())  OF oDlgProd PIXEL  //"Voltar"
	
	ACTIVATE MSDIALOG oDlgProd CENTERED
Else
	MSGALERT ('Atenção, não há registro de estoques para este produto','AVISO') //"Atencao"###"Nao registro de estoques para este produto."###"Voltar"
	//Aviso(STR0014,STR0062,{STR0016},2) //"Atencao"###"Nao registro de estoques para este produto."###"Voltar"
EndIf
//EndIf
dbSelectArea(cCursor)
dbCloseArea()
RestArea(aAreaSM0)
RestArea(aAreaSB2)
RestArea(aAreaSB1)
RestArea(aArea)
Return(.T.)

Static Function EST001Atu(nRec01)
	
			dbSelectArea(cCursor)
			nvolta:= 1
			(cCursor)->(dbGotop(nRec01))
			While (cCursor)->(!Eof()) .and. nvolta<nRec01
			nvolta++
			(cCursor)->(dbSkip())
			Enddo
			
			nSaldoSB2:=SaldoSB2(,,,,,cCursor)
			cNomeArmazem:= "Armazém: "+(cCursor)->B2_LOCAL+" - "+Posicione("SX5",1,xFilial("SX5")+"AM"+(cCursor)->B2_LOCAL,"X5_DESCRI")
			nTotDisp	:= nSaldoSB2
			nSaldo		:= (cCursor)->B2_QATU
			nQtPV		:= (cCursor)->B2_QPEDVEN
			nQemp		:= (cCursor)->B2_QEMP
			nSalpedi	:= (cCursor)->B2_SALPEDI
			nReserva	:= (cCursor)->B2_RESERVA
			nQempSA		:= (cCursor)->B2_QEMPSA
			nQtdTerc	:= (cCursor)->B2_QTNP
			nQtdNEmTerc	:= (cCursor)->B2_QNPT
			nSldTerc	:= (cCursor)->B2_QTER
			nQEmpN		:= (cCursor)->B2_QEMPN
			nQAClass	:= (cCursor)->B2_QACLASS
			nVirtual    := ((cCursor)->B2_QATU+(cCursor)->B2_SALPEDI-((cCursor)->B2_QPEDVEN+(cCursor)->B2_RESERVA))

oDlgProd:refresh()
oDlgProd:oWnd:refresh() 
oget1:refresh()
oget2:refresh()
oget3:refresh()
oget4:refresh()
oget5:refresh()
oget6:refresh()
oget7:refresh()
oget8:refresh()
oget9:refresh()
oget10:refresh()
oget11:refresh()
oget12:refresh()
oget13:refresh()
oget14:refresh()

Return
