User Function M020INC()
    Local aArea  := GetArea()
    Local lRet   := .T.
 
    DbSelectarea("CTD")
    CTD->(DbSetOrder(1))
    If ! CTD->(DbSeek(FWxFilial("CTD") + 'F' + SA2->A2_COD + SA2->A2_LOJA))
         
        RecLock("CTD", .T.)
            CTD->CTD_FILIAL := XFILIAL("CTD")
            CTD->CTD_ITEM   := 'F' + SA2->A2_COD + SA2->A2_LOJA
            CTD->CTD_DESC01 := SA2->A2_NOME
            CTD->CTD_CLASSE := "2"
            CTD->CTD_NORMAL := "0"
            CTD->CTD_BLOQ   := "2"
            CTD->CTD_DTEXIS := CTOD("01/01/1980")
            CTD->CTD_ITLP   := 'F' + SA2->A2_COD + SA2->A2_LOJA
            CTD->CTD_CLOBRG := "2"
            CTD->CTD_ACCLVL := "1"
        CTD->(MsUnLock())
    Endif
     
    RestArea(aArea)
Return lRet