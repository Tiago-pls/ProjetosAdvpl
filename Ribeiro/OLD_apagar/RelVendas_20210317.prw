#INCLUDE "MATR580.CH" 
#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MATR580  ³ Autor ³ Tiago Santos          ³ Data ³ 16/03/21 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Estatistica de Venda por Ordem de Vendedor                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFAT - R4                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
user Function RelVendas()

Local oReport
Local aPDFields := {"A3_NOME"}
Local oFatVend


oReport := TReport():New("MATR580",STR0015,"RTR580", {|oReport| ReportPrint(oReport,oFatVend)},STR0016 + " " + STR0017 + " " + STR0018)
Pergunte(oReport:uParam,.F.)
oFatVend := TRSection():New(oReport,STR0026,{"SA3"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

oFatVend:SetTotalInLine(.F.)
TRCell():New(oFatVend,"D2_FILIAL"	,"QRY"  ,RetTitle("A3_FILIAL")		,PesqPict("SA3","A3_FILIAL")	,TamSx3("A3_FILIAL")	[1]	,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo Filial"
TRCell():New(oFatVend,"F2_VEND1"	,"QRY"  ,RetTitle("A3_COD")			,PesqPict("SA3","A3_COD")		,TamSx3("A3_COD")		[1]	,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo do Vendedor"
TRCell():New(oFatVend,"CNOME"		,		,RetTitle("A3_NOME")		,PesqPict("SA3","A3_NOME")		,TamSx3("A3_NOME")		[1]	,/*lPixel*/,/*{|| cNome }*/						)		// "Nome do Vendedor"
TRCell():New(oFatVend,"TB_VALOR1"	,    	,STR0019					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)		// "Faturamento S/ ICM/IPI"
TRCell():New(oFatVend,"TB_VALOR2"	,     	,STR0020					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)       // "Valor da Mercadoria"
TRCell():New(oFatVend,"TB_VALOR3"	,   	,STR0021					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)       // "Valor Total"
TRCell():New(oFatVend,"F2_CLIENTE" 	,"QRY" 	,"Cliente"					,PesqPict("SF2","F2_CLIENTE")	,TamSx3("F2_CLIENTE")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)       // "Cliente"
TRCell():New(oFatVend,"NOME_CLIENTE",   	,"Nome Cliente"				,PesqPict("SA1","A1_NOME")	    ,TamSx3("A1_NOME")	    [1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)       // "Nome Cliente"

oReport:PrintDialog()

return

Static Function ReportPrint(oReport,oFatVend)

Local oDados  	:= oReport:Section(1)
Local nOrdem  	:= oDados:GetOrder()
Local lMultVend := SuperGetMv("MV_LJTPCOM",,'1') $'23'
Local cEstoq 	:= If( (MV_PAR09 == 1),"S",If( (MV_PAR09 == 2),"N","SN" ) )
Local cDupli 	:= If( (MV_PAR08 == 1),"S",If( (MV_PAR08 == 2),"N","SN" ) )
Local lValadi	:= cPaisLoc == "MEX" .AND. VALTYPE(MV_PAR12) == "N"  .AND. MV_PAR12==1  .AND. SD2->(FieldPos("D2_VALADI")) > 0
Local nCont := 0
Private nDecs:=msdecimais(mv_par06)
oReport:SetTitle(oReport:Title() + " " + IIF(mv_par05 == 1,STR0023,STR0024) + " - "  + GetMv("MV_MOEDA"+STR(mv_par06,1)) )		// "Faturamento por Vendedor"###"(Ordem Decrescente por Vendedor)"###"(Por Ranking)"

oDados:Init()

If Select("QRY")>0         
	QRY->(dbCloseArea())
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtragem do relatório                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nModulo == 12 .And. !lMultVend) .Or. (nModulo != 12 )

	dbSelectArea("SD2")			// Itens de Venda da NF
	dbSetOrder(5)				// Filial,Emissao,NumSeq
	dbSelectArea("SD1")			// Itens da Nota de Entrada
	dbSetOrder(6)				// Filial,Data de Digitacao,NumSeq
    cQry := MontaQry()

    TcQuery cQry New Alias "QRY"   

    While QRY->( !EOF())
        oReport:IncMeter()
		nTOTAL  :=0
		nVALICM :=0
		nVALIPI :=0
		nVALST  :=0
        nCont +=1
        nTaxa	:=	IIf( QRY->F2_TXMOEDA > 0, QRY->F2_TXMOEDA,0)		
		nMoedNF	:=	IIf( QRY->F2_MOEDA > 0,QRY->F2_MOEDA,0)

        If AvalTes( QRY->D2_TES,cEstoq,cDupli)
            nVALICM += xMoeda(QRY->D2_VALICM,1,mv_par06 ,QRY->D2_EMISSAO,nDecs+1)
			nVALIPI += xMoeda(QRY->D2_VALIPI,1,mv_par06 ,QRY->D2_EMISSAO,nDecs+1)
			nVALST	+= xMoeda(QRY->F2_ICMSRET,1,mv_par06,QRY->D2_EMISSAO,nDecs+1)

            If !(QRY->F2_TIPO == "I" .AND. QRY->F2_ICMSRET > 0)
				nTotal	+=	xMoeda(QRY->D2_TOTAL-Iif(lValadi,QRY->D2_VALADI,0),nMoedNF,mv_par06,QRY->D2_EMISSAO,nDecs+1,nTaxa)
			EndIf	
        Endif


        oFatVend:Cell("TB_VALOR1"):SetValue(nTotal)	
        

        oFatVend:PrintLine()
        oFatVend:SetHeaderSection(.F.)  

        QRY->( DbSkip())
    Enddo
Endif


return


static Function MontaQry ()   
local cRet:= ""


cQuery :=" SELECT  SD2.*, F2_EMISSAO, F2_TIPO, F2_DOC, F2_FRETE, F2_SEGURO, F2_DESPESA, F2_FRETAUT, F2_ICMSRET, F2_VEND1, F2_CLIENTE, "
cQuery += " F2_TXMOEDA, F2_MOEDA"
cQuery += " FROM " + RetSqlName("SD2") + " SD2"
cquery += " inner join " + RetSqlName("SF4") +" SF4 on F4_CODIGO  = D2_TES and F4_FILIAL = D2_FILIAL"
cQuery += " inner join " + RetSqlName("SF2") + " SF2 on "
cQuery += " D2_DOC     = F2_DOC AND D2_SERIE   = F2_SERIE 	AND "
cQuery += " D2_CLIENTE = F2_CLIENTE AND D2_LOJA    = F2_LOJA"
cQuery += " WHERE D2_EMISSAO between '" +  DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
cQuery += " AND D2_TIPO NOT IN ('D', 'B')"
cQuery += " AND SD2.D_E_L_E_T_ =' '"
cQuery += " AND SF2.D_E_L_E_T_ =' '"
cQuery += " AND SF4.D_E_L_E_T_ =' '"
cQuery += " AND F2_VEND1 between '" +  mv_par03 +"' AND '" + mv_par04  + "' "
cQuery += " ORDER BY D2_FILIAL,D2_EMISSAO,D2_DOC,D2_NUMSEQ"
Return cQuery
