#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    �  ProvAfast   � Autor � Tiago Santos      � Data �27.09.19 ���
��+----------+------------------------------------------------------------���
���Descri��o �  Relatorio Gerencial Folha de Pagamento         		      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function ProvAfast
cCC := '402030200'

cQuery := " Select * from " + RetSqlName("SRT") +" SRT "
cQuery += " Where RT_CC = '"+cCC + "' and RT_DATACAL ='20200229' and D_E_L_E_T_ =' ' "
cQuery += " Order by RT_FILIAL, RT_MAT, RT_CC,RT_DATACAL, RT_TIPPROV, RT_VERBA "

If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif

If Select("SRT")==0         
	DbSelectArea("SRT")
Endif

SRT->( DbSetOrder(1)) // RT_FILIAL + RT_MAT + RT_CC + RT_DATACAL + RT_TIPPROV + RT_VERBA


TcQuery cQuery New Alias "QRY" 

While QRY->( ! EOF())

    SRT->( DbGotop())
    cChave := QRY->(RT_FILIAL + RT_MAT + RT_CC + '20200229' + RT_TIPPROV + RT_VERBA)

    If SRT->( DbSeek( cChave))
        RecLock("SRT", .F.)	 // Alteração
            dbDelete()

        MsUnLock() 

    Endif

    QRY->( DbSkip())

Enddo
QRY->( DbCloseArea())
Return