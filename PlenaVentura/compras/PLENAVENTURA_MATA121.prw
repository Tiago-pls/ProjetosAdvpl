#include 'protheus.ch'
user  Function PCodInfo()

	Local cCondicaoPagamento := '001'
	Local cObservaoAdicional := 'SF1->F1_OBSADL'
	Local lOk 			:= .F.
	Local oDlgCustom
	Local oObs
	Local cSeek  		:= xFilial( "ZK1" ) + ''//SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)
	Local cWhile 		:= "ZK1->ZK1_FILIAL + ZK1->ZK1_CHAVE"
	Local aObjects   	:= {}
	Local aSize      	:= MsAdvSize( .F. )
	Local aNoFields 	:= {"ZK1_CHAVE"}
	
	Local aHeadZK1 	:= {}
	Local aColZK1 	:= {}
	Local aParcsOld 	:= {}
	Local n1
	Local nValTotal  	:= 0
	Local lData		:= .T.
	Local dData		:= DDATABASE
	Local nTotalNF	:= 0
	private aCols,aHeader:={}
	private INCLUI := .F.
	private ALTERA := .T.
	Private oParcs
	aSaveGrid 	:= {aCols,aHeader}


	//monta aHeadZK1 e aColZK1
	FillGetDados(4,"ZK1",1,cSeek,{|| &cWhile },,aNoFields,,,,,,@aHeadZK1,@aColZK1,,,,)

	DEFINE MSDIALOG oDlgCustom TITLE 'cCadastro' From 0,0 TO 350,500 PIXEL

	@ 10,20   SAY "Condição de Pagamento" SIZE 73, 8 OF oDlgCustom PIXEL
	@ 20,20   MSGET cCondicaoPagamento PICTURE PesqPict("SF1","F1_COND") F3 "SE4" VALID ExistCPO("SE4", cCondicaoPagamento) SIZE 20,9 OF oDlgCustom When INCLUI .Or. ALTERA PIXEL

	@ 20, 50 Button "Gerar"  Size 32, 9 Pixel Action AtualizaParcelas(cCondicaoPagamento, @oParcs, @aParcsOld)   Of oDlgCustom

	oParcs  := MsNewGetDados():New(010,100,70,230,IIF(INCLUI .Or. ALTERA,GD_UPDATE,0),"AllwaysTrue","AllwaysTrue",/*inicpos*/,,/*freeze*/,120,"AllwaysTrue",/*superdel*/,/*delok*/,oDlgCustom,aHeadZK1,aColZK1)

	@ 70,20   SAY "Observação" SIZE 73, 8 OF oDlgCustom PIXEL
	@ 80,20   GET oObs Var cObservaoAdicional MEMO VALID !Empty(cCondicaoPagamento) SIZE 210,60 OF oDlgCustom PIXEL
	//apenas na inclusao e na alteração podera alterar

	IF !(ALTERA .Or. INCLUI)
		//não sendo o caso, desabilita edição no memo
		oObs:lReadOnly := .T.
	EndIF
	//aParc := AtualizaParcelas(cCondicaoPagamento, @oParcs, @aParcsOld)
	oParcs:aCols := AtualizaParcelas(cCondicaoPagamento, @oParcs, @aParcsOld)
	oParcs:refresh()
	DEFINE SBUTTON FROM 150, 175 When .T. TYPE 1 ACTION (aColZK1 := oParcs:aCols, aHeadZK1 := oParcs:aHeader,oDlgCustom:End(),lOk:=.T.) ENABLE OF oDlgCustom
	DEFINE SBUTTON FROM 150, 205 When .T. TYPE 2 ACTION (oDlgCustom:End()) ENABLE OF oDlgCustom

	ACTIVATE MSDIALOG oDlgCustom CENTERED

	//se confirmar e for alteração ou inclusao
	IF lOk .And. ( ALTERA .Or. INCLUI )

		nValTotal := 0
		nTotalNF  := 0

		//loop para retornar o valor total digitado
		For n1 := 1 to len(aColZK1)

			nValTotal  += aColZK1[n1][3]  //valor itens
			dData 		:= aColZK1[n1][2] //Data digitada

			//Valida se a data digitada é menor que a data base do sistema
			if  dData < dDataBase
				//muda variavel logica
				lData := .F.
			Endif

		Next n1

		//Retonar valor total da NF com Impostos/frete etc
		nTotalNF := u_VALTOTNF()
		//se a data digitada for acima da data base do sistema entra no if
		If lData		

			For n1 := 1 to len(aColZK1)
				ZK1->( dbSetOrder(1) ) // pedido
				if ZK1->( dbSeek( cSeek + 'pedido' ) )
					RecLock("ZK1",.F.)
					ZK1->( dbDelete() )
					ZK1->( MsUnLock())
				else
					RecLock("ZK1", .T.)
						ZK1->ZK1_FILIAL := xFilial("ZK1")
						ZK1->ZK1_CHAVE  := SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)
						ZK1->ZK1_PARC   := aColZK1[n1][1]
						ZK1->ZK1_VENC   := aColZK1[n1][2]
						ZK1->ZK1_VALOR  := aColZK1[n1][3]
					ZK1->( MsUnLock())
				endif				
			Next n1

		Else
			if !lData
				MsgAlert( 'Data das parcelas não podem ser menor que a data base do sistema!')
			EndIF

			PCodInfo()
		EndIF
	EndIF

	aCols := aSaveGrid[1]
	aHeader := aSaveGrid[2]

Return



Static Function AtualizaParcelas(cCondicao, oGrid, aParcsOld)

	Local nValTotal 	:= 1000 //VALTOTNF()
	Local aParcelas 	:= Condicao(nValTotal, cCondicao,,dDatabase)
	Local n1
	Local n2
	Local cParcela 	:= IIF(Len(aParcelas)>1,SuperGetMV("MV_1DUP")," ")

	//Local nValTotal 	:= ALLTRIM(STR(u_VALTOTNF() * 10,14,2)) //Valor Total do Pedido (Nota-se a140Total[2] e a140Total[3]) //STR para vir com pontos
	Local nZK1_PARC  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZK1_PARC"} ) //Pega a posicao do campo
	Local nZK1_VENC  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZK1_VENC"} ) //Pega a posicao do campo
	Local nZK1_VALOR 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZK1_VALOR"} ) //Pega a posicao do campo

	For n1 := 1 to len(aCols)
		IF GDFieldGet('ZK1_REC_WT',n1) != 0
			aAdd(aParcsOld,GDFieldGet('ZK1_REC_WT',n1))
		EndiF
	Next n1
	aCols := {}

	For n1 := 1 to len(aParcelas)
		aAdd( aCols, Array(len(aHeader)+1) )
		For n2 := 1 To Len(aHeader)
			IF IsHeadRec(aHeader[n2][2])
				aCols[len(aCols)][n2] := 0
			ElseIF IsHeadAlias(aHeader[n2][2])
				aCols[len(aCols)][n2] := "ZK1"
			Else
				aCols[len(aCols)][n2] := CriaVar(aHeader[n2,2],.F.)
			EndIF
		Next n2

		aCols[len(aCols)][len(aHeader)+1] := .F.

		aCols[n1][nZK1_PARC]  := cParcela //posicao 1
		aCols[n1][nZK1_VENC]  := aParcelas[n1][1]	//posicao 2
		aCols[n1][nZK1_VALOR] := aParcelas[n1][2] //ALLTRIM(TransForm(aParcelas[n1][2],"@E 999,999.99"))
		//aCols[n1][4]  		 := cUserName //posicao 4

		cParcela := MaParcela(cParcela)
	Next n1

Return aCols

