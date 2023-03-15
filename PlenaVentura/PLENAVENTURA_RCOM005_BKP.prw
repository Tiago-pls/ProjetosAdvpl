#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*__________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  ValPoten   - Autor - Tiago Santos      - Data -02.02.23   ---
--+----------+---------------------------------------------------------------
---Descri--o -  Relatório para geração dos valores vendidos e potencias    ---
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
oSection2 := trSection():New(oRel,cTitle,{"SF2","SD2","SA3"},aOrdem)
oSection3 := trSection():New(oRel,cTitle,{"SF2","SD2","SA3"},aOrdem)
//oDados:SetHeaderSection(.F.)    
//oDados:HeaderBreak()     
oSection1:SetHeaderBreak() 

// Defini--o das colunas a serem impressas no relat-rio

	TRCell():New(oSection1,"F1_FILIAL"	, "QRY", "Filial")
	TRCell():New(oSection1,"F1_DTDIGIT" , "QRY", "Dt Digitacao")
	TRCell():New(oSection1,"F1_DOC"		, "QRY", "Documento")
	TRCell():New(oSection1,"F1_SERIE"	, "QRY", "Serie")
	TRCell():New(oSection1,"F1_FORNECE" , "QRY", "Fornecedor")
	TRCell():New(oSection1,"F1_LOJA"	, "QRY", "Loja")
	TRCell():New(oSection1,"NOME"		, "QRY", "Nome",,40)
	TRCell():New(oSection1,"F1_VALBRUT" , "QRY", "Valor Bruto")
	TRCell():New(oSection1,"Y1_NOME"    , "SY1", "Comprador")
	TRFunction():New(oSection1:Cell("F1_DOC"),,"COUNT",,"QUANTIDADE",,,.F.,.T.,.F.,oSection1)
	TRFunction():New(oSection1:Cell("F1_VALBRUT"),,"SUM",,"VALOR TOTAL",,,.F.,.T.,.F.,oSection1)

	trCell():New(oSection2,"E2_NUM","QR2" ,  ,"@!",TamSx3("E5_NUMERO")[1])
	trCell():New(oSection2,"E2_VENCREA","QR2" ,  ,"@!",TamSx3("E5_NUMERO")[1])
	trCell():New(oSection2,"IMPOSTO","QR2" ,  ,"@!",TamSx3("E5_NUMERO")[1])
	trCell():New(oSection2,"E2_VALOR","QR2" ,  ,"@E 999,999,999.99",17)
	
	trCell():New(oSection3,"LIQ","QR2" ,  ,"@E 999,999,999.99",17)
	
//Executa o relatorio
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
Local oSection2  	:= oRel:Section(2)
Local oSection3  	:= oRel:Section(3)
//Local nOrdem  	:= oDados:GetOrder()



//Seleciona os registros
//********************************************************************************
If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif
cQry := MontaQry()
TcQuery cQry New Alias "QRY"                          

TCSetField("QRY","F1_DTDIGIT","D",8,0)  
nCont := 0
If QRY->(!Eof())
	While QRY->(!Eof()) .and. !oRel:Cancel() 
  		ProcRegua(10)
  		nCont ++
		 MsProcTxt("Analisando registro " )		 
		//Cancelado pelo usuario
		If oRel:Cancel()
			Exit
		EndIf   
		oSection1:Init()		
  		oRel:IncMeter(10)   
		If QRY->F1_TIPO $ ('BD')
			cForCli := Posicione("SA1",1,xFilial("SA1")+QRY->F1_FORNECE+QRY->F1_LOJA,"A1_NOME")
			cComprador := ""
		Else
			cForCli := Posicione("SA2",1,xFilial("SA2")+QRY->F1_FORNECE+QRY->F1_LOJA,"A2_NOME")
			SD1->( dbSetOrder(1) )
			SD1->( dbSeek(QRY->F1_FILIAL + QRY->F1_DOC + QRY->F1_SERIE + QRY->F1_FORNECE + QRY->F1_LOJA) )
			SC7->( dbSetOrder(1) )
			SC7->( dbSeek(SD1->D1_FILIAL + SD1->D1_PEDIDO + SD1->D1_ITEMPC) )
			SY1->( DbSetOrder(3) )
			SY1->( DbSeek( xFilial('SY1') + SC7->C7_USER ) )
			cComprador := SY1->Y1_NOME
		EndIf
		nValorLiq :=QRY->( F1_VALBRUT - F1_IRRF - F1_VALPIS - F1_VALCOFI - F1_VALCSLL)
		oSection1:Cell("NOME"):SetValue(cForCli)
  		oSection1:PrintLine()
		oSection2:init() 
		cQuerySe2 :="select E2_NUM, E2_VENCREA, E2_VALOR, ED_DESCRIC from " + RetSqlName("SE2") + " SE2"+ cLFRC
		cQuerySe2 +=" inner join "+ RetSqlName("SED") +" SED  on E2_NATUREZ = ED_CODIGO and SED.D_E_L_E_T_=' ' "+ cLFRC
		
		cQuerySe2 += " Where SE2.D_E_L_E_T_ =' ' and  E2_FILIAL = '"+QRY->F1_FILIAL+"' and E2_NUM =  '" +QRY->F1_DOC+"' "+ cLFRC
		//cQuerySe2 += " and E2_TIPO ='TX' and E2_FORNECE = '" + QRY->F1_FORNECE +"' and E2_LOJA ='" +QRY->F1_LOJA+ "'"+ cLFRC
		cQuerySe2 += " and E2_TIPO ='TX' "+ cLFRC
		If Select("QR2")>0         
			QR2->(dbCloseArea())
		Endif
		TcQuery cQuerySe2 New Alias "QR2"  
		TCSetField("QR2","E2_VENCREA","D",8,0)  
		While QR2->(!Eof())			

			oSection2:Cell("IMPOSTO"):SetValue(Alltrim(QR2->ED_DESCRIC))					
			oSection2:PrintLine()	
			QR2->( DbSkip())
		Enddo
		oSection2:Finish()
		oSection3:Init()	
		oSection3:Cell("LIQ"):SetValue(nValorLiq)
		oSection3:PrintLine()
		oSection3:Finish()	

		oRel:Skipline()
     //   oSection1:SetHeaderSection(.F.)
	QRY->(dbSkip())			
	oSection1:Finish()		
	Enddo	
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
CheckSx1(cPerg, '08', '1º Vencimento Ate?', '', '', 'mv_ch8', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par08')

Return

// fun--o para retornar a query conforme tipo do relat-rio selecionado
static Function MontaQry ()                                   
Local cQuery := " " 

cQuery += "	SELECT F1_FILIAL, F1_DTDIGIT, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_VALBRUT,F1_TIPO, F1_P1VENC, F1_PREFIXO, F1_IRRF, F1_VALPIS, F1_VALCOFI, F1_VALCSLL"+ cLFRC
cQuery += "	FROM " + RetSqlName('SF1') +" SF1"+ cLFRC
cQuery += " Where F1_DOC >= '" +MV_PAR01+ "'"+ cLFRC
cQuery += "	     AND F1_DOC <= '" + MV_PAR02 + "'"      + cLFRC
cQuery += "	     AND F1_DTDIGIT	>= '" + DtoS(MV_PAR03) + "'"  + cLFRC
cQuery += "	     AND F1_DTDIGIT	<= '" + DtoS(MV_PAR04) + "'"  + cLFRC
cQuery += "	     AND F1_FORNECE	>= '" + MV_PAR05 + "'"  + cLFRC
cQuery += "	     AND F1_FORNECE	<= '" + MV_PAR06 + "'"  + cLFRC
cQuery += "	     AND SF1.D_E_L_E_T_ =' ' "  + cLFRC

return cQuery
