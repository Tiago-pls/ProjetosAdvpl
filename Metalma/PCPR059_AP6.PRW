#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/03/01
#IFNDEF WINDOWS
        #DEFINE PSAY SAY
#ENDIF

User Function PCPR059()        // incluido pelo assistente de conversao do AP5 IDE em 14/03/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("TITULO,CDESC1,CDESC2,CDESC3,ARETURN,ALINHA")
SetPrvt("NOMEPROG,NLASTKEY,TAMANHO,CPERG,M_MAQUINA,M_TEOR")
SetPrvt("M_REFU,M_REAL,M_PERCEN,M_TEORT,M_REFUT,M_REALT")
SetPrvt("M_CONT,LEND,CBTXT,CBCONT,CABEC1,CSTRING")
SetPrvt("LI,M_PAG,WNREL,NTOTREGS,NMULT,NPOSANT")
SetPrvt("NPOSATU,NPOSCNT,CSAV20,CSAV7,CABEC2,M_FLAG")
SetPrvt("M_LI,")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PCPR059  ³ Autor ³ Aurea Fraga           ³ Data ³ 27/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio de Producao (pedido x produzido)                 ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#IFNDEF WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 14/03/01 ==>         #DEFINE PSAY SAY
#ENDIF
SET CENTURY ON
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Todas as variaveis PRIVATE.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo       :="RELATORIO DE PRODUTIVIDADE POR DATA"
cDesc1       :="Emiss„o da Rela‡„o da Produtividade por Data"
cDesc2       :=" "
cDesc3       :=" "
aReturn      :={ "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
aLinha       :={ }
nomeprog     :="PCPR059"
nlastkey     :=0
tamanho      :="M"
cPerg        :="PCPR13"
m_maquina    :=space(06) 
m_teor       := 0
m_refu       := 0
m_real       := 0
m_percen     := 0
m_teort      := 0
m_refut      := 0
m_realt      := 0
m_cont       := 0      
m_qtdmat     := 0
m_matter     := 0
m_qtdtot     := 0   
m_totmat     := 0  
m_refup      := 0
m_teorp      := 0
m_realp      := 0  
m_teoricototal:=0
m_refugototal:=0
m_matprima   := space(15)   
m_requisitado:= 0    
m_totrequi   := 0
m_leitura    := "S"   
m_tipo2      := "S" 
m_teor       := 0
m_refu       := 0
m_real       := 0
m_teorg      := 0
m_refug      := 0
m_realg      := 0
m_contg      := 0    
m_horareal   := 0
m_minreal    := 0
m_horateor   := 0
m_minteor    := 0
m_horarpe    := 0
m_minrpe     := 0
m_horatpe    := 0
m_mintpe     := 0
m_hrrealt    := 0
m_mnrealt    := 0
m_hrteort    := 0
m_mnteort    := 0
m_tpteorico  := 0  
m_hreat      := 0
m_hrtnt      := 0    
m_htempopar  := space(05)
m_mtempopar  := space(05)
m_thpar      := 0
m_tmpar      := 0
m_thpartot   := 0
m_tmpartot   := 0
m_op         := space(13)
m_primeira   := "S"
lEnd         :=.F.
lAbortPrint  := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis Utilizadas para Impressao de Cabecalho e Rodape                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    :=space(10)
cbcont   :=0
cabec1   :="O.P.       Cliente                      Producao      Moido Gerado            Total        %  T.Real T.Teor.  % Prod."
cString  :="SH6"
li       :=80
m_pag    :=1
wnrel    :="PCPR059"  // nome default do relatorio em disco
nTotregs := nMult    := nPosAnt  := nPosAtu  := nPosCnt  := 0 // Regua
cSav20   := cSav7 := ' ' // Regua
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajuste dos Parametros de Impressao via Funcao SETPRINT                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("PCPR13",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Utilizadas para parametros                                     ³
//³mv_par01          Da Data de Producao                                     ³
//³mv_par02          Ate a Data de Producao                                  ³
//³mv_par03          Cliente de                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel   :=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,tamanho)

If nLastKey == 27
   Set Filter to
   Return
Endif

#IFDEF WINDOWS
        RptStatus({|| fRC_Imp()})  //-- Chamada do Relatorio.// Substituido pelo assistente de conversao do AP5 IDE em 14/03/01 ==>         RptStatus({|| Execute(fRC_Imp)})  //-- Chamada do Relatorio.
#ELSE
        fRC_Imp()
#ENDIF

Return Nil

// Substituido pelo assistente de conversao do AP5 IDE em 14/03/01 ==> Function fRC_Imp
Static Function fRC_Imp()

If LastKey() == 27 
   #IFNDEF WINDOWS
           restscreen(3,0,24,79,cSavScr1)
   #ENDIF        
   return
Endif   
aStru := {}

AADD(aStru,{"CLIENTE","C",6,0})
AADD(aStru,{"NREDUZ","C",20,0})
AADD(aStru,{"PRODUTO","C",15,0})
AADD(aStru,{"DESCPRO","C",30,0})
AADD(aStru,{"OP","C",13,0})
AADD(aStru,{"TEORICO","N",13,2})
AADD(aStru,{"REFUGO","N",13,2})
AADD(aStru,{"QUANT","N",13,2})
AADD(aStru,{"MAQUINA","C",6,0})
AADD(aStru,{"TIPO","C",1,0})
AADD(aStru,{"TEMPO","C",5,0})
AADD(aStru,{"TPTEORICO","C",5,0})
AADD(aStru,{"ENCER","C",1,0})
cArqTrab := CriaTrab(aStru,.T.)
Dbusearea(.t.,,cArqTrab,"MAX",.f.,.f.)
cArqInd := CriaTrab("",.f.)
cChave  := "OP + PRODUTO"
Indregua("MAX",cArqInd,cChave,,,"Gerando Arquivo de Trabalho...")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Aceita Parametros e faz Ajustes necessarios                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetDefault(aReturn,cString)
dbSelectArea("SD3")
dbSetOrder(1)
Set Filter TO D3_EMISSAO >= mv_par01 - 1 .and. D3_EMISSAO <= mv_par02 + 1 .and. D3_FILIAL == ALLTRIM(SM0->M0_CODFIL)
dbGoTop()
dbSelectArea("SZ7")
dbSetOrder(2)
Set Filter TO Z7_DATA >= mv_par01 - 1 .and. Z7_DATA <= mv_par02 + 1 .and. Z7_FILIAL == ALLTRIM(SM0->M0_CODFIL) 
dbGoTop()
dbSelectArea("SH6")
dbSetOrder(1)
Set Filter TO H6_DATAINI >= mv_par01 .and. H6_DATAINI <= mv_par02 + 1 .and.;
              H6_FILIAL == ALLTRIM(SM0->M0_CODFIL) .and. H6_RECURSO >= mv_par05 .and. H6_RECURSO <= mv_par06

dbGoTop()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Regua Processamento                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(RecCount()) //-- Total de elementos da regua.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis Utilizadas na Barra de Espaco                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cabec2  :="                                                 Do Dia "+Dtoc(mv_par01)+ " ate o dia " + Dtoc(mv_par02)
m_flag  :="N"
m_maquina := H6_RECURSO 

while !eof() 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Movimenta Regua Processamento                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    IncRegua()  //-- Move a regua.

    If SH6->H6_FILIAL <> ALLTRIM(SM0->M0_CODFIL)
       Exit
    Endif   
    If SH6->H6_DATAINI = mv_par01 .and. SH6->H6_HORAINI < "06:00"
       dbSelectArea("SH6")
       dbSkip()
       Loop
    Endif    
    If SH6->H6_DATAINI == mv_par02 + 1 .and. SH6->H6_HORAINI >= "06:00"
       dbSelectArea("SH6")
       dbSkip()
       Loop
    Endif    
    If Subs(SH6->H6_OP,1,6) == space(06)
       dbSkip()
       Loop
    Endif   

    dbSelectArea("SC6")
    dbSetOrder(1)
    dbSeek(xFilial("SC6") + Subs(SH6->H6_OP,1,6))
    If Found()
       If SC6->C6_CLI < mv_par03 .or. SC6->C6_CLI > mv_par04 
          dbSelectArea("SH6")
          dbSkip()   
          Loop
       Endif   
       dbSelectArea("SA1")
       dbSetOrder(1)
       dbSeek(xFilial("SA1") + SC6->C6_CLI)
       If Found()
          m_codcli := SC6->C6_CLI
          m_nomecli := SA1->A1_NREDUZ 
       Else
          m_codcli := space(06)
          m_nomecli := space(20)
//          dbSelectArea("SH6")
//          dbSkip()
//          Loop
       Endif
    Else
       dbSelectArea("SC6")
       dbSetOrder(7)
       dbSeek(xFilial("SC6") + Subs(SH6->H6_OP,1,6))
       If Found()
          If SC6->C6_CLI < mv_par03 .or. SC6->C6_CLI > mv_par04 
             dbSelectArea("SH6")
             dbSkip()   
             Loop
          Endif   
          dbSelectArea("SA1")
          dbSetOrder(1)
          dbSeek(xFilial("SA1") + SC6->C6_CLI)
          If Found()
             m_codcli := SC6->C6_CLI
             m_nomecli := SA1->A1_NREDUZ 
          Else
             m_codcli := space(06)
             m_nomecli := space(20)
          Endif
       Else   
          m_codcli := space(06)
          m_nomecli := space(20)
       Endif   
    Endif         
    dbSelectArea("SH6")
    #IFNDEF WINDOWS
        Inkey()
        If Lastkey() == 286
           lEnd := .T.
        EndIf   
    #ELSE
                
         If lAbortPrint
         @Prow()+1,0 PSAY "CANCELADO PELO OPERADOR"
         Exit
         EndIF
    #ENDIF              

    dbSelectArea("SB1")
    dbSetOrder(1)
    dbSeek(xFilial("SB1") + SH6->H6_PRODUTO)
    If Subs(SB1->B1_GRUPO,1,1) == "3" .and. SB1->B1_UM == "PC"
       m_teor  := SH6->H6_QTDPROD * SB1->B1_PESO
//       m_refu  := SH6->H6_QTDPERD * SB1->B1_PESO
       m_refu  := SH6->H6_QTDPERD
    ElseIf Subs(SB1->B1_GRUPO,1,1) == "3" .and. SB1->B1_UM == "KG"
       m_teor  := SH6->H6_QTDPROD
       m_refu  := SH6->H6_QTDPERD
    ElseIf Subs(SB1->B1_GRUPO,1,1) <> "3" .and. SB1->B1_UM == "KG"
       m_teor  := SH6->H6_QTDPROD
       m_refu  := SH6->H6_QTDPERD
    ElseIf Subs(SB1->B1_GRUPO,1,1) <> "3" .and. SB1->B1_UM <> "KG"
       m_teor  := SH6->H6_QTDPROD * SB1->B1_CONV
//       m_refu  := SH6->H6_QTDPERD * SB1->B1_CONV
       m_refu  := SH6->H6_QTDPERD
    Endif  
    m_recurso := SH6->H6_RECURSO   
    dbSelectArea("SG2")
    dbSetOrder(1)
    dbSeek(xFilial("SG2") + SH6->H6_PRODUTO)   
    m_tpteorico := m_hora := m_min := 0
    If Found()
       While SG2->G2_PRODUTO == SH6->H6_PRODUTO
          If SG2->G2_RECURSO == SH6->H6_RECURSO
             m_tpteorico := m_teor / SG2->G2_LOTEPAD   
             Exit
          Else  
             dbSkip()
             Loop
          Endif   
       End  
       m_hora := int(m_tpteorico)
       m_min  := m_tpteorico - m_hora
       m_minuto := STR(m_min,4,2)
       m_minuto := Substr(m_minuto,3,2)
       m_min  := (Val(m_minuto) * 60) / 100
       m_min := int(m_min)
       If m_min >= 60
          m_hora := m_hora + 1
          m_min := m_min - 60
       Endif
       If m_hora < 10
          m_hora := "0" + STR(m_hora,1)
       Else 
          m_hora := STR(m_hora,2)
       Endif
       If m_min < 10
          m_min := "0" + STR(m_min,1)
       Else 
          m_min := STR(m_min,2)
       Endif
       m_horamin := m_hora + ":" + m_min
    Else
       m_horamin := "00:00" 
    Endif            
    Dbselectarea("MAX")
    Append Blank
    Replace OP With SH6->H6_OP, PRODUTO With SH6->H6_PRODUTO, TIPO With "1",; 
            MAQUINA With SH6->H6_RECURSO, REFUGO WITH m_refu, TEORICO With m_teor,;
            CLIENTE With m_codcli, NREDUZ With m_nomecli,;
            DESCPRO With SB1->B1_DESC, TEMPO With SH6->H6_TEMPO, ENCER With "S",;
            TPTEORICO With m_horamin
//novo
   If SH6->H6_OP <> m_op
       m_op := SH6->H6_OP  
       dbSelectArea("SD3")
       dbSeek(xFilial("SD3") + m_op)
       m_qtdmat := 0
       While ALLTRIM(SD3->D3_OP) == ALLTRIM(m_op)
          If Subs(SD3->D3_COD,1,1) > "9" .or. Subs(SD3->D3_CF,1,1) == "P" .or. ;
             SD3->D3_ESTORNO == "S" .or. Subs(SD3->D3_CF,1,1) =="E"
             dbSelectArea("SD3")
             dbSkip()
             Loop
          Endif                       
          dbSelectArea("SC5")
          dbSetOrder(1)
          dbSeek(xFilial("SC5") + Subs(m_op,1,6))
          dbSelectArea("SA1")
          dbSetOrder(1)
          dbSeek(xFilial("SA1") + SC5->C5_CLIENTE)
          dbSelectArea("SB1")
          dbSetOrder(1)
          dbSeek(xFilial("SB1") + SD3->D3_COD)

          If Subs(SD3->D3_CF,1,2) == "RE" 
             m_qtdmat := SD3->D3_QUANT
          Else   
             m_qtdmat := (-1) * SD3->D3_QUANT
          Endif   
          Dbselectarea("MAX")
          DbSeek(SUBS(SD3->D3_OP,13) + SD3->D3_COD)
          If !Found()
              Append Blank
              Replace OP With SD3->D3_OP, PRODUTO With SD3->D3_COD, TIPO With "2",; 
                      QUANT WITH m_qtdmat, CLIENTE With SC5->C5_CLIENTE, ;
                      MAQUINA With m_recurso, NREDUZ With SA1->A1_NREDUZ,;
                      DESCPRO With SB1->B1_DESC
          Else           
             Replace QUANT WITH QUANT + m_qtdmat
          Endif    
          dbSelectArea("SD3")
          dbSkip()
          Loop
       End   

       dbSelectArea("SZ7")
       dbSeek(xFilial("SZ7") + m_op)
       m_matter := 0
       While SZ7->Z7_OP == m_op
          dbSelectArea("SC5")
          dbSetOrder(1)
          dbSeek(xFilial("SC5") + Subs(m_op,1,6))
          dbSelectArea("SA1")
          dbSetOrder(1)
          dbSeek(xFilial("SA1") + SC5->C5_CLIENTE)
          dbSelectArea("SB1")
          dbSetOrder(1)
          dbSeek(xFilial("SB1") + SZ7->Z7_PRODUTO)
          Dbselectarea("MAX")
          DbSeek(SZ7->Z7_OP + SZ7->Z7_PRODUTO)
          If !Found()
              Append Blank
              Replace OP With SZ7->Z7_OP, PRODUTO With SZ7->Z7_PRODUTO, TIPO With "2", ;
                      QUANT WITH SZ7->Z7_QUANT, CLIENTE With SC5->C5_CLIENTE, ;
                      NREDUZ With SA1->A1_NREDUZ, DESCPRO With SB1->B1_DESC,;
                      MAQUINA With m_recurso
          Else           
              Replace QUANT WITH QUANT + SZ7->Z7_QUANT
          Endif    
          dbSelectArea("SZ7")
          dbSkip()
          Loop
       End   
    Endif  
//novo    
    dbSelectArea("SH6")
    dbSkip()
End      
dbSelectArea("SH6")
dbSetOrder(5)
dbGoTop()
dbSelectArea("MAX")
Set Filter To                 
dbGoTop()
cArqInd2 := criatrab("",.f.)
cChave2  := "MAQUINA + CLIENTE + OP + TIPO + ENCER"
Indregua("MAX",cArqInd2,cChave2,,,"Selecionando Registros...")
m_maq := MAQUINA
m_cliente := CLIENTE                
m_op := OP
m_prim := "S"      
m_teor := m_refu := m_real := m_hreat := m_hrtnt := 0
m_tipoant := "1"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressao dos Dados                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !eof()
    If li >= 60
       Cabec(titulo,cabec2,nomeprog,tamanho)
       @ 10,001 PSAY cabec1
       li := 12
    Endif
    If m_prim == "S"
       m_cont := m_cont + 1
       @ li,001 PSAY MAQUINA
       li := li + 1
       m_prim := "N"
       @ li,012 PSAY Subs(PRODUTO,1,8) + "-" + DESCPRO     
       li := li + 1
       @ li,001 PSAY Subs(OP,1,6) + "/" + Subs(OP,7,2) 
       @ li,012 PSAY NREDUZ
       @ li,034 PSAY TEORICO Picture "@E 999,999,999.999"
       @ li,052 PSAY REFUGO Picture "@E 999,999,999.999"
       @ li,069 PSAY TEORICO + REFUGO Picture "@E 999,999,999.999"
       @ li,086 PSAY (REFUGO / (TEORICO + REFUGO)) * 100 Picture "@E 9999.99"
       @ li,096 PSAY TEMPO   
       @ li,104 PSAY TPTEORICO 
       m_hrr  := Substr(TEMPO,1,2)
       m_mir  := Substr(TEMPO,4,2)
       m_hrrn := Val(m_hrr)
       m_mirn := Val(m_mir)
       m_hrrn := (m_hrrn * 60)
       m_hrea := m_hrrn + m_mirn
       m_hrt  := Substr(TPTEORICO,1,2)
       m_mit  := Substr(TPTEORICO,4,2)
       m_hrtn := Val(m_hrt)
       m_mitn := Val(m_mit)
       m_hrtn := (m_hrtn * 60)
       m_hteo := m_hrtn + m_mitn
       m_prod := (m_hteo / m_hrea) * 100
       @ li,113 PSAY m_prod Picture "@E 999.99"
       li := li + 1
       m_teor     := m_teor  + TEORICO
       m_refu     := m_refu  + REFUGO
       m_real     := m_real  + TEORICO + REFUGO
       m_teort    := m_teort + TEORICO
       m_refut    := m_refut + REFUGO
       m_realt    := m_realt + TEORICO + REFUGO  
       m_hreat := m_hreat + m_hrea
       m_hrtnt := m_hrtnt + m_hteo
       m_trhora   := Substr(TEMPO,1,2)
       m_trmin    := Substr(TEMPO,4,2) 
       m_horareal := m_horareal + val(m_trhora)
       m_minreal  := m_minreal  + val(m_trmin) 
       If m_minreal >= 60
          m_horareal := m_horareal + 1
          m_minreal  := m_minreal - 60
       Endif   
       m_trhorat  := Substr(TPTEORICO,1,2)
       m_trmint   := Substr(TPTEORICO,4,2) 
       m_horateor := m_horateor + val(m_trhorat)
       m_minteor  := m_minteor  + val(m_trmint) 
       If m_minteor >= 60
          m_horateor := m_horateor + 1
          m_minteor  := m_minteor - 60
       Endif                                 
       m_horarpe := m_horarpe + val(m_trhora)
       m_minrpe  := m_minrpe  + val(m_trmin) 
       If m_minrpe >= 60
          m_horarpe := m_horarpe + 1
          m_minrpe  := m_minrpe - 60
       Endif   
       m_horatpe := m_horatpe + val(m_trhorat)
       m_mintpe  := m_mintpe  + val(m_trmint) 
       If m_mintpe >= 60
          m_horatpe := m_horatpe + 1
          m_mintpe  := m_mintpe - 60
       Endif                                 
       m_tipoant := "1"
       m_maq := MAQUINA
       m_op := OP
       m_cliente := CLIENTE
    Else   
       If TIPO == "1"
          m_cont := m_cont + 1
       Endif   
       If m_maq <> MAQUINA
          @ li,015 PSAY "Total Produzido :"
          @ li,034 PSAY m_teor Picture "@E 999,999,999.999"
          @ li,052 PSAY m_refu Picture "@E 999,999,999.999"
          @ li,069 PSAY m_real Picture "@E 999,999,999.999"   
          @ li,086 PSAY (m_refu / (m_teor + m_refu)) * 100 Picture "@E 9999.99"
          If m_horarpe < 10 
             @ li,096 PSAY "000"
             @ li,099 PSAY m_horarpe Picture "9"
          ElseIf m_horarpe >= 10 .and. m_horarpe < 100
             @ li,096 PSAY "00"
             @ li,098 PSAY m_horarpe Picture "99"
          ElseIf m_horarpe >= 100 .and. m_horarpe < 1000
             @ li,096 PSAY "0"
             @ li,097 PSAY m_horarpe Picture "999"
          Else
             @ li,096 PSAY m_horarpe Picture "9999"
          Endif   
          @ li,100 PSAY ":"
          If m_minrpe < 10
             @ li,101 PSAY "0"
             @ li,102 PSAY m_minrpe Picture "9"
          Else
             @ li,101 PSAY m_minrpe Picture "99"
          Endif   

          If m_horatpe < 10 
             @ li,104 PSAY "000"
             @ li,107 PSAY m_horatpe Picture "9"
          ElseIf m_horatpe >= 10 .and. m_horatpe < 100
             @ li,104 PSAY "00"
             @ li,106 PSAY m_horatpe Picture "99"
          ElseIf m_horatpe >= 100 .and. m_horatpe < 1000
             @ li,104 PSAY "0"
             @ li,105 PSAY m_horatpe Picture "999"
          Else
             @ li,104 PSAY m_horatpe Picture "9999"
          Endif   
          @ li,108 PSAY ":"
          If m_mintpe < 10
             @ li,109 PSAY "0"
             @ li,110 PSAY m_mintpe Picture "9"
          Else
             @ li,109 PSAY m_mintpe Picture "99"
          Endif         
          @ li,113 PSAY (m_hrtnt / m_hreat) * 100 Picture "@E 999.99"
          li := li + 1
          m_kgh := (m_horarpe * 60) + m_minrpe
          m_kgth := m_kgh /60
          @ li,112 PSAY m_teor / m_kgth Picture "@E 9999.99"             
          @ li,120 PSAY "KG/H"
          m_horarpe := m_minrpe := m_horatpe := m_mintpe := 0
          li := li + 2
          m_existeordemp := "N"
          dbSelectArea("SH6")
          dbSeek(xFilial("SH6") + m_op)
          If Found()
             m_thpar := m_tmpar := 0
             While SH6->H6_ORDEMP == m_op   
                If SH6->H6_DATAINI <= mv_par01 .and. SH6->H6_HORAINI < "06:00"
                   dbSelectArea("SH6")
                   dbSkip()
                   Loop
                Endif    
                If SH6->H6_DATAINI == mv_par02 + 1 .and. SH6->H6_HORAINI >= "06:00"
                   dbSelectArea("SH6")
                   dbSkip()
                   Loop
                Endif          
                m_existeordemp := "S"
                DbSelectArea('SX5')
                DbSetOrder(1)
                Dbseek(xFilial('SX5')+'44'+SH6->H6_MOTIVO)  
                @ li,001 PSAY "PARADA DE MAQUINA-->"
                @ li,021 PSAY SX5->X5_DESCRI
                @ li,096 PSAY SH6->H6_TEMPO 
                m_htempopar := Substr(SH6->H6_TEMPO,1,2)
                m_mtempopar := Substr(SH6->H6_TEMPO,4,2)
                m_thpar := m_thpar + val(m_htempopar) 
                m_tmpar := m_tmpar + val(m_mtempopar) 
                If m_tmpar > 60
                   m_tmpar := m_tmpar - 60
                   m_thpar := m_thpar + 1
                Endif   
                li := li + 1         
                dbSelectArea("SH6")
                dbSkip()
                Loop
             End
             If m_existeordemp == "S"
                If m_thpar < 10 
                   @ li,096 PSAY "000"
                   @ li,099 PSAY m_thpar Picture "9"
                ElseIf m_thpar >= 10 .and. m_thpar < 100
                   @ li,096 PSAY "00"
                   @ li,098 PSAY m_thpar Picture "99"
                ElseIf m_thpar >= 100 .and. m_thpar < 1000
                   @ li,096 PSAY "0"
                   @ li,097 PSAY m_thpar Picture "999"
                Else
                   @ li,096 PSAY m_thpar Picture "9999"
                Endif   
                @ li,100 PSAY ":"
                If m_tmpar < 10
                   @ li,101 PSAY "0"
                   @ li,102 PSAY m_tmpar Picture "9"
                Else
                   @ li,101 PSAY m_tmpar Picture "99"
                Endif   
                li := li + 2
                m_thpartot := m_thpartot + m_thpar
                m_tmpartot := m_tmpartot + m_tmpar
                If m_tmpartot > 60
                   m_tmpartot := m_tmpartot - 60
                   m_thpartot := m_thpartot + 1
                Endif   
             Endif
          Endif      
          dbSelectArea("MAX")
          @ li,001 PSAY "Total " + m_maq
          @ li,015 PSAY m_cont Picture "@E 99,999"
          @ li,034 PSAY m_teort Picture "@E 999,999,999.999"
          @ li,052 PSAY m_refut Picture "@E 999,999,999.999"
          @ li,069 PSAY m_realt Picture "@E 999,999,999.999"
          @ li,086 PSAY (m_refut / (m_teort + m_refut)) * 100 Picture "@E 9999.99"
          m_teoricototal := m_teort + m_teoricototal
          m_refugototal := m_refut + m_refugototal
          If m_horareal < 10 
             @ li,096 PSAY "000"
             @ li,099 PSAY m_horareal Picture "9"
          ElseIf m_horareal >= 10 .and. m_horareal < 100
             @ li,096 PSAY "00"
             @ li,098 PSAY m_horareal Picture "99"
          ElseIf m_horareal >= 100 .and. m_horareal < 1000
             @ li,096 PSAY "0"
             @ li,097 PSAY m_horareal Picture "999"
          Else
             @ li,096 PSAY m_horareal Picture "9999"
          Endif   
          @ li,100 PSAY ":"
          If m_minreal < 10
             @ li,101 PSAY "0"
             @ li,102 PSAY m_minreal Picture "9"
          Else
             @ li,101 PSAY m_minreal Picture "99"
          Endif   

          If m_horateor < 10 
             @ li,104 PSAY "000"
             @ li,107 PSAY m_horateor Picture "9"
          ElseIf m_horateor >= 10 .and. m_horateor < 100
             @ li,104 PSAY "00"
             @ li,106 PSAY m_horateor Picture "99"
          ElseIf m_horateor >= 100 .and. m_horateor < 1000
             @ li,104 PSAY "0"
             @ li,105 PSAY m_horateor Picture "999"
          Else
             @ li,104 PSAY m_horateor Picture "9999"
          Endif   
          @ li,108 PSAY ":"
          If m_minteor < 10
             @ li,109 PSAY "0"
             @ li,110 PSAY m_minteor Picture "9"
          Else
             @ li,109 PSAY m_minteor Picture "99"
          Endif         
          m_prodreal := (m_horareal * 60) + m_minreal
          m_prodteor := (m_horateor * 60) + m_minteor
          @ li,113 PSAY ((m_prodteor / m_prodreal) * 100) Picture "@E 999.99"
          li := li + 1
          If m_thpartot < 10 
             @ li,096 PSAY "000"
             @ li,099 PSAY m_thpartot Picture "9"
          ElseIf m_thpartot >= 10 .and. m_thpartot < 100
             @ li,096 PSAY "00"
             @ li,098 PSAY m_thpartot Picture "99"
          ElseIf m_thpartot >= 100 .and. m_thpartot < 1000
             @ li,096 PSAY "0"
             @ li,097 PSAY m_thpartot Picture "999"
          Else
             @ li,096 PSAY m_thpartot Picture "9999"
          Endif   
          @ li,100 PSAY ":"
          If m_tmpartot < 10
             @ li,101 PSAY "0"
             @ li,102 PSAY m_tmpartot Picture "9"
          Else
             @ li,101 PSAY m_tmpartot Picture "99"
          Endif   
          li := li + 2                   
          m_thpartot := m_tmpartot := 0
          m_contg := m_contg + m_cont
          m_teorg := m_teorg + m_teort
          m_refug := m_refug + m_refut
          m_realg := m_realg + m_realt 
          @ li,001 PSAY Replicate("-",110)  
          m_hrrealt := m_hrrealt + m_horareal 
          m_mnrealt  := m_mnrealt  + m_minreal 
          m_hrteort := m_hrteort + m_horateor 
          m_mnteort  := m_mnteort  + m_minteor 
          If m_mnrealt >= 60
             m_hrrealt := m_hrrealt + 1
             m_mnrealt  := m_mnrealt - 60
          Endif   
          If m_mnteort >= 60
             m_hrteort := m_hrteort + 1
             m_mnteort  := m_mnteort - 60
          Endif   
          li = li + 1
          @ li,001 PSAY MAQUINA
          m_cont := m_teort := m_refut := m_realt := m_teor := m_refu := m_real := m_totmat := 0
          m_horareal := m_minreal := m_horateor := m_minteor := m_hreat := m_hrtnt := 0
          li := li + 1                         
          @ li,012 PSAY Subs(PRODUTO,1,8) + "-" + DESCPRO     
          li := li + 1
          @ li,001 PSAY Subs(OP,1,6) + "/" + Subs(OP,7,2) 
          @ li,012 PSAY NREDUZ
          @ li,034 PSAY TEORICO Picture "@E 999,999,999.999"
          @ li,052 PSAY REFUGO Picture "@E 999,999,999.999"
          @ li,069 PSAY TEORICO + REFUGO Picture "@E 999,999,999.999"
          @ li,086 PSAY (REFUGO / (TEORICO + REFUGO)) * 100 Picture "@E 9999.99"
          @ li,096 PSAY TEMPO
          @ li,104 PSAY TPTEORICO
          m_hrr  := Substr(TEMPO,1,2)
          m_mir  := Substr(TEMPO,4,2)
          m_hrrn := Val(m_hrr)
          m_mirn := Val(m_mir)
          m_hrrn := (m_hrrn * 60)
          m_hrea := m_hrrn + m_mirn
          m_hrt  := Substr(TPTEORICO,1,2)
          m_mit  := Substr(TPTEORICO,4,2)
          m_hrtn := Val(m_hrt)
          m_mitn := Val(m_mit)
          m_hrtn := (m_hrtn * 60)
          m_hteo := m_hrtn + m_mitn
          m_prod := (m_hteo / m_hrea) * 100
          @ li,113 PSAY m_prod Picture "@E 999.99"
          li := li + 1
          m_teor  := m_teor + TEORICO
          m_refu  := m_refu + REFUGO
          m_real  := m_real + TEORICO + REFUGO
          m_hreat := m_hreat + m_hrea
          m_hrtnt := m_hrtnt + m_hteo
          m_teort := m_teort + TEORICO
          m_refut := m_refut + REFUGO
          m_realt := m_realt + TEORICO + REFUGO
          m_trhora := Substr(TEMPO,1,2)
          m_trmin  := Substr(TEMPO,4,2) 
          m_horareal := m_horareal + val(m_trhora)
          m_minreal := m_minreal + val(m_trmin) 
          If m_minreal >= 60
             m_horareal := m_horareal + 1
             m_minreal  := m_minreal - 60
          Endif   
          m_trhorat := Substr(TPTEORICO,1,2)
          m_trmint  := Substr(TPTEORICO,4,2) 
          m_horateor := m_horateor + val(m_trhorat)
          m_minteor := m_minteor + val(m_trmint) 
          If m_minteor >= 60
             m_horateor := m_horateor + 1
             m_minteor  := m_minteor - 60
          Endif   
          m_horarpe := m_horarpe + val(m_trhora)
          m_minrpe  := m_minrpe  + val(m_trmin) 
          If m_minrpe >= 60
             m_horarpe := m_horarpe + 1
             m_minrpe  := m_minrpe - 60
          Endif   
          m_horatpe := m_horatpe + val(m_trhorat)
          m_mintpe  := m_mintpe  + val(m_trmint) 
          If m_mintpe >= 60
             m_horatpe := m_horatpe + 1
             m_mintpe  := m_mintpe - 60
          Endif                                 
          m_maq := MAQUINA
          m_op := OP
          m_cliente := CLIENTE
       Else
          If m_op == OP
             @ li,001 PSAY Subs(OP,1,6) + "/" + Subs(OP,7,2) 
             @ li,012 PSAY NREDUZ
             @ li,034 PSAY TEORICO Picture "@E 999,999,999.999"
             @ li,052 PSAY REFUGO Picture "@E 999,999,999.999"
             @ li,069 PSAY TEORICO + REFUGO Picture "@E 999,999,999.999"
             @ li,086 PSAY (REFUGO / (TEORICO + REFUGO)) * 100 Picture "@E 9999.99"
             @ li,096 PSAY TEMPO
             @ li,104 PSAY TPTEORICO
             m_hrr  := Substr(TEMPO,1,2)
             m_mir  := Substr(TEMPO,4,2)
             m_hrrn := Val(m_hrr)
             m_mirn := Val(m_mir)
             m_hrrn := (m_hrrn * 60)
             m_hrea := m_hrrn + m_mirn
             m_hrt  := Substr(TPTEORICO,1,2)
             m_mit  := Substr(TPTEORICO,4,2)
             m_hrtn := Val(m_hrt)
             m_mitn := Val(m_mit)
             m_hrtn := (m_hrtn * 60)
             m_hteo := m_hrtn + m_mitn
             m_prod := (m_hteo / m_hrea) * 100
             @ li,113 PSAY m_prod Picture "@E 999.99"
             li := li + 1
             m_teor  := m_teor + TEORICO
             m_refu  := m_refu + REFUGO
             m_real  := m_real + TEORICO + REFUGO
             m_hreat := m_hreat + m_hrea
             m_hrtnt := m_hrtnt + m_hteo
             m_teort := m_teort + TEORICO
             m_refut := m_refut + REFUGO
             m_realt := m_realt + TEORICO + REFUGO
             m_trhora := Substr(TEMPO,1,2)
             m_trmin  := Substr(TEMPO,4,2) 
             m_horareal := m_horareal + val(m_trhora)
             m_minreal := m_minreal + val(m_trmin) 
             If m_minreal >= 60
                m_horareal := m_horareal + 1
                m_minreal  := m_minreal - 60
             Endif   
             m_trhorat := Substr(TPTEORICO,1,2)
             m_trmint  := Substr(TPTEORICO,4,2) 
             m_horateor := m_horateor + val(m_trhorat)
             m_minteor := m_minteor + val(m_trmint) 
             If m_minteor >= 60
                m_horateor := m_horateor + 1
                m_minteor  := m_minteor - 60
             Endif   
             m_horarpe := m_horarpe + val(m_trhora)
             m_minrpe  := m_minrpe  + val(m_trmin) 
             If m_minrpe >= 60
                m_horarpe := m_horarpe + 1
                m_minrpe  := m_minrpe - 60
             Endif   
             m_horatpe := m_horatpe + val(m_trhorat)
             m_mintpe  := m_mintpe  + val(m_trmint) 
             If m_mintpe >= 60
                m_horatpe := m_horatpe + 1
                m_mintpe  := m_mintpe - 60
             Endif                                 
          Else
             @ li,015 PSAY "Total Produzido :"
             @ li,034 PSAY m_teor Picture "@E 999,999,999.999"
             @ li,052 PSAY m_refu Picture "@E 999,999,999.999"
             @ li,069 PSAY m_real Picture "@E 999,999,999.999"
             @ li,086 PSAY (m_refu / (m_teor + m_refu)) * 100 Picture "@E 9999.99"
             If m_horarpe < 10 
                @ li,096 PSAY "000"
                @ li,099 PSAY m_horarpe Picture "9"
             ElseIf m_horarpe >= 10 .and. m_horarpe < 100
                @ li,096 PSAY "00"
                @ li,098 PSAY m_horarpe Picture "99"
             ElseIf m_horarpe >= 100 .and. m_horarpe < 1000
                @ li,096 PSAY "0"
                @ li,097 PSAY m_horarpe Picture "999"
             Else
                @ li,096 PSAY m_horarpe Picture "9999"
             Endif   
             @ li,100 PSAY ":"
             If m_minrpe < 10
                @ li,101 PSAY "0"
                @ li,102 PSAY m_minrpe Picture "9"
             Else
                @ li,101 PSAY m_minrpe Picture "99"
             Endif   
             If m_horatpe < 10 
                @ li,104 PSAY "000"
                @ li,107 PSAY m_horatpe Picture "9"
             ElseIf m_horatpe >= 10 .and. m_horatpe < 100
                @ li,104 PSAY "00"
                @ li,106 PSAY m_horatpe Picture "99"
             ElseIf m_horatpe >= 100 .and. m_horatpe < 1000
                @ li,104 PSAY "0"
                @ li,105 PSAY m_horatpe Picture "999"
             Else
                @ li,104 PSAY m_horatpe Picture "9999"
             Endif   
             @ li,108 PSAY ":"
             If m_mintpe < 10
                @ li,109 PSAY "0"
                @ li,110 PSAY m_mintpe Picture "9"
             Else
                @ li,109 PSAY m_mintpe Picture "99"
             Endif         
             @ li,113 PSAY (m_hrtnt / m_hreat) * 100 Picture "@E 999.99"
             li := li + 1
             m_kgh := (m_horarpe * 60) + m_minrpe
             m_kgth := m_kgh /60
             @ li,112 PSAY m_teor / m_kgth Picture "@E 9999.99"             
             @ li,120 PSAY "KG/H"
             m_horarpe := m_minrpe := m_horatpe := m_mintpe := 0
             m_teor := m_refu := m_real :=0
             li := li + 2
             dbSelectArea("SH6")
             dbSeek(xFilial("SH6") + m_op)
             m_existeordemp := "N"
             If Found()
                m_thpar := m_tmpar := 0
                While SH6->H6_ORDEMP == m_op   
                   If SH6->H6_DATAINI <= mv_par01 .and. SH6->H6_HORAINI < "06:00"
                      dbSelectArea("SH6")
                      dbSkip()
                      Loop
                   Endif    
                   If SH6->H6_DATAINI == mv_par02 + 1 .and. SH6->H6_HORAINI >= "06:00"
                      dbSelectArea("SH6")
                      dbSkip()
                      Loop
                   Endif    
                   m_existeordemp := "S"
                   DbSelectArea('SX5')
                   DbSetOrder(1)
                   Dbseek(xFilial('SX5')+'44'+SH6->H6_MOTIVO)  
                   @ li,001 PSAY "PARADA DE MAQUINA-->"
                   @ li,021 PSAY SX5->X5_DESCRI
                   @ li,096 PSAY SH6->H6_TEMPO 
                   m_htempopar := Substr(SH6->H6_TEMPO,1,2)
                   m_mtempopar := Substr(SH6->H6_TEMPO,4,2)
                   m_thpar := m_thpar + val(m_htempopar) 
                   m_tmpar := m_tmpar + val(m_mtempopar) 
                   If m_tmpar > 60
                      m_tmpar := m_tmpar - 60
                      m_thpar := m_thpar + 1
                   Endif   
                   li := li + 1         
                   dbSelectArea("SH6")
                   dbSkip()
                   Loop
                End
                If m_existeordemp == "S"
                   If m_thpar < 10 
                      @ li,096 PSAY "000"
                      @ li,099 PSAY m_thpar Picture "9"
                   ElseIf m_thpar >= 10 .and. m_thpar < 100
                      @ li,096 PSAY "00"
                      @ li,098 PSAY m_thpar Picture "99"
                   ElseIf m_thpar >= 100 .and. m_thpar < 1000
                      @ li,096 PSAY "0"
                      @ li,097 PSAY m_thpar Picture "999"
                   Else
                      @ li,096 PSAY m_thpar Picture "9999"
                   Endif   
                   @ li,100 PSAY ":"
                   If m_tmpar < 10
                      @ li,101 PSAY "0"
                      @ li,102 PSAY m_tmpar Picture "9"
                   Else
                      @ li,101 PSAY m_tmpar Picture "99"
                   Endif   
                   li := li + 2
                   m_thpartot := m_thpartot + m_thpar
                   m_tmpartot := m_tmpartot + m_tmpar
                   If m_tmpartot > 60
                      m_tmpartot := m_tmpartot - 60
                      m_thpartot := m_thpartot + 1
                   Endif   
                Endif
             Endif      
             dbSelectArea("MAX")
             @ li,012 PSAY Subs(PRODUTO,1,8) + "-" + DESCPRO     
             li := li + 1
             @ li,001 PSAY Subs(OP,1,6) + "/" + Subs(OP,7,2) 
             @ li,012 PSAY NREDUZ
             @ li,034 PSAY TEORICO Picture "@E 999,999,999.999"
             @ li,052 PSAY REFUGO Picture "@E 999,999,999.999"
             @ li,069 PSAY TEORICO + REFUGO Picture "@E 999,999,999.999"
             @ li,086 PSAY (REFUGO / (TEORICO + REFUGO)) * 100 Picture "@E 9999.99"
             @ li,096 PSAY TEMPO
             @ li,104 PSAY TPTEORICO
             m_hrr  := Substr(TEMPO,1,2)
             m_mir  := Substr(TEMPO,4,2)
             m_hrrn := Val(m_hrr)
             m_mirn := Val(m_mir)
             m_hrrn := (m_hrrn * 60)
             m_hrea := m_hrrn + m_mirn
             m_hrt  := Substr(TPTEORICO,1,2)
             m_mit  := Substr(TPTEORICO,4,2)
             m_hrtn := Val(m_hrt)
             m_mitn := Val(m_mit)
             m_hrtn := (m_hrtn * 60)
             m_hteo := m_hrtn + m_mitn
             m_prod := (m_hteo / m_hrea) * 100
             @ li,113 PSAY m_prod Picture "@E 999.99"
             li := li + 1
             m_teor  := m_teor + TEORICO
             m_refu  := m_refu + REFUGO
             m_real  := m_real + TEORICO + REFUGO
             m_hreat := m_hreat + m_hrea
             m_hrtnt := m_hrtnt + m_hteo
             m_teort := m_teort + TEORICO
             m_refut := m_refut + REFUGO
             m_realt := m_realt + TEORICO + REFUGO
             m_trhora := Substr(TEMPO,1,2)
             m_trmin  := Substr(TEMPO,4,2) 
             m_horareal := m_horareal + val(m_trhora)
             m_minreal := m_minreal + val(m_trmin) 
             If m_minreal >= 60
                m_horareal := m_horareal + 1
                m_minreal  := m_minreal - 60
             Endif   
             m_trhorat := Substr(TPTEORICO,1,2)
             m_trmint  := Substr(TPTEORICO,4,2) 
             m_horateor := m_horateor + val(m_trhorat)
             m_minteor := m_minteor + val(m_trmint) 
             If m_minteor >= 60
                m_horateor := m_horateor + 1
                m_minteor  := m_minteor - 60
             Endif   
             m_horarpe := m_horarpe + val(m_trhora)
             m_minrpe  := m_minrpe  + val(m_trmin) 
             If m_minrpe >= 60
                m_horarpe := m_horarpe + 1
                m_minrpe  := m_minrpe - 60
             Endif   
             m_horatpe := m_horatpe + val(m_trhorat)
             m_mintpe  := m_mintpe  + val(m_trmint) 
             If m_mintpe >= 60
                m_horatpe := m_horatpe + 1
                m_mintpe  := m_mintpe - 60
             Endif                                 
             m_maq := MAQUINA
             m_cliente := CLIENTE
             m_op := OP       
          Endif
       Endif       
    Endif
    dbSelectArea("MAX")
    dbSkip()
End       
If li >= 60
   Cabec(titulo,cabec2,nomeprog,tamanho)
   @ 10,001 PSAY cabec1
   li := 12
Endif
li := li + 1
dbSelectArea("SH6")
dbSeek(xFilial("SH6") + m_op)
m_existeordemp := "N"
If Found()
   m_thpar := m_tmpar := 0
   While SH6->H6_ORDEMP == m_op   
      If SH6->H6_DATAINI <= mv_par01 .and. SH6->H6_HORAINI < "06:00"
         dbSelectArea("SH6")
         dbSkip()
         Loop
      Endif    
      If SH6->H6_DATAINI == mv_par02 + 1 .and. SH6->H6_HORAINI >= "06:00"
         dbSelectArea("SH6")
         dbSkip()
         Loop
      Endif    
      m_existeordemp := "S"
      DbSelectArea('SX5')
      DbSetOrder(1)
      Dbseek(xFilial('SX5')+'44'+ SH6->H6_MOTIVO)
      @ li,001 PSAY "PARADA DE MAQUINA-->"
      @ li,021 PSAY SX5->X5_DESCRI
      @ li,096 PSAY SH6->H6_TEMPO
      m_htempopar := Substr(SH6->H6_TEMPO,1,2)
      m_mtempopar := Substr(SH6->H6_TEMPO,4,2)
      m_thpar := m_thpar + val(m_htempopar) 
      m_tmpar := m_tmpar + val(m_mtempopar) 
      If m_tmpar > 60
         m_tmpar := m_tmpar - 60
         m_thpar := m_thpar + 1
      Endif   
      li := li + 1         
      dbSelectArea("SH6")
      dbSkip()
      Loop
   End
   If m_existeordemp == "S"
      If m_thpar < 10 
         @ li,096 PSAY "000"
         @ li,099 PSAY m_thpar Picture "9"
      ElseIf m_thpar >= 10 .and. m_thpar < 100
         @ li,096 PSAY "00"
         @ li,098 PSAY m_thpar Picture "99"
      ElseIf m_thpar >= 100 .and. m_thpar < 1000
         @ li,096 PSAY "0"
         @ li,097 PSAY m_thpar Picture "999"
      Else
         @ li,096 PSAY m_thpar Picture "9999"
      Endif   
      @ li,100 PSAY ":"
      If m_tmpar < 10
         @ li,101 PSAY "0"
         @ li,102 PSAY m_tmpar Picture "9"
      Else
         @ li,101 PSAY m_tmpar Picture "99"
      Endif   
      li := li + 2
   Endif
Endif      

m_thpartot := m_thpartot + m_thpar
m_tmpartot := m_tmpartot + m_tmpar
If m_tmpartot > 60
   m_tmpartot := m_tmpartot - 60
   m_thpartot := m_thpartot + 1
Endif   
      
@ li,001 PSAY "Total " + m_maq
@ li,015 PSAY m_cont Picture "@E 99,999"
@ li,034 PSAY m_teort Picture "@E 999,999,999.999"
@ li,052 PSAY m_refut Picture "@E 999,999,999.999"
@ li,069 PSAY m_realt Picture "@E 999,999,999.999"
@ li,086 PSAY (m_refut /(m_teort + m_refut)) * 100 Picture "@E 9999.99"
If m_horareal < 10 
   @ li,096 PSAY "000"
   @ li,099 PSAY m_horareal Picture "9"
ElseIf m_horareal >= 10 .and. m_horareal < 100
   @ li,096 PSAY "00"
   @ li,098 PSAY m_horareal Picture "99"
ElseIf m_horareal >= 100 .and. m_horareal < 1000
   @ li,096 PSAY "0"
   @ li,097 PSAY m_horareal Picture "999"
Else
   @ li,096 PSAY m_horareal Picture "9999"
Endif   
@ li,100 PSAY ":"
If m_minreal < 10
   @ li,101 PSAY "0"
   @ li,102 PSAY m_minreal Picture "9"
Else
   @ li,101 PSAY m_minreal Picture "99"
Endif   
If m_horateor < 10
   @ li,104 PSAY "0"
   @ li,105 PSAY m_horateor Picture "999"
ElseIf m_horateor >= 10 .and. m_horateor < 100
   @ li,104 PSAY "00"
   @ li,106 PSAY m_horateor Picture "99"
ElseIf m_horateor >= 100 .and. m_horateor < 1000
   @ li,104 PSAY "0"
   @ li,105 PSAY m_horateor Picture "999"
Else   
   @ li,104 PSAY m_horateor Picture "9999"
Endif   
@ li,108 PSAY ":"
If m_minteor < 10
   @ li,109 PSAY "0"
   @ li,110 PSAY m_minteor Picture "9"
Else
   @ li,109 PSAY m_minteor Picture "99"
Endif   
m_prodreal := (m_horareal * 60) + m_minreal
m_prodteor := (m_horateor * 60) + m_minteor
@ li,113 PSAY ((m_prodteor / m_prodreal) * 100) Picture "@E 999.99"
li := li + 1
If m_thpartot < 10 
   @ li,096 PSAY "000"
   @ li,099 PSAY m_thpartot Picture "9"
ElseIf m_thpartot >= 10 .and. m_thpartot < 100
   @ li,096 PSAY "00"
   @ li,098 PSAY m_thpartot Picture "99"
ElseIf m_thpartot >= 100 .and. m_thpartot < 1000
   @ li,096 PSAY "0"
   @ li,097 PSAY m_thpartot Picture "999"
Else
   @ li,096 PSAY m_thpartot Picture "9999"
Endif   
@ li,100 PSAY ":"
If m_tmpartot < 10
   @ li,101 PSAY "0"
   @ li,102 PSAY m_tmpartot Picture "9"
Else
   @ li,101 PSAY m_tmpartot Picture "99"
Endif   
li := li + 2
          m_teoricototal := m_teort + m_teoricototal
          m_refugototal := m_refut + m_refugototal
@ li,034 PSAY m_teoricototal Picture "@E 999,999,999.999"
@ li,052 PSAY m_refugototal Picture "@E 999,999,999.999"
m_contg := m_contg + m_cont
//novo
li := li + 2
@ li,001 PSAY "           Produto                                                            Total"
li := li + 2
m_cont := 0
m_prim := "S"
DbSelectarea("MAX")
dbGoTop()
cArqInd2 := criatrab("",.f.)
cChave2  := "PRODUTO"
Indregua("MAX",cArqInd2,cChave2,,,"Selecionando Registros...")
m_produto := PRODUTO
m_desc := SPACE(30)

While !eof()
   If Subs(PRODUTO,1,1) < "4"
      dbSkip()
      Loop
   Endif   
   If m_prim = "S"
      m_produto := PRODUTO              
      m_desc := DESCPRO
      m_prim := "N"
   Endif   
   If m_produto == PRODUTO
      m_requisitado := m_requisitado + QUANT
   Else
      If li >= 60
         Cabec(titulo,cabec2,nomeprog,tamanho)
         @ 10,012 PSAY "           Produto                                                            Total"
         li := 12
      Endif
      @ li,012 PSAY Subs(m_produto,1,8) + "-" + m_desc
      @ li,069 PSAY m_requisitado Picture "@E 999,999,999.999"
      li := li + 1
      m_produto := PRODUTO
      m_desc := DESCPRO   
      m_totrequi := m_totrequi + m_requisitado
      m_requisitado := 0
      m_requisitado := m_requisitado + QUANT
   Endif
   dbSkip()
End     

//novo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura tela e Set's                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFNDEF WINDOWS
        Set Device To Screen
#ENDIF
dbSelectArea("SH6")
SET FILTER TO     
dbSelectArea("MAX")
Close
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se Impressao em Disco, chama SPOOL                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1
   Set Printer To
   Commit
   ourspool(wnrel)
Endif
SET CENTURY OFF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Libera Relatorio Para Spool da Rede                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MS_FLUSH()


//O.P.       Cliente                      Producao      Moido Gerado            Total        %  T.Real T.Teor.  % Prod.
//999999/99  xxxxxxxxxxxxxxxxxxxx  999,999,999,999   999,999,999,999  999,999,999,999  9999,99   99:99   99:99    99,99
//                                        Producao      Moido Gerado            Total           T.Real T.Teor.                      "
//                                                                                               9999:99 9999:99
