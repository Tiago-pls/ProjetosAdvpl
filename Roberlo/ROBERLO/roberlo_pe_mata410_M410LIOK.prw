#include "protheus.ch"
User Function M410LIOK
Local oGD  := ParamIXB
Local lRet := .T.

// este trecho deve NECESSARIAMENTE ficar logo antes do return!
// coloque quaisquer outras validacoes antes deste trecho
If lRet
	lRet := StaticCall(ROBERLO_PE_MATA410_MT410ROD, DescProg, 1)
EndIf
Return lRet