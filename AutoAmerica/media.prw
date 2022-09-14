#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

user Function MEDFER(cPdRot)

local cMesesMed := GetMV("AA_MESESME")
local nValorOr    := fBuscaPD("177")
Local cMesAno   := MesAno( MonthSub(FirstDate(apd[ascan( apd,  {|x|x[1] ='177'} ) ,10]) -1, Val(cMesesMed)))
Local nDias     := apd[ascan( apd,  {|x|x[1] ='177'} ) ,4]

cQuery :=" select round(SUM(case when RV_TIPOCOD ='1' then RD_VALOR else RD_VALOR * -1 end)/"+(cMesesMed)+",2) TOT"

cQuery += " from "+ RetSqlName("SRD") + " SRD "
cQuery += " inner join "+ RetSqlName("SRV")  +" SRV on RD_FILIAL = RV_FILIAL and RD_PD = RV_COD"
cQuery += " Where RD_FILIAL ='"+SRA->RA_FILIAL+"' and RD_MAT ='"+SRA->RA_MAT+"' and RV_MEDFER = '" + cMesesMed  +"' and RD_ROTEIR ='FOL' and RD_DATARQ > '" +cMesAno+"' "
cQuery += " and RV_TIPOCOD in ('1','2') and RV_TIPO ='V'"

If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif

TcQuery cQuery New Alias "QRY" 
nDif := Round((QRY->TOT / 30) * ndias,2) - nValorOr

if nDif >0
   // gerar verba de diferença de médias
Endif
Return
