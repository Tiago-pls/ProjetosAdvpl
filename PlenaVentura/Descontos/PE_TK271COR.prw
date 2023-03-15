#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! TK271LEG                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! PE para tratar clegendas                                !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                            !
+------------------+---------------------------------------------------------!
!Data              ! 06/09/2022                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/

/*
PE chamado Outras Ações -> Legendas

*/
user function TK271LEG(cPasta) 
Local aArea  := GetArea()
aCores :={}

aCores := {	{"BR_MARRON"  	,"Atendimento" },; 	//"Atendimento"
    {"BR_AZUL"		,"Orcamento" },;      				//"Orçamento"
    {"BR_VERDE"    	,"Faturamento" },;					//"Faturamento"
    {"BR_VERMELHO" 	,"NF.Emitida" },;					//"NF.Emitida"
    {"BR_PINK" 	," Bloq Lim Desconto" },;					//"NF.Emitida"
    {"BR_PRETO"    	,'Cancelado' }}	

RestArea(aArea) 							
Return(aCores)


/*-----------------+---------------------------------------------------------+
!Nome              ! TK271COR                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! PE para tratar cor Mbrowse                              !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                            !
+------------------+---------------------------------------------------------!
!Data              ! 06/09/2022                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/

user function TK271COR

Local aCores    := {{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 1 .AND. Empty(SUA->UA_DOC))" , "BR_VERDE"   },;// Faturamento - VERDE
						{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 1 .AND. !Empty(SUA->UA_DOC))", "BR_VERMELHO"},;// Faturado - VERMELHO
   						{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 2 .and. (SUA->UA_XBLOQOR=='N'))"	, "BR_AZUL"   },;						// Orcamento - AZUL
   						{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 3)"	, "BR_MARRON" },; 						// Atendimento - MARRON
   						{"(!EMPTY(SUA->UA_CODCANC))","BR_PRETO"		},;
   						{"(SUA->UA_XBLOQOR=='S')","BR_PINK"		}} 														// Cancelado
   						
return aCores


