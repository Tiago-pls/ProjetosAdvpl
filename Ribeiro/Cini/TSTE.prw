USER FUNCTION IMPRESSAO
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
cPorta := "LPT1:"
cModelo := "ELTRON"
cLogo := "SIGA.PCX"
MSCBPRINTER( cModelo, cPorta,,,.F.,,,,,"Ativo")
MSCBCHKStatus(.f.)
	MSCBBEGIN(1,6)
            MSCBGRAFIC(04,02,"SIGA")                   
            MSCBSAY(10,10,"DESTINATARIO:","B","3","1")
            MSCBSAY(17,10,'SA1->A1_NOME',"B","4","1.4")
            MSCBSAY(25,10,'SA1->A1_END',"B","3","1")
            MSCBSAY(30,10,"CEP: ",  "B","3","1")
            //MSCBLINEH(30,20,75)
            MSCBLINEV(35,10,200)
            MSCBSAY(50,50,"N.F.:","B","5","3")
            MSCBSAY(65,40,"VOLUME:","B","5","3")
            MSCBLINEV(75,10,200,25)
            MSCBSAY(80,50,"EMBALAGEM DE TRANSPORTE","B","3","2")
            MSCBSAY(87,30,"MANTER OS PRODUTOS SEMPRE BEM FECHADOS","B","3","1")
            MSCBLINEV(89,10,200,10)
            MSCBSAY(98,10, ,"B","3","0.5")
            MSCBSAY(98,120,"NUM. PEDIDO. ","B","3","0.5")
           
            MSCBEND() // Finaliza a formacao da imagem da etiqueta
            MSCBCLOSEPRINTER()
		MSCBBEGIN(1,6)
            MSCBGRAFIC(04,02,"SIGA")                   
            MSCBSAY(10,10,"DESTINATARIO:","B","3","1")
            MSCBSAY(17,10,'SA1->A1_NOME',"B","4","1.4")
            MSCBSAY(25,10,'SA1->A1_END',"B","3","1")
            MSCBSAY(30,10,"CEP: ","B","3","1")
            //MSCBLINEH(30,20,75)
            MSCBLINEV(35,10,200)
            MSCBSAY(50,50,"N.F.:" ,"B","5","3")
            MSCBSAY(65,40,"VOLUME:" ,"B","5","3")
            MSCBLINEV(75,10,200,25)
            MSCBSAY(80,50,"EMBALAGEM DE TRANSPORTE","B","3","2")
            MSCBSAY(87,30,"MANTER OS PRODUTOS SEMPRE BEM FECHADOS","B","3","1")
            MSCBLINEV(89,10,200,10)
            MSCBSAY(98,10, 'RE',"B","3","0.5")
            MSCBSAY(98,120,"NUM. PEDIDO. " ,"B","3","0.5")
       MSCBCLOSEPRINTER()    

RETURN
