#INCLUDE "TCBROWSE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} M410AGRV
//TODO Ponto de entrada executado antes da exclusao do pedido de venda
@author SMS - Tiago Santos
@since 20/09/2022
@type function
/*/
user function M410AGRV()
Local aRet := GetArea()
    if ALTERA .and. SC5->C5_CONDPAG <> M->C5_CONDPAG
        cLog := "Alterado campo [C5_CONDPAG] DE: " + AllTrim(SC5->C5_CONDPAG) + " => PARA: " + AllTrim(M->C5_CONDPAG) + " | " + CRLF
	    U_FtGeraLog( cFilAnt, "SC5", xFilial("SC5") + SC5->C5_NUM, "Log Pedido de Venda.", cLog )
    endif
RestArea(aRet)
return .T.
