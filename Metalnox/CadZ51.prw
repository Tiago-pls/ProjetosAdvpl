#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! CadZ51                                                  !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o       ! Cadastros dos codigos de Protheus para MDM              !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                            !
+------------------+---------------------------------------------------------!
!Data              ! 08/11/2022                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/

User Function CadZ51()
	Local cAlias := "Z51"
	Private cCadastro := "Grup Trib Compras"
	Private aRotina := {}
	AADD(aRotina,{"Pesquisar"  ,"AxPesqui",0, 1})
	AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})
	AADD(aRotina,{"Incluir"    ,"AxInclui",0,3})
	AADD(aRotina,{"Alterar"    ,"AxAltera",0,4})
	AADD(aRotina,{"Excluir"    ,"AxDeleta",0,5})
	mBrowse(6,1,22,75,cAlias)
Return


user function ValidGrp
Local lRet := .T.
Local aZ51 := Z51->( GetArea())

Z51->( dbgoTop())
if Z51->( DbSeek( xFilial("Z51") + M->Z51_GPTRIB))
    MsgAlert("Grupo já cadastrado", "Atenção")
    lRet := .F.
Endif
RestArea(aZ51)
return lRet
