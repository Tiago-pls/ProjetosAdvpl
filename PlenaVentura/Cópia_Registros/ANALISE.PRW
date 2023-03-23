#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE2.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"  
//----------------------------------------------------------
/*/{Protheus.doc} ANALISE
Função ANALISE
@param Não recebe parâmetros
@return Não retorna nada
@author Reinaldo Dias
@owner Totvs S/A
@version Protheus 10, Protheus 11
@since 04/10/2012 - data de revisão do artefato
 

/*/
//----------------------------------------------------------

Static cPict        := ""

User Function ANALISE()            
Local oDlgMain    
Local aArea          := GetArea()
Local oNoMarked      := LoaDBitmap( GetResources(), "LBNO" )
Local oMarked        := LoaDBitmap( GetResources(), "LBOK" )
Local cPerg          := "ANALISE"
 

Private cPict2UM     := PesqPict('SB2','B2_QTSEGUM')
Private cPictD5      := PesqPict('SD5','D5_QUANT')
Private cPictDB      := PesqPict('SDB','DB_QUANT')
Private cPictB1      := PesqPict('SB1','B1_CONV')

private lChSA1       := .F.
private lChSB1       := .F.
                                             
Private aNumSeq      := {}
Private _cFilOri       := Space(6)
Private _cFilDes       := Space(6)
Private dDtProces    := dDataBase
Private _cEmpDes     := Space(2)

Private nSldKarLocal := nSldKarLote := nSldKarEnde := 0
Private _cEmpOri     := Space(2)
Private _cEmpOld     := Space(2)
Private cDescEmpOri  := Space(40)
Private cDescEmpDes  := Space(40)
Private nOpSB8       := 1
Private nOpSBF       := 1
Private cMensagem    := ""
Private cMensOK      := ""
Private cMensErro    := ""
Private cMensSB8     := ""
Private cMensSBF     := ""        
Private cCrlLot      := ""        
Private cCrlEnd      := ""        
Private cDescFilOri         := ""
Private cDescFilDes         := ""
Private c2UM         := ""
Private nFatConv     := 0
Private cTipConv     := ""
Private cZona        := ""
Private aSx3Box      := RetSx3Box(Posicione('SX3',2,'BE_STATUS','X3CBox()'),,,1)
Private cMensB8BF    := ""
Private cMensBJBK    := ""
Private cMensDocto   := ""
Private cMensNumSeq  := ""
Private cMensDAB8    := ""
Private _lReturn     := .F.

cPict        := PesqPict('SB2','B2_QATU')

#IFDEF TOP
    IF !fDigSenha()
       Return
    Endif
#ELSE
    MsgStop("Essa rotina funciona somente no ambiente TOP.")
    Return
#ENDIF

Pergunte(cPerg,.F.)               

DEFINE MSDIALOG oDlgMain TITLE "Cópia registros"  OF oMainWnd PIXEL FROM 040,040 TO 670,1017
DEFINE FONT oBold   NAME "Arial" SIZE 0, -12 BOLD
DEFINE FONT oBold2  NAME "Arial" SIZE 0, -40 BOLD
DEFINE FONT oBold3  NAME "Arial" SIZE 0, -80 BOLD
DBSelectArea("SB1")

@ 100,006 FOLDER oFolder OF oDlgMain PROMPT "&Faturamento","Compras","XX","XX","XX","XX","XX","XX","XX","XX","XX","XX" PIXEL SIZE 478,241
//                                           01       02         03          04           05          06    07    08                09                 10                11                   12

@ 005,005 TO 070, 220 PROMPT "Origem"             PIXEL OF oDlgMain 
@ 020,010 SAY "Empresa "                                     SIZE 040,10 PIXEL OF oDlgMain FONT oBold 
@ 019,040 MSGET oVar   VAR _cEmpOri Picture "@!"         SIZE 010,10 PIXEL OF oDlgMain F3 "SM0MRP" VALID(ValEmpDe( 1))
@ 019,065 MSGET oVar   VAR cDescEmpOri   Picture "@!"    SIZE 150,10 PIXEL OF oDlgMain When .F.

@ 041,010 SAY "Filial"                                     SIZE 040,10 PIXEL OF oDlgMain FONT oBold 
@ 040,029 MSGET oVar   VAR _cFilOri Picture "@!"         SIZE 030,10 PIXEL OF oDlgMain F3 "SM0"  VALID(ValEmpDe(2))
@ 040,065 MSGET oVar   VAR cDescFilOri      Picture "@!" SIZE 150,10 PIXEL OF oDlgMain When .F.


@ 005,245 TO 070, 485 PROMPT "Destino"               PIXEL OF oDlgMain
@ 020,250 SAY "Empresa"                                 SIZE 040,10 PIXEL OF oDlgMain FONT oBold 
@ 019,281 MSGET oVar   VAR _cEmpDes  Picture "@!"       SIZE 010,10 PIXEL OF oDlgMain F3 "SM0MRP" VALID(ValEmpPa( 1))
@ 019,310 MSGET oVar   VAR cDescEmpDes   Picture "@!"   SIZE 150,10 PIXEL OF oDlgMain When .F.

@ 041,250 SAY "Filial"                                  SIZE 070,10 PIXEL OF oDlgMain FONT oBold 
@ 040,271 MSGET oVar   VAR _cFilDes    Picture "@!"     SIZE 030,10 PIXEL OF oDlgMain F3 "SM0"  VALID(ValEmpPa(2))
@ 040,310 MSGET oVar   VAR cDescFilDes     Picture "@!" SIZE 150,10 PIXEL OF oDlgMain When .F.


// opções para selecioar as tabelas para cópia
@ 020, 006 checkbox oChFAT var lChSA1 size 100, 008 pixel of oFolder:aDialogs[1] prompt "SA1 - Clientes" pixel  
@ 030, 006 checkbox oChFAT var lChSB1 size 100, 008 pixel of oFolder:aDialogs[1] prompt "SB1 - Produtos" pixel  


@ 080,450 BUTTON "&Processar"   SIZE 40,16 PIXEL ACTION Processa({||fProcessa()})

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 02
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////       
oCheck2 := TCheckBox():New(21,01,'XX2',,oFolder:aDialogs[2],054,020,,,,,,,,.T.,,,)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 03
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

oCheck3 := TCheckBox():New(21,01,'XX3',,oFolder:aDialogs[3],054,020,,,,,,,,.T.,,,)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 04
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
oCheck4 := TCheckBox():New(21,01,'XX4',,oFolder:aDialogs[4],054,020,,,,,,,,.T.,,,)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 05
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
oCheck5 := TCheckBox():New(21,01,'XX5',,oFolder:aDialogs[5],054,020,,,,,,,,.T.,,,)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 06
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
oCheck6 := TCheckBox():New(21,01,'XX6',,oFolder:aDialogs[6],054,020,,,,,,,,.T.,,,)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 07
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
oCheck7 := TCheckBox():New(21,01,'XX7',,oFolder:aDialogs[7],054,020,,,,,,,,.T.,,,)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 08
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 09
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 10
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 11
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 12
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@ 080,320 BUTTON "&Sair"        SIZE 40,16 PIXEL ACTION oDlgMain:End()

ACTIVATE MSDIALOG oDlgMain  CENTERED
cEmpAnt := _cEmpOld
RestArea(aArea)        

Return(.T.)




//----------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função MarcaTodos
@param lMark Recebo o lMark
@return Não retorna nada
@author Reinaldo Dias
@owner Totvs S/A
@obs Marca todos os itens do folder
@history
04/10/2012 - Acrescimo de cabecalho Protheus.Doc
/*/
//----------------------------------------------------------
Static Function MarcaTodos(lMark)
For nI:= 1 To Len(aFolder)
  aFolder[nI,1] := IIF(lMark,.T.,.F.)
Next
oBox:Refresh()
Return


//----------------------------------------------------------
/*/{Protheus.doc} fProcessa
Função fProcessa
@param Não recebe parâmetros
@return Não retorna nada
@author Reinaldo Dias
@owner Totvs S/A
@obs Funcao para processar a movimentacao dos saldos.
@history
04/10/2012 - Acrescimo de cabecalho Protheus.Doc
/*/
//----------------------------------------------------------
Static Function fProcessa()


/*
montar regras para processamento das cópias
IF Empty(_cFilDes) .OR. Empty(dDataF)
   MsgStop("Datas de Processamento Invalidas !!!")
   Return
Endif
*/  
ProcRegua(15)


if _cEmpOri + _cFilOri == _cEmpDes + _cFilDes
   MsgStop("Empresa + Filial Origem iguais a Empresa Filial Destino !!!")
   return
Endif
IncProc("Processando Faturamento")
IncProc("Processando Compras")
IncProc("Processando XX")

Return

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function ValidACols()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local cCampo  := ReadVar()
Local _Return := .T.
IF cCampo $ "M->ORIGEM/M->CF"
   MsgStop("Este campo não pode ser alterado.","Atenção")
   _Return := .F.
ElseIF cCampo == "M->QTDE2UM"
   nQuant     := &(cCampo)
   aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "QTDE"})]    := ConvUM(_cEmpOri,0,nQuant,1) // 1UM
ElseIF cCampo == "M->QTDE"
   nQuant     := &(cCampo)
   aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "QTDE2UM"})] := ConvUM(_cEmpOri,nQuant,0,2) // 2UM
ElseIF cCampo == "M->ENDERECO" .And. aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "ORIGEM"})] == "SDB" .And. Empty(&(cCampo))
   MsgStop("O endereço deve ser preenchido.","Atenção")
   _Return := .F.
ElseIF cCampo == "M->LOTE" .And. aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "ORIGEM"})] == "SD5" .And. Empty(&(cCampo))
   MsgStop("O lote deve ser preenchido.","Atenção")
   _Return := .F.
ElseIF cCampo == "M->DATA" .And. !Empty(aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "ORIGEM"})]) .And. Empty(&(cCampo))
   MsgStop("A data deve ser preenchida.","Atenção")
   _Return := .F.
ElseIF cCampo == "M->DOCTO" .And. !Empty(aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "ORIGEM"})]) .And. Empty(&(cCampo))
   MsgStop("O documento deve ser preenchida.","Atenção")
   _Return := .F.
Endif      

Return (_Return)


//----------------------------------------------------------
/*/{Protheus.doc} fPesquisa
Função fPesquisa
@param cOpcao  utilizado para identificar uma alteracao ou exclusao
@param oBrowse utilizado para passar objetivo oBrowse
@return Não retorna nada
@author Reinaldo Dias
@owner Totvs S/A
@obs Funcao utilizada para realizar pesquisa nos browsers.
@history
04/10/2012 - Acrescimo de cabecalho Protheus.Doc
/*/
//----------------------------------------------------------
Static Function fPesquisa(cOpcao,oBrowse)

Local oDlgPesq
Local aArea   := GetArea()
Local cCampos := Space(20)          
Local cSeek   := Space(20)   
Local aCampos := {}

For I:= 1 To Len(oBrowse:AHEADERS)
   IF Valtype(oBrowse:AARRAY[1,I]) = "C" .AND. !UPPER(Alltrim(oBrowse:AHEADERS[I])) $ "STATUS/TM/SERIE/LOJA/CLIE.FOR/ORIGEM"
      AAdd(aCampos,oBrowse:AHEADERS[I])
   Endif   
Next

DBSelectArea("SB1")

DEFINE MSDIALOG oDlgPesq TITLE "Pesquisar no "+cOpcao  OF oDlgPesq PIXEL FROM 010,010 TO 150,265 

@ 010,005 COMBOBOX cCampos ITEMS aCampos       SIZE 100,10 PIXEL OF oDlgPesq 
@ 030,005 MSGET oVar  VAR  cSeek Picture "@!"  SIZE 100,10 PIXEL OF oDlgPesq 
                                                 
@ 050,090 BUTTON "&Sair"      SIZE 30,14 PIXEL ACTION oDlgPesq:End()

ACTIVATE MSDIALOG oDlgPesq  CENTERED

RestArea(aArea)

Return



//----------------------------------------------------------
/*/{Protheus.doc} fDigSenha
Função fDigSenha
@param Não recebe parâmetros
@return Não retorna nada
@author Reinaldo Dias
@owner Totvs S/A
@obs Funcao para solicitar a senha para acessar a rotina de analise.
@history
04/10/2012 - Acrescimo de cabecalho Protheus.Doc
/*/
//----------------------------------------------------------
Static Function fDigSenha()
Private cSenha   := Space(10)         
Private cSenhAce := "tudo"
@ 067,020 To 169,312 Dialog Senhadlg Title OemToAnsi("Liberação de Acesso")
@ 015,005 Say OemToAnsi("Informe a senha para o acesso ?") Size 80,8
@ 015,089 Get cSenha Size 50,10 Password
@ 037,106 BmpButton Type 1 Action fOK()
@ 037,055 BmpButton Type 2 Action Close(Senhadlg)
Activate Dialog Senhadlg CENTERED
Return(_lReturn)                     


//----------------------------------------------------------
/*/{Protheus.doc} fOK
Função fOK
@param Não recebe parâmetros
@return Não retorna nada
@author Reinaldo Dias
@owner Totvs S/A
@obs Funcao para validar a senha digitada
@history
04/10/2012 - Acrescimo de cabecalho Protheus.Doc
/*/
//----------------------------------------------------------
Static Function fOK()

If ALLTRIM(cSenha)<> cSenhAce
   MsgStop("Senha não Confere !!!")
   cSenha  := Space(10)
   dlgRefresh(Senhadlg)
Else
   _lReturn  := .T.
   Close(Senhadlg)
Endif
Return

/*
Validação empresa / Filial
*/
static Function ValEmpDe(nOp)
Local lRet := .T.
SM0->( Dbgotop())

cBusca := iif (nOp ==1, _cEmpOri, _cEmpOri + _cFilOri)

if SM0->( dbSeek(cBusca))
   cDescEmpOri:=Alltrim(SM0->M0_NOME)
   cDescFilOri:= iif (EMPTY( _cFilOri ), " ",   Alltrim(SM0->M0_FILIAL))
   cEmpAnt := _cEmpOri
else   
   lRet := .F.
endif
return lRet


/*
Validação empresa / Filial
*/
static Function ValEmpPa(nOp)
Local lRet := .T.
SM0->( Dbgotop())

cBusca := iif (nOp ==1, _cEmpDes, _cEmpDes + _cFilDes)

if SM0->( dbSeek(cBusca))
   cDescEmpDes:=Alltrim(SM0->M0_NOME)
   cDescFilDes:= iif (EMPTY( _cFilDes ), " ",   Alltrim(SM0->M0_FILIAL))
   cEmpAnt := _cEmpDes
else   
   lRet := .F.
endif
return lRet
