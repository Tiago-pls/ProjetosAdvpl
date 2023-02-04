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
Local oFatVend
Local oSection1:= Nil
Local oSection2:= Nil

oReport := TReport():New("MATR580",STR0015,"RTR580", {|oReport| ReportPrint(oReport,oFatVend)},STR0016 + " " + STR0017 + " " + STR0018)
Pergunte(oReport:uParam,.F.)
oSection1 := TRSection():New(oReport,STR0026,{"SA3"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oSection1,"F2_VEND1"	,"QRY"  ,RetTitle("A3_COD")		    ,PesqPict("SA3","A3_FILIAL")	,TamSx3("A3_FILIAL")	[1]	,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo Filial"
TRCell():New(oSection1,"A3_NOME"   	,"QRY"  ,RetTitle("A3_NOME")		,PesqPict("SA3","A3_NOME")		,TamSx3("A3_NOME")		[1]	+ TamSx3("F2_LOJA")	[1]	+ TamSx3("F2_CLIENTE") [1],/*lPixel*/,/*{|| cVend }*/						)		// "Codigo do Vendedor"

oSection2 := TRSection():New(oReport,STR0026,{"SA3"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oSection2,"D2_FILIAL"	,  "QRY",RetTitle("D2_FILIAL")		,PesqPict("SD2","D2_FILIAL")	,TamSx3("D2_FILIAL")	[1]	,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo Filial"
TRCell():New(oSection2,"F2_CLIENTE"	,  "QRY",RetTitle("F2_CLIENTE")		,PesqPict("SA3","F2_CLIENTE")	,TamSx3("F2_CLIENTE")	[1]	,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo do Vendedor"
TRCell():New(oSection2,"F2_LOJA"	,"QRY"  ,RetTitle("F2_LOJA")		,PesqPict("SF2","F2_LOJA")	    ,TamSx3("F2_LOJA")  	[1]	,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo do Vendedor"
TRCell():New(oSection2,"A1_NOME"	,"QRY"  ,RetTitle("A1_NOME")		,PesqPict("SF2","A1_NOME")	    ,TamSx3("A1_NOME")  	[1]	,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo do Vendedor"
TRCell():New(oSection2,"D2_DOC"	    ,"QRY"  ,RetTitle("D2_DOC")		    ,PesqPict("SD2","D2_DOC")	    ,TamSx3("D2_DOC") [1]  + 13	,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo do Vendedor"

TRCell():New(oSection2,"TB_VALOR1"  ,    	,STR0019					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)		// "Faturamento S/ ICM/IPI"
TRCell():New(oSection2,"TB_VALOR2"  ,    	,STR0020					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)		// "Faturamento S/ ICM/IPI"
TRCell():New(oSection2,"TB_VALOR3"  ,    	,STR0021					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)		// "Faturamento S/ ICM/IPI"

// Alinhamento das colunas de valor a direita
oSection2:Cell("TB_VALOR1"):SetHeaderAlign("RIGHT")
oSection2:Cell("TB_VALOR2"):SetHeaderAlign("RIGHT")
oSection2:Cell("TB_VALOR3"):SetHeaderAlign("RIGHT")

oDevolucoes := TRSection():New(oReport,STR0026,{"SA3"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oDevolucoes,"D1_FILIAL"	,"QRYDEV"  ,RetTitle("D1_FILIAL")		,PesqPict("SD1","D1_FILIAL")	,TamSx3("D1_FILIAL")	[1]	,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo Filial"
TRCell():New(oDevolucoes,"F2_CLIENTE"	,"QRYDEV"  ,RetTitle("F2_CLIENTE")		,PesqPict("SA3","F2_CLIENTE")	,TamSx3("F2_CLIENTE")	[1]	,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo do Vendedor"
TRCell():New(oDevolucoes,"F2_LOJA"	    ,"QRYDEV"  ,RetTitle("F2_LOJA")		,PesqPict("SF2","F2_LOJA")	    ,TamSx3("F2_LOJA")  	[1]	,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo do Vendedor"
TRCell():New(oDevolucoes,"A1_NOME"	    ,"QRYDEV"  ,RetTitle("A1_NOME")		,PesqPict("SF2","A1_NOME")	    ,TamSx3("A1_NOME")  	[1]	,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo do Vendedor"
TRCell():New(oDevolucoes,"D1_DOC"	    ,"QRYDEV"  ,RetTitle("D1_DOC")		    ,PesqPict("SD1","D1_DOC")	    ,TamSx3("D1_DOC")    	[1]	,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo do Vendedor"
TRCell():New(oDevolucoes,"D1_NFORI"	    ,"QRYDEV"  ,RetTitle("D1_NFORI")		    ,PesqPict("SD1","D1_NFORI")	    ,TamSx3("D1_NFORI")    	[1]	,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo do Vendedor"

TRCell():New(oDevolucoes,"TB_VALOR1"  ,    	,STR0019					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)		// "Faturamento S/ ICM/IPI"
TRCell():New(oDevolucoes,"TB_VALOR2"  ,    	,STR0020					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)		// "Faturamento S/ ICM/IPI"
TRCell():New(oDevolucoes,"TB_VALOR3"  ,    	,STR0021					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)		// "Faturamento S/ ICM/IPI"

// Alinhamento das colunas de valor a direita
oDevolucoes:Cell("TB_VALOR1"):SetHeaderAlign("RIGHT")
oDevolucoes:Cell("TB_VALOR2"):SetHeaderAlign("RIGHT")
oDevolucoes:Cell("TB_VALOR3"):SetHeaderAlign("RIGHT")

oTot := TRSection():New(oReport,STR0026,{"SA3"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oTot,"TOTAIS"	,          ,STR0032,PesqPict("SD2","D2_FILIAL")	,83,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo Filial"
TRCell():New(oTot,"TB_VALOR1"	,    	,STR0019					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1] ,/*lPixel*/,/*{|| code-block de impressao }*/	)		// "Faturamento S/ ICM/IPI"
TRCell():New(oTot,"TB_VALOR2"	,     	,STR0020					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)       // "Valor da Mercadoria"
TRCell():New(oTot,"TB_VALOR3"	,   	,STR0021					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)       // "Valor Total"
oTot:Cell("TB_VALOR3"):SetHeaderAlign("RIGHT")

oTotVenda := TRSection():New(oReport,STR0026,{"SA3"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oTotVenda,"TOTAIS"	,          ,STR0034,PesqPict("SD2","D2_FILIAL")	,83,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo Filial"
TRCell():New(oTotVenda,"TB_VALOR1"	,    	,STR0019					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1] ,/*lPixel*/,/*{|| code-block de impressao }*/	)		// "Faturamento S/ ICM/IPI"
TRCell():New(oTotVenda,"TB_VALOR2"	,     	,STR0020					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)       // "Valor da Mercadoria"
TRCell():New(oTotVenda,"TB_VALOR3"	,   	,STR0021					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)       // "Valor Total"
oTotVenda:Cell("TB_VALOR3"):SetHeaderAlign("RIGHT")


oTotDevolucao := TRSection():New(oReport,STR0026,{"SA3"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oTotDevolucao,"TOTAIS"	,          ,STR0035,PesqPict("SD2","D2_FILIAL")	,83,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo Filial"
TRCell():New(oTotDevolucao,"TB_VALOR1"	,    	,STR0019					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1] ,/*lPixel*/,/*{|| code-block de impressao }*/	)		// "Faturamento S/ ICM/IPI"
TRCell():New(oTotDevolucao,"TB_VALOR2"	,     	,STR0020					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)       // "Valor da Mercadoria"
TRCell():New(oTotDevolucao,"TB_VALOR3"	,   	,STR0021					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)       // "Valor Total"
oTotDevolucao:Cell("TB_VALOR3"):SetHeaderAlign("RIGHT")

oTextDev := TRSection():New(oReport,STR0026,{"SA3"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oTextDev,"Devolucoes....."	,          ,STR0036,PesqPict("SD2","D2_FILIAL")	,120,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo Filial"

oTotGeral := TRSection():New(oReport,STR0026,{"SA3"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oTotGeral,"TOTAIS"	,           ,STR0033,PesqPict("SD2","D2_FILIAL")	,72,/*lPixel*/,/*{|| cVend }*/						)		// "Codigo Filial"
TRCell():New(oTotGeral,"TB_VALOR1"	,    	,STR0019					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1] ,/*lPixel*/,/*{|| code-block de impressao }*/	)		// "Faturamento S/ ICM/IPI"
TRCell():New(oTotGeral,"TB_VALOR2"	,     	,STR0020					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)       // "Valor da Mercadoria"
TRCell():New(oTotGeral,"TB_VALOR3"	,   	,STR0021					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)       // "Valor Total"

oTotGeral:Cell("TB_VALOR3"):SetHeaderAlign("RIGHT")
oReport:SetTotalInLine(.F.)

oSection1:SetPageBreak(.T.)
oSection1:SetTotalText(" ") 
oReport:PrintDialog()

return

Static Function ReportPrint(oReport,oFatVend)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)     
Local oTot      := oReport:Section(3)     
Local oTotVenda := oReport:Section(4)     
Local oTotGeral := oReport:Section(5)     

Local lMultVend := SuperGetMv("MV_LJTPCOM",,'1') $'23'
Local cEstoq 	:= If( (MV_PAR09 == 1),"S",If( (MV_PAR09 == 2),"N","SN" ) )
Local cDupli 	:= If( (MV_PAR08 == 1),"S",If( (MV_PAR08 == 2),"N","SN" ) )
Local lValadi	:= cPaisLoc == "MEX" .AND. VALTYPE(MV_PAR12) == "N"  .AND. MV_PAR12==1  .AND. SD2->(FieldPos("D2_VALADI")) > 0
Local nCont := 0
Local aArea := GetArea()
Private nDecs:=msdecimais(mv_par06)

oReport:SetTitle(oReport:Title() + " " + IIF(mv_par05 == 1,STR0023,STR0024) + " - "  + GetMv("MV_MOEDA"+STR(mv_par06,1)) )		// "Faturamento por Vendedor"###"(Ordem Decrescente por Vendedor)"###"(Por Ranking)"

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
    nGeralV1 := 0
    nGeralV2 := 0
    nGeralV3 := 0
    While QRY->( !EOF())
		If oReport:Cancel()
            Exit
        EndIf

        nCont +=1
        nTaxa	:=	IIf( QRY->F2_TXMOEDA > 0, QRY->F2_TXMOEDA,0)		
		nMoedNF	:=	IIf( QRY->F2_MOEDA > 0,QRY->F2_MOEDA,0)

        oSection1:Init()
        oReport:IncMeter()
        
        cVend := QRY->F2_VEND1
        IncProc("Imprimindo Vendedor "+alltrim(cVend))
        oSection1:Printline()

        oSection2:init()

        nTotVendV1 := 0
        nTotVendV2 := 0
        nTotVendV3 := 0
        While  cVend == QRY->F2_VEND1
            oReport:IncMeter()    
            nTOTAL  :=0
		    nVALICM :=0
		    nVALIPI :=0
		    nVALST  :=0
            nValor1 := 0
            nValor2 := 0
            nValor3 := 0
            
            cChave := QRY->(D2_FILIAL + D2_DOC)
            While cChave == QRY->(D2_FILIAL + D2_DOC)
                If U_RAvalTes( QRY->D2_FILIAL, QRY->D2_TES,cEstoq,cDupli) // 0 
                    nVALICM += xMoeda(QRY->D2_VALICM,1,mv_par06 ,QRY->D2_EMISSAO,nDecs+1)
                    nVALIPI += xMoeda(QRY->D2_VALIPI,1,mv_par06 ,QRY->D2_EMISSAO,nDecs+1)
                    nVALST	+= xMoeda(QRY->F2_ICMSRET,1,mv_par06,QRY->D2_EMISSAO,nDecs+1)

                    If !(QRY->F2_TIPO == "I" .AND. QRY->F2_ICMSRET > 0)
                        nTotal	+=	xMoeda(QRY->D2_TOTAL-Iif(lValadi,QRY->D2_VALADI,0),nMoedNF,mv_par06,QRY->D2_EMISSAO,nDecs+1,nTaxa)
                    EndIf	
                    If nTotal <> 0 .OR. QRY->F2_TIPO == "I" .AND. QRY->F2_ICMSRET > 0                                    
                        nValor1 := nTOTAL-nVALICM
                        nValor2 := IIF(QRY->F2_TIPO == "P",0,nTOTAL) 
                        nValor3 := IIF(QRY->F2_TIPO == "P",0,nTotal)+nVALIPI                        
                    EndIf
                Endif            	
                nAdic := 0
                If mv_par11 == 1
                    nAdic := xMoeda(QRY->F2_FRETE+QRY->F2_SEGURO+QRY->F2_DESPESA,nMoedNF,mv_par06,QRY->F2_EMISSAO,nDecs+1,nTaxa)		
                    nValor3 += nAdic
                EndIf
                nValor3  += xMoeda(QRY->F2_FRETAUT+QRY->F2_ICMSRET,nMoedNF,mv_par06,QRY->F2_EMISSAO,nDecs+1,nTaxa)		
                
                oSection2:Cell("D2_FILIAL"):SetValue(QRY->D2_FILIAL)	
                oSection2:Cell("F2_CLIENTE"):SetValue(QRY->F2_CLIENTE)	
                oSection2:Cell("F2_LOJA"):SetValue(QRY->F2_LOJA)	
                oSection2:Cell("A1_NOME"):SetValue(QRY->A1_NOME)	
                oSection2:Cell("D2_DOC"):SetValue(QRY->D2_DOC)	

                   QRY->( DbSkip())
            Enddo   
            nTotVendV1 += nValor1
            nTotVendV2 += nValor2
            nTotVendV3 += nValor3                        

            oSection2:Cell("TB_VALOR1"):SetValue(nValor1)	
            oSection2:Cell("TB_VALOR2"):SetValue(nValor2)	
            oSection2:Cell("TB_VALOR3"):SetValue(nValor3)	    
            oSection2:PrintLine()         
            
        Enddo

       
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³Processa Devolucao                                                      ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

        // Imprime total Vendas
        oTotVenda:init()
            oTotVenda:Cell("TB_VALOR1"):SetValue(nTotVendV1)	
            oTotVenda:Cell("TB_VALOR2"):SetValue(nTotVendV2)	
            oTotVenda:Cell("TB_VALOR3"):SetValue(nTotVendV3)	
            oTotVenda:PrintLine()
        oTotVenda:Finish()

	    If ( MV_PAR07 == 1 )
            nTotDev1:=0
            nTotDev2:=0
            nTotDev3:=0
            cQuery := QryDevol(cVend)
            If Select("QRYDEV") <> 0
                QRYDEV->(DbCloseArea())
            Endif
            TcQuery cQuery New Alias "QRYDEV"   

            If QRYDEV->(! EOF())
                nTotal :=0
                oTextDev:init()	
                    oTextDev:PrintLine()
                oTextDev:Finish()
                oDevolucoes:init()

                    While QRYDEV->(!EOF())
                        nTaxa	:=	IIf( QRYDEV->F2_TXMOEDA > 0, QRYDEV->F2_TXMOEDA,0)		
		                nMoedNF	:=	IIf( QRYDEV->F2_MOEDA > 0,QRYDEV->F2_MOEDA,0)
                        If U_RAvalTes( QRYDEV->D1_FILIAL, QRYDEV->D1_TES,cEstoq,cDupli) // 0 
                            nVALICM := xMoeda(QRYDEV->D1_VALICM,1,mv_par06 ,QRYDEV->D1_DTDIGIT,nDecs+1)
                            nVALIPI := xMoeda(QRYDEV->D1_VALIPI,1,mv_par06 ,QRYDEV->D1_DTDIGIT,nDecs+1)
                            nVALST	:= xMoeda(QRYDEV->F2_ICMSRET,1,mv_par06,QRYDEV->D1_DTDIGIT,nDecs+1)

                            If !(QRYDEV->F2_TIPO == "I" .AND. QRYDEV->F2_ICMSRET > 0)
                                nTotal	:=	xMoeda(QRYDEV->D1_TOTAL-Iif(lValadi,QRYDEV->D1_VALADI,0),nMoedNF,mv_par06,QRYDEV->D1_DTDIGIT,nDecs+1,nTaxa)
                            EndIf	
                            If nTotal <> 0 .OR. QRY->F2_TIPO == "I" .AND. QRY->F2_ICMSRET > 0                                    
                                nValor1 := nTOTAL-nVALICM
                                nValor2 := IIF(QRYDEV->F2_TIPO == "P",0,nTOTAL) 
                                nValor3 := IIF(QRYDEV->F2_TIPO == "P",0,nTotal)+nVALIPI                        
                            EndIf
                        Endif            	
                        nAdic := 0
                        If mv_par11 == 1
                            nAdic := xMoeda(QRYDEV->F2_FRETE+QRYDEV->F2_SEGURO+QRYDEV->F2_DESPESA,nMoedNF,mv_par06,QRYDEV->D1_DTDIGIT,nDecs+1,nTaxa)		
                            nValor3 += nAdic
                        EndIf
                        nValor3  += xMoeda(QRYDEV->F2_FRETAUT+QRYDEV->F2_ICMSRET,nMoedNF,mv_par06,QRYDEV->D1_DTDIGIT,nDecs+1,nTaxa)		
            
                        oDevolucoes:Cell("TB_VALOR1"):SetValue(nValor1)	
                        oDevolucoes:Cell("TB_VALOR2"):SetValue(nValor2)	
                        oDevolucoes:Cell("TB_VALOR3"):SetValue(nValor3)	

                        nTotVendV1 -=  nValor1
                        nTotVendV2 -=  nValor2
                        nTotVendV3 -=  nValor3
                        nTotDev1 += nValor1
                        nTotDev2 += nValor2
                        nTotDev3 += nValor3
                        oDevolucoes:PrintLine()
                        QRYDEV->( DbSkip())
                    Enddo
                oDevolucoes:Finish()
                        // Imprime total Vendas
            oTotDevolucao:init()
                oTotDevolucao:Cell("TB_VALOR1"):SetValue(nTotDev1)	
                oTotDevolucao:Cell("TB_VALOR2"):SetValue(nTotDev2)	
                oTotDevolucao:Cell("TB_VALOR3"):SetValue(nTotDev3)	
                oTotDevolucao:PrintLine()
            oTotDevolucao:Finish()

            Endif
        Endif
        //finalizo a segunda seção para que seja reiniciada para o proximo registro
        oSection2:Finish()
        nGeralV1 := nGeralV1 + nTotVendV1
        nGeralV2 := nGeralV2 + nTotVendV2
        nGeralV3 := nGeralV3 + nTotVendV3
        oTot:Cell("TB_VALOR1"):SetValue(nTotVendV1)	
        oTot:Cell("TB_VALOR2"):SetValue(nTotVendV2)	
        oTot:Cell("TB_VALOR3"):SetValue(nTotVendV3)
        oTot:Init()
            oTot:Printline()
        oTot:Finish()

        // teste

        //imprimo uma linha para separar uma NCM de outra
        oReport:ThinLine()
         //finalizo a primeira seção
        oSection1:Finish()   
        
    Enddo
    
Endif
oReport:ThinLine()
oReport:SkipLine()
oReport:SkipLine()
oTotGeral:Cell("TB_VALOR1"):SetValue(nGeralV1)	
oTotGeral:Cell("TB_VALOR2"):SetValue(nGeralV2)	
oTotGeral:Cell("TB_VALOR3"):SetValue(nGeralV3)
oTotGeral:Init()
oTotGeral:Printline()
oTotGeral:Finish()
RestArea(aArea)
return

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  ENVEMAIL     ¦ Autor ¦ Tiago Santos      ¦ Data ¦11.03.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Retorna a query com os valores Faturados                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
static Function MontaQry ()   
Local cParCFOP := GetMv( "RB_CFOPVEN" , .F. ,  ) 
Local nContC := 0
cQuery :=" SELECT  SD2.*, F2_EMISSAO, F2_TIPO, F2_DOC, F2_FRETE, F2_SEGURO, F2_DESPESA, F2_FRETAUT, F2_ICMSRET, F2_VEND1, F2_CLIENTE, "
cQuery += " F2_TXMOEDA, F2_MOEDA, A3_NOME, F2_LOJA, A1_NOME"
cQuery += " FROM " + RetSqlName("SD2") + " SD2"
cquery += " inner join " + RetSqlName("SF4") +" SF4 on F4_CODIGO  = D2_TES and F4_FILIAL = D2_FILIAL"
cQuery += " inner join " + RetSqlName("SF2") + " SF2 on "
cQuery += " D2_DOC     = F2_DOC AND D2_SERIE   = F2_SERIE 	AND "
cQuery += " D2_CLIENTE = F2_CLIENTE AND D2_LOJA    = F2_LOJA"
cQuery += " inner join " + RetSqlName("SA3") + " SA3 on "
cQuery += " F2_VEND1     = A3_COD  "
cQuery += " inner join " + RetSqlName("SA1") + " SA1 on "
cQuery += " F2_CLIENTE     = A1_COD  and D2_LOJA = A1_LOJA"
cQuery += " WHERE D2_EMISSAO between '" +  DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
cQuery += " AND D2_TIPO NOT IN ('D', 'B')"

cCFOP := "("
for nContC:= 1 to len (cParCFOP) step 5
    cCFOP += "'" +SubStr( cParCFOP,nContC,4 )+ "',"
Next nContC 
cCFOP := Left(cCFOP, Len(cCFOP) -1) // tirar a ultima virgula
cCFOP += ")"
cQuery += " AND F4_CF IN " + cCFOP 
cQuery += " AND SD2.D_E_L_E_T_ =' '"
cQuery += " AND SF2.D_E_L_E_T_ =' '"
cQuery += " AND SF4.D_E_L_E_T_ =' '"
cQuery += " AND SA3.D_E_L_E_T_ =' '"
cQuery += " AND SA1.D_E_L_E_T_ =' '"
cQuery += " AND F2_VEND1 between '" +  mv_par03 +"' AND '" + mv_par04  + "' "
cQuery += " ORDER BY F2_VEND1, D2_FILIAL, F2_CLIENTE, F2_LOJA, D2_DOC"
Return cQuery

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  ENVEMAIL     ¦ Autor ¦ Tiago Santos      ¦ Data ¦11.03.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Retorna a query com os valores de devolucao               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
static Function QryDevol (cVendedor)   

cQuery := " select 	* from " + RetSqlName("SD1") + " SD1"
cQuery += " inner join " + RetSqlName("SF2") +" SF2 on D1_NFORI = F2_DOC AND F2_SERIE   = D1_SERIORI"
cQuery += " inner join " + RetSqlName("SA1") + " SA1 on "
cQuery += " F2_CLIENTE     = A1_COD  and D1_LOJA = A1_LOJA"
cQuery += " Where SD1.D_E_L_E_T_ =' ' AND  SF2.D_E_L_E_T_ =' ' AND SA1.D_E_L_E_T_ =' ' AND  D1_TIPO = 'D' "
cQuery += " AND F2_VEND1 = '" + cVendedor + "'"
cQuery += " AND D1_DTDIGIT between '" +  DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "

cQuery += " ORDER BY D1_FILIAL, F2_CLIENTE, F2_LOJA, D1_DOC"
Return cQuery


user Function RAvalTes( cFilVenda, cTes,cEstoq,cDupli )

Local lRet   := .F.,;
	cAlias := ""

If !((cAlias := Alias()) == "SF4")
	DbSelectArea( "SF4" )
Endif

If (cFilVenda + cTes == SF4->F4_FILIAL+SF4->F4_CODIGO) .Or. DbSeek( cFilVenda + cTes,.F. )
	Do Case
	Case (cEstoq # NIL) .And. (cDupli # NIL)
		lRet := ((SF4->F4_ESTOQUE $ cEstoq) .And. (SF4->F4_DUPLIC $ cDupli))
	Case (cDupli == NIL) .And. (cEstoq # NIL)
		lRet := (SF4->F4_ESTOQUE $ cEstoq)
	Case (cEstoq == NIL) .And. (cDupli # NIL)
		lRet := (SF4->F4_DUPLIC $ cDupli)
	EndCase
EndIf

If !(cAlias == "SF4")
	DbSelectArea( cAlias )
EndIf

Return( lRet )

