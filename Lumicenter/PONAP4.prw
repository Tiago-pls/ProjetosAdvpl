/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                            !
+------------------+---------------------------------------------------------+
!Descricao         !Ponto de entrada para gerar o evento esperífico do estag !
!                  !iario ou menor aprendiz          			             !
+------------------+---------------------------------------------------------+
!Nome              ! PONAPO4                                                 !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 23/03/2022                                              !
+------------------+--------------------------------------------------------*/

#INCLUDE "topconn.ch"

User Function PonaPo4()

Local aArea := GetArea()
Local __aMarcacoes  := aClone( ParamIxb[1] )
Local __aTabCalend  := aClone( ParamIxb[2] )
Local __aCodigos    := aClone( ParamIxb[3] )
Local __aEvesIds    := aClone( ParamIxb[4] )
Local __aResult	  := aClone( aEventos )
Local dDtGer	  := dDataBase
Local cEvento	  := "135"
Local cCusto 	  := SRA->RA_CC
Local cTpMarc 	  := ""
Local cPeriodo	  := ""
Local nTole   	  := 0
Local cArred	  := ""
Local lSubstitui	  := .T.
Local nPosicao	:= 0

IF SRA->RA_CATFUNC $'E|G' .or. SRA->RA_CATEG =='07'
	for nPosicao:= 1 to Len(aEventos)
		if  aEventos[nPosicao][2] = '101' //codigo do evento de adicional noturno 25%
			aEventos[nPosicao][2] := '123' // Alteração do evento de adicional noturno 50%
		ENDIF		
	NEXT nPosicao
ENDIF
RestArea(aArea)

Return( NIL )	

// inclusao do campo RA_CATEG para ser utilizado no apontamento mensal 
user Function PNM010CPOS
Local aArea := GetArea()
AAdd( ParamIxb,"RA_CATEG" )
RestArea(aArea)      
return ParamIxb
