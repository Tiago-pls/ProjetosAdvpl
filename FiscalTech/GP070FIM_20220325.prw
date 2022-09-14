#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

USER FUNCTION GP070FIM()
Local cTitulo:= "Teste Ponto de Entrada GP070FIM"
Local cMat := SRA->(RA_FILIAL + RA_MAT)
/*
6 - RT_FILIAL+RT_MAT+DTOS(RT_DATACAL)+RT_TIPPROV
*/
Local cQuery := " Select RT_FILIAL, RT_MAT, RT_CC, RT_TIPPROV, RT_VALOR,RT_VERBA from "+ RetSqlName("SRT") + " SRT "
cQuery       += " Where RT_FILIAL >= '" + cFilDe+"' and RT_FILIAL <= '" +cFilAte +"' "
cQuery       += " And RT_CC >= '" + cCcDe+"' and RT_CC <= '" +cCcAte +"' "
cQuery       += " and RT_MAT >= '" + cMatDe+"' and RT_MAT <= '" +cMatAte +"' "
cQuery       += " and RT_DATACAL>= '" + Dtos(dDataRef)+"' and RT_VERBAOR <> ' ' and D_E_L_E_T_ =' '"
cQuery       += " order by RT_FILIAL, RT_MAT, RT_CC, RT_TIPPROV"
aSRTArea := SRT->( GetArea())

If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif

TcQuery cQuery New Alias "QRY" 
/*
SRT->(dbSetOrder(4))
While QRY->( !EOF())

    aCC  := GetAdvFVal("SRA",{"RA_CC","RA_ITEM","RA_CLVL"},  QRY->(RT_FILIAL + RT_MAT),1,"")
    if (SRT->( dbSeek( QRY->(RT_FILIAL + RT_MAT) + aCC[1] + aCC[2] + aCC[3] + Dtos(dDataRef) + QRY->(RT_TIPPROV + RT_VERBA))))
    
        IF RecLock( "SRT" , .F. )
            SRT->RT_VALOR -= QRY->RT_VALOR
        SRT->( MsUnlock() )
        endif
    elseif QRY->RT_TIPPROV =='2'
        if (SRT->( dbSeek( QRY->(RT_FILIAL + RT_MAT) + aCC[1] + aCC[2] + aCC[3] + Dtos(dDataRef) + '1' + QRY->RT_VERBA)))
            IF RecLock( "SRT" , .F. )
                SRT->RT_VALOR -= QRY->RT_VALOR
            SRT->( MsUnlock() )
            endif
        endif
    Endif

    QRY->( DbSkip())
Enddo
*/
RestArea(aSRTArea)
Return
