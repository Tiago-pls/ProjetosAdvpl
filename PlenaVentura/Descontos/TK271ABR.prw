#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! TK271LEG                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! PE para tratar clegendas                                !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                            !
+------------------+---------------------------------------------------------!
!Data              ! 06/09/2022                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/

User Function TK271ABR()
Local lRet := .T.
Local nOpc := Paramixb[1]
If nOpc == 4 .and. SUA->UA_XBLOQOR =='S'	
    Alert('Orçamento :' + SUA->UA_NUM + " encontra-se bloqueado por limite de desconto, por favor aguarde a liberação")	
    lRet := .F.
EndIf 

Return(lRet)
