#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  ImpSup      ¦ Autor ¦ Tiago Santos      ¦ Data ¦26.06.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Relatorio para geracao do Historico de alteracoes Z03     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function ImpSup() 

Local cTitle    := OemToAnsi("Relatorio Historico Superiores")
Local cHelp     := OemToAnsi("Relatorio Historico Superiores")
Local aOrdem 	:= {"Matricula","Superior"}//
Local oRel
Local oDados
Private cPerg 	:= "" 

//Cria a pergunta de acordo com o tamanho da SX1
dbSelectArea("SX1")  
dbSetOrder(1)
cPerg := "IMPSUP" +Replicate(" ",Len(X1_GRUPO)- Len("IMPSUP"))
		
//Carrega os Par?metros
//********************************************************************************
GeraPerg(cPerg)

If !Pergunte(cPerg,.T.)
   Return
Endif                                                       

//T?tulo do relat?rio no cabe?alho
cTitle := OemToAnsi("Relatorio Historico Superiores")

//Criacao do componente de impress?o
oRel := tReport():New("Historico Superiores",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)

//Seta a orienta??o do papel
oRel:SetLandscape()

//Seta impress?o em planilha                      
oRel:SetDevice(4)                       

//Inicia a Sess?o
oDados := trSection():New(oRel,cTitle,{"Z03","SRA","CTT"},aOrdem)
//oDados:SetHeaderSection(.F.)    
//oDados:HeaderBreak()     
oDados:SetHeaderBreak()

// Celulas comuns a todos os tipos de relat?rios
trCell():New(oDados,"RA_MAT"     	,"QRY" ,"Matricula"     	,"@!",06)
trCell():New(oDados,"RA_NOME"       ,"QRY" ,"Nome"     	,"@!",38)
trCell():New(oDados,"RA_CC"	        ,"QRY" ,"C.Custo"   	,"@!",09)
trCell():New(oDados,"CTT_DESC01"    ,"QRY" ,"Desc Custo" 	,"@!",30)
trCell():New(oDados,"Z03_SUPERI"    ,"QRY" ,"Mat Gestor"    ,"@!",10) 
trCell():New(oDados,"NOME_SUP"      ,"QRY" ,"Nome Gestor"    ,"@!",36) 
trCell():New(oDados,"Z03_DATA"      ,"QRY" ,"Data Alt"    ,"@!",10) 
trCell():New(oDados,"Z03_HORA"      ,"QRY" ,"Hora"    ,"@!",10) 	
trCell():New(oDados,"Z03_USUARI"    ,"QRY" ,"Usuario"    ,"@!",20)
 	                                                    	
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
cCateg:= mv_par07
cSitua:= mv_par08

oDados:Init()

//Seleciona os registros
//********************************************************************************
If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif

cQry := MontaQry(nOrdem)

TcQuery cQry New Alias "QRY"

TCSetField("QRY","Z03_DATA","D",8,0)  
  
If QRY->(!Eof())
	While QRY->(!Eof()) .and. !oRel:Cancel()  
	    	
		//Cancelado pelo usu?rio
		If oRel:Cancel()
			Exit
		EndIf
		If  !( QRY->RA_CATFUNC $ cCateg ) .or. !( QRY->RA_SITFOLH $ cSitua )
			QRY->(dbSkip())
			Loop
		Endif
		oRel:IncMeter(10)
		// Nome Filial
		oDados:Cell("NOME_SUP"):SetValue(alltrim(  POSICIONE("SRA",1,QRY->(Z03_FILIAL + Z03_SUPERI),"RA_NOME")))  
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
cQuery += " Z03_FILIAL, RA_MAT, RA_NOME, Z03_SUPERI, Z03_DATA,Z03_HORA, Z03_USUARI, RA_CC, CTT_DESC01, RA_SITFOLH , RA_CATFUNC "
cQuery += " from " + RetSqlName("Z03") + " Z03 "
cQuery += " inner join " + RetSqlName("SRA") + " SRA on Z03_FILIAL = RA_FILIAL and Z03_MAT = RA_MAT "
cQuery += " inner join " + RetSqlName("CTT") + " CTT on RA_CC = CTT_CUSTO "

cQuery += " where SRA.D_E_L_E_T_ =' ' and Z03.D_E_L_E_T_ =' ' and CTT.D_E_L_E_T_ =' '

cQuery += " and RA_FILIAL between '" +MV_PAR01+"' and '" + MV_PAR02+"'"
cQuery += " and RA_CC between '" +MV_PAR03+"' and '" + MV_PAR04+"'"
cQuery += " and RA_MAT between '" +MV_PAR05+"' and '" + MV_PAR06+"'"        

// Ordem
if nOrdem =1
    cQuery += " Order by Z03_MAT"
else
    cQuery += " Order by Z03_SUPERI"
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

