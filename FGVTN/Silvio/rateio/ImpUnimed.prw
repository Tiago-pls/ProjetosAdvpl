#Include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
//#include "Directry.ch"  

User function ImpUnimed() 
	Processa({||ImpCop(),"Importação de Co-participação" })
Return

/*
Static Function ImpCop()
cBenefic  := SubStr(cLinha,465,16)  
nValEvent := val(SubStr(cLinha,231,13))/100   
Alert(cBenefic)
Alert(nValEvent)
Return       
*/

Static Function ImpCop()

Local aRegUni   := {}
/*
Local nLidos	:= 0
Local nCount	:= 0
Local nDemit	:= 0
Local nAlter    := 0
Local nPosNome	:= 0
Local cNomeArq	:= ""
Local cNomeTXT	:= ""
Local cArquivo	:= ""
Local cMatPro 	:= ""
Local cQuery 	:= ""
Local cQryRHO 	:= ""
Local cBenefic	:= Space(16)
Local nValEvent	:= 0.00
Local cSubVlr   := "S" //GETMV("MV_GPEUNIM")
*/

Public dDtOcor	   := Ctod("")
Public _aErros    := {}
Public _aDados    := {}


cTipo := "Arquivos Texto  (*.TXT)  | *.TXT | "
cNomeTXT := cGetFile(cTipo,OemToAnsi("Selecionar Arquivo..."))

If Empty(cNomeTXT)
	Return
EndIF

AADD(aRegUni,{"REGISTRO","C",550,0})

If Select("UNI") > 0
	UNI->(dbCloseArea())
Endif

cNomeArq:=CriaTrab(aRegUni, .t. )
dbUseArea(.T.,__LocalDriver,cNomeArq,"UNI",.F.,.F.)

ProcRegua(Len(aRegUni))

Append from &cNomeTXT SDF

DbSelectArea("UNI")
DbGoTop()

IF ALLTRIM(SubStr(UNI->REGISTRO,1,7)) <> "000001H"
	Alert("Arquivo Inválido para importação!")
	Return
ENDIF

	If SubStr(UNI->REGISTRO,1,7)=="000001H"
		//DbSelectArea("UNI")
		//DbSkip()
		dDtOcor := Ctod("01"+SubStr(UNI->REGISTRO,79,6))
		//Exit
	EndIf
	//DbSelectArea("UNI")
	//DbSkip()

DbSelectArea("UNI")

nConta  := 0
nNConta := 0

While !Eof()

	cTipoReg:= SubStr(UNI->REGISTRO,7,1)
	If SubStr(UNI->REGISTRO,1,7)=="000001H"
		dDtOcor := Stod(SubStr(UNI->REGISTRO,81,4)+SubStr(UNI->REGISTRO,79,2)+"01")
	EndIf



	If cTipoReg == "D"

		cBenefic  := SubStr(UNI->REGISTRO,465,16)  
		cIdReg    := val(SubStr(UNI->REGISTRO,1,6))  
		nValEvent := val(SubStr(UNI->REGISTRO,218,13))/100   
		cNome     := AllTrim(SubStr(UNI->REGISTRO,21,25) )
		cCPF      := SubStr(UNI->REGISTRO,447,11)

		ATUnimed (cCPF,cBenefic)
	
		_aDados := BuscaSRA(cBenefic)

		cTipo     := _aDados[5]
		cFilial   := _aDados[1]
		cFornec   := _aDados[7]
		cPlano    := _aDados[8]
		cCodigo   := _aDados[6]
		cMatr     := _aDados[2]
		cStatus   := _aDados[4]

		cExSra := POSICIONE("SRA",5,_aDados[1]+cCPF,"RA_NOME")

/*
	@ nLin, 001  PSAY "SEQ."
	@ nLin, 010  PSAY "COLABORADOR"
	@ nLin, 065  PSAY "VALOR"
	@ nLin, 075  PSAY "INCONSISTÊNCIA"
*/

		//IF cStatus = "D" .And. cTipo = "D"
		//	aadd(_aErros,{STRZERO(cIdReg,6),cNome,nValEvent,"Dependente de Funcionário demitido"})
		//	nNConta++
		//ELSEIF cStatus = "D" .And. cTipo = "T"
		//	aadd(_aErros,{STRZERO(cIdReg,6),cNome,nValEvent,"Funcionário demitido"})
		//	nNConta++
		//IF Empty(cExSra) 
		//	aadd(_aErros,{STRZERO(cIdReg,6),cNome,nValEvent,"Funcionário não localizado no Protheus"})		
		//	nNConta++
		IF Empty(cMatr) 
			aadd(_aErros,{STRZERO(cIdReg,6),cNome,nValEvent,"Carteirinha não cadastrado no Protheus"})		
			nNConta++
		ELSEIF Empty(cFornec) .And. cTipo = "T"
			aadd(_aErros,{STRZERO(cIdReg,6),cNome,nValEvent,"Titular não cadastrado no plano Ativo"})
			nNConta++
		ELSEIF Empty(cFornec) .And. cTipo = "D"
			aadd(_aErros,{STRZERO(cIdReg,6),cNome,nValEvent,"Dependente não cadastrado no plano Ativo"})
			nNConta++
		ELSE// !Empty(cMatr) .OR. !Empty(cFornec) 	
			DbSelectArea("ZRH")
			DbSetOrder(1)
			DbGoTop()
			//ZRH_FILIAL + ZRH_MAT + ZRH_PERIOD + ZRH_TIPO + ZRH_ID
			IF !DbSeek(_aDados[1]+cMatr+dtos(dDtOcor)+cTipo+cvaltochar(cIdReg))
				RecLock("ZRH",.t.)
				ZRH->ZRH_FILIAL	:= _aDados[1]
				ZRH->ZRH_MAT	:= cMatr
				ZRH->ZRH_CARTEI	:= cBenefic
				ZRH->ZRH_TIPO	:= cTipo
				ZRH->ZRH_PERIOD	:= dDtOcor
				ZRH->ZRH_VALOR	:= nValEvent
				ZRH->ZRH_ID     := cIdReg
				ZRH->ZRH_CODIGO := cCodigo
				ZRH->ZRH_CODFOR := cFornec
				ZRH->ZRH_TPPLAN := cPlano
				nConta++
				MsUnLock()
			ELSE
				RecLock("ZRH",.f.)
				ZRH->ZRH_VALOR	:= nValEvent
				MsUnLock()
			ENDIF

		ENDIF

	ENDIF


//jdgti


	DbSelectArea("UNI")
	DbSkip()

End

DbSelectArea("UNI")
UNI->(DbCloseArea())

If !Empty(_aErros)
		RELINC(nConta,nNConta)
	Else
		MsgInfo(cValToChar(nConta)+" Registros importados com sucesso!","Importação")
	EndIf


IF (select("QRY2") <> 0)
	QRY2->(dbCloseArea())
ENDIF

cQuery:="	WITH ACUMULADO AS	"
cQuery+="	(	"
cQuery+="	SELECT	"
cQuery+="	ZRH_FILIAL FILIAL,	"
cQuery+="	ZRH_MAT MATRICULA,	"
cQuery+="	ISNULL(RK_VLSALDO,0) ACUMULADO,	"
cQuery+="	ROUND(SUM(ZRH_VALOR)/100*RCA_CONTEU,2)+ISNULL(RK_VLSALDO,0) SALDO	"
cQuery+="	FROM ZRH010 ZRH	"
cQuery+="	LEFT JOIN RCA010 RCA ON RCA_MNEMON = 'M_COPARTFUNC' AND RCA_CONTEU <> 0	"
cQuery+="	INNER JOIN SRK010 SRK ON RK_FILIAL = ZRH_FILIAL AND RK_MAT = ZRH_MAT AND RK_STATUS = '2' AND RK_PD = '509' AND SRK.D_E_L_E_T_ = ' '	"
cQuery+="	WHERE	"
cQuery+="	ZRH.D_E_L_E_T_ = ' '	"
cQuery+="	GROUP BY	"
cQuery+="	RK_VLSALDO,	"
cQuery+="	RCA_CONTEU,	"
cQuery+="	ZRH_FILIAL,	"
cQuery+="	ZRH_MAT	"
cQuery+="	)	"
cQuery+="	SELECT	"
cQuery+="	ZRH_FILIAL FILIAL,	"
cQuery+="	ZRH_MAT MATRICULA,	"
cQuery+="	ZRH_PERIOD PERIODO,	"
cQuery+="	ZRH_CODIGO CODIGO,	"
cQuery+="	ZRH_CODFOR FORNEC,	"
cQuery+="	ZRH_TPPLAN PLANO,	"
cQuery+="	SUM(ZRH_VALOR) TOTAL,	"
cQuery+="	ROUND(SUM(ZRH_VALOR)/100*(100-RCA_CONTEU),2) VLREMP,	"
cQuery+="	ROUND(SUM(ZRH_VALOR)/100*RCA_CONTEU,2) VLRFUN,	"
cQuery+="	ISNULL(AC.SALDO,0) ACUMULADO	"
cQuery+="	FROM ZRH010 ZRH	"
cQuery+="	LEFT JOIN RCA010 RCA ON RCA_MNEMON = 'M_COPARTFUNC' AND RCA_CONTEU <> 0	"
cQuery+="	LEFT JOIN ACUMULADO AC ON AC.FILIAL = ZRH_FILIAL AND AC.MATRICULA = ZRH_MAT AND ZRH_CODIGO = '  '	"
cQuery+="	WHERE	"
cQuery+="	ZRH.D_E_L_E_T_ = ' '	"
cQuery+="	GROUP BY	"
cQuery+="	AC.SALDO,	"
cQuery+="	RCA_CONTEU,	"
cQuery+="	ZRH_FILIAL,	"
cQuery+="	ZRH_MAT,	"
cQuery+="	ZRH_PERIOD,	"
cQuery+="	ZRH_CODIGO,	"
cQuery+="	ZRH_CODFOR,	"
cQuery+="	ZRH_TPPLAN	"

TcQuery cQuery new Alias "QRY2"

While !QRY2->(Eof())
	
	//Incproc("Colaborador " + TRIM(QRY->NOME) )
	
	IncProc()
	
	//TCSetField ("QRY", "PERIODO","D")

	DbSelectArea("RHO")
	DbSetOrder(3)
	DbGoTop()
	//RHO_FILIAL+RHO_MAT+RHO_COMPPG+RHO_CODFOR+RHO_CODIGO 
	IF !DbSeek(QRY2->FILIAL+QRY2->MATRICULA+AnoMes(Stod(QRY2->PERIODO))+QRY2->FORNEC+QRY2->CODIGO)
		RecLock("RHO",.t.)
        RHO->RHO_FILIAL  	:= QRY2->FILIAL
        RHO->RHO_MAT		:= QRY2->MATRICULA
        RHO->RHO_DTOCOR		:= Stod(QRY2->PERIODO)
        RHO->RHO_ORIGEM	    := IIF(QRY2->CODIGO="  ","1","2")
        RHO->RHO_TPFORN	    := "1"
		RHO->RHO_CODIGO     := QRY2->CODIGO
        RHO->RHO_CODFOR	    := QRY2->FORNEC
        RHO->RHO_TPLAN	    := QRY2->PLANO
        RHO->RHO_PD	        := "418"
        RHO->RHO_VLRFUN     := QRY2->VLRFUN
		RHO->RHO_VLREMP     := QRY2->VLREMP
        RHO->RHO_COMPPG     := AnoMes(Stod(QRY2->PERIODO))
        IF QRY2->CODIGO="  "
		RHO->RHO_CPF        := POSICIONE("SRA",13,QRY2->MATRICULA+QRY2->FILIAL,"RA_CIC")               
		ELSE
		RHO->RHO_CPF        := POSICIONE("SRB",1,QRY2->FILIAL+QRY2->MATRICULA+QRY2->CODIGO,"RB_CIC")  
		ENDIF
//		nSaldo              := SaldoSRK (QRY2->FILIAL,QRY2->MATRICULA)
		RHO->RHO_ANTERI     := QRY2->ACUMULADO //IIF(nSaldo > 0 , nSaldo + QRY2->VLRFUN , 0)
		MsUnLock()
	ELSE
		RecLock("RHO",.f.)
		RHO->RHO_VLRFUN     := QRY2->VLRFUN
		RHO->RHO_VLREMP     := QRY2->VLREMP
		MsUnLock()
	ENDIF
	
	QRY2->(DbSkip())
	
End

//jdgti


Return


Static Function BuscaSRA(cUnimed)

Private aDados := {}

If Select("QRY") > 0         
 QRY->(dbCloseArea())
Endif  

cQuery:="	WITH GERAL AS	"
cQuery+="	(	"
cQuery+="	SELECT	"
cQuery+="	RA_FILIAL FILIAL,	"
cQuery+="	RA_MAT MATRICULA,	"
cQuery+="	RA_UNIMED UNIMED,	"
cQuery+="	RA_SITFOLH STATUS,	"
cQuery+="	'T' TIPO,	"
cQuery+="	'  ' CODIGO,	"
cQuery+="	RHK_CODFOR FORNECEDOR,	"
cQuery+="	RHK_TPPLAN PLANO	"
cQuery+="	FROM SRA010 SRA	"
cQuery+="	INNER JOIN RHK010 RHK ON RHK_TPFORN = '1' AND RA_FILIAL = RHK_FILIAL AND RA_MAT = RHK_MAT AND RHK_PERFIM = ' ' AND RHK.D_E_L_E_T_ = ' '	"
cQuery+="	WHERE	"
cQuery+="	RA_UNIMED <> ' ' AND RA_SITFOLH <> 'D' AND	"
cQuery+="	SRA.D_E_L_E_T_ = ' '	"
cQuery+="	UNION ALL	"
cQuery+="	SELECT	"
cQuery+="	RB_FILIAL FILIAL,	"
cQuery+="	RB_MAT MATRICULA,	"
cQuery+="	RB_UNIMED UNIMED,	"
cQuery+="	RA_SITFOLH STATUS,	"
cQuery+="	'D' TIPO,	"
//cQuery+="	CASE WHEN LEN(RB_COD) = 1 THEN '0'+RB_COD ELSE RB_COD END CODIGO,	"
cQuery+="	RB_COD CODIGO,	"
cQuery+="	RHL_CODFOR FORNECEDOR,	"
cQuery+="	RHL_TPPLAN PLANO	"
cQuery+="	FROM SRB010 SRB	"
cQuery+="	INNER JOIN SRA010 SRA ON RA_FILIAL = RB_FILIAL AND RA_MAT = RB_MAT AND RA_SITFOLH <> 'D' AND SRA.D_E_L_E_T_ = ' '	"
cQuery+="	LEFT JOIN RHL010 RHL ON RHL_TPFORN = '1' AND RA_FILIAL = RHL_FILIAL AND RA_MAT = RHL_MAT AND RHL_PERFIM = ' ' AND RHL.D_E_L_E_T_ = ' '	"
cQuery+="	WHERE	"
cQuery+="	RB_UNIMED <> ' ' AND	"
cQuery+="	SRB.D_E_L_E_T_ = ' '	"
cQuery+="	)	"
cQuery+="	SELECT *	"
cQuery+="	FROM GERAL	"
cQuery+="	WHERE	"
cQuery+="	UNIMED = '"+cUnimed+"'	"

TcQuery cQuery New Alias "QRY"

xRet := aadd(aDados,{QRY->FILIAL,QRY->MATRICULA,QRY->UNIMED,QRY->STATUS,QRY->TIPO,QRY->CODIGO,QRY->FORNECEDOR,QRY->PLANO})

Return xRet


Static function RELINC(nOK,nNOK)

	Local cQuery := ""
	Local nLin         := 80
	Private m_pag      := 01

	cString	:= "REL"
	cDesc1	:= "Inconsistencias do Arquivo de Co-Participação"
	cDesc2	:= ""
	cDesc3	:= ""
	Tamanho	:= "M"
	Titulo	:= "Inconsistencias do Arquivo de Co-Participação"
	nLastKey := 0
	wnrel   := "RELINC"
	aReturn := { "Zebrado", 1,"", 2, 1, 2, "",1 }

	cabec1 := ""
	cabec2 := ""


	SetPrint(cString,wnrel,,Titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho,,.F.,,,.F.)

	If nLastKey == 27
		Set Filter To
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Set Filter To
		Return
	Endif

	If nLin>=58
		Cabec(titulo,cDesc1,cabec2,wnrel,tamanho,18) //Impressao do cabecalho
		nLin:= 0
	Endif

	nLin+=8

	@ nLin, 000      PSAY ""

	nLin+=1

	//@ nLin, 001  PSAY "ERRO"
	@ nLin, 001  PSAY "SEQ."
	@ nLin, 010  PSAY "NOME"
	@ nLin, 065  PSAY "VALOR"
	@ nLin, 075  PSAY "INCONSISTÊNCIA"


	For i := 1 to len(_aErros)
		If nLin>=55
			Cabec(titulo,cDesc1,cabec2,wnrel,tamanho,18) //Impressao do cabecalho
			nLin := 8
		Endif

		nLin +=1
		@ nLin, 001      PSAY _aErros[i,1]
		@ nLin, 010      PSAY _aErros[i,2] 
		@ nLin, 065      PSAY _aErros[i,3]
		@ nLin, 075      PSAY _aErros[i,4]


	Next
	nLin +=2

	@ nLin+1, 001      PSAY cValToChar(STRZERO(nOK+nNOK,4)) + " - TOTAL DE REGISTROS"
	nLin +=1
	@ nLin+1, 001      PSAY cValToChar(STRZERO(nOK,4)) + " - Importado(s)"
	nLin +=1
	@ nLin+1, 001      PSAY cValToChar(STRZERO(nNOK,4)) + " - Não Importado(s)"

	@ nLin+1, 000      PSAY ""

	Roda(0,"","M")
	Set Filter To
	If aReturn[5] == 1
		Set Printer To
		Commit
		ourspool(wnrel) //Chamada do Spool de Impressao
	Endif
	MS_FLUSH() //Libera fila de relatorios em spool

Return


/*
Static Function SaldoSRK (cFil,cMat)

If Select("QRY") > 0         
 QRY->(dbCloseArea())
Endif

cQuery:="	SELECT	"
cQuery+="	RK_FILIAL FILIAL,	"
cQuery+="	RK_MAT MATRICULA,	"
cQuery+="	RK_VLSALDO SALDO,	"
cQuery+="	RK_DOCUMEN ULTIMA	"
cQuery+="	FROM SRK010 SRK	"
cQuery+="	WHERE	"
cQuery+="	RK_STATUS = '2' AND	"
cQuery+="	RK_FILIAL = '"+cFil+"' AND	"
cQuery+="	RK_MAT = '"+cMat+"' AND	"
cQuery+="	RK_PD = '418' AND	"
cQuery+="	SRK.D_E_L_E_T_ = ' '	"

TcQuery cQuery New Alias "QRY"

xRet := QRY->SALDO

Return xRet
*/


User Function ParcCOP()

If Select("QRYU") > 0         
 QRYU->(dbCloseArea())
Endif

cQueryU:="	SELECT	"
cQueryU+="	RK_FILIAL FILIAL,	"
cQueryU+="	RK_MAT MATRICULA,	"
cQueryU+="	MAX(RK_DOCUMEN)*1 ULTIMO	"
cQueryU+="	FROM SRK010 SRK	"
cQueryU+="	WHERE	"
//cQueryU+="	RK_STATUS = '2' AND	"
cQueryU+="	RK_FILIAL = '"+SRA->RA_FILIAL+"' AND	"
cQueryU+="	RK_MAT = '"+SRA->RA_MAT+"' AND	"
//cQueryU+="	RK_PD = '509' AND	"
cQueryU+="	SRK.D_E_L_E_T_ = ' '	"
cQueryU+="	GROUP BY	"
cQueryU+="	RK_FILIAL,	"
cQueryU+="	RK_MAT	"

TcQuery cQueryU New Alias "QRYU"

nParc := IIF(EMPTY(ParcUn(SRA->RA_FILIAL,SRA->RA_MAT,CPERIODO)),0,ParcUn(SRA->RA_FILIAL,SRA->RA_MAT,CPERIODO))

nVlrTot := 0

	DbSelectArea("RHO") 
	RHO->(DbSetorder(2))
	RHO->( DbGotop()) 
	If RHO->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT)) 
		While RHO->(!EOF()) .AND. SRA->RA_FILIAL + SRA->RA_MAT == RHO->RHO_FILIAL + RHO->RHO_MAT 	
		nVlrTot := nVlrTot+=RHO->RHO_VLRFUN
			RHO->(dbskip()) 
		Enddo
	Endif

nUltimo  := IIF(EMPTY(QRYU->ULTIMO),0,QRYU->ULTIMO)
dPeriodo := STOD(CPERIODO+"01")
cNumDoc  := IIF(Empty(nUltimo),"000001",StrZero(QRYU->ULTIMO+1,6)) 
cNumID   := "RHO509"+cValToChar(CPERIODO)

IF nParc > 0


//desativa emprestimo anterior

		/*
		IF  !Empty(nUltimo)

		cNumDocA := "SRK"+SRA->RA_FILIAL+SRA->RA_MAT+"509"+cValToChar(StrZero(QRY->ULTIMO,6))

			DbSelectArea("SRK")
			DbSetOrder(2)
			DbGoTop()
			//2 - RK_FILIAL+RK_MAT+RK_NUMID
			IF DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cValToChar(cNumDocA))
				IF CPERIODO <> SRK->RK_PERINI 
				RecLock("SRK",.f.)
				SRK->RK_STATUS   := "3"
				MsUnLock()
				ENDIF
			ENDIF

		ENDIF
		*/

	DbSelectArea("SRK")
	DbSetOrder(2)
	DbGoTop()
	//2 - RK_FILIAL+RK_MAT+RK_NUMID
	//3 - RK_FILIAL+RK_MAT+RK_PERINI+RK_NUMPAGO
	//IF !DbSeek("RHO"+SRA->RA_FILIAL+SRA->RA_MAT+"508"+cValToChar(CPERIODO))
	IF !DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cNumID)
		RecLock("SRK",.t.)
        SRK->RK_FILIAL   := SRA->RA_FILIAL
        SRK->RK_MAT      := SRA->RA_MAT
		SRK->RK_PD       := "509"
		SRK->RK_VALORTO  := nVlrTot
		SRK->RK_PARCELA  := nParc
		SRK->RK_VALORPA  := nVlrTot / nParc
		SRK->RK_DTVENC   := dPeriodo
		SRK->RK_DTMOVI   := dPeriodo
		SRK->RK_DOCUMEN  := cNumDoc
		SRK->RK_CC       := SRA->RA_CC
		SRK->RK_PERINI   := CPERIODO
		SRK->RK_NUMPAGO  := "01"
		SRK->RK_REGRADS  := "1"
		SRK->RK_STATUS   := "2"
		SRK->RK_VLSALDO  := nVlrTot
		SRK->RK_NUMID    := cNumID
		SRK->RK_PROCES   := "00001"
		SRK->RK_EMPCONS  := "2"
		SRK->RK_DTREF    := dPeriodo
    	MsUnLock()
	ENDIF



ENDIF

Return


Static Function ATUnimed (cCPF,cNumero)

If Select("QRY") > 0         
 QRY->(dbCloseArea())
Endif

cQuery:="	SELECT	"
cQuery+="	'T' TIPO,	"
cQuery+="	SRA.R_E_C_N_O_ RECNO	"
cQuery+="	FROM	"
cQuery+="	SRA010 SRA	"
cQuery+="	WHERE	"
cQuery+="	RA_CIC = '"+cCPF+"' AND	"
cQuery+="	RA_SITFOLH <> 'D' AND	"
//cQuery+="	RA_MAT = '"+cMat+"' AND	"
//cQuery+="	SUBSTRING(RA_NOME,1,25) = '"+cNome+"' AND	"
cQuery+="	SRA.D_E_L_E_T_ = ' '	"
cQuery+="	UNION ALL	"
cQuery+="	SELECT	"
cQuery+="	'D' TIPO,	"
cQuery+="	SRB.R_E_C_N_O_ RECNO	"
cQuery+="	FROM	"
cQuery+="	SRB010 SRB	"
cQuery+="	INNER JOIN SRA010 SRA ON RA_FILIAL = RB_FILIAL AND RB_MAT = RA_MAT AND RA_SITFOLH <> 'D' AND SRA.D_E_L_E_T_ = ' ' "
cQuery+="	WHERE	"
cQuery+="	RB_CIC = '"+cCPF+"' AND	"
//cQuery+="	RB_FILIAL = '01' AND	"
//cQuery+="	RB_MAT = '"+cMat+"' AND	"
//cQuery+="	SUBSTRING(RB_NOME,1,25) = '"+cNome+"' AND	"
cQuery+="	SRB.D_E_L_E_T_ = ' '	"

TcQuery cQuery New Alias "QRY"

nRecno := QRY->RECNO
cTipo  := QRY->TIPO

IF !Empty(cTipo)

	IF cTipo = "T"

		//Posicionando no registro
		DbSelectArea('SRA')
		SRA->(DbGoTo(nRecno))
		
		//Alterando o registro
		
		RecLock('SRA', .F.)
			SRA->RA_UNIMED := cNumero
		SRA->(MsUnlock())		

	ELSE

		//Posicionando no registro
		DbSelectArea('SRB')
		SRB->(DbGoTo(nRecno))
		
		//Alterando o registro
		
		RecLock('SRB', .F.)
			SRB->RB_UNIMED := cNumero
		SRB->(MsUnlock())

	ENDIF 

ENDIF


Return


Static Function ParcUn(xFil,xMat,xPer)

Local xFil, xMat, xPer

If Select("QRY") > 0         
 QRY->(dbCloseArea())
Endif

cQuery:="	SELECT	"
cQuery+="	CAST(SUBSTRING(RCC_CONTEU,7,2) AS INT) PARCELAS	"
cQuery+="	FROM RCC010 RCC	"
cQuery+="	WHERE	"
cQuery+="	RCC_FIL = '"+xFil+"' AND	"
cQuery+="	RCC_CHAVE = '"+xPer+"' AND  "
cQuery+="	SUBSTRING(RCC_CONTEU,1,6) = '"+xMat+"' AND	"
cQuery+="	RCC_CODIGO = 'U005' AND 	"
cQuery+="	RCC.D_E_L_E_T_ = ' '	"

TcQuery cQuery New Alias "QRY"

Return (QRY->PARCELAS)




User Function DelPd418(xFil,xMat,xPer)

Local xFil, xMat, xPer

If Select("QRY8") > 0         
 QRY8->(dbCloseArea())
Endif


cQuery:="	WITH SRK509 AS	"
cQuery+="	(	"
cQuery+="	SELECT	"
cQuery+="	RK_FILIAL FILIAL,	"
cQuery+="	RK_MAT MATRICULA,	"
cQuery+="	RK_VALORTO TOTAL,	"
cQuery+="	RK_VALORPA PARCELA,	"
cQuery+="	SUBSTRING(RK_DTMOVI,1,6) PERIODO	"
cQuery+="	FROM SRK010 SRK	"
cQuery+="	WHERE	"
cQuery+="	RK_PD = '509' AND	"
cQuery+="	RK_STATUS = '2' AND	"
cQuery+="	SRK.D_E_L_E_T_ = ' '	"
cQuery+="	)	"
cQuery+="	SELECT	"
cQuery+="	RGB_FILIAL FILIAL,	"
cQuery+="	RGB_MAT MATRICULA,	"
cQuery+="	RGB_PD VERBA,	"
cQuery+="	RGB_PERIOD PER_SRB,	"
cQuery+="	SRK.PERIODO PER_SRK,	"
cQuery+="	RGB_VALOR TOTAL_RGB,	"
cQuery+="	SRK.TOTAL TOTAL_SRK,	"
cQuery+="	SRK.PARCELA PARC_SRK	"
cQuery+="	FROM RGB010 RGB	"
cQuery+="	LEFT JOIN SRK509 SRK ON SRK.FILIAL = RGB_FILIAL AND SRK.MATRICULA = RGB_MAT AND SRK.PERIODO = RGB_PERIOD	"
cQuery+="	WHERE	"
cQuery+="	RGB_PERIOD = '"+xPer+"' AND	"
cQuery+="	RGB_PD = '418' AND	"
cQuery+="	RGB_FILIAL = '"+xFil+"' AND	"
cQuery+="	RGB_MAT = '"+xMat+"' AND	"
cQuery+="	RGB.D_E_L_E_T_ = ' '	"


TcQuery cQuery New Alias "QRY8"

IF QRY8->PER_SRB = QRY8->PER_SRK .AND. QRY8->TOTAL_RGB = QRY8->TOTAL_SRK
FDELPD("418")

nPartEmp := FBUSCAPD("772","V")
FDelpd("772")

FGERAVERBA("772",nPartEmp + QRY8->TOTAL_RGB,0,CSEMANA,SRA->RA_CC,,"G",,,DDATA_PGTO,.F.,,,,,,,,DDATAREF)  

ENDIF


Return 




//jdgti
