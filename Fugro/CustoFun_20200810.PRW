#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    �  ImportaSP8   � Autor � Tiago Santos      � Data �27.09.19 ���
��+----------+------------------------------------------------------------���
���Descri��o �  Relatorio Gerencial Folha de Pagamento         		      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function CustoFun
                      
Private cPerg 	:= "" 
dbSelectArea("SX1")  
dbSetOrder(1)
cPerg := "CUSTOFUN" +Replicate(" ",Len(X1_GRUPO)- Len("CUSTOFUN"))

//Carrega os Par�metros
//********************************************************************************
GeraPerg(cPerg)
  
If !Pergunte(cPerg,.T.)
   Return
Endif  

MsAguarde({|| GeraRel()}, "Aguarde...", "Gerando Registros...")
Return


/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    �  GeraRel    � Autor � Tiago Santos        � Data �18.09.19 ���
��+----------+------------------------------------------------------------���
���Descri��o �  Gera o Relat�io                              		      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

static function GeraRel()
Local cTitle    := OemToAnsi("Relat�rio Conferencia MDT")
Local cHelp     := OemToAnsi("Relat�rio Conferencia MDT")   
Local aOrdem 	:= {}                
Local oRel
Local oDados             

//T�tulo do relat�rio no cabe�alho
cTitle := OemToAnsi("Relatorio Custo Funcionario")

//Criacao do componente de impress�o
oRel := tReport():New("Custo Funcionario",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)

//Seta a orienta��o do papel
oRel:SetLandscape()

//Seta impress�o em planilha                      
oRel:SetDevice(4)    

//Inicia a Sess�o
oDados := trSection():New(oRel,cTitle,{"SRA","SRJ","SQB"},aOrdem)
//oDados:SetHeaderSection(.F.)    
//oDados:HeaderBreak()     
oDados:SetHeaderBreak() 

// Defini��o das colunas a serem impressas no relat�rio

trCell():New(oDados,"MES" 	              ,"QRY" ,"Competencia"   	     ,"@!",06)
trCell():New(oDados,"RA_FILIAL"           ,"QRY" ,"Cod Filial"   	     ,"@!",02)
trCell():New(oDados,"FILIAL" 	          ,"QRY" ,"Nome Filial"  	     ,"@!",20)
trCell():New(oDados,"QB_DESCRIC"          ,"QRY" ,"Area"                 ,"@!",20) 
trCell():New(oDados,"RA_CC"               ,"QRY" ,"Centro Custo"         ,"@!",20) 
trCell():New(oDados,"RA_MAT"              ,"QRY" ,"Matricula"     	     ,"@!",06)
trCell():New(oDados,"RA_NOME"             ,"QRY" ,"Nome"     	         ,"@!",30)
trCell():New(oDados,"RJ_DESC"             ,"QRY" ,"Funcao" 	             ,"@!",20)
trCell():New(oDados,"RA_ADMISSA"          ,"QRY" ,"Admissao"     	     ,"@!",15)
trCell():New(oDados,"RA_SALARIO"          ,"QRY" ,"Salario Normal"	     ,"@E 999,999,999.99",17)
trCell():New(oDados,"Z03_SUPERI"          ,"QRY" ,"Mat Gestor"         ,"@!",10) 
trCell():New(oDados,"NOME_SUP"            ,"QRY" ,"Nome Gestor"        ,"@!",36) 
trCell():New(oDados,"GRUPO0"              ,"QRY" ,"Bolsa Estagio"	     ,"@E 999,999,999.99",17)
trCell():New(oDados,"GRUPO1"              ,"QRY" ,"Ajuda de Custo"	     ,"@E 999,999,999.99",17)
trCell():New(oDados,"GRUPO2"              ,"QRY" ,"Periculosidade"	     ,"@E 999,999,999.99",17)
trCell():New(oDados,"GRUPO3"              ,"QRY" ,"Insalubridade"	     ,"@E 999,999,999.99",17)
trCell():New(oDados,"GRUPO4"              ,"QRY" ,"Hora Extra"	         ,"@E 999,999,999.99",17)
trCell():New(oDados,"GRUPO5"              ,"QRY" ,"DSR - Hora Extra"   	 ,"@E 999,999,999.99",17)
trCell():New(oDados,"GRUPO6"              ,"QRY" ,"Adic Noturno"	     ,"@E 999,999,999.99",17)
trCell():New(oDados,"GRUPO7"              ,"QRY" ,"Grat Viagem"	         ,"@E 999,999,999.99",17)
trCell():New(oDados,"GRUPO8"              ,"QRY" ,"Gratificacao"	     ,"@E 999,999,999.99",17)
trCell():New(oDados,"GRUPO9"              ,"QRY" ,"Produtividade"	     ,"@E 999,999,999.99",17)
trCell():New(oDados,"ORDENADOS"           ,"QRY" ,"Total de Sal?rios" ,"@E 999,999,999.99",17)
trCell():New(oDados,"GRUPOA"              ,"QRY" ,"PPR"	                 ,"@E 999,999,999.99",17)
trCell():New(oDados,"FERIASMES"           ,"QRY" ,"Ferias Mes"	         ,"@E 999,999,999.99",17)
trCell():New(oDados,"13MES"               ,"QRY" ,"13 Mes"	             ,"@E 999,999,999.99",17)
trCell():New(oDados,"AVISOPREVIO"         ,"QRY" ,"Aviso Previo"	     ,"@E 999,999,999.99",17)
trCell():New(oDados,"TOTALSALARIOS"       ,"QRY" ,"Total Salarios"	     ,"@E 999,999,999.99",17)
trCell():New(oDados,"INSS"                ,"QRY" ,"INSS"	             ,"@E 999,999,999.99",17)
trCell():New(oDados,"FGTS"                ,"QRY" ,"FGTS"	             ,"@E 999,999,999.99",17)
trCell():New(oDados,"TOTALENCARGOS"       ,"QRY" ,"Total Encargos"	     ,"@E 999,999,999.99",17)
trCell():New(oDados,"GRUPOB"              ,"QRY" ,"Plano de Saude"	     ,"@E 999,999,999.99",17)
trCell():New(oDados,"GRUPOC"              ,"QRY" ,"Odonto"	             ,"@E 999,999,999.99",17)
trCell():New(oDados,"GRUPOD"              ,"QRY" ,"Auxilio Educacao"	 ,"@E 999,999,999.99",17)
trCell():New(oDados,"GRUPOE"              ,"QRY" ,"Auxilio Creche"	     ,"@E 999,999,999.99",17)
trCell():New(oDados,"GRUPOF"              ,"QRY" ,"Vale Refeicao"	     ,"@E 999,999,999.99",17)
trCell():New(oDados,"GRUPOG"              ,"QRY" ,"Vale Transporte"	     ,"@E 999,999,999.99",17)
trCell():New(oDados,"GRUPOH"              ,"QRY" ,"Seguro de Vida"	     ,"@E 999,999,999.99",17)
trCell():New(oDados,"TOTALGERAL"          ,"QRY" ,"Total Geral"	         ,"@E 999,999,999.99",17)
    
//Executa o relatorio
oRel:PrintDialog()

Return

/*-----------------+---------------------------------------------------------+
!Nome              ! ReportPrint                                             !
+------------------+---------------------------------------------------------+
!Descri��o         ! Processamento dos dados e impressao do relat�rio        !
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

cQry := MontaQry()

TcQuery cQry New Alias "QRY"                          
                                         
// Set as colunas do tipo Data
TCSetField("QRY","RA_ADMISSA","D",8,0)  

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
		
  		oRel:IncMeter(10)  
  		
  		oDados:Cell("MES"):SetValue(MV_PAR09)	
  		
		// Nome Filial   		
		SM0->(dbSetOrder(1))
		nRecnoSM0 := SM0->(Recno())
		SM0->(dbSeek(SUBS(cNumEmp,1,2)+QRY->RA_FILIAL))
		oDados:Cell("FILIAL"	):SetValue(Alltrim(SM0->M0_FILIAL))	
		SM0->(dbGoto(nRecnoSM0))			  
		cSup := RetSup(QRY->RA_MAT, MV_PAR09)  
	
			oDados:Cell("Z03_SUPERI"):SetValue( cSup)
			oDados:Cell("NOME_SUP"):SetValue(alltrim(  POSICIONE("SRA",1,QRY->RA_FILIAL + cSup ,"RA_NOME")))  

		oDados:Cell("ORDENADOS"	):SetValue( QRY->(RA_SALARIO+GRUPO1+GRUPO2+GRUPO3+GRUPO6+GRUPO8+GRUPO9))

		oDados:Cell("FERIASMES"	):SetValue( QRY->(RA_SALARIO+GRUPO1+GRUPO2+GRUPO3+GRUPO6+GRUPO4+GRUPO5) * 0.1111)
		
		oDados:Cell("13MES"	):SetValue( QRY->(RA_SALARIO+GRUPO1+GRUPO2+GRUPO3+GRUPO6+GRUPO4+GRUPO5) * 0.0833)
		
		nTotSalarios := QRY->(GRUPO9 +GRUPO0 + GRUPO4 + GRUPO5 + GRUPOA) 
		nTotSalarios += oDados:Cell("ORDENADOS"	):uvalue
		nTotSalarios += oDados:Cell("FERIASMES"	):uvalue
		nTotSalarios += oDados:Cell("13MES"	):uvalue

		oDados:Cell("TOTALSALARIOS"	):SetValue( nTotSalarios)

		nBaseEncargos := oDados:Cell("TOTALSALARIOS"):UVALUE - (QRY->(GRUPO1 + GRUPOA))

		oDados:Cell("INSS"	):SetValue( nBaseEncargos * 0.063)// Colocar um parametro para FAP
		oDados:Cell("FGTS"	):SetValue( nBaseEncargos * 0.08)
		oDados:Cell("TOTALENCARGOS"	):SetValue( oDados:Cell("INSS"):UVALUE + oDados:Cell("FGTS"):UVALUE  )

		nTotalGeral:= QRY->(RA_SALARIO+GRUPO0+GRUPO1+GRUPO2+GRUPO3+GRUPO4+GRUPO5+GRUPO6+GRUPO7+GRUPO8+GRUPO9+GRUPOA+GRUPOB+GRUPOC+GRUPOD+GRUPOE+GRUPOF+GRUPOG+GRUPOH)
		nTotalGeral+=oDados:Cell("TOTALENCARGOS"):UVALUE
		nTotalGeral+=oDados:Cell("FERIASMES"):UVALUE
		nTotalGeral+=oDados:Cell("13MES"):UVALUE

		oDados:Cell("TOTALGERAL"):SetValue(nTotalGeral)
		oDados:PrintLine()
		oDados:SetHeaderSection(.F.)    
	
	QRY->(dbSkip())		
				
	Enddo	
Else		
	MsgInfo("Nao foram encontrados registros para os parametros informados!")
    Return .F.
Endif
		
Return

/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    �  GeraPerg     � Autor � Tiago Santos      � Data �18.09.19 ���
��+----------+------------------------------------------------------------���
���Descri��o �  Atualiza SX1                                		      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function GeraPerg(cPerg) 
Local aRegs:= {}

aAdd(aRegs,{cPerg,"01","Filial"         ,"Filial De"        ,"Filial De"       ,"mv_ch1","C",02,0,0,"G"," ","mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"02","Filial Ate"     ,"Filial Ate"       ,"Filial Ate"      ,"mv_ch2","C",02,0,0,"G","naovazio()","mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"03","Area de"        ,"Are De"           ,"Centro Custo De" ,"mv_ch3","C",09,0,0,"G"," ","mv_par03","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SQB","",""})
aAdd(aRegs,{cPerg,"04","Area Ate"       ,"Are Ate"          ,"Centro Custo Ate","mv_ch4","C",09,0,0,"G","naovazio()","mv_par04","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SQB","",""})
aAdd(aRegs,{cPerg,"05","Centro Custo"   ,"Centro Custo De"  ,"Centro Custo De" ,"mv_ch5","C",09,0,0,"G"," ","mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"06","Centro Ate"     ,"Centro Custo Ate" ,"Centro Custo Ate","mv_ch6","C",09,0,0,"G","naovazio()","mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"07","Matricula"      ,"Matricula De"     ,"Matricula De"    ,"mv_ch7","C",06,0,0,"G"," ","mv_par07","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"08","Matricula Ate"  ,"Matricula Ate"    ,"Matricula Ate"   ,"mv_ch8","C",06,0,0,"G","naovazio()","mv_par08","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"09","Folha"          ,"Folha"            ,"Folha"           ,"mv_ch9","C",06,0,0,"G","naovazio()","mv_par09","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})

U_BuscaPerg(aRegs)

Return

// fun��o para retornar a query conforme tipo do relat�rio selecionado
static Function MontaQry ()                                   
Local cQuery := " " 
Local cProcesso := '00001'
Local cRotBlank := "FOL"
Local cPeriodo := mv_par09
Local Semana    := "01"     
Local aPerAberto := {}
Local aPerFechado := {}


cQuery := ' select coalesce("0", ' + "' ') Grupo0," 
cQuery += ' coalesce("1", ' + "' ') Grupo1," 
cQuery += ' coalesce("2", ' + "' ') Grupo2," 
cQuery += ' coalesce("3", ' + "' ') Grupo3," 
cQuery += ' coalesce("4", ' + "' ') Grupo4," 
cQuery += ' coalesce("5", ' + "' ') Grupo5," 
cQuery += ' coalesce("6", ' + "' ') Grupo6," 
cQuery += ' coalesce("7", ' + "' ') Grupo7," 
cQuery += ' coalesce("8", ' + "' ') Grupo8," 
cQuery += ' coalesce("9", ' + "' ') Grupo9," 
cQuery += ' coalesce("A", ' + "' ') GrupoA,"
cQuery += ' coalesce("B", ' + "' ') GrupoB," 
cQuery += ' coalesce("C", ' + "' ') GrupoC," 
cQuery += ' coalesce("D", ' + "' ') GrupoD," 
cQuery += ' coalesce("E", ' + "' ') GrupoE," 
cQuery += ' coalesce("F", ' + "' ') GrupoF," 
cQuery += ' coalesce("G", ' + "' ') GrupoG," 
cQuery += ' coalesce("H", ' + "' ') GrupoH," 

cQuery += " * from ( "

cQuery += " select RA_FILIAL, RA_MAT, RA_NOME,RA_CATFUNC, RA_ADMISSA, RA_CC,RV_GRPVERB, "
cQuery += " case when RV_TIPOCOD ='2' then RD_VALOR * -1 else  RD_VALOR End VALOR, " 
cQuery += " RJ_DESC, RA_SALARIO, QB_DESCRIC , RA_HRSMES"
cQuery +=" from " +RetSqlName("SRA")+" SRA"
cQuery +=" inner join " + RetSqlName("SRD")+" SRD on RA_FILIAL = RD_FILIAL and RA_MAT = RD_MAT "
cQuery +=" inner join " + RetSqlName("SRV")+" SRV on RD_PD = RV_COD"
cQuery +=" inner join " + RetSqlName("SRJ")+" SRJ on RA_CODFUNC = RJ_FUNCAO"          
cQuery +=" left join " + RetSqlName("SQB")+" SQB on RA_DEPTO = QB_DEPTO"
cQuery +=" Where SRA.D_E_L_E_T_ =' ' and SQB.D_E_L_E_T_ =' 'and  RD_FILIAL Between '" + mv_par01 +"' and '" + mv_par01 +"'" 
cquery +=" and RD_DEPTO Between '" + mv_par03 +"' and '" + mv_par04 +"'" 
cquery +=" and RD_CC Between '" + mv_par05 +"' and '" + mv_par06 +"'" 
cquery +=" and RD_MAT Between '" + mv_par07 +"' and '" + mv_par08 +"'" 
cquery +=" and RD_DATARQ ='" +mv_par09+ "') tabela"

cQuery +="  pivot ( "
cQuery +="   sum(VALOR) "
cQuery +='    for RV_GRPVERB in ("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H")  '
cQuery +="   )"
cQuery +="   piv"
cQuery +=" order by QB_DESCRIC " // Ordenação por área
				
return cQuery                   

static function RetSup(cMat, cCompetencia)
Local cRet :=" "           
Local cQuery1 :=" select TOP 1 * from " + RetSqlName("Z03") +" Z03 Where Z03.D_E_L_E_T_ =' '  and Z03_MAT ='" + cMat + "'"
Local cAtual :=" and  Substring(Z03_DATA,1,6)= '" + cCompetencia + "'"
Local cAnter :=" and  Substring(Z03_DATA,1,6)< '" + cCompetencia + "'"
Local cOrder :=" order by Z03_DATA desc, Z03_HORA desc"

If Select("QRY1")>0         
	QRY1->(dbCloseArea())
Endif

TcQuery cQuery1 + cAtual  + cOrder New Alias "QRY1"                          
If QRY1->(!Eof())
	cRet := QRY1->Z03_SUPERI
	
Else      
	If Select("QRY2")>0         
		QRY2->(dbCloseArea())
	Endif
	TcQuery cQuery1 + cAnter  + cOrder New Alias "QRY2"	
	If QRY2->(!Eof())
		cRet := QRY2->Z03_SUPERI
	Endif
Endif
return cRet