#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"


User Function AxCadZSA
Local cAlias      := "ZSA"
Private cCadastro := "Grupo de Aprovadores"
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
