#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PRCONST.CH"

user function PN80GRBH()
Local aArea := GetArea()
Local nHrsPos := 0
Local nHrsNeg := 0
Local nSaldo  := 0
Local cPDCred :="209"
Local cPDDeb  :="461"

nHrsPos := Posicione("SPB",1,SRA->( RA_FILIAL + RA_MAT) + cPDCred ,"PB_HORAS")
nHrsNeg := Posicione("SPB",1,SRA->( RA_FILIAL + RA_MAT) + cPDDeb  ,"PB_HORAS")
nSaldo  := nHrsPos - nHrsNeg
	
If nSaldo > 0
		
	DbSelectArea("SPB")
	DbSetOrder(1)
	DbGoTop()
	IF SPB->( DbSeek(SRA->( RA_FILIAL + RA_MAT)+cPDCred)) //PC_FILIAL+PC_MAT+PC_PD
		RecLock("SPB",.F.)
		SPB->PB_HORAS := nSaldo
		SPB->PB_TIPO2 := "I"
		MsUnLock()
	ENDIF
	
	DbSelectArea("SPB")
	DbSetOrder(1)
	DbGoTop()
	IF SPB->( DbSeek(SRA->( RA_FILIAL + RA_MAT) + cPDDeb)) //PC_FILIAL+PC_MAT+PC_PD
		RecLock("SPB",.F.)
		SPB->(DbDelete())
		MsUnLock()
	ENDIF
	
Else		
		// Quando for negativo
	
	DbSelectArea("SPB")
	DbSetOrder(1)
	DbGoTop()
	IF SPB->( DbSeek(SRA->(RA_FILIAL + RA_MAT) + cPDCred)) //PC_FILIAL+PC_MAT+PC_PD
		RecLock("SPB",.F.)
		SPB->(DbDelete())
		MsUnLock()
	ENDIF
	
	DbSelectArea("SPB")
	DbSetOrder(1)
	DbGoTop()
	IF SPB->( DbSeek(SRA->(RA_FILIAL + RA_MAT) + cPDDeb)) //PC_FILIAL+PC_MAT+PC_PD
		RecLock("SPB",.F.)
		SPB->(DbDelete())
		MsUnLock()
	ENDIF
	
EndIf
RestArea(aArea)
return
