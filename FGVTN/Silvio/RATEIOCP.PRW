#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "MsOle.ch"
#Include "Report.ch"
#Include "Protheus.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "FWPrintSetup.ch" 
#include "topconn.ch"
#include "tbiconn.ch"


User Function RATEIOCP() 

	Local cTitle    := OemToAnsi("Rateio Co-Participação")
	Local cHelp     := OemToAnsi("Rateio Co-Participação")
	Local aOrdem 	:= {"Matrícula + Pagamento","Nome"}
	Local oRel
	Local oDados
	Local cPerg := "RATEIOCP"
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
	cTitle := OemToAnsi("Rateio Co-Participação")


	//Criacao do componente de impressão
	oRel := tReport():New("RATEIOCP",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)
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

	// Total de Funcionários por Filial

	oBreak := TRBreak():New(oDados,oDados:Cell("FILIAL"),"TOTAL: "  )
	TRFunction():New(oDados:Cell("RATEIO"),NIL,"SUM",oBreak,,,,.F.,.F.) 
	TRFunction():New(oDados:Cell("PERC"),NIL,"SUM",oBreak,,,,.F.,.F.) 

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
cForn := mv_par04

	If Select("QRY") > 0         
		QRY->(dbCloseArea())
	Endif              

IF cForn = "001"

cQuery:="	WITH GERAL AS	"
cQuery+="	(	"
cQuery+="	SELECT	"
cQuery+="	RA_FILIAL FILIAL,	"
cQuery+="	SUBSTRING(RHO_DTOCOR,1,6) PERIODO,	"
cQuery+="	SUBSTRING(RHO_DTOCOR,5,2)+'/'+SUBSTRING(RHO_DTOCOR,1,4) PERREL,	"
cQuery+="	RA_CC CCUSTO,	"
cQuery+="	CTT_DESC01 DESCCC,	"
cQuery+="	ROUND(SUM(RHO_VLRFUN+RHO_VLREMP),2) RATEIO	"
cQuery+="	FROM RHO010 RHO	"
cQuery+="	INNER JOIN SRA010 SRA ON RA_FILIAL = RHO_FILIAL AND RA_MAT = RHO_MAT AND SRA.D_E_L_E_T_ = ' '	"
cQuery+="	INNER JOIN CTT010 CTT ON CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = ' '	"
cQuery+="	WHERE	"
cQuery+="	SUBSTRING(RHO_DTOCOR,1,6) = '"+cPer1+"' AND	"
cQuery+="	RA_FILIAL BETWEEN '"+cFil1+"' AND '"+cFil2+"' AND 	"
cQuery+="	RHO.D_E_L_E_T_ = ' '	"
cQuery+="	GROUP BY 	"
cQuery+="	RA_CC, CTT_DESC01, RA_FILIAL, SUBSTRING(RHO_DTOCOR,1,6)	, SUBSTRING(RHO_DTOCOR,5,2)+'/'+SUBSTRING(RHO_DTOCOR,1,4)	"
cQuery+="	), TOTAL AS	"
cQuery+="	(	"
cQuery+="	SELECT	"
cQuery+="	PERIODO,	"
cQuery+="	SUM(RATEIO) TOTAL	"
cQuery+="	FROM GERAL	"
cQuery+="	GROUP BY	"
cQuery+="	PERIODO	"
cQuery+="	)	"
cQuery+="	SELECT	"
cQuery+="	GERAL.FILIAL,	"
cQuery+="	GERAL.PERIODO,	"
cQuery+="	PERREL,	"
cQuery+="	CCUSTO,	"
cQuery+="	DESCCC,	"
cQuery+="	RATEIO,	"
cQuery+="	ROUND((RATEIO / TOTAL * 100),2) PERC	"
cQuery+="	FROM GERAL	"
cQuery+="	LEFT JOIN TOTAL ON TOTAL.PERIODO = GERAL.PERIODO 	"
cQuery+="	ORDER BY 1,4	"

ELSE

cQuery:="	WITH GERAL AS	"
cQuery+="	(	"
cQuery+="	SELECT 	"
cQuery+="	RCC_FIL FILIAL,	"
cQuery+="	RCC_CHAVE PERIODO,	"
cQuery+="	SUBSTRING(RCC_CHAVE,5,2)+'/'+SUBSTRING(RCC_CHAVE,1,4) PERREL,	"
cQuery+="	RA_CC CCUSTO,	"
cQuery+="	CTT_DESC01 DESCCC,	"
cQuery+="	ROUND(SUM(CAST(RTRIM(SUBSTRING(RCC_CONTEU,10,12)) AS FLOAT)),2) RATEIO	"
cQuery+="	FROM RCC010 RCC	"
cQuery+="	INNER JOIN SRA010 SRA ON RA_FILIAL = RCC_FIL AND RA_MAT = SUBSTRING(RCC_CONTEU,1,6) AND SRA.D_E_L_E_T_ = ' '	"
cQuery+="	INNER JOIN CTT010 CTT ON CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = ' '	"
cQuery+="	WHERE	"
cQuery+="	RCC_CHAVE = '"+cPer1+"'AND	"
cQuery+="	RCC_FIL BETWEEN '"+cFil1+"' AND '"+cFil2+"' AND 	"
cQuery+="	SUBSTRING(RCC_CONTEU,7,3) = '"+cForn+"' AND	"
cQuery+="	RCC_CODIGO = 'U004' AND 	"
cQuery+="	RCC.D_E_L_E_T_ = ' '	"
cQuery+="	GROUP BY	"
cQuery+="	SUBSTRING(RCC_CONTEU,7,3),	"
cQuery+="	RCC_FIL,	"
cQuery+="	RCC_CHAVE,	"
cQuery+="	SUBSTRING(RCC_CHAVE,5,2)+'/'+SUBSTRING(RCC_CHAVE,1,4),	"
cQuery+="	RA_CC,	"
cQuery+="	CTT_DESC01	"
cQuery+="	), TOTAL AS	"
cQuery+="	(	"
cQuery+="	SELECT	"
cQuery+="	PERIODO,	"
cQuery+="	SUM(RATEIO) TOTAL	"
cQuery+="	FROM GERAL	"
cQuery+="	GROUP BY	"
cQuery+="	PERIODO	"
cQuery+="	)	"
cQuery+="	SELECT	"
cQuery+="	GERAL.FILIAL,	"
cQuery+="	GERAL.PERIODO,	"
cQuery+="	PERREL,	"
cQuery+="	CCUSTO,	"
cQuery+="	DESCCC,	"
cQuery+="	RATEIO,	"
cQuery+="	ROUND((RATEIO / TOTAL * 100),2) PERC	"
cQuery+="	FROM GERAL	"
cQuery+="	LEFT JOIN TOTAL ON TOTAL.PERIODO = GERAL.PERIODO 	"
cQuery+="	ORDER BY 1,4	"

ENDIF

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

aAdd( aPerg , { "01", "Período De           	      " , "mv_ch1" ,  "D",  8,  0 ,"MV_PAR01","G" ," ", " "  ," " 	," "	,"  " ,"   ",""} )
aAdd( aPerg , { "02", "Filial De	                  " , "mv_ch2" ,  "C",  2 , 0 ,"MV_PAR02","C" ,"SM0", " "  ,""	," "	,"  " ,"   ",""} )
aAdd( aPerg , { "03", "Filial Até	                  " , "mv_ch3" ,  "C",  2 , 0 ,"MV_PAR03","C" ,"SM0", " "  ,""	," "	,"  " ,"   ",""} )
aAdd( aPerg , { "04", "Fornecedor	                  " , "mv_ch4" ,  "C",  3 , 0 ,"MV_PAR04","C" ,"U003", " "  ,""	," "	,"  " ,"   ","NaoVazio()"} )

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
		X1_Def05   With aPerg[nn,14], X1_VALID   With aPerg[nn,15]
		MsUnlock()
	EndIf
Next

Return
