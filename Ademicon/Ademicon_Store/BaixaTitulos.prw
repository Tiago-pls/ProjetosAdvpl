#INCLUDE  "protheus.ch"

USER FUNCTION TSTF110Auto()

LOCAL aTitulos  :=  Array(8)
LOCAL aBcoBaixa := Separa(alltrim(SUPERGETMV( "AD_BCOBX", , "341;1538;648302",  )),";")
PRIVATE lMsErroAuto  :=  .F.
aTitulos[1] :=  {85,86,87}
aTitulos[2] :=  aBcoBaixa[1]
aTitulos[3] :=  aBcoBaixa[2]
aTitulos[4] :=  aBcoBaixa[3]
aTitulos[5] :=  ''
aTitulos[6] :=  ''
aTitulos[7] :=  'OUTROS    '
aTitulos[8] := DATE()

MSExecAuto({|x,y| Fina110(x,y)},3,aTitulos)

IF lMsErroAuto
    MostraErro()
ENDIF

RETURN nil
