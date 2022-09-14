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
Local cQuery := " Select *  from "+ RetSqlName("SRT") + " SRT "
cQuery       += " Where RT_FILIAL >= '" + cFilDe+"' and RT_FILIAL <= '" +cFilAte +"' "
cQuery       += " And RT_CC >= '" + cCcDe+"' and RT_CC <= '" +cCcAte +"' "
cQuery       += " and RT_MAT >= '" + cMatDe+"' and RT_MAT <= '" +cMatAte +"' "
cQuery       += " and RT_VERBAOR <> ' ' and D_E_L_E_T_ =' '"
cQuery       += " order by RT_FILIAL, RT_MAT, RT_CC, RT_TIPPROV"
aSRTArea := SRT->( GetArea())

If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif

TcQuery cQuery New Alias "QRY" 
/*
SRT->(dbSetOrder(4))
While QRY->( !EOF())
    if !(SRT->( dbSeek( QRY->(RT_FILIAL + RT_MAT + RT_CC + RT_ITEM + RT_CLVL) + Dtos(dDataRef) + QRY->(RT_TIPPROV + RT_VERBA))))
    
        IF RecLock( "SRT" , .T. )
            SRT->RT_FILIAL  := QRY->RT_FILIAL
            SRT->RT_MAT     := QRY->RT_MAT
            SRT->RT_CC      := QRY->RT_CC
            SRT->RT_DATACAL := dDataRef
            SRT->RT_TIPPROV := QRY->RT_TIPPROV
            SRT->RT_VERBA   := QRY->RT_VERBA
            SRT->RT_VALOR   := QRY->RT_VALOR
            SRT->RT_DATABAS := StoD(QRY->RT_DATABAS)
            SRT->RT_SALARIO := QRY->RT_SALARIO
            SRT->RT_TIPMOVI := QRY->RT_TIPMOVI
            SRT->RT_ITEM    := QRY->RT_ITEM
            SRT->RT_VERBAOR := QRY->RT_VERBAOR
            SRT->( MsUnlock() )
        Endif        
    Endif
    QRY->( DbSkip())
Enddo
*/

RestArea(aSRTArea)
Return
