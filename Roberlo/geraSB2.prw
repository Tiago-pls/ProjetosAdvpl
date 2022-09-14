#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

user function SB2FALT

cQuery := "select B1_COD from SB1030 left join SB2030 on B1_COD = B2_COD Where B2_FILIAL is NULL"
If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif
TcQuery cQuery New Alias "QRY"  

While QRY->( ! EOF())
    CriaSB2(QRY->B1_COD,'01')
    QRY->( DbSkip())
enddo
return
