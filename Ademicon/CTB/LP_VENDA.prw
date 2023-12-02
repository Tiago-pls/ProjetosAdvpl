#Include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"


User function VlrVendaLP(cSeq,cIdFluig) 
Local nValor := 0
if select("Z11") ==0
    DBSELECTAREA( "Z11" )
Endif
cIdFluig := cValtoChar(val(cIdFluig))
Z11->(DbSetOrder(3)) // Z11_FILIAL+Z11_IDPROV                                                                                                                                           
Z11->(dbGotop())

if Z11->( DbSeek(xFilial('SE1') + cIdFluig))
    Do Case
        Case cSeq =='002'
            nvalor := Z11->(Z11_VBRCOM + Z11_ESTOQU)

        Case cSeq =='003'
            // E1_VALOR - estoque de Cotas - Comissao 
            nvalor := SE1->E1_VALOR -  Z11->(Z11_VBRCOM + Z11_ESTOQU + Z11_VCVCAU + Z11_VCVCGE + Z11_VCVCLI + Z11_VCVCRE)

        Case cSeq =='004'
        //Comissao 
            nvalor := Z11->(Z11_VCVCAU+Z11_VCVCGE+Z11_VCVCLI+Z11_VCVCRE)

        Case cSeq =='005'
        //E1_VALOR - estoque de Cotas - Comissao - Serviços pres' 
            nvalor :=SE1->E1_VALOR -  Z11->(Z11_VBRCOM + Z11_ESTOQU + Z11_VCVCAU + Z11_VCVCGE + Z11_VCVCLI + Z11_VCVCRE + Z11_VALLPR)
            
        Case cSeq =='006'
        //Comissao 
            nvalor := Z11->Z11_VALLPR
    EndCase 
endif

return nValor
