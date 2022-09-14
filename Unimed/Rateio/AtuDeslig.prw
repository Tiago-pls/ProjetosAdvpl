#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch" 
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ AtuDeslig ¦ Autor ¦  Tiago Santos        ¦ Data ¦25.08.20  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Atualiza os status Rateio FOlha para desligados            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User function AtuDeslig()

cQuery :=" select Distinct RG_FILIAL,  RG_MAT, RG_DATADEM from " + RetSqlName("SRG") +" SRG "
cQuery += " inner join " + RetSqlName("Z39")+" Z39 on RG_FILIAL = Z39_FILIAL and RG_MAT = Z39_FUNCIO"
cQuery += " where SRG.D_E_L_E_T_ =' ' and Z39_VIGENC ='S' and RG_EFETIVA ='S'"

If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif

If Select("Z39")==0         
	DbSelectArea("Z39")
Endif

Z39->( DbSetOrder(2))
TcQuery cQuery New Alias "QRY"
If QRY->(!Eof())
    While QRY->(!Eof())
        Z39->( dbGotop())
        Z39->( DbSeek( QRY->( RG_FILIAL + RG_MAT)))
            Begin Transaction
                RecLock("Z39",.F.)
                    Z39->Z39_VIGENC:= "N"
                MsUnLock("Z39") 
            end transaction 
    	QRY->(dbSkip())		
	End
Endif
Return
