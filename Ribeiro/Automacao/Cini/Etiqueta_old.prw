//Fonte para impressão da etiqueta de transporte RACD004.prw
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


USER FUNCTION RACD004(_cRotina)

LOCAL _CPORTA := "LPT1"
LOCAL _AAREA := GETAREA()
local nPos := 1

if _cRotina == "MATA410"
    DbSelectArea("SF2")
    SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
    // teste

  
    if ! SF2->(DbSeek(SC5->(C5_FILIAL + C5_NOTA +C5_SERIE)))
        MSgAlert("Pedido ainda nao faturado!")
        Return
    Endif
Endif

MSCBPRINTER("Eltron",_CPORTA,,,.F.)//211
MSCBCHKSTATUS(.F.)

//MSCBINFOETI("ALLEGRO","MODELO 1")

DbSelectArea("SA1")
SA1->(DbSetOrder(1))
if SA1->(dBSeek(xFilial("SA1")+ SF2->F2_CLIENTE + SF2->F2_LOJA))
    
    while nPos<=SF2->F2_VOLUME1
            MSCBBEGIN(1,3)
        

            MSCBSAY(10,10,"DESTINATARIO:","B","3","1")
            MSCBSAY(17,10,SA1->A1_NOME,"B","4","1.4")
            MSCBSAY(25,10,SA1->A1_END,"B","3","1")
            MSCBSAY(30,10,"CEP: "+SubStr(SA1->A1_CEP,1,5)+"-"+ SubStr(SA1->A1_CEP,6,3) + " - " + alltrim(SA1->A1_MUN) + " - " + alltrim(SA1->A1_EST) + " - (" + alltrim(SA1->A1_DDD) +") "+ Transform(SA1->A1_TEL, "@R 9999-9999"),"B","3","1")
            //MSCBLINEH(30,20,75)

            MSCBLINEV(35,10,200)
            MSCBSAY(50,50,"N.F.:" + alltrim(SF2->F2_DOC) + "/" + alltrim(SF2->F2_SERIE),"B","5","3")
            MSCBSAY(65,40,"VOLUME:" + Alltrim(Strzero(nPos,3)) + "/" + Alltrim(Strzero(SF2->F2_VOLUME1,3)),"B","5","3")
            MSCBLINEV(75,10,200,25)
            MSCBSAY(80,50,"EMBALAGEM DE TRANSPORTE","B","3","2")
            MSCBSAY(87,30,"MANTER OS PRODUTOS SEMPRE BEM FECHADOS","B","3","1")
            MSCBLINEV(89,10,200,10)
            MSCBSAY(98,10, alltrim(SF2->F2_TRANSP) + " - " + alltrim(Posicione("SA4",1,xFilial("SA4")+SF2->F2_TRANSP,"A4_NOME")),"B","3","0.5")
            if _cRotina == "MATA410"
                MSCBSAY(98,120,"NUM. PEDIDO. " + alltrim(SC5->C5_NUM),"B","3","0.5")
            Else
                MSCBSAY(98,120,"NUM. PEDIDO. " + Posicione("SC6",4,xFilial("SC6")+SF2->F2_DOC+SF2->F2_SERIE,"C6_NUM"),"B","3","0.5")
            Endif
     
        nPos++

    EndDo
   MSCBEND() //RESTO
    Sleep(3000)
ENDIF

MSCBCLOSEPRINTER()
RESTAREA(_AAREA)

RETURN 
