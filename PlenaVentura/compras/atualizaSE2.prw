#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE2.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"

user Function AtuSE2()

cQuery := "Select * from " + RetSqlName("SE2") +" SE2"
cQuery += " where D_E_L_E_T_ =' ' and E2_NATUREZ =' ' "

if select("QRX2") <> 0
   QRX2->( DBCLOSEAREA(  ))
Endif

if select ("SE2")==0
    DbSelectArea("SE2")
Endif

SE2->( DBSETORDER( 1 ))
//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA                                                                                               

SE2->( DBGOTOP(  ))
TCQuery cQuery New Alias "QRX2"
//cQuery += " and RA_ADMISSA = ( select Max(RA_ADMISSA) from " + RetSqlName("SRA") + " SRA where RA_UNIMED = '"+cBenefic+"' and D_E_L_E_T_ =' ')"

While QRX2->( !EOF())
    SE2->( DBGOTOP(  ))
    if SE2->(DbSeek( QRX2 ->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
        cQuery := " Select E2_NATUREZ from "+ RetSqlName("SE2") +" SE2"
        cQuery += " Where E2_FORNECE ='" + SE2->E2_FORNECE  +"' and E2_LOJA ='"+ SE2->E2_LOJA+"' and "
        cQuery += " E2_EMISSAO = ( select max(E2_EMISSAO) from " + RetSqlName("SE2") +" SE22  where  SE22.E2_FORNECE  = SE2.E2_FORNECE and SE22.E2_LOJA  = SE2.E2_LOJA  and D_E_L_E_T_ =' ' and E2_NATUREZ <> ' ')"
        
        if select("QRX3") <> 0
            QRX3->( DBCLOSEAREA(  ))
        Endif
        TCQuery cQuery New Alias "QRX3"
        
        RECLOCK( "SE2", .F. )
            SE2->E2_NATUREZ := QRX3->E2_NATUREZ
        SE2->(MSUNLOCK())
    else
        MSGALERT( QRX2 ->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
    Endif   
    QRX2->( dbSkip())

Enddo
return
