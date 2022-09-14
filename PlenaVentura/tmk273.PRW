#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"
STATIC lChecaKit  := SuperGetMv("MV_TMKKIT") 
USER Function Tk273Calc(cCampo,nLinha,lTudo)

Local aAreaSC6	:= SC6->(GetArea())			// Salva area da tabela SC6
Local nValor   							    // Get atual do campo
Local nPProd    := aPosicoes[1][2]		   		// Posicao do Produto
Local nPQtd 	:= aPosicoes[4][2]		   		// Posicao da Quantidade
Local nPTes	    := aPosicoes[11][2]		   		// Posicao da TES
Local nPItem	:= aPosicoes[20][2]        		// Posicao do Item
Local nPPrcTab  := aPosicoes[15][2]				// Posicao do Preco de Tabela
Local nPCFO		:= aPosicoes[12][2]				// Posicao da CF
Local aListaKit	:= {}							// Itens do cadastro de KIT
Local nCont 	:= 0 							// Contador	de Itens do KIT
Local nAtual  	:= 0							// Linha atual depois da inclusao de KIT 
Local nColuna 	:= 1   							// Contador de colunas do aHeader
Local cItem 	:= ""							// Valor do item dos produtos (01,02,...)
Local lRet      := .F.							// Retorno da funcao
Local nPVrUnit  := aPosicoes[5][2]				// Posicao do Valor unitario
Local lReplace  := .F.							// Indica se o codigo do produto esta sendo alterado no acols
Local nPValDesc := aPosicoes[10][2]			// $ Desconto em Valor
Local cAltPed	:= SuperGetMV("MV_ALTPED")  // Parametro que permite a edi?o de pedido j?faturado
Local lRsDoFAt  := IIF(SuperGetMv("MV_RSDOFAT") == "S",.F.,.T.)  // Parametro que permite a edi?o de pedido eliminado por residuo
Local lTKVDACR	:= Iif(SuperGetMV("MV_TMKLOJ",,.F. )== "S" .And. GetNewPar("MV_TKVDACR",.F.),.T.,.F.)	//Se possuir integra?o com o SIGALOJA, faz o c?culo do acrescimo sobre o total menos o desconto.
Local npCodFCI	:= Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_FCICOD"})
Local nAcresRat := 0
Local cNaturez  := Tk273DpNat(M->UA_CLIENTE,M->UA_LOJA) //Obtem Natureza do Cliente/Prospect

Default cCampo  := ReadVar() 
Default nLinha 	:= N						// Linha a ser utilizada no calculo
Default lTudo 	:= .F.						// Define se todas as linhas serao recalculadas
Default nValor := GDFIELDGET("UB_VRUNIT",N)	

//????????????????????????????????????????
//?Faz uma c?ia do aCols quando ?utilizado a edi?o por linha na MsGetDados.	?
//????????????????????????????????????????
If !lTk271Auto .And. Type("oGetTlv") == "O" .And. Type("aColsEdit") == "A" .And.;
   oGetTlv:lEditLine .And. (cCampo == "UB_PRODUTO")
	aColsEdit := aClone(aCols) 
EndIf


If Empty(M->UA_CLIENTE)
	Help(" ",1,"SEM CLIENT")
	Return(lRet)
Endif	

SC6->(DbSetOrder(1))
If SC6->(DbSeek(xFilial("SC6") + M->UA_NUMSC5 + aCols[nLinha][nPItem] + aCols[nLinha][nPProd]))
	If cAltPed == "N" .AND. SC6->C6_QTDENT > 0
		Help("",1,"A410PEDFAT")
		RestArea(aAreaSC6)
		Return(.F.)
	ElseIf lRsDoFat .And. AllTrim(SC6->C6_BLQ) $ "RS"
		Help(" ",1,"A410ELIM")
		RestArea(aAreaSC6)
		Return(.F.)
	EndIf
	RestArea(aAreaSC6)
EndIf

//?????????????????
//?erifica se existe os produtos.?
//?????????????????
If cCampo <> "UB_PRODUTO"
	If Empty(aCols[nLinha][nPProd])
		Return(lRet)
	Endif
Else
	If	Upper(AllTrim(aCols[nLinha][nPProd])) <> Upper(AllTrim(nValor)) .AND.;
		Upper(AllTrim(aCols[nLinha][nPProd])) <> ""
		
		lReplace := .T.	
    EndIf
	//????????????????????????????????????????????
	//?ratamento efetuado para carregar o c?igo FCI ao informar o produto (Legisla?o FCI)?
	//????????????????????????????????????????????
	If npCodFCI > 0 .And. AllTrim(aHeader[npCodFCI][2]) == "UB_FCICOD"  //SIGAFIS
		aCols[n][npCodFCI] := Upper( XFciGetOrigem( M->UB_PRODUTO, M->UA_EMISSAO )[2] )	
	Endif
Endif  

Do Case
 	Case (cCampo == "UA_TABELA")
 	    nValor := aCols[nLinha][nPProd]
		lRet := TKP000A(nValor,nLinha,lTudo)

 	Case (cCampo == "UB_PRODUTO")
		lRet := TKP000A(nValor,nLinha,lTudo)
	
	Case (cCampo == "UB_QUANT")
		lRet := TKP000B(nValor,nLinha)
		
	Case (cCampo == "UB_VRUNIT")
		lRet := TkP000C(nValor,nLinha)
		
	Case (cCampo == "UB_DESC")
		lRet := TkP000D(nValor,nLinha)
		If !lRet
			Return(lRet)
		Endif	
		
	Case (cCampo == "UB_VALDESC")
		lRet := TkP000E(nValor,nLinha)
		If !lRet
			Return(lRet)
		Endif	
		
	Case (cCampo == "UB_ACRE")
		lRet := TkP000G(nValor,nLinha)
		If !lRet
			Return(lRet)
		Endif	
			
	Case (cCampo == "UB_VALACRE")
		lRet := TkP000H(nValor,nLinha)
		If !lRet
			Return(lRet)
		Endif	

Endcase

Eval(bRefresh)

MaFisAlt("IT_TES",aCols[nLinha][nPTes],nLinha)
If !Empty(cNaturez)
	MaFisAlt("NF_NATUREZA",cNaturez)
EndIf

If MaFisFound()		

	MaColsToFis(aHeader	, aCols	, nLinha	, "TK273"	,;
					.T.		)	

	Tk273RecCpg(,,nLinha,@nAcresRat)

	If cCampo == "UA_TABELA" .OR. (cCampo == "UB_PRODUTO" .AND. !lReplace)
		
		MaFisAlt("IT_QUANT",aCols[nLinha][nPQtd],nLinha)
		MaFisAlt("IT_PRCUNI",aCols[nLinha][nPVrUnit],nLinha)
		MaFisAlt("IT_VALMERC",A410Arred(aCols[nLinha][nPQtd]*(aCols[nLinha][nPVrUnit])+nAcresRat ,"UB_VLRITEM"),nLinha)
		MaFisAlt("IT_CF",aCols[nLinha][nPCFO],nLinha)

		If cPaisLoc == "BRA" .And. !Empty(aCols[nLinha][nPTes]) .And. ( M->UA_DESC4 > 0 .OR. M->UA_DESC1 > 0 .OR. M->UA_DESC2 > 0 .OR. M->UA_DESC3 > 0)
			SF4->(dbSetOrder(1))
			SF4->(dbseek(xFilial("SF4")+aCols[nLinha][nPTes]))
			If SF4->F4_IPI == "S" .And. SF4->F4_TPIPI == "B" 
				MaFisAlt("IT_BASEIPI",aCols[nLinha][nPPrcTab],nLinha)				
			EndIf			
		EndIf  

        If cCampo == "UB_PRODUTO" .And. aCols[nLinha][nPVrUnit]>0
			Tk273AtuNFs()
		Endif
	Else	   
		                                               	
		MaFisAlt("IT_QUANT",aCols[nLinha][nPQtd],nLinha)
		MaFisAlt("IT_PRCUNI",aCols[nLinha][nPVrUnit],nLinha)
		MaFisAlt("IT_VALMERC",A410Arred(aCols[nLinha][nPQtd]*(aCols[nLinha][nPVrUnit])+nAcresRat ,"UB_VLRITEM"),nLinha)
		MaFisAlt("IT_CF",aCols[nLinha][nPCFO],nLinha)

		If cPaisLoc == "BRA" .And. cCampo $ ("UB_DESC/UB_VALDESC") .And. !Empty(aCols[nLinha][nPTes])
			SF4->(dbSetOrder(1))
			SF4->(dbseek(xFilial("SF4")+aCols[nLinha][nPTes]))
			If SF4->F4_TPIPI == "B"
				MaFisAlt("IT_BASEIPI",MaFisRet(nLinha,"IT_BASEIPI") + aCols[nLinha][nPValDesc],nLinha)				
			EndIf
		EndIf
		If lTKVDACR .And. M->UA_OPER == "2"
			Tk273RodImposto("NF_DESCONTO",0)
			Tk273RodImposto("NF_DESPESA",0)
		Else
			Tk273RodImposto("NF_DESPESA",0)
			Tk273RodImposto("NF_FRETE",0) 
			Tk273RodImposto("NF_DESCONTO",0)
		EndIf

	Endif

	MaFisToCols(aHeader,aCols,nLinha,"TK273")

	If cCampo == "UB_PRODUTO" .Or. cCampo == "UB_QUANT" .And. aCols[nLinha][nPVrUnit]>0
		Tk273AtuNFs()
	EndIf
	
	Eval(bRefresh)
Endif

If M->UA_PDESCAB > 0
	Tk273CalcDesc()
Endif
	
DbSelectArea("SF4")
DbSetOrder(1)
If DbSeek(xFilial("SF4")+aCols[nLinha][nPTes])
	If SF4->F4_DUPLIC == "S"
	
		If MaTesSel(aCols[nLinha][nPTes])
			lTesTit := .F.				
		Else
			lTesTit := .T.	
		Endif
	Else
		lTesTit := .F.
	Endif
Endif

If (lChecaKit) .AND. (cCampo == "UB_PRODUTO")
	
	DbSelectArea("SUG")
	DbSetOrder(2)
	If DbSeek(xFilial("SUG") + nValor)
		If nValor == SUG->UG_PRODUTO
			DbSelectArea("SU1")
			DbSetOrder(1)
			If DbSeek(xFilial("SU1")+SUG->UG_CODACE)
				While (! Eof()) .AND. (SU1->U1_FILIAL == xFilial("SU1")) .AND. (SU1->U1_CODACE == SUG->UG_CODACE)
						
					If SU1->U1_KIT == "1"  //SIM
						
						AADD(aListaKit,{SU1->U1_ACESSOR,;			//Codigo do Acessorio
										SU1->U1_QTD})				//Quantidade
					Endif
					
					SU1->(DbSkip())
				End
			Endif
						
			cItem 	:= aCols[Len(aCols)][nPItem]
			nAtual  := 0
			nAtual	:= Len(aCols)
			
			For nCont := 1 to Len(aListaKit)
				AADD(aCols,Array(Len(aHeader)+1))
				nAtual ++
								
				For nColuna := 1 to Len( aHeader )
					
					If aHeader[nColuna][8] == "C"
						aCols[nAtual][nColuna] := Space(aHeader[nColuna][4])
						
					ElseIf aHeader[nColuna][8] == "D"
						aCols[nAtual][nColuna] := dDataBase
						
					ElseIf aHeader[nColuna][8] == "M"
						aCols[nAtual][nColuna] := ""
						
					ElseIf aHeader[nColuna][8] == "N"
						aCols[nAtual][nColuna] := 0
						
					Else
						aCols[nAtual][nColuna] := .F.
					Endif
					
				Next nColuna
				
				aCols[nAtual][Len(aHeader)+1] := .F.
				
				//???????????????????????????????????????????????????
				//?tualiza o aCols com o acessorio, atualizado o item o produto e a quantidade alem da funcao fiscal ?
				//???????????????????????????????????????????????????
				cItem 			 	  := Soma1(cItem,Len(cItem))
				aCols[nAtual][nPItem] := cItem
				
				M->UB_PRODUTO	 	  := aListaKit[nCont][1]
				aCols[nAtual][nPProd] := aListaKit[nCont][1]
				
				M->UB_QUANT  		 := aListaKit[nCont][2]
				aCols[nAtual][nPQtd] := aListaKit[nCont][2]
								
				//???????????????????????????????????????????????????
				//?tualizar a variavel n, pois as funcoes fiscais usam ela como referencia                           ?
				//???????????????????????????????????????????????????			
				n := nAtual
				
				TKP000A(M->UB_PRODUTO,nAtual,NIL)
				
				n := nAtual

				TKP000B(M->UB_QUANT,nAtual)				                                                                       
				
				//?????????????????????????????????????
				//?tualiza as informacoes do acols em relacao a MatXFis para o novo item. |
				//?????????????????????????????????????				
				MaFisToCols(aHeader,aCols,nAtual,"TK273",.F.)
				Tk273Calcula("UB_PRODUTO",nAtual)                        				
				
			Next nCont
			n := nAtual
			M->UB_PRODUTO := nValor // Inicializa a variavel de memoria com o item pai

            Eval(bGDRefresh)
		Endif
	Endif
Endif    

lRet:= Iif (cCampo == "M->UB_TES",.T.,lRet)                          

Return(lRet)


Static Function TkP000C(nValor,nLinha)

Local lRet 		:= .T.									// Retorno da funcao
Local lRecalc	:= .T.									// Indica se os valores devem ser recalculados
Local nPQtd		:= aPosicoes[4][2]						// Quantidade
Local nPVrUnit	:= aPosicoes[5][2]						// Valor unitario
Local nPVlrItem := aPosicoes[6][2]						// Valor do item 
Local nPDesc 	:= aPosicoes[9][2]						// % Desconto
Local nPAcre 	:= aPosicoes[13][2]						// % Acrescimo
Local nPValDesc := aPosicoes[10][2]						// $ Desconto em valor
Local nPValAcre := aPosicoes[14][2]						// $ Acrescimo em valor	
Local nPPrctab  := aPosicoes[15][2]						// Posicao do Preco de Tabela
Local nPProd  := aPosicoes[1][2]						// Posicao do Produto
Local cPrcFiscal:= TkPosto(M->UA_OPERADO,"U0_PRECOF") 	// Preco fiscal bruto 1=SIM / 2=NAO
Local lTk27300C := ExistBlock("TK27300C")				// P.E. utilizado na alteracao do preco unitario
Local nDesc		:= 0									// Desconto vindo da regra de desconto

If !Tk273VldRes()
	Return .F.
EndIf          

//?????????????????????????????????
//?erifica a existencia do ponto de entrada de validacao do preco?
//?????????????????????????????????
If lTk27300C
	lRet := ExecBlock( "TK27300C", .F., .F. )
	If ValType(lRet) <> "L"
		lRet := .F.
	Endif	
Endif	
lRecalc := (aCols[nLinha][nPVrUnit] <> nValor)

If lRet .AND. lRecalc
	aCols[nLinha][nPVrUnit] := nValor
	
	aCols[nLinha][nPDesc]   := 0
	aCols[nLinha][nPAcre]   := 0
	aCols[nLinha][nPValDesc]:= 0
	aCols[nLinha][nPValAcre]:= 0
	aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")
		
	If aCols[nLinha][nPPrctab] == 0
		aCols[nLinha][nPPrctab] := aCols[nLinha][nPVrUnit]
		
		//nDesc := TkRegraDesc(	1			, aValores[TOTAL]	, 0		, NIL	,;
		//						M->UA_CONDPG, nLinha			)

        //MaFisRet(, "NF_TOTAL")
        
		nDesc := IIf(nDesc < 0,0,nDesc)
		TkP000D(nDesc,nLinha)
	ElseIf INCLUI
		If SB1->B1_COD <> aCols[nLinha][nPProd] // Verifica se eh o mesmo produto
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+aCols[nLinha][nPProd])) // Existe pois passou pela validacao do campo
		EndIf
		nPrcProd := SB1->B1_PRV1
		If Empty(M->UA_TABELA) .And. nPrcProd == 0
			aCols[nLinha][nPPrctab] := aCols[nLinha][nPVrUnit]
		Else
			If !Empty(M->UA_TABELA)
				nPrcProd := 	MaTabPrVen(	M->UA_TABELA,;
													aCols[nLinha][nPProd],;
													aCols[nLinha][nPQtd],;
													M->UA_CLIENTE,;
													M->UA_LOJA,;
													M->UA_MOEDA,;
													NIL,;
													NIL,;
													NIL,;
													.T.,;
													lProspect)

			EndIf
			aCols[nLinha][nPPrctab] := IIf((nPrcProd == 0) .And. (aCols[nLinha][nPPrctab] > 0),aCols[nLinha][nPVrUnit],nPrcProd)
		EndIf
	EndIf
	
	MaFisAlt("IT_PRCUNI",aCols[nLinha][nPVrUnit],nLinha)
	MaFisAlt("IT_VALMERC",aCols[nLinha][nPVlrItem],nLinha)
	If cPrcFiscal == "1"  // Se for Preco fiscal bruto = 1 - Sim
		aValores[DESCONTO] := 0
		If !aCols[nLinha][Len(aHeader)+1]		// Se a linha for valida
			aValores[DESCONTO] += aCols[nLinha][nPValDesc]
		Endif	
	Endif
Endif

M->UB_VRUNIT := aCols[nLinha][nPVrUnit]

Return(lRet)

Static Function Tk273VldRes()

Local aAreaSC6	:= SC6->(GetArea())			// Salva area da tabela SC6
Local aAreaSUA	:= SUA->(GetArea())			// Salva area da tabela SUA
Local nPProd    := aPosicoes[1][2]	   		// Posicao do Produto
Local nPItem	:= aPosicoes[20][2]    		// Posicao do Item
Local lRsDoFAt  := IIF(SuperGetMv("MV_RSDOFAT") == "S",.F.,.T.)  // Parametro que permite a edi?o de pedido eliminado por residuo

If lRsDoFat
	DbSelectArea("SUA")
	DbSetOrder(1)
	DbSeek(xFilial("SUA") + M->UA_NUM)
	
	DbSelectArea("SC6")
	DbSetOrder(1)
	If DbSeek(xFilial("SC6") + SUA->UA_NUMSC5 + aCols[n][nPItem] + aCols[n][nPProd])
		If AllTrim(SC6->C6_BLQ) $ "RS"
			Help(" ",1,"A410ELIM")
			RestArea(aAreaSC6)
			RestArea(aAreaSUA)		
			Return .F.
		EndIf
	EndIf
EndIf

RestArea(aAreaSC6)
RestArea(aAreaSUA)
		
Return .T.



Static Function TkP000D(nValor,nLinha)

Local lRet		:=.F.										// Retorno da funcao
Local nPQtd		:= aPosicoes[4][2]							// Posicao da Quantidade
Local nPVrUnit	:= aPosicoes[5][2]							// Posicao do Valor unitario
Local nPVlrItem := aPosicoes[6][2]							// Posicao do Valor do item
Local nPDesc 	:= aPosicoes[9][2]							// Posicao do % Desconto
Local nPValDesc := aPosicoes[10][2]							// Posicao do $ Desconto em Valor
Local nPTes	    := aPosicoes[11][2]							// Posicao do Codigo do TES
Local nPAcre 	:= aPosicoes[13][2]							// Posicao do Acrescimo em %
Local nPValAcre := aPosicoes[14][2]							// Posicao do % Acrescimo	
Local nPPrctab  := aPosicoes[15][2]							// Posicao do Preco de Tabela
Local cDesconto := TkPosto(M->UA_OPERADO,"U0_DESCONT")		// Desconto  1=ITEM / 2=TOTAL / 3=AMBOS / 4=NAO
Local cPrcFiscal:= TkPosto(M->UA_OPERADO,"U0_PRECOF")		// Preco fiscal bruto 1=SIM / 2=NAO
Local cTesBonus := SuperGetMv("MV_BONUSTS") 				// Codigo da TES usado para as regras de bonificacao
Local cTes    	:= aCols[nLinha][nPTes]						// Conteudo do TES
Local lTemPrcTab:= If(aCols[nLinha][nPPrcTab]>0,.T.,.F.)	// Se tem pre? de tabela

//?????????????????????
//?erifica se o item do pedido de venda  ?
//?oi eliminado por res?uo. (MV_RSDOFAT)?
//?????????????????????
If !Tk273VldRes()
	Return .F.
EndIf  

//????????????????????????????????
//?e n? tiver pre? de tabela, ignora a tentativa de c?culo.?
//????????????????????????????????
If !lTemPrcTab
	Return(.T.)
EndIf

//?????????????????????????????????????????????
//?e a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos?
//?????????????????????????????????????????????
If ( cTes == cTesBonus )
	Return(lRet)
Endif	

//????????????????????????????????????????????????????
//?o pode dar desconto se o Posto de venda estiver configurado para Item ou Ambos						?
//????????????????????????????????????????????????????
If AllTrim(cDesconto) == "2" .OR. AllTrim(cDesconto) == "4"   // Desconto = Total ou Desconto = Nao
	If nValor > 0 
		If  !lTk271Auto 
			Help( " ", 1, "NAO_DESCON")
		Endif	
		aCols[nLinha][nPDesc] := 0
		Return(lRet)
	Endif
Endif

//?????????????????????????????????????
//? valor de deconto (%) nao pode ser maior ou igual a 100%  			  ?
//?????????????????????????????????????
If nValor >= 100
	Help( " ", 1, "DESCMAIOR2" )
	aCols[nLinha][nPDesc] := 0
	Return(lRet)
Endif

//?????????????????????????
//?arrego novamente o valor de desconto calculado?
//?????????????????????????
aCols[nLinha][nPDesc]	:= nValor

//????????????????
//?era os valores de acr?cimo.?
//????????????????
aCols[nLinha][nPValAcre]	:= 0
aCols[nLinha][nPAcre]		:= 0

//????????????????????????????
//?alcula os descontos, tanto do cabe?lho como do item.?
//????????????????????????????
//Tk273DesCLi(nLinha,1)	// Percentual

//????????????????????????????????????
//?e o posto de venda do operador estiver com preco fiscal bruto = SIM  ?
//? valor unitario do produto sera jogado no desconto total 		     ?
//????????????????????????????????????
If AllTrim(cPrcFiscal) != "2"  // SIM
	aCols[nLinha][nPVlrItem]	:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")
	aCols[nLinha][nPValDesc]	:= aCols[nLinha][nPVlrItem] - A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VALDESC")
	aCols[nLinha][nPValAcre]	:= 0
	aCols[nLinha][nPAcre]		:= 0
	
	//??????????????????????????????????????????
	//?ogo o desconto desse item no TOTAL pois o valor do unitario nao sera recalculado?
	//??????????????????????????????????????????
	If cPrcFiscal == "1"  // Se for PRECO FISCAL BRUTO igual a SIM
		aValores[DESCONTO]:= 0
		If !aCols[nLinha][Len(aHeader)+1]		// Se a linha for valida
			aValores[DESCONTO] += aCols[nLinha][nPValDesc]
		Endif	
		Eval(bRefresh)
	Endif
Endif

//??????????????????????????????
//? desconto nao pode ser maior que o valor de Tabela		 ?
//??????????????????????????????
If aCols[nLinha][nPValDesc] >= ( aCols[nLinha][nPPrcTab] * aCols[nLinha][nPQtd] ) .AND. nValor > 0
	Help(" ", 1, "DESCMAIOR2" )
	aCols[nLinha][nPDesc]   := 0
	aCols[nLinha][nPValDesc]:= 0
	Return(lRet)
Endif


lRet:=.T.

Return(lRet)
