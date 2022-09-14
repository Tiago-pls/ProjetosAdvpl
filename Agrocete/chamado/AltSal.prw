#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! AltSal                                                  !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o         ! Rotina para cadastro de Tipos de Alteções Salariais   !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                      !
+------------------+---------------------------------------------------------!
!Data              ! 03/12/2010                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/

User Function AltSal()
	Local cAlias := "SX5"
	Private cCadastro := "Tipos Alterações Salariais"
	Private aRotina := {}
    SX5->(dbSetFilter({|| (SX5->X5_TABELA = '41') }, "(SX5->X5_TABELA = '41')"))
	AADD(aRotina,{"Pesquisar" ,"AxPesqui",0, 1})
	AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})
	AADD(aRotina,{"Incluir" ,"AxInclui",0,3})
	AADD(aRotina,{"Alterar" ,"AxAltera",0,4})
	AADD(aRotina,{"Excluir" ,"AxDeleta",0,5})

	mBrowse(6,1,22,75,cAlias)
	
Return
