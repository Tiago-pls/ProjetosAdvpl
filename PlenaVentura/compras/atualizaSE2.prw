#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE2.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"

user Function AtuSE2()

cQuery := "Select * from " + RetSqlName("SE2") +" SE2"
cQuery += " where D_E_L_E_T_ =' ' and E2_NATUREZ =' ' and E2_VENCTO >='20231001' "

if select("QRX2") <> 0
   QRX2->( DBCLOSEAREA(  ))
Endif

if select ("SE2")==0
    DbSelectArea("SE2")
Endif

SE2->( DBSETORDER( 1 ))                                                                                            
SE2->( DBGOTOP(  ))
TCQuery cQuery New Alias "QRX2"
cLenSA2 :=cValtoChar(len(alltrim(xFilial("SA2"))) )
While QRX2->( !EOF())
    SE2->( DBGOTOP(  ))
    if SE2->(DbSeek( QRX2 ->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))

        // 1 Ultima natureza lançada para o fornecedor
        cQuery := " Select E2_NATUREZ NATUREZA from "+ RetSqlName("SE2") +" SE2"
        cQuery += " Where E2_FORNECE ='" + SE2->E2_FORNECE  +"' and E2_LOJA ='"+ SE2->E2_LOJA+"' and "
        cQuery += " E2_EMISSAO = ( select max(E2_EMISSAO) from " + RetSqlName("SE2") +" SE22  where  SE22.E2_FORNECE  = SE2.E2_FORNECE and SE22.E2_LOJA  = SE2.E2_LOJA  and D_E_L_E_T_ =' ' and E2_NATUREZ <> ' ')"
        cQuery := ChangeQuery(cQuery)
        if select("QRX3") <> 0
            QRX3->( DBCLOSEAREA(  ))
        Endif       
        TCQuery cQuery New Alias "QRX3"

        if Empty(QRX3->NATUREZA)
            //2 Pedido
            cQuery := " Select C7_ZNATURE NATUREZA from "+RetSqlName("SC7") +" SC7"
            cQuery += " Where D_E_L_E_T_ =' ' and C7_FORNECE ='"+QRX2->E2_FORNECE+"' and C7_LOJA ='"+QRX2->E2_LOJA+"'  "
            cQuery += " AND SubString('" + QRX2->E2_FILIAL+"' ,1,"+cLenSA2+")   =  SubString(C7_FILIAL ,1,"+cLenSA2+") "
            cQuery += " AND C7_DINICOM = ( select max(C7_DINICOM) from " + RetSqlName("SC7") +" SC72  where  SC72.C7_FORNECE  = SC7.C7_FORNECE and SC72.C7_LOJA  = SC7.C7_LOJA  and D_E_L_E_T_ =' ' and C7_ZNATURE <> ' ')"
    
            cQuery := ChangeQuery(cQuery)
            if select("QRX3") <> 0
                QRX3->( DBCLOSEAREA(  ))
            Endif
            TCQuery cQuery New Alias "QRX3"
        
            if Empty(QRX3->NATUREZA)
                // 3 fornecedor
                cQuery := " Select A2_NATUREZ NATUREZA from "+RetSqlName("SA2") +" SA2"
                cQuery += " Where D_E_L_E_T_ =' ' and A2_COD ='"+QRX2->E2_FORNECE+"' and A2_LOJA ='"+QRX2->E2_LOJA+"' "
                cQuery += " AND SubString('" + QRX2->E2_FILIAL+"' ,1,"+cLenSA2+")   =  SubString(A2_FILIAL ,1,"+cLenSA2+") "
                cQuery := ChangeQuery(cQuery)
                if select("QRX3") <> 0
                    QRX3->( DBCLOSEAREA(  ))
                Endif
                TCQuery cQuery New Alias "QRX3"
            Endif
        Endif 
        if !Empty(QRX3->NATUREZA)
            RECLOCK( "SE2", .F. )
                SE2->E2_NATUREZ := QRX3->NATUREZA
            SE2->(MSUNLOCK())
        Endif
    else
        MSGALERT( QRX2 ->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
    Endif   
    QRX2->( dbSkip())
Enddo
return
