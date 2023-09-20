#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"

//jdgti

User Function VALMERC

Local nSalario  := 0
Local nLimiteSB := 0
Local nPercVM   := 0
Local nValorVM  := 0
Local nFaltaVM  := 0
Local nLimFaVM  := 0
Local nPD479    := 0
Local nPD865    := 0
Local n2ViaCar  := 0


nLimiteSB := val(POSICIONE("RCA",1,"  " + "M_VMLIMITESB","RCA_CONTEU"))
nPercVM   := val(POSICIONE("RCA",1,"  " + "M_VMPERCDE","RCA_CONTEU"))
nValorVM  := val(POSICIONE("RCA",1,"  " + "M_VMVALOR","RCA_CONTEU"))
//cPdFalVM  := ALLTRIM(POSICIONE("RCA",1,"  " + "M_VMPDFALTAS","RCA_CONTEU"))
//nFaltaVM  := fBuscaPd(cPdFalVM,'H') *-1 
nFaltaVM  := FaltasPC (SRA->RA_FILIAL,SRA->RA_MAT)
nLimFaVM  := val(ALLTRIM(POSICIONE("RCA",1,"  " + "M_VMLIMFALTA","RCA_CONTEU")))
nPD479    := nValorVM / 100 * nPercVM
nPD865    := nValorVM - nPD479


/*
Alert("nSalario: " + cvaltochar(nSalario) )
Alert("nLimiteSB: " + cvaltochar(nLimiteSB) )
Alert("nPercVM: " + cvaltochar(nPercVM) )
Alert("nValorVM: " + cvaltochar(nValorVM) )
Alert("cPdFalVM: " + cvaltochar(cPdFalVM) )
Alert("nFaltaVM: " + cvaltochar(nFaltaVM) )
Alert("nLimFaVM: " + cvaltochar(nLimFaVM) )
*/

//busca desconto 2.ª cartão vale mercado

//Alert("nFaltaVM: " + cvaltochar(nFaltaVM) )

If Select("QRY") > 0
	QRY->(DbCloseArea())
End

cQuery:="	SELECT	"
cQuery+="	SUBSTRING(RCC_CONTEU,1,6) PERIODO,	"
cQuery+="	RCC_FIL FILIAL,	"
cQuery+="	SUBSTRING(RCC_CONTEU,9,6) MATRICULA,	"
cQuery+="	SUM(CAST(SUBSTRING(RCC_CONTEU,15,6) AS FLOAT)) VALOR,	"
cQuery+="	COUNT(*) QUANT	"
cQuery+="	FROM RCC010 RCC	"
cQuery+="	WHERE	"
cQuery+="	SUBSTRING(RCC_CONTEU,1,6) = '"+CPERIODO+"' AND	"
cQuery+="	RCC_CODIGO = 'U001' AND	"
cQuery+="	RCC_FIL = '"+SRA->RA_FILIAL+"' AND	"
cQuery+="	SUBSTRING(RCC_CONTEU,9,6) = '"+SRA->RA_MAT+"' AND	"
cQuery+="	RCC.D_E_L_E_T_ = ' '	"
cQuery+="	GROUP BY	"
cQuery+="	SUBSTRING(RCC_CONTEU,1,6),	"
cQuery+="	RCC_FIL,	"
cQuery+="	SUBSTRING(RCC_CONTEU,9,6)	"

TCQUERY cQuery NEW ALIAS "QRY"

n2ViaCar  := QRY->VALOR
n2ViaQtd  := QRY->QUANT

IF n2ViaCar > 0 
    FGERAVERBA("460",n2ViaCar,n2ViaQtd,CSEMANA,SRA->RA_CC,,"G",,,DDATA_PGTO,.F.,,,,,,,,DDATAREF)  
ENDIF

cMesAnt  := SubStr(Dtos(MonthSub(STOD(CPERIODO+"01"),1)),1,6)

nSal101 := 0
nSal110 := 0
nSal221 := 0
nSal173 := 0

nSal101  := POSICIONE("SRD",13,SRA->RA_FILIAL+SRA->RA_MAT+cMesAnt+"101","RD_VALOR")
nSal110  := POSICIONE("SRD",13,SRA->RA_FILIAL+SRA->RA_MAT+cMesAnt+"110","RD_VALOR")
nSal114  := POSICIONE("SRD",13,SRA->RA_FILIAL+SRA->RA_MAT+cMesAnt+"114","RD_VALOR")
nSal221  := POSICIONE("SRD",13,SRA->RA_FILIAL+SRA->RA_MAT+cMesAnt+"221","RD_VALOR")
nSal173  := POSICIONE("SRD",13,SRA->RA_FILIAL+SRA->RA_MAT+cMesAnt+"173","RD_VALOR")

nBaseSal := nSal101 + nSal110 + nSal114 + nSal221 + nSal173

nSalario := IIF(nBaseSal = 0,SRA->RA_SALARIO,nBaseSal)  

cNaoGera := STRTRAN(ALLTRIM(POSICIONE("RCA",1,"  "+"M_NAODESCV","RCA_CONTEU")),"'","")

nDiasFol := 0
nDiasAFA := 0
DiasACi1 := 0
DiasACi2 := 0
nDiasFM  := 0

nDiasFol := POSICIONE("SRD",13,SRA->RA_FILIAL+SRA->RA_MAT+cMesAnt+"101","RD_HORAS")
nDiasAFA := POSICIONE("SRD",13,SRA->RA_FILIAL+SRA->RA_MAT+cMesAnt+"110","RD_HORAS")
nDiasAFA += POSICIONE("SRD",13,SRA->RA_FILIAL+SRA->RA_MAT+cMesAnt+"114","RD_HORAS")
DiasACi1 := POSICIONE("SRD",13,SRA->RA_FILIAL+SRA->RA_MAT+cMesAnt+"221","RD_HORAS")
DiasACi2 := POSICIONE("SRD",13,SRA->RA_FILIAL+SRA->RA_MAT+cMesAnt+"155","RD_HORAS")
nDiasFM  := POSICIONE("SRD",13,SRA->RA_FILIAL+SRA->RA_MAT+cMesAnt+"173","RD_HORAS")

nDiasFA := nDiasFol+nDiasAFA+DiasACi1+DiasACi2

IIF(nDiasFA=0,nDiasFA:=0,nDiasFA:=nDiasFA)
IIF(EMPTY(nDiasFM),nDiasFM:=0,nDiasFM:=nDiasFM)

ndiasCal := nDiasFA + nDiasFM

IF  At(SRA->RA_MAT,cNaoGera,1) = 0
    IF SUBSTR(DTOS(SRA->RA_ADMISSA),1,6) <> CPERIODO 
        IF nSalario < nLimiteSB 

            IF nFaltaVM <= nLimFaVM .AND. SRA->RA_CATFUNC = "M"
                FGERAVERBA("479",nPD479/30*ndiasCal,0,CSEMANA,SRA->RA_CC,,"G",,,DDATA_PGTO,.F.,,,,,,,,DDATAREF)  
                FGERAVERBA("865",nPD865/30*ndiasCal,0,CSEMANA,SRA->RA_CC,,"G",,,DDATA_PGTO,.F.,,,,,,,,DDATAREF)  
            ENDIF
        ENDIF
    ENDIF
ENDIF
//RGB_FILIAL+RGB_MAT+RGB_PD+RGB_PERIOD+RGB_SEMANA+RGB_SEQ+RGB_CONVOC+RGB_NRBEN                                                                                    
//nInf479 := POSICIONE("RGB",10,SRA->RA_FILIAL+"479"+SRA->RA_MAT+" ","RGB_VALOR") //RGB_FILIAL+RGB_PD+RGB_MAT+RGB_SEQ 
nInf479 := POSICIONE("RGB",1,SRA->RA_FILIAL+SRA->RA_MAT+"479"+cPeriodo,"RGB_VALOR")

    IF nInf479 > 0
        FGERAVERBA("865",nValorVM-nInf479,0,CSEMANA,SRA->RA_CC,,"G",,,DDATA_PGTO,.F.,,,,,,,,DDATAREF)  
    ENDIF


/*
20220316/20220415
MV_PONMES 
PD 865 BASE EMPRESA VM 
PD 479 VALE MERCADO
M_VMLIMITE - LIMITE SALARIO BASE VALE MERCADO - 5242.57                           
M_VMPERCDE - PERCENTUAL DESCONTO FUNC - 5
M_VMVALOR  - VALOR TOTAL VALE MERCADO - 303.49
VMPDFALTAS - VERBAS DE FALTAS - "430,431"
VMLIMFALTA - LIMITE HORAS FALTAS - 18.10
*/


Return 


Static Function FaltasPC (xFil,xMat)

//Local xFil, xMat, cPer1, cPer2

cPdFalVM  := ALLTRIM(POSICIONE("RCA",1,"  " + "M_VMPDFALTAS","RCA_CONTEU"))

If Select("QRY") > 0
	QRY->(DbCloseArea())
End

cPerBus := SubStr(Dtos(MonthSub(STOD(CPERIODO+"01"),1)),1,6)

cQuery:="	SELECT 	"
cQuery+="	PC_FILIAL FILIAL,	"
cQuery+="	PC_MAT MATRICULA,	"
cQuery+="	SUM(PC_QUANTC) HORAS	"
cQuery+="	FROM SPC010 SPC	"
cQuery+="   INNER JOIN SP9010 SP9 ON P9_CODIGO = PC_PD AND P9_TIPOCOD = '2' AND SP9.D_E_L_E_T_ = ' ' "
cQuery+="	INNER JOIN RFQ010 RFQ ON RFQ_PROCES = '00001' AND RFQ_PERIOD = '"+cPerBus+"' AND RFQ_FILIAL = PC_FILIAL AND RFQ.D_E_L_E_T_ = ' '	"
cQuery+="	WHERE	"
cQuery+="	( PC_ABONO IN ("+cPdFalVM+") OR PC_ABONO = ' ' ) AND 
cQuery+="	PC_DATA BETWEEN RFQ_DTINI AND RFQ_DTFIM AND 	"
cQuery+="	PC_FILIAL = '"+xFil+"' AND	"
cQuery+="	PC_MAT = '"+xMat+"' AND	"
cQuery+="	SPC.D_E_L_E_T_ = ' '	"
cQuery+="	GROUP BY	"
cQuery+="	PC_FILIAL,	"
cQuery+="	PC_MAT	"


TCQUERY cQuery NEW ALIAS "QRY"

xRet := QRY->HORAS

RETURN xRet
