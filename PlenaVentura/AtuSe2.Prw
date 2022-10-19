#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"


user function AtuSe2 ()
cQuery :=" Select  E2_FILIAL, E2_FORNECE, E2_LOJA, E2_NUM from SE2090 where D_E_L_E_T_ =' ' and E2_XANEXO ='1'"
cQuery +=" group BY E2_FILIAL, E2_FORNECE, E2_LOJA, E2_NUM "

if select("QRY") > 0
    QRY->( dbcloseArea())
Endif
TcQuery cQuery New Alias "QRY" 

if select("SF1") ==0
    DbSelectArea("SF1")
Endif

SF1->( DbSetOrder(2))
SF1->( Dbgotop())

While QRY->( ! EOF())
    if SF1->( DbSeek( QRY->(E2_FILIAL + E2_FORNECE + E2_LOJA + E2_NUM)))
        While SF1->(F1_FILIAL + F1_FORNECE + F1_LOJA +F1_DOC) == QRY->(E2_FILIAL + E2_FORNECE + E2_LOJA +E2_NUM)
            
                Reclock("SF1",.F.)
                    SF1->F1_XNESE2:= '1'
                SF1->(msUnlock()) 
            
        SF1->(DbSkip())
        enddo
    Endif
    QRY->( DbSkip())
Enddo
return
