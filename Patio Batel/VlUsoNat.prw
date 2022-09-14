#include "protheus.ch"

User Function VlUsoNat() // não permite utilizar a natureza diferente de despesa

Local lRet := .T.
Local lUso := Iif(posicione("SED",1,xFilial("SED")+M->D1_NATUREZ,"ED_USO")$"0|2",.T.,.F.)

If !Empty(M->D1_NATUREZ)
	If	!lUso
		MsgStop("Natureza não pode ser utilizada nessa rotina","Uso da Natureza - VlUsoNat")
		lRet := .F.
	Endif
Endif

Return(lRet)


User Function VldUsoNt(CTab) // não permite utilizar a natureza diferente de despesa

Local lRet := .T.
Local lUso
If CTab == "SC1"
	lUso := Iif(posicione("SED",1,xFilial("SED")+M->C1_NATUREZ,"ED_USO")$"0|2",.T.,.F.)
	
	If !Empty(M->C1_NATUREZ)
		If	!lUso
			MsgStop("Natureza não pode ser utilizada nessa rotina","Uso da Natureza - VldUsoNt")
			lRet := .F.
		Endif
	Endif
ElseIf cTab == "SC7"
	lUso := Iif(posicione("SED",1,xFilial("SED")+M->C7_NATUREZ,"ED_USO")$"0|2",.T.,.F.)
	
	If !Empty(M->C7_NATUREZ)
		If	!lUso
			MsgStop("Natureza não pode ser utilizada nessa rotina","Uso da Natureza - VldUsoNt")
			lRet := .F.
		Endif
	Endif
	
EndIf
Return(lRet)