#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! AxCadZ24                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Markup por Estado                                       !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                            !
+------------------+---------------------------------------------------------!
!Data              ! 03/08/2022                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/

User Function AxCadZ24
Local cAlias := "Z24"
Private cCadastro := "Markup por Estado"
Private aRotina := {}

AADD(aRotina,{"Pesquisar" ,"AxPesqui",0, 1})
AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})
AADD(aRotina,{"Incluir" ,"AxInclui",0,3})
AADD(aRotina,{"Alterar" ,"AxAltera",0,4})
AADD(aRotina,{"Excluir" ,"AxDeleta",0,5})

mBrowse(6,1,22,75,cAlias)
	
Return

user function ValidEst
Local lRet := .T.
Local aZ24 := Z24->( GetArea())

Z24->( dbgoTop())
if Z24->( DbSeek( xFilial("Z24") + M->Z24_ESTADO))
    MsgAlert("Estado já cadastrado", "Atenção")
    lRet := .F.
Endif

RestArea(aZ24)
return lRet


User Function AxCadZ25
Local cAlias      := "Z25"
Private cCadastro := "Markup por Grupo Tributário"
Private aRotina   := {}

AADD(aRotina,{"Pesquisar" ,"AxPesqui",0, 1})
AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})
AADD(aRotina,{"Incluir" ,"AxInclui",0,3})
AADD(aRotina,{"Alterar" ,"AxAltera",0,4})
AADD(aRotina,{"Excluir" ,"AxDeleta",0,5})

mBrowse(6,1,22,75,cAlias)
	
Return


user function ValidGrp
Local lRet := .T.
Local aZ25 := Z25->( GetArea())

Z25->( dbgoTop())
if Z25->( DbSeek( xFilial("Z25") + M->Z25_GRUPO))
    MsgAlert("Grupo já cadastrado", "Atenção")
    lRet := .F.
Endif
RestArea(aZ25)
return lRet



/*
grupo de aprovadores descontos no orçamento SIGATMK
*/
User Function AxCadZ26
Local cAlias      := "Z26"
Private cCadastro := "Grupo Aprovação Descontos"
Private aRotina   := {}

AADD(aRotina,{"Pesquisar" ,"AxPesqui",0, 1})
AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})
AADD(aRotina,{"Incluir" ,"AxInclui",0,3})
AADD(aRotina,{"Alterar" ,"AxAltera",0,4})
AADD(aRotina,{"Excluir" ,"AxDeleta",0,5})

mBrowse(6,1,22,75,cAlias)
	
Return
