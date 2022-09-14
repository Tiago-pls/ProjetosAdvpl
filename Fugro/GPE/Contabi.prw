#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦  RCusOrcDH  ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦23.03.18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Relatório de Custos e Orçamento DH					      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function RCusOrcDH() 
                                                
Local cTitle    := OemToAnsi("Custos DH-Plano") //Título do relatório no cabeçalho
Local cHelp     := OemToAnsi("Custos DH-Plano")
Local cPerg		:= "CUSORCDH"
Local aOrdem 	:= {"Filial + Matrícula ","Filial + Centro de Custo","Filial + Verba"}
Local oRel
Local oDados

//Cria a pergunta de acordo com o tamanho da SX1
dbSelectArea("SX1")  
dbSetOrder(1)
cPerg := cPerg+Replicate(" ",Len(X1_GRUPO)- Len(cPerg))
		
//Carrega os Parâmetros
//********************************************************************************
GeraPerg(cPerg)

If !Pergunte(cPerg,.T.)
   Return
Endif


//Criacao do componente de impressão
oRel := tReport():New("Orcamento Plano",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)

//Seta a orientação do papel
oRel:SetLandscape()                      
oRel:SetDevice(4) //Seta impressão em planilha                      

//Inicia a Sessão
oDados := trSection():New(oRel,cTitle,{},aOrdem)  
//oDados:HeaderBreak()
oDados:SetHeaderBreak()
//Define o cabeçalho
trCell():New(oDados,"FILIAL"	,"QRY" ,"Filial"   		,"@!",03)
trCell():New(oDados,"ANO" 		,"QRY" ,"Ano"     		,"@!",04)
trCell():New(oDados,"VALOR" 	,"QRY" ,"Valor"    		,"@E 999,999,999.99",20,,,"RIGHT",,"RIGHT")
trCell():New(oDados,"MAT"    	,"QRY" ,"Matrícula" 	,"@!",10)
trCell():New(oDados,"NOME"		,"QRY" ,"Nome"   		,"@!",40)
trCell():New(oDados,"COD_FUNCAO","QRY" ,"Função"	   	,"@!",07)
trCell():New(oDados,"DESC_FUNCAO","QRY" ,"Descrição"   	,"@!",20)
trCell():New(oDados,"COD_VERBA"	,"QRY" ,"Verba"   		,"@!",06)
trCell():New(oDados,"DESC_VERBA","QRY" ,"Descrição"   	,"@!",20)                                                                                                          
trCell():New(oDados,"UNIDADE"	,"QRY" ,"Unidade"		,"@!",09)                                                                                                          
trCell():New(oDados,"COD_CC"	,"QRY" ,"Centro Custo"	,"@!",09)                                                                                                          
trCell():New(oDados,"DESC_CC"	,"QRY" ,"Descrição"		,"@!",09)                                                                                                          
trCell():New(oDados,"CONTA"		,"QRY" ,"Conta Contabil","@!",20) 

// Total de Funcionários por Filial
oBreak := TRBreak():New(oDados,oDados:Cell("FILIAL"),"Total")
TRFunction():New(oDados:Cell("VALOR"),NIL,"SUM",oBreak,,,,.F.,.F.) 

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

//Definição das variáveis
//********************************************************************************
Local oDados  	:= oRel:Section(1)
Local nOrdem  	:= oDados:GetOrder()

Local cFilDe	:= mv_par01
Local cFilAte 	:= mv_par02
Local cPeriodo	:= mv_par03
Local cCusDe 	:= mv_par04
Local cCusAte 	:= mv_par05
Local cMatDe 	:= mv_par06
Local cMatAte 	:= mv_par07
Local cVerbas 	:= Alltrim(mv_par08)
Local cWhere	:= ""
Local cWhere1	:= ""
Local cConta	:= ""

oDados:Init()

//Modifica variaveis para a Query
//********************************************************************************
If nOrdem == 1
	cOrdem:= "FILIAL, MAT"
Elseif nOrdem == 2
	cOrdem:= "FILIAL, COD_CC"
Else
	cOrdem:= "FILIAL, COD_VERBA"
Endif

cVerbaQry := ""
For nReg:=1 to Len(cVerbas) Step 3
	cVerbaQry += "'"+Subs(cVerbas,nReg,3)+"'"
	If ( nReg+1 ) <= Len(cVerbas)
		cVerbaQry += "," 
	Endif
Next nReg
If Len(cVerbaQry) >=4
	cVerbaQry:= Substr(cVerbaQry,1,Len(cVerbaQry)-1)
Endif	        
cVerbaQry :=  StrTran(cVerbaQry,'*','')

If !Empty(cFilAte)
	cWhere+= " AND RD_FILIAL BETWEEN '"+cFilDe+"' and '"+cFilAte+"'"
	cWhere1+= " AND RT_FILIAL BETWEEN '"+cFilDe+"' and '"+cFilAte+"'"
Endif
If !Empty(cCusAte)
	cWhere+= " AND RD_CC BETWEEN '"+cCusDe+"' and '"+cCusAte+"'"
	cWhere1+= " AND RT_CC BETWEEN '"+cCusDe+"' and '"+cCusAte+"'"
Endif
If !Empty(cMatAte)	
	cWhere+= " AND RD_MAT BETWEEN '"+cMatDe+"' and '"+cMatAte+"'"
	cWhere1+= " AND RT_MAT BETWEEN '"+cMatDe+"' and '"+cMatAte+"'"
Endif
If Len(cVerbaQry)>3
	cWhere+= " AND RD_PD IN ("+cVerbaQry+")" 
	cWhere1+= " AND RT_VERBA IN ("+cVerbaQry+")" 
Endif


//Trata o período anterior para uso na SRT
cPerAnt:= AnoMes(MonthSub(stod(cPeriodo+'01'),1))
		
//Seleciona os registros
//********************************************************************************
If Select("QRY") > 0         
	QRY->(dbCloseArea())
Endif


cQry:= "	WITH QRYMESANT AS ( "+chr(13)+chr(10)
cQry+= "		SELECT RT_FILIAL FILIAL, "+chr(13)+chr(10)
cQry+= "			SUBSTRING('"+cPeriodo+"',5,2) MES, SUBSTRING('"+cPeriodo+"',1,4) ANO, "+chr(13)+chr(10)
cQry+= "			RT_VALOR - COALESCE((SELECT B.RT_VALOR FROM "+RetSqlName("SRT")+" B WHERE SRT.RT_FILIAL = B.RT_FILIAL AND SRT.RT_MAT = B.RT_MAT "+chr(13)+chr(10)
//Baixa férias
cQry+= "                  AND SRT.RT_CC = B.RT_CC AND B.RT_VERBA = CASE"+chr(13)+chr(10) 
cQry+= "                  	WHEN SRT.RT_VERBA = '911' THEN '778' "+chr(13)+chr(10) //BAIXA PROVISAO DE FERIAS 
cQry+= "                  	WHEN SRT.RT_VERBA = '915' THEN '779' "+chr(13)+chr(10) //BAIXA INSS PROV. FERIAS
cQry+= "                  	WHEN SRT.RT_VERBA = '917' THEN '780' "+chr(13)+chr(10) //BAIXA FGTS PROV. FERIAS
cQry+= "                  	WHEN SRT.RT_VERBA = '919' THEN '781' "+chr(13)+chr(10) //BAIXA ADIC. PROV. FERIAS
cQry+= "                  	WHEN SRT.RT_VERBA = '913' THEN '782' "+chr(13)+chr(10) //BAIXA 1/3 PROVISAO FERIAS
cQry+= "                  	ELSE '0' END "+chr(13)+chr(10)
cQry+= "                  AND SUBSTRING(B.RT_DATACAL,1,6) = '"+cPeriodo+"' AND SRT.RT_TIPPROV = B.RT_TIPPROV AND B.D_E_L_E_T_ = ' '),0) "+chr(13)+chr(10)
//Baixa transferência
cQry+= "				- COALESCE((SELECT B.RT_VALOR FROM "+RetSqlName("SRT")+" B WHERE SRT.RT_FILIAL = B.RT_FILIAL AND SRT.RT_MAT = B.RT_MAT "+chr(13)+chr(10)
cQry+= "                  AND SRT.RT_CC = B.RT_CC "+chr(13)+chr(10)
cQry+= "                  AND B.RT_VERBA = CASE "+chr(13)+chr(10)
cQry+= "                  	WHEN SRT.RT_VERBA = '911' THEN '957'"+chr(13)+chr(10) //BAIXA PROV.TRANSF
cQry+= "                  	WHEN SRT.RT_VERBA = '919' THEN '958'"+chr(13)+chr(10) //BAIXA ADIC.TRANSF
cQry+= "                  	WHEN SRT.RT_VERBA = '913' THEN '959'"+chr(13)+chr(10) //BAIXA 1/3 TRANSF
cQry+= "                  	WHEN SRT.RT_VERBA = '915' THEN '960'"+chr(13)+chr(10) //BAIXA INSS TRANSF
cQry+= "                  	WHEN SRT.RT_VERBA = '917' THEN '961'"+chr(13)+chr(10) //BAIXA FGTS TRANSF
cQry+= "                  	WHEN SRT.RT_VERBA = '901' THEN '967'"+chr(13)+chr(10) //BAIXA 13.SAL.TRANSF
cQry+= "                  	WHEN SRT.RT_VERBA = '919' THEN '968'"+chr(13)+chr(10) //BAIXA ADIC.13 TRANSF
cQry+= "                  	WHEN SRT.RT_VERBA = '903' THEN '969'"+chr(13)+chr(10) //BAIXA INSS 13 TRANSF
cQry+= "                  	WHEN SRT.RT_VERBA = '905' THEN '970'"+chr(13)+chr(10) //BAIXA FGTS 13 TRANSF
cQry+= "                  	ELSE '0' END "+chr(13)+chr(10)

cQry+= "                  AND SUBSTRING(B.RT_DATACAL,1,6) = '"+cPeriodo+"' AND SRT.RT_TIPPROV = B.RT_TIPPROV AND B.D_E_L_E_T_ = ' '),0) "+chr(13)+chr(10)
//Baixa demissão
cQry+= "				- COALESCE((SELECT B.RT_VALOR FROM "+RetSqlName("SRT")+" B WHERE SRT.RT_FILIAL = B.RT_FILIAL AND SRT.RT_MAT = B.RT_MAT "+chr(13)+chr(10)
cQry+= "                  AND SRT.RT_CC = B.RT_CC AND B.RT_VERBA = CASE "+chr(13)+chr(10)
cQry+= "                  	WHEN SRT.RT_VERBA = '911' THEN '962' "+chr(13)+chr(10) //BAIXA PROV.DEMITIDO
cQry+= "                  	WHEN SRT.RT_VERBA = '919' THEN '963' "+chr(13)+chr(10) //BAIXA ADIC.DEMITIDO
cQry+= "                  	WHEN SRT.RT_VERBA = '913' THEN '964' "+chr(13)+chr(10) //BAIXA 1/3 DEMITIDO
cQry+= "                  	WHEN SRT.RT_VERBA = '915' THEN '965' "+chr(13)+chr(10) //BAIXA INSS DEMITIDO
cQry+= "                  	WHEN SRT.RT_VERBA = '917' THEN '966' "+chr(13)+chr(10) //BAIXA FGTS DEMITIDO
cQry+= "                  	WHEN SRT.RT_VERBA = '901' THEN '971' "+chr(13)+chr(10) //BAIXA 13.SAL.DEMITIDO
cQry+= "                  	WHEN SRT.RT_VERBA = '919' THEN '972' "+chr(13)+chr(10) //BAIXA ADIC 13 DEMITIDO
cQry+= "                  	WHEN SRT.RT_VERBA = '903' THEN '973' "+chr(13)+chr(10) //BAIXA INSS 13.DEMITIDO
cQry+= "                  	WHEN SRT.RT_VERBA = '905' THEN '974' "+chr(13)+chr(10) //BAIXA FGTS 13 DEMITIDO
cQry+= "                  	ELSE '0' END "+chr(13)+chr(10)
cQry+= "                  AND SUBSTRING(B.RT_DATACAL,1,6) = '"+cPeriodo+"' AND SRT.RT_TIPPROV = B.RT_TIPPROV AND B.D_E_L_E_T_ = ' '),0) RT_VALOR, "+chr(13)+chr(10)
cQry+= " 			RT_TIPPROV, RT_MAT MAT, RA_NOME NOME, RA_CODFUNC COD_FUNCAO, "+chr(13)+chr(10)
cQry+= "			SRJ.RJ_DESC DESC_FUNCAO, RT_VERBA COD_VERBA, RV_DESC DESC_VERBA, RT_CC COD_CC, CTT_DESC01 DESC_CC, CT5_CREDIT,CT5_DEBITO, "+chr(13)+chr(10)
cQry+= "		    CASE WHEN CT5_DEBITO = ' ' OR SUBSTRING(RT_VERBA,1,1) = '7' THEN CT5_CREDIT ELSE CT5_DEBITO END CONTA, '' AS TIPO  "+chr(13)+chr(10)
cQry+= "        FROM "+RetSqlName("SRT")+" SRT "+chr(13)+chr(10)
        
cQry+= "        INNER JOIN "+RetSqlName("SRV")+" SRV ON RV_COD = RT_VERBA AND SRV.D_E_L_E_T_ = ' ' "
cQry+= "		INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = RT_FILIAL AND RA_MAT = RT_MAT AND SRA.D_E_L_E_T_ = ' ' "+chr(13)+chr(10)
cQry+= "		INNER JOIN "+RetSqlName("SRJ")+" SRJ ON SRJ.RJ_FUNCAO = RA_CODFUNC AND SRJ.D_E_L_E_T_ = ' ' "+chr(13)+chr(10)
cQry+= "		INNER JOIN "+RetSqlName("CTT")+" CTT ON CTT_CUSTO = RT_CC AND CTT.D_E_L_E_T_ = ' '  "+chr(13)+chr(10)
cQry+= "		INNER JOIN "+RetSqlName("CT5")+" CT5 ON CT5_LANPAD = SRV.RV_LCTOP AND CT5.D_E_L_E_T_ = ' ' "+chr(13)+chr(10) 
        
cQry+= "        WHERE SRT.D_E_L_E_T_ = ' ' "+chr(13)+chr(10) 
cQry+= cWhere1 +chr(13)+chr(10)
cQry+= "			AND ((RT_VALOR > 0 AND CT5_SEQUEN = '001') OR (RT_VALOR < 0 AND CT5_SEQUEN = '002')) "+chr(13)+chr(10)
cQry+= "			AND SUBSTRING(RT_DATACAL,1,6) = CASE WHEN RV_DESC LIKE 'BAIXA%' THEN '204999' ELSE '"+cPerAnt+"' END "+chr(13)+chr(10) 

cQry+= "	), QRYMESATU AS ( "+chr(13)+chr(10)
cQry+= "		SELECT RT_FILIAL FILIAL, SUBSTRING(RT_DATACAL,5,2) MES, SUBSTRING(RT_DATACAL,1,4) ANO, 
cQry+= "			RT_VALOR  " 
//Transferencia
cQry+= "			 + COALESCE((SELECT B.RT_VALOR FROM "+RetSqlName("SRT")+" B WHERE SRT.RT_FILIAL = B.RT_FILIAL AND SRT.RT_MAT = B.RT_MAT "+chr(13)+chr(10)
cQry+= "                  AND B.RT_CC  = (SELECT RE_CCD FROM "+RetSqlName("SRE")+" SRE WHERE RE_FILIALD = B.RT_FILIAL AND RE_MATD = B.RT_MAT 
cQry+= "                  AND SUBSTRING(RE_DATA,1,6) = '"+cPeriodo+"' AND SRE.D_E_L_E_T_ = ' ')
cQry+= "                  AND B.RT_VERBA = CASE "+chr(13)+chr(10)
cQry+= "                  	WHEN SRT.RT_VERBA = '911' THEN '957'"+chr(13)+chr(10) //BAIXA PROV.TRANSF
cQry+= "                  	WHEN SRT.RT_VERBA = '919' THEN '958'"+chr(13)+chr(10) //BAIXA ADIC.TRANSF
cQry+= "                  	WHEN SRT.RT_VERBA = '913' THEN '959'"+chr(13)+chr(10) //BAIXA 1/3 TRANSF
cQry+= "                  	WHEN SRT.RT_VERBA = '915' THEN '960'"+chr(13)+chr(10) //BAIXA INSS TRANSF
cQry+= "                  	WHEN SRT.RT_VERBA = '917' THEN '961'"+chr(13)+chr(10) //BAIXA FGTS TRANSF
cQry+= "                  	WHEN SRT.RT_VERBA = '901' THEN '967'"+chr(13)+chr(10) //BAIXA 13.SAL.TRANSF
cQry+= "                  	WHEN SRT.RT_VERBA = '919' THEN '968'"+chr(13)+chr(10) //BAIXA ADIC.13 TRANSF
cQry+= "                  	WHEN SRT.RT_VERBA = '903' THEN '969'"+chr(13)+chr(10) //BAIXA INSS 13 TRANSF
cQry+= "                  	WHEN SRT.RT_VERBA = '905' THEN '970'"+chr(13)+chr(10) //BAIXA FGTS 13 TRANSF
cQry+= "                  	ELSE '0' END "+chr(13)+chr(10)
cQry+= "                  AND SUBSTRING(B.RT_DATACAL,1,6) = '"+cPeriodo+"' AND B.RT_TIPPROV = '1' AND B.D_E_L_E_T_ = ' ' "+chr(13)+chr(10)
cQry+= "                  AND NOT EXISTS (SELECT RT_VALOR FROM "+RetSqlName("SRT")+" A WHERE SRT.RT_FILIAL = A.RT_FILIAL AND SRT.RT_MAT = A.RT_MAT "+chr(13)+chr(10) 
cQry+= "                  AND SRT.RT_CC = A.RT_CC AND SRT.RT_DATACAL = A.RT_DATACAL AND A.RT_VERBA = '911' AND A.RT_TIPPROV = '1' AND A.D_E_L_E_T_ = ' ')),0) "+chr(13)+chr(10)
//Baixa férias
cQry+= " 			 + COALESCE((SELECT B.RT_VALOR FROM "+RetSqlName("SRT")+" B WHERE SRT.RT_FILIAL = B.RT_FILIAL AND SRT.RT_MAT = B.RT_MAT "+chr(13)+chr(10)
cQry+= "                  AND SRT.RT_CC = B.RT_CC "+chr(13)+chr(10)
cQry+= "                  AND B.RT_VERBA = CASE "+chr(13)+chr(10)
cQry+= "                  	WHEN SRT.RT_VERBA = '911' THEN '778' "+chr(13)+chr(10) //BAIXA PROVISAO DE FERIAS 
cQry+= "                  	WHEN SRT.RT_VERBA = '915' THEN '779' "+chr(13)+chr(10) //BAIXA INSS PROV. FERIAS
cQry+= "                  	WHEN SRT.RT_VERBA = '917' THEN '780' "+chr(13)+chr(10) //BAIXA FGTS PROV. FERIAS
cQry+= "                  	WHEN SRT.RT_VERBA = '919' THEN '781' "+chr(13)+chr(10) //BAIXA ADIC. PROV. FERIAS
cQry+= "                  	WHEN SRT.RT_VERBA = '913' THEN '782' "+chr(13)+chr(10) //BAIXA 1/3 PROVISAO FERIAS
cQry+= "                  	ELSE '0' END "+chr(13)+chr(10)
cQry+= "                  AND SUBSTRING(B.RT_DATACAL,1,6) = '"+cPeriodo+"' AND B.RT_TIPPROV = '1' AND B.D_E_L_E_T_ = ' ' "+chr(13)+chr(10)
cQry+= "				    AND EXISTS (SELECT RD_PD FROM "+RetSqlName("SRD")+" A WHERE B.RT_FILIAL = A.RD_FILIAL AND B.RT_MAT = A.RD_MAT "+chr(13)+chr(10)
cQry+= "								AND SUBSTRING(B.RT_DATACAL,1,6) = A.RD_DATARQ AND RD_PD = '221' AND A.D_E_L_E_T_ = ' ' " //221 - VERBA LIQUIDO DE FÉRIAS  
cQry+= "								)"+chr(13)+chr(10)

cQry+= "					AND EXISTS (SELECT RT_VERBA FROM "+RetSqlName("SRT")+" C "+chr(13)+chr(10)
cQry+= "					            WHERE SRT.RT_FILIAL = C.RT_FILIAL AND SRT.RT_MAT = C.RT_MAT AND SRT.RT_CC = C.RT_CC "+chr(13)+chr(10) 
cQry+= "					            AND ((C.RT_VERBA = '778' AND C.RT_DFERVEN = 30 AND C.RT_DFERPRO = 0 AND C.RT_DFERANT > 0 AND C.D_E_L_E_T_ = ' ') "+chr(13)+chr(10)
cQry+= "					            )"+chr(13)+chr(10) //OR (C.RT_VERBA = B.RT_VERBA AND C.RT_VERBA <> '778')
cQry+= "								)"+chr(13)+chr(10)
cQry+= " 			),0)"+chr(13)+chr(10)    

cQry+= "			RT_VALOR, "+chr(13)+chr(10)
cQry+= "			RT_TIPPROV, RT_MAT MAT, RA_NOME NOME, RA_CODFUNC COD_FUNCAO, SRJ.RJ_DESC DESC_FUNCAO, RT_VERBA COD_VERBA, RV_DESC DESC_VERBA, RT_CC COD_CC, "+chr(13)+chr(10) 
cQry+= "			CTT_DESC01 DESC_CC, CT5_CREDIT,CT5_DEBITO, CASE WHEN CT5_DEBITO = ' ' OR SUBSTRING(RT_VERBA,1,1) = '7' THEN CT5_CREDIT ELSE CT5_DEBITO END CONTA, '' AS TIPO "+chr(13)+chr(10)
cQry+= "		FROM "+RetSqlName("SRT")+" SRT "+chr(13)+chr(10)
cQry+= "		INNER JOIN "+RetSqlName("SRV")+" SRV ON RV_COD = RT_VERBA AND SRV.D_E_L_E_T_ = ' ' "+chr(13)+chr(10) 
cQry+= "		INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = RT_FILIAL AND RA_MAT = RT_MAT AND SRA.D_E_L_E_T_ = ' ' " +chr(13)+chr(10)
cQry+= "		INNER JOIN "+RetSqlName("SRJ")+" SRJ ON SRJ.RJ_FUNCAO = RA_CODFUNC AND SRJ.D_E_L_E_T_ = ' ' "+chr(13)+chr(10) 
cQry+= "		INNER JOIN "+RetSqlName("CTT")+" CTT ON CTT_CUSTO = RT_CC AND CTT.D_E_L_E_T_ = ' ' " +chr(13)+chr(10)
cQry+= "		INNER JOIN "+RetSqlName("CT5")+" CT5 ON CT5_LANPAD = SRV.RV_LCTOP AND CT5.D_E_L_E_T_ = ' ' "  +chr(13)+chr(10)
cQry+= "		WHERE SRT.D_E_L_E_T_ = ' ' " +chr(13)+chr(10)
cQry+= 	cWhere1 +chr(13)+chr(10)
cQry+= "		AND ((RT_VALOR > 0 AND CT5_SEQUEN = '001') OR (RT_VALOR < 0 AND CT5_SEQUEN = '002'))  "+chr(13)+chr(10)
cQry+= "		AND SUBSTRING(RT_DATACAL,1,6) = '"+cPeriodo+"' "+chr(13)+chr(10) 
cQry+= "	)  "+chr(13)+chr(10)
//Provisões
cQry+= "	SELECT COALESCE(A.FILIAL, B.FILIAL) AS FILIAL, COALESCE(A.MES, B.MES) AS MES, COALESCE(A.ANO, B.ANO) AS ANO, COALESCE(A.RT_VALOR, 0) - COALESCE(B.RT_VALOR, 0) AS VALOR, "+chr(13)+chr(10)
cQry+= "	    COALESCE(A.MAT, B.MAT) AS MAT, COALESCE(A.NOME, B.NOME) AS NOME, COALESCE(A.COD_FUNCAO, B.COD_FUNCAO) AS COD_FUNCAO, "+chr(13)+chr(10)
cQry+= "		COALESCE(A.DESC_FUNCAO, B.DESC_FUNCAO) AS DESC_FUNCAO, COALESCE(A.COD_VERBA, B.COD_VERBA) AS COD_VERBA, COALESCE(A.DESC_VERBA, B.DESC_VERBA) AS DESC_VERBA, "+chr(13)+chr(10)
cQry+= "		COALESCE(A.COD_CC, B.COD_CC) AS COD_CC, COALESCE(A.DESC_CC, B.DESC_CC) AS DESC_CC, COALESCE(A.CT5_CREDIT,B.CT5_CREDIT) AS CT5_CREDIT, COALESCE(A.CT5_DEBITO, B.CT5_DEBITO) AS CT5_DEBITO, "+chr(13)+chr(10)
cQry+= "	    COALESCE(A.CONTA, B.CONTA) AS CONTA, '' AS TIPO "+chr(13)+chr(10)
cQry+= "	FROM QRYMESATU A "+chr(13)+chr(10)
cQry+= "  	FULL OUTER JOIN QRYMESANT B ON A.FILIAL = B.FILIAL AND A.MAT = B.MAT AND A.COD_CC = B.COD_CC AND A.COD_VERBA = B.COD_VERBA "+chr(13)+chr(10)
cQry+= "      AND A.RT_TIPPROV = B.RT_TIPPROV "+chr(13)+chr(10)
/*
cQry+= "	UNION ALL "
//Baixa provisões 

cQry+= "	SELECT RT_FILIAL FILIAL, SUBSTR("+cPeriodo+" ,5,2) MES, SUBSTR("+cPeriodo+" ,1,4) ANO, RT_VALOR VALOR, " 
cQry+= "			RT_MAT MAT, RA_NOME NOME, RA_CODFUNC COD_FUNCAO, SRJ.RJ_DESC DESC_FUNCAO, "
cQry+= "			RT_VERBA COD_VERBA, RV_DESC DESC_VERBA, RT_CC COD_CC, CTT_DESC01 DESC_CC, CT5_CREDIT,CT5_DEBITO, " 
cQry+= "			CASE WHEN CT5_DEBITO = ' ' OR SUBSTR(RT_VERBA,1,1) = '7' THEN CT5_CREDIT ELSE CT5_DEBITO END CONTA, ' ' AS TIPO  "
cQry+= "	FROM  "+RetSqlName("SRT")+" SRT "
cQry+= "	INNER JOIN "+RetSqlName("SRV")+" SRV ON RV_COD = RT_VERBA AND SRV.D_E_L_E_T_ = ' ' "
cQry+= "	INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = RT_FILIAL AND RA_MAT = RT_MAT AND SRA.D_E_L_E_T_ = ' ' "
cQry+= "	INNER JOIN "+RetSqlName("SRJ")+" SRJ ON SRJ.RJ_FUNCAO = RA_CODFUNC AND SRJ.D_E_L_E_T_ = ' ' "
cQry+= "	INNER JOIN "+RetSqlName("CTT")+" CTT ON CTT_CUSTO = RT_CC AND CTT.D_E_L_E_T_ = ' ' "
cQry+= "	INNER JOIN "+RetSqlName("CT5")+" CT5 ON CT5_LANPAD = SRV.RV_LCTOP AND CT5.D_E_L_E_T_ = ' ' "	
cQry+= "	WHERE 
cQry+= "		SRT.D_E_L_E_T_ = ' ' " 
cQry+= "		AND ((RT_VALOR > 0 AND CT5_SEQUEN = '001') OR (RT_VALOR < 0 AND CT5_SEQUEN = '002'))    
cQry+= cWhere1  
cQry+= "		AND SUBSTR(RT_DATACAL,1,6) = '"+cPeriodo+"' "  
cQry+= "		AND RT_TIPPROV = '1' AND RT_VERBA IN ('960','961') "	   
  */
cQry+= "	UNION ALL "+chr(13)+chr(10)
//Folha
cQry+= "	SELECT RD_FILIAL FILIAL, SUBSTRING(RD_DATARQ,5,2) MES, SUBSTRING(RD_DATARQ,1,4) ANO, RD_VALOR VALOR, RD_MAT MAT, RA_NOME NOME, RA_CODFUNC COD_FUNCAO, "+chr(13)+chr(10) 
cQry+= "		SRJ.RJ_DESC DESC_FUNCAO, RD_PD COD_VERBA, RV_DESC DESC_VERBA, RD_CC COD_CC, CTT_DESC01 DESC_CC, CT5_CREDIT, CT5_DEBITO, "+chr(13)+chr(10)
cQry+= "		CASE WHEN CT5_DEBITO = ' ' THEN CT5_CREDIT ELSE CT5_DEBITO END CONTA, '' AS TIPO "+chr(13)+chr(10)
cQry+= "	FROM "+RetSqlName("SRD")+" SRD "+chr(13)+chr(10)	
cQry+= "	INNER JOIN "+RetSqlName("SRV")+" SRV ON RV_COD = RD_PD AND SRV.D_E_L_E_T_ = ' ' " +chr(13)+chr(10)
cQry+= "	INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = RD_FILIAL AND RA_MAT = RD_MAT AND SRA.D_E_L_E_T_ = ' ' " +chr(13)+chr(10)
cQry+= "	INNER JOIN "+RetSqlName("SRJ")+" SRJ ON SRJ.RJ_FUNCAO = RA_CODFUNC AND SRJ.D_E_L_E_T_ = ' ' " +chr(13)+chr(10)
cQry+= "	INNER JOIN "+RetSqlName("CTT")+" CTT ON CTT_CUSTO = RD_CC AND CTT.D_E_L_E_T_ = ' ' " +chr(13)+chr(10)
cQry+= "	INNER JOIN "+RetSqlName("CT5")+" CT5 ON CT5_LANPAD = SRV.RV_LCTOP AND CT5_SEQUEN = '001' AND CT5.D_E_L_E_T_ = ' ' "+chr(13)+chr(10)  
cQry+= "	WHERE "+chr(13)+chr(10)
cQry+= "		SRD.D_E_L_E_T_ = ' ' " +chr(13)+chr(10)
cQry+= "	    AND RD_DATARQ = '"+cPeriodo+"' "+chr(13)+chr(10) 
cQry+= "	    AND RD_PD NOT IN('842','931') "+chr(13)+chr(10)
cQry+= cWhere +chr(13)+chr(10)
cQry+= " ORDER BY "+cOrdem +chr(13)+chr(10)
conout("### Query REL ORÇAMENTO ### "+chr(13)+chr(10)+cQry)		
TcQuery cQry New Alias "QRY"


If QRY->(!Eof()) 
	While QRY->(!Eof()) .and. !oRel:Cancel()  
	    	
		//Cancelado pelo usuário
		If oRel:Cancel()
			Exit
		EndIf
		
		If QRY->VALOR == 0
			QRY->(dbSkip())
		Endif	
		oRel:IncMeter(10)		
		
		//Define os campos fora da query
		oDados:Cell("FILIAL"):Disable()
		oDados:Cell("UNIDADE"):SetValue(cEmpAnt)
        //Posiciona na SRA
        Posicione("SRA",1,xFilial("SRA")+QRY->MAT,"RA_NOME")
        
        Do Case
        	//13º salário
			Case QRY->COD_VERBA = '967' 
				cConta := '46121911401'
			Case QRY->COD_VERBA = '968'
				cConta := '46121911401'
			Case QRY->COD_VERBA = '971'
				cConta := '46121911401'
			Case QRY->COD_VERBA = '972'
				cConta := '46121911401'
			
			//Férias	
			Case QRY->COD_VERBA = '957' 
				cConta := '46121911402'
			Case QRY->COD_VERBA = '958'
				cConta := '46121911402'
			Case QRY->COD_VERBA = '959'
				cConta := '46121911402'
			Case QRY->COD_VERBA = '963'
				cConta := '46121911402'
			Case QRY->COD_VERBA = '964'
				cConta := '46121911402'
			Case QRY->COD_VERBA = '962'
				cConta := '46121911402'			
			
			//FGTS	
			Case QRY->COD_VERBA = '961' 
				cConta := '46141911201'
			Case QRY->COD_VERBA = '966'
				cConta := '46141911201'
			Case QRY->COD_VERBA = '970'
				cConta := '46141911201' 
				
			// INSS	
			Case QRY->COD_VERBA = '960' 
				cConta := '46141911101'
			Case QRY->COD_VERBA = '965'
				cConta := '46141911101'
			Case QRY->COD_VERBA = '969'
				cConta := '46141911101'
			Case QRY->COD_VERBA = '973'
				cConta := '46141911101'													
			Otherwise
				cConta:= &(QRY->CONTA)
		EndCase

        
        oDados:Cell("CONTA"):SetValue(cConta)
        cTipo:= Posicione("SRV",1,xFilial("SRV")+QRY->COD_VERBA,"RV_TIPOCOD")
        oDados:Cell("VALOR"):SetValue(IIf(cTipo = '2',QRY->VALOR*-1,QRY->VALOR))
//        oDados:Cell("VALOR"):SetValue(IIf(!Empty(QRY->CT5_DEBITO) .AND. QRY->TIPO = ' ' .AND. LEFT(QRY->COD_VERBA,1) <> '7' .AND. LEFT(QRY->DESC_VERBA,5) = 'BAIXA',QRY->VALOR*-1,QRY->VALOR))
        	
	    oDados:PrintLine()
	    
		QRY->(dbSkip())
		
	End
	
Else
	MsgInfo("Não foram encontrados registros para os parâmetros informados!")
    Return .F.
Endif

oDados:Finish()


Return



//  Cria as perguntas na SX1                               
//********************************************************************************

Static Function GeraPerg(cPerg) 

Local aRegs:= {}

aAdd(aRegs,{cPerg,'01','Filial De' 			,'','','mv_ch1','C',2,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','SM0','','',''})
aAdd(aRegs,{cPerg,'02','Filial Até'			,'','','mv_ch2','C',2,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','SM0','','',''})
aAdd(aRegs,{cPerg,'03','Ano/Mês 	' 		,'','','mv_ch3','C',6,0,0,'G','naovazio()','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
aAdd(aRegs,{cPerg,'04','Centro de Custo De' ,'','','mv_ch4','' ,TamSx3('RD_CC')[1],0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','CTT','','',''})
aAdd(aRegs,{cPerg,'05','Centro de Custo Até','','','mv_ch5','' ,TamSx3('RD_CC')[1],0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','CTT','','',''})
aAdd(aRegs,{cPerg,'06','Matrícula De'		,'','','mv_ch6','' ,TamSx3('RA_MAT')[1],0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','SRA','','',''})
aAdd(aRegs,{cPerg,'07','Matrícula Até'		,'','','mv_ch7','' ,TamSx3('RA_MAT')[1],0,0,'G','','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','SRA','','',''})
aAdd(aRegs,{cPerg,'08','Filtrar Verbas'		,'','','mv_ch8','' ,99,0,0,'G','fVerbas()','MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
