#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

USER FUNCTION GrvZAS()
LOCAL aTitulos  :=  Array(8)
Local aSE1RECNO := {}
Local cFileErr := "/dirdoc/errows_"+procname()+"_"+dtos(date())+"_"+strtran(time(),":","")+".txt"
PRIVATE lMsErroAuto  :=  .F.
PREPARE ENVIRONMENT EMPRESA '05' FILIAL '040101' TABLES 'ZAS','SE1','SE5'

    If !LockByName("BXTIT",.T.,.F.)
        Conout("[BXTIT] - Rotina está sendo executada, execução cancelada. . ")
        RPCClearEnv()
    else
        BXTIT()
    endif

RESET ENVIRONMENT
return

static function BXTIT    
LOCAL aTitulos  :=  Array(8)
Local aSE1RECNO := {}
Local cFileErr := "/dirdoc/errows_"+procname()+"_"+dtos(date())+"_"+strtran(time(),":","")+".txt"
PRIVATE lMsErroAuto  :=  .F.

cQuery :=" Select * from " +RetSqlName("ZAS") +" ZAS"
cQuery += " Where D_E_L_E_T_ =' ' and ZAS_STATUS <> 'B'" // Baixado
cQuery += " and ZAS_DATAB ='"+ Dtos(dDatabase)+ "'" // bara ser baixado no dia da execução

If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif
TcQuery cQuery New Alias "QRY" 
While QRY->( !EOF())
    Aadd(aSE1RECNO,QRY->ZAS_RECNO)
    QRY->( DbSkip())
Enddo
aBcoBaixa := Separa(alltrim(SUPERGETMV( "AD_BCOBX", , "341;1538;648302",  )),";")

For nCont := 1 to Len(aSE1RECNO)
    aTitulos[1] :=  {aSE1RECNO[nCont]}
    aTitulos[2] :=  aBcoBaixa[1]
    aTitulos[3] :=  aBcoBaixa[2]
    aTitulos[4] :=  aBcoBaixa[3]
    aTitulos[5] :=  ''
    aTitulos[6] :=  ''
    aTitulos[7] :=  'OUTROS    '
    aTitulos[8] := DATE()
    MSExecAuto({|x,y| Fina110(x,y)},3,aTitulos)
    IF lMsErroAuto
        cStatus :="E" // ERRO
        cError := "Error: "
        aLog  := GetAutoGRLog() 
        aeval(aLog, {|x| cError += x+CRLF})
        memowrite(cFileErr, ;
                varInfo("aSE1RECNO",aSE1RECNO, , .f., .f.) + CRLF  ;
                + cError )  
        ConOut(Procname()+" -> "+cError)
    else
        cStatus :="B" // Baixado
    Endif
    ZAS->( DbGotop())
    if ZAS->( DbSeek( cValToChar(aSE1RECNO[nCont])))
        RECLOCK( "ZAS", .F. )
            ZAS->ZAS_STATUS := cStatus
        ZAS->(MSUNLOCK())
    endif
Next nCont
UnLockByName("BXTIT",.T.,.F.)
RETURN nil
