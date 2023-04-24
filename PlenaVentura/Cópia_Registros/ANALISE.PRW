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
 
Private cLFRC	:= chr(13)+chr(10)
Private cPict2UM     := PesqPict('SB2','B2_QTSEGUM')
Private cPictD5      := PesqPict('SD5','D5_QUANT')
Private cPictDB      := PesqPict('SDB','DB_QUANT')
Private cPictB1      := PesqPict('SB1','B1_CONV')

private  lChSED  := .F.
private  lChZM9  := .F.
private  lChSA2  := .F.


private lChSAH       := .F.
private lChSB1       := .F.
private lChSBM       := .F.
private lChZ01       := .F.
private lChZ02       := .F.
private lChSE4       := .F.
private lChCT1   := .F.
private lChCTD   := .F.
private lChCTH   := .F.
private lChCVD   := .F.
private lChCVN   := .F.
private lChCT5   := .F.
private lChSF4   := .F.
private lChSF7   := .F.
private lChCVE   := .F.
private lChCVF   := .F.
private lChCTN   := .F.
private lChSAL   := .F.
private lChSY1   := .F.
private lChDHL   := .F.
private lChSFM   := .F.
private lChF3K   := .F.
private lMarkTd   := .F.
private aOpcoes  := {}
                                             
Private aNumSeq      := {}
Private _cFilOri       := Space(6)
Private _cFilDes       := Space(6)
Private dDtProces    := dDataBase
Private _cEmpDes     := Space(2)

Private nSldKarLocal := nSldKarLote := nSldKarEnde := 0
Private _cEmpOri     := Space(2)
Private _cEmpOld     := Space(2)
Private _cEmpIni     := cEmpant
Private _cFilIni     := cFilant
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

//@ 100,006 FOLDER oFolder OF oDlgMain PROMPT "&Faturamento","Financeiro","Compras","Contabilidade","XX","XX","XX","XX","XX","XX","XX","XX" PIXEL SIZE 478,241
@ 100,006 FOLDER oFolder OF oDlgMain PROMPT "&Faturamento","Financeiro","Compras","Contabilidade","Fiscal"  PIXEL SIZE 478,241
//                                           01                 02         03          04           05          06    07    08                09                 10                11                   12

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
//@ 005,005 TO 070, 220 PROMPT "*Marcar todas"        PIXEL OF oFolder:aDialogs[1] change(sfMkAll())

//@ 005,005 CHECKBOX oChFAT VAR lMarkTd PROMPT "Marcar/Desmarcar Todos" When .T. SIZE 200,017 PIXEL of oFolder:aDialogs[1] ON CHANGE sfMkAll(lMarkTd,1)
@ 005,005 BUTTON "&Marcar todos"        SIZE 50,12 PIXEL of oFolder:aDialogs[1] ACTION sfMkAll(.T., 1)
@ 005,075 BUTTON "&Desmarcar todos"     SIZE 60,12 PIXEL of oFolder:aDialogs[1] ACTION sfMkAll(.F., 1)

@ 030, 006 checkbox oChFAT var lChSBM size 100, 008 pixel of oFolder:aDialogs[1] prompt "SBM - Grupo Produtos" pixel  
@ 040, 006 checkbox oChFAT var lChSB1 size 100, 008 pixel of oFolder:aDialogs[1] prompt "SB1 - Produtos" pixel  
@ 050, 006 checkbox oChFAT var lChZ01 size 100, 008 pixel of oFolder:aDialogs[1] prompt "Z01 - Sub Grupo Produtos" pixel  
@ 060, 006 checkbox oChFAT var lChZ02 size 100, 008 pixel of oFolder:aDialogs[1] prompt "Z02 - Família" pixel  
@ 070, 006 checkbox oChFAT var lChSAH size 100, 008 pixel of oFolder:aDialogs[1] prompt "SAH - Unidade Medidas" pixel  
@ 080, 006 checkbox oChFAT var lChSE4 size 100, 008 pixel of oFolder:aDialogs[1] prompt "SE4 - Condição Pagamento" pixel  

@ 080,450 BUTTON "&Processar"   SIZE 40,16 PIXEL ACTION Processa({||fValida()})

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 02
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////       
@ 005,005 BUTTON "&Marcar todos"        SIZE 50,12 PIXEL of oFolder:aDialogs[2] ACTION sfMkAll(.T., 2)
@ 005,075 BUTTON "&Desmarcar todos"     SIZE 60,12 PIXEL of oFolder:aDialogs[2] ACTION sfMkAll(.F., 2)

@ 030, 006 checkbox oChFAT var lChSED size 100, 008 pixel of oFolder:aDialogs[2] prompt "SED - Natureza Financeira" pixel  
@ 040, 006 checkbox oChFAT var lChZM9 size 100, 008 pixel of oFolder:aDialogs[2] prompt "ZM9 - Empresa Fluig" pixel  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 03
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@ 005,005 BUTTON "&Marcar todos"        SIZE 50,12 PIXEL of oFolder:aDialogs[3] ACTION sfMkAll(.T., 3)
@ 005,075 BUTTON "&Desmarcar todos"     SIZE 60,12 PIXEL of oFolder:aDialogs[3] ACTION sfMkAll(.F., 3)

@ 030, 006 checkbox oChFAT var lChSA2 size 100, 008 pixel of oFolder:aDialogs[3] prompt "SA2 - Fornecedores" pixel  
@ 040, 006 checkbox oChFAT var lChSY1 size 100, 008 pixel of oFolder:aDialogs[3] prompt "SY1 - Comprador" pixel  
@ 050, 006 checkbox oChFAT var lChSAL size 100, 008 pixel of oFolder:aDialogs[3] prompt "SAL - Alcadas" pixel  
@ 060, 006 checkbox oChFAT var lChDHL size 100, 008 pixel of oFolder:aDialogs[3] prompt "DHL - Perfil Aprovacao" pixel  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 04
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@ 005,005 BUTTON "&Marcar todos"        SIZE 50,12 PIXEL of oFolder:aDialogs[4] ACTION sfMkAll(.T., 4)
@ 005,075 BUTTON "&Desmarcar todos"     SIZE 60,12 PIXEL of oFolder:aDialogs[4] ACTION sfMkAll(.F., 4)

@ 030, 006 checkbox oChFAT var lChCT1 size 100, 008 pixel of oFolder:aDialogs[4] prompt "CT1 - Plano de Contas" pixel  
@ 040, 006 checkbox oChFAT var lChCTD size 100, 008 pixel of oFolder:aDialogs[4] prompt "CTD - Item Contábil" pixel  
@ 050, 006 checkbox oChFAT var lChCTH size 100, 008 pixel of oFolder:aDialogs[4] prompt "CTH - Classe Valor" pixel  
@ 060, 006 checkbox oChFAT var lChCVD size 100, 008 pixel of oFolder:aDialogs[4] prompt "CVD - Plano Contas Referencial" pixel  
@ 070, 006 checkbox oChFAT var lChCVN size 100, 008 pixel of oFolder:aDialogs[4] prompt "CVN - Amarração Plano Contas referencial" pixel  
@ 080, 006 checkbox oChFAT var lChCT5 size 100, 008 pixel of oFolder:aDialogs[4] prompt "CT5 - Lançamento Padrão" pixel  
//@ 090, 006 checkbox oChFAT var lChFK3 size 100, 008 pixel of oFolder:aDialogs[4] prompt "FK3 - Produtos X Valores declaratórios" pixel  
@ 090, 006 checkbox oChFAT var lChCVE size 100, 008 pixel of oFolder:aDialogs[4] prompt "CVE - Visão Gerencial" pixel  
@ 100, 006 checkbox oChFAT var lChCVF size 100, 008 pixel of oFolder:aDialogs[4] prompt "CVF - Visão Gerencial" pixel  
@ 110, 006 checkbox oChFAT var lChCTN size 100, 008 pixel of oFolder:aDialogs[4] prompt "CTN - Livro Contábil" pixel  
// FOLDER 05
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@ 005,005 BUTTON "&Marcar todos"        SIZE 50,12 PIXEL of oFolder:aDialogs[5] ACTION sfMkAll(.T., 5)
@ 005,075 BUTTON "&Desmarcar todos"     SIZE 60,12 PIXEL of oFolder:aDialogs[5] ACTION sfMkAll(.F., 5)

@ 030, 006 checkbox oChFAT var lChSF4 size 100, 008 pixel of oFolder:aDialogs[5] prompt "SF4 - Tipos Entrada Saida" pixel  
@ 040, 006 checkbox oChFAT var lChSF7 size 100, 008 pixel of oFolder:aDialogs[5] prompt "SF7 - Excecao Fiscal" pixel  
@ 050, 006 checkbox oChFAT var lChSFM size 100, 008 pixel of oFolder:aDialogs[5] prompt "SFM - TES Inteligente" pixel  
@ 060, 006 checkbox oChFAT var lChF3K size 100, 008 pixel of oFolder:aDialogs[5] prompt "F3K - Produto X Cod Valores Declaratórios" pixel  
@ 080,320 BUTTON "&Sair"        SIZE 40,16 PIXEL ACTION oDlgMain:End()

ACTIVATE MSDIALOG oDlgMain  CENTERED
cEmpAnt := _cEmpOld
RestArea(aArea)        

Return(.T.)

//----------------------------------------------------------
/*/{Protheus.doc} sfMkAll
Função sfMkAll
@param lMark Recebo o lMark
@return Não retorna nada
@author Reinaldo Dias
@owner Totvs S/A
@obs Marca todos os itens do folder
@history
04/10/2012 - Acrescimo de cabecalho Protheus.Doc
/*/
//----------------------------------------------------------
Static Function sfMkAll(lMark, nOpc)

if nOpc == 1 .or. nOpc == 0
   lChSBM := lMark
   lChSB1 := lMark
   lChZ01 := lMark 
   lChZ02 := lMark
   lChSAH := lMark
   lChSE4 := lMark 
endif
if nOpc == 2 .or. nOpc == 0
   lChSED := lMark
   lChZM9 := lMark
endif

if nOpc ==3 .or. nOpc == 0
   lChSA2 := lMark
   lChSY1 := lMark
   lChSAL := lMark
   lChDHL := lMark
endif
if nOpc ==4 .or. nOpc == 0
   lChCT1 := lMark
   lChCTD := lMark
   lChCTH := lMark
   lChCVD := lMark
   lChCVN := lMark
   lChCT5 := lMark
   lChCVE := lMark
   lChCVF := lMark
   lChCTN := lMark
Endif
if nOpc ==5 .or. nOpc == 0
   lChSF4 := lMark
   lChSF7 := lMark
   lChSFM := lMark
   lChF3K := lMark
endif
Return

//----------------------------------------------------------
/*/{Protheus.doc} fValida
Função fValida
@param Não recebe parâmetros
@return Não retorna nada
@author Tiago Santos
@owner SMSTI
@obs Função para validar os registros antes das cópias
/*/
//----------------------------------------------------------
Static Function fValida()
Local aTabelas := {}
if _cEmpOri + _cFilOri == _cEmpDes + _cFilDes
   MsgStop("Empresa + Filial Origem iguais a Empresa Filial Destino !!!")
   return
Endif

// Se tabela selecionada, inclui no Array para processamento
aTabelas := retTabelas()
// definir a variavel de empresa e filial conforme seleção na tela

if len(aTabelas) ==0
      MsgStop("Não Foram selecionadas tabelas para Cópia !!!")
      return
endif

oProcess := MsNewProcess():New({|| fProcessa(oProcess, aTabelas)}, "Processando...", "Aguarde...", .T.)
oProcess:Activate()

Return

//----------------------------------------------------------
/*/{Protheus.doc} fProcessa
Função fProcessa
@param Não recebe parâmetros
@return Não retorna nada
@author Tiago Santos
@owner SMSTI
@obs Função para validar os registros antes das cópias
/*/
//----------------------------------------------------------
static function fProcessa(oOBj, aTab)
Local nAtual := 0
Local nTotal := 0
local nAtu2  := 0
Local nTot2  := 90

For nCont :=1 to len (aTab)

   // verificar se há dados no destino

   if TrocaEmp(aTab[nCont])
  
   endif

Next nConta

return

//----------------------------------------------------------
/*/{Protheus.doc} TrocaEmp
Função TrocaEmp
@param Não recebe parâmetros
@return Query da tabela selecionada
@author Tiago Santos
@owner SMSTI
@obs Query da tabela selecionada
/*/
//----------------------------------------------------------
static function TrocaEmp(cTab)
Local cFilBus := left(_cFilOri,4)
Local cFilDes := left(_cFilDes,4)
Local lRet := .T.
Local _nQtdReg :=0

// pegar o nome da tabela SX2 destino
cQuery := " Select *  From SX2" +_cEmpDes + "0 Where D_E_L_E_T_ =' '"
cQuery += " and  X2_CHAVE = '" +cTab + "' "
if select("QRX2") <> 0
   QRX2->( DBCLOSEAREA(  ))
Endif
TCQuery cQuery New Alias "QRX2"


// verificar se a table existe no banco
if QRX2->( !EOF())
   cQuery := "select table_name TN from ALL_TABLES where table_name = '" + alltrim(QRX2->X2_ARQUIVO) +"'"
   if select("QRALL") <> 0
      QRALL->( DBCLOSEAREA(  ))
   Endif
   TCQuery cQuery New Alias "QRALL"

   // verificar compartilhamento table
   if QRX2->X2_MODO == 'E'
      cFilBus :=_cFilOri
      cFilDes := _cFilDes
   Elseif QRX2->(X2_MODO + X2_MODO + X2_MODOEMP) =='CCC'
      cFilBus = Space(6)
      cFilDes = Space(6)
   Endif
   cFilWhere := iif(left(cTab,1)=="S", right(cTab,2),cTab) + '_FILIAL'   

   // buscar campos SX3 não virtuais
   cQuery := "Select X3_CAMPO, X3_TIPO from SX3"+_cEmpOri+"0 Where X3_ARQUIVO ='"+cTab+"' and D_E_L_E_T_ =' ' and X3_CONTEXT <> 'V' "
   cQuery += "and X3_CAMPO <>  '"+cFilWhere+"'  and X3_CAMPO NOT like ('%USERLG%')   Order by X3_ORDEM"
   if select("QX3") <> 0
      QX3->( DBCLOSEAREA(  ))
   Endif
   TCQuery cQuery New Alias "QX3"
   // força a mudança de empresas antes da função EmpOpenFile
   if cEmpant == _cEmpDes
      cEmpant := '01'
   endif

   // buscar registros tabela origem
   cQuery := "select * from " + alltrim(QRALL->TN )+ " Where "+cFilWhere +"='"+cFilBus+"' and D_E_L_E_T_ =' '"
   if select("QOR") <> 0
      QOR->( DBCLOSEAREA(  ))
   Endif
   TCQuery cQuery New Alias "QOR"
   cModo :=""
   cCampo := ''
   cValor := ' '
   nTotal := 0
   Count To nTotal
   QOR->(DbGoTop())
   
   oprocess:IncRegua1("Tabela: "+cTab)
   oprocess:SetRegua2(nTotal)
   if EmpOpenFile(cTab,cTab,1,.T.,_cEmpDes,@cModo)
      // se existir registros da filial destino, pergunta se deseja excluir antes da cópia
      if (cTab)->(DbSeek(cFilDes))
         cMsg := "Há Dados na tabela " + cTab +" da empresa: "+ _cEmpDes
         cMsg += " Filial: "+ _cFilDes
         cMsg += '<br><br><font color="#ff0000"> Deseja Sobrepor os dados ?  </font> '
         if (ApMsgYesNo(cMsg, "Atenção"))            
            MsAguarde({|| DelReg(cTab, cFilWhere, cFilDes)}, "Aguarde...", "Deletando Registros "+cTab +" Emp: " + _cEmpDes +" Filial: "+_cFilDes)
         else
            return
         Endif
      Endif
      nAtual :=0
      While QOR ->( ! EOF())
         nAtual++
         oProcess:IncRegua2("Registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) )
         Begin Transaction
            RecLock(cTab, .T.)	
               &(cTab+'->'+cFilWhere)     :=  cFilDes
                  QX3->( Dbgotop())
                  While QX3->(!EOF())   
                     //oprocess:IncRegua2("Campo: "+QX3->X3_CAMPO )  
                     if QX3->X3_TIPO =='D'
                        &(ctab+ '->'+QX3->X3_CAMPO)  :=  Stod(&('QOR->'+QX3->X3_CAMPO)   )                        
                     elseif QX3->X3_TIPO =='L'
                        &(ctab+ '->'+QX3->X3_CAMPO)  := iif(&('QOR->'+QX3->X3_CAMPO)=='T', .T., .F.)
                     elseif QX3->X3_TIPO <>'M'
                        &(ctab+ '->'+QX3->X3_CAMPO)  :=      &('QOR->'+QX3->X3_CAMPO)    
                     Endif                     
                     QX3->( DbSkip())
                  Enddo                        
            (cTab)->( MsUnLock())         
         End Transaction
         QOR->( DbSkip())
      Enddo 
   Endif
else
   cMsg := '<br><br><font color="#ff0000"> Tabela: '+cTab+' nao criada na empresa: '+_cEmpDes+'   </font> '
   MSGALERT( cMsg, 'Atencao'  )
   lRet := .F.
Endif

Return lRet
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


static function retTabelas ()
atabelas := {}
if lChSBM
	aadd(atabelas,'SBM')
Endif 
if lChSB1
	aadd(atabelas,'SB1')
Endif
if lChZ01
	aadd(atabelas,'Z01')
Endif
if lChZ02
	aadd(atabelas,'Z02')
Endif
if lChSAH
	aadd(atabelas,'SAH')
Endif
if lChSE4
	aadd(atabelas,'SE4')
Endif
if lChSED
	aadd(atabelas,'SED')
endif
if lChZM9
	aadd(atabelas,'ZM9')
endif
if lChSA2
	aadd(atabelas,'SA2')
endif
if lChCT1
	aadd(atabelas,'CT1')
endif
if lChCTD
	aadd(atabelas,'CTD')
endif
if lChCTH
	aadd(atabelas,'CTH')
endif
if lChCVD
	aadd(atabelas,'CVD')
endif
if lChCVN
	aadd(atabelas,'CVN')
endif
if lChCT5
	aadd(atabelas,'CT5')
endif
if lChCVE
	aadd(atabelas,'CVE')
endif
if lChCVF
	aadd(atabelas,'CVF')
endif
if lChCTN
	aadd(atabelas,'CTN')
endif
if lChSAL
	aadd(atabelas,'SAL')
endif
if lChDHL
	aadd(atabelas,'DHL')
endif
if lChSY1
	aadd(atabelas,'SY1')
endif
if lChSF4
	aadd(atabelas,'SF4')
endif
if lChSF7
	aadd(atabelas,'SF7')
endif
if lChSFM
	aadd(atabelas,'SFM')
endif
if lChF3K
	aadd(atabelas,'F3K')
endif

Return atabelas




static function DelReg (cTab, cFilWhere, cFilDel)
local aArea := (cTab)->(GetArea())

cFilDel := cFilDel + Space(tamsx3("A2_FILIAL")[1] - len(cFilDel)) 

(cTab)->(DBGOTOP(  ))
if (cTab)->(DbSeek(cFilDel))
   While (cTab)->( !EOF()) .and. &(ctab+ '->'+cFilWhere) == cFilDel
      RecLock(cTab, .F.)
         DBDelete()
      (cTab)->(MSUNLOCK())
      (cTab)->(DbSkip())
   Enddo
Endif

(cTab)->(RestArea(aArea))
Return
