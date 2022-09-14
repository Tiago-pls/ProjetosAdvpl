#INCLUDE "protheus.ch"
#INCLUDE "report.ch"
#INCLUDE "topconn.ch"
//���������������������������������������������������������������������������������������
//� Criado		: 20/05/2015			     											�
//� Autor		: Cristiano Roberto Giacomozzi											�
//� Utiliza��o	: M�dulo Gest�o de Pessoal - Relat�rio de Funcion�rios.					�
//� Descri��o	: Programa respons�vel por gerar uma lista com algumas informa��es dos 	�
//� funcion�rios cadastros e ativos no sistema.											�
//� Criado		: 10/09/2018			     											�
//� Autor		: Cristiano Roberto Giacomozzi											�
//� Descri��o	: Query alterada.													 	�
//� Alteracao   : 06/04/2022			     											�
//� Autor		: Tiago Santos               											�
//� Descri��o	: Inclus�o Descricao CC, Item e Descri��o Item   					 	�
//���������������������������������������������������������������������������������������
User Function FTGPERRF()
Local oReport

If TRepInUse()
	Pergunte("FTGPERRF",.F.)
	oReport := ReportDef()
	oReport:PrintDialog()	
EndIf
Return

Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2
Local aOrdem	:= { "Filial+Matricula","Filial+Nome","Filial+Centro de Custo","Filial+Contrato"}

oReport := TReport():New("FTGPERRF","Relat�rio de funcion�rios","FTGPERRF",{|oReport| PrintReport(oReport)},"Relat�rio de funcion�rios")

oSection1 := TRSection():New(oReport,"FUNCIONARIOS",{"SRA"},aOrdem)

TRCell():New(oSection1,"RA_FILIAL"	,"SRA"	,"Filial")
TRCell():New(oSection1,"RA_MAT"		,"SRA"	,"Matr�cula")
TRCell():New(oSection1,"RA_NOME"	,"SRA"	,"Nome")
TRCell():New(oSection1,"RA_SEXO"	,"SRA"	,"Sexo")
TRCell():New(oSection1,"RA_CIC"		,"SRA"	,"CPF")
TRCell():New(oSection1,"RA_ADMISSA"	,"SRA"	,"Data de Admiss�o")
TRCell():New(oSection1,"RA_DTVCCNH"	,"SRA"	,"Data Venc. CNH")
TRCell():New(oSection1,"RA_CC"		,"SRA"	,"Centro de Custos")
TRCell():New(oSection1,"CTT_DESC01"	,"CTT"	,"Desc Centro C.")
TRCell():New(oSection1,"RA_ITEM"	,"SRA"	,"Item")
TRCell():New(oSection1,"CTD_DESC01"	,"CTD"	,"Desc. Item")
TRCell():New(oSection1,"RA_CHAPA"	,"SRA"	,"Contrato")
TRCell():New(oSection1,"RA_EXAMEDI"	,"SRA"	,"Data Venc. Exame. Med.")
TRCell():New(oSection1,"RA_CODFUNC"	,"SRA"	,"C�digo Fun��o")
TRCell():New(oSection1,"RJ_DESC"	,"SRJ"	,"Descri��o Fun��o")
TRCell():New(oSection1,"RA_SALARIO"	,"SRA"	,"Sal�rio")
TRCell():New(oSection1,"FILHOS"		," "	,"Filhos")

Return oReport

Static Function PrintReport(oReport)
Local oSection1 := oReport:Section(1)
Local nOrdem	:= oSection1:GetOrder()
Local cOrdem	:= ""
Private cFilTit	:= ""
Private cCcTit	:= ""
Private aInfo	:= ""

If nOrdem == 1
	cOrdem += "%RA_FILIAL, RA_MAT%"
ElseIf nOrdem == 2
	cOrdem += "%RA_FILIAL, RA_NOME%"
ElseIf nOrdem == 3
	cOrdem += "%RA_FILIAL, RA_CC%"
ElseIf nOrdem == 4
	cOrdem += "%RA_FILIAL, RA_CHAPA%"
EndIf

	
#IFDEF TOP	
  
	MakeSqlExpr("FTGPERRF")
	
	oSection1:BeginQuery()
		
		BeginSql alias "QRYSRA"

			SELECT DISTINCT RA_FILIAL, RA_MAT, RA_NOME, RA_SEXO, RA_ADMISSA, RA_DTVCCNH, RA_CC, CTT_DESC01,RA_ITEM,  CTD_DESC01,RA_CHAPA, RA_EXAMEDI, RA_CODFUNC, RJ_DESC, RA_SALARIO, RA_DTVCRIP
			, (SELECT COUNT(*) FROM SRB010 WHERE D_E_L_E_T_ = '' AND RA_FILIAL = RB_FILIAL AND RA_MAT = RB_MAT AND RB_GRAUPAR = 'F') AS FILHOS, RA_CIC
			FROM %table:SRA% SRA
			INNER JOIN %table:SRJ% SRJ ON RA_CODFUNC = RJ_FUNCAO
			INNER JOIN %table:CTT% CTT ON RA_CC      = CTT_CUSTO
			INNER JOIN %table:CTD% CTD ON RA_ITEM    = CTD_ITEM
			WHERE SRA.%notDel% AND SRJ.%notDel%
			AND (RA_SITFOLH != 'D' or RA_DEMISSA >=%Exp:mv_par09%)
			AND RA_FILIAL BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
			AND RA_CC BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
			AND RA_CHAPA BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
			AND RA_ADMISSA <=    %Exp:mv_par09% 
			ORDER BY %exp:cOrdem%
		EndSql	
	oSection1:EndQuery() 

#ENDIF

cFilTit := RA_FILIAL
cCcTit	:= RA_CC

If mv_par08 == 1 .AND. nOrdem == 3
	oBreakCc := TRBreak():New(oSection1,oSection1:Cell("RA_CC"),{|| "Total Centro de Custo : " + fDescRel(2)},.F.)
	TRFunction():New(oSection1:Cell("RA_CC"),,"COUNT",oBreakCc,,"@E 999999",,.F.,.F.,.F.)
EndIf

oBreakFil := TRBreak():New(oSection1,oSection1:Cell("RA_FILIAL"),{|| "Total da Filial : "  + fDescRel(1) },.F.)
TRFunction():New(oSection1:Cell("RA_FILIAL"),,"COUNT",oBreakFil,,"@E 999999",,.F.,.F.,.F.)
TRFunction():New(oSection1:Cell("RA_FILIAL"),"Total Empresa","COUNT",,,"@E 999999",,.F.,.T.)

If mv_par07 == 1
	oBreakFil:SetPageBreak(.T.)
EndIf

oSection1:Print()


Return

//�������������������������������������������������������������������������������������������
//� Fun��o respons�vel pela montagem da descri��o do total por filial e centro de custo.	�
//�������������������������������������������������������������������������������������������
Static Function fDescRel(nTipo)
Local cRet	:= ""

If nTipo == 1	// Filial
	fInfo(@aInfo,cFilTit)
	cRet	:= cFilTit + " " + aInfo[1]
	cFilTit	:= RA_FILIAL
ElseIf nTipo == 2	// Centro de Custo
	cRet	:= cCcTit + " " + Left(fDesc("CTT",cCcTit,"CTT->CTT_DESC01",,cFilTit) + Space(10),30)
	cCcTit	:= RA_CC
EndIf

Return(cRet)
