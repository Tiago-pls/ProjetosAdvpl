#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#INCLUDE "TOTVS.CH"
user function tstcb()

Local cBitMap := "\system\imagens\LGRL0101.BMP" ///Logotipo da empresa

// retorna XML

cChaveNfe := "1200675621672000113550030000032591780976690"

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
oFont24b := TFont():New( "Arial",,24,,.t.,,,,,.f.,.f. )

// Mostra a tela de Setup
//oPrint:Setup() ///???????????????

oPrint:SetPortrait()
oPrint:SetPaperSize(9)       ///(DMPAPER_A4)
   
// Inicia uma nova pagina
oPrint:StartPage()

nLin :=100
oPrint:SayBitMap(nLin,116,cBitMap,300,300)


nLin +=400
oPrint:Box(100,1890,390,2400)
oPrint:Line(150,1890,150,2400)

oPrint:Box(420,100,2000,2400)

nLin += 120


MSBAR('CODE128',nLin ,0.8,alltrim(cChaveNfe),oPrint,.F.,,.T.,0.013,0.7,,,,.F.)

//MSBAR('CODE128',0.7,5.8,alltrim(cChaveNfe),oPrint,.F.,,.T.,0.013,0.7,,,,.F.) 
oPrint:EndPage()

oPrint:Preview()

Return .F. 

Return

