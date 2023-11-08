#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  RepMarc    ¦ Autor ¦ Tiago Santos        ¦ Data ¦02.08.23 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Marcações ìmpares                                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
// Programa desenvolvido por SMS Consultoria

user function GeraFatura
Private cPerg 	:= "" 
dbSelectArea("SX1")  
dbSetOrder(1)
cPerg := "FATURA" +Replicate(" ",Len(X1_GRUPO)- Len("FATURA"))

//Carrega os Parï¿½metros
//********************************************************************************
GeraPerg(cPerg)
  
If !Pergunte(cPerg,.T.)
   Return
Endif  
MsAguarde({|| GeraDados()}, "Aguarde...", "Gerando Registros...")
Return

Static function GeraDados
Local aFatPag :={}
Local aTits :={}
Local aLogfile	:= {}  // Array para conter as ocorrencias a serem impressas   
Local aLogTitulo:= {}  // Array para conter as ocorrencias a serem impressas  
Private nTamTit := TamSx3("E2_NUM")[1]
Private nTamParc := TamSx3("E2_PARCELA")[1]
Private nTamForn := TamSx3("E2_FORNECE")[1]
Private nTamLoja := TamSx3("E2_LOJA")[1]
Private nTamTipo := TamSx3("E2_TIPO")[1]
Private nTamFil  := TamSx3("E2_FILIAL")[1]
 
Private lMsErroAuto := .F.

aAdd(aLogFile, "- Geração de Faturas - Início em "  + Dtoc(MsDate()) + ', as ' + Time() + '.') 

cQuery := " Select E2_FILIAL, E2_NUM, E2_PREFIXO, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_VALOR, E2_NATUREZ"
cQuery += " From "+ RetSqlName("SE2") +" SE2"
cQuery += " Where D_E_L_E_T_ =' '  and E2_FILIAL = '" + xFilial("SE2") +"' "
cQuery += " and E2_VENCTO >= '"+DtoS(MV_PAR01)+"' and E2_VENCTO <= '"+DtoS(MV_PAR02)+"'"
cQuery += " and E2_PREFIXO ='"+MV_PAR03+"' and E2_SALDO <>0  "
cQuery += " and E2_FORNECE >= '"+MV_PAR04+"' and E2_FORNECE <= '"+MV_PAR05+"' "
cQuery += " Order by E2_FORNECE"

If Select("QRY") > 0
	QRY->(dbCloseArea())
Endif
TcQuery cQuery New Alias "QRY"  
cFornecedor :=""
cFatura	:= Soma1(GetMv("MV_NUMFATP"))
nValorTotal := 0
dDatade := MV_PAR01
dDataate := MV_PAR02
aAdd(aLogTitulo, "Fatura : "+ cFatura)
While QRY->( !EoF() )
	if !Empty(cFornecedor) .and. cFornecedor <> QRY->E2_FORNECE
		GravaFatura(aTits,cFatura)
		aAdd(aLogTitulo, "Total dos Títulos selecionados: "+ Transform(nValorTotal,"@E 999,999,999.99") + CHR(13)+CHR(10) )
		aTits :={}
		cFatura	:= Soma1(GetMv("MV_NUMFATP"))
		aAdd(aLogTitulo, "Fatura : "+ cFatura)
		nValorTotal := 0
	Endif

	aadd(aTits ,{ QRY->E2_PREFIXO, PADR(QRY->E2_NUM,nTamTit), PADR(QRY->E2_PARCELA,nTamParc), PADR(QRY->E2_TIPO,nTamTipo), .f., PADR(QRY->E2_FORNECE,nTamForn),PADR(QRY->E2_LOJA,nTamLoja), PADR(QRY->E2_FILIAL,nTamFil) }	)
	cFornecedor :=  QRY->E2_FORNECE
	cLoja :=  QRY->E2_LOJA
	cNatureza := QRY->E2_NATUREZ
	cTexto :="Título: " + QRY->E2_NUM + " Prefixo: "+QRY->E2_PREFIXO+ " Parcela: "+QRY->E2_PARCELA+ " Tipo: "+QRY->E2_TIPO+ " Fornecedor: "+QRY->E2_FORNECE+ " Loja: "+QRY->E2_LOJA+" Valor:" + Transform(QRY->E2_VALOR,"@E 999,999,999.99")
	nValorTotal += QRY->E2_VALOR
	aAdd(aLogTitulo,  cTexto)
	QRY->( DbSkip())
End while

if !empty(cFornecedor) // se entrou pelo menos uma vez no While
	GravaFatura(aTits,cFatura)

	aAdd(aLogTitulo, "Total dos Títulos selecionados: "+ Transform(nValorTotal,"@E 999,999,999.99"))
Endif
aAdd(aLogFile, "- Geração de Faturas - Fim em "  + Dtoc(MsDate()) + ', as ' + Time() + '.') 
fMakeLog( { aLogFile, aLogTitulo } , { 'Log de Ocorrencias:', OemToAnsi("Seleção de títulos para os parâmetros selecionados") } , NIL , .T. , FunName() )    

Return 
  
static function GravaFatura(aTits, cFatura)
	// fornecedor diferente	
	aFatPag := { "FAT", PADR("NF",nTamTipo), cFatura, "200201002", dDatade, dDataAte, PADR(cFornecedor,nTamForn), PADR(cLoja,nTamLoja), PADR(cFornecedor,nTamForn),  PADR(cLoja,nTamLoja), "001", 01, aTits ,0 ,0 }
	MsExecAuto( { |x,y| FINA290(x,y)}, 3, aFatPag )		
	If lMsErroAuto
		MostraErro()
	Else
		//Alert("Fatura gerada com sucesso")
		PutMv("MV_NUMFATP", cFatura)
	Endif
Return

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
