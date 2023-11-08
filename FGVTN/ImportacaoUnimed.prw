#Include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
//#include "Directry.ch"  

User function ImpCoop() 
	oProcess := MsNewProcess():New({|| ImpCop()}, "Processando...", "Aguarde...", .T.)
	oProcess:Activate()

Return

Static Function ImpCop()

Local aRegUni   := {}
Local nTotal := 0

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
Count To nTotal
DbGoTop()

IF ALLTRIM(SubStr(UNI->REGISTRO,1,7)) <> "000001H"
	Alert("Arquivo Inválido para importação!")
	Return
ENDIF

If SubStr(UNI->REGISTRO,1,7)=="000001H"
	dDtOcor := Ctod("01"+SubStr(UNI->REGISTRO,79,6))
EndIf

DbSelectArea("UNI")

nConta  := 0
nNConta := 0
cMat := ''
oprocess:SetRegua2(nTotal)
cMatr :=""
While UNI->(!Eof())
    cTipoReg:= SubStr(UNI->REGISTRO,7,1)
	If SubStr(UNI->REGISTRO,1,7)=="000001H"
		dDtOcor := Stod(SubStr(UNI->REGISTRO,81,4)+SubStr(UNI->REGISTRO,79,2)+"01")
	EndIf
    
    cBenefic  := SubStr(UNI->REGISTRO,465,16)
	cIdReg    := val(SubStr(UNI->REGISTRO,1,6))
	nValEvent := val(SubStr(UNI->REGISTRO,218,13))/100
	cNome     := AllTrim(SubStr(UNI->REGISTRO,21,25) )
	cCPF      := SubStr(UNI->REGISTRO,447,11)
	oProcess:IncRegua2("Importando CPF " +cCPF )
    nPercDep  := ATUnimed (cCPF,cBenefic)
    if ! Empty(cBenefic)
    	_aDados := BuscaSRA(cMatr, cBenefic)
		cTipo     := _aDados[5]
		cFilial   := _aDados[1]
		cFornec   := _aDados[7]
		cPlano    := _aDados[8]
		cCodigo   := _aDados[6]
		cMatr     := _aDados[2]
		cStatus   := _aDados[4]

		cExSra := POSICIONE("SRA",5,_aDados[1]+cCPF,"RA_NOME")
		IF Empty(cMatr) 
			aadd(_aErros,{STRZERO(cIdReg,6),cNome,nValEvent,"Carteirinha não cadastrado no Protheus"})		
			nNConta++
		ELSEIF Empty(cFornec) .And. cTipo = "T"
			aadd(_aErros,{STRZERO(cIdReg,6),cNome,nValEvent,"Titular não cadastrado no plano Ativo"})
			nNConta++
		ELSEIF Empty(cFornec) .And. cTipo = "D"
			aadd(_aErros,{STRZERO(cIdReg,6),cNome,nValEvent,"Dependente não cadastrado no plano Ativo"})
			nNConta++
		ELSE
			DbSelectArea("ZRH")
			DbSetOrder(1)
			DbGoTop()
		
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
				ZRH->ZRH_PERCDP := nPercDep
				nConta++
				MsUnLock()
			ELSE
				RecLock("ZRH",.f.)
				ZRH->ZRH_VALOR	:= nValEvent
				ZRH->ZRH_PERCDP := nPercDep
				MsUnLock()
			ENDIF
		ENDIF

    End    

    UNI->(DbSkip())
enddo
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
//cQuery+="	ROUND(SUM(ZRH_VALOR)/100*RCA_CONTEU,2)+ISNULL(RK_VLSALDO,0) SALDO	"
cQuery+="	ROUND(SUM(ZRH_VALOR)/100*ZRH_PERCDP,2)+ISNULL(RK_VLSALDO,0) SALDO	"
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
//cQuery+="	ROUND(SUM(ZRH_VALOR)/100*(100-RCA_CONTEU),2) VLREMP,	"
cQuery+="	ROUND(SUM(ZRH_VALOR)/100*(100-ZRH_PERCDP),2) VLREMP,	"
//cQuery+="	ROUND(SUM(ZRH_VALOR)/100*RCA_CONTEU,2) VLRFUN,	"
cQuery+="	ROUND(SUM(ZRH_VALOR)/100*ZRH_PERCDP,2) VLRFUN,	"
cQuery+="	ISNULL(AC.SALDO,0) ACUMULADO	"
cQuery+="	FROM ZRH010 ZRH	"
cQuery+="	LEFT JOIN RCA010 RCA ON RCA_MNEMON = 'M_COPARTFUNC' AND RCA_CONTEU <> 0	"
cQuery+="	LEFT JOIN ACUMULADO AC ON AC.FILIAL = ZRH_FILIAL AND AC.MATRICULA = ZRH_MAT AND ZRH_CODIGO = '  '	"
cQuery+="	WHERE	"
cQuery+="	ZRH.D_E_L_E_T_ = ' '"
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
	
	IncProc()

	DbSelectArea("RHO")
	DbSetOrder(3)
	DbGoTop()
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
return




Static Function ATUnimed (cCPF,cNumero)

If Select("QRY") > 0         
 QRY->(dbCloseArea())
Endif

cQuery:="	WITH GERAL AS	"
cQuery+="	(	"
cQuery+="	SELECT	"
cQuery+="	RA_MAT MATRICULA,	"
cQuery+="	ISNULL(SUBSTRING(RCC.RCC_CONTEU,1,6),'') MAT2, "
cQuery+="	RA_NOME NOME,	"
cQuery+="	'T' TIPO,	"
cQuery+="	SRA.R_E_C_N_O_ RECNO, 	0 RB_XPERCUN	"
cQuery+="	FROM	"
cQuery+="	SRA010 SRA	"
cQuery+="	LEFT JOIN RCC010 RCC ON RCC.RCC_CODIGO = 'U006' AND RCC.RCC_FIL = RA_FILIAL AND SUBSTRING(RCC.RCC_CONTEU,1,6) = RA_MAT AND RCC.D_E_L_E_T_ = ' ' "
cQuery+="	WHERE	"
cQuery+="	RA_CIC = '"+cCPF+"' AND	"
cQuery+="	RA_SITFOLH <> 'D' AND	"
cQuery+="	SRA.D_E_L_E_T_ = ' '	"
cQuery+="	UNION ALL	"
cQuery+="	SELECT	"
cQuery+="	RB_MAT MATRICULA,	"
cQuery+="	ISNULL(SUBSTRING(RCC.RCC_CONTEU,1,6),'') MAT2, "
cQuery+="	RA_NOME NOME,	"
cQuery+="	'D' TIPO,	"
cQuery+="	SRB.R_E_C_N_O_ RECNO, RB_XPERCUN	"
cQuery+="	FROM	"
cQuery+="	SRB010 SRB	"
cQuery+="	INNER JOIN SRA010 SRA ON RA_FILIAL = RB_FILIAL AND RB_MAT = RA_MAT AND RA_SITFOLH <> 'D' AND SRA.D_E_L_E_T_ = ' '	"
cQuery+="	LEFT JOIN RCC010 RCC ON RCC.RCC_CODIGO = 'U006' AND RCC.RCC_FIL = RA_FILIAL AND SUBSTRING(RCC.RCC_CONTEU,1,6) = RA_MAT AND RCC.D_E_L_E_T_ = ' ' "
cQuery+="	WHERE	"
cQuery+="	RB_CIC = '"+cCPF+"' AND	"
cQuery+="	SRB.D_E_L_E_T_ = ' '	"
cQuery+="	)	"
cQuery+="	SELECT	"
cQuery+="	*	"
cQuery+="	FROM GERAL WHERE MAT2 = '' "

TcQuery cQuery New Alias "QRY"

nRecno := QRY->RECNO
cTipo  := QRY->TIPO

IF !Empty(cTipo)

	IF cTipo = "T"
		//Posicionando no registro
		DbSelectArea('SRA')
		SRA->(DbGoTo(nRecno))
		
		RecLock('SRA', .F.)
			SRA->RA_UNIMED := cNumero
		SRA->(MsUnlock())		

	ELSE
		DbSelectArea('SRB')
		SRB->(DbGoTo(nRecno))
		
		//Alterando o registro		
		RecLock('SRB', .F.)
			SRB->RB_UNIMED := cNumero
		SRB->(MsUnlock())
 
	ENDIF 

ENDIF

Return QRY->RB_XPERCUN


Static Function BuscaSRA (cMatr , cBenefic)
local aRet :={}
Private aDados := {}
If Select("QR1") > 0         
    QR1->(dbCloseArea())
Endif  

cMatExc := SUPERGETMV( "MV_MATEXCL", .F., '005698')
// primeiro busca na SRA
cQuery := " SELECT	"
cQuery += " RA_FILIAL FILIAL,	"
cQuery += " RA_MAT MATRICULA,	"
cQuery += " RA_UNIMED UNIMED,	"
cQuery += " RA_SITFOLH STATUS,	"
cQuery += " 'T' TIPO,	"
cQuery += " '  ' CODIGO,	"
cQuery += " RHK_CODFOR FORNECEDOR,	"
cQuery += " RHK_TPPLAN PLANO	, RA_CIC"
cQuery += " FROM SRA010 SRA	"
cQuery += " INNER JOIN RHK010 RHK ON RHK_TPFORN = '1' AND RA_FILIAL = RHK_FILIAL AND RA_MAT = RHK_MAT AND RHK_PERFIM = ' ' AND RHK.D_E_L_E_T_ = ' '	"
cQuery += " WHERE	"
cQuery += " RA_UNIMED = '"+cBenefic+"' AND 	"
cQuery += " SRA.D_E_L_E_T_ = ' '  and RA_MAT <> '"+cMatExc+"'"
cQuery += " and RA_ADMISSA = ( select Max(RA_ADMISSA) from " + RetSqlName("SRA") + " SRA where RA_UNIMED = '"+cBenefic+"' and D_E_L_E_T_ =' ')"

TcQuery cQuery New Alias "QR1"

if QR1->(!EOF())
    aRet := aadd(aDados,{QR1->FILIAL,QR1->MATRICULA,QR1->UNIMED,QR1->STATUS,QR1->TIPO,QR1->CODIGO,QR1->FORNECEDOR,QR1->PLANO})
else // se não for funcionario procura por dependente
    QR1->(dbCloseArea())
    cQuery := " SELECT	"
    cQuery += " RB_FILIAL FILIAL,	"
    cQuery += " RB_MAT MATRICULA,	"
    cQuery += " RB_UNIMED UNIMED,	"
    cQuery += " RA_SITFOLH STATUS,	"
    cQuery += " 'D' TIPO,	"
    cQuery += " RB_COD CODIGO,	"
    cQuery += " RHL_CODFOR FORNECEDOR,	"
    cQuery += " RHL_TPPLAN PLANO	"
    cQuery += " FROM SRB010 SRB	"
    cQuery += " INNER JOIN SRA010 SRA ON RA_FILIAL = RB_FILIAL AND RA_MAT = RB_MAT  AND SRA.D_E_L_E_T_ = ' '	"
    cQuery += " LEFT JOIN RHL010 RHL ON RHL_TPFORN = '1' AND RA_FILIAL = RHL_FILIAL AND RA_MAT = RHL_MAT AND RHL_PERFIM = ' ' AND RHL.D_E_L_E_T_ = ' '	"
    cQuery += " WHERE	"
    cQuery += " RB_UNIMED  ='"+cBenefic+"' AND	"
    cQuery += " SRB.D_E_L_E_T_ = ' '	"
	cQuery += " and RHL_CODFOR <> ' '"  
	cQuery += " and RA_ADMISSA = ( select Max(RA_ADMISSA) from " + RetSqlName("SRA") + " B "
	cQuery += " where B.RA_FILIAL = SRA.RA_FILIAL and B.RA_MAT = SRA.RA_MAT  and B.D_E_L_E_T_ =' ')"
	
    TcQuery cQuery New Alias "QR1"

    if QR1->(!EOF())
        aRet := aadd(aDados,{QR1->FILIAL,QR1->MATRICULA,QR1->UNIMED,QR1->STATUS,QR1->TIPO,QR1->CODIGO,QR1->FORNECEDOR,QR1->PLANO})
    else
        aRet := {'','','','','','','',''}
    Endif
     
endif
 
Return aRet

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
