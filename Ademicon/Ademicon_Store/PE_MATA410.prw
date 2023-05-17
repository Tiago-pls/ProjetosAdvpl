#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#Include "TBICONN.ch"
#include "Fileio.ch"

User Function MT410ACE()
    Local aArea        := GetArea()
    Local lContinua    := .T.  
    Local nOpc            := PARAMIXB[1]
    Local lResiduo := IsInCallStack('MA410RESID')
     
    //Se for inclus�o, visualiza��o ou res�duo, permite continuar
    If (nOpc == 3) .Or. (nOpc == 2) .Or. (lResiduo)
        lContinua := .T.
         
    //Sen�o, mostra mensagem ao usu�rio
    Elseif !EMPTY( SC5->C5_IDFLUIG)
        MsgAlert("Pedido com origem do Fluig n�o pode ser manipulado!", "Aten��o")
        lContinua := .F.
    Endif
                     
    RestArea(aArea)
Return lContinua


