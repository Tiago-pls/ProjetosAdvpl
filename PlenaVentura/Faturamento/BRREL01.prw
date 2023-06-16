#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#DEFINE MAXBOXV   2450
#DEFINE INIBOXH   -10
/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    �  BRREL01	   � Autor � Luciane             � Data �02.10.21 ���
��+----------+------------------------------------------------------------���
���Descri��o �  Relat�rio de Transporte de Bens Ativo Imobilizado		  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function BRREL01()

Local aPergs := {}
Local cPerg := PadR("BRREL01",10)

ValidPerg(cPerg)

If !Pergunte (PadR(cPerg,10),.T.)
	Return .F.
EndIf

Processa({|| MontaRel() }, "Montando Relat�rio...")

Return

Static Function MontaRel()
Private	cLocal		:= GetTempPath()
Private nLin 		:= 10 	//Controlador da posi��o das linhas Verticais
Private nCol 		:= 10   //Controlador da posi��o das linhas horizontais 
Private nPag		:= 1  
Private nColTot		:= 0
Private nTotal		:= 0
Private cDoc        := MV_PAR01
Private cSerie      := MV_PAR02
Private lAdjustToLegacy := .t.
Private lDisableSetup 	:= .F.

//Fontes do Relat�rio Gr�fico
oFont1  := TFont():New("Tahoma",,15,,.T.,,,,.T.,.F.)
oFont1n := TFont():New("Tahoma",,15,,.F.,,,,.F.,.F.)
oFont6  := TFont():New("Tahoma",,9,,.F.,,,,.F.,.F.)
oFont6n := TFont():New("Tahoma",,9,,.T.,,,,.F.,.F.)
oFont12 := TFont():New("Tahoma",,12,,.F.,,,,.F.,.F.)     
oFont12i:= TFont():New("Tahoma",,12,,.F.,,,,.F.,.F.,.T.)     
oFont12s:= TFont():New("Tahoma",,12,,.F.,,,,.F.,.T.,.F.)     
oFont12n:= TFont():New("Tahoma",,12,,.T.,,,,.F.,.F.)     
oFont16n:= TFont():New("Tahoma",,16,,.T.,,,,.F.,.F.)     
oFont36n:= TFont():New("Tahoma",,36,,.T.,,,,.F.,.F.)

//Posiciona na nota
If !SF2->(dbSeek(xFilial("SF2")+cDoc+cSerie))
	MsgStop("Documento "+Alltrim(cDoc)+"/"+Alltrim(cSerie)+" n�o encontrado!")
	Return
Endif
SD2->(dbSetOrder(3))	
SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))
//Posiciona no cliente
SA1->(dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))

IncProc("Gerando relat�rio para o documento "+Alltrim(cDoc)+"/"+Alltrim(cSerie))

cNome  := Alltrim(cDoc)+Alltrim(cSerie)                                                         

oPrint := FWMSPrinter():New(cNome+'.REL', IMP_PDF, lAdjustToLegacy,cLocal, lDisableSetup, , , , , , .F., )
oPrint:SetResolution(78) //Tamanho estipulado para a Danfe
//oPrint:SetPortrait() tiago Santos
oPrint:SetLandscape()
oPrint:SetPaperSize(9)
oPrint:SetMargin(60,60,60,60)
oPrint:setDevice(IMP_PDF)
oPrint:lServer 	:= .t.
oPrint:cPrinter	:= ""
oPrint:nDevice := IMP_PDF


     
nLin := 30
Canhoto()// tiago Santos
Cabec()
EmiDest()

//Bloco natureza da opera��o
nLin += 60
oPrint:Box(nLin,nCol,nLin+50,nCol+2385)
nLin += 30
oPrint:Say(nLin,nCol+10,"Natureza da opera��o realizada: "+Upper(Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_FINALID")),oFont12n,1400)

nLin += 30

CabecItem()  

While SD2->(!Eof()) .and. SD2->D2_FILIAL = xFilial("SD2") .and. SD2->D2_DOC = SF2->F2_DOC .and. SD2->D2_SERIE = SF2->F2_SERIE
	//Posiciona no produto
	SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))
	
	// tiago Santos
	SB5->(dbSeek(xFilial("SB5")+SD2->D2_COD))
	nTotal+= SD2->D2_TOTAL

	//Verifica a quebra de p�gina
	GetNewPage()

	//Imprime o item	
	ImpItem()
	SD2->(dbSkip())

End

Total()

nLin+=60
GetNewPage()

oPrint:Say(nLin,nCol+10,"DECLARO SOB AS PENAS DA LEI, QUE OS BENS DESCRITOS ACIMA N�O CONSTITUEM OBJETO DE MERCADORIA OU PRESTA��O QUE CONFIGURE HIPOTESE",oFont12i,1400)
nLin+=30
oPrint:Say(nLin,nCol+10,"DE INCID�NCIA DO ICMS.",oFont12i,1400)

nLin+=60
GetNewPage()

oPrint:Say(nLin,nCol+10,Capital(Alltrim(SM0->M0_CIDCOB))+", "+Strzero(Day(date()),2)+" de "+lower(mesExtenso(date()))+" de "+cvaltochar(Year(date()))+".",oFont12,1400)

nLin+=60
GetNewPage()

oPrint:Say(nLin,nCol+10,"Precedente Consulta n� 129 de 20-5-1999. E Precedente Consulta n� 056, de 29-3-1990.",oFont12,1400)

nLin+=60
GetNewPage()

oPrint:Say(nLin,nCol+10,"http://www.atendimento.fazenda.pr.gov.br/sacsefa/portal/index",oFont12s,1400)

nLin+=60
GetNewPage()
oPrint:Say(nLin,nCol+10,"Observa��es:",oFont12,1400)

nLin+=30
GetNewPage()
oPrint:Say(nLin,nCol+10,"� Destinat�rios contribuintes do ICMS devem emitir nota fiscal de entrada quando do recebimento.",oFont12,1400)

nLin+=30
GetNewPage()
oPrint:Say(nLin,nCol+10,"� A fiscaliza��o poder� solicitar a apresenta��o de documento que comprove a propriedade do bem transportado e a natureza",oFont12,1400)
nLin+=30
oPrint:Say(nLin,nCol+10,"  da opera��o declarada.",oFont12,1400)

nLin+=30
GetNewPage()
oPrint:Say(nLin,nCol+10,"  Assim, � recomend�vel que, al�m da presente Declara��o, o transporte seja acompanhado de:",oFont12,1400)

nLin+=30
GetNewPage()
oPrint:Say(nLin,nCol+10,"       � Contrato social, quando os bens pertencerem a pessoa jur�dica.",oFont12,1400)

nLin+=30
GetNewPage()
oPrint:Say(nLin,nCol+10,"       � C�pia do Contrato de loca��o, quando se tratar de movimenta��o de bem destinado a aluguel.",oFont12,1400)

nLin+=30
GetNewPage()
oPrint:Say(nLin,nCol+10,"       � Documenta��o fiscal da opera��o que deu origem � devolu��o, no caso de devolu��o.",oFont12,1400)

nLin+=30
GetNewPage()
oPrint:Say(nLin,nCol+10,"       � Documento fiscal de origem do bem, emitida pelo fornecedor, ou documenta��o que comprove sua propriedade.",oFont12,1400)

nLin+=30
GetNewPage()
oPrint:Say(nLin,nCol+10,"�  A presente declara��o n�o impede a verifica��o da carga, bem como o lan�amento relativo � eventual infra��o tribut�ria pela ",oFont12,1400)
nLin+=30
oPrint:Say(nLin,nCol+10,"  Fiscaliza��o, nos termos da legisla��o vigente.",oFont12,1400)

nLin+=50
MensAdic()

oPrint:EndPage() //Fecha a p�gina
oPrint:Preview()

Return


//---------------------------------+
//       IMPRIME CABE�ALHO         !
//---------------------------------+
Static Function Cabec()
Local _cLogo    := "\system\lgrl"+cEmpAnt+".bmp"
 
//oPrint:StartPage()  

nLin += 30
oPrint:Line(nLin,nCol,nLin,nCol+2380)
nLin += 05
oPrint:SayBitMap(nLin,nCol+5,_cLogo,320,180)
oPrint:Say(nLin+20,nCol+2280,"P�g:"+strzero(nPag,3),oFont6,1400)
nLin+=50
// oPrint:Say(nLin,nCol+830,"DECLARA��O DE ALIENA��O",oFont16n,1400)
oPrint:Say(nLin,nCol+830,"DECLARA��O DE TRANSPORTE",oFont16n,1400)
nLin += 50
//oPrint:Say(nLin,nCol+630,"TRANSPORTE DE BENS DO ATIVO IMOBILIZADO",oFont16n,1400)
oPrint:Say(nLin,nCol+900,"E OUTROS FINS",oFont16n,1400)
nLin += 30
oPrint:Say(nLin+30,nCol+950,"N�."+SF2->F2_DOC+"/"+SF2->F2_SERIE,oFont16n,1400)

oPrint:Say(nLin,nCol+2140,"Emiss�o:"+CVALTOCHAR(Date()),oFont6,1400)
nLin += 30
oPrint:Say(nLin,nCol+2205,"Hora:"+CVALTOCHAR(Time()),oFont6,1400)
nLin += 30 
oPrint:Line(nLin,nCol,nLin,nCol+2380)  

Return

//---------------------------------+
// Bloco Emitente e Destinat�rio   !
//---------------------------------+
Static Function EmiDest()
Local nLinAux:= nLin
Local nColSep:= 1200

//Box
oPrint:Box(nLin,nCol,nLin+240,nCol+2385)
oPrint:Line(nLin,nColSep,nLin+240,nColSep) 

//Cabe�alho do box
nLin += 30
oPrint:Say(nLin,nCol+10,"Emitente",oFont12n,1400)
oPrint:Say(nLin,nColSep+10,"Destinat�rio",oFont12n,1400)

nLinAux:= nLin

//Emitente
nLinAux += 30
oPrint:Say(nLinAux,nCol+10,Upper(SM0->M0_NOMECOM),oFont12,1400)
nLinAux += 30
oPrint:Say(nLinAux,nCol+10,"N�O CONTRIBUINTE DO ICMS",oFont12i,1400)
nLinAux += 30   
oPrint:Say(nLinAux,nCol+10,"CNPJ: "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),oFont12,1400)
nLinAux += 30 
oPrint:Say(nLinAux,nCol+10,Upper(Alltrim(SM0->M0_ENDCOB)+" "+Alltrim(SM0->M0_COMPCOB)),oFont12,1400)
nLinAux += 30 
oPrint:Say(nLinAux,nCol+10,Upper(Alltrim(SM0->M0_BAIRCOB)+" "+Alltrim(SM0->M0_CIDCOB)+" - "+Alltrim(SM0->M0_ESTCOB)),oFont12,1400)
nLinAux += 30 
oPrint:Say(nLinAux,nCol+10,Transform(SM0->M0_TEL,"@R (999)9999-9999")+" "+Iif(!Empty(SM0->M0_FAX),Transform(SM0->M0_FAX,"@R (999)9999-9999"),""),oFont12,1400)

nLinAux:= nLin

//Destinat�rio
nLinAux += 30
oPrint:Say(nLinAux,nColSep+10,Upper(SA1->A1_NOME),oFont12,1400)
nLinAux += 30   
oPrint:Say(nLinAux,nColSep+10,"CNPJ: "+Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")+" I.E.: "+SA1->A1_INSCR,oFont12,1400)
nLinAux += 30 
oPrint:Say(nLinAux,nColSep+10,Upper(Alltrim(SA1->A1_END)+" "+Alltrim(SA1->A1_COMPLEM)),oFont12,1400)
nLinAux += 30 
oPrint:Say(nLinAux,nColSep+10,Upper(Alltrim(SA1->A1_BAIRRO)+" "+Alltrim(SA1->A1_MUN)+" - "+Alltrim(SA1->A1_EST)),oFont12,1400)
nLinAux += 30 
oPrint:Say(nLinAux,nColSep+10,"("+Alltrim(SA1->A1_DDD)+") "+Transform(Right(Alltrim(Strtran(SA1->A1_TEL,"-","")),8),"@R 9999-9999"),oFont12,1400)

nLin:= nLinAux+10

Return



//---------------------------------+
//       IMPRIME CABE�ALHO ITENS   !
//---------------------------------+ 

Static Function CabecItem() 
Local nColAux:= nCol
Local nLinAux:= nLin
Local nTamLinha:= 50

oPrint:Box(nLin,nCol,nLin+50,nCol+2385)
nLin += 30
nColAux+=10
oPrint:Say(nLin,nColAux+10,"Item",oFont12n,1400)
nColAux+=150
oPrint:Say(nLin,nColAux+10,"C�digo",oFont12n,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=300
oPrint:Say(nLin,nColAux+10,"Descri��o",oFont12n,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=600
oPrint:Say(nLin,nColAux+10,"Marca/Fabricante",oFont12n,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=400
oPrint:Say(nLin,nColAux+10,"Quant.",oFont12n,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=150
oPrint:Say(nLin,nColAux+10,"Vlr Unit�rio",oFont12n,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=350
oPrint:Say(nLin,nColAux+10,"Vlr Total",oFont12n,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)

nLin:= nLinAux+nTamLinha

Return


//---------------------------------+
//       IMPRIME OS ITENS   	   !
//---------------------------------+ 

Static Function ImpItem()
Local nColAux:= nCol
Local nLinAux:= nLin
Local nTamLinha:= 50

oPrint:Box(nLin,nCol,nLin+50,nCol+2385)
nLin += 30
nColAux+=10
oPrint:Say(nLin,nColAux+10,SD2->D2_ITEM,oFont12,1400)
nColAux+=150
oPrint:Say(nLin,nColAux+10,SD2->D2_COD,oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=300
//oPrint:Say(nLin,nColAux+10,SB1->B1_DESC,oFont12,1400)
oPrint:Say(nLin,nColAux+10,SB5->B5_CEME,oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=600
oPrint:Say(nLin,nColAux+10,SB1->B1_FABRIC,oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=400
oPrint:Say(nLin,nColAux+10,cvaltochar(SD2->D2_QUANT),oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=150
oPrint:Say(nLin,nColAux+10,Transform(SD2->D2_PRCVEN,PesqPict("SD2","D2_TOTAL")),oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=350
nColtot:= nColAux
oPrint:Say(nLin,nColAux+10,Transform(SD2->D2_TOTAL,PesqPict("SD2","D2_TOTAL")),oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)

nLin:= nLinAux+nTamLinha

Return  

//---------------------------------+
// Imprime o total				   !
//---------------------------------+
Static Function Total()

oPrint:Box(nLin,nColTot,nLin+50,nCol+2380)
nLin += 30

oPrint:Say(nLin,nColTot+10,Transform(nTotal,PesqPict("SD2","D2_TOTAL")),oFont12n,1400)

Return


//---------------------------------+
// Verifica a quebra de pagina	   !
//---------------------------------+
Static Function GetNewPage()

If nLin >= 2965
	oPrint:EndPage()
	nLin := 30
	nPag++
	Cabec()
	CabecItem()
Endif

Return

//  Cria as perguntas na SX1                               
//********************************************************************************

Static Function ValidPerg(cPerg) 

Local aRegs:= {}

aAdd(aRegs,{cPerg, '01', "Documento"		,"Documento"  	,"Documento" 		, 'mv_ch1' , 'C', 09	, 0, 0, 'G', '', 'mv_par01', '','','','','','','','','','','','','','','','','','','','','','','','','SF2VEI','','',''})
aAdd(aRegs,{cPerg, '02', "S�rie"			,"S�rie"  		,"S�rie" 			, 'mv_ch2' , 'C', 03	, 0, 0, 'G', '', 'mv_par02', '','','','','','','','','','','','','','','','','','','','','','','','','','','',''})

U_BuscaPerg(aRegs)

Return






//---------------------------------+
// Bloco Emitente e Destinat�rio   !
//---------------------------------+
Static Function Canhoto()
oPrint:StartPage()  


oPrint:Box(nLin+100,nCol, MAXBOXV+50, 67)
oPrint:Say(MAXBOXV, INIBOXH+50, "RECEBEMOS DE "+ alltrim(Upper(SM0->M0_NOMECOM)) +" OS PRODUTOS CONSTANTES DA DECLARACAO INDICADA AO LADO", oFont12n, , , 270)

oPrint:Box(nLin+2052,nCol+59, MAXBOXV+52, 151)
oPrint:Say(MAXBOXV, INIBOXH+105, "DATA DE RECEBIMENTO", oFont12n, , , 270)

oPrint:Box(nLin+100,nCol+59, MAXBOXV-370, 151)
oPrint:Say(MAXBOXV -500, INIBOXH+105, "IDENTIFICA��O E ASSINATURA DO RECEBEDOR", oFont12n, , , 270)

// Nfe 
oPrint:Box(nLin+30, nCol, nLin+280,  150)
oPrint:Say(MAXBOXV-2190, INIBOXH+60, "NF-e", oFont12n, , , 270)
oPrint:Say(MAXBOXV-2160, INIBOXH+95, "N� "+StrZero(Val(cDoc),9), oFont12n, , , 270)
oPrint:Say(MAXBOXV-2160, INIBOXH+130, "S�RIE "+cSerie, oFont12n, , , 270)

oPrint:Say(MAXBOXV, INIBOXH+182, Replicate("- ",100), oFont12n, , , 270)

nCol := 186
Return


Static Function MensAdic()

oPrint:Box(nLin,nCol,MAXBOXV+50,nCol+2385)
oPrint:Say(nLin +10,nCol+10,"Informa��es Complementares: ",oFont12n,1400)

/*
oPrint:Box(nLin+2052,nCol+59, MAXBOXV+52, 151)
oPrint:Say(MAXBOXV, INIBOXH+105, "DATA DE RECEBIMENTO", oFont12n, , , 270)

oPrint:Box(nLin+100,nCol+59, MAXBOXV-370, 151)
oPrint:Say(MAXBOXV -500, INIBOXH+105, "IDENTIFICA��O E ASSINATURA DO RECEBEDOR", oFont12n, , , 270)

// Nfe 
oPrint:Box(nLin+30, nCol, nLin+280,  150)
oPrint:Say(MAXBOXV-2190, INIBOXH+60, "NF-e", oFont12n, , , 270)
oPrint:Say(MAXBOXV-2160, INIBOXH+95, "N� "+StrZero(Val(cDoc),9), oFont12n, , , 270)
oPrint:Say(MAXBOXV-2160, INIBOXH+130, "S�RIE "+cSerie, oFont12n, , , 270)
*/

Return
