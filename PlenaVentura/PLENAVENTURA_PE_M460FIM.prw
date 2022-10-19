/*/{Protheus.doc} M460FIM
// Este P.E. e' chamado apos a Gravacao da NF de Saida, e fora da transação.
// Gera ativo a partir de um pedido de vendas.
@author totvs.fernando
@since 26/11/2015
@version 1.0

@type function
/*/
#Include "TOPCONN.CH"
User Function M460FIM()

Local aArea 		:= GetArea()
Local aAreaSD2 		:= SD2->(GetArea())
Local _cNota 		:= SF2->F2_DOC
Local cDsProd		:= ""
Local cSeq			:= ""
Local cAtuAtivo		:= SuperGetMv("BL_ATUATV",.F.,"N") 			// Atualiza o ativo fixo?
Local cPatrim 		:= "N"
Local dAquisic 		:= dDataBase 
Local dIndDepr 		:= RetDinDepr(dDataBase)
Local nTamBase 		:= TamSX3("N3_CBASE")[1]
Local nTamChapa 	:= TamSX3("N3_CBASE")[1]
Local aParam 		:= {}
Local aCab 			:= {}
Local aItens 		:= {}
Local cLog			:= ""
Local BLNUMFROT     := GetMv("BL_NUMFROT")
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
	

// -> Atualiza informações da NF
If Alltrim(FunName()) == "MATA461"                                                     
  	RecLock("SF2",.F.)
	//SF2->F2_MENNOTA := ""
	SF2->F2_MENNOTA := SC5->C5_MENNOTA
  	MsUnlock("SF2")  
EndIf

										
dbSelectArea("SD2")
SD2->(dbSetOrder(3))
SD2->(dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE))

While !SD2->(EOF()) .AND. SD2->D2_DOC == _cNota
	//Abre os itens dos pedidos
	SC6->(dbSetOrder(1))
	IF SC6->(dbSeek( xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV))
		Reclock("SD2",.F.) 	
		SD2->D2_CCUSTO := SC6->C6_CCUSTO
		MsUnlock()
	endif
	if cEmpAnt = "09"
		U_MFAT001()
	Endif
	If cAtuAtivo == "S"	// Gera ativo a partir do pedido de venda
		cGeraAtivo 	:= Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_ATUATF")
		If cGeraAtivo <> "S"
			SD2->(dbSkip())
			Loop
		Endif
		
		cDsProd 	:= Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")
		cGeraFrota 	:= Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1__GRFRT")
		
		If cGeraFrota == "S"
			cSeq	:= BLNUMFROT  // Codigo numerico
			cCodigo := "F" + cSeq
			PutMv("BL_NUMFROT",SOMA1(strzero(val(cSeq),len(cSeq) )))
			 
		Else
			cCodigo := substr(SD2->D2_COD,1, nTamBase)
		Endif
		nValor 	:= SD2->D2_TOTAL
		DbSelectArea("SN1")
		DbSetOrder(1)
		If DbSeek(xFilial("SN1")+cCodigo+"0001")
			Alert("Ativo " + cCodigo + "já inserido no sistema!")
			SD2->(dbSkip())
			Loop
		Endif
		RecLock("SN1",.T.)
		SN1->N1_FILIAL	:= xFilial("SN1")	
		SN1->N1_CBASE	:= cCodigo		 	
		SN1->N1_ITEM	:= "0001" 			
		SN1->N1_AQUISIC := dDataBase 		
		SN1->N1_DESCRIC := cDsProd 			
		//SN1->N1_ORIGEM  := "ATFA310" 		
		SN1->N1_QUANTD  := SD2->D2_QUANT	
		SN1->N1_CHAPA	:= cCodigo 			
		SN1->N1_PATRIM	:= cPatrim 			
		SN1->N1_STATUS	:= "0"	 			
		SN1->N1__PRDOR	:= SD2->D2_COD				
		SN1->N1_PRODUTO	:= SD2->D2_COD
		SN1->N1_NSERIE	:= SD2->D2_SERIE
		SN1->N1_NFISCAL	:= SD2->D2_DOC		
		SN1->(MsUnlock())
		
		RecLock("SN3",.T.)
		SN3->N3_FILIAL	:= xFilial("SN3")
		SN3->N3_CBASE	:= cCodigo 		
		SN3->N3_ITEM	:= "0001" 		
		SN3->N3_TIPO 	:= "01"			
		SN3->N3_TPSALDO := "1"
		SN3->N3_BAIXA   := "0" 			
		SN3->N3_HISTOR  := cDsProd 						
		SN3->N3_DINDEPR := dIndDepr 
		SN3->N3_AQUISIC := dDataBase	
		SN3->N3_VORIG1  := nValor 							
		SN3->N3_VORIG3 	:= nValor 							
		SN3->N3_TPDEPR 	:= "1"		
		SN3->N3_CUSTBEM := SD2->D2_CCUSTO
		SN3->(MsUnlock())
		
		cLog += "Ativo " + alltrim(cCodigo) + " incluído com sucesso!" + chr(13) + chr(10) 
				
		
	Endif
	SD2->(dbSkip())
EndDo
if !Empty(SC5->C5_MDNUMED).and.  FWCodEmp() =='09'
 
	//Filtra títulos dessa nota
	cSql := "SELECT R_E_C_N_O_ AS REC FROM "+RetSqlName("SE1")
	cSql += " WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND D_E_L_E_T_<>'*' "
	cSql += " AND E1_PREFIXO = '"+SF2->F2_SERIE+"' AND E1_NUM = '"+SF2->F2_DOC+"' "
	cSql += " AND E1_TIPO = 'NF' "
	
	TcQuery ChangeQuery(cSql) New Alias "_QRY"
     
    //Enquanto tiver dados na query
	While !_QRY->(eof())
		DbSelectArea("SE1")
		SE1->(DbGoTo(_QRY->REC))
		aCondicao := Condicao(SE1->E1_VALOR ,SC5->C5_CONDPAG,,DdATABASE)
		IF len(aCondicao) != 0 .And. ! Empty(aCondicao[1][1])
			dVencimento := aCondicao[1][1]
		EndIF
		//Se tiver dado, altera o tipo de pagamento
		If !SE1->(EoF())
			RecLock("SE1",.F.)
				Replace E1_VENCTO WITH dVencimento
				Replace E1_VENCREA WITH dVencimento
			MsUnlock()
		EndIf
		
		_QRY->(DbSkip())
	Enddo
	_QRY->(DbCloseArea())
Endif
if ( !empty(cLog) )
	msgInfo(cLog)
endIf
RestArea(aAreaSD2)
RestArea(aArea)

//Chama funcao para integracao do faturamento com Financeiro (Centro de Custo)
U_AFAT001()
 
Return
