#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SRH100   º Autor ³ SIDNEY GAMA        º Data ³  24/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ LIQUIDI CAIXA BANCO FERIAS                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
/*/
User Function SRH102
Local cDesc1  := "Liquido Caixa Bancos Ferias"
Local cDesc2  := "Sera  impresso de acordo com os parametros solicitados pelo"
Local cDesc3  := "usuario."
Local cPict   := ""
Local nLin    := 80
Local Cabec1  := "                                                   Situac        *--- Periodo  ---*  *--- Dias ---*   *----- Historico -----*"
Local Cabec2  := "Matric  Nome                                      Periodo          Inicio   Termino  Dir Conc Saldo   Concessao Gozo Abomo   "
Local imprime := .T.
Local cString := "SRA"        // alias do arquivo principal (Base)
Local aOrd    := {"Centro de Custo","Matricula","Nome","C.Custo + Nome","Filial + Dt.Base","Banco + Nome"}//
Private limite     := 120
Private lEnd       := .F.
Private lAbortPrint:= .F.
Private CbTxt      := ""
Private tamanho    := "M"
Private nomeprog   := "SRH102" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo      := 15
Private aReturn    := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey   := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "SRH102" // Coloque aqui o nome do arquivo usado para impressao em disco
Private aReturn    := {"Zebrado",1,"Administracao",2,2,1,"",1 }   //,
Private NomeProg   := "SRH102"
Private aLinha     := { }
Private nLastKey   := 0
Private cPerg      := "SRH102"
Private cIndCond

Private Titulo   := "Liquido para Caixa e Bancos - Ferias"
Private AT_PRG   := "SRH102"
Private Wcabec0  := 2
Private Wcabec1  := "                                                   Situac        *--- Periodo  ---*  *--- Dias ---*   *----- Historico -----*"
Private Wcabec2  := "Matric  Nome                                      Periodo          Inicio   Termino  Dir Conc Saldo   Concessao Gozo Abomo   "
Private CONTFL   := 1
Private LI       := 0
//ÿÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÿ

cPerg := PadR(cPerg,10)
VldPerg(cPerg)
Pergunte(cPerg,.F.)

//ÿÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÿ
wnrel:="SRH102"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho)

If nLastKey = 27
   Return
Endif
SetDefault(aReturn,cString)
If nLastKey = 27
   Return
Endif
nTipo := If(aReturn[4]==1,15,18)
RptStatus({|lEnd| SRH102Imp(@lEnd,wnRel,cString)},Titulo)
Return

              

Static Function SRH102Imp(lEnd,WnRel,cString)
//ÿÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais (Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÿ
Local FimPAqui    := ""
Local DFimPAqui   := ""
Local DPRPAqui    := ""
Local cAcessaSRA  := &("{ || " + ChkRH("GPER400","SRA","2") + "}")
Local lTemPendente

//ÿÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Private(Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÿ
Private Normal    := 0
Private Descanso  := 0
Private cPerFeAc  := GetNewPar("MV_FERPAC", "N") // Ferias por ano civil

//ÿÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÿ
nOrdem     := aReturn[8]
cFilDe     := mv_par01                          //  Filial De
cFilAte    := mv_par02                          //  Filial Ate
cCcDe      := mv_par03                          //  Centro de Custo De
cCcAte     := mv_par04                          //  Centro de Custo Ate
cMatDe     := mv_par05                          //  Matricula De
cMatAte    := mv_par06                          //  Matricula Ate
dDatade    := mv_par07
dDataAte   := mv_par08
cNomDe     := mv_par09                          //  Nome De
cNomAte    := mv_par10                          //  Nome Ate
cBcoDe     := mv_par11                          //  Banco De
cBcoAte    := mv_par12                          //  Banco Ate

_cQuery := "SELECT "
_cQuery += "      RA_FILIAL, RA_CC, RA_MAT, RA_NOME, RA_ADMISSA, RA_SITFOLH, RA_CATFUNC, RR_DATA, RR_DATAPAG, "
_cQuery += "      RA_BCDEPSA, RA_AGENCIA, RA_CTDEPSA, RA_CIC, RR_VALOR, RR_TIPO3, RR_PD " 
_cQuery += "  FROM "+RetSQLName("SRA")+", "+RetSQLName("SRR")
_cQuery += " WHERE "+RetSQLName("SRA")+".D_E_L_E_T_ = ' ' AND "+RetSQLName("SRR") + ".D_E_L_E_T_ = ' ' "
_cQuery += "   AND RA_FILIAL = RR_FILIAL  "
_cQuery += "   AND RA_MAT    = RR_MAT     "
_cQuery += "   AND RA_FILIAL  BETWEEN '"+cFilDe+"' AND '"+cFilAte+"' "
_cQuery += "   AND RA_CC      BETWEEN '"+cCcDe+"' AND '"+cCcAte+"' "
_cQuery += "   AND RA_MAT     BETWEEN '"+cMatDe+"' AND '"+cMatAte+"' "
_cQuery += "   AND RA_NOME    BETWEEN '"+cNomDe+"' AND '"+cNomAte+"' "
_cQuery += "   AND RA_BCDEPSA BETWEEN '"+cBcoDe+"' AND '"+cBcoAte+"' "
_cQuery += "   AND RR_TIPO3  = 'F' AND RR_PD = '431' "
_cQuery += "   AND RR_DATA   BETWEEN '"+dtos(dDataDe)+"' AND '"+dtos(dDataAte)+"' "

do case
   case nOrdem==1
      _cQuery += "   ORDER BY RA_FILIAL, RA_BCDEPSA, RA_CC "
   case nOrdem==2
      _cQuery += "   ORDER BY RA_FILIAL, RA_BCDEPSA, RA_MAT "
   case nOrdem==3
      _cQuery += "   ORDER BY RA_FILIAL, RA_BCDEPSA, RA_NOME "
   case nOrdem==4
      _cQuery += "   ORDER BY RA_FILIAL, RA_BCDEPSA, RA_CC, RA_NOME "
   case nOrdem==5
      _cQuery += "   ORDER BY RA_FILIAL, RA_BCDEPSA, RR_DATA "
   case nOrdem==6
      _cQuery += "   ORDER BY RA_BCDEPSA, RA_AGENCIA, RA_NOME "


endcase
if (select("TSRA") <> 0)
        TSRA->(dbCloseArea())
   endIf
TcQUERY _cQuery NEW ALIAS "TSRA"

Cabec1 := "Ord Bco / Ag    Conta             Valor Dt  Cred  Nome                                       Matric C.Custo              C.P.F."
//         0.........1.........2.........3.........4.........5.........6.........7.........8.........9.........0.........1.........2.........3
nLin := 80                                                                                                        
nTotGer := 0
nTotBan := 0
nOrdImp := 1
TSRA->(dbgotop())
_cBanco := substr(TSRA->RA_BCDEPSA,1,3)
While !TSRA->(EOF())
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,"",NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif
   If substr(TSRA->RA_BCDEPSA,1,3) <> _cBanco
      @nLin,010 PSAY "Total Banco:" + transform(nTotBan,"@E 99,999,999.99")   
      nTotBan := 0
      Cabec(Titulo,Cabec1,"",NomeProg,Tamanho,nTipo)
      nLin := 8      
   Endif
   @nLin,001 PSAY str(nOrdImp,4)
   @nLin,006 PSAY substr(TSRA->RA_BCDEPSA,1,3)
   @nLin,010 PSAY substr(TSRA->RA_AGENCIA,1,6)
   @nLin,017 PSAY TSRA->RA_CTDEPSA           
   @nLin,030 PSAY transform(TSRA->RR_VALOR,"@E 99,999.99")
   @nLin,040 PSAY stod(TSRA->RR_DATAPAG) 
   @nLin,050 PSAY substr(TSRA->RA_NOME,1,40)
   @nLin,093 PSAY TSRA->RA_MAT
   CTT->(dbseek(TSRA->RA_FILIAL+TSRA->RA_CC))
   @nLin,100 PSAY substr(CTT->CTT_DESC01,1,15)
   @nLin,117 PSAY transf(TSRA->RA_CIC,"@R 999.999.999-99")
   nOrdImp++
   nLin++      
   nTotGer := nTotGer + TSRA->RR_VALOR
   nTotBan := nTotBan + TSRA->RR_VALOR   
   _cBanco := substr(TSRA->RA_BCDEPSA,1,3)
   TSRA->(dbskip())
Enddo
nLin++      
@nLin,010 PSAY "Total Banco:" + transform(nTotBan,"@E 99,999,999.99")   
nLin++      
nLin++      
@nLin,010 PSAY "Total Geral:" + transform(nTotGer,"@E 99,999,999.99")

dbSelectArea("TSRA")
dbcloseArea("TSRA")

SET DEVICE TO SCREEN
If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif
MS_FLUSH()
Return



Static Function VldPerg(cPerg)
   _sAlias := Alias()
   dbSelectArea("SX1")
   dbSetOrder(1)
   If !dbSeek(cPerg+"01")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='01'
   sx1->x1_pergunt:='Filial de'
   sx1->x1_variavl:='mv_ch1'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=2
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par01'
   sx1->x1_f3     :='XM0'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"02")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='02'
   sx1->x1_pergunt:='Filial Até'
   sx1->x1_variavl:='mv_ch2'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=2
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par02'
   sx1->x1_f3     :='XM0'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"03")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='03'
   sx1->x1_pergunt:='Centro de Custo de'
   sx1->x1_variavl:='mv_ch3'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=9
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par03'
   sx1->x1_f3     :='CTT'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"04")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='04'
   sx1->x1_pergunt:='Centro de Custo Até'
   sx1->x1_variavl:='mv_ch4'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=9
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par04'
   sx1->x1_f3     :='CTT'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"05")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='05'
   sx1->x1_pergunt:='Matrícula de'
   sx1->x1_variavl:='mv_ch5'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=6
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par05'
   sx1->x1_f3     :='SRA'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"06")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='06'
   sx1->x1_pergunt:='Matrícula Até'
   sx1->x1_variavl:='mv_ch6'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=6
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par06'
   sx1->x1_f3     :='SRA'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"07")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='07'
   sx1->x1_pergunt:='Data De'
   sx1->x1_variavl:='mv_ch7'
   sx1->x1_tipo   :='D'
   sx1->x1_tamanho:=8
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par07'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"08")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='08'
   sx1->x1_pergunt:='Data Até'
   sx1->x1_variavl:='mv_ch8'
   sx1->x1_tipo   :='D'
   sx1->x1_tamanho:=8
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par08'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"09")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='09'
   sx1->x1_pergunt:='Nome de'
   sx1->x1_variavl:='mv_ch9'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=30
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'        
   sx1->x1_var01  :='mv_par09'  
   sx1->x1_valid  :=''
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"10")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='10'
   sx1->x1_pergunt:='Nome Até'
   sx1->x1_variavl:='mv_chA'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=30
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'        
   sx1->x1_var01  :='mv_par10'
   sx1->x1_valid  :=''   
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"11")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='11'
   sx1->x1_pergunt:='Banco de'
   sx1->x1_variavl:='mv_chB'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=8
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'        
   sx1->x1_var01  :='mv_par11'  
   sx1->x1_valid  :=''  
   sx1->x1_f3     :='BA1'      
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"12")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='12'
   sx1->x1_pergunt:='Banco Até'
   sx1->x1_variavl:='mv_chC'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=8
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'        
   sx1->x1_var01  :='mv_par12'
   sx1->x1_valid  :=''
   sx1->x1_f3     :='BA1'   
   sx1->(MsUnlock())

   dbSelectArea(_sAlias)
Return









