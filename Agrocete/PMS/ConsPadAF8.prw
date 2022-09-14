#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/11/00
/*/{Protheus.doc} zModel2
Exemplo de Modelo 2 para cadastro de SX5
@author Tiago Santos
@since 24/05/2021
@version 1.0
	@return Nil, Função não tem retorno
	@example
	TarProj()
	AF9 -> Tarefas
    AF8 -> Projetos
/*/
User Function ConEspOp()
   Local oDlg, oLbx
   Local aCpos  := {}
   Local aRet   := {}
   Local cQuery := ""
   Local cAlias := GetNextAlias()
   Local lRet   := .F.
   Local cProjeto :=aCols[n,2]
   cQuery := " select * from "+ RetSqlName("AF9") +" where D_E_L_E_T_ =' ' and  AF9_PROJET ='"+ cProjeto +"'"
   cQuery += " ORDER BY AF9_EDTPAI, AF9_TAREFA "
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

   While (cAlias)->(!Eof())
      aAdd(aCpos,{ (cAlias)->(AF9_REVISA), Alltrim((cAlias)->(AF9_EDTPAI)) , Alltrim((cAlias)->(AF9_TAREFA)), Alltrim((cAlias)->(AF9_DESCRI))})
      (cAlias)->(dbSkip())
   End
   (cAlias)->(dbCloseArea())

   If Len(aCpos) < 1
      aAdd(aCpos,{" "," "," "," "})
   EndIf

   DEFINE MSDIALOG oDlg TITLE /*STR0083*/ "Roteiro de operações" FROM 0,0 TO 260,500 PIXEL

     @ 10,10 LISTBOX oLbx FIELDS HEADER 'REVISAO', 'EDTPAI' /*"Roteiro"*/, 'Tarefa' /*"Produto"*/, 'Descricao',  SIZE 250,95 OF oDlg PIXEL

     oLbx:SetArray( aCpos )
     oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3], aCpos[oLbx:nAt,4]}}
     oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4]}}}

  DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4]})  ENABLE OF oDlg
  ACTIVATE MSDIALOG oDlg CENTER

  If Len(aRet) > 0 .And. lRet
     If Empty(aRet[1])
        lRet := .F.
     Else
        AF9->( dbSetOrder(1))
        AF9->( DbGotop())
        AF9->( dbSeek(xFilial("AF9") + cProjeto +  aRet[1]+aRet[3]))
     EndIf
  EndIf
Return lRet


user function GatEDIPAI()


Return '9999'
