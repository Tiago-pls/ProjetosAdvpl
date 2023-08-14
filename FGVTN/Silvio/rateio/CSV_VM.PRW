#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "MsOle.ch"
#Include "Report.ch"
#Include "Protheus.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "FWPrintSetup.ch" 
#include "topconn.ch"
#include "tbiconn.ch"


User Function CSV_VM()              

	Local aRegArq	:= {}     
	Local cQuery	:= ""   
	Local cArqTXT	:= ""   
	Private cPerg 	:= "" 

	//Cria a pergunta de acordo com o tamanho da SX1

	dbSelectArea("SX1")  
	dbSetOrder(1)
	cPerg := "CSV_VM" +Replicate(" ",Len(X1_GRUPO)- Len("CSV_VM"))

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

	cArqTXT := "C:\TEMP\#RATEIO_VM_"+SUBSTR(cData1,1,6)+".csv"

	AADD(aRegArq,{"LINHA","C",629,0})

	cNomeArq:=CriaTrab(aRegArq, .t. )
	dbUseArea(.T.,__LocalDriver,cNomeArq,"TXT",.F.,.F.)  

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
cQuery+="	RC_PERIODO = '"+SUBSTR(cData1,1,6)+"' AND	"
cQuery+="	RC_FILIAL BETWEEN '"+cFil1+"' AND '"+cFil2+"' 	"
cQuery+="	GROUP BY	"
cQuery+="	RC_FILIAL,	"
cQuery+="	RC_PERIODO,	"
cQuery+="	RC_CC,	"
cQuery+="	CTT_DESC01	"
cQuery+="	), TOTAL AS	"
cQuery+="	(	"
cQuery+="	SELECT	"
cQuery+="	FILIAL,	"
cQuery+="	PERIODO,	"
cQuery+="	SUM(RATEIO) TOTAL	"
cQuery+="	FROM GERAL	"
cQuery+="	GROUP BY	"
cQuery+="	FILIAL,	"
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
cQuery+="	LEFT JOIN TOTAL ON TOTAL.PERIODO = GERAL.PERIODO AND TOTAL.FILIAL = GERAL.FILIAL	"
cQuery+="	ORDER BY 1,4 "

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


