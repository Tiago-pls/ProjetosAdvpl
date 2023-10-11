#Include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
//#include "Directry.ch"  

User function ImpUnimed() 
u_ImpCoop() 
RETURN
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
cQueryU+="	RK_FILIAL = '"+SRA->RA_FILIAL+"' AND	"
cQueryU+="	RK_MAT = '"+SRA->RA_MAT+"' AND	"
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
		While RHO->(!EOF()) .AND. SRA->RA_FILIAL + SRA->RA_MAT  == RHO->(RHO_FILIAL + RHO_MAT  )
			if RHO->RHO_COMPPG == cPeriodo
				nVlrTot := nVlrTot+=RHO->RHO_VLRFUN
			endif
			RHO->(dbskip()) 
		Enddo 
	Endif

nUltimo  := IIF(EMPTY(QRYU->ULTIMO),0,QRYU->ULTIMO)
dPeriodo := STOD(CPERIODO+"01")
cNumDoc  := IIF(Empty(nUltimo),"000001",StrZero(QRYU->ULTIMO+1,6)) 
cNumID   := "RHO509"+cValToChar(CPERIODO)

IF nParc > 0

	DbSelectArea("SRK")
	DbSetOrder(2)
	DbGoTop()
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
cQuery+="   RA_UNIMED <> ' '" // ultimos 60 dias
cQuery+="	and SRA.D_E_L_E_T_ = ' '	"
cQuery+="	UNION ALL	"
cQuery+="	SELECT	"
cQuery+="	'D' TIPO,	"
cQuery+="	SRB.R_E_C_N_O_ RECNO	"
cQuery+="	FROM	"
cQuery+="	SRB010 SRB	"
cQuery+="	INNER JOIN SRA010 SRA ON RA_FILIAL = RB_FILIAL AND RB_MAT = RA_MAT AND SRA.D_E_L_E_T_ = ' ' "
cQuery+="	WHERE	"
cQuery+="	RB_CIC = '"+cCPF+"' AND	"
cQuery+="	SRB.D_E_L_E_T_ = ' '	"

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
