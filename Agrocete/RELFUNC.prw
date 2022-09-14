#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  ConfMDT      ¦ Autor ¦ Tiago Santos      ¦ Data ¦14.05.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Relat?rio de cadastros SIGAMDT              		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function RelFunc() 

Local cTitle    := OemToAnsi("Relatorio Funcionarios")
Local cHelp     := OemToAnsi("Relatorio Funcionarios")
Local aOrdem 	:= {"Matricula","Nome"}//
Local oRel
Local oDados
Private cPerg 	:= "" 

//Cria a pergunta de acordo com o tamanho da SX1
dbSelectArea("SX1")  
dbSetOrder(1)
cPerg := "FUNC" +Replicate(" ",Len(X1_GRUPO)- Len("FUNC"))
		
//Carrega os Par?metros
//********************************************************************************
GeraPerg(cPerg)

If !Pergunte(cPerg,.T.)
   Return
Endif                                                       

//T?tulo do relat?rio no cabe?alho
cTitle := OemToAnsi("Relatorio Funcionarios")

//Criacao do componente de impress?o
oRel := tReport():New("Funcionarios",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)

//Seta a orienta??o do papel
oRel:SetLandscape()

//Seta impress?o em planilha                      
oRel:SetDevice(4)                       

//Inicia a Sess?o
oDados := trSection():New(oRel,cTitle,{"SRA","CTT","SR6","SRJ"},aOrdem)
//oDados:SetHeaderSection(.F.)    
//oDados:HeaderBreak()     
oDados:SetHeaderBreak()


// Celulas comuns a todos os tipos de relat?rios
trCell():New(oDados,"RA_MAT"     	,"QRY" ,"Matricula"     	,"@!",06)
trCell():New(oDados,"RA_NOME"       ,"QRY" ,"Nome"     	,"@!",38)
trCell():New(oDados,"RA_NASC"	    ,"QRY" ,"Dt Nascimento"   	,"@!",08)
trCell():New(oDados,"RA_CIC" 	    ,"QRY" ,"CPF" 	,"@R 999.999.999-99",12)
trCell():New(oDados,"RA_PIS"        ,"QRY" ,"PIS"    ,"@!",12) 
trCell():New(oDados,"RA_ADMISSA"	,"QRY" ,"Admissao"	,"@!",08)
trCell():New(oDados,"RA_CODFUNC"	,"QRY" ,"Funcao"	,"@!",10)
trCell():New(oDados,"RJ_DESC"	    ,"QRY" ,"Desc Funcao"	,"@!",30)
trCell():New(oDados,"RJ_CODCBO"	    ,"QRY" ,"CBO"	,"@!",20)
trCell():New(oDados,"RA_TNOTRAB"	,"QRY" ,"Cod Turno"	,"@!",20)
trCell():New(oDados,"R6_DESC"	    ,"QRY" ,"Desc Turno"	,"@!",20)
trCell():New(oDados,"RA_DEPTO"	    ,"QRY" ,"Depto"	,"@!",20)
trCell():New(oDados,"QB_DESCRIC"	,"QRY" ," Desc Depto"	,"@!",20)
trCell():New(oDados,"RA_HRSDIA"	    ,"QRY" ,"Total de horas diarias"	,"@E 99.99",20)
trCell():New(oDados,"RA_CC"	,"QRY"  ,"C. Custo"	,"@!",15)
trCell():New(oDados,"CTT_DESC01"	,"QRY" ,"Desc C.Custo"	,"@!",40)
trCell():New(oDados,"RA_SITFOLH"	,"QRY" ,"Situacao","@!",10)
	                                                    	
//Executa o relat?rio
oRel:PrintDialog()

Return

/*-----------------+---------------------------------------------------------+
!Nome              ! ReportPrint                                             !
+------------------+---------------------------------------------------------+
!Descri??o         ! Processamento dos dados e impressao do relat?rio        !
+------------------+---------------------------------------------------------+
!Autor             ! Lucilene Mendes	                                     !
+------------------+--------------------------------------------------------*/
Static Function ReportPrint(oRel)

Local oDados  	:= oRel:Section(1)
Local nOrdem  	:= oDados:GetOrder()
Local dDataDe	:= ""
Local dDataAte	:= ""
Local cTes		:= ""
Local cNotIn	:= "" 
cSituacao:= mv_par07

oDados:Init()

//Seleciona os registros
//********************************************************************************
If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif

cQry := MontaQry(nOrdem)

TcQuery cQry New Alias "QRY"

TCSetField("QRY","RA_NASC","D",8,0)  
TCSetField("QRY","RA_ADMISSA","D",8,0)  

If QRY->(!Eof())
	While QRY->(!Eof()) .and. !oRel:Cancel()  
	    	
		//Cancelado pelo usu?rio
		If oRel:Cancel()
			Exit
		EndIf
		If  !( QRY->RA_SITFOLH $ cSituacao )
			QRY->(dbSkip())
			Loop
		Endif
		oRel:IncMeter(10)
		// Nome Filial

	    oDados:PrintLine()
	    oDados:SetHeaderSection(.F.)    
		QRY->(dbSkip())
		
	End
Else
	MsgInfo("N?o foram encontrados registros para os par?metros informados!")
    Return .F.
Endif

oDados:Finish()


Return
                                     
// fun??o para retornar a query conforme tipo do relat?rio selecionado
static Function MontaQry (nOrdem)                                   
Local cQuery := " "                                                   


cQuery := " select "
cQuery += " RA_MAT     ,RA_NOME    ,RA_NASC    ,RA_CIC     ,RA_PIS     ,RA_ADMISSA ,RA_CODFUNC ,RJ_DESC    ,RJ_CODCBO	   ,RA_TNOTRAB ,R6_DESC    ,RA_DEPTO   ,QB_DESCRIC,RA_CC	   ,CTT_DESC01, "
cQuery += " AVG(PJ_HRTOTAL) RA_HRSDIA, RA_SITFOLH "
cQuery += " from " + RetSqlName("SRA")+" SRA                                                                                                                            "
cQuery += " inner join " + RetSqlName("CTT")+" CTT on RA_CC = CTT_CUSTO"
cQuery += " inner join " + RetSqlName("SRJ")+" SRJ on RA_CODFUNC = RJ_FUNCAO "
cQuery += " inner join " + RetSqlName("SR6")+" SR6 on RA_TNOTRAB = R6_TURNO                                                                                            "
cQuery += " left join  " + RetSqlName("SQB")+" SQB on RA_DEPTO = QB_DEPTO "
cQuery += " left join "  + RetSqlName("SPJ")+" SPJ on RA_TNOTRAB = PJ_TURNO and PJ_SEMANA ='01' and SPJ.D_E_L_E_T_ =' ' and PJ_HRTOTAL<> 0 "
cQuery += " Where                                                                                                                                       "
cQuery += "  SRA.D_E_L_E_T_ =' ' and  CTT.D_E_L_E_T_ = ' '  and                      "
cQuery += "  SRJ.D_E_L_E_T_ =' ' and  SR6.D_E_L_E_T_ = ' '                        "

cQuery += " and RA_FILIAL between '" +MV_PAR01+"' and '" + MV_PAR02+"'"
cQuery += " and RA_CC between '" +MV_PAR03+"' and '" + MV_PAR04+"'"
cQuery += " and RA_MAT between '" +MV_PAR05+"' and '" + MV_PAR06+"'"        
cQuery += " group by RA_MAT     ,RA_NOME    ,RA_NASC    ,RA_CIC     ,RA_PIS     ,RA_ADMISSA ,RA_CODFUNC ,RJ_DESC,"
cQuery += " RJ_CODCBO	   ,RA_TNOTRAB ,R6_DESC    ,RA_DEPTO   ,QB_DESCRIC,RA_CC	   ,CTT_DESC01,RA_SITFOLH "
// Ordem
if nOrdem =1
    cQuery += " Order by RA_MAT"
else
    cQuery += " Order by RA_NOME"
endif
//cQuery += " order by 1, 2, 4, 6, 8                                                                         "
// Filial + Risco + Agente + tarefa 


return cQuery

//  Cria as perguntas na SX1                               
//********************************************************************************

Static Function GeraPerg(cPerg) 
Local aRegs:= {}

aAdd(aRegs,{cPerg,"01","Filial De"	  ,"Filial De"    ,"Filial De"	  ,"mv_ch1","C",02,0,0,"G",""          ,"mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"02","Filial At?"   ,"Filial At?"   ,"Filial At?"   ,"mv_ch2","C",02,0,0,"G","naovazio()","mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"03","C.Custo De"	  ,"C.Custo De"   ,"C.Custo De"	  ,"mv_ch1","C",09,0,0,"G",""          ,"mv_par03","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"04","C.Custo At?"  ,"C.Custo At?"  ,"C.Custo At?"  ,"mv_ch2","C",09,0,0,"G","naovazio()","mv_par04","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"05","Matricula De" ,"Matricula De" ,"Matricula De" ,"mv_ch1","C",06,0,0,"G",""          ,"mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"06","Matricula At?","Matricula At?","Matricula At?","mv_ch2","C",06,0,0,"G","naovazio()","mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})

U_BuscaPerg(aRegs)

Return

