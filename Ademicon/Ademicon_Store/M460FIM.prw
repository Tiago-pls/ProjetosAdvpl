#Include "TOPCONN.CH"
#include "protheus.ch"
#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ M460FIM     ³ Autor ³  Márcio A. Zaguetti³ Data ³07.03.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ponto de entrada executado após a gravação do documento    ³±±
±±             de saída                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Específico - Conseg                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function M460FIM                        
Local aArea:=GetArea()
LOCAL aTitulos  :=  Array(8)
Local aSE1RECNO :={}
Local cFileErr := "/dirdoc/errows_"+procname()+"_"+dtos(date())+"_"+strtran(time(),":","")+".txt"
local cCondPIX := SUPERGETMV("AD_COND", .T., "031")
PRIVATE lMsErroAuto  :=  .F.
   // -> Atualiza informações da NF
   If Alltrim(FunName()) == "MATA461"                                                     
      // -> Atualiza dados da NF
      RecLock("SF2",.F.)
      SF2->F2_XNATURE:=SC5->C5_XNATURE
      MsUnlock("SF2")
      // -> Atualiza Itens da NF
      DbSelectArea("SC6")
      SC6->(DbSetOrder(4))
      SC6->(DbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))
      While !SC6->(Eof()) .and. SC6->C6_FILIAL == SF2->F2_FILIAL .and. SC6->C6_NOTA == SF2->F2_DOC .and. SC6->C6_SERIE == SF2->F2_SERIE
         DbSelectArea("SD2")
         SD2->(DbSetOrder(8))
         If SD2->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))
            RecLock("SD2",.F.)
            SD2->D2_CCUSTO:=SC6->C6_XCCUSTO
            SD2->D2_ITEMCC:=SC6->C6_XITEMCC
            SD2->D2_CLVL  :=SC6->C6_XCLVL
            MsUnlock("SD2")
         EndIf
         SC6->(DbSkip())
      EndDo
   EndIf

   If Type("_xcNat") <> "U"
	   If SC5->C5_TIPO <> "D" //If incluido por Antonio em 29/12/2015 pois caso nao encontre, gera mensagem de EOF e rollback
	      DbSelectArea("SA1")
	      SA1->(DbSetOrder(1))
	      SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
	      RecLock("SA1",.F.)   
	      SA1->A1_NATUREZ:=_xcNat
	      MsUnlock("SA1") 
	   EndIf
   EndIf
      // Tiago Santos
   if SC5->(FieldPos( "C5_IDFLUIG" )) > 0
      if !Empty(SC5->C5_IDFLUIG)
         cSql := "SELECT E1_VENCTO, R_E_C_N_O_ AS REC FROM "+RetSqlName("SE1")
         cSql += " WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND D_E_L_E_T_<>'*' "
         cSql += " AND E1_PREFIXO = '"+SF2->F2_SERIE+"' AND E1_NUM = '"+SF2->F2_DOC+"' "
         cSql += " AND E1_TIPO = 'NF' "
         TcQuery ChangeQuery(cSql) New Alias "_QRY"
         //Enquanto tiver dados na query
         While !_QRY->(eof())
            DbSelectArea("SE1")
            SE1->(DbGoTo(_QRY->REC))
               
            //Se tiver dados, altera o tipo de pagamento
            If !SE1->(EoF())
               AAdd(aSE1RECNO, {_QRY->REC,E1_VENCTO})
               RecLock("SE1",.F.)
                  Replace E1_IDFLUIG WITH SC5->C5_IDFLUIG
               MsUnlock()
            EndIf
               
            _QRY->(DbSkip())
         Enddo
         _QRY->(DbCloseArea())
            For nCont :=1 to len(aSE1RECNO)
               RECLOCK( "ZAS", .T. )
                  ZAS->ZAS_FILIAL := xFilial("ZAS")
                  ZAS->ZAS_RECNO  := aSE1RECNO[nCont,1] 
                  ZAS->ZAS_DATAB  := aSE1RECNO[nCont,2] 
                  ZAS->ZAS_STATUS := 'N'
                  ZAS->ZAS_DATAIN := ddatabase
                  ZAS->ZAS_HORA := Time()
               ZAS->(MSUNLOCK())
            Next nCont
      Endif
   Endif
RestArea(aArea)
Return
