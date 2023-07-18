#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PRCONST.CH"

User Function PN80GRBH

Local nHrsPos  := 0 // 119
Local nHrsNeg  := 0 // 338
Local nSaldo   := 0
Local dDataGrv := PARAMIXB[5]
Local dPerIni		:= Ctod("//")
Local dPerFim		:= Ctod("//")
Local cLastFil  := xFilial("SRA")
Local lPerCompleto	:= .F.
checkPonMes( @dPerIni , @dPerFim , NIL , NIL , .T. , cLastFil , NIL , @lPerCompleto )
dPerFim +=1
DbSelectArea("SPB") 
SPB->(DbSetorder(1))
SPB->( DbGotop() ) 
If SPB->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT)) 
	While SPB->(!EOF()) .AND. SRA->RA_FILIAL + SRA->RA_MAT == SPB->PB_FILIAL + SPB->PB_MAT 
		IF SPB->PB_PD = "255" // horas positivas
			nHrsPos := nHrsPos + SPB->PB_HORAS
		ELSEIF SPB->PB_PD = "466" // horas negativas
			nHrsNeg := nHrsNeg + SPB->PB_HORAS
		ENDIF
		SPB->(dbskip()) 		
	Enddo
Endif
nSaldo  := nHrsPos - nHrsNeg
DbSelectArea("SPB") 
SPB->(DbSetorder(1))
SPB->( DbGotop() ) 
If SPB->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT)) 
	While SPB->(!EOF()) .AND. SRA->RA_FILIAL + SRA->RA_MAT == SPB->PB_FILIAL + SPB->PB_MAT 
		IF SPB->PB_PD = "255" .or. SPB->PB_PD = "466" 
			RecLock("SPB",.F.)
			SPB->(DbDelete())
			MsUnLock()
		ENDIF
		SPB->(dbskip())
	Enddo
Endif

IF nSaldo < 0 // desconto
	nSaldo := fConvHr(nSaldo*-1,'H',,3)
	nDtSaldo := stod(SubStr(POSICIONE("SX6",1,SRA->RA_FILIAL+"MV_PAPONTA","X6_CONTEUD"),10,8)) 
	RecLock("SPB",.t.)
		SPB->PB_FILIAL := SRA->RA_FILIAL
		SPB->PB_MAT    := SRA->RA_MAT
		SPB->PB_PD     := '535'
		SPB->PB_TIPO1  := 'H'
		SPB->PB_TIPO2  := "I"
		SPB->PB_HORAS  := nSaldo
		SPB->PB_DATA   := nDtSaldo
		SPB->PB_CC     := SRA->RA_CC
	SPB->(MsUnlock())
ELSE
	// se for positivo: pagar até 20 horas a 65 %
	// se maior pagar o restante em 100%
	RecLock("SPB",.t.)
		SPB->PB_FILIAL := SRA->RA_FILIAL
		SPB->PB_MAT    := SRA->RA_MAT
		SPB->PB_PD     := "182"
		SPB->PB_TIPO1  := "H"
		SPB->PB_TIPO2  := "I"
		SPB->PB_DATA   := dDataGrv
		SPB->PB_CC     := SRA->RA_CC
		SPB->PB_HORAS := Min(nSaldo ,20)
	SP8->(MsUnLock())
	
	if nSaldo > 20
		RecLock("SPB",.t.)
			SPB->PB_FILIAL := SRA->RA_FILIAL
			SPB->PB_MAT    := SRA->RA_MAT
			SPB->PB_PD     := "187"
			SPB->PB_TIPO1  := "H"
			SPB->PB_TIPO2  := "I"
			SPB->PB_DATA   := dDataGrv
			SPB->PB_CC     := SRA->RA_CC
			SPB->PB_HORAS := nSaldo - 20
		SP8->(MsUnLock())	
	Endif
ENDIF
Return	
