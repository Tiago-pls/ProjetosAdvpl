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
User Function GeraSant ()


Private cPerg 	:= "" 
dbSelectArea("SX1")  
dbSetOrder(1)
cPerg := "ArqSant" +Replicate(" ",Len(X1_GRUPO)- Len("ArqSant"))

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
Local cNome := "CADASTRO_" + Dtos(dDataBase)+"_" + cValToChar(Randomize(100000,300000) )
Local nHandle := FCreate(AllTrim(MV_PAR07) + cNome +".txt")
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

	cQuery := " select RA_CIC,RA_NOME, RA_MAE, RA_NASC, RA_EMAIL, RA_RG, RA_DTRGEXP, RA_RGORG,RA_DDDCELU, RA_NUMCELU, RA_CEP,"
	cQuery += " RA_LOGRTP,RA_LOGRDSC, RA_LOGRNUM, RA_COMPLEM, RA_BAIRRO, RA_MUNICIP, RA_ESTADO "
	cQuery += " from " + RetSqlname("SRA") + " SRA"
	cQuery += " Where SRA.D_E_L_E_T_ =' ' and RA_FILIAL between '"+mv_par01+"' and '" + mv_par02 +"' and"
	cQuery += "  RA_CC between '"+mv_par03+"' and '" + mv_par04 +"' and"
	cQuery += "  RA_MAT between '"+mv_par05+"' and '" + mv_par06 +"' "


	TcQuery cQuery New Alias "QRY" 

	While QRY->( ! EOF())
	nCont ++
		cLinha := QRY->RA_CIC	
		cLinha += Padr(alltrim(QRY->RA_NOME),80)
		cLinha += Padr(alltrim(QRY->RA_MAE),80)
		

		cData := QRY->RA_NASC
		cData := Substr(cData,7,2) + Substr(cData,5,2) + Substr(cData,1,4)  
		cLinha+= cData
		cLinha += Padr(alltrim(QRY->RA_EMAIL),80)
		cLinha += Padr(alltrim(QRY->RA_RG),10)

		cData := QRY->RA_DTRGEXP
		cData := Substr(cData,7,2) + Substr(cData,5,2) + Substr(cData,1,4) 
		cLinha+= cData

		cLinha += Padr(alltrim(QRY->RA_RGORG),10)
		cLinha += Padr(alltrim(QRY->RA_DDDCELU),2)
		cLinha += Padr(alltrim(QRY->RA_NUMCELU),13)
		cLinha += Padr(alltrim(QRY->RA_CEP),8)
		
		cLinha += Padr(ALLTRIM(fDescRCC('S054',QRY->RA_LOGRTP,1,4,5,20)),10)
		cLinha += Padr(alltrim(QRY->RA_LOGRDSC),100)

		cLinha += Padr(alltrim(QRY->RA_LOGRNUM),10)
		cLinha += Padr(alltrim(QRY->RA_COMPLEM),30)
		cLinha += Padr(alltrim(QRY->RA_BAIRRO),50)
		cLinha += Padr(alltrim(QRY->RA_MUNICIP),50)
		cLinha += Padr(alltrim(QRY->RA_ESTADO),2)
		cLinha += Strzero(nCont,6)
		cLinha += Space(32)

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
aAdd(aRegs,{cPerg,"05","Centro Custo"   ,"Centro Custo De"  ,"Centro Custo De" ,"mv_ch3","C",09,0,0,"G"," ","mv_par03","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"06","Centro Ate"     ,"Centro Custo Ate" ,"Centro Custo Ate","mv_ch4","C",09,0,0,"G","naovazio()","mv_par04","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"07","Matricula"      ,"Matricula De"     ,"Matricula De"    ,"mv_ch5","C",06,0,0,"G"," ","mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"08","Matricula Ate"  ,"Matricula Ate"    ,"Matricula Ate"   ,"mv_ch6","C",06,0,0,"G","naovazio()","mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"09","Arquivo"        ,"Arquivo"          ,"Arquivo"         ,"mv_ch7","C",99,0,0,"G","naovazio()","mv_par07","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})

U_BuscaPerg(aRegs)

Return