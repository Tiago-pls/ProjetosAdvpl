#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"


//-------------------------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------------------------
// Fonte que faz as baixas dos títulos a receber gerados pela rotina de importação PDV
//------------------------------------------------------------------------------------------------------------------------------------------
//SMS - 05/07/2021
//------------------------------------------------------------------------------------------------------------------------------------------


user function BXSE1
Local aBaixa := {}
Private lMsErroAuto:= .F.
PREPARE ENVIRONMENT EMPRESA "03" FILIAL "01"

conout("Teste de Baixa de Titulo")
if select("QRY")<>0
    dbCloseArea("QRY")
Endif

cQuery := "Select E1_PREFIXO, E1_NUM, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NATUREZ, E1_PARCELA"
//cQuery += "AUTMOTBX, CBANCO, CAGENCIA, CCONTA, AUTDTBAIXA, AUTDTCREDITO, AUTDTCREDITO, AUTHIST, AUTJUROS"
cQuery += " from "+ RetSqlName("SE1")+" SE1 "
cQuery += " Where SE1.D_E_L_E_T_ =' ' and E1_SALDO > 0 and (E1_PREFIXO ='PDV' or E1_PEDIDO <> ' ')"
TcQuery cQuery New Alias "QRY"

While QRY->(!Eof()) 
 aBaixa := {{"E1_PREFIXO"  ,QRY->E1_PREFIXO ,Nil },;
            {"E1_NUM"      ,QRY->E1_NUM ,Nil },;
            {"E1_TIPO"     ,QRY->E1_TIPO ,Nil },;
            {"E1_CLIENTE"  ,QRY->E1_CLIENTE ,Nil },;
            {"E1_LOJA"     ,QRY->E1_LOJA ,Nil },;
            {"E1_NATUREZ"  ,QRY->E1_NATUREZ ,Nil },;
            {"E1_PARCELA"  ,QRY->E1_PARCELA ,Nil },;
            {"AUTMOTBX"    ,'NOR' ,Nil },;
            {"CBANCO"      ,"237" ,Nil },;
            {"CAGENCIA"    ,"1010 " ,Nil },;
            {"CCONTA"      ,"10101 " ,Nil },;
            {"AUTDTBAIXA"  ,dDataBase ,Nil },;
            {"AUTDTCREDITO",dDataBase,Nil },;
            {"AUTHIST"     ,"TESTE CADASTRO 002000002 " ,Nil },;
            {"AUTJUROS"    ,0 ,Nil,.T.}}
            //{"NVALREC" ,560,Nil }}
 
    MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3) //3 - Baixa de Título, 5 - Cancelamento de baixa, 6 - Exclusão de Baixa.

    If lMsErroAuto
        MostraErro()
    Else
        conout("BAIXADO COM SUCESSO!" + E1_NUM)
    Endif
    QRY->( DbSKIP())
Enddo

RESET ENVIRONMENT
Return
