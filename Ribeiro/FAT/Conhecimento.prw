#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#INCLUDE "TOTVS.CH"
user function ImpConhec()

Local cBitMap := "\system\imagens\LGRL0101.BMP" ///Logotipo da empresa
Local nCont := 0
nMargem:= 2400
// retorna XML
cRet := DecodeUTF8( U_RSpedExp(2)) // CCe
// Razao Social
iw1 := AT("<xNome>" , cRet )
iw2 := AT("</xNome>" , cRet )
cRazSoc := Capital( RTRIM(SM0->M0_NOMECOM))

cEnder   := RTRIM(SM0->M0_ENDENT) + " - " + RTRIM(SM0->M0_BAIRENT) + " - " + RTRIM(SM0->M0_CIDENT) 

// FOne
cFone := RTRIM(SM0->M0_TEL)
cFone :=  "Fone: " + TRANSF(cFone,"@R (99)9999-9999")

 // CNPJ
cCNPJ :=   TRANSF(SM0->M0_CGC,"@R 99.999.999/9999-99")

cIE := SM0->M0_INSC

 

// chaveNFe
iw1 := AT("<chNFe>" , cRet )
iw2 := AT("</chNFe>" , cRet )
cChaveNfe := Subs(cRet, iw1 +7, iw2 - (iw1 + 7))


//Seleciona os registros
//********************************************************************************
If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif
If Select("QR1")>0         
	QR1->(dbCloseArea())
Endif

cQry := " Select F2_SERIE, F2_DOC, A1_NOME, A1_CGC, A1_INSCR, F2_TIPO from "+ RetSqlName("SF2") + " SF2"
cQry += " inner join "+ RetSqlName("SA1") + " SA1 on  F2_CLIENTE = A1_COD and F2_LOJA = A1_LOJA"
cQry += " Where F2_CHVNFE ='" + cChaveNfe +"' and SF2.D_E_L_E_T_ =' ' and SA1.D_E_L_E_T_ =' '"

TcQuery cQry New Alias "QRY"   

// tratatar devolucao
IF (QRY->F2_TIPO ='D')
    cQry := " Select F2_SERIE, F2_DOC, A2_NOME, A1_CGC, A2_INSCR, F2_TIPO from "+ RetSqlName("SF2") + " SF2"
    cQry += " inner join "+ RetSqlName("SA2") + " SA2 on  F2_CLIENTE = A2_COD and F2_LOJA = A2_LOJA"
    cQry += " Where F2_CHVNFE ='" + cChaveNfe +"' and SF2.D_E_L_E_T_ =' ' and SA2.D_E_L_E_T_ =' '"

    TcQuery cQry New Alias "QR1" 

    cIECLi := QR1->A1_INSCR
    cNomeCli := QR1->A1_NOME
    cCNPJCli:= TRANSF(QR1->A1_CGC,"@R 99.999.999/9999-99") 

Else
    cIECLi := QRY->A2_INSCR
    cNomeCli := QRY->A2_NOME
    cCNPJCli:= TRANSF(QRY->A2_CGC,"@R 99.999.999/9999-99") 
endif
  
    cSerie := QRY->F2_SERIE
    cNFe := QRY->F2_DOC




// DtEmissao
iw1 := AT("<dhEvento>" , cRet )
iw2 := AT("</dhEvento>" , cRet )
cEmissao := Subs(cRet, iw1 +10, iw2 - (iw1 + 25))
cEmissao := Subs(cEmissao,9,2) + "/" + Subs(cEmissao,6,2) + "/" + Subs(cEmissao,1,4)
cHora := Subs(cRet, iw1 + 21, iw2 - (iw1 + 27))

// nProt
iw1 := AT("<nProt>" , cRet )
iw2 := AT("</nProt>" , cRet )
cProt := Subs(cRet, iw1 +7, iw2 - (iw1 + 7))

// xCorrecao
iw1 := AT("<xCorrecao>" , cRet )
iw2 := AT("</xCorrecao>" , cRet )
cCorrecao := Subs(cRet, iw1 +11, iw2 - (iw1 + 11))

// xCondUso
iw1 := AT("<xCondUso>" , cRet )
iw2 := AT("</xCondUso>" , cRet )
cCondUso := Subs(cRet, iw1 +10, iw2 - (iw1 + 10))


//xCorrecao
//Tï¿½tulo do relatï¿½rio no cabeï¿½alho
cTitle := OemToAnsi("Carta Correção")

//Criacao do componente de impressï¿½o
//oPrint := tReport():New("Carta Correção",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cTitle)

oPrint := TMSPrinter():New("Impressão da Carta de Correção Eletronica - CC-e")

// Cria os objetos com as configuracoes das fontes
//                                              Negrito  Subl  Italico
oFont08  := TFont():New( "Arial",,08,,.f.,,,,,.f.,.f. )
oFont08b := TFont():New( "Arial",,08,,.t.,,,,,.f.,.f. )
oFont09  := TFont():New( "Arial",,09,,.f.,,,,,.f.,.f. )
oFont10  := TFont():New( "Arial",,10,,.f.,,,,,.f.,.f. )
oFont10b := TFont():New( "Arial",,10,,.t.,,,,,.f.,.f. )
oFont10b := TFont():New( "Arial",,10,,.t.,,,,,.f.,.f. )
oFont11  := TFont():New( "Arial",,11,,.f.,,,,,.f.,.f. )
oFont11b := TFont():New( "Arial",,11,,.t.,,,,,.f.,.f. )
oFont12  := TFont():New( "Arial",,12,,.f.,,,,,.f.,.f. )
oFont12b := TFont():New( "Arial",,12,,.t.,,,,,.f.,.f. )
oFont13b := TFont():New( "Arial",,13,,.t.,,,,,.f.,.f. )
oFont13  := TFont():New( "Arial",,13,,.f.,,,,,.f.,.f. )
oFont14  := TFont():New( "Arial",,14,,.f.,,,,,.f.,.f. )
oFont14b := TFont():New( "Arial",,14,,.t.,,,,,.f.,.f. )
oFont20b := TFont():New( "Arial",,20,,.t.,,,,,.f.,.f. )
oFont24b := TFont():New( "Arial",,24,,.t.,,,,,.f.,.f. )

// Mostra a tela de Setup
//oPrint:Setup() ///???????????????

oPrint:SetPortrait()
oPrint:SetPaperSize(9)       ///(DMPAPER_A4)
   
// Inicia uma nova pagina
oPrint:StartPage()
oPrint:SetFont(oFont24b)
nLin :=100
oPrint:SayBitMap(nLin,116,cBitMap,300,300)
nLin += 20
oPrint:Say(nLin,600, Capital( cRazSoc),oFont13b ,140)
nLin += 50
cEnder := Capital( cEnder) + " / " + SM0->M0_ESTENT
oPrint:Say(nLin,600, cEnder,oFont12 ,140)
nLin += 50
oPrint:Say(nLin,600, cFone ,oFont12 ,140)
nLin += 50
oPrint:Say(nLin,600, cCnpj ,oFont12 ,140)
nLin += 50
oPrint:Say(nLin,600,"I.Estadual: "+cIE,oFont13 ,140)


oPrint:Box(100,1770,390,nMargem)
oPrint:Line(150,1770,150,nMargem)

oPrint:Say(200,1800,"Série: "+ cSerie,oFont12 ,100)
oPrint:Say(270,1800,"N.Fiscal: "+ cNFe,oFont12 ,100)
oPrint:Say(340,1800,"Dt.Emissão: "+ cEmissao,oFont12 ,100)

oPrint:Box(420,100,2500,nMargem)

nLin += 170
oPrint:Say(nLin,450, Space(6) + 'Carta de Correção Eletrônica - CC-e', oFont20b ,140)
nLin += 200
oPrint:Say(nLin,110,'Chave de Acesso da NF-e',oFont10b ,140)

nLin += 50
oPrint:Say(nLin,110 , cChaveNfe , oFont11 ,140)
nLin += 50
oPrint:Say(nLin,110,'Protocolo de Autorização de Uso da Nfe',oFont10b ,140)
nLin += 50
oPrint:Say(nLin,110 , cProt , oFont11 ,140)

cPicChave := TRANSF(cChaveNfe,"@R 9999.9999.9999.9999.9999.9999.9999.9999.9999.9999")
oPrint:Say(nLin,1200 , cPicChave , oFont09 ,140)

nLin += 100
oPrint:Line(nLin,100,nLin,nMargem)

nLin += 80
oPrint:Say(nLin,110,"Dados do destinatário",oFont12b ,200)
nLin += 80

oPrint:Say(nLin,110,"Razão Social / Nome ",oFont10b ,200)
oPrint:Say(nLin,1100,"CNPJ/CPF",oFont10b ,200)
oPrint:Say(nLin,1550,"Inscrição Estadual",oFont10b ,200)
nLin += 50
oPrint:Say(nLin,110,cNomeCli , oFont11 ,200)
oPrint:Say(nLin,1100,cCNPJCli,oFont11 ,200)
oPrint:Say(nLin,1550, cIECLi ,oFont11 ,200)

nLin += 100
oPrint:Say(nLin,110,"Data da CC-e ",oFont10b ,200)
oPrint:Say(nLin,500,"Horário",oFont10b ,200)
oPrint:Say(nLin,750,"Tipo Evento",oFont10b ,200)
oPrint:Say(nLin,1100,"Estado",oFont10b ,200)
oPrint:Say(nLin,1800,"Protocolo",oFont10b ,200)
nLin += 50
oPrint:Say(nLin,110,cEmissao ,oFont11 ,200)
oPrint:Say(nLin,500, cHora,oFont11 ,200)
oPrint:Say(nLin,750,"110110",oFont11 ,200)
oPrint:Say(nLin,1100,"Evento registrado e vinculado a NF-e",oFont11 ,200)
oPrint:Say(nLin,1800,cProt,oFont11 ,200)
nLin += 50
oPrint:Line(nLin,100,nLin,nMargem)

nLin += 50
oPrint:Say(nLin,110,"Correções a serem considerada",oFont11b ,200)
nLin += 100

nCont := 1
nLimCor := 120 // limite de caracteres para impressão do conteudo da tag xCorrecao
If ! Empty(cCorrecao)
    While nCont < Len(cCorrecao)
        cAtual :=SubStr(cCorrecao, nCont, nLimCor )
        nUlt:= Rat( " ", cAtual)
        if nUlt == 0 // não encontrou o espaço em branco
            nCar := Len(cAtual)
        Else
            nCar := nUlt
        Endif
        oPrint:Say(nLin,110, SubStr(cCorrecao, nCont, nCar ),oFont11 ,200)
        nLin += 50
        nCont += nCar        
    Enddo
Endif


nLin := 2600

oPrint:Say(nLin,110,"Condições de uso da carta de correção",oFont11b ,200)
nLin += 50
cTxt1:=  "A Carta de Correção é disciplinada pelo § 1º-A do art. 7º do Convênio S/N, de 15 de dezembro de 1970 e pode ser utilizada" 
cTxt2 := "para regularização de erro ocorrido na emissão de documento fiscal, desde que o erro não esteja relacionado com:"
cTxt3 := "I - as variáveis que determinam o valor do imposto tais como: base de cálculo, alíquota, diferença de preço, quantidade,"
cTxt4 := "valor da operação ou da prestação;"
cTxt5 := "II - a correção de dados cadastrais que implique mudança do remetente ou do destinatário;"
cTxt6 := "III - a data de emissão ou de saída."
oPrint:Say(nLin,110,cTxt1,oFont11 ,200)
nLin += 50
oPrint:Say(nLin,110,cTxt2,oFont11 ,200)
nLin += 50
oPrint:Say(nLin,110,cTxt3,oFont11 ,200)
nLin += 50
oPrint:Say(nLin,110,cTxt4,oFont11 ,200)
nLin += 50
oPrint:Say(nLin,110,cTxt5,oFont11 ,200)
nLin += 50
oPrint:Say(nLin,110,cTxt6,oFont11 ,200)
nLin += 50

MSBAR('CODE128',5.4 , 9.5 ,alltrim(cChaveNfe),oPrint,.F.,,.T.,0.020, 0.8,,,,.F.)

nLin += 100
oPrint:EndPage()

oPrint:Preview()

Return
