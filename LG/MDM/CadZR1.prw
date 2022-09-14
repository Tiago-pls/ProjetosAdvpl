#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! CadZR1                                                  !
+------------------+---------------------------------------------------------+
!Descrição       ! Cadastros dos codigos de Protheus para MDM              !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                            !
+------------------+---------------------------------------------------------!
!Data              ! 03/12/2010                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/

User Function CadZR1()
	Local cAlias := "ZR1"
	Private cCadastro := "Codification Table"
	Private aRotina := {}
	AADD(aRotina,{"Pesquisar"  ,"AxPesqui",0, 1})
	AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})
	AADD(aRotina,{"Incluir"    ,"AxInclui",0,3})
	AADD(aRotina,{"Alterar"    ,"AxAltera",0,4})
	AADD(aRotina,{"Excluir"    ,"AxDeleta",0,5})
	mBrowse(6,1,22,75,cAlias)
Return
