#include "protheus.ch"
#include "topconn.ch"

User Function PEDFAT()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Declaracao de variaveis                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cCod := Posicione('SA3',7,xFilial('SA3')+__cUserId,'A3_COD')
	Private oReport  := Nil
	//Private cPerg 	 := PadR ("PEDFAT001", Len (SX1->X1_GRUPO))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao e apresentacao das perguntas      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//PutSx1(cPerg,"01","Emissão de?"  ,'','',"mv_ch1","D",TamSx3 ("C5_EMISSAO")[1] ,0,,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
	//PutSx1(cPerg,"02","Emissão ate?" ,'','',"mv_ch2","D",TamSx3 ("C5_EMISSAO")[1] ,0,,"G","","","","","mv_par02","","","","","","","","","","","","","","","","")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicoes/preparacao para impressao      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := reportDef()
	oReport	:PrintDialog()
Return Nil

Static function reportDef()
	Local oReport
	Local oSection1
	Local oSection2
	Local cTitulo := 'Pedidos Abertos e Faturados'

	oReport := TReport():New("REL001", cTitulo,cPerg, {|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de pedidos.")
	//oReport:SetPortrait()
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()

	oSection1 := TRSection():New(oReport,"Pedidos",{"QRY"})
	oSection1:SetTotalInLine(.F.)

	TRCell():New(oSection1, "NUMERO"	, "QRY", 'NUMERO'	,"",40)//TamSX3("Z3_ESCALA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "EMISSAO"	, "QRY", 'EMISSAO'	,"",65)//TamSX3("Z3_ROTA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "CLIENTE"	, "QRY", 'CLIENTE'	,"",150)//TamSX3("Z3_DESCROT")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "VENDEDOR"  ,"QRY",  'VENDEDOR' ,"",150)//TamSX3("Z3_BOX")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "PRODUTO"	, "QRY", 'PRODUTO'	,"",150)//TamSX3("Z3_DIARIA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "QTD_VENDIDA"	, "QRY",'QTD VENDIDA',"@E 99,999,999.99",50)//TamSX3("Z3_NOMVEIC")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "QTD_ENTREGUE"	, "QRY",'QTD ENTREGUE'	,"@E 99,999,999.99",50)//TamSX3("Z3_NONMOT")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "SLD_ENT"	, "QRY",'SALDO A ENTREGAR'	,"@E 99,999,999.99",50)//TamSX3("Z3_NONMOT")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "PRECO"		, "QRY", 'PRECO'  	,"@E 99,999,999.99",30)//TamSX3("Z3_OBS")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TOTAL"		, "QRY", 'TOTAL'  	,"@E 99,999,999.99",50)//TamSX3("Z3_OBS")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "VLR_ENT"	, "QRY", 'VALOR A ENTREGAR'  	,"@E 99,999,999.99",50)//TamSX3("Z3_OBS")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TIPO"		, "QRY", 'TIPO'  	,"",50)//TamSX3("Z3_OBS")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

	//oBreak := TRBreak():New(oSection1,oSection1:Cell("Z3_ESCALA"),,.F.)

	//TRFunction():New(oSection1:Cell("Z3_ROTA"),"TOTAL FILIAL","COUNT",oBreak,,"@E 999999",,.F.,.F.)

	//TRFunction():New(oSection1:Cell("Z3_ESCALA"),"TOTAL GERAL" ,"COUNT",,,"@E 999999",,.F.,.T.)	

	return (oReport)
Return Nil

Static Function PrintReport(oReport)
	Local cQuery    := ""
	Local oSection1 := oReport:Section(1)
	Pergunte(cPerg,.F.)

	cQuery := " SELECT * FROM ( "
	cQuery += " SELECT "
	cQUery += "	C6_NUM AS 'NUMERO',"
	cQuery += "	CONVERT(SMALLDATETIME,C5_EMISSAO) AS 'EMISSÃO2',"
	cQuery += "	C5_EMISSAO AS 'EMISSAO',"
	cQuery += "	C6_CLI+' - '+RTRIM(A1_NOME) AS 'CLIENTE',"
	cQuery += "	RTRIM(A3_NOME) AS 'VENDEDOR',"
	cQuery += "	RTRIM(C6_PRODUTO)+' - '+RTRIM(B1_DESC) AS 'PRODUTO',"
	cQuery += "	C6_QTDVEN AS 'QTD_VENDIDA',"
	cQuery += "	C6_QTDENT AS 'QTD_ENTREGUE',"
	cQuery += "	C6_QTDVEN - C6_QTDENT AS 'SLD_ENT',"
	cQuery += "	C6_PRCVEN AS 'PRECO',"
	cQUery += "	C6_VALOR AS 'TOTAL'," 
	cQUery += " C6_PRCVEN * (C6_QTDVEN - C6_QTDENT) AS 'VLR_ENT', "
	cQuery += "	'PED. A FATURAR' AS 'TIPO' "
	cQuery += " FROM"
	cQuery += "	SC6010 SC6 INNER JOIN SA1010 SA1 ON A1_COD+A1_LOJA = C6_CLI+C6_LOJA AND SA1.D_E_L_E_T_='' AND A1_FILIAL =''"
	cQuery += "	INNER JOIN SC5010 SC5 ON C5_NUM = C6_NUM AND SC5.D_E_L_E_T_='' AND C5_FILIAL ='01'"
	//cQuery += "	INNER JOIN SB1010 SB1 ON B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_='' AND  B1_FILIAL ='01'"
	cQuery += "	INNER JOIN SB1010 SB1 ON B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_= '' "
	cQuery += "	LEFT OUTER JOIN SA3010 SA3 ON A3_COD = C5_VEND1 "
	cQuery += " INNER JOIN SF4010 SF4 ON SF4.D_E_L_E_T_ = '' AND F4_CODIGO = C6_TES AND (F4_DUPLIC = 'S' OR C5_VEND1 IN ('000086', '000184')) "
	cQUery += " WHERE"
	cQuery += "	SC6.D_E_L_E_T_=''"
	cQUery += "	AND C6_FILIAL ='01'"
	//cQUery += "	AND C5_EMISSAO BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"'"
	cQUery += "	AND C5_EMISSAO BETWEEN '20230201' AND '20230331'"
	If __cUserId =='000124' //comercial
		cQuery += " AND C5_VEND1 NOT IN ('000086', '000125') "
	Else
		//cQUery += "	AND (C5_VEND1 = '"+cCod+"'"+ " OR C5_VEND2 ='"+cCod+"')"	
		cQUery += "	AND (C5_VEND1 = '"+cCod+"'"+ " OR C5_VEND2 = '"+cCod+"' OR "
		cQUery += " A1_X_GER = '"+cCod+"' OR A1_X_VEND3 = '"+cCod+"')"	
	Endif
	cQUery += "	AND C6_QTDVEN > C6_QTDENT "   
	cQUery += "	AND C6_BLQ <> 'R' "
	cQUery += " UNION ALL "
	cQuery += " SELECT"
	cQuery += "	D2_DOC AS 'NÚMERO',"
	cQUery += "	CONVERT(SMALLDATETIME,D2_EMISSAO) AS 'EMISSÃO2',"
	cQUery += "	D2_EMISSAO AS 'EMISSAO',"
	cQuery += "	D2_CLIENTE+' - '+RTRIM(A1_NOME) AS 'CLIENTE',"
	cQUery += "	A3_NOME AS 'VENDEDOR',"
	cQuery += "	RTRIM(D2_COD)+' - '+RTRIM(B1_DESC) AS 'PRODUTO',"
	cQuery += "	D2_QUANT AS 'QTD_VENDIDA',"
	cQUery += "	D2_QUANT AS 'QTD_ENTREGUE',"
	cQUery += "	D2_QUANT-D2_QUANT AS 'SLD_ENT', "
	cQUery += "	D2_PRCVEN AS 'PRECO',"
	cQuery += "	D2_TOTAL AS 'TOTAL'," 
	cQUery += " D2_PRCVEN * (D2_QUANT-D2_QUANT ) AS 'VLR_ENT', "
	cQuery += "	'FATURADO' AS 'TIPO'"
	cQuery += " FROM "
	cQuery += "	SD2010 SD2 INNER JOIN SA1010 SA1 ON A1_COD+A1_LOJA = D2_CLIENTE+D2_LOJA AND SA1.D_E_L_E_T_='' AND A1_FILIAL =''	"
	//cQuery += "	INNER JOIN SB1010 SB1 ON B1_COD = D2_COD AND SB1.D_E_L_E_T_='' AND  B1_FILIAL ='01'"
	cQuery += "	INNER JOIN SB1010 SB1 ON B1_COD = D2_COD AND SB1.D_E_L_E_T_='' "
	cQuery += "	INNER JOIN SF2010 SF2 ON D2_DOC+D2_CLIENTE+D2_LOJA = F2_DOC+F2_CLIENTE+F2_LOJA AND F2_FILIAL='01' AND SF2.D_E_L_E_T_=''"
	cQuery += "	LEFT OUTER JOIN SA3010 SA3 ON A3_COD = F2_VEND1 "
	cQuery += "	INNER JOIN SF4010 SF4 ON SF4.D_E_L_E_T_ = '' AND F4_CODIGO = D2_TES AND (F4_DUPLIC = 'S' OR F2_VEND1 IN ('000086', '000184')) "
	cQuery += " WHERE"
	cQuery += "	SD2.D_E_L_E_T_=''"
	cQuery += "	AND D2_FILIAL ='01'"
	cQuery += "	AND D2_EMISSAO BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"'"
	IF __cUserId == '000124'//comercial	
		cQuery += " AND F2_VEND1 NOT IN ('000086', '000125') "
	Else
		//cQUery += "	AND (F2_VEND1 = '"+cCod+"'"+ " OR F2_VEND2 ='"+cCod+"')"	
		cQUery += "	AND (F2_VEND1 = '"+cCod+"'"+ " OR F2_VEND2 ='"+cCod+"' OR "
		cQUery += " A1_X_GER = '"+cCod+"' OR A1_X_VEND3 = '"+cCod+"')"
	Endif
	cQuery += " ) A WHERE QTD_VENDIDA > QTD_ENTREGUE " //APENAS SALDO EM ABERTO DE PEDIDOS GIORDANE - 14/11/2017
	cQuery += " ORDER BY "
	cQuery += "	A.EMISSAO "
	
	MemoWrite('c:/temp/PEDFAT.SQL',cQuery)
	
	cQuery := ChangeQuery(cQuery)

	If Select("QRY") > 0
		Dbselectarea("QRY")
		QRY->(DbClosearea())
	EndIf

	TcQuery cQuery New Alias "QRY"

	TCSetField("QRY","EMISSAO","D")

	dbSelectArea("QRY")
	dbGoTop()

	oSection1:Init()
	oSection1:SetHeaderSection(.T.)
	oReport:SetMeter(RecCount()) 

	While QRY->(!Eof())
		
		If oReport:Cancel()
			Exit
		EndIf

		oReport:IncMeter()

		oSection1:Cell("NUMERO"):SetValue(QRY->NUMERO)
		oSection1:Cell("NUMERO"):SetAlign("LEFT")

		oSection1:Cell("EMISSAO"):SetValue(QRY->EMISSAO)
		oSection1:Cell("EMISSAO"):SetAlign("LEFT")

		oSection1:Cell("CLIENTE"):SetValue(QRY->CLIENTE)
		oSection1:Cell("CLIENTE"):SetAlign("LEFT")

		oSection1:Cell("VENDEDOR"):SetValue(QRY->VENDEDOR)
		oSection1:Cell("VENDEDOR"):SetAlign("LEFT")

		oSection1:Cell("PRODUTO"):SetValue(QRY->PRODUTO)
		oSection1:Cell("PRODUTO"):SetAlign("LEFT")

		oSection1:Cell("QTD VENDIDA"):SetValue(QRY->QTD_VENDIDA)
		oSection1:Cell("QTD VENDIDA"):SetAlign("RIGHT")

		oSection1:Cell("QTD ENTREGUE"):SetValue(QRY->QTD_ENTREGUE)
		oSection1:Cell("QTD ENTREGUE"):SetAlign("RIGHT") 

		oSection1:Cell("SALDO A ENTREGAR"):SetValue(QRY->SLD_ENT)
		oSection1:Cell("SALDO A ENTREGAR"):SetAlign("RIGHT")

		oSection1:Cell("PRECO"):SetValue(QRY->PRECO)
		oSection1:Cell("PRECO"):SetAlign("RIGHT")     

		oSection1:Cell("TOTAL"):SetValue(QRY->TOTAL)
		oSection1:Cell("TOTAL"):SetAlign("RIGHT")

		oSection1:Cell("VALOR A ENTREGAR"):SetValue(QRY->VLR_ENT)
		oSection1:Cell("VALOR A ENTREGAR"):SetAlign("RIGHT")

		oSection1:Cell("TIPO"):SetValue(QRY->TIPO)
		oSection1:Cell("TIPO"):SetAlign("RIGHT")


		oSection1:PrintLine()
		oReport:IncMeter() 

		dbSelectArea("QRY")
		QRY->(dbSkip())
	EndDo	
	
	oSection1:Finish()

Return Nil
