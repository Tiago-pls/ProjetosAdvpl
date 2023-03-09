#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! AxCadZZZ                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Markup por Estado                                       !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                            !
+------------------+---------------------------------------------------------!
!Data              ! 13/02/2023                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/

User Function AxCadZZZ
Local cAlias := "ZZZ"
Private cCadastro := "Integração Fluig"
Private aRotina := {}

AADD(aRotina,{"Pesquisar" ,"AxPesqui",0, 1})
AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})
AADD(aRotina,{"Incluir" ,"AxInclui",0,3})
AADD(aRotina,{"Alterar" ,"AxAltera",0,4})
AADD(aRotina,{"Excluir" ,"AxDeleta",0,5})

mBrowse(6,1,22,75,cAlias)
	
Return

user function Valgrupo
Local lRet := .T.
Local aZZY := ZZY->( GetArea())

ZZY->( dbgoTop())
if ZZY->( DbSeek( xFilial("ZZY") + M->ZZY_GRUPO))
    MsgAlert("Grupo já cadastrado", "Atenção")
    lRet := .F.
Endif

RestArea(aZZY)
return lRet


User Function AxCadZZY
Local cAlias      := "ZZY"
Private cCadastro := "Grupo de Descontos"
Private aRotina   := {}

AADD(aRotina,{"Pesquisar" ,"AxPesqui",0, 1})
AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})
AADD(aRotina,{"Incluir" ,"AxInclui",0,3})
AADD(aRotina,{"Alterar" ,"AxAltera",0,4})
AADD(aRotina,{"Excluir" ,"AxDeleta",0,5})

mBrowse(6,1,22,75,cAlias)
	
Return
