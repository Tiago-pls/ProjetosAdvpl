#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*__________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  MSD2460   - Autor - Tiago Santos      - Data -02.02.23   ---
--+----------+---------------------------------------------------------------
---Descri--o -  atualização dos campos do integrador na nota fiscal       ---
--+-----------------------------------------------------------------------+--
--+-----------------------------------------------------------------------+--
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/

user function MAAVCRPR 
Local aArea     := GetArea()
Local cPedAtual	:= SC6->C6_NUM
Local aASC6		:= SC6->(GetArea())
Local lRet      := PARAMIXB[7] // se liberado ou nao

// controla a liberação de crédito para os pedidos que tenham integradores
if !Empty(SC5->C5_XINTEGR) .and. SA1->A1_XLIMINT =='S'
    if select("ZSA")==0
        DBSELECTAREA( 'ZSA' )
    Endif
    ZSA->( dbSetOrder(1))
    ZSA->( DbGotop())
    if ZSA->( DbSeek( xFilial('ZSA') + SC5->C5_XINTEGR))
        // calcular o valor total do pedido
        //Loop nos itens
        nVlPed := 0
		SC6->(DbSetorder(1))
		
		If SC6->(DbSeek(xFilial("SC6") + cPedAtual))        
            While (!SC6->(Eof()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. SC6->C6_NUM == cPedAtual)
                nVlPed += SC6->C6_VALOR
                SC6->(DbSkip())
            EndDo
            cAprovadores := SUPERGETMV( 'RS_LIBPEDI', , '999999',  )
            if RetCodUsr() $ cAprovadores
                // Gravar ZSD aprovadores
            else
                if ZSA->ZSA_LIMITE < nVlPed
                    cTitulo :='<font color="#ff0000">Limite de Credito Integrador Insuficiente</font>'           
                    cMsg :="<b>Limite Integrador: </b>"
                    cMsg += '<font color="#ff0000"> '+TRANSFORM(ZSA->ZSA_LIMITE, "@E 999,999,999.99")+ " </font>  "
                    cMsg += "  <b> Total Pedido: </b>"+ TRANSFORM(nVlPed, "@E 999,999,999.99")
                    cMsg += '<br><br><h3>Favor solicitar ao responsavel a liberação do pedido</h3> '                
                    MsgAlert(cMsg,cTitulo)
                    lRet := .F.
                else
                    lRet := .T.
                Endif
            endif
        Endif
        RestArea(aASC6)
    else
        MsgAlert("Limite de crédito não cadastrado para o Integrador")
        lRet := .F.
    Endif
Else
    MsgAlert("Análise de crédito por cliente e não por integrador")
Endif
RestArea(aArea)
Return lRet
