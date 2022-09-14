#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! IbqZRL                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Rotina para cadastro de Veiculos                        !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 26/12/2013                                              !
+------------------+---------------------------------------------------------!
!Alt 06/01/2014    ! - Correção no tratamento no filtro para quando selecion !
!    Pedro         !   ar mais de 1 cliente, quando o usuário não tem acesso;!
+------------------+--------------------------------------------------------*/

User Function ibqZRL()
	Local cAlias := "SR9"
	Private cCadastro := "Historico SEFIP"
	Private aRotina := {}
    SR9->(dbSetFilter({|| (SR9->R9_CAMPO = 'RA_OCORREN') }, "(SR9->R9_CAMPO = 'RA_OCORREN')"))
	AADD(aRotina,{"Pesquisar" ,"AxPesqui",0, 1})
	AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})
	AADD(aRotina,{"Incluir" ,"AxInclui",0,3})
	AADD(aRotina,{"Alterar" ,"AxAltera",0,4})
	AADD(aRotina,{"Excluir" ,"AxDeleta",0,5})

//		AxCadastro(cAlias, cCadastro)
	mBrowse(6,1,22,75,cAlias)
	
Return