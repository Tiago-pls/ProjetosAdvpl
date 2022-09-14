#INCLUDE 'PROTHEUS.CH'
User Function GP070GRV()
Local aArea := GetArea()
Local cFilial := PARAMIXB[1]
Local cMat := PARAMIXB[2]
Local nTpProv := PARAMIXB[3]
Local cVBOri  := GetAdvFVal("SRV","RV_CODCOM_",xFilial("SRT") + RT_VERBA,1,"")
/*
If nTpProv != 4 .and. !Empty(cVBOri) .and. Empty(SRT->RT_VERBAOR )
    IF RecLock( "SRT" , .F. )
        SRT->RT_VERBAOR := SRT->RT_VERBA
        SRT->RT_VERBA := cVBOri
    SRT->( MsUnlock() )
    EndIF
EndIf
*/
RestArea( aArea )
Return
