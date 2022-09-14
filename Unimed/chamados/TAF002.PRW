#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"

User Function TAF002

Processa({|| TAF002B()},"Aguarde Processando...")

Return


Static function TAF002B()

Local cPerg  := "TAF002"
Local cQuery := ""
Local aDados := {} 
Local cDir    := "C:\temp\"
Local cArq    := "query.txt"
Local nHandle := FCreate(cDir+cArq)                       

cPerg := PadR(cPerg,10," ")

VldPerg(cPerg)

if (!Pergunte(cPerg,.T.) )
	return
else
	cPeriodo := SubStr(DTOS(MV_PAR01),1,6)
Endif


oFwMsEx := NIL
cArq := ""
cDir := GetSrvProfString("Startpath","")
cWorkSheet := ""
cTable := ""
cDirTmp := GetTempPath()
cCadastro := "Gerar XML"

cUsuLog := Upper(UsrRetName(__cUserId))

//Alert(cValToChar(cUsuLog))
//001996 - Silvio  t0434
//001575-Thiago   38870
//001453-Laura    37280       

cAutoriza := AT( cUsuLog, u_ParGer('TAF001_001') ) 

If cAutoriza == 0
	MsgAlert('Usuário não autorizado para gerar esse relatório')
	return
Endif 

cStatusF := POSICIONE("RCH",6,cFilAnt+"00001FOL"+cPeriodo,"RCH_STATUS")

If cStatusF = "5"
//Alert("Folha Fechada")
cStatus := "F"
Else
//Alert("Folha Aberta")
cStatus := "A"
EndIf

If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIF

IF cStatus = "A"

cQuery:="	WITH ESOCIAL AS	"
cQuery+="	(	"
cQuery+="	SELECT 	"
cQuery+="	 C87_CODIGO CATEGORIA,	"
cQuery+="	 TRIM(C87_DESCRI) CATDESC,	"
cQuery+="	 T2M_CPFTRB CPF,	"
cQuery+="	 SUM(T2R_VALOR) ESOCIAL	"
cQuery+="	 FROM "+RetSQLName("T2M")+" T2M	"
cQuery+="	 INNER JOIN "+RetSQLName("T2R")+" T2R ON T2M_VERSAO = T2R_VERSAO AND T2R_TPVLR IN('000001','000004') AND T2R.D_E_L_E_T_ = ' '	"
cQuery+="	 INNER JOIN "+RetSQLName("C87")+" C87 ON C87_ID = T2R_CODCAT AND C87.D_E_L_E_T_ = ' '	"
cQuery+="	 WHERE 	"
cQuery+="	 T2M_ID = (SELECT MAX(T2M_ID) FROM "+RetSQLName("T2M")+" B WHERE B.T2M_PERAPU = T2M.T2M_PERAPU AND B.T2M_CPFTRB = T2M.T2M_CPFTRB AND T2M.D_E_L_E_T_ = ' ') AND	"
cQuery+="	 T2M_PERAPU  = '"+cPeriodo+"' AND 	"
cQuery+="	 T2M.D_E_L_E_T_ = ' ' GROUP BY T2M_CPFTRB, C87_CODIGO, C87_DESCRI	"
cQuery+="	) ,GERAL AS (	"
cQuery+="	SELECT	"
cQuery+="	"+cPeriodo+" PERIODO,	"
cQuery+="	RA_CIC CPF,	"
cQuery+="	RA_MAT MATRICULA,	"
cQuery+="	RA_NOME NOME,	"
cQuery+="	CASE RA_SITFOLH	"
cQuery+="	WHEN 'A' THEN 'AFASTADO'	"
cQuery+="	WHEN 'D' THEN 'DEMITIDO'	"
cQuery+="	WHEN 'F' THEN 'FÉRIAS'	"
cQuery+="	WHEN ' ' THEN 'NORMAL'	"
cQuery+="	END SITFOLHA,	"
cQuery+="	RC_CC CCUSTO,	"
cQuery+="	CTT_DESC01 DESCCC,	"
cQuery+="	RA_CATEFD CATESOCIAL,	"
cQuery+="	ESOCIAL.CATDESC,	"
cQuery+="	SUM(RC_VALOR) BASE_FOLHA,	"
cQuery+="	ESOCIAL.ESOCIAL BASE_ESOCIAL,	"
cQuery+="	ROUND(SUM(RC_VALOR) - ESOCIAL.ESOCIAL,2) DIFERENCA	"
cQuery+="	FROM "+RetSQLName("SRC")+" SRC	"
cQuery+="	INNER JOIN "+RetSQLName("SRA")+" SRA ON RA_FILIAL = RC_FILIAL AND RA_MAT = RC_MAT AND SRA.D_E_L_E_T_ = ' ' 	"
cQuery+="	INNER JOIN "+RetSQLName("SRV")+" SRV ON RV_COD = RC_PD AND RV_COD IN ("+u_ParGer('TAF002_001')+") AND SRV.D_E_L_E_T_ = ' '	"
cQuery+="	LEFT JOIN ESOCIAL ON ESOCIAL.CPF = RA_CIC AND ESOCIAL.CATEGORIA = RA_CATEFD	"
cQuery+="	INNER JOIN "+RetSQLName("CTT")+" CTT ON CTT_CUSTO = RC_CC AND CTT.D_E_L_E_T_ = ' '	"
cQuery+="	WHERE 	"
cQuery+="	SRC.D_E_L_E_T_ = ' '	"
cQuery+="	GROUP BY 	"
cQuery+="	RA_NOME, RA_CIC, ESOCIAL.ESOCIAL, RA_CATEFD, CATDESC, RC_CC, CTT_DESC01, RA_SITFOLH, RA_MAT	"
cQuery+="	)	"
cQuery+="	SELECT * FROM GERAL	"
cQuery+="	ORDER BY NOME,CATESOCIAL "

Else

cQuery:="	WITH ESOCIAL AS	"
cQuery+="	(	"
cQuery+="	SELECT 	"
cQuery+="	 C87_CODIGO CATEGORIA,	"
cQuery+="	 TRIM(C87_DESCRI) CATDESC,	"
cQuery+="	 T2M_CPFTRB CPF,	"
cQuery+="	 SUM(T2R_VALOR) ESOCIAL	"
cQuery+="	 FROM "+RetSQLName("T2M")+" T2M	"
cQuery+="	 INNER JOIN "+RetSQLName("T2R")+" T2R ON T2M_VERSAO = T2R_VERSAO AND T2R_TPVLR IN('000001','000004') AND T2R.D_E_L_E_T_ = ' '	"
cQuery+="	 INNER JOIN "+RetSQLName("C87")+" C87 ON C87_ID = T2R_CODCAT AND C87.D_E_L_E_T_ = ' '	"
cQuery+="	 WHERE 	"
cQuery+="	 T2M_ID = (SELECT MAX(T2M_ID) FROM "+RetSQLName("T2M")+" B WHERE B.T2M_PERAPU = T2M.T2M_PERAPU AND B.T2M_CPFTRB = T2M.T2M_CPFTRB AND T2M.D_E_L_E_T_ = ' ') AND	"
cQuery+="	 T2M_PERAPU  = '"+cPeriodo+"' AND 	"
cQuery+="	 T2M.D_E_L_E_T_ = ' ' GROUP BY T2M_CPFTRB, C87_CODIGO, C87_DESCRI	"
cQuery+="	) ,GERAL AS (	"
cQuery+="	SELECT	"
cQuery+="	RD_DATARQ PERIODO,	"
cQuery+="	RA_CIC CPF,	"
cQuery+="	RA_MAT MATRICULA,	"
cQuery+="	RA_NOME NOME,	"
cQuery+="	CASE RA_SITFOLH	"
cQuery+="	WHEN 'A' THEN 'AFASTADO'	"
cQuery+="	WHEN 'D' THEN 'DEMITIDO'	"
cQuery+="	WHEN 'F' THEN 'FÉRIAS'	"
cQuery+="	WHEN ' ' THEN 'NORMAL'	"
cQuery+="	END SITFOLHA,	"
cQuery+="	RD_CC CCUSTO,	"
cQuery+="	CTT_DESC01 DESCCC,	"
cQuery+="	RA_CATEFD CATESOCIAL,	"
cQuery+="	ESOCIAL.CATDESC,	"
cQuery+="	SUM(RD_VALOR) BASE_FOLHA,	"
cQuery+="	ESOCIAL.ESOCIAL BASE_ESOCIAL,	"
cQuery+="	ROUND(SUM(RD_VALOR) - ESOCIAL.ESOCIAL,2) DIFERENCA	"
cQuery+="	FROM "+RetSQLName("SRD")+" SRD	"
cQuery+="	INNER JOIN "+RetSQLName("SRA")+" SRA ON RA_FILIAL = RD_FILIAL AND RA_MAT = RD_MAT AND SRA.D_E_L_E_T_ = ' ' 	"
cQuery+="	INNER JOIN "+RetSQLName("SRV")+" SRV ON RV_COD = RD_PD AND RV_COD IN ("+u_ParGer('TAF002_001')+") AND SRV.D_E_L_E_T_ = ' '	"
cQuery+="	LEFT JOIN ESOCIAL ON ESOCIAL.CPF = RA_CIC AND ESOCIAL.CATEGORIA = RA_CATEFD	"
cQuery+="	INNER JOIN "+RetSQLName("CTT")+" CTT ON CTT_CUSTO = RD_CC AND CTT.D_E_L_E_T_ = ' '	"
cQuery+="	WHERE 	"
cQuery+="	RD_EMPRESA = '  ' AND	"
cQuery+="	RD_DATARQ = '"+cPeriodo+"' AND	"
cQuery+="	SRD.D_E_L_E_T_ = ' '	"
cQuery+="	GROUP BY 	"
cQuery+="	RA_NOME, RA_CIC, ESOCIAL.ESOCIAL, RA_CATEFD, CATDESC, RD_CC, CTT_DESC01, RA_SITFOLH, RD_DATARQ, RA_MAT	"
cQuery+="	)	"
cQuery+="	SELECT * FROM GERAL	"
//cQuery+="	WHERE DIFERENCA <> 0	"
cQuery+="	ORDER BY NOME,CATESOCIAL "

EndIf

TCQUERY cQuery NEW ALIAS "QRY"

//FWrite(nHandle, cQuery + CRLF)

QRY->(dbGoTop())

if (QRY->(Eof()))
	MsgAlert('Não existe relação para os parâmetros informados!')
	QRY->(DbCloseArea())
	return
endif

nCount := 0
Count To nCount
QRY->(dbGoTop())
                                    
cWorkSheet := "Retorno Inss Protheus"

cTable     := ""
oFwMsEx := FWMsExcel():New()

oFwMsEx:AddWorkSheet( cWorkSheet )
oFwMsEx:AddTable( cWorkSheet, cTable )
oFwMsEx:AddColumn( cWorkSheet, cTable, "Período",2,2)
oFwMsEx:AddColumn( cWorkSheet, cTable, "C.P.F.",2,1) 
oFwMsEx:AddColumn( cWorkSheet, cTable, "Matrícula",2,1)
oFwMsEx:AddColumn( cWorkSheet, cTable, "Nome",2,1)
oFwMsEx:AddColumn( cWorkSheet, cTable, "Sit.Folha",2,1)
oFwMsEx:AddColumn( cWorkSheet, cTable, "C.Custo",2,1) 
oFwMsEx:AddColumn( cWorkSheet, cTable, "Desc. C.Custo",2,1)                          
oFwMsEx:AddColumn( cWorkSheet, cTable, "Categ.",2,1)
oFwMsEx:AddColumn( cWorkSheet, cTable, "Desc.Categ.",2,1)
oFwMsEx:AddColumn( cWorkSheet, cTable, "Base Folha",2,2)
oFwMsEx:AddColumn( cWorkSheet, cTable, "Base e-Social",2,2)
oFwMsEx:AddColumn( cWorkSheet, cTable, "Diferença",2,2)

ProcRegua(RecCount("QRY"))

While !QRY->(Eof())

	Incproc(cValToChar(QRY->CPF) + "-"+ cValToChar(ALLTRIM(QRY->NOME)) )
	        
   		oFwMsEx:AddRow( cWorkSheet, cTable, {SubStr(cValToChar(QRY->PERIODO),5,2)+"/"+SubStr(cValToChar(QRY->PERIODO),1,4),QRY->CPF,QRY->MATRICULA,QRY->NOME,QRY->SITFOLHA,QRY->CCUSTO,QRY->DESCCC,QRY->CATESOCIAL,QRY->CATDESC,QRY->BASE_FOLHA,QRY->BASE_ESOCIAL,QRY->DIFERENCA},2,2)
  		
	QRY->(dbSkip())
	
EndDo


oFwMsEx:Activate()
cArq := CriaTrab( NIL, .F. ) + ".xml"
LjMsgRun( "Gerando o arquivo, aguarde...", cCadastro, {|| oFwMsEx:GetXMLFile( cArq ) } )
If __CopyFile( cArq, cDirTmp + cArq )
	//	If aRet[3]
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open( cDirTmp + cArq )
	oExcelApp:SetVisible(.T.)
Else
	MsgInfo( "Arquivo não copiado para temporário do usuário." )
Endif


Return


Static Function VldPerg(cPerg)

Local aPerg         := {}

aAdd( aPerg , { "01", "Período" , "mv_ch1",  "D", 10,  0 ,"MV_PAR01","G" ,"", " "  ," " 	," "	,"  " ,"   "} )


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
		X1_Def05   With aPerg[nn,14]
		MsUnlock()
	EndIf
Next

Return

Return
                              
