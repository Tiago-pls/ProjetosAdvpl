#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

user Function MEDFER(cPdRot)

local cMesesMed := GetMV("AA_MESESME")
local nValorOr  := fBuscaPD('177,178')
Local dDataFim  := FirstDate(apd[ascan( apd,  {|x|x[1] ='177'} ) ,10]) -1
Local cMesAno   := MesAno( MonthSub( dDataFim, Val(cMesesMed)-1  ))
Local nDias     := apd[ascan( apd,  {|x|x[1] ='173'} ) ,4]

cQuery := " select round(SUM(case when RV_TIPOCOD ='1' then RD_VALOR else RD_VALOR * -1 end)/"+(cMesesMed)+",2) TOT"

cQuery += " from "+ RetSqlName("SRD") + " SRD "
cQuery += " inner join "+ RetSqlName("SRV")  +" SRV on RD_FILIAL = RV_FILIAL and RD_PD = RV_COD"
cQuery += " Where RD_FILIAL ='"+SRA->RA_FILIAL+"' and RD_MAT ='"+SRA->RA_MAT+"' and RV_MEDFER = '" + cMesesMed  +"' and RD_ROTEIR ='FOL' "
cQuery += " and RD_DATARQ >= '" +cMesAno+"' and RD_DATARQ <= '" +MesAno(dDataFim)+"'  "
cQuery += " and RV_TIPOCOD in ('1','2') "

If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif

TcQuery cQuery New Alias "QRY" 
nDifMes := Round((QRY->TOT / 30) * ndias,2) - nValorOr

if nDifMes >0
   // gerar verba de diferença de médias
   FGERAVERBA("313", nDifMes ,nDias,CSEMANA,SRA->RA_CC,,"C",,,DDATA_PGTO,.T.,,,,,,,,DDATAREF)
Endif

if fBuscaPd('188') > 0
   nDias     := apd[ascan( apd,  {|x|x[1] ='182'} ) ,4]
   nValorOr  := fBuscaPD("188,189")
   nDifMes := Round((QRY->TOT / 30) * ndias,2) - nValorOr
   if nDifMes >0
      // gerar verba de diferença de médias seguintes
      FGERAVERBA("314", nDifMes ,nDias,CSEMANA,SRA->RA_CC,,"C",,,DDATA_PGTO,.T.,,,,,,,,DDATAREF)
   Endif

Endif
Return
