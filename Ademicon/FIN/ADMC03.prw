#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*/{Protheus.doc} ADMC03
Geracao de faturas da MultiCotas/Contemplay
@type function
@version 1.0 
@author Tiago Santos
@since 31/10/2023
@return variant, fixo nulo
/*/
user function ADMC03
	Private cPerg 	:= "" 
	dbSelectArea("SX1")  
	SX1->(dbSetOrder(1))
	cPerg := "FATURA" +Replicate(" ",Len(X1_GRUPO)- Len("FATURA"))

	//Carrega os Parï¿½metros
	//********************************************************************************
	GeraPerg(cPerg)
	
	If Pergunte(cPerg,.T.)
		MsAguarde({|| GeraDados()}, "Aguarde...", "Gerando Registros...")
	Endif  
Return


/*/{Protheus.doc} GeraDados
Processamento da geracao de faturas da MultiCotas/Contemplay
@type function
@version 1.0 
@author Tiago Santos
@since 31/10/2023
@return variant, fixo nulo
/*/
Static function GeraDados
	Local aTits :={}
	Local aLogfile	:= {}  // Array para conter as ocorrencias a serem impressas   
	Local aLogTitulo:= {}  // Array para conter as ocorrencias a serem impressas  
	Local nTamTit := TamSx3("E2_NUM")[1]
	Local nTamParc := TamSx3("E2_PARCELA")[1]
	Local nTamFil  := TamSx3("E2_FILIAL")[1]
	Private nTamForn := TamSx3("E2_FORNECE")[1]
	Private nTamLoja := TamSx3("E2_LOJA")[1]
	Private nTamTipo := TamSx3("E2_TIPO")[1]
	Private dDatade
	Private dDataate

	dDatade := MV_PAR01
	dDataate := MV_PAR02

	aAdd(aLogFile, "- Geração de Faturas - Início em "  + Dtoc(MsDate()) + ', as ' + Time() + '.') 

	cQuery := " Select E2_FILIAL, E2_NUM, E2_PREFIXO, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_VALOR, E2_NATUREZ, E2_EMISSAO"
	cQuery += " From "+ RetSqlName("SE2") +" SE2"
	cQuery += " Where D_E_L_E_T_ =' '  and E2_FILIAL = '" + xFilial("SE2") +"' "
	cQuery += " and E2_VENCTO >= '"+DtoS(dDatade)+"' and E2_VENCTO <= '"+DtoS(dDataate)+"'"
	cQuery += " and E2_PREFIXO ='"+MV_PAR03+"' and E2_SALDO <>0  "
	cQuery += " and E2_FORNECE >= '"+MV_PAR04+"' and E2_FORNECE <= '"+MV_PAR05+"' "
	cQuery += " Order by E2_FORNECE"

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	Endif
	TcQuery cQuery New Alias "QRY"  
	cFornecedor :=""
	While QRY->( !EoF() )
		cFornecedor :=  QRY->E2_FORNECE
		cLoja :=  QRY->E2_LOJA
		cNatureza := QRY->E2_NATUREZ
		aTits := {}
		cFatura	:= Soma1(GetMv("MV_NUMFATP"))
		aAdd(aLogTitulo, "Fatura : "+ cFatura)
		nValorTotal := 0
		nCont := 0
		While QRY->( !EoF() ) .and. cFornecedor == QRY->E2_FORNECE
		
			aadd(aTits ,{ QRY->E2_PREFIXO, PADR(QRY->E2_NUM,nTamTit), PADR(QRY->E2_PARCELA,nTamParc), PADR(QRY->E2_TIPO,nTamTipo), .f., PADR(QRY->E2_FORNECE,nTamForn),PADR(QRY->E2_LOJA,nTamLoja), PADR(QRY->E2_FILIAL,nTamFil) }	)
			cTexto :="Título: " + QRY->E2_NUM + " Prefixo: "+QRY->E2_PREFIXO+ " Parcela: "+QRY->E2_PARCELA+ " Tipo: "+QRY->E2_TIPO+ " Fornecedor: "+QRY->E2_FORNECE+ " Loja: "+QRY->E2_LOJA+" Valor:" + Transform(QRY->E2_VALOR,"@E 999,999,999.99")
			nValorTotal += QRY->E2_VALOR
			aAdd(aLogTitulo,  cTexto)

			if nCont == 0 
				dDatede := Stod(E2_EMISSAO)
				dDateAte := Stod(E2_EMISSAO)
			else
				dDatade := Max(Stod(E2_EMISSAO))
				dDataAte := Max(Stod(E2_EMISSAO) , dDataAte)
			Endif
			nCont += 1
			QRY->( DbSkip())
		enddo
		GravaFatura(aTits, cFatura, cNatureza)
		aAdd(aLogTitulo, "Total dos Títulos selecionados: "+ Transform(nValorTotal,"@E 999,999,999.99") + CRLF )
	Enddo
	QRY->(dbCloseArea())
	aAdd(aLogFile, "- Geração de Faturas - Fim em "  + Dtoc(MsDate()) + ', as ' + Time() + '.') 
	fMakeLog( { aLogFile, aLogTitulo } , { 'Log de Ocorrencias:', OemToAnsi("Seleção de títulos para os parâmetros selecionados") } , NIL , .T. , FunName() )    
Return 


/*/{Protheus.doc} GravaFatura
Gerar a fatura
@type function
@version 1.0 
@author Tiago Santos
@since 31/10/2023
@param aTits, array, array de titulos a gerar a fatura
@param cFatura, character, numero da fatura a gerar
@param cNatureza, character, natureza do titulo a gerar
@return variant, fixo nulo
/*/
static function GravaFatura(aTits, cFatura, cNatureza)
	Local aFatPag :={}
	Private lMsErroAuto := .F.
	// fornecedor diferente	
	aFatPag := { "FAT", PADR("NF",nTamTipo), cFatura, cNatureza, dDatade, dDataAte, PADR(cFornecedor,nTamForn), PADR(cLoja,nTamLoja), PADR(cFornecedor,nTamForn),  PADR(cLoja,nTamLoja), "001", 01, aTits , 0, 0}
	MsExecAuto( { |x,y| FINA290(x,y)}, 3, aFatPag )		
	If lMsErroAuto
		MostraErro()
	Else
		//Alert("Fatura gerada com sucesso")
		PutMv("MV_NUMFATP", cFatura)
	Endif
Return

/*/{Protheus.doc} GeraPerg
Criar as perguntas da geracao de fatura
@type function
@version 1.0 
@author Tiago Santos
@since 31/10/2023
@param cPerg, character, pergunta
@return variant, fixo nulo
/*/
Static Function GeraPerg(cPerg) 
	Local aRegs:= {}

	//aAdd(aRegs,{cPerg,"01","Filial"         ,"Filial De"        ,"Filial De"       ,"mv_ch1","C",06,0,0,"G"," "         ,"mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
	//aAdd(aRegs,{cPerg,"02","Filial Ate"     ,"Filial Ate"       ,"Filial Ate"      ,"mv_ch2","C",06,0,0,"G","naovazio()","mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
	aAdd(aRegs,{cPerg,"01","Vencimento de"  ,"Vencimento De"    ,"Vencimento De"   ,"mv_ch1","D",08,0,0,"G"," "         ,"mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Vencimento Ate" ,"Vencimento Ate"   ,"Vencimento Ate"  ,"mv_ch2","D",08,0,0,"G","naovazio()","mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Prefixo"        ,"Prefixo"          ,"Prefixo"         ,"mv_ch3","C",03,0,0,"G","naovazio()","mv_par03","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Fornecedor de"  ,"Fornecedor De"    ,"Fornecedor De"   ,"mv_ch4","C",06,0,0,"G"," "         ,"mv_par04","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","","SA2"})
	aAdd(aRegs,{cPerg,"05","Fornecedor Ate" ,"Fornecedor Ate"   ,"Fornecedor Ate"  ,"mv_ch5","C",06,0,0,"G"," "         ,"mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","","SA2"})
	U_BuscaPerg(aRegs)
Return
