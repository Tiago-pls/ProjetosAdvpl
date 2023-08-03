#INCLUDE 'PROTHEUS.CH'


/*/{Protheus.doc} MT120OK
PE confirmação pedido de compras
@type function
@version  
@author EMERSON
@since 11/08/2022
@return variant, return_description
/*/
User Function  MT120OK()
	Local lValido   := .T.
	Local nX        := 0 
	Local cNaturez  := SA2->A2_NATUREZ 
	Local cText	    := 'Deseja mudar a Natureza Financeira?'
	Local nTotal    := 0 
	    if !l120Auto
		nPosTot := aScan(aHeader, {|x| AllTrim(x[2])=="C7_TOTAL"})
		nPosDesc := aScan(aHeader, {|x| AllTrim(x[2])=="C7_VLDESC"})
		nPosObs := aScan(aHeader, {|x| AllTrim(x[2])=="C7_OBS"})
		cObs :=""
		For nCont := 1 to Len(aCols)
			if  !acols[ncont , len(acols[nCont])]
				nTotal += acols[nCont][nPosTot]
				nTotal -= acols[nCont][nPosDesc]
				cObs += Alltrim(acols[nCont][nPosObs])
			Endif
		Next nCont
        cObsSC7 := alltrim(u_PCodInfo(nTotal,cObs)) // janela de condição de pagamento de pedido de compras
		if cObsSC7 <> cObs
			// atualiza a observação do pedido
			for nCont := 1 to len (aCols)
				if  !acols[ncont , len(acols[nCont])]
					acols[ nCont ,nPosObs] := cObsSC7
					nCont := len(aCols)
				endif
			Next nCont
			
		endif
    Endif

	//Não é execauto?
	if !l120Auto .AND. SC7->(FieldPos( "C7_ZNATURE" )) > 0
		cNaturez := IIF(Empty(gdfieldget("C7_ZNATURE")),cNaturez,gdfieldget("C7_ZNATURE"))
		DEFINE MSDIALOG oDlgSB2 TITLE "Natureza Financeira"  OF oDlgSB2 PIXEL FROM 010,010 TO 200,265 Style DS_MODALFRAME 
		DEFINE FONT oBold   NAME "Arial" SIZE 0, -12 BOLD
		@ 014,010 SAY cText  SIZE 180,10 PIXEL OF oDlgSB2 FONT oBold 
		@ 044,005 SAY "Natureza: "                              SIZE 040,10 PIXEL OF oDlgSB2 FONT oBold 
		@ 040,043 MSGET oVar  VAR  cNaturez  F3 'SED' Picture "@!" SIZE 050,10 PIXEL OF oDlgSB2  Valid(!Empty(Alltrim(cNaturez)) .AND. Existcpo("SED",cNaturez))
		@ 075,025 BUTTON "&Cancelar" SIZE 30,14 PIXEL ACTION (oDlgSB2:End())
		@ 075,065 BUTTON "&Confirmar" SIZE 30,14 PIXEL ACTION (oDlgSB2:End())
		ACTIVATE MSDIALOG oDlgSB2  CENTERED	
		if !Empty(Alltrim(cNaturez)) .and. ExistCPO("SED", cNaturez)
			
			//Variavel de cabeçalho recebe natureza do fornecedor 
			//cCodNatu := cNaturez
			For nX :=1 To Len( aCols )     
				//Atualiza natureza
				Acols[nX,GDFIELDPOS("C7_ZNATURE")] := cNaturez
			Next nX
		Else
			MsgStop("Informe uma natureza financeira valida para alteração!")
			lValido := .F.
		EndIF
	Endif
Return lValido
