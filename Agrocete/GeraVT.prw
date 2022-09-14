#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³RERPM01   ºAutor  ³ Tiago Santos       º Data ³ 31/12/2013  º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³ GeraArqSan                       .                         º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ Academia ERP                                               º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GeraArqVT ()


Private cPerg 	:= "" 
dbSelectArea("SX1")  
dbSetOrder(1)
cPerg := "ArqVT" +Replicate(" ",Len(X1_GRUPO)- Len("ArqVT"))
 //Carrega os Par�metros
//********************************************************************************
GeraPerg(cPerg)
If !Pergunte(cPerg,.T.)
   Return
Endif  

MsAguarde({|| GeraArq()}, "Aguarde...", "Gerando Registros...")
Return

static function GeraArq


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³FCreate - É o comando responsavel pela criação do arquivo.                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cNome := "arquivo VT " + MV_PAR07 + ".txt"
Local nHandle := FCreate(AllTrim(MV_PAR08) + cNome)
Local nCont  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³nHandle - A função FCreate retorna o handle, que indica se foi possível ou não criar o arquivo. Se o valor for     ³
//³menor que zero, não foi possível criar o arquivo.                                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nHandle < 0
	MsgAlert("Erro durante criação do arquivo.")
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FWrite - Comando reponsavel pela gravação do texto.                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("QRY")>0         
		QRY->(dbCloseArea())
	Endif

	cQuery := " select R0_MAT, R0_VALCAL "
	cQuery += " from " + RetSqlname("SR0") + " SR0"
	cQuery += " Where SR0.D_E_L_E_T_ =' ' and R0_FILIAL between '"+mv_par01+"' and '" + mv_par02 +"' and"
	cQuery += "  R0_CC between '"+mv_par03+"' and '" + mv_par04 +"' and"
	cQuery += "  R0_MAT between '"+mv_par05+"' and '" + mv_par06 +"' and"
	cQuery += "  R0_TPVALE ='0' and R0_VALCAL <> 0"

	TcQuery cQuery New Alias "QRY" 

	While QRY->( ! EOF())
	nCont ++
		cLinha := QRY->R0_MAT + ";"	
		cLinha += cvaltoChar(QRY->R0_VALCAL	)
		
		FWrite(nHandle, cLinha + CRLF)
		QRY->( DbSkip())
	enddo
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FClose - Comando que fecha o arquivo, liberando o uso para outros programas.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FClose(nHandle)

	MSGALERT( "Arquivo Gerado com sucesso" )
EndIf

Return



Static Function GeraPerg(cPerg) 
Local aRegs:= {}

aAdd(aRegs,{cPerg,"01","Filial"         ,"Filial De"        ,"Filial De"       ,"mv_ch1","C",02,0,0,"G"," ","mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"02","Filial Ate"     ,"Filial Ate"       ,"Filial Ate"      ,"mv_ch2","C",02,0,0,"G","naovazio()","mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"03","Centro Custo"   ,"Centro Custo De"  ,"Centro Custo De" ,"mv_ch3","C",09,0,0,"G"," ","mv_par03","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"04","Centro Ate"     ,"Centro Custo Ate" ,"Centro Custo Ate","mv_ch4","C",09,0,0,"G","naovazio()","mv_par04","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"05","Matricula"      ,"Matricula De"     ,"Matricula De"    ,"mv_ch5","C",06,0,0,"G"," ","mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"06","Matricula Ate"  ,"Matricula Ate"    ,"Matricula Ate"   ,"mv_ch6","C",06,0,0,"G","naovazio()","mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"07","Competencia"    ,"Competencia"      ,"Competencia"     ,"mv_ch7","C",06,0,0,"G","naovazio()","mv_par07","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Arquivo"        ,"Arquivo"          ,"Arquivo"         ,"mv_ch8","C",50,0,0,"G","naovazio()","mv_par08","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})

U_BuscaPerg(aRegs)

Return