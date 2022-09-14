#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PRCONST.CH"

user function PN80GRBH()
Local aArea := GetArea()
Local nHrsPos := 0 // 518
Local nHrsNeg := 0 // 519
Local nSaldo  := 0
Local cPDCred :="269"
Local cPDDeb  :="961"

nHrsPos := Posicione("SPB",1,SRA->RA_FILIAL + SRA->RA_MAT + cPDCred + SRA->RA_CC,"PB_HORAS")
nHrsNeg := Posicione("SPB",1,SRA->RA_FILIAL + SRA->RA_MAT + cPDDeb + SRA->RA_CC,"PB_HORAS")
nSaldo  := nHrsPos - nHrsNeg
	
If nSaldo > 0
		
	DbSelectArea("SPB")
	DbSetOrder(1)
	DbGoTop()
	IF DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cPDCred) //PC_FILIAL+PC_MAT+PC_PD
		RecLock("SPB",.F.)
		SPB->PB_HORAS := nSaldo
		SPB->PB_TIPO2 := "I"
		MsUnLock()
	ENDIF
	
	DbSelectArea("SPB")
	DbSetOrder(1)
	DbGoTop()
	IF DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cPDDeb) //PC_FILIAL+PC_MAT+PC_PD
		RecLock("SPB",.F.)
		SPB->(DbDelete())
		MsUnLock()
	ENDIF
	
Else
		
		// Quando for negativo
	
	DbSelectArea("SPB")
	DbSetOrder(1)
	DbGoTop()
	IF DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cPDCred) //PC_FILIAL+PC_MAT+PC_PD
		RecLock("SPB",.F.)
		SPB->(DbDelete())
		MsUnLock()
	ENDIF
	
	DbSelectArea("SPB")
	DbSetOrder(1)
	DbGoTop()
	IF DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cPDDeb) //PC_FILIAL+PC_MAT+PC_PD
		RecLock("SPB",.F.)
		SPB->(DbDelete())
		MsUnLock()
	ENDIF
	
EndIf
RestArea(aArea)
return