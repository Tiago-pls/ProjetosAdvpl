#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "MsOle.ch"
#Include "Report.ch"
#Include "Protheus.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "FWPrintSetup.ch" 
#include "topconn.ch"
#include "tbiconn.ch"


User Function CSV_FARM()              

	Local aRegArq	:= {}     
	Local cQuery	:= ""   
	Local cArqTXT	:= ""   
	Private cPerg 	:= "" 

	//Cria a pergunta de acordo com o tamanho da SX1

	dbSelectArea("SX1")  
	dbSetOrder(1)
	cPerg := "CSV_FARM" +Replicate(" ",Len(X1_GRUPO)- Len("CSV_FARM"))

	//Carrega os Parâmetros
	//********************************************************************************

	GeraPerg(cPerg)


IF (!Pergunte(cPerg,.T.) )
	return
ELSE
cFil1 := mv_par01
cFil2 := mv_par02
cData1 := DTOS(mv_par03)
Endif                        

	cArqTXT := "C:\TEMP\#RATEIO_FARM_"+SUBSTR(cData1,1,6)+".csv"

	AADD(aRegArq,{"LINHA","C",629,0})

	cNomeArq:=CriaTrab(aRegArq, .t. )
	dbUseArea(.T.,__LocalDriver,cNomeArq,"TXT",.F.,.F.)  

If Select("QRY") > 0         
		QRY->(dbCloseArea())
Endif              

cQuery:="	WITH GERAL AS	"
cQuery+="	(	"
cQuery+="	SELECT	"
cQuery+="	RGB_FILIAL FILIAL,	"
cQuery+="	RGB_PERIOD PERIODO,	"
cQuery+="	SUBSTRING(RGB_PERIOD,5,2)+'/'+SUBSTRING(RGB_PERIOD,1,4) PERREL,	"
cQuery+="	RGB_CC CCUSTO,	"
cQuery+="	RGB_VALOR VALOR	"
cQuery+="	FROM RGB010 RGB	"
cQuery+="	WHERE	"
cQuery+="	RGB_PD IN ('421') AND	"
cQuery+="	RGB.D_E_L_E_T_ = ' ' AND	"
cQuery+="	RGB_PERIOD = '"+SUBSTR(cData1,1,6)+"' AND	"
cQuery+="	RGB_FILIAL BETWEEN '"+cFil1+"' AND '"+cFil2+"' 	"
cQuery+="	UNION ALL	"
cQuery+="	SELECT	"
cQuery+="	RCC_FIL FILIAL,	"
cQuery+="	RCC_CHAVE PERIODO,	"
cQuery+="	SUBSTRING(RCC_CHAVE,5,2)+'/'+SUBSTRING(RCC_CHAVE,1,4) PERREL,	"
cQuery+="	SUBSTRING(RCC_CONTEU,1,9) CCUSTO,	"
cQuery+="	SUBSTRING(RCC_CONTEU,10,6) VALOR	"
cQuery+="	FROM RCC010 RCC	"
cQuery+="	WHERE	"
cQuery+="	RCC_FIL BETWEEN '"+cFil1+"' AND '"+cFil2+"' AND "
cQuery+="	RCC_CHAVE = '"+SUBSTR(cData1,1,6)+"' AND	"
cQuery+="	RCC_CODIGO = 'U002' AND	"
cQuery+="	RCC.D_E_L_E_T_ = ' '	"
cQuery+="	), TOTAL AS	"
cQuery+="	(	"
cQuery+="	SELECT	"
cQuery+="	FILIAL,	"
cQuery+="	PERIODO,	"
cQuery+="	SUM(VALOR) RATEIO	"
cQuery+="	FROM GERAL	"
cQuery+="	GROUP BY	"
cQuery+="	FILIAL,	"
cQuery+="	PERIODO	"
cQuery+="	)	"
cQuery+="	SELECT	"
cQuery+="	GERAL.FILIAL,	"
cQuery+="	GERAL.PERIODO,	"
cQuery+="	PERREL,	"
cQuery+="	CCUSTO,	"
cQuery+="	CTT_DESC01 DESCCC,	"
cQuery+="	SUM(VALOR) RATEIO,	"
cQuery+="	ROUND((SUM(VALOR) / TOTAL.RATEIO*100),2) PERC	"
cQuery+="	FROM GERAL	"
cQuery+="	INNER JOIN CTT010 CTT ON CTT_CUSTO = CCUSTO AND CTT.D_E_L_E_T_ = ' '	"
cQuery+="	LEFT JOIN TOTAL ON TOTAL.PERIODO = GERAL.PERIODO	"
cQuery+="	GROUP BY	"
cQuery+="	GERAL.FILIAL,	"
cQuery+="	GERAL.PERIODO,	"
cQuery+="	PERREL,	"
cQuery+="	CCUSTO,	"
cQuery+="	CTT_DESC01,	"
cQuery+="	TOTAL.RATEIO	"
cQuery+="	ORDER BY 2,3	"


	TcQuery cQuery new Alias "QRY"   

	DbSelectArea("QRY")
	DbGoTop() 
	If Eof()    
		DbSelectArea("QRY")
		DbCloseArea()
		DbSelectArea("TXT")
		DbCloseArea()
		Return                          
	Else

RecLock("TXT",.t.)  
TXT->LINHA := "C.Custo;;;%"
		While !Eof()   
			RecLock("TXT",.t.)  
				TXT->LINHA := Alltrim("0"+AllTrim(QRY->CCUSTO)+";;;"+cvaltochar(QRY->PERC) )
			MsUnLock()         			
			DbSelectArea("QRY")
			DbSkip()
		End
	EndIf

	DbSelectArea("QRY")
	DbCloseArea()                                                                 

	DbSelectArea("TXT")
	DbGoTop()
	Copy to &cArqTXT SDF  

	MsgInfo(cArqTXT + " - Gerado com sucesso!!!")

	DbSelectArea("TXT")
	DbCloseArea()

Return


Static Function GeraPerg(cPerg) 

	Local aRegs:= {}

	aAdd(aRegs,{cPerg,"01","Filial De"      ,"Filial De"  ,"Filial De"	,"mv_ch1","C",02,0,0,"G","naovazio()","mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","SM0","","",""})
	aAdd(aRegs,{cPerg,"02","Filial Até"   	,"Filial Até" ,"Filial Até","mv_ch2","C",02,0,0,"G","naovazio()","mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","SM0","","",""})
	aAdd(aRegs,{cPerg,"03","Período"      	,"Período De" ,"Período De","mv_ch3","D",08,0,0,"G","naovazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	U_BuscaPerg(aRegs)

Return


