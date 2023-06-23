#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#DEFINE MAXBOXV   2450
#DEFINE INIBOXH   -10
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦  BRREL01	   ¦ Autor ¦ Luciane             ¦ Data ¦02.10.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Relatório de Transporte de Bens Ativo Imobilizado		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BRREL01()

Local aPergs := {}
Local cPerg := PadR("BRREL01",10)

ValidPerg(cPerg)

If !Pergunte (PadR(cPerg,10),.T.)
	Return .F.
EndIf

Processa({|| MontaRel() }, "Montando Relatório...")

Return

Static Function MontaRel()
Private	cLocal		:= GetTempPath()
Private nLin 		:= 10 	//Controlador da posição das linhas Verticais
Private nCol 		:= 10   //Controlador da posição das linhas horizontais 
Private nPag		:= 1  
Private nColTot		:= 0
Private nTotal		:= 0
Private cDoc        := MV_PAR01
Private cSerie      := MV_PAR02
Private lAdjustToLegacy := .t.
Private lDisableSetup 	:= .F.
private nLimite    :=2900

//Fontes do Relatório Gráfico
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
	MsgStop("Documento "+Alltrim(cDoc)+"/"+Alltrim(cSerie)+" não encontrado!")
	Return
Endif
SD2->(dbSetOrder(3))	
SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))
//Posiciona no cliente
SA1->(dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))

IncProc("Gerando relatório para o documento "+Alltrim(cDoc)+"/"+Alltrim(cSerie))

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

//Bloco natureza da operação
nLin += 60
oPrint:Box(nLin,nCol,nLin+50,nCol+nLimite)
nLin += 25
oPrint:Say(nLin,nCol+10,"Natureza da operação realizada: "+Upper(Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_FINALID")),oFont12n,1400)
nLin += 30

Fatura()
nLin += 60

Transporte()
nLin += 10
Volume()
nLin += 20

CabecItem()  

While SD2->(!Eof()) .and. SD2->D2_FILIAL = xFilial("SD2") .and. SD2->D2_DOC = SF2->F2_DOC .and. SD2->D2_SERIE = SF2->F2_SERIE
	//Posiciona no produto
	SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))
	
	// tiago Santos
	SB5->(dbSeek(xFilial("SB5")+SD2->D2_COD))
	nTotal+= SD2->D2_TOTAL

	//Verifica a quebra de página
	GetNewPage()

	//Imprime o item	
	ImpItem()
	SD2->(dbSkip())

End

Total()

nLin+=60
GetNewPage()

oPrint:Say(nLin,nCol+10,"DECLARO SOB AS PENAS DA LEI, QUE OS BENS DESCRITOS ACIMA NÃO CONSTITUEM OBJETO DE MERCADORIA OU PRESTAÇÃO QUE CONFIGURE HIPOTESE",oFont12i,1400)
nLin+=30
oPrint:Say(nLin,nCol+10,"DE INCIDÊNCIA DO ICMS.",oFont12i,1400)

nLin+=60
GetNewPage()

oPrint:Say(nLin,nCol+10,Capital(Alltrim(SM0->M0_CIDCOB))+", "+Strzero(Day(date()),2)+" de "+lower(mesExtenso(date()))+" de "+cvaltochar(Year(date()))+".",oFont12,1400)

nLin+=60
GetNewPage()

oPrint:Say(nLin,nCol+10,"Precedente Consulta nº 129 de 20-5-1999. E Precedente Consulta nº 056, de 29-3-1990.",oFont12,1400)

nLin+=60
GetNewPage()

oPrint:Say(nLin,nCol+10,"http://www.atendimento.fazenda.pr.gov.br/sacsefa/portal/index",oFont12s,1400)

nLin+=60
GetNewPage()
oPrint:Say(nLin,nCol+10,"Observações:",oFont12,1400)

nLin+=30
GetNewPage()
oPrint:Say(nLin,nCol+10,"° Destinatários contribuintes do ICMS devem emitir nota fiscal de entrada quando do recebimento.",oFont12,1400)

nLin+=30
GetNewPage()
oPrint:Say(nLin,nCol+10,"° A fiscalização poderá solicitar a apresentação de documento que comprove a propriedade do bem transportado e a natureza da operação declarada.",oFont12,1400)


nLin+=30
GetNewPage()
oPrint:Say(nLin,nCol+10,"  Assim, é recomendável que, além da presente Declaração, o transporte seja acompanhado de:",oFont12,1400)

nLin+=30
GetNewPage()
oPrint:Say(nLin,nCol+10,"       ° Contrato social, quando os bens pertencerem a pessoa jurídica.",oFont12,1400)

nLin+=30
GetNewPage()
oPrint:Say(nLin,nCol+10,"       ° Cópia do Contrato de locação, quando se tratar de movimentação de bem destinado a aluguel.",oFont12,1400)

nLin+=30
GetNewPage()
oPrint:Say(nLin,nCol+10,"       ° Documentação fiscal da operação que deu origem à devolução, no caso de devolução.",oFont12,1400)

nLin+=30
GetNewPage()
oPrint:Say(nLin,nCol+10,"       ° Documento fiscal de origem do bem, emitida pelo fornecedor, ou documentação que comprove sua propriedade.",oFont12,1400)

nLin+=30
GetNewPage()
oPrint:Say(nLin,nCol+10,"°  A presente declaração não impede a verificação da carga, bem como o lançamento relativo à eventual infração tributária pela ",oFont12,1400)
nLin+=30
oPrint:Say(nLin,nCol+10,"  Fiscalização, nos termos da legislação vigente.",oFont12,1400)

nLin+=50
MensAdic()
AssiNBox()
oPrint:EndPage() //Fecha a página

oPrint:lViewPDF := .F.
oPrint:Print()

AssinatDig(oPrint:cPathPDF + alltrim(cDoc) + alltrim(cSerie)+".pdf")
Return


//---------------------------------+
//       IMPRIME CABEÇALHO         !
//---------------------------------+
Static Function Cabec()
Local _cLogo    := "\system\lgrl"+cEmpAnt+".bmp"
 
//oPrint:StartPage()  

nLin += 30
oPrint:Line(nLin,nCol,nLin,nCol+nLimite)
nLin += 05
oPrint:SayBitMap(nLin,nCol+5,_cLogo,320,180)
oPrint:Say(nLin+20,nCol+2680,"Pág:"+strzero(nPag,3),oFont6,1400)
nLin+=50
// oPrint:Say(nLin,nCol+830,"DECLARAÇÃO DE ALIENAÇÃO",oFont16n,1400)
oPrint:Say(nLin,nCol+930,"DECLARAÇÃO DE TRANSPORTE",oFont16n,1400)
nLin += 50
//oPrint:Say(nLin,nCol+630,"TRANSPORTE DE BENS DO ATIVO IMOBILIZADO",oFont16n,1400)
oPrint:Say(nLin,nCol+1000,"E OUTROS FINS",oFont16n,1400)
nLin += 30
oPrint:Say(nLin+30,nCol+1050,"Nº."+SF2->F2_DOC+"/"+SF2->F2_SERIE,oFont16n,1400)

oPrint:Say(nLin,nCol+2540,"Emissão:"+CVALTOCHAR(Date()),oFont6,1400)
nLin += 30
oPrint:Say(nLin,nCol+2605,"Hora:"+CVALTOCHAR(Time()),oFont6,1400)
nLin += 30 
oPrint:Line(nLin,nCol,nLin,nCol+2380)  

Return

//---------------------------------+
// Bloco Emitente e Destinatário   !
//---------------------------------+
Static Function EmiDest()
Local nLinAux:= nLin
Local nColSep:= 1200

//Box
oPrint:Box(nLin,nCol,nLin+240,nCol+nLimite)
oPrint:Line(nLin,nColSep,nLin+240,nColSep) 

//Cabeçalho do box
nLin += 30
oPrint:Say(nLin,nCol+10,"Emitente",oFont12n,1400)
oPrint:Say(nLin,nColSep+10,"Destinatário",oFont12n,1400)

nLinAux:= nLin

//Emitente
nLinAux += 30
oPrint:Say(nLinAux,nCol+10,Upper(SM0->M0_NOMECOM),oFont12,1400)
nLinAux += 30
oPrint:Say(nLinAux,nCol+10,"NÃO CONTRIBUINTE DO ICMS",oFont12i,1400)
nLinAux += 30   
oPrint:Say(nLinAux,nCol+10,"CNPJ: "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),oFont12,1400)
nLinAux += 30 
oPrint:Say(nLinAux,nCol+10,Upper(Alltrim(SM0->M0_ENDCOB)+" "+Alltrim(SM0->M0_COMPCOB)),oFont12,1400)
nLinAux += 30 
oPrint:Say(nLinAux,nCol+10,Upper(Alltrim(SM0->M0_BAIRCOB)+" "+Alltrim(SM0->M0_CIDCOB)+" - "+Alltrim(SM0->M0_ESTCOB)),oFont12,1400)
nLinAux += 30 
oPrint:Say(nLinAux,nCol+10,Transform(SM0->M0_TEL,"@R (999)9999-9999")+" "+Iif(!Empty(SM0->M0_FAX),Transform(SM0->M0_FAX,"@R (999)9999-9999"),""),oFont12,1400)

nLinAux:= nLin

//Destinatário
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
//       IMPRIME CABEÇALHO ITENS   !
//---------------------------------+ 

Static Function CabecItem() 
Local nColAux:= nCol
Local nLinAux:= nLin
Local nTamLinha:= 50

oPrint:Box(nLin,nCol,nLin+50,nCol+nLimite)
nLin += 30
nColAux+=10
oPrint:Say(nLin,nColAux+10,"Item",oFont12n,1400)
nColAux+=100
oPrint:Say(nLin,nColAux+10,"Código",oFont12n,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=300
oPrint:Say(nLin,nColAux+10,"Descrição",oFont12n,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=1300
oPrint:Say(nLin,nColAux+10,"Marca/Fabricante",oFont12n,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=400
oPrint:Say(nLin,nColAux+10,"Quant.",oFont12n,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=130
oPrint:Say(nLin,nColAux+10,"Vlr Unitário",oFont12n,1400)
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

oPrint:Box(nLin,nCol,nLin+50,nCol+nLimite)
nLin += 30
nColAux+=10
oPrint:Say(nLin,nColAux+10,SD2->D2_ITEM,oFont12,1400)
nColAux+=100
oPrint:Say(nLin,nColAux+10,SD2->D2_COD,oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=300
//oPrint:Say(nLin,nColAux+10,SB1->B1_DESC,oFont12,1400)
cProd := Alltrim(iif ( Empty(SB5->B5_CEME), SB1->B1_DESC,SB5->B5_CEME ))
oPrint:Say(nLin,nColAux+10,cProd,oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=1300
oPrint:Say(nLin,nColAux+10,SB1->B1_FABRIC,oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=400
oPrint:Say(nLin,nColAux+10,cvaltochar(SD2->D2_QUANT),oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=130
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

//oPrint:Box(nLin,nColTot,nLin+50,nCol+2380)
oPrint:Box(nLin,nColTot,nLin+50,nCol+nLimite)
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
aAdd(aRegs,{cPerg, '02', "Série"			,"Série"  		,"Série" 			, 'mv_ch2' , 'C', 03	, 0, 0, 'G', '', 'mv_par02', '','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
aAdd(aRegs,{cPerg, '02', "Arquivo PFX*"		,"Série"  		,"Série" 			, 'mv_ch3' , 'C', 80	, 0, 0, 'G', '', 'mv_par03', '','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
aAdd(aRegs,{cPerg, '02', "Senha"			,"Senha"  		,"Senha" 			, 'mv_ch4' , 'C', 30	, 0, 0, 'G', '', 'mv_par04', '','','','','','','','','','','','','','','','','','','','','','','','','','','',''})

U_BuscaPerg(aRegs)

Return






//---------------------------------+
// Bloco Emitente e Destinatário   !
//---------------------------------+
Static Function Canhoto()
oPrint:StartPage()  


oPrint:Box(nLin+100,nCol, MAXBOXV+50, 67)
oPrint:Say(MAXBOXV, INIBOXH+50, "RECEBEMOS DE "+ alltrim(Upper(SM0->M0_NOMECOM)) +" OS PRODUTOS CONSTANTES DA DECLARACAO INDICADA AO LADO", oFont12n, , , 270)

oPrint:Box(nLin+2052,nCol+59, MAXBOXV+52, 151)
oPrint:Say(MAXBOXV, INIBOXH+105, "DATA DE RECEBIMENTO", oFont12n, , , 270)

oPrint:Box(nLin+100,nCol+59, MAXBOXV-370, 151)
oPrint:Say(MAXBOXV -500, INIBOXH+105, "IDENTIFICAÇÃO E ASSINATURA DO RECEBEDOR", oFont12n, , , 270)

// Nfe 
oPrint:Box(nLin+30, nCol, nLin+280,  150)
oPrint:Say(MAXBOXV-2190, INIBOXH+60, "NF-e", oFont12n, , , 270)
oPrint:Say(MAXBOXV-2160, INIBOXH+95, "Nº "+StrZero(Val(cDoc),9), oFont12n, , , 270)
oPrint:Say(MAXBOXV-2160, INIBOXH+130, "SÉRIE "+cSerie, oFont12n, , , 270)

oPrint:Say(MAXBOXV, INIBOXH+182, Replicate("- ",66), oFont12n, , , 270)

nCol := 186
Return

Static Function MensAdic()
Local lFimTexto := .F.
Local nTamanho  := 250
Local nCont  := 1
Local cTextoSF2 := Alltrim(SF2->F2_MENNOTA)
Local nLinha :=100
oPrint:Box(nLin,nCol,MAXBOXV+50,nCol+1300)
oPrint:Say(nLin +30,nCol+10,"Informações Complementares: ",oFont12n,1400)

While ! lFimTexto
	cTexto := SUBSTR( cTextoSF2, nCont, 75) // 75 é o limite caracteres por linha
	if !Empty(cTexto)
		oPrint:Say(nLin +nLinha,nCol+10, cTexto ,oFont12,1400)
		nCont  += 75
		nLinha += 50
	else
		lFimTexto :=.T.
	Endif

Enddo

Return

Static Function Fatura()
Local nColAux:= nCol
Local nLinAux:= nLin
Local nTamLinha:= 50
Local nCont
oPrint:Box(nLin,nCol,nLin+100,nCol+nLimite)
oPrint:Say(nLin +30,nCol+10,"Fatura    ",oFont12n,1400)
nLin += 30

nColAux+=150
nColTit := (nLimite-nColAux)/8
cQuery := " select E1_VENCREA, E1_VALOR from "+ RetSqlName("SE1")+ " SE1"
cQuery += " Where D_E_L_E_T_ =' ' and E1_NUM ='"+cDoc+"' and E1_PREFIXO ='"+cSerie+"'"
cQuery += " and E1_CLIENTE = '"+SF2->F2_CLIENTE+"' and E1_LOJA ='"+SF2->F2_LOJA+"' and E1_FILIAL ='"+xFilial("SE1")+"'"
cQuery += " Order by 1"

If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif
TcQuery cQuery New Alias "QRY"    
for nCont :=1 to 8 // limite maximo de titulos NFe
	If QRY->(!EOF())
		While QRY->(!EOF())
			cData := SUBSTR( QRY->E1_VENCREA, 7, 2)+'/'+SUBSTR( QRY->E1_VENCREA, 5, 2)+'/'+SUBSTR( QRY->E1_VENCREA, 1, 4)
			oPrint:Say(nLin,nColAux+10,cData,oFont12,1400)	
			cValor:= Alltrim(transform(QRY->E1_VALOR," @E 999,999,999.99"))
			oPrint:Say(nLin+50,nColAux+10,cValor,oFont12,1400)	
			QRY->(DbSkip())
		Enddo
	Endif
	oPrint:Line(nLinAux,nColAux,nLinAux+100,nColAux)
	nColAux+=nColTit
Next nCont
nLin:= nLinAux+nTamLinha
Return


static Function Transporte()

Local nColAux:= nCol
Local nLinAux:= nLin
Local nTamLinha:= 100
Local cNome :=""
Local cCGC :=""
Local cEndereco :=""
Local cMunicipio :=""
Local cTpFrete :=""
if select("SA4")==0
	DBSELECTAREA( "SA4" )
Endif
Sa4->(DBGOTOP(  ))
oPrint:Box(nLin,nCol,nLin+nTamLinha,nCol+nLimite)
nLin += 30
nColAux+=10
oPrint:Say(nLin,nColAux,"Transporte",oFont12n,1400)
nColAux+=250

// dados transportadora
if !Empty(SF2->F2_TRANSP)
	cNome := Alltrim(Posicione("SA4",1, xFilial("SA4") + SF2->F2_TRANSP ,"A4_NOME"))
	cCGC := Alltrim(Posicione("SA4",1, xFilial("SA4") + SF2->F2_TRANSP ,"A4_CGC"))
	cEndereco := Alltrim(Posicione("SA4",1, xFilial("SA4") + SF2->F2_TRANSP ,"A4_END"))
	cMunicipio := Alltrim(Posicione("SA4",1, xFilial("SA4") + SF2->F2_TRANSP ,"A4_MUN"))
Endif

oPrint:Say(nLin,nColAux+10,"Razão Social",oFont12n,1400)
oPrint:Say(nLin+40,nColAux+10,cNome,oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=900

oPrint:Say(nLin,nColAux+10,"CNPJ",oFont12n,1400)
oPrint:Say(nLin+40,nColAux+10,cCGC,oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)

nColAux+=400
oPrint:Say(nLin,nColAux+10,"Endereço",oFont12n,1400)
oPrint:Say(nLin+40,nColAux+10,cEndereco,oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)

nColAux+=750
oPrint:Say(nLin,nColAux+10,"Município",oFont12n,1400)
oPrint:Say(nLin+40,nColAux+10,cMunicipio,oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)

nColAux+=500

//oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
//nColAux+=400

nLin:= nLinAux+nTamLinha

Return



static Function Volume()

Local nColAux:= nCol
Local nLinAux:= nLin
Local nTamLinha:= 100
Local cNome :=""
Local cCGC :=""
Local cEndereco :=""
Local cMunicipio :=""
Local cTpFrete :=""
if select("SA4")==0
	DBSELECTAREA( "SA4" )
Endif
Sa4->(DBGOTOP(  ))
oPrint:Box(nLin,nCol,nLin+nTamLinha,nCol+nLimite)
nLin += 30
nColAux+=10
oPrint:Say(nLin,nColAux,"",oFont12n,1400)
nColAux+=250

oPrint:Say(nLin,nColAux+10,"Frete por Conta",oFont12n,1400)

do case 
	case SF2->F2_TPFRETE =='C'
		cTpFrete :="CIF"
	case SF2->F2_TPFRETE =='F'
		cTpFrete :="FOB"
	case SF2->F2_TPFRETE =='T'
		cTpFrete :="Terceiros"
	case SF2->F2_TPFRETE =='R'
		cTpFrete :="Remetente"
	case SF2->F2_TPFRETE =='D'
		cTpFrete :="Destinatario"
	OTHERWISE
		cTpFrete :="Sem Frete"
Endcase
oPrint:Say(nLin+40,nColAux+10,cTpFrete,oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=300

oPrint:Say(nLin,nColAux+10,"Quantidade",oFont12n,1400)
oPrint:Say(nLin+40,nColAux+10,transform(SF2->F2_VOLUME1," @E 999,999,999.99"),oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)
nColAux+=300
oPrint:Say(nLin,nColAux+10,"Especie",oFont12n,1400)
oPrint:Say(nLin+40,nColAux+10,Alltrim(SF2->F2_ESPECI1),oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)

nColAux+=400

oPrint:Say(nLin,nColAux+10,"Valor Frete",oFont12n,1400)
oPrint:Say(nLin+40,nColAux+10,transform(SF2->F2_FRETE," @E 999,999,999.99"),oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)

nColAux+=450
oPrint:Say(nLin,nColAux+10,"Peso Bruto",oFont12n,1400)
oPrint:Say(nLin+40,nColAux+10,transform(SF2->F2_PBRUTO," @E 999,999,999.99"),oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)

nColAux+=500
oPrint:Say(nLin,nColAux+10,"Peso Liquido",oFont12n,1400)
oPrint:Say(nLin+40,nColAux+10,transform(SF2->F2_PLIQUI," @E 999,999,999.99"),oFont12,1400)
oPrint:Line(nLinAux,nColAux,nLinAux+nTamLinha,nColAux)


nLin:= nLinAux+nTamLinha

Return

static function AssinatDig(cArquivo)
//oPrint:Box(2052,nCol+1500, MAXBOXV+52, nLimite)
MSGRun("Assinando arquivo PDF de Nota de Débito","Processando...", {|| ;
	u_Sign(cArquivo, alltrim(MV_PAR03) ,alltrim(MV_PAR04) ) })
Return 


Static Function AssiNBox()
oPrint:Box(nLin,nCol+1600,MAXBOXV+50,nCol+nLimite)
oPrint:Say(nLin +30,nCol+1650,"Assinatura Digital: ",oFont12n,1400)
Return
