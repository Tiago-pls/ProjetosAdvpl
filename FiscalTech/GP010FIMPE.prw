#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! GP010FIMPE                                              !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o       ! PE cadastrar usuario Portal RD0                         !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                            !
+------------------+---------------------------------------------------------!
!Data              ! 14/04/2022                                              !
!Data              ! 19/10/2022 - Tratar somente admissão                    !
!Data              ! 11/01/2021 - alteração do usuário padrão para 000547    !
+------------------+--------------------------------------------------------*/

User Function GP010FIMPE ()
Local aArea   := RD0->(GetArea() )

if INCLUI // alteração 19/10/2022
	cLogin := RetLogin( Alltrim(M->RA_NOME))
	RD0->(DbSetorder(6)) // CPF
	RD0->( DbGotop() ) 
	If RD0->( DbSeek(xFilial("RD0") + SRA->RA_CIC))
		While RD0->(!EOF()) .AND. SRA->RA_CIC == RD0->RD0_CIC
			IF RD0->RD0_DTADMI = SRA->RA_ADMISSA
				RecLock("RD0", .F.)	
				RD0->RD0_PORTAL := "000547"
				RD0->RD0_LOGIN := cLogin
				RD0->RD0_FILRH := M->RA_FILIAL
				MsUnLock()
			ENDIF
		RD0->(dbskip()) 
		Enddo
	Endif
endif

RestArea(aArea)
Return(Nil)


static function RetLogin(cNome)

Local cSobreNome :=""
Local lProcura := .T.

While lProcura
	cPNome := Left (cNome, at(' ',cNome)-1)
	cSobrenome:= right( cNome, Len(cNome) - rat(' ',cNome))
	clogin:= cPNome+'.'+cSobrenome

	DbSelectArea("RD0") 
	RD0->(DbSetorder(9)) // Login
	RD0->( DbGotop() ) 

	if RD0->( Dbseek( xFilial("RD0") + cLogin))
		cNome := Alltrim(left( M->RA_NOME,  rat(' ',cNome)))
	else
		lProcura := .F.
	Endif
Enddo
Return cLogin
