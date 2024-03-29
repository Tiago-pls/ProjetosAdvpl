#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*__________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  ValPoten   - Autor - Tiago Santos      - Data -02.02.23   ---
--+----------+---------------------------------------------------------------
---Descri--o -  Relatório para geração dos valores vendidos e potencias    ---
--+-----------------------------------------------------------------------+--
--+-----------------------------------------------------------------------+--
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/

user function  AxZSA()
Local cAlias := "ZSA"
Private cCadastro := "Limite Integrador"
Private aRotina := {}

AADD(aRotina,{"Pesquisar" ,"AxPesqui",0, 1})
AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})
AADD(aRotina,{"Incluir" ,"U_RAxInclui",0,3})
AADD(aRotina,{"Alterar" ,"u_RAxAltera",0,4})
AADD(aRotina,{"Excluir" ,"u_RAxDeleta",0,5})

mBrowse(6,1,22,75,cAlias)
	
Return

user function  RAxInclui(cAlias,nReg,nOpc,aAcho,cFunc,aCpos,cTudoOk,lF3,cTransact,aButtons,;
						aParam,aAuto,lVirtual,lMaximized,cTela,lPanelFin,oFather,aDim,uArea,lFlat,lSubst)

Local aArea    := GetArea(cAlias)
Local aCRA     := { oemtoansi("Confirma"),oemtoansi("Redigita"),oemtoansi("Abandona") }//"Confirma" ### "Redigita" ### "Abandona"
Local aSvRot   := Nil
Local aPosEnch := {}
Local cMemo    := ""
Local nX       := 0
Local nOpcA    := 0
Local nLenSX8  := GetSX8Len()
Local bCampo   := {|nCPO| Field(nCPO) }
Local bOk      := Nil
Local bOk2     := {|| .T.}
Local oDlg
Local nTop
Local nLeft
Local nBottom
Local nRight
Local cAliasMemo
Local bEndDlg := {|lOk| lOk:=oDlg:End(), nOpcA:=1, lOk}
Local oEnc01
Local oSize


Private aTELA[0][0]
Private aGETS[0]

DEFAULT cTudoOk := ".T."
DEFAULT bOk     := &("{|| "+cTudoOk+"}")
DEFAULT lF3     := .F.
DEFAULT lVirtual:= .F.
DEFAULT lPanelFin := .F.
DEFAULT lFlat	  := .F.
DEFAULT lSubst	  := .F.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento de codeblock de validacao de confirmacao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aParam)
	bOk2 := aParam[2]
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == Nil
	nOpc := 3
	If Type("aRotina") == "A"
		aSvRot := aClone(aRotina)
	EndIf
	Private aRotina := { { " "," ",0,1 } ,{ " "," ",0,2 },{ " "," ",0,3 } }
EndIf

RegToMemory(cAlias, .T., lVirtual )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis para campos Memos Virtuais (GILSON)			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("aMemos")=="A"
	For nX :=1 To Len(aMemos)
		cMemo := aMemos[nX][2]
		If ExistIni(cMemo)
			&cMemo := InitPad(SX3->X3_RELACAO)
		Else
			&cMemo := ""
		EndIf
	Next nX
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcoes executadas antes da chamada da Enchoice      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cFunc != NIL
	&cFunc.()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento de codeblock de antes da interface                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aParam)
	Eval(aParam[1],nOpc)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets		 			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aAuto == Nil
	If !lPanelFin .AND. !lFlat

		// Verifica se eh substituicao de titulo e define emissao e vencimento conforme titulo de origem
		If lSubst
			M->E2_EMISSAO  := SE2->E2_EMISSAO
			M->E2_VENCTO   := SE2->E2_VENCTO
			M->E2_VENCREA  := SE2->E2_VENCREA
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula as dimensoes dos objetos                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSize := FwDefSize():New( .T. ) // Com enchoicebar

		oSize:lLateral     := .F.  // Calculo vertical

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria Enchoice                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dispara o calculo                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSize:Process()

		nTop    := oSize:aWindSize[1]
		nLeft   := oSize:aWindSize[2]
		nBottom := oSize:aWindSize[3]
		nRight  := oSize:aWindSize[4]

		If IsPDA()
			nTop := 0
			nLeft := 0
			nBottom := PDABOTTOM
			nRight  := PDARIGHT
		EndIf

		// Build com correção no tratamento dos controles pendentes na dialog ao executar o método End()
		bEndDlg := {|lOk| If(lOk:=oDlg:End(),nOpcA:=1,nOpcA:=3), lOk}

		DEFINE MSDIALOG oDlg TITLE cCadastro FROM nTop,nLeft TO nBottom,nRight PIXEL OF oMainWnd STYLE nOr(WS_VISIBLE,WS_POPUP)
		If lMaximized <> NIL
			oDlg:lMaximized := lMaximized
		EndIf

		If IsPDA()
			aPosEnch := {,,,}
			oEnc01:= MsMGet():New( cAlias, nReg, nOpc, aCRA,"CRA",oemtoansi("STR0005"),aAcho, aPosEnch , aCpos, , , ,cTudoOk,,lF3,lVirtual,.t.,,,,,,,,cTela) //"Quanto … inclus„o?"
			oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT
		Else
			aPosEnch := {oSize:GetDimension("ENCHOICE","LININI"),;
				 oSize:GetDimension("ENCHOICE","COLINI"),;
				 oSize:GetDimension("ENCHOICE","LINEND"),;
				 oSize:GetDimension("ENCHOICE","COLEND")}

			oEnc01:= MsMGet():New( cAlias, nReg, nOpc, aCRA,"CRA",oemtoansi("STR0005"),aAcho, aPosEnch , aCpos, , , ,cTudoOk,,lF3,lVirtual,,,,,,,,,cTela) //"Quanto … inclus„o?"
			oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT
		Endif

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela).And.Eval(bOk).And.Eval(bOk2,nOpc),Eval(bEndDlg),(nOpcA:=3,.f.))},{|| nOpcA := 3,oDlg:End()},,aButtons)
     

	EndIf

	If lF3  // Esta na conpad, desabilita o trigger por execblock
		SetEntryPoint(.f.)
	EndIf
Else
	If EnchAuto(cAlias,aAuto,{|| Obrigatorio(aGets,aTela).And.Eval(bOk).And.Eval(bOk2,nOpc)},nOpc,aCpos)
		nOpcA := 1
	EndIf
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao da enchoice                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcA == 1
	Begin Transaction
		RecLock(cAlias,.T.)
		For nX := 1 TO FCount()
			If "_FILIAL"$FieldName(nX)
				FieldPut(nX,xFilial(cAlias))
			Else
				FieldPut(nX,M->&(EVAL(bCampo,nX)))
			EndIf
		Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os campos Memos Virtuais         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("aMemos") == "A"
			For nX := 1 to Len(aMemos)
				cVar := aMemos[nX][2]
				//Incluído parametro com o nome da tabela de memos => para módulo APT
				cAliasMemo := If(len(aMemos[nX]) == 3,aMemos[nX][3],Nil)
				MSMM(,TamSx3(aMemos[nX][2])[1],,&cVar,1,,,cAlias,aMemos[nX][1],cAliasMemo)
			Next nX
		EndIf
		// Desbloqueio do registro inserido - COMMIT
		If cModulo == "FIN"
			(cAlias)->(MsUnLock())
		EndIf
		While ( GetSX8Len() > nLenSX8 )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Confirma a numeracao com a verificacao do numero gravado ativado  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ConfirmSx8()
		EndDo
		If cTransact != Nil
			If !("("$cTransact)
				cTransact+="()"
			EndIf
			&cTransact
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processamento de codeblock dentro da transacao                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aParam)
			Eval(aParam[3],nOpc)
		EndIf

	End Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento de codeblock fora da transacao                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    aDados:= {}

    Aadd(aDados,ZSA->ZSA_INTEGR)
    Aadd(aDados,ZSA->ZSA_LOJA)
    Aadd(aDados,'I') // Inclusão
    Aadd(aDados,ZSA->ZSA_LIMITE)
        // Grava Histórico Limite Integrador
    u_AtuLimCr(aDados) 

	If !Empty(aParam)
		Eval(aParam[4],nOpc)
	EndIf
Else
	While ( GetSX8Len() > nLenSX8 )
		RollBackSX8()
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade dos dados                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aSvRot != Nil
	aRotina := aClone(aSvRot)
EndIf
RestArea(aArea)
lRefresh := .T.

If lPanelFin
	FinVisual(cAlias,uArea,(cAlias)->(Recno()))
Endif

Return(nOpcA)



user FUNCTION RAxAltera(cAlias,nReg,nOpc,aAcho,aCpos,nColMens,cMensagem,cTudoOk,cTransact,cFunc,;
				aButtons,aParam,aAuto,lVirtual,lMaximized,cTela,lPanelFin,oFather,aDim,uArea,lFlat)

Local aArea    := GetArea(cAlias)
Local aPosEnch := {}
Local bCampo   := {|nCPO| Field(nCPO) }
Local bOk      := Nil
Local bOk2     := {|| .T.}
Local cCpoFil  := PrefixoCpo(cAlias)+"_FILIAL"
Local cMemo    := ""
Local nOpcA    := 0
Local nX       := 0
Local oDlg
Local nTop
Local nLeft
Local nBottom
Local nRight
Local cAliasMemo
Local bEndDlg := {|lOk| lOk:=oDlg:End(), nOpcA:=1, lOk}
Local oEnc01
Local oSize

Private aTELA[0][0]
Private aGETS[0]

DEFAULT lVirtual:= .F.
DEFAULT cTudoOk := ".T."
DEFAULT nReg    := (cAlias)->(RecNO())
DEFAULT bOk := &("{|| "+cTudoOk+"}")
DEFAULT lPanelFin := .F.
DEFAULT lFlat := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento de codeblock de validacao de confirmacao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aParam)
	bOk2 := aParam[2]
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VerIfica se esta' alterando um registro da mesma filial               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAlias)
If (cAlias)->(FieldGet(FieldPos(cCpoFil))) == xFilial(cAlias)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a entrada de dados do arquivo						     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SoftLock(cAlias)
		RegToMemory(cAlias,.F.,lVirtual)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa variaveis para campos Memos Virtuais		 			  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("aMemos")=="A"
			For nX:=1 to Len(aMemos)
				cMemo := aMemos[nX][2]
				If ExistIni(cMemo)
					&cMemo := InitPad(SX3->X3_RELACAO)
				Else
					&cMemo := ""
				EndIf
			Next nX
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa variaveis para campos Memos Virtuais		 			  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( ValType( cFunc ) == 'C' )
		    If ( !("(" $ cFunc) )
			   cFunc+= "()"
			EndIf
			&cFunc
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processamento de codeblock de antes da interface                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aParam)
			Eval(aParam[1],nOpc)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia para processamento dos Gets				   	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aAuto == Nil
		   If !lPanelFin .AND. !lFlat

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula as dimensoes dos objetos                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oSize := FwDefSize():New( .T. ) // Com enchoicebar

				oSize:lLateral     := .F.  // Calculo vertical

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cria Enchoice                                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Dispara o calculo                                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oSize:Process()

				nTop    := oSize:aWindSize[1]
				nLeft   := oSize:aWindSize[2]
				nBottom := oSize:aWindSize[3]
				nRight  := oSize:aWindSize[4]

				If IsPDA()
					nTop := 0
					nLeft := 0
					nBottom := PDABOTTOM
					nRight  := PDARIGHT
				EndIf
				// Build com correção no tratamento dos controles pendentes na dialog ao executar o método End()
				bEndDlg := {|lOk| If(lOk:=oDlg:End(),nOpcA:=1,nOpcA:=3), lOk}

				DEFINE MSDIALOG oDlg TITLE cCadastro FROM nTop,nLeft TO nBottom,nRight PIXEL OF oMainWnd STYLE nOr(WS_VISIBLE,WS_POPUP)

				If lMaximized <> NIL
					oDlg:lMaximized := lMaximized
				EndIf

				If IsPDA()
					oEnc01:= MsMGet():New( cAlias, nReg, nOpc,     ,"CRA",oemtoansi('STR0004'),aAcho,  aPosEnch,aCpos, ,nColMens,If(nColMens != Nil,cMensagem,NIL),cTudoOk,,lVirtual,.t.,,,,,,,,, cTela) //"Quanto …s altera‡”es?"
					oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT
				Else

					aPosEnch := {oSize:GetDimension("ENCHOICE","LININI"),;
						 oSize:GetDimension("ENCHOICE","COLINI"),;
						 oSize:GetDimension("ENCHOICE","LINEND"),;
						 oSize:GetDimension("ENCHOICE","COLEND")}

					If nColMens != Nil
						oEnc01:= MsMGet():New( cAlias, nReg, nOpc, ,"CRA",oemtoansi('STR0004'),aAcho,aPosEnch,aCpos,,nColMens,cMensagem,cTudoOk,,,lVirtual,,,,,,,,, cTela) //"Quanto …s altera‡”es?"
					Else
						oEnc01:= MsMGet():New( cAlias, nReg, nOpc, ,"CRA",oemtoansi('STR0004'),aAcho,aPosEnch,aCpos,,,,cTudoOk,,,lVirtual,,,,,,,,, cTela) //"Quanto …s altera‡”es?"
					EndIf
					oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT
				EndIf
				ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIf(Obrigatorio(aGets,aTela).And.Eval(bOk).And.Eval(bOk2,nOpc),Eval(bEndDlg),(nOpcA:=3,.F.))},{|| nOpcA := 3,oDlg:End()},,aButtons,nReg,cAlias)
			Else

				DEFINE MSDIALOG ___oDlg OF oFather:oWnd  FROM 0, 0 TO 0, 0 PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )

				aPosEnch := {,,,}
				oEnc01:= MsMGet():New( cAlias, nReg, nOpc,,"CRA",oemtoansi('STR0004'),aAcho,aPosEnch,aCpos,,,,cTudoOk,___oDlg  ,,lVirtual,.F.,,,,,,,,cTela) //"Quanto …s altera‡”es?"
				oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT

				bEndDlg := {|lOk| If(lOk:=___oDlg:End(),nOpcA:=1,nOpcA:=3), lOk}

				// posiciona dialogo sobre a celula
				___oDlg:nWidth := aDim[4]-aDim[2]
				ACTIVATE MSDIALOG ___oDlg  ON INIT (FaMyBar(___oDlg,{|| If(Obrigatorio(aGets,aTela).And.Eval(bOk).And.Eval(bOk2,nOpc),Eval(bEndDlg),(nOpcA:=3,.f.))},{|| nOpcA := 3,___oDlg:End()},aButtons), ___oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1]) )

			Endif
		Else
			If EnchAuto(cAlias,aAuto,{|| Obrigatorio(aGets,aTela) .And. Eval(bOk).And.Eval(bOk2,nOpc)},nOpc,aCpos)
				nOpcA := 1
			EndIf
		EndIf
		(cAlias)->(MsGoTo(nReg))
		If nOpcA == 1
			Begin Transaction
				RecLock(cAlias,.F.)
				For nX := 1 TO FCount()
					FieldPut(nX,M->&(EVAL(bCampo,nX)))
				Next nX
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava os campos Memos Virtuais					  				  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Type("aMemos") == "A"
					For nX := 1 to Len(aMemos)
						cVar := aMemos[nX][2]
						cVar1:= aMemos[nX][1]
						//Incluído parametro com o nome da tabela de memos => para módulo APT
						cAliasMemo := If(len(aMemos[nX]) == 3,aMemos[nX][3],Nil)
						MSMM(&cVar1,TamSx3(aMemos[nX][2])[1],,&cVar,1,,,cAlias,aMemos[nX][1],cAliasMemo)
					Next nX
				EndIf
				If cTransact != Nil
					If !("("$cTransact)
						cTransact+="()"
					EndIf
					&cTransact
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Processamento de codeblock dentro da transacao                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(aParam)
					Eval(aParam[3],nOpc)
				EndIf
			End Transaction
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processamento de codeblock fora da transacao                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    aDados:= {}

				Aadd(aDados,ZSA->ZSA_INTEGR)
				Aadd(aDados,ZSA->ZSA_LOJA)
				Aadd(aDados,'A') // Inclusão
				Aadd(aDados,ZSA->ZSA_LIMITE)
					// Grava Histórico Limite Integrador
				u_AtuLimCr(aDados) 
				
			If !Empty(aParam)
				Eval(aParam[4],nOpc)
			EndIf
		EndIf
	Else
		nOpcA := 3
	EndIf
Else
	Help(" ",1,"A000FI")
	nOpcA := 3
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade dos dados                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsUnLockAll()
RestArea(aArea)

If lPanelFin
	FinVisual(cAlias,uArea,(cAlias)->(Recno()))
Endif

Return(nOpcA)



user Function RAxDeleta(cAlias,nReg,nOpc,cTransact,aCpos,aButtons,aParam,aAuto,lMaximized,cTela,aAcho,lPanelFin,oFather,aDim, lFlat)

Local aArea    := GetArea()
Local aPosEnch := {}
Local nOpcA    := 0
Local nX       := 0
Local oDlg
Local nTop
Local nLeft
Local nBottom
Local nRight
Local cMsgError:= ""
Local oEnc01
Local lVirtual:=.F. // Qdo .F. carrega inicializador padrao nos campos virtuais
Local oSize

Private aTELA[0][0]
Private aGETS[0]

DEFAULT lPanelFin := .F.
DEFAULT lFlat		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAlias)
If SoftLock( cAlias )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento de codeblock de antes da interface                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aParam)
		Eval(aParam[1],nOpc)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controle de Interface                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case ( Type("__cInternet") # "C" .Or. __cInternet # 'AUTOMATICO' ) .And. aAuto == Nil

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula as dimensoes dos objetos                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oSize := FwDefSize():New( .T. ) // Com enchoicebar

			oSize:lLateral     := .F.  // Calculo vertical

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria Enchoice                                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Dispara o calculo                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oSize:Process()

			nTop    := oSize:aWindSize[1]
			nLeft   := oSize:aWindSize[2]
			nBottom := oSize:aWindSize[3]
			nRight  := oSize:aWindSize[4]

			If IsPDA()
				nTop := 0
				nLeft := 0
				nBottom := PDABOTTOM
				nRight  := PDARIGHT
			EndIf

         If !lPanelFin .AND. !lFlat
				DEFINE MSDIALOG oDlg TITLE cCadastro FROM nTop,nLeft TO nBottom,nRight PIXEL OF oMainWnd STYLE nOr(WS_VISIBLE,WS_POPUP)

				If lMaximized <> NIL
					oDlg:lMaximized := lMaximized
				EndIf
				If IsPDA()
					aPosEnch := {,,,}  // ocupa todo o  espaço da janela
					oEnc01:= MsMGet():New( cAlias, nReg, nOpc,,,,aCpos,aPosEnch,,,,,,,,.t.,,,,,,,,,cTela )
					oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT
				Else

					aPosEnch := {oSize:GetDimension("ENCHOICE","LININI"),;
						 oSize:GetDimension("ENCHOICE","COLINI"),;
						 oSize:GetDimension("ENCHOICE","LINEND"),;
						 oSize:GetDimension("ENCHOICE","COLEND")}

					oEnc01:= MsMGet():New( cAlias, nReg, nOpc,,,,aCpos,aPosEnch,,,,,,,,,,,,,,,,,cTela)
					oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT
				EndIf
				ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()},,aButtons)
		   Else

		   	DEFINE MSDIALOG ___oDlg OF oFather:oWnd FROM 0, 0 TO 0, 0 PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )

				aPosEnch := {,,,}
				oEnc01:= MsMGet():New( cAlias, nReg, nOpc,,,,aAcho,aPosEnch,,,,,,___oDlg,,lVirtual,,,,,,,,,cTela)
				oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT

				// posiciona dialogo sobre a celula
				___oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])

				ACTIVATE MSDIALOG ___oDlg  ON INIT (FaMyBar(___oDlg,{|| If(Obrigatorio(aGets,aTela).And.Eval(bOk).And.Eval(bOk2,nOpc),Eval(bEndDlg),(nOpcA:=3,.f.))},{|| nOpcA := 3,___oDlg:End()},aButtons), ___oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1]) )

				If Type("FinWindow") <> "U"
					FinVisual(cAlias,FinWindow,(cAlias)->(Recno()))
				EndIf
		   Endif

		Case aAuto <> Nil
			RegToMemory(cAlias,.F.,.F.)
			If EnchAuto(cAlias,aAuto,{|| Obrigatorio(aGets,aTela)},nOpc,aCpos)
				nOpcA := 2
			EndIf
		OtherWise
			nOpcA := 2
	EndCase
	If nOpcA == 2
		dbSelectArea(cAlias)
		If Type("cDelFunc") != "U" .and. cDelFunc != Nil
			If !&(cDelFunc)
				nOpcA := 0
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento de codeblock de validacao de confirmacao            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcA == 2 .And. !Empty(aParam)
		If !Eval(aParam[2],nOpc)
			nOpcA := 0
		EndIf
	EndIf
	If nOpcA == 2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao da tabela                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Begin Transaction
			DbSelectArea(cAlias)
			If cTransact != Nil .And. ValType(cTransact) == "C"
				If !("("$cTransact)
					cTransact+="()"
				EndIf
				&cTransact
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processamento de codeblock dentro da transacao                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aParam)
				Eval(aParam[3],nOpc)
			EndIf

			If Type("aMemos")=="A"
				For nX := 1 To Len(aMemos)
//Incluído parametro com o nome da tabela de memos => para módulo APT
					cAliasMemo := If(len(aMemos[nX]) == 3,aMemos[nX][3],Nil)
					MSMM(&(aMemos[nX][1]),,,,2,,,,,cAliasMemo)
				Next nX
			EndIf

			RecLock(cAlias,.F.,.T.)
			IF !FKDelete(@cMsgError)
			   RollBackDelTran(cMsgError)
			EndIf
			MsUnLock()

		End Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processamento de codeblock fora da transacao                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	    aDados:= {}

		Aadd(aDados,ZSA->ZSA_INTEGR)
		Aadd(aDados,ZSA->ZSA_LOJA)
		Aadd(aDados,'E') // Inclusão
		Aadd(aDados,ZSA->ZSA_LIMITE)
					// Grava Histórico Limite Integrador
		u_AtuLimCr(aDados) 


		If !Empty(aParam)
			Eval(aParam[4],nOpc)
		EndIf
	EndIf
EndIf
MsUnLockAll()
RestArea(aArea)
Return(nOpcA)



/*
Validação do integrador
*/user function ValInteg
Local lRet := .T.
Local aZSA := ZSA->( GetArea())

ZSA->( dbgoTop())
if ZSA->( DbSeek( xFilial("ZSA") + M->ZSA_INTEGR + M->ZSA_LOJA))
    MsgAlert("Integrador já cadastrado", "Atenção")
    lRet := .F.
Endif

RestArea(aZSA)
return lRet


