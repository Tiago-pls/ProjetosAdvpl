#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE2.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"

user Function GeraDados()
	Private _cPerg := ''
	_cPerg := "GERADADOS"
	GeraPerg(_cPerg)
	If !Pergunte(_cPerg,.T.)
		Return
	Endif
	cQuery := Query(MV_PAR07)
	cArq := alltrim(MV_PAR08)
	cArq += "\" +iif(MV_PAR07 =='1', 'Titulos', 'Fornecedores')
	cArq += "_"+strtran(DToC(Date()),"/","")+"_"+strtran(time(),":","")+".txt"
	nHandle := fCreate(cArq,0)

	FWrite(nHandle, cHeader)
	nCont := 0
	nValor := 0

	While QRY->(! EOF())
		nCOnt += 1
		nValor += QRY->E2_VALOR
		FWrite(nHandle, LoteR())
		QRY->(DbSkip())
	enddo


Return


Static Function GeraPerg(_cPerg)
	Local aRegs:= {}
	aAdd(aRegs,{_cPerg,"01","Filial de"        ,"Filial de"        ,"Filial de"        ,"mv_ch1",'C',06,0,0,'G',''          , '', '', '', 'MV_PAR01'})
	aAdd(aRegs,{_cPerg,"02","Filial Ate"       ,"Filial Ate"       ,"Filial Ate"       ,"mv_ch2","C",06,0,0,"G","naovazio()","mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{_cPerg,"03","Fornecedor de"    ,"Fornecedor de"    ,"Fornecedor de"    ,"mv_ch3","C",06,0,0,"G"," "         ,"mv_par03","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{_cPerg,"04","Fornecedor Ate"   ,"Fornecedor Ate"   ,"Fornecedor Ate"   ,"mv_ch4","C",06,0,0,"G","naovazio()","mv_par04","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{_cPerg,"05","Data de"          ,"Data Ate"         ,"Data Ate"         ,"mv_ch5","D",08,0,0,"G","          ","mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{_cPerg,"06","Data Ate"         ,"Data Ate"         ,"Data Ate"         ,"mv_ch6","D",08,0,0,"G","naovazio()","mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{_cPerg,"07","Tipo arquivo"     ,"Tipo arquivo"     ,"Tipo arquivo"     ,"mv_ch7","C",01,0,0,"G","naovazio()","mv_par07","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{_cPerg,"08","Diretório Arquivo","Diretório Arquivo","Diretório Arquivo","mv_ch8","C",99,0,0,"G","naovazio()","mv_par08","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})

	U_BuscaPerg(aRegs)

Return

static function Query(cTipo)
	cQuery :=""

	if cTipo =='1'
		cLenSA2 :=cValtoChar(len(alltrim(xFilial("SA2"))) )
		cQuery := " Select * from " + RetSqlName("SE2") + " SE2"
		cQuery += " Inner join "+ RetSqlName("SA2") +" SA2 on E2_FORNECE = A2_COD and E2_LOJA = A2_LOJA"
		cQuery += " Where E2_FILIAL >= '" + MV_PAR01+"' and E2_FILIAL <='" + MV_PAR02+"' and SE2.D_E_L_E_T_ =' '"
		cQuery += " AND E2_FORNECE >='"+MV_PAR03+"' and E2_FORNECE <= '"+MV_PAR04+"' "
		cQuery += " AND E2_VENCTO >= '"+ DTos(MV_PAR05)+"' and E2_VENCTO <= '"+ Dtos(MV_PAR06)+"' and SA2.D_E_L_E_T_ =' '"
		cQuery += " AND SubString(E2_FILIAL ,1,"+cLenSA2+")   =  SubString(A2_FILIAL ,1,"+cLenSA2+") "
	Endif
return ChangeQuery(cQuery)
