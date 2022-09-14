#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"

/*-----------------+---------------------------------------------------------+
!Nome              ! FTAprLote                                               !
+------------------+---------------------------------------------------------+
!Descricao         ! Aprovação em lote aprovações                            !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                            !
+------------------+---------------------------------------------------------!
+ Data             + 18/04/2022                                              !
+------------------+--------------------------------------------------------*/

user function FTAprLote
Local cMsg	  := ""
Local cAviso  := ""	
local nCont := 0
Default aEmp  := {"01", "0101"}
RPCSetType(3)
RPCSetEnv(aEmp[1], aEmp[2], Nil, Nil, Nil, GetEnvServer())

cQuery := " Select RH3_FILIAL, RH3_CODIGO, RH3_MAT , RH3_TIPO, RH3_STATUS, RH3_DTSOLI"
cQuery += " from " + RetSqlName("RH3") + " RH3"
cQuery += " Where RH3.D_E_L_E_T_ =' ' and  RH3_TIPO IN ('8','Z') and RH3_STATUS ='4'"

If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif

TcQuery cQuery  New Alias "QRY"    

dbSelectArea('RH3')
dbSetOrder(1) // RH3_FILIAL + RH3_CODIGO
While QRY->( !EOF())
    If QRY->RH3_TIPO == "Z" //Marcação de Ponto via Portal
        nRet := fAprovPon( QRY->RH3_FILIAL, QRY->RH3_MAT, QRY->RH3_CODIGO, @cMsg, @cAviso, .F. )
        DbSelectArea("SRA")
        DbSetOrder(1)
        SRA->(DbSeek(QRY->RH3_FILIAL + QRY->RH3_MAT))
        If nRet == 1
            ConOut(cMsg)
            ConOut(cAviso)
            loop			
        ElseIf nRet == 2
            ConOut("Marcacao esta fora do periodo aberto, nao podera ser incluida!")
            loop
        Else
            RH3->( DbGotop())
            RH3->(dbSeek(QRY->(RH3_FILIAL + RH3_CODIGO)))
            If RecLock("RH3",.F.)
                RH3->RH3_STATUS	:= '2'
                RH3->RH3_DTATEN	:= DDATABASE
                MsUnLock()
            Endif
        EndIf
        elseIf QRY->RH3_TIPO == "8" //Marcação de Ponto via Portal
            RH3->( DbGotop())
            RH3->(dbSeek( QRY->(RH3_FILIAL + RH3_CODIGO)))
            If RecLock("RH3",.F.)
                RH3->RH3_STATUS	:= '2'
                RH3->RH3_DTATEN	:= DDATABASE
                MsUnLock()
            Endif
        EndIf    
    nCont++
    QRY->( DbSkip())
Enddo
ConOut("Total Solicitacoes aprovadas: -------> " + cValtoChar(nCont))
Return
