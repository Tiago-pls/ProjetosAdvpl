#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#Include "TBICONN.ch"
#include "Fileio.ch"
/*
nEntSai := 1=Entrada|2 = saida
cTpOper,
cClieFor:= Cliente ou Fornecedor para busca SA1 ou SA2
cLoja := Loja Cliente ou Fornecedor para busca SA1 ou SA2para busca SA1 ou SA2
cTipoCF:= C = Cliente | F Fornecedor
cProduto := Produto
cCampo := campo para preenchimento
cTipoCli,
cEstOrig,
cOrigem
*/

//MaTesInt(2,,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),M->C6_PRODUTO,"C6_TES")          
user Function PMaTesInt(nEntSai,cTpOper,cClieFor,cLoja,cTipoCF,cProduto,cCampo,cTipoCli,cEstOrig,cOrigem)
Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSA2	:= SA2->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSX3	:= SX3->(GetArea())
Local aTes		:= {}
Local aDadosCfo	:= {}
Local cTesRet	:= "   "
Local cGrupo	:= ""
Local cGruProd	:= ""
Local cQuery	:= ""
Local cQuery1	:= ""
Local cProg		:= "MT100"
Local cNCM		:= ""
Local cEstado	:= ""
Local cAliasSFM	:= "SFM"
Local cTabela	:= ""
Local lQuery	:= .F.
Local nPosCpo	:= 0
Local nPosCfo	:= 0
Local nFM_POSIPI:= SFM->(FieldPos("FM_POSIPI"))
Local nFM_EST	:= SFM->(FieldPos("FM_EST"))
Local nFM_MSBLQL:= SFM->(FieldPos("FM_MSBLQL"))
Local nFM_TIPOMO:= SFM->(FieldPos("FM_TIPOMOV"))
Local cAlias	:= ""	//Tabela a ser utiliza para informacoes do produto
Local c_GRTRIB	:= ""	//SBI->BI_GRTRIB	/	SB1->B1_GRTRIB
Local c_POSIPI	:= ""	//SBI->BI_POSIPI	/	SB1->B1_POSIPI
Local c_TS		:= ""
Local c_TE		:= ""
Local cSb1Sbz	:= SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local lArqProp	:= SuperGetMV("MV_ARQPROP",.F.,.F.)
Local bCond		:= {||.T.}
Local bCondAux	:= {||.T.}
Local lAddTes	:= .F.
Local bSort		:= {||}
Local bAddTes	:= {||.T.}
Local bAtTes	:= {||.T.}
Local bIFWhile	:= {||.T.}
Local aRet		:= {}
Local lRet		:= .T.
Local cTesSaiB1	:= ""
Local cTesEntB1	:= ""
Local lGrade	:= MaGrade()
Local nFM_GRPTI	:= SFM->(ColumnPos("FM_GRPTI"))
Local nFM_TPCLI	:= IIF(cPaisLoc == "BRA",SFM->(ColumnPos("FM_TIPOCLI")),0)
Local nB1_GRPTI	:= IIF(cPaisLoc == "BRA",SB1->(ColumnPos("B1_GRPTI")),0)
Local nFM_GRPCST:= SFM->(ColumnPos("FM_GRPCST"))
Local nB1_GRPCST:= IIF(cPaisLoc == "BRA",SB1->(ColumnPos("B1_GRPCST")),0)
Local cGrpcst	:= ""
Local c_GRPCST 	:= "" 
Local cGrupoTI	:= ""
Local cTpCliFor	:= ""
Local c_GRPTI	:= ""
Local cGrpTi	:= ""
Local cTipFrete := Iif(Type("M->C5_TPFRETE")<>"U",M->C5_TPFRETE,"")
Local lTipPed	:= Type("M->C5_TIPO") <> "U"
Local cMVA089FAC := GetNewPar("MV_A089FAC","")
Local aCndTesInt	:= {} //Array com informações da condição do Tes inTeligente.
Local nQtdeEnq	:= 0
Local cPrOrdClie	:= "{1,2,3,4,5,6,7,8,9,10,11,12}" 
Local cPrOrdForn	:= "{1,2,3,4,5,6,7,8,9,10}" 
Local cOrdClie	:= GetNewPar("MV_OTICLI",cPrOrdClie) //Ordem dos campos da SFM Cliente
Local cOrdForn	:= GetNewPar("MV_OTIFOR",cPrOrdForn) //Ordem dos campos da SFM Fornecedor
Local aOrdSFM	:= {}
Local aOrdForn	:= {}
Local nCont		:= 0
Local cLogTes	:= ""
Local nQtdEmp	:= 0
Local nPosQtdEnq	:= 0
Local lFmId			:= SFM->(FieldPos("FM_ID")) > 0
Local cIdFM		:= '' 
Local cRecno	:= ''
Local nFM_ORIGEM:= SFM->(FieldPos("FM_ORIGEM"))

DEFAULT cTpOper  := &(ReadVar())
DEFAULT cClieFor := ""
DEFAULT cProduto := ""
DEFAULT nEntSai  := 0
DEFAULT cTipoCF  := "C"
DEFAULT cCampo   := ""
DEFAULT cTipoCli := Iif(Type("M->C5_TIPOCLI")<>"U",M->C5_TIPOCLI,"")
DEFAULT cEstOrig := ""
DEFAULT cOrigem  := "" 	

//---------------------------------------------------
//Para nova regra irá buscar ordem dos campos da SFM.
//---------------------------------------------------
If cTipoCF	== 'C'
	If len(cOrdClie) >= 3 .AND. substr(cOrdClie,1,1) == '{' .AND. substr(cOrdClie,Len(cOrdClie),1) == '}'
		aOrdSFM	:= &(cOrdClie)
	EndIF
	
ElseIf len(cOrdForn) >= 3 .AND. substr(cOrdForn,1,1) == '{' .AND. substr(cOrdForn,Len(cOrdForn),1) == '}'
	aOrdSFM	:= &(cOrdForn)	
EndIF

If !Empty(cCampo) .AND. ValType(aHeader) == "A"
	nPosCpo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim(cCampo)})
	If nPosCpo > 0
		cTabela := GetSx3Cache(AllTrim(aHeader[nPosCpo,2]),"X3_ARQUIVO")
		RestArea(aAreaSX3)
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o grupo de tributacao do cliente/fornecedor         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea(IIf(cTipoCF == "C","SA1","SA2"))
dbSetOrder(1)
MsSeek(xFilial()+cClieFor+cLoja)
If cTipoCF == "C"
	cGrupo  := SA1->A1_GRPTRIB
	cEstado := SA1->A1_EST
	If Empty(cTipoCli)
		cTipoCli := SA1->A1_TIPO
	EndIf	
Else
	cGrupo  := SA2->A2_GRPTRIB
	cEstado := SA2->A2_EST
EndIf
//Verifica se cEstOrig foi carregado na chamada da função. Se sim substitui o valor que há em cEstado pelo valor de cEstOrig
If !Empty(cEstOrig) .and. cEstado <> cEstOrig
	cEstado := cEstOrig
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o codigo do produto informado eh de grade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGrade
	MatGrdPrrf(@cProduto)
EndIf

If nModulo == 23 .AND. !(FindFunction("STFIsPOS") .AND. STFIsPOS()) // Se não for Totvs PDV 
	dbSelectArea("SBI")
	dbSetOrder(1)
	If dbSeek(xFilial("SBI") + cProduto)
		cGruProd := SBI->BI_GRTRIB
			cNCM := SBI->BI_POSIPI
	Endif
Else
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1") + cProduto)
		cAlias   := "SB1"
		c_GRTRIB := "SB1->B1_GRTRIB"
		c_POSIPI := "SB1->B1_POSIPI"
		c_TS     := "SB1->B1_TS"
		c_TE     := "SB1->B1_TE"
		If nB1_GRPTI > 0
			c_GRPTI := "SB1->B1_GRPTI"
		EndIf
		If nB1_GRPCST > 0
			c_GRPCST := "SB1->B1_GRPCST"
		EndIf
		
		If cSb1Sbz == "SBZ"
			// Se existir registro no SBZ (Indicadores de Produtos) busca as informacoes desta tabela 
			c_GRTRIB  := "SBZ->BZ_GRTRIB"
			dbSelectArea("SBZ")
			SBZ->(dbSetOrder(1)) //BZ_FILIAL+BZ_PRODUTO
			If DbSeek(xFilial("SBZ") + cProduto) .And. lArqProp .And.!Empty(SBZ->BZ_GRTRIB)//O parametro eh true e o campo esta preenchido?
				// sim
				cGruProd := &(c_GRTRIB)
			ElseIf !lArqProp  // O parametro eh false busca o conteudo vazio da tabela SBZ
				cGruProd := &(c_GRTRIB)
			Else // Neste caso o parametro eh true e busca as informacoes na Tabela SB1
				c_GRTRIB := "SB1->B1_GRTRIB"
				cGruProd := &(c_GRTRIB)
			EndIf
		Else // neste caso busca as informacoes na tabela SB1 apenas
			cGruProd := &(c_GRTRIB)
			cTesSaiB1:= &(c_TS)
			cTesEntB1:= &(c_TE)
			If nB1_GRPTI > 0
				cGrpTI := &(c_GRPTI)
			EndIf
			If nB1_GRPCST > 0
				cGrpcst := &(c_GRPCST)
			EndIf
		EndIf
		// Como não existe o campo NCM na SBZ, não sendo o módulo 23, será verificado na SB1
		If !Empty(c_POSIPI)
			cNCM := &(c_POSIPI)
		Endif
		// Como não existe o campo GRUPO TI na SBZ, não sendo o módulo 23, será verificado na SB1
		If !Empty(c_GRPTI)
			cGrpTI := &(c_GRPTI)
		Endif

	EndIf
EndIf

If cTipoCF == "C" 	
	#IFDEF TOP
		bAddTes		:=	{||aAdd(aTes, {(cAliasSFM)->FM_PRODUTO,;
					(cAliasSFM)->FM_GRPROD,;
					IIf(nFM_POSIPI>0,(cAliasSFM)->FM_POSIPI,""),;
					(cAliasSFM)->FM_CLIENTE,;
					(cAliasSFM)->FM_LOJACLI,;
					(cAliasSFM)->FM_GRTRIB,;
					IIf(nFM_EST>0,(cAliasSFM)->FM_EST,""),;
					(cAliasSFM)->FM_TE,;
					(cAliasSFM)->FM_TS,;
					Iif(lGrade,(cAliasSFM)->FM_REFGRD,""),;
					Iif(nFM_GRPTI > 0, (cAliasSFM)->FM_GRPTI, ""),;
					Iif(nFM_TPCLI > 0, (cAliasSFM)->FM_TIPOCLI, ""),;
					Iif(nFM_GRPCST > 0, (cAliasSFM)->FM_GRPCST, ""),;
					nQtdeEnq,;
					Iif(nFM_TIPOMO > 0, (cAliasSFM)->FM_TIPOMOV, ""),;
					Iif(lFmId,(cAliasSFM)->FM_ID ,''),;
					(cAliasSFM)->R_E_C_N_O_,;
					Iif(nFM_ORIGEM > 0, (cAliasSFM)->FM_ORIGEM, "")})}
	#ELSE
		bAddTes		:=	{||aAdd(aTes, {(cAliasSFM)->FM_PRODUTO,;
						(cAliasSFM)->FM_GRPROD,;
						IIf(nFM_POSIPI>0,(cAliasSFM)->FM_POSIPI,""),;
						(cAliasSFM)->FM_CLIENTE,;
						(cAliasSFM)->FM_LOJACLI,;
						(cAliasSFM)->FM_GRTRIB,;
						IIf(nFM_EST>0,(cAliasSFM)->FM_EST,""),;
						(cAliasSFM)->FM_TE,;
						(cAliasSFM)->FM_TS,;
						Iif(lGrade,(cAliasSFM)->FM_REFGRD,""),;
						Iif(nFM_GRPTI > 0, (cAliasSFM)->FM_GRPTI, ""),;
						Iif(nFM_TPCLI > 0, (cAliasSFM)->FM_TIPOCLI, ""),;
						Iif(nFM_GRPCST > 0, (cAliasSFM)->FM_GRPCST, ""),;
						nQtdeEnq,;
						Iif(nFM_TIPOMO > 0, (cAliasSFM)->FM_TIPOMOV, ""),;
						Iif(lFmId,(cAliasSFM)->FM_ID ,''),;
						(cAliasSFM)->(Recno()),;
						Iif(nFM_ORIGEM > 0, (cAliasSFM)->FM_ORIGEM, "") })}	
	#ENDIF
					
					

		bSort		:=	{|x,y| x[14] > y[14]}
Else
	#IFDEF TOP
		bAddTes		:=	{|| aAdd(aTes,{(cAliasSFM)->FM_PRODUTO,;
					(cAliasSFM)->FM_GRPROD,;
					IIf(nFM_POSIPI>0,(cAliasSFM)->FM_POSIPI,""),;
					(cAliasSFM)->FM_FORNECE,;
					(cAliasSFM)->FM_LOJAFOR,;
					(cAliasSFM)->FM_GRTRIB,;
					IIf(nFM_EST>0,(cAliasSFM)->FM_EST,""),;
					(cAliasSFM)->FM_TE,;
					(cAliasSFM)->FM_TS,;
					Iif(lGrade,(cAliasSFM)->FM_REFGRD,""),;
					Iif(nFM_GRPTI > 0, (cAliasSFM)->FM_GRPTI, ""),;
					Iif(nFM_GRPCST > 0, (cAliasSFM)->FM_GRPCST, ""),;
					nQtdeEnq,;
					Iif(lFmId,(cAliasSFM)->FM_ID ,''),;
					(cAliasSFM)->R_E_C_N_O_,;
					Iif(nFM_ORIGEM > 0, (cAliasSFM)->FM_ORIGEM, "")})}									
	#ELSE
		bAddTes		:=	{|| aAdd(aTes,{(cAliasSFM)->FM_PRODUTO,;
						(cAliasSFM)->FM_GRPROD,;
						IIf(nFM_POSIPI>0,(cAliasSFM)->FM_POSIPI,""),;
						(cAliasSFM)->FM_FORNECE,;
						(cAliasSFM)->FM_LOJAFOR,;
						(cAliasSFM)->FM_GRTRIB,;
						IIf(nFM_EST>0,(cAliasSFM)->FM_EST,""),;
						(cAliasSFM)->FM_TE,;
						(cAliasSFM)->FM_TS,;
						Iif(lGrade,(cAliasSFM)->FM_REFGRD,""),;
						Iif(nFM_GRPTI > 0, (cAliasSFM)->FM_GRPTI, ""),;
						Iif(nFM_GRPCST > 0, (cAliasSFM)->FM_GRPCST, ""),;
						nQtdeEnq,;
						Iif(lFmId,(cAliasSFM)->FM_ID ,''),;
						(cAliasSFM)->(Recno()),;
						Iif(nFM_ORIGEM > 0, (cAliasSFM)->FM_ORIGEM, "")})}
	#ENDIF
	bSort		:=	{|x,y| x[13] > y[13]}
EndIf

bIRWhile		:=	{||((cAliasSFM)->(!Empty(FM_GRTRIB) .And. !Empty(FM_GRPROD)) .And. AllTrim(cGrupo)+AllTrim(cGruProd)==(cAliasSFM)->(AllTrim(FM_GRTRIB)+AllTrim(FM_GRPROD))) .Or.;
					(cAliasSFM)->(Empty(FM_GRTRIB) .Or. Empty(FM_GRPROD))}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada que permite alterar a regra de selecao do TES,³
//³alterar a ordem do array com os elementos encontrados pela     ³
//³rotina e alterar o conteudo do array com os campos do SFM.     ³
//³Todos os retornos tem que ser em forma de CodBlock.            ³
//³Caso seja incluido campo novo para ser tratado na regra, se faz³
//³necessario incluir no X2_UNICO do SFM.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT089CD")
	aRet		:= Execblock("MT089CD",.T.,.T.,{bCond,bSort,bIRWhile,bAddTes,cTabela,cTpOper})
	bCondAux	:= aRet[1]
	bSort		:= aRet[2]
	bIFWhile	:= aRet[3]
	bAtTes		:= aRet[4]
	If Len(aRet) > 4
		cTpOper	:= aRet[5]
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa por todas as regras validas para este caso          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para tratar seleção da tes inteligente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (ExistBlock("MT089TES"))
		cRet := ExecBlock("MT089TES",.F.,.F.,{nEntSai,cTpOper,cClieFor,cLoja,cProduto})
		If Valtype( cRet ) == "C"
			cQuery := cRet
			lQuery := .T.
			lRet := .F.
		EndIf
	EndIf
	If(lRet)
		lQuery := .T.
		cAliasSFM := GetNextAlias()
		cQuery += "SELECT  
		If !Empty(cProduto)
			cQuery1 += Iif(EMPTY(cQuery1)," ( ","")+" (CASE "
			cQuery1 += "		WHEN SFM.FM_PRODUTO = '"+cProduto+"'
			cQuery1 += "		THEN 1
			cQuery1 += "		ELSE 0
			cQuery1 += "	END)
		EndIf
		If !Empty(cGruProd)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE
			cQuery1 += "	  WHEN SFM.FM_GRPROD = '"+cGruProd+"'
			cQuery1 += "	  THEN 1
			cQuery1 += "	  ELSE 0
			cQuery1 += "  END)
		EndIf
		If !Empty(cGrupo)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE
			cQuery1 += "  WHEN SFM.FM_GRTRIB = '"+cGrupo+"'
			cQuery1 += "  THEN 1
			cQuery1 += "  ELSE 0
			cQuery1 += " END)
		EndIf
		If cTipoCF == "C" .And. !Empty(cClieFor) .And. !Empty(cLoja)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE
			cQuery1 += "	WHEN SFM.FM_CLIENTE = '"+cClieFor+"' AND SFM.FM_LOJACLI = '"+cLoja+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf
		If cTipoCF == "F" .And. !Empty(cClieFor) .And. !Empty(cLoja)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE
			cQuery1 += "	WHEN SFM.FM_FORNECE = '"+cClieFor+"' AND SFM.FM_LOJAFOR = '"+cLoja+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf
		If !Empty(cEstado)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_EST = '"+cEstado+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf
		If lTipPed .And. !Empty(M->C5_TIPO) .And. nFM_TIPOMO > 0
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_TIPOMOV = '"+M->C5_TIPO+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf
		If !Empty(cNCM)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_POSIPI = '"+cNCM+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf
		If !Empty(cGrpTi)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_GRPTI = '"+cGrpTi+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf
		If !Empty(cTipoCli)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_TIPOCLI = '"+cTipoCli+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf
		If !Empty(cGrpcst)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_GRPCST = '"+cGrpcst+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf
		If !Empty(cOrigem)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_ORIGEM = '"+cOrigem+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf

		cQuery += Iif(!Empty(cQuery1),cQuery1+") QTDREGRA, ","")+"SFM.* FROM " + RetSqlName("SFM") + " SFM "
		cQuery += "WHERE SFM.FM_FILIAL = '" + xFilial("SFM") + "' "
		cQuery += "AND SFM.FM_TIPO = '" + cTpOper + "' "
		cQuery += "AND SFM.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY "+Iif(!Empty(cQuery1),"QTDREGRA DESC,","")+SqlOrder(SFM->(IndexKey()))
	EndIf
	cAliasSFM := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFM,.T.,.T.)
#ELSE
	dbSelectArea("SFM")
	dbSetOrder(1)
	MsSeek(xFilial("SFM")+cTpOper)
#ENDIF

lQuery1 := Iif(!Empty(cQuery1), .T., .F.) 
nQTDREGRA := Iif(lQuery1,(cAliasSFM)->QTDREGRA,0)

If ValType(nQTDREGRA) == "C"
	nQTDREGRA := Val(nQTDREGRA)
EndIf

While (cAliasSFM)->(!Eof()) .And. (cAliasSFM)->FM_TIPO==cTpOper
	// Caso a quantidade de regras atendidas seja igual a zero, significa que
	// não existe regra de TES Inteligente que atenda ao cenário informado.
	If ( lQuery1 .AND. (cAliasSFM)->QTDREGRA == 0 )
		Exit
	EndIf

	// Verificar se esta Bloqueado
	If ( nFM_MSBLQL > 0 .And. (cAliasSFM)->FM_MSBLQL == '1' )
		(cAliasSFM)->( dbSkip() )
		LOOP
	EndIf

	//Será considerado como prioridade a maior quantidade de campos enquadrados
	lAddTes	:= .F.
	nQtdeEnq	:= 0			
	If !Empty((cAliasSFM)->FM_TS) .Or. !Empty((cAliasSFM)->FM_TE)
/*
		aCndTesInt	:= Condicao(cAliasSFM,	nFM_EST,	nFM_TIPOMO,	nFM_POSIPI,	nFM_GRPTI,;
								nFM_TPCLI,	nFM_GRPCST,	lGrade,		cTipoCF,	cProduto,;
								cGruProd,	cClieFor,	cLoja,		cGrupo,		cEstado,;
								cNCM,		cGrpTi,		cTipoCli,	cGrpcst,	lTipPed,;
								nFM_ORIGEM, cOrigem)
*/
		nQtdeEnq	:= 0
		lAddTes	:= .F.
	EndIF

	IF lAddTes .AND. Eval(bCondAux)
		If Eval(bIRWhile) .And. Eval(bIFWhile)
			Eval(bAddTes)//Adiciono o conteudo original da rotina
			Eval(bAtTes) //Caso o ponto de entrada MT089CD esteja ativo, adiciono o retorno dele
		EndIf
	EndIf

	(cAliasSFM)->( dbSkip() )
EndDo

If ( lQuery )
	(cAliasSFM)->( dbCloseArea() )
	dbSelectArea("SFM")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa por todas as regras validas para este caso          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSort(aTES,,,bSort) //Ordena o array conforme passado na regra do bSort, podendo ser alterardo pelo PE MT089CD

//Caso utilize ponto de entrada, mantenho o legado do sistema
If !ExistBlock("MT089CD")	
	//------------------------------------------------------------------
	//Para nova regra, deverá verificar se houve empate de enquadramento
	//------------------------------------------------------------------
	//Verifica se existe empate, se existir irá desempatar pela regra do cliente	
	If !Desempate(@aTes,cTipoCF,aOrdSFM, Iif(cTipoCF == 'C',cPrOrdClie ,cPrOrdForn ))
		
		//Se não conseguiu desempatar pela regra do cliente irá tentar desempatar pela regra padrão
		IF !Desempate(@aTes,cTipoCF,,Iif(cTipoCF == 'C',cPrOrdClie ,cPrOrdForn ))
			//Se ainda assim não conseguiu desempatar, pela regra do cliente e pela regra padrão
			//é porque existem regras cadastradas na SFM somente com tipo de movimento igual copm TES diferente ou
			//regras com mesmo campos chaves iguais, neste caso não irei sugerir nenhum TES pois este cadastro está duplicado.
			//Por este motivo irei zerar o aTES  
			//Abaixo trecho de LOG para incidar regras de TES que estão empatadas e que a rotina não irá sugerir por falta de critério
			//o usuário deverá analisar estes empates para rever as regras e eliminar regras conflitantes.			
			
			nPosQtdEnq	:= Iif(cTipoCF == "C",14,13)			
			nQtdEmp	:= aTES[1][nPosQtdEnq]  
			
			ProcLogIni({})
			ProcLogAtu("INICIO",'STR0009',,'MATA089')
			For nCont := 1 to len(aTES)
				
				cIdFM	:= ''
				If lFmId
					cIdFM	:= aTES[nCont][Iif(cTipoCF == "C",16,14)]					
				EndIF
				
				cRecno	:= cvaltochar(aTES[nCont][Iif(cTipoCF == "C",17,15)]) 			
							
				//Somente irei guardar LOG dos empates com maior número de enquadramento
				IF nQtdEmp ==  aTES[nCont][nPosQtdEnq]
					cLogTes	+= Iif(!Empty(cIdFM),'Código da Regra de TES Inteligente: ' + cIdFM ,'' ) + " TES: " + aTES[nCont][ Iif(nEntSai==1,8,9) ] + " Tipo de Movimentação: " +  cTpOper +" Rotina: " + FunName() + " RECNO: " + cRecno +  CHR(10)+CHR(13)	+  CHR(10)+CHR(13)				
				Else					 
					Exit
				EndIF 
				
			Next nCont			
			
			ProcLogAtu("ERRO",'STR0013',cLogTes,'MATA089')			
			ProcLogAtu("FIM",'STR0014',,'MATA089')
			aTES	:= {}
		EndIF		
	EndIF
EndIF

If Len(aTes) <> 0
	cTesRet := If(nEntSai==1,aTes[1][8],aTes[1][9])
EndIf

If nPosCpo > 0 .And. !Empty(cTesRet) .And. Type('aCols') <> "U"
	aCols[n][nPosCpo] := cTesRet
	Do Case
		Case cTabela == "SD1"
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("D1_CF") })
		Case cTabela == "SD2"
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("D2_CF") })
		Case cTabela == "SC6"
			dbSelectArea("SF4")
			dbSetOrder(1)
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("C6_CF") })
			If nPosCfo > 0 .And. MsSeek(xFilial("SF4")+cTesRet)
				aDadosCfo := {}
				AAdd(aDadosCfo,{"OPERNF","S"})
				AAdd(aDadosCfo,{"TPCLIFOR",If(cTipoCF == "C", cTipoCli     , SA2->A2_TIPO )})
				AAdd(aDadosCfo,{"UFDEST"  ,If(cTipoCF == "C", SA1->A1_EST  , SA2->A2_EST  )})
				AAdd(aDadosCfo,{"INSCR"   ,If(cTipoCF == "C", SA1->A1_INSCR, SA2->A2_INSCR)})
				AAdd(aDadosCfo,{"CONTR"   ,If(cTipoCF == "C", SA1->A1_CONTRIB, "")})
				Aadd(aDadosCfo,{"FRETE"   ,cTipFrete})
				aCols[n][nPosCfo] := MaFisCfo( ,SF4->F4_CF,aDadosCfo )
			EndIf
			nPosCfo := 0
		Case cTabela == "SC7"
			cProg := "MT120"
		Case cTabela == "SC8"
			cProg := "MT150"
		Case cTabela == "SUB"
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("UB_CF") })
			cProg := "TK273"
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Agroindustria  		   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cTabela == "NKO"  
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("NKO_TES") })
		
	EndCase
	If nPosCfo > 0
		aCols[n][nPosCfo] := Space(Len(aCols[n][nPosCfo]))
	EndIf
	If MaFisFound("IT",N)
		MaFisAlt("IT_TES",cTesRet,n)
		MaFisRef("IT_TES",cProg,cTesRet)
	EndIf
EndIf
If !Empty(cTesRet)
	dbSelectArea("SF4")
	If SF4->( MsSeek(xFilial("SF4")+cTesRet) )
		If !RegistroOK("SF4")
			cTesRet := Space(Len(cTesRet))
		EndIf
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso NENHUMA regra tenha sido aplicada, ao inves de retornar uma TES em ³
	//³branco, a instrucao a seguir MANTEM a TES existente no aCols, ANTES da  ³
	//³execucao do gatilho do campo ??_OPER que executou esta funcao MaTesInt()³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	If Type("aCols") == "A" .AND. !(nModulo == 12)  .And. (!Empty(cTesSaiB1) .Or. !Empty(cTesEntB1))
		nPosTes := aScan(aHeader,{|x| AllTrim( Substr( x[2] , AT("_TES" , x[2] ) , AT("_TES" , x[2] )+ 4  ))  == AllTrim("_TES") } )
		If nPosTes > 0
			cTesRet := aCols[N,nPosTes]
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da rotina                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSA2)
RestArea(aAreaSA1)
RestArea(aAreaSB1)
RestArea(aArea)
Return(cTesRet)
Static Function Desempate(aTes,cTipoCF,aOrdemTes, cOrdSFM)

Local nCont		:= 0
Local nQtde		:= 0
Local nContTes	:= 0
Local bSort		:=	Iif(cTipoCF == 'C',{|x,y| x[14] > y[14]},{|x,y| x[13] > y[13]})
Local lAlt			:= .F.
Local lRet			:= .F.
Local nPosATes	:= Iif(cTipoCF == 'C',14,13)

Default aOrdemTes	:= &(cOrdSFM)  //Ordem padrão do sistema

//Verifica se existem regras empatadas no array aTes
//A variável nQtde terá a quantidade de TES empatadas
If CheckEmpate(aTes,@nQtde,cTipoCF)

	//Aqui existem pelo menos duas regras empatadas.	Irá então processar a ordem dos campos de prioridade para desempatar e sugerir o TES
	For nCont := 1 to Len(aOrdemTes)
		lAlt	:= .F.
		//Irá verificar em todos os tes empatados a ordem dos campos
		For nContTes	:= 1 to nQtde		
			
			If ChkOrdSFM(aTes[nContTes],aOrdemTes[nCont],cTipoCF)
				//Se atendeu a regra da ordem prioritária, irá incrementar o número de enquadramento
				aTes[nContTes][nPosATes] ++
				lAlt	:= .T.
			EndIF
		
		Next nContTes
		
		//Somente irá processar se houve alteração em alguma regra 
		If lAlt		
			//Após verificar o campo em todos as regras empatadas, irá então ordenar novamente para ver se
			//ainda resta regras empatadas
			aSort(aTES,,,bSort)
			//Deverá verificar aqui se desempatou
			If !CheckEmpate(aTes,,cTipoCF)
				//Não há mais empate, foi resolvido com o processamento da ordem dos campos e não deverá mais verificar os
				//demais campos da ordem de prioridade
				lRet	:= .T.
				Exit
			Endif
		EndIF	
									
	Next nCont		
Else
	lRet	:= .T.
EndIf

Return lRet

/*/{Protheus.doc} CheckEmpate
 
Função que irá percorrer o array aTes, verifica se existe regras com o 
mesmo número de campos enquadrados, ou seja, estão empatados.
  
@param  	aTes      - Array com informações dos Tes enquadrados
			nQtde     - Quantidade de Tes empatadas
			cTipoCF   -Indca operação com Cliente 'C' ou fornecedor 'F'
@return	(nQtde>1)  - Retornar booleano, indicando que existem Tes empatadas			
@author Erick G. Dias
@since 12/05/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function CheckEmpate(aTes,nQuantidad,cTipoCF)
Local nContEmp		:= 0
Local nQtdeEnq	:= 0
Local nPosATes	:= Iif(cTipoCF == 'C',14,13)
Default nQuantidad		:= 0

//Verifica se existem regras empatadas
For nContEmp	:= 1 to Len(aTes)	
	If  aTes[nContEmp][nPosATes] >= nQtdeEnq
		nQtdeEnq	:= aTes[nContEmp][nPosATes]
		nQuantidad++
	Else
		Exit
	EndIF
	
Next nContEmp

Return (nQuantidad>1)



user function RetCli(cFilBusca,nCliente)
Local cRet:= ""
Local aAreaSM0 := SM0->(GetArea())
if SM0->( DbSeek(cEmpAnt + cFilBusca))
    If Select("QRY")>0         
        QRY->(dbCloseArea())
    Endif
    cQry := "Select A1_COD, A1_LOJA from "+ RetSqlName("SA1")+" SA1"
    cQry += " Where D_E_L_E_T_ =' ' and A1_CGC ='"+ SM0->M0_CGC+"'"
    TcQuery cQry New Alias "QRY"  

    if QRY->(!EOF())
        if nCliente ==0
            cRet :=  QRY->A1_COD
        Else
            cRet :=  QRY->A1_LOJA
        Endif
    endif
Endif
RestArea(aAreaSM0)
Return cRet
