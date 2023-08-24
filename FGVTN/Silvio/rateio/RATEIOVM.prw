#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "MsOle.ch"
#Include "Report.ch"
#Include "Protheus.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "FWPrintSetup.ch" 
#include "topconn.ch"
#include "tbiconn.ch"


User Function RATEIOVM() 

	Local cTitle    := OemToAnsi("Rateio Vale Mercado")
	Local cHelp     := OemToAnsi("Rateio Vale Mercado")
	Local aOrdem 	:= {"Matrícula + Pagamento","Nome"}
	Local oRel
	Local oDados
	Local cPerg := "RATEIOVM"
	Private lNivel	:= .F.


cPerg := PadR(cPerg,10," ")

VldPerg(cPerg)

if (!Pergunte(cPerg,.T.) )
	return
else
	cPer1   := SubStr(DTOS(MV_PAR01),1,6)
	cFil1   := MV_PAR02
	cFil2   := MV_PAR03
Endif


	//Título do relatório no cabeçalho
	cTitle := OemToAnsi("Rateio Vale Mercado")


	//Criacao do componente de impressão
	oRel := tReport():New("RATEIOVM",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)
	oRel:SetTotalInLine(.t.)


	//Seta a orientação do papel
	oRel:SetLandscape()               
	oRel:SetDevice(4)       

	//Inicia a Sessão
	oDados := trSection():New(oRel,cTitle,{},aOrdem)  
	//oDados:HeaderBreak()
	oDados:SetHeaderBreak()

	//Define o cabeçalho
	trCell():New(oDados,"PERREL"	 ,"QRY",  "Período" ,"@!",10)
	trCell():New(oDados,"FILIAL"     ,"QRY",  "FILIAL"   ,"@!",10)
	trCell():New(oDados,"CCUSTO"	 ,"QRY",  "C.Custo" ,"@!",10)
	trCell():New(oDados,"DESCCC"     ,"QRY",  "Desc. C.Custo"  ,"@!",60)
	trCell():New(oDados,"RATEIO"     ,"QRY",  "Valor Rateio"  ,"@E 999,999.99",20,,,"RIGHT",,"RIGHT")
	trCell():New(oDados,"PERC"       ,"QRY",  "Percentual"  ,"@E 999,999.99",20,,,"RIGHT",,"RIGHT")


	//TRFunction():New(oDados:Cell("RATEIO"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oDados:Cell("RATEIO"),,"SUM",,"Total Geral",,,.F.,.T.,.F.,oDados)

	// Total de Funcionários por Filial

	//oBreak := TRBreak():New(oDados,oDados:Cell("FILIAL"),"TOTAL: "  )
	//TRFunction():New(oDados:Cell("RATEIO"),NIL,"SUM",oBreak,,,,.F.,.F.) 
	//TRFunction():New(oDados:Cell("PERC"),NIL,"SUM",oBreak,,,,.F.,.F.) 

	//DEFINE FUNCTION FROM oDados:Cell("RA_MAT")		FUNCTION COUNT NO END SECTION
	//Executa o relatório
	oRel:PrintDialog()

Return


/*-----------------+---------------------------------------------------------+
!Nome              ! ReportPrint                                             !
+------------------+---------------------------------------------------------+
!Descrição         ! Processamento dos dados e impressao do relatório        !
+------------------+---------------------------------------------------------+
!Autor             ! Silvio                                                  !
+------------------+--------------------------------------------------------*/
Static Function ReportPrint(oRel)

	Local oDados  	:= oRel:Section(1)
	Local nOrdem  	:= oDados:GetOrder()
	Local cFilDe	:= ""
	Local cFilAte	:= ""
	Local cCustoDe	:= ""
	Local cCustoAte	:= ""
	Local cMatriDe	:= ""
	Local cMatriAte	:= ""
	Local cSituac	:= ""
	Local cCateg	:= ""
	Local cOrdem	:= ""
	Local cSitQuery	:= ""
	Local cCatQuery	:= ""
	Local cCodCC	:= "" 
	Local cCodFil   := ""
	Local nVlrRef	:= ""
	Local nPercent	:= ""           
	Private _aErros   := {}

	//oDados:SetTotalInLine()
	oDados:Init()


	//Seleciona os registros
	//********************************************************************************

cPer  := SubStr(dToS(mv_par01),1,6)
cFil1 := mv_par02
cFil2 := mv_par03

	If Select("QRY") > 0         
		QRY->(dbCloseArea())
	Endif              

cQuery:="	WITH GERAL AS	"
cQuery+="	(	"
cQuery+="	SELECT	"
cQuery+="	RC_FILIAL FILIAL,	"
cQuery+="	RC_PERIODO PERIODO,	"
cQuery+="	SUBSTRING(RC_PERIODO,5,2)+'/'+SUBSTRING(RC_PERIODO,1,4) PERREL,	"
cQuery+="	RC_CC CCUSTO,	"
cQuery+="	CTT_DESC01 DESCCC,	"
cQuery+="	SUM(RC_VALOR) RATEIO	"
cQuery+="	FROM SRC010 SRC	"
cQuery+="	INNER JOIN CTT010 CTT ON CTT_CUSTO = RC_CC AND CTT.D_E_L_E_T_ = ' '	"
cQuery+="	WHERE	"
cQuery+="	RC_PD IN ('479','460','865') AND	"
cQuery+="	SRC.D_E_L_E_T_ = ' ' AND	"
cQuery+="	RC_PERIODO = '"+cPer1+"' AND	"
cQuery+="	RC_FILIAL BETWEEN '"+cFil1+"' AND '"+cFil2+"' 	"
cQuery+="	GROUP BY	"
cQuery+="	RC_FILIAL,	"
cQuery+="	RC_PERIODO,	"
cQuery+="	RC_CC,	"
cQuery+="	CTT_DESC01	"
cQuery+="	), TOTAL AS	"
cQuery+="	(	"
cQuery+="	SELECT	"
//cQuery+="	FILIAL,	"
cQuery+="	PERIODO,	"
cQuery+="	SUM(RATEIO) TOTAL	"
cQuery+="	FROM GERAL	"
cQuery+="	GROUP BY	"
//cQuery+="	FILIAL,	"
cQuery+="	PERIODO	"
cQuery+="	)	"
cQuery+="	SELECT 	"
cQuery+="	GERAL.FILIAL,	"
cQuery+="	GERAL.PERIODO,	"
cQuery+="	GERAL.PERREL,	"
cQuery+="	CCUSTO,	"
cQuery+="	DESCCC,	"
cQuery+="	GERAL.RATEIO, "
cQuery+="	ROUND((RATEIO / TOTAL * 100),2) PERC	"
cQuery+="	FROM GERAL	"
cQuery+="	LEFT JOIN TOTAL ON TOTAL.PERIODO = GERAL.PERIODO " // AND TOTAL.FILIAL = GERAL.FILIAL	"
cQuery+="	ORDER BY 1,4 "


	TcQuery cQuery New Alias "QRY"

	nQtd := 0

	If QRY->(!Eof())
		While QRY->(!Eof()) .and. !oRel:Cancel()  

			//Cancelado pelo usuário
			If oRel:Cancel()
				Exit                 
			EndIf

			oRel:IncMeter(10)		

			//oDados:Cell("ZCS_CPF"):Disable()

			oDados:PrintLine()

			cMat  := QRY->FILIAL   	

			nQtd++
			QRY->(dbSkip())

		End
		//oRel:SkipLine(1)
		//oRel:PrintText("Total de funcionários: "+cvaltochar(nQtd))
		nQtd:= 0 
	Else
		MsgInfo("Não foram encontrados registros para os parâmetros informados!")
		Return .F.
	Endif

	oDados:Finish()

Return



Static Function VldPerg(cPerg)

Local aPerg  := {}

aAdd( aPerg , { "01", "Período De           	      " , "mv_ch1" ,  "D",  8,  0 ,"MV_PAR01","G" ," ", " "  ," " 	," "	,"  " ,"   "} )
aAdd( aPerg , { "02", "Filial De	                  " , "mv_ch2" ,  "C",  2 , 0 ,"MV_PAR02","C" ,"SM0", " "  ,""	," "	,"  " ,"   "} )
aAdd( aPerg , { "03", "Filial Até	                  " , "mv_ch3" ,  "C",  2 , 0 ,"MV_PAR03","C" ,"SM0", " "  ,""	," "	,"  " ,"   "} )
/*
aAdd( aPerg , { "03", "Matricula De	                  " , "mv_ch3" ,  "C",  6 , 0 ,"MV_PAR03","C" ,"SRA", " "  ,""	," "	,"  " ,"   "} )
aAdd( aPerg , { "04", "Matricula Até	              " , "mv_ch4" ,  "C",  6 , 0 ,"MV_PAR04","C" ,"SRA", " "  ,""	," "	,"  " ,"   "} )
aAdd( aPerg , { "05", "CC De           	              " , "mv_ch5" ,  "C",  9,  0 ,"MV_PAR05","C" ,"CTT", " "  ," " 	," "	,"  " ,"   "} )
aAdd( aPerg , { "06", "CC Até                         " , "mv_ch6" ,  "C",  9,  0 ,"MV_PAR06","C" ,"CTT", " "  ," " 	," "	,"  " ,"   "} )
aAdd( aPerg , { "08", "Período Até                    " , "mv_ch8" ,  "D",  8,  0 ,"MV_PAR08","G" ," ", " "  ," " 	," "	,"  " ,"   "} )
aAdd( aPerg , { "09", "Verbas                         " , "mv_ch9" ,  "C", 20,  0 ,"MV_PAR09","C" ," ", " "  ," " 	," "	,"  " ,"   "} )
aAdd( aPerg , { "10", "Imprimir Folha                 " , "mv_ch10",  "N",  1,  0 ,"MV_PAR10","C" ," ","Folha Aberta","Folha Fechada","","",""} )
*/

// Compatibiliza com tamanho do SX1
cPerg := cPerg+Space( Len(Sx1->x1_grupo) - Len(cPerg) )

DbSelectArea("SX1")
DbSetOrder(1)
For nN := 1 To Len( aPerg )
	If !DbSeek( cPerg  + aPerg[nn,1] )
		RecLock("SX1",.T.)
		Replace X1_GRUPO   With cPerg,;
		X1_ORDEM   With aPerg[nn,01],;
		X1_PERGUNT With aPerg[nn,02], X1_VARIAVL With aPerg[nn,03],;
		X1_TIPO    With aPerg[nn,04], X1_TAMANHO With aPerg[nn,05],;
		X1_DECIMAL With aPerg[nn,06], X1_VAR01   With aPerg[nn,07],;
		X1_GSC     With aPerg[nn,08], X1_F3      With aPerg[nn,09],;
		X1_Def01   With aPerg[nn,10], X1_Def02   With aPerg[nn,11],;
		X1_Def03   With aPerg[nn,12], X1_Def04   With aPerg[nn,13],;
		X1_Def05   With aPerg[nn,14]
		MsUnlock()
	EndIf
Next

Return
