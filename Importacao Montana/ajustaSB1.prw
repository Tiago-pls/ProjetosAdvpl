#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"

user function AjustSB1
cQuery := "select B1_COD, B1_PDVLEG from SB10301_PDV where B1_PDVLEG <> ' ' and D_E_L_E_T_ =' '"

If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif

If Select("SB1")== 0
	dbselectArea("SB1")
Endif

TcQuery cQuery New Alias "QRY"   

While QRY->( !EOF())

    SB1->( dbgotop())
    if SB1->( dbSeek( xFilial("SB1") + QRY->B1_COD))
		if RecLock("SB1",.F.)
			SB1->B1_PDVLEG   := QRY->B1_PDVLEG
			MsUnLock("SB1")   
		endif  
    Endif
    QRY->(dbSkip())
Enddo
Return
