#INCLUDE "TOTVS.CH"
#INCLUDE 'TBICONN.CH'

//#INCLUDE "XMLCSVCS.CH"
//-------------------------------------------------------------------------------------------------------------------------------------------
// RbPost - realizando um post em https://api.tabletcloud.com.br/
//-------------------------------------------------------------------------------------------------------------------------------------------
// PE Ponto de Entrada chamado depois da gravação de todos os dados e da impressão do cupom fiscal na Venda Assistida e após o processamento
// do Job LjGrvBatch(FRONT LOJA)
//------------------------------------------------------------------------------------------------------------------------------------------
//SMS - 21/05/2021
//------------------------------------------------------------------------------------------------------------------------------------------


user Function LJ7002

Local aArea :=GetArea()    
if !isincallstack("LJGRVBATCH")
    RECLOCK("SL1", .F.)      
        SL1->L1_SITUA:="RX"          
        SL1->L1_DOC:= cvaltochar(cCupom)
        SL1->L1_SERIE:= 'PDV'
    SL1->( MSUNLOCK())     // It unlocks the record.
endif

RestArea(aArea)
Return 
