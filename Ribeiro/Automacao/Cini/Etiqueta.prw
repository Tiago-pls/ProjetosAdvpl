#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"


User Function MA410MNU
Local area := GetArea()

aadd(aRotina,{'Imprime Etiqueta','U_RACD004("MATA410")' , 0 , 8,0,NIL}) //Chama a rotina de impressão de etiquetas para o pedido posicionado.

RestArea(area)
return NIL
USER FUNCTION TESTE
Local aArea := GetArea()
Local cString:= "SN1"
Local wnRel  := "ATFR99" //Nome Default do relatorio em Disco
Local cPerg	 := "AFR099"
Local titulo := "Etiquetas de Ativos Fixos"
Local cDesc1 := "Imprime Etiquetas de Ativos fixos, com seu respectivo código de barras"
Local cDesc2 :=""
Local cDesc3 :=""
Local nX
Local cPorta
Local cModelo := ""
Local cLogo := ""

cPorta := "LPT1"
cModelo := "ELTRON"
cLogo := "SIGA.PCX"
MSCBPRINTER( cModelo, cPorta,,,.F.,,,,,"Ativo")
MSCBCHKStatus(.f.)


RETURN

User Function RACD004(_cRotina)
Local aArea := GetArea()
Local cString:= "SN1"
Local wnRel  := "ATFR99" //Nome Default do relatorio em Disco
Local cPerg	 := "AFR099"
Local titulo := "Etiquetas de Ativos Fixos"
Local cDesc1 := "Imprime Etiquetas de Ativos fixos, com seu respectivo código de barras"
Local cDesc2 :=""
Local cDesc3 :=""
Local nX
Local cPorta
Local cModelo := ""
Local cLogo := ""

Private aReturn := { "Zebrado", 1, "Administração", 1, 2, 1, "",1 }
Private nomeprog:="ImpCodBarAtf"
Private nLastKey := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Cbtxt 	:= ""
cbcont	:= 0
li 		:= 0
m_pag 	:= 1
cPorta := "COM4:9600,n,8,2"
cPorta := "LPT1"
cModelo := "ELTRON"
cLogo := "SIGA.PCX"
MSCBPRINTER( cModelo, cPorta,,,.F.,,,,,"Ativo")
MSCBCHKStatus(.f.)
	MSCBBEGIN(1,6)
            MSCBGRAFIC(04,02,"SIGA")                   
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
            MSCBSAY(98,120,"NUM. PEDIDO. " + alltrim(SC5->C5_NUM),"B","3","0.5")
           
            MSCBEND() // Finaliza a formacao da imagem da etiqueta

            MSCBCLOSEPRINTER()
            
//MSCBLOADGRF(cLogo)
/*if _cRotina == "MATA410"
    DbSelectArea("SF2")
    SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
    // teste
  
    if ! SF2->(DbSeek(SC5->(C5_FILIAL + C5_NOTA +C5_SERIE)))
        MSgAlert("Pedido ainda nao faturado!")
        RestArea(aArea)
        Return
    Endif
    if SF2-> F2_VOLUME1 == 0
         MSgAlert("Volume igual a zero!")
        RestArea(aArea)
        Return
    Endif
Endif
*/
// Localiza o primeiro bem a ser impresso
//DbSelectArea("SA1")
QSA1->(DbSetOrder(1))
nPos := 1
if SA1->(dBSeek(xFilial("SA1")+ SF2->F2_CLIENTE + SF2->F2_LOJA))
    while nPos<=SF2->F2_VOLUME1
		MSCBBEGIN(1,6)
            MSCBGRAFIC(04,02,"SIGA")                   
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
            MSCBSAY(98,120,"NUM. PEDIDO. " + alltrim(SC5->C5_NUM),"B","3","0.5")
           
            MSCBEND() // Finaliza a formacao da imagem da etiqueta
        DbSkip()	
        nPos++	
    End		

endif
MSCBCLOSEPRINTER()
RestArea(aArea)
Return
