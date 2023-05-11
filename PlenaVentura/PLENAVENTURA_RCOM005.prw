#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*___________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  RCOM005    - Autor - Tiago Santos      - Data -02.02.23   ---
--+----------+---------------------------------------------------------------
---Descri--o -  Documento de entrada e títulos relacionados               ---
--+-----------------------------------------------------------------------+--
--+-----------------------------------------------------------------------+--
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/

User Function RCOM005
                      
Private cPerg := 'RPLENAX001'
Private cLFRC	:= chr(13)+chr(10)

criaSx1(cPerg)
Pergunte(cPerg, .F.)
MsAguarde({|| GeraRel()}, "Aguarde...", "Gerando Registros...")
Return

/*__________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  GeraRel    - Autor - Tiago Santos        - Data -06.04.22 ---
--+----------+---------------------------------------------------------------
---Descri--o -  Gera o Relat-io                              		      ---
--+-----------------------------------------------------------------------+--
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/

static function GeraRel()
Local cTitle    := OemToAnsi("Relat-rio Conferencia ")
Local cHelp     := OemToAnsi("Relat-rio Conferencia ")   
Local aOrdem 	:= {}                
Local oRel
Local oSection1             
Local oSection2

//T-tulo do relat-rio no cabe-alho
cTitle := OemToAnsi("Relatorio valores faturados")

//Criacao do componente de impress-o
oRel := tReport():New("Relatorio valores faturados",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)

//Seta a orienta--o do papel
oRel:SetLandscape()

//Seta impress-o em planilha                      
oRel:SetDevice(4)    

//Inicia a Sess-o
oSection1 := trSection():New(oRel,cTitle,{"SF2","SD2","SA3"},aOrdem)
//oSection2 := trSection():New(oRel,cTitle,{"SF2","SD2","SA3"},aOrdem)   
oSection1:SetHeaderBreak() 
//oSection2:SetHeaderSection(.F.)

	TRCell():New(oSection1,"F1_FILIAL"	, "QRY", "Filial")
	TRCell():New(oSection1,"F1_EMISSAO" , "QRY", "Dt Emissão")	
	TRCell():New(oSection1,"F1_DTDIGIT" , "QRY", "Dt Digitacao")
	TRCell():New(oSection1,"F1_DOC"		, "QRY", "Documento")
	TRCell():New(oSection1,"F1_SERIE"	, "QRY", "Serie")
	TRCell():New(oSection1,"CC"	        , "QRY", "C.Custo")
	TRCell():New(oSection1,"F1_FORNECE" , "QRY", "Fornecedor")
	TRCell():New(oSection1,"F1_LOJA"	, "QRY", "Loja")
	TRCell():New(oSection1,"NOME"		, "QRY", "Nome",,40)	
	TRCell():New(oSection1,"LIQUIDO"    , "SE2", "Valor Liquido")	
	TRCell():New(oSection1,"Y1_NOME"    , "SY1", "Comprador")
	TRCell():New(oSection1,"F1_P1VENC"  , "QRY", "Vencimento")

	//TRFunction():New(oSection1:Cell("F1_DOC"),,"COUNT",,"QUANTIDADE",,,.F.,.T.,.F.,oSection1)
	//TRFunction():New(oSection1:Cell("LIQUIDO"),,"SUM",,"VALOR TOTAL",,,.F.,.T.,.F.,oSection1)

	oSection1:SetPageBreak(.T.)
oRel:PrintDialog()

Return

/*-----------------+---------------------------------------------------------+
!Nome              ! ReportPrint                                             !
+------------------+---------------------------------------------------------+
!Descri--o         ! Processamento dos dados e impressao do relat-rio        !
+------------------+---------------------------------------------------------+
!Autor             ! Lucilene Mendes	                                     !
+------------------+--------------------------------------------------------*/
Static Function ReportPrint(oRel)

Local oSection1  	:= oRel:Section(1)
//Local oSection2  	:= oRel:Section(2)

//Seleciona os registros
//********************************************************************************
If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif
cQry := MontaQry()
TcQuery cQry New Alias "QRY"                          

TCSetField("QRY","F1_DTDIGIT","D",8,0)  
TCSetField("QRY","F1_EMISSAO","D",8,0)  
TCSetField("QRY","F1_P1VENC","D",8,0)  
nCont := 0
nValTotal := 0
If QRY->(!Eof())
	While QRY->(!Eof()) .and. !oRel:Cancel() 
  		ProcRegua(10)
  		nCont ++
		
		 MsProcTxt("Analisando registro " )		 
		If oRel:Cancel()
			Exit
		EndIf   
		oSection1:Init()		
  		oRel:IncMeter(10)   
		cCC :=""
		If QRY->F1_TIPO $ ('BD')
			cForCli := Posicione("SA1",1,xFilial("SA1")+QRY->F1_FORNECE+QRY->F1_LOJA,"A1_NOME")
			cComprador := ""
		Else
			cForCli := Posicione("SA2",1,xFilial("SA2")+QRY->F1_FORNECE+QRY->F1_LOJA,"A2_NOME")
			SD1->( dbSetOrder(1) )
			SD1->( dbSeek(QRY->F1_FILIAL + QRY->F1_DOC + QRY->F1_SERIE + QRY->F1_FORNECE + QRY->F1_LOJA) )
			SC7->( dbSetOrder(1) )
			cCC := SD1->D1_CC
			SC7->( dbSeek(SD1->D1_FILIAL + SD1->D1_PEDIDO + SD1->D1_ITEMPC) )
			SY1->( DbSetOrder(3) )
			SY1->( DbSeek( xFilial('SY1') + SC7->C7_USER ) )
			cComprador := SY1->Y1_NOME
		EndIf
		nValorLiq :=QRY->( F1_VALBRUT - F1_IRRF - F1_VALPIS - F1_VALCOFI - F1_VALCSLL)
		nValTotal += nValorLiq
		oSection1:Cell("NOME"):SetValue(cForCli)
		oSection1:Cell("LIQUIDO"):SetValue(nValorLiq)
		oSection1:Cell("F1_FILIAL"):SetValue(QRY->F1_FILIAL)
		oSection1:Cell("F1_FORNECE"):setValue(QRY->F1_FORNECE)
		oSection1:Cell("F1_LOJA"):setValue(QRY->F1_LOJA)
		oSection1:Cell("F1_P1VENC"):setValue(QRY->F1_P1VENC)
		oSection1:Cell("F1_DOC"):setValue(QRY->F1_DOC)
		oSection1:Cell("CC"):setValue(cCC)
		oSection1:Cell("Y1_NOME"):setValue( Alltrim(cComprador))
		oSection1:Cell("F1_EMISSAO"):setValue(QRY->F1_EMISSAO)
		oSection1:Cell("F1_DTDIGIT"):setValue(QRY->F1_DTDIGIT)
		oSection1:Cell("F1_SERIE"):setValue(QRY->F1_SERIE)
		
  		oSection1:PrintLine()
		
		cQuerySe2 :="select E2_FILIAL, E2_NUM, E2_VENCREA, E2_VALOR, ED_DESCRIC, E2_FORNECE, E2_LOJA from " + RetSqlName("SE2") + " SE2"+ cLFRC
		cQuerySe2 +=" inner join "+ RetSqlName("SED") +" SED  on E2_NATUREZ = ED_CODIGO and SED.D_E_L_E_T_=' ' "+ cLFRC		
		cQuerySe2 += " Where SE2.D_E_L_E_T_ =' ' and  E2_FILIAL = '"+QRY->F1_FILIAL+"' and E2_NUM =  '" +QRY->F1_DOC+"' "+ cLFRC
		cQuerySe2 += " and E2_TIPO in ('TX','INS') and E2_PREFIXO ='"+QRY->F1_SERIE+"' "+ cLFRC	

		If Select("QR2")>0         
			QR2->(dbCloseArea())
		Endif
		TcQuery cQuerySe2 New Alias "QR2"  
		TCSetField("QR2","E2_VENCREA","D",8,0) 
		nTotal := 0
		While QR2->(!Eof())			
			nTotal += QR2->E2_VALOR
			oSection1:Cell("F1_FILIAL"):setValue(QR2->E2_FILIAL)
			oSection1:Cell("F1_FORNECE"):setValue(QR2->E2_FORNECE)
			oSection1:Cell("F1_LOJA"):setValue(QR2->E2_LOJA)			
			oSection1:Cell("NOME"):setValue(Alltrim(QR2->ED_DESCRIC))
			oSection1:Cell("LIQUIDO"):setValue(QR2->E2_VALOR)
			oSection1:Cell("F1_P1VENC"):setValue(QR2->E2_VENCREA)
			oSection1:Cell("F1_DOC"):setValue(QR2->E2_NUM)
			oSection1:PrintLine()
			QR2->( DbSkip())
		Enddo
		oSection1:Cell("F1_FILIAL"):SetValue(' ')
		oSection1:Cell("F1_FORNECE"):setValue(' ')
		oSection1:Cell("F1_LOJA"):setValue(' ')
		oSection1:Cell("F1_P1VENC"):setValue(' ')
		oSection1:Cell("F1_DOC"):setValue(' ')
		oSection1:Cell("Y1_NOME"):setValue(' ')
		oSection1:Cell("F1_EMISSAO"):setValue(' ')
		oSection1:Cell("F1_DTDIGIT"):setValue(' ')
		oSection1:Cell("F1_SERIE"):setValue(' ')
		oSection1:Cell("CC"):setValue(' ')
	
		oSection1:Cell("NOME"):setValue('* Total Imposto')
		oSection1:Cell("LIQUIDO"):setValue(nTotal)
		oSection1:PrintLine()	

        oSection1:SetHeaderSection(.F.)
		oSection1:Finish()	
	QRY->(dbSkip())					
	Enddo	
	oRel:printtext("Total Geral")  
	oRel:printtext("QUANTIDADE: "+ cValToChar(nCont) )  
	oRel:printtext("VALOR TOTAL: "+ cValToChar(nValTotal) )  
Else		
	MsgInfo("Nao foram encontrados registros para os parametros informados!")
    Return .F.
Endif
		
Return

/*__________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  GeraPerg     - Autor - Tiago Santos      - Data -18.09.19 ---
--+----------+---------------------------------------------------------------
---Descri--o -  Atualiza SX1                                		      ---
--+-----------------------------------------------------------------------+--
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/

static function criaSX1(cPerg)

CheckSx1(cPerg, '01', 'Documento De?' 		, '', '', 'mv_ch1', 'C', 9, 0, 0, 'G', '', 'SF1', '', '', 'mv_par01')
CheckSx1(cPerg, '02', 'Documento Ate?'		, '', '', 'mv_ch2', 'C', 9, 0, 0, 'G', '', 'SF1', '', '', 'mv_par02')
CheckSx1(cPerg, '03', 'Dt Digitacao De?'    , '', '', 'mv_ch3', 'D', tamSx3("F1_DTDIGIT")[1], 0, 0, 'G', '', '', '', '', 'mv_par03')
CheckSx1(cPerg, '04', 'Dt Digitacao Ate?'  	, '', '', 'mv_ch4', 'D', tamSx3("F1_DTDIGIT")[1], 0, 0, 'G', '', '', '', '', 'mv_par04')
CheckSx1(cPerg, '05', 'Fornecedor De?' 		, '', '', 'mv_ch5', 'C', 6, 0, 0, 'G', '', 'A2A', '', '', 'mv_par05')
CheckSx1(cPerg, '06', 'Fornecedor Ate?'		, '', '', 'mv_ch6', 'C', 6, 0, 0, 'G', '', 'A2A', '', '', 'mv_par06')
CheckSx1(cPerg, '07', '1º Vencimento De?'	, '', '', 'mv_ch7', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par07')
CheckSx1(cPerg, '08', '1º Vencimento Ate?'  , '', '', 'mv_ch8', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par08')

Return

static Function MontaQry ()                                   
Local cQuery := " " 

cQuery += "	SELECT F1_FILIAL, F1_EMISSAO, F1_DTDIGIT, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_VALBRUT,F1_TIPO,  F1_PREFIXO, F1_IRRF, F1_VALPIS, F1_VALCOFI, F1_VALCSLL,  F1_P1VENC"+ cLFRC
cQuery += "	FROM " + RetSqlName('SF1') +" SF1"+ cLFRC
cQuery += " Where F1_DOC >= '" +MV_PAR01+ "'"+ cLFRC
cQuery += "	     AND F1_DOC <= '" + MV_PAR02 + "'"      + cLFRC
cQuery += "	     AND F1_DTDIGIT	>= '" + DtoS(MV_PAR03) + "'"  + cLFRC
cQuery += "	     AND F1_DTDIGIT	<= '" + DtoS(MV_PAR04) + "'"  + cLFRC
cQuery += "	     AND F1_FORNECE	>= '" + MV_PAR05 + "'"  + cLFRC
cQuery += "	     AND F1_FORNECE	<= '" + MV_PAR06 + "'"  + cLFRC
cQuery += "	     AND SF1.D_E_L_E_T_ =' ' "  + cLFRC

return cQuery
