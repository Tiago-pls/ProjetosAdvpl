#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦  ConfMDT      ¦ Autor ¦ Tiago Santos      ¦ Data ¦14.05.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Relatório de cadastros SIGAMDT              		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function ConfMDT() 

Local cTitle    := OemToAnsi("Relatório Conferencia MDT")
Local cHelp     := OemToAnsi("Relatório Conferencia MDT")
Local aOrdem 	:= {}
Local oRel
Local oDados
Private cPerg 	:= "" 

//Cria a pergunta de acordo com o tamanho da SX1
dbSelectArea("SX1")  
dbSetOrder(1)
cPerg := "ConfMDT" +Replicate(" ",Len(X1_GRUPO)- Len("ConfMDT"))
		
//Carrega os Parâmetros
//********************************************************************************
GeraPerg(cPerg)

If !Pergunte(cPerg,.T.)
   Return
Endif                                                       

//Título do relatório no cabeçalho
cTitle := OemToAnsi("Relatório Conferencia MDT")

//Criacao do componente de impressão
oRel := tReport():New("Conferencia MDT",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)

//Seta a orientação do papel
oRel:SetLandscape()

//Seta impressão em planilha                      
oRel:SetDevice(4)                       

//Inicia a Sessão
oDados := trSection():New(oRel,cTitle,{"TN0","TMA","TN5","TIK","SB1"},aOrdem)
//oDados:SetHeaderSection(.F.)    
//oDados:HeaderBreak()     
oDados:SetHeaderBreak()

cTipoRel := MV_PAR07
// Celulas comuns a todos os tipos de relatórios
trCell():New(oDados,"TN0_FILIAL" 	,"QRY" ,"Cod Filial"   	,"@!",02)
trCell():New(oDados,"FILIAL" 	    ,"QRY" ,"Nome Filial"  	,"@!",30)
trCell():New(oDados,"TN0_NUMRIS" 	,"QRY" ,"Risco"     	,"@!",09)
trCell():New(oDados,"TN0_DTRECO"    ,"QRY" ,"Emissao"     	,"@!",15)
trCell():New(oDados,"TN0_AGENTE"	,"QRY" ,"Cod Agente"   	,"@!",06)
trCell():New(oDados,"TMA_NOMAGE" 	,"QRY" ,"Nome Agente" 	,"@!",20)
trCell():New(oDados,"TN0_CODTAR"    ,"QRY" ,"Cod Tarefa"    ,"@!",06) 
trCell():New(oDados,"TN5_NOMTAR"	,"QRY" ,"Tarefa GHE"	,"@!",20)

if cTipoRel == 1      // Riscos

	trCell():New(oDados,"TNE_NOME"   	,"QRY" ,"Ambiente"          ,"@!",09)
  //	trCell():New(oDados,"TNE_MEMODS"   	,"QRY" ,"Desc Ambiente" ,"@!",50)
	trCell():New(oDados,"TN0_INDEXP" 	,"QRY" ,"Tipo de Exposição" ,"@!",30)
	trCell():New(oDados,"TN0_FONTE" 	,"QRY" ,"Cod Fonte"         ,"@!",09)
	trCell():New(oDados,"TN7_NOMFON"    ,"QRY" ,"Nome Fonte"        ,"@!",15)
	trCell():New(oDados,"TN6_MAT"   	,"QRY" ,"Matricula"       	,"@!",06)


Elseif cTipoRel == 2    // EPI

	trCell():New(oDados,"TIK_EPI"       ,"QRY" ,"EPI"			,"@!",06)                                                                                                          
	trCell():New(oDados,"B1_DESC"       ,"QRY" ,"Nome EPI"		,"@!",20) 
else
	// Exames  
	trCell():New(oDados,"TM5_EXAME"       ,"QRY" ,"Cod Exame"			,"@!",06)                                                                                                          
	trCell():New(oDados,"TM4_NOMEXA"       ,"QRY" ,"Exame"		,"@!",20) 
Endif 

trCell():New(oDados,"RA_NOME" 	    ,"QRY" ,"Nome"          	,"@!",30)
trCell():New(oDados,"RJ_DESC"       ,"QRY" ,"Funcao"            ,"@!",06) 
trCell():New(oDados,"RJ_CODCBO"  	,"QRY" ,"CBO"           	,"@!",20)
	                                                    	
//Executa o relatório
oRel:PrintDialog()

Return

/*-----------------+---------------------------------------------------------+
!Nome              ! ReportPrint                                             !
+------------------+---------------------------------------------------------+
!Descrição         ! Processamento dos dados e impressao do relatório        !
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


oDados:Init()

//Seleciona os registros
//********************************************************************************
If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif

cTipoRel := MV_PAR07 // 1 - Riscos / 2 - EPI / 3 - Exames

cQry := MontaQry(cTipoRel)

TcQuery cQry New Alias "QRY"

TCSetField("QRY","TN0_DTRECO","D",8,0)  
if select("TNE") == 0
	DbSelectArea("TNE")
endif
cChaveTNE := fwFilial("TNE") + QRY->TN0_CODAMB

//Ambiente
TNE->( dbSetOrder(1))                     
TNE->( DbGotop())
TNE->( DbSeek(cChaveTNE))  
cExposicao:= ""
If QRY->(!Eof())
	While QRY->(!Eof()) .and. !oRel:Cancel()  
	    	
		//Cancelado pelo usuário
		If oRel:Cancel()
			Exit
		EndIf
		
		oRel:IncMeter(10)
		// Nome Filial
		
		SM0->(dbSetOrder(1))
		nRecnoSM0 := SM0->(Recno())
		SM0->(dbSeek(SUBS(cNumEmp,1,2)+QRY->TN0_FILIAL))
		oDados:Cell("FILIAL"	):SetValue(Alltrim(SM0->M0_FILIAL))	
	
		SM0->(dbGoto(nRecnoSM0))
		
		// Descrição - MEMO 
	   //	oDados:Cell("TNE_MEMODS"	):SetValue(alltrim(TNE->TNE_MEMODS))	
			
	   // Tipo de Exposição 
	   if cTipoRel == 1
			DO CASE
		         CASE QRY-> TN0_INDEXP =='1'
					cExposicao := 'Habitual / Permanente'
		         CASE QRY-> TN0_INDEXP =='2'
					cExposicao := 'Ocasional / Intermitente'
		         CASE QRY-> TN0_INDEXP =='3'
					cExposicao := 'Ausência de Agente Nocivo'
		         CASE QRY-> TN0_INDEXP =='4'
					cExposicao := 'Eventual'											
		         CASE QRY-> TN0_INDEXP =='5'
					cExposicao := 'Habitual / Intermitente'	 
			ENDCASE		
		
			oDados:Cell("TN0_INDEXP"	):SetValue(alltrim( cExposicao))  
		endif			
	    oDados:PrintLine()
	    oDados:SetHeaderSection(.F.)    
		QRY->(dbSkip())
		
	End
Else
	MsgInfo("Não foram encontrados registros para os parâmetros informados!")
    Return .F.
Endif

oDados:Finish()


Return
                                     
// função para retornar a query conforme tipo do relatório selecionado
static Function MontaQry (cTipoRel)                                   
Local cQuery := " "                                                   

if cTipoRel == 1   // Risco
	cQuery := " select "
	cQuery += " TN0_FILIAL, TN0_NUMRIS, TN0_DTRECO,TN0_CODAMB, TNE_NOME, TNE_MEMODS, TN0_AGENTE, TMA_NOMAGE,TN0_INDEXP, TN0_FONTE,TN7_NOMFON,TN0_CODTAR, TN5_NOMTAR,TN6_MAT, RA_NOME , RJ_DESC, RJ_CODCBO "
	cQuery += " from " + RetSqlName("TN0")+" TN0                                                                                                                            "
	cQuery += " inner join " + RetSqlName("TMA")+" TMA on TN0_AGENTE = TMA_AGENTE  and TN0_FILIAL = TMA_FILIAL                                                                                           "
	cQuery += " inner join " + RetSqlName("TN7")+" TN7 on TN0_FONTE = TN7_FONTE                                                                                              "
	cQuery += " inner join " + RetSqlName("TN5")+" TN5 on TN0_CODTAR = TN5_CODTAR  and TN0_FILIAL = TN5_FILIAL                                                                                          "
	cQuery += " left join  " + RetSqlName("TN6")+" TN6 on TN5_CODTAR = TN6_CODTAR    and TN0_FILIAL = TN6_FILIAL                                                                                         "
	cQuery += " left join  " + RetSqlName("SRA")+" SRA on TN6_FILIAL = RA_FILIAL and TN6_MAT = RA_MAT and RA_SITFOLH NOT IN ('D','T')                                                                    "
	cQuery += " left join  " + RetSqlName("SRJ")+" SRJ on RA_CODFUNC = RJ_FUNCAO                                                                                              "
	cQuery += " left join  " + RetSqlName("TNE")+" TNE on TN0_CODAMB = TNE_CODAMB and TN0_FILIAL = TNE_FILIAL  "
		
	cQuery += " Where                                                                                                                                       "
	cQuery += "  TN7.D_E_L_E_T_ =' ' and  TN6.D_E_L_E_T_ = ' ' "
		
Elseif cTipoRel == 2    // EPI   
	cQuery := " Select TN0_FILIAL, TN0_NUMRIS, TN0_DTRECO, TN0_CODAMB, TN0_AGENTE, TMA_NOMAGE, TN0_CODTAR, TN5_NOMTAR, TIK_EPI, B1_DESC ,RA_NOME , RJ_DESC, RJ_CODCBO  "
    cQuery += "  from TN0020 TN0 "
    cQuery += " inner join " + RetSqlName("TMA")+" TMA  on TN0_AGENTE = TMA_AGENTE and TN0_FILIAL = TMA_FILIAL "
  	cQuery += " inner join " + RetSqlName("TN5")+" TN5 on TN0_CODTAR = TN5_CODTAR  and TN0_FILIAL = TN5_FILIAL " //and TN5_FILIAL = '" +Fwfilial("TN5") +"'" 
	cQuery += " left join  " + RetSqlName("TN6")+" TN6 on TN5_CODTAR = TN6_CODTAR  and TN0_FILIAL = TN6_FILIAL                                                                                           "
	cQuery += " left join  " + RetSqlName("SRA")+" SRA on TN6_FILIAL = RA_FILIAL and TN6_MAT = RA_MAT and RA_SITFOLH NOT IN ('D','T')                                                                    "
	cQuery += " left join  " + RetSqlName("SRJ")+" SRJ on RA_CODFUNC = RJ_FUNCAO   	
  	cQuery += " left join " + RetSqlName("TIK")+" TIK on TN0_CODTAR = TIK_TAREFA                                          "
 	cQuery += " left join " + RetSqlName("SB1")+" SB1 on TIK_EPI = B1_COD                                                 "	
  	cQuery += " Where    TN5.D_E_L_E_T_ = ' '                                                                             "	
else // Exame    

	cQuery := " select  TN0_FILIAL, TN0_NUMRIS, TN0_DTRECO,TN0_CODAMB, TN0_AGENTE, TMA_NOMAGE, TN0_CODTAR, TN5_NOMTAR, "
	cQuery += " TM5_EXAME, TM4_NOMEXA, RA_NOME , RJ_DESC, RJ_CODCBO "
	cQuery += " from TN0020 TN0"
	cQuery += " inner join " + RetSqlName("TMA")+" TMA on TN0_AGENTE = TMA_AGENTE and TN0_FILIAL = TMA_FILIAL "
	cQuery += " inner join " + RetSqlName("TN5")+" TN5 on TN0_CODTAR = TN5_CODTAR and TN0_FILIAL = TN5_FILIAL"  
	cQuery += " left join  " + RetSqlName("TN6")+" TN6 on TN5_CODTAR = TN6_CODTAR and TN0_FILIAL = TN6_FILIAL"
	cQuery += " left join  " + RetSqlName("SRA")+" SRA on TN6_FILIAL = RA_FILIAL and TN6_MAT = RA_MAT and RA_SITFOLH NOT IN ('D','T')                                                                    "
	cQuery += " left join  " + RetSqlName("SRJ")+" SRJ on RA_CODFUNC = RJ_FUNCAO 	
	cQuery += " inner join " + RetSqlName("TM0")+"  TM0 on RA_FILIAL = TM0_FILFUN and RA_MAT = TM0_MAT"
	cQuery += " inner join " + RetSqlName("TM5")+"  TM5 on TM0_NUMFIC = TM5_NUMFIC"
	cQuery += " inner join " + RetSqlName("TM4")+"  TM4 on TM5_EXAME = TM4_EXAME"
	cQuery += " Where TMA.D_E_L_E_T_=' '"


endif              

cQuery += " and TN0_FILIAL between '" +MV_PAR01+"' and '" + MV_PAR02+"'"
cQuery += " and TN0_NUMRIS between '" +MV_PAR03+"' and '" + MV_PAR04+"'"
cQuery += " and TN0_AGENTE between '" +MV_PAR05+"' and '" + MV_PAR06+"'"        
cQuery += " and TN0.D_E_L_E_T_ =' ' and TMA.D_E_L_E_T_ =' ' and TN5.D_E_L_E_T_ = ' '                                      "

cQuery += " order by 1, 2, 4, 6, 8                                                                         "
// Filial + Risco + Agente + tarefa 


return cQuery

//  Cria as perguntas na SX1                               
//********************************************************************************

Static Function GeraPerg(cPerg) 
Local aRegs:= {}

aAdd(aRegs,{cPerg,"01","Filial De"	 ,"Filial De"  ,"Filial De"	,"mv_ch1","C",02,0,0,"G",""          ,"mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"02","Filial Até"  ,"Filial Até" ,"Filial Até","mv_ch2","C",02,0,0,"G","naovazio()","mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,'03',"Tipo"  ,'','','mv_ch3','C',1,0,0,'C','','MV_PAR09','Riscos','','','','','EPI','','','','','Exames','','','','','','','','','','','','','','','','',''})


U_BuscaPerg(aRegs)

Return

