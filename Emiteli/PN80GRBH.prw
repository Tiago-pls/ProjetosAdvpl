#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PRCONST.CH"

User Function PN80GRBH

Local nHrsPos       := 0 // 119
Local nHrsNeg       := 0 // 338
Local nSaldo        := 0
Local dDataGrv      := PARAMIXB[5]
Local dPerIni		:= Ctod("//")
Local dPerFim		:= Ctod("//")
Local cLastFil      := xFilial("SRA")
Local lPerCompleto	:= .F.
checkPonMes( @dPerIni , @dPerFim , NIL , NIL , .T. , cLastFil , NIL , @lPerCompleto )
dPerFim +=1
DbSelectArea("SPB") 
SPB->(DbSetorder(1))
SPB->( DbGotop() ) 
If SPB->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT)) 
	While SPB->(!EOF()) .AND. SRA->RA_FILIAL + SRA->RA_MAT == SPB->PB_FILIAL + SPB->PB_MAT 
		IF SPB->PB_PD == "119" // horas positivas
			nHrsPos := nHrsPos + SPB->PB_HORAS
			RecLock("SPB",.F.)
				SPB->(DbDelete())
			MsUnLock()
		ELSEIF SPB->PB_PD == "388" // horas negativas
			nHrsNeg := nHrsNeg + SPB->PB_HORAS
			RecLock("SPB",.F.)
				SPB->(DbDelete())
			MsUnLock()
		ENDIF

		SPB->(dbskip()) 		
	Enddo
Endif
nSaldo  := nHrsPos - nHrsNeg
DbSelectArea("SPB") 
SPB->(DbSetorder(1))
SPB->( DbGotop() ) 

// verificar se é o fechamento mensal ou semestral
if lFechMensal
	IF nSaldo < 0 // desconto
		RecLock("SPI",.t.)
			SPI->PI_FILIAL := SRA->RA_FILIAL
			SPI->PI_MAT    := SRA->RA_MAT
			SPI->PI_DATA   := nDtSaldo
			SPI->PI_PD     := "388"
			SPI->PI_CC     := SRA->RA_CC //POSICIONE("SRA",13,SRA->RA_MAT+SRA->RA_FILIAL,"RA_CC")
			SPI->PI_QUANT  := nSaldo
			SPI->PI_QUANTV := nSaldo
			SPI->PI_FLAG   := "I"
		MsUnLock()
	endif
else
	IF nSaldo < 0 // desconto
		//nSaldo := fConvHr(nSaldo*-1,'H',,3)
		
		RecLock("SPB",.t.)
			SPB->PB_FILIAL := SRA->RA_FILIAL
			SPB->PB_MAT    := SRA->RA_MAT
			SPB->PB_PD     := '388'
			SPB->PB_TIPO1  := 'H'
			SPB->PB_TIPO2  := "I"
			SPB->PB_HORAS  := nSaldo
			SPB->PB_DATA   := dPerFim -1
			SPB->PB_CC     := SRA->RA_CC
		SPB->(MsUnlock())
	ELSE
		RecLock("SPB",.t.)
			SPB->PB_FILIAL := SRA->RA_FILIAL
			SPB->PB_MAT    := SRA->RA_MAT
			SPB->PB_PD     := "182"
			SPB->PB_TIPO1  := "H"
			SPB->PB_TIPO2  := "I"
			SPB->PB_DATA   := dDataGrv
			SPB->PB_CC     := SRA->RA_CC
			SPB->PB_HORAS := nSaldo// Min(nSaldo ,20)
		SP8->(MsUnLock())

	ENDIF

endif

Return	

user function PNM080CPOS
public lFechMensal := 	MsgYesNo("Deseja realizar o fechamento mensal", "Atencao")
return
