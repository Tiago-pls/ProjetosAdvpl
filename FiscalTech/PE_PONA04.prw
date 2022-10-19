#INCLUDE "topconn.ch"
/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                            !
+------------------+---------------------------------------------------------+
!Descricao         !Troca de eventos para o turno 125 no sábado              !
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Nome              ! PONAPO4                                                 !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 19/09/2022                                              !
+------------------+---------------------------------------------------------+

+------------------+--------------------------------------------------------*/
User Function PonaPo4()
Local aArea     := GetArea()
Local __aResult := aClone( aEventos )
Local nPosicao  := 0
Local cTurno    := SuperGetMV("FT_TNOHES", .T., "125")
Local cEvento   := SuperGetMV("FT_EVEHES", .T., "300")

// Tratar Sabado e Banco de Horas
if cTurno == SRA->RA_TNOTRAB
    for nPosicao:= 1 to Len(__aResult) 
        if Dow(__ARESULT[nPosicao][1])== 7 .and. __ARESULT[nPosicao][2]  =='200'// sabado e Banco de horas
            __ARESULT[nPosicao][2] := cEvento // evento hora extra
        Endif
    NEXT nPosicao
endif

aEventos := aClone( __aResult )
RestArea(aArea)
Return
