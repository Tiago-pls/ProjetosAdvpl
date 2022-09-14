#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#INCLUDE "TOTVS.CH"
user function TRImpCon()

Local cBitMap := "\system\imagens\LGRL0101.BMP" ///Logotipo da empresa
nMargem:= 2200
// retorna XML
cRet := U_RSpedExp()
// Razao Social
iw1 := AT("<xNome>" , cRet )
iw2 := AT("</xNome>" , cRet )
cRazSoc := Subs(cRet, iw1 +7, iw2 - (iw1 + 7))

// --------  Endereço
iw1 := AT("<xLgr>" , cRet )
iw2 := AT("</xLgr>" , cRet )
cEnder := Subs(cRet, iw1 +6, iw2 - (iw1 + 6))

iw1 := AT("<xBairro>" , cRet )
iw2 := AT("</xBairro>" , cRet )
cEnder += ' | ' + Subs(cRet, iw1 +9, iw2 - (iw1 + 9))

iw1 := AT("<xMun>" , cRet )
iw2 := AT("</xMun>" , cRet )
cEnder += ' | ' + Subs(cRet, iw1 +6, iw2 - (iw1 + 6))

iw1 := AT("<UF>" , cRet )
iw2 := AT("</UF>" , cRet )
cEnder += ' | ' + Subs(cRet, iw1 +4, iw2 - (iw1 + 4))

// FOne
iw1 := AT("<fone>" , cRet )
iw2 := AT("</fone>" , cRet )
cFone := Subs(cRet, iw1 +6, iw2 - (iw1 + 6))
cFone :=  "Fone: " + TRANSF(cFone,"@R (99)9999-9999")

 // CNPJ
iw1 := AT("<CNPJ>" , cRet )
iw2 := AT("</CNPJ>" , cRet )
cCNPJ := Subs(cRet, iw1 +6, iw2 - (iw1 + 6))
cCNPJ :=  "C.N.P.J.: " + TRANSF(cCNPJ,"@R 99.999.999/9999-99")

 // IE
iw1 := AT("<IE>" , cRet )
iw2 := AT("</IE>" , cRet )
cIE := "I.Estadual: " + Subs(cRet, iw1 + 4, iw2 - (iw1 + 4))

// Serie
iw1 := AT("<serie>" , cRet )
iw2 := AT("</serie>" , cRet )
cSerie := Subs(cRet, iw1 +7, iw2 - (iw1 + 7))


// Nfe
iw1 := AT("<nNF>" , cRet )
iw2 := AT("</nNF>" , cRet )
cNfe := Subs(cRet, iw1 +5, iw2 - (iw1 + 5))

// chaveNFe
iw1 := AT("<chNFe>" , cRet )
iw2 := AT("</chNFe>" , cRet )
cChaveNfe := Subs(cRet, iw1 +7, iw2 - (iw1 + 7))


// DtEmissao
iw1 := AT("<dhRecbto>" , cRet )
iw2 := AT("</dhRecbto>" , cRet )
cEmissao := Subs(cRet, iw1 +10, iw2 - (iw1 + 25))
cEmissao := Subs(cEmissao,9,2) + "/" + Subs(cEmissao,6,2) + "/" + Subs(cEmissao,1,4)
cHora := Subs(cRet, iw1 +21, iw2 - (iw1 + 27))


// nProt
iw1 := AT("<nProt>" , cRet )
iw2 := AT("</nProt>" , cRet )
cProt := Subs(cRet, iw1 +7, iw2 - (iw1 + 7))

//Tï¿½tulo do relatï¿½rio no cabeï¿½alho
cTitle := OemToAnsi("Carta Correção")

//Criacao do componente de impressï¿½o
//oPrint := tReport():New("Carta Correção",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cTitle)

oPrint := FwMsPrinter():New("Impressão da Carta de Correção Eletronica - CC-e")

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
oPrint:Say(nLin,700,cRazSoc,oFont14b ,140)
nLin += 50
oPrint:Say(nLin,700,cEnder,oFont13 ,140)
nLin += 50
oPrint:Say(nLin,700,cFone,oFont13 ,140)
nLin += 50
oPrint:Say(nLin,700,cCnpj,oFont13 ,140)
nLin += 50
oPrint:Say(nLin,700,cIE,oFont13 ,140)


oPrint:Box(100,1770,390,nMargem)
oPrint:Line(150,1770,150,nMargem)

oPrint:Say(200,1800,"Série: "+ cSerie,oFont12 ,100)
oPrint:Say(270,1800,"N.Fiscal: "+ cNFe,oFont12 ,100)
oPrint:Say(340,1800,"Dt.Emissão: "+ cEmissao,oFont12 ,100)

oPrint:Box(420,100,2000,nMargem)

nLin += 170
oPrint:Say(nLin,450, Space(10) + 'Carta de Correção Eletrônica - CC-e',oFont24b ,140)
nLin += 100
oPrint:Say(nLin,110,'Chave de Acesso da NF-e',oFont10b ,140)

nLin += 50
oPrint:Say(nLin,110 , cChaveNfe , oFont11 ,140)
nLin += 50
oPrint:Say(nLin,110,'Protocolo de Autorização de Uso da Nfe',oFont10b ,140)

oPrint:Code128B(nLin, 900, cChaveNfe , 30, 30 )
nLin += 50
oPrint:Say(nLin,110 , cProt , oFont11 ,140)
cPicChave := TRANSF(cChaveNfe,"@R 9999.9999.9999.9999.9999.9999.9999.9999.9999.9999")
oPrint:Say(nLin,1200 , cPicChave , oFont09 ,140)

nLin += 100
oPrint:Line(nLin,100,nLin,nMargem)

nLin += 80
oPrint:Say(nLin,110,"Dados do destinatário",oFont11 ,200)
nLin += 50

oPrint:Say(nLin,110,"Razão Social / Nome ",oFont10b ,200)
oPrint:Say(nLin,1300,"CNPJ/CPF",oFont10b ,200)
oPrint:Say(nLin,1550,"Inscrição Estadual",oFont10b ,200)
nLin += 50
oPrint:Say(nLin,110,cRazSoc , oFont11 ,200)
oPrint:Say(nLin,1300,'cCnpj',oFont11 ,200)
oPrint:Say(nLin,1550, cIE ,oFont11 ,200)

nLin += 50
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
oPrint:Say(nLin,110,"Correções a serem considerada",oFont11 ,200)
//

nLin := 2300

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


MSBAR('CODE128',30 , 10,alltrim(cChaveNfe),oPrint,.F.,,.T.,0.013,0.7,,,,.F.)

nLin += 250
oPrint:EndPage()

oPrint:Preview()

Return

