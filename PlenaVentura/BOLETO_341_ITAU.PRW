#include 'protheus.ch'


#define __codBanco "341"
#define __nomBanco "ITAU"

#define nLarg  (605-35)
#define nAlt   842


User Function RBol341( oBoleto )

	
	Local nBloco1 := 0
	Local nBloco2 := 0
	Local nBloco3 := 0
	Local cCart:= 'R01'
	Local nPont :=""

	Private oArial06  := TFont():New('Arial',06,06,,.F.,,,,.T.,.F.,.F.)
	Private oArial09N := TFont():New('Arial',10,10,,.T.,,,,.T.,.F.,.F.)
	Private oArial12N := TFont():New('Arial',12,12,,.T.,,,,.T.,.F.,.F.)
	Private oArial14  := TFont():New('Arial',16,16,,.F.,,,,.T.,.F.,.F.)
	Private oArial18N := TFont():New('Arial',21,21,,.T.,,,,.T.,.F.,.F.)

	//calcula o valor dos abatimentos
	//Private nValorAbatimentos :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	Private nValorAbatimentos := SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"S",/*data*/,/*nValorImpostos*/,/*nTotIrAbt*/,/*nTotCsAbt*/,/*nTotPisAbt*/,/*nTotCofAbt*/,/*nTotInsAbt*/,SE1->E1_FILIAL, /*nTxMoeda*/, /*nTotISS*/)


	//calculo valor total
	Private nValorDocumento := Round((((SE1->E1_SALDO+SE1->E1_ACRESC)-SE1->E1_DECRESC)*100)-(nValorAbatimentos*100),0)/100

	//nosso numero
	Private cNossoNumero := GetNossoNumero()
	Private cLinhaDigitavel := ""
	//codigo de barras
	Private cCodigoBarra := ""

	Private lEnderecoCobranca := !Empty(SA1->A1_ENDCOB) .and. !Empty(SA1->A1_BAIRROC) .and. !Empty(SA1->A1_MUNC) .and. !Empty(SA1->A1_ESTC) .and. !Empty(SA1->A1_CEPC)

	Private aInstrucoes := {"","","",""}

	// Cálculo do Digito é na hora da impressão.
	cNossoNumero := alltrim(SEE->EE_CODCART) + "/" + substr(SE1->E1_NUMBCO,1,8) + "-" + alltrim(Str(nnItau(substr(SE1->E1_NUMBCO,1,8))))
	cCodigoBarra := BolCodBar()
	
	aInstrucoes[1] := ALLTRIM(SE1->E1_HIST) //"CONDOMINIO AREA COMUM"

	If cEmpAnt $ getmv("MV_EMPJUR")//cEmpAnt ="09" //Braslift
		npercmulta:=getmv("MV_LJMULTA")
		aInstrucoes[2] := "Após o vencimento, cobrar mora  de "+ Transform(SE1->E1_PORCJUR,"@E 99.99") +"% (R$ " + Transform(nValorDocumento*SE1->E1_PORCJUR/100,"@E 999,999.99") +") ao dia."
		aInstrucoes[3] := "Após o vencimento, cobrar multa de "+ Transform(npercmulta,"@E 99.99") +"% (R$ " + Transform(nValorDocumento*npercmulta/100,"@E 999,999.99") +")"
	Else
		aInstrucoes[2] := "Após o vencimento, cobrar mora  de "+ Transform(SE1->E1_VALJUR,"@E 99.99")+"% (R$ " + Transform(nValorDocumento*SE1->E1_VALJUR/100,"@E 999,999.99") +") ao dia."
		aInstrucoes[3] := "Após o vencimento, cobrar multa de "+Transform(SE1->E1_PORCJUR,"@E 99.99")+"% (R$ " + Transform(nValorDocumento*SE1->E1_PORCJUR/100,"@E 999,999.99") +")"
	Endif
	
    aInstrucoes[4] := IIF(SE1->E1_XDESCON<>0,"Conceder abatimento de R$ "+Transform(SE1->E1_XDESCON,"@E 999,999.99") +" para pagamento até o dia "+FormDate(SE1->E1_VENCTO),"")
          
	//inicia pagina
	oBoleto:StartPage()

	//ajuste fino
	nBloco2 -= 145
	//Pontilhado separador
	For nPont := 10 to nLarg+10 Step 4
		oBoleto:Line(nBloco2+147, nPont,nBloco2+147, nPont+2,,)
	Next nPont

	//Nome do Banco
	oBoleto:Say(nBloco2+170,25,"ITAU",oArial12N )
	//logo
	oBoleto:SayBitmap(nBloco2+157, 20, "\boletos\logos\logo-banco-341.jpg", 75, 20)
	//Line(linha_inicial, coluna_inicial, linha final, coluna final)
	oBoleto:Line( nBloco2+157,  95, nBloco2+177,  95,,"01")
	oBoleto:Line( nBloco2+157, 146, nBloco2+177, 146,,"01")
	oBoleto:Line( nBloco2+177,  20, nBloco2+177,nLarg,,"01")

	//Numero do Banco
	oBoleto:Say(nBloco2+174,99,"341-7",oArial18N )

	//adiciona mais dois ao depois
	nBloco1 += 3

	oBoleto:Say(nBloco2+174,420,"Recibo do Pagador",oArial09N)

	ImprimeBloco(oBoleto, nBloco2, 1)


	//BLOCO 3
	nBloco3 := -160
	//Pontilhado separador
	For nPont := 10 to nLarg+10 Step 4
		oBoleto:Line(nBloco3+470, nPont,nBloco3+470, nPont+2,,)
	Next nPont

	//Nome do Banco
	oBoleto:Say(nBloco3+493,25,"ITAU",oArial12N )
	//logo
	oBoleto:SayBitmap(nBloco3+480, 20, "\boletos\logos\logo-banco-341.jpg", 75, 20)
	//Line(linha_inicial, coluna_inicial, linha final, coluna final)
	oBoleto:Line( nBloco3+480,  95, nBloco3+500,  95,,"01")
	oBoleto:Line( nBloco3+480, 146, nBloco3+500, 146,,"01")
	oBoleto:Line( nBloco3+500,  20, nBloco3+500,nLarg,,"01")

	//Numero do Banco
	oBoleto:Say(nBloco3+497,99,"341-7",oArial18N )
	//linha digitavel
	oBoleto:SayAlign(nBloco3+485,155,cLinhaDigitavel,oArial14,400,,,1)

	ImprimeBloco(oBoleto, nBloco3 + 323 , 2)


	//oBoleto:Say(480,25,cCodigoBarra,oArial09N)

	//CODIGO DE BARRAS
	//oBoleto:Say(600,25,cCodigoBarra,oArial09N)
	//oBoleto:Code128C(650,26,cCodigoBarra,55)
	oBoleto:int25(650,25,cCodigoBarra,1,55)



	//Finaliza pagina
	oBoleto:EndPage()
	If Alltrim(SE1->E1_NUMBCO) = ''
	DbSelectArea("SE1")
	 RecLock("SE1",.f.)
	  SE1->E1_NUMBCO := Alltrim(cNossoNumero)   //GRAVA NOSSO NUMERO NO TITULO
	DbUnlock()
	Endif

//	RecLock("SE1",.F.)
//	SE1->E1_EMITBOL := "S"
//	MsUnLock("SE1")

Return








Static Function ImprimeBloco(oBoleto, nBloco, nPosBloco)

	//bloco 2 linha 1 ->
	oBoleto:Say(nBloco+185,25 ,"Local de Pagamento",oArial06)
	oBoleto:Say(nBloco+197,25 ,"Até o vencimento, preferencialmente no Itaú e Após o vencimento, somente no Itaú",oArial09N)

	oBoleto:Say(nBloco+185,425 ,"Vencimento",oArial06)
	oBoleto:SayAlign(nBloco+187,435,FormDate(SE1->E1_VENCTO),oArial09N,100,10,,1)

	//bloco 2 linha 2 ->
	oBoleto:Line( nBloco+202,  20, nBloco+202,nLarg,,"01")
	oBoleto:Say(nBloco+210,25 , "Nome do Beneficiário / CNPJ / CPF / Endereço",oArial06)
	oBoleto:Say(nBloco+220,25 , SM0->M0_NOMECOM + " - CNPJ: " + transform(SM0->M0_CGC,"@R 99.999.999/9999-99") ,oArial09N)
	oBoleto:Say(nBloco+229,25 , alltrim(SM0->M0_ENDCOB) + " - " + alltrim(SM0->M0_BAIRCOB) + " - " + alltrim(SM0->M0_CIDCOB) + "-" + SM0->M0_ESTCOB + " - " + transform(SM0->M0_CEPCOB,"@R 99999-999") ,oArial09N)

	oBoleto:Say(nBloco+210,425 ,"Agência/Código Beneficiário",oArial06)
	oBoleto:SayAlign(nBloco+212,435, alltrim(SEE->EE_AGENCIA)+ "/" + alltrim(SEE->EE_CONTA) + "-" + alltrim(SEE->EE_DVCTA),oArial09N,100,10,,1)

	//bloco 2 linha 4 ->
	oBoleto:Line( nBloco+237,  20, nBloco+237,nLarg,,"01")
	oBoleto:Say(nBloco+243,25, "Data do Documento" ,oArial06)
	oBoleto:Say(nBloco+253,25, FormDate(SE1->E1_EMISSAO), oArial09N)

	oBoleto:Line(nBloco+237, 110, nBloco+257,110,,"01")
	oBoleto:Say(nBloco+243,115, "Nro. Documento"                                  ,oArial06)
	oBoleto:Say(nBloco+253,115, SE1->E1_PREFIXO+alltrim(SE1->E1_NUM)+IIF(Empty(SE1->E1_PARCELA),"","/")+SE1->E1_PARCELA ,oArial09N)

	oBoleto:Line(nBloco+237, 232, nBloco+257,232,,"01")
	oBoleto:Say(nBloco+243,237, "Espécie Doc."                                   ,oArial06)
	oBoleto:Say(nBloco+253,237, "PD"										,oArial09N) //Tipo do Titulo

	oBoleto:Line(nBloco+237, 293, nBloco+257,293,,"01")
	oBoleto:Say(nBloco+243,298, "Aceite"                                         ,oArial06)
	oBoleto:Say(nBloco+253,298, "NÃO"                                             ,oArial09N)

	oBoleto:Line(nBloco+237, 339, nBloco+257,339,,"01")
	oBoleto:Say(nBloco+243,344, "Data do Processamento"                          ,oArial06)
	oBoleto:Say(nBloco+253,344, FormDate(dDataBase),oArial09N) // Data impressao

	oBoleto:Say(nBloco+243,425 ,"Nosso Número",oArial06)
	oBoleto:SayAlign(nBloco+244,435,cNossoNumero,oArial09N,100,10,,1)

	//bloco 2 linha 5 ->
	oBoleto:Line( nBloco+257,  20, nBloco+257,nLarg,,"01")
	oBoleto:Say(nBloco+263,25,"Uso do Banco"                                   ,oArial06)
	oBoleto:Say(nBloco+273,25,""                                   ,oArial09N)

	oBoleto:Line(nBloco+257,110, nBloco+277,110,,"01")
	oBoleto:Say(nBloco+263,115 ,"Carteira"                                       ,oArial06)
	oBoleto:Say(nBloco+273,115 ,SEE->EE_CODCART                                  	,oArial09N)

	oBoleto:Line(nBloco+257, 171, nBloco+277,171,,"01")
	oBoleto:Say(nBloco+263,176 ,"Espécie"                                        ,oArial06)
	oBoleto:Say(nBloco+273,176 ,"9-REAL"                                             ,oArial09N)

	oBoleto:Line(nBloco+257, 232, nBloco+277,232,,"01")
	oBoleto:Say(nBloco+263,237,"Quantidade"                                     ,oArial06)
	oBoleto:Line(nBloco+257,339, nBloco+277,339,,"01")
	oBoleto:Say(nBloco+263,344,"Valor"                                          ,oArial06)

	oBoleto:Say(nBloco+263,425 ,"Valor do Documento",oArial06)
	oBoleto:SayAlign(nBloco+264,435,Transform(nValorDocumento,"@E 999,999,999.99"),oArial09N,100,10,,1)


	//bloco 2 linha 6 ->
	oBoleto:Line( nBloco+277,  20, nBloco+277,nLarg,,"01")
	oBoleto:Say( nBloco+283,25, "Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do beneficiário)" , oArial06)

	oBoleto:Say(nBloco+303,0025,aInstrucoes[1],oArial09N)
	oBoleto:Say(nBloco+313,0025,aInstrucoes[2],oArial09N)
	oBoleto:Say(nBloco+323,0025,aInstrucoes[3],oArial09N)
	oBoleto:Say(nBloco+336,0025,aInstrucoes[4],oArial09N)

	oBoleto:Say(nBloco+283,425,"(-)Desconto/Abatimento",oArial06)
	oBoleto:SayAlign(nBloco+286,435,Transform(SE1->E1_XDESCON,"@E 999,999,999.99"),oArial09N,100,10,,1)

	//bloco 2 linha 7 ->
	oBoleto:Line( nBloco+297,  420, nBloco+297,nLarg,,"01")
	oBoleto:Say(nBloco+303,425,"(-)Outras Deduções",oArial06)

	//bloco 2 linha 8 ->
	oBoleto:Line( nBloco+317,  420, nBloco+317,nLarg,,"01")
	oBoleto:Say(nBloco+323,425,"(+)Mora/Multa",oArial06)

	//bloco 2 linha 9 ->
	oBoleto:Line( nBloco+337,  420, nBloco+337,nLarg,,"01")
	oBoleto:Say(nBloco+343,425,"(+)Outros Acréscimos",oArial06)

	//bloco 2 linha 10 ->
	oBoleto:Line( nBloco+357,  420, nBloco+357,nLarg,,"01")
	oBoleto:Say(nBloco+363,425,"(=)Valor Cobrado",oArial06)
	oBoleto:Line( nBloco+177,  420, nBloco+377,420,,"01")

	//bloco 2 Sacado ->
	oBoleto:Line( nBloco+377,  20, nBloco+377,nLarg,,"01")
	oBoleto:Say(nBloco+386,25 ,"Pagador",oArial06)
	oBoleto:Say(nBloco+386,90 ,alltrim(SA1->A1_NOME) + " (" +SA1->A1_COD+" - "+SA1->A1_LOJA+")",oArial09N)
	oBoleto:Say(nBloco+396,90 ,IIF(lEnderecoCobranca,SA1->A1_ENDCOB,SA1->A1_END) + " - " + IIF(lEnderecoCobranca,SA1->A1_BAIRROC,SA1->A1_BAIRRO) ,oArial09N)
	oBoleto:Say(nBloco+406,90 ,transform(IIF(lEnderecoCobranca,SA1->A1_CEPC,SA1->A1_CEP),"@R 99999-999")+ " - " + alltrim(IIF(lEnderecoCobranca,SA1->A1_MUNC,SA1->A1_MUN))+"/"+IIF(lEnderecoCobranca,SA1->A1_ESTC,SA1->A1_EST) ,oArial09N)
	IF SA1->A1_PESSOA == "J"
		oBoleto:Say(nBloco+416,90 ,"CNPJ: " + transform(SA1->A1_CGC,"@R 99.999.999/9999-99") ,oArial09N)
	Else
		oBoleto:Say(nBloco+416,90 ,"CPF: " + transform(SA1->A1_CGC,"@R 999.999.999-99") ,oArial09N)
	EndIF
	oBoleto:Say(nBloco+416,430 ,cNossoNumero ,oArial09N)

	//bloco 2 Sacado - autenticação ->
	oBoleto:Say(nBloco+416, 25, "Sacado/Avalista" , oArial06)
	oBoleto:Line( nBloco+420,  20, nBloco+420,nLarg,,"01")
	oBoleto:Say(nBloco+426,420, "Autenticação Mecânica - Ficha de compensação" , oArial06)

	If nPosBloco = 1
		oBoleto:Say(nBloco+426,20, "Recebimento através do cheque núm. do banco" , oArial06)
		oBoleto:Say(nBloco+436,20, "Esta quitação só terá validade após o pagamento do cheque pelo banco sacado." , oArial06)
	EndIf

Return


User Function b341NossoNum()

	//gera nosso numero
	NossoNum()

	RecLock("SE1",.F.)
	SE1->E1_BCOBOL := "341"
	SE1->( MsUnlock() )

Return

Static Function GetNossoNumero()

	Local cNossoNum := '' //Right(alltrim(NossoNum()), 06)

	// Gerar nosso número banco.
	If Empty(SE1->E1_NUMBCO)	
		IF !Empty(SEE->EE_FAXATU)
			cNossoNum := strzero(val(SEE->EE_FAXATU) + 1,8)
		else
			Aviso("Atenção","Tabela Parâmetros dos Bancos (EE_FAXATU) não configurada!",{"Sair"}, 2)
			Return
		EndIF
		IF !Empty(cNossoNum)
			IF RecLock("SEE",.F.)
				SEE->EE_FAXATU := cNossoNum
				SEE->(MsUnlock())
			EndIF
			 
			// Gravando sem o dígito da conta.
			IF RecLock("SE1",.F.)
				SE1->E1_NUMBCO := cNossoNum
				SE1->(MsUnlock())
			EndIF
			
		EndIF
	Endif


Return cNossoNum


Static Function BolCodBar()

	Local cValorFinal := StrZero(Round(nValorDocumento*100,0),10)
	Local nDigVerNN   := alltrim(Str(nnItau(substr(SE1->E1_NUMBCO,1,8))))
	Local nDigVerCB   := 0
	Local cCodigo     := ''
	Local cAuxiliar   := ''
	Local cFator      := StrZero( SE1->E1_VENCTO - CtoD("07/10/97"),4)

	Local cCarteira   := SEE->EE_CODCART
	Local cAgencia    := SUBSTR(SEE->EE_AGENCIA,1,4)
	Local cConta      := IIF(!EMPTY(SEE->EE_DVCTA),substr(SEE->EE_CONTA,1,5) +  substr(SEE->EE_DVCTA,1,1),substr(SEE->EE_CONTA,1,6))

	//	 Definicao do CODIGO DE BARRAS
	cAuxiliar:= SEE->EE_CODIGO + "9" + cFator +  cValorFinal + cCarteira + alltrim(SE1->E1_NUMBCO)+ alltrim(nDigVerNN) + cAgencia + cConta + '000'
	nDigVerCB := modulo11(cAuxiliar)
	cCodigo   := SubStr(cAuxiliar, 1, 4) + alltrim(str(nDigVerCB)) + SubStr(cAuxiliar,5,39)

	//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
	//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
	//	AAABC.CCDDX		DDDDD.DDFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV
	// 	CAMPO 1:
	//	AAA	= Codigo do banco na Camara de Compensacao
	//	  B = Codigo da moeda, sempre 9
	//	CCC = Codigo da Carteira de Cobranca
	//	 DD = Dois primeiros digitos no nosso numero
	//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	cAuxiliar    := SEE->EE_CODIGO + "9" + cCarteira + SubStr(alltrim(SE1->E1_NUMBCO),1,2)
	cLinhaDigitavel   := SubStr(cAuxiliar, 1, 5) + '.' + SubStr(cAuxiliar, 6, 4) + alltrim(str(modulo10(cAuxiliar))) + '  '

	// 	CAMPO 2:
	//	DDDDDD = Restante do Nosso Numero
	//	     E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
	//	   FFF = Tres primeiros numeros que identificam a agencia
	//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	cAuxiliar := Substr(alltrim(SE1->E1_NUMBCO),3,6) + Alltrim(nDigVerNN)+ Subs(cAgencia,1,3)
	cLinhaDigitavel +=  SubStr(cAuxiliar,1,5) + '.' + SubStr(cAuxiliar,6,5)  + alltrim(str(modulo10(cAuxiliar))) + ' '

	// 	CAMPO 3:
	//	     F = Restante do numero que identifica a agencia
	//	GGGGGG = Numero da Conta + DAC da mesma
	//	   HHH = Zeros (Nao utilizado)
	//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	cAuxiliar    := Subs(cAgencia,4,1) + Subs(cConta,1,4) +  Subs(cConta,5,2) +'000'
	cLinhaDigitavel   := cLinhaDigitavel + Subs(cAgencia,4,1) + Subs(cConta,1,4) +'.'+ Subs(cConta,5,2) +'000'+ alltrim(str(Modulo10(cAuxiliar)))
	//	CAMPO 4:
	//	     K = DAC do Codigo de Barras
	cLinhaDigitavel   := cLinhaDigitavel + ' ' + AllTrim(Str(nDigVerCB)) + '  '

	// 	CAMPO 5:
	//	      UUUU = Fator de Vencimento
	//	VVVVVVVVVV = Valor do Titulo
	cLinhaDigitavel   := cLinhaDigitavel + cFator + StrZero(Round(nValorDocumento * 100,0),14-Len(cFator))

Return cCodigo


Static Function Modulo10(cData)
	Local L,D,P := 0
	Local B     := .F.
	L := Len(cData)
	B := .T.
	D := 0
	While L > 0
		P := val(SubStr(cData, L, 1))
		IF (B)
			P := P * 2
			IF P > 9
				P := P - 9
			EndIF
		EndIF
		D := D + P
		L := L - 1
		B := !B
	EndDO
	D := 10 - (Mod(D,10))
	IF D = 10
		D := 0
	EndIF
Return(D)



Static Function Modulo11(cData)
	Local L, D, P := 0
	L := Len(cdata)
	D := 0
	P := 1
	While L > 0
		P := P + 1
		D := D + (val(SubStr(cData, L, 1)) * P)
		IF P = 9
			P := 1
		EndIF
		L := L - 1
	EndDO
	D := 11 - (mod(D,11))
	IF (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	EndIF
Return(D)


/*/{Protheus.doc} nnItau
(Gera nosso número Itaú)
@author Fernando Nonato
@since 23/03/2017
@version 1.0
/*/

Static Function nnItau(cNossoNum)
Local cNN 	:= Strzero(val(cNossoNum),8)
Local cAge	:= SUBSTR(SEE->EE_AGENCIA,1,4)
Local cCta	:= substr(SEE->EE_CONTA,1,5) 

cNN := Modulo10Itau(cAge + cCta + alltrim(SEE->EE_CODCART) + cNN)
Return(cNN)

Static Function Modulo10Itau(cNN)
	LOCAL L,D,P := 0
	LOCAL B     := .F.
	L := Len(cNN)
	B := .T.
	D := 0
	While L > 0
		P := Val(SubStr(cNN, L, 1))
		If (B)
			P := P * 2
			If P > 9
				P := P - 9
			End
		End
		D := D + P
		L := L - 1
		B := !B
	End
	D := 10 - (Mod(D,10))
	If D = 10
		D := 0
	End
Return(D)
