#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*__________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  ValPoten   - Autor - Tiago Santos      - Data -02.02.23   ---
--+----------+---------------------------------------------------------------
---Descri--o -  Relatório para geração dos valores vendidos e potencias    ---
--+-----------------------------------------------------------------------+--
--+-----------------------------------------------------------------------+--
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/

User Function ValPoten
                      
Private cPerg 	:= "" 
Private cLFRC	:= chr(13)+chr(10)
dbSelectArea("SX1")  
dbSetOrder(1)
cPerg := "VALPOTEN" +Replicate(" ",Len(X1_GRUPO)- Len("VALPOTEN"))

//Carrega os Par-metros
//********************************************************************************
GeraPerg(cPerg)
  
If !Pergunte(cPerg,.T.)
   Return
Endif  

MsAguarde({|| GeraRel()}, "Aguarde...", "Gerando Registros...")
Return

/*__________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  GeraRel    - Autor - Tiago Santos        - Data -06.04.22 ---
--+----------+---------------------------------------------------------------
---Descri--o -  Gera o Relat-io                              		      ---
--+-----------------------------------------------------------------------+--
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/

static function GeraRel()
Local cTitle    := OemToAnsi("Relat-rio Conferencia ")
Local cHelp     := OemToAnsi("Relat-rio Conferencia ")   
Local aOrdem 	:= {}                
Local oRel
Local oDados             

//T-tulo do relat-rio no cabe-alho
cTitle := OemToAnsi("Relatorio valores faturados")

//Criacao do componente de impress-o
oRel := tReport():New("Relatorio valores faturados",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)

//Seta a orienta--o do papel
oRel:SetLandscape()

//Seta impress-o em planilha                      
oRel:SetDevice(4)    

//Inicia a Sess-o
oDados := trSection():New(oRel,cTitle,{"SF2","SD2","SA3"},aOrdem)
//oDados:SetHeaderSection(.F.)    
//oDados:HeaderBreak()     
oDados:SetHeaderBreak() 

// Defini--o das colunas a serem impressas no relat-rio

trCell():New(oDados,"F2_FILIAL   ","QRY" ,  ,"@!",TamSx3("F2_FILIAL")[1])
trCell():New(oDados,"F2_DOC      ","QRY" ,  ,"@!",TamSx3("F2_DOC")[1])
trCell():New(oDados,"F2_CF       ","QRY" ,  ,"@!",TamSx3("F2_CF")[1])
trCell():New(oDados,"F2_CLIENTE  ","QRY" ,  ,"@!",TamSx3("F2_CLIENTE")[1])
trCell():New(oDados,"F2_LOJA     ","QRY" ,  ,"@!",TamSx3("F2_LOJA")[1])
trCell():New(oDados,"A1_NOME     ","QRY" ,  ,"@!",TamSx3("A1_NOME")[1])
trCell():New(oDados,"A1_CODINTE  ","QRY" ,  ,"@!",TamSx3("A1_CODINTE")[1])
trCell():New(oDados,"A1_LOJINT   ","QRY" ,  ,"@!",TamSx3("A1_LOJINT")[1])
trCell():New(oDados,"A1_NOMEINT  ","QRY" ,  ,"@!",TamSx3("A1_NOMEINT")[1])
trCell():New(oDados,"F2_COND     ","QRY" ,  ,"@!",TamSx3("F2_COND")[1])
trCell():New(oDados,"E4_DESCRI   ","QRY" ,  ,"@!",TamSx3("E4_DESCRI")[1])
trCell():New(oDados,"F2_EMISSAO  ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"F2_VEND1    ","QRY" ,  ,"@!",TamSx3("F2_VEND1")[1])
trCell():New(oDados,"A3_NOME     ","QRY" ,  ,"@!",TamSx3("A3_NOME")[1])
trCell():New(oDados,"D2_COD      ","QRY" ,  ,"@!",TamSx3("D2_COD")[1])
trCell():New(oDados,"B1_DESC     ","QRY" ,  ,"@!",TamSx3("D2_COD")[1])
trCell():New(oDados,"D2_QUANT    ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"D2_TOTAL    ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"D2_UM       ","QRY" ,  ,"@!",TamSx3("D2_UM")[1])
trCell():New(oDados,"B1_XPOTENC  ","QRY" ,  ,"@!",TamSx3("B1_XPOTENC")[1])
trCell():New(oDados,"B1_XVLPOTE  ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"D2_AXPLICA  ","QRY" ,  ,"@!",30)

//Executa o relatorio
oRel:PrintDialog()

Return

/*-----------------+---------------------------------------------------------+
!Nome              ! ReportPrint                                             !
+------------------+---------------------------------------------------------+
!Descri--o         ! Processamento dos dados e impressao do relat-rio        !
+------------------+---------------------------------------------------------+
!Autor             ! Lucilene Mendes	                                     !
+------------------+--------------------------------------------------------*/
Static Function ReportPrint(oRel)

Local oDados  	:= oRel:Section(1)
//Local nOrdem  	:= oDados:GetOrder()

oDados:Init()

//Seleciona os registros
//********************************************************************************
If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif
cQry := MontaQry()
TcQuery cQry New Alias "QRY"                          

TCSetField("QRY","F2_EMISSAO","D",8,0)  
nCont := 0
If QRY->(!Eof())
	While QRY->(!Eof()) .and. !oRel:Cancel() 
  		ProcRegua(10)
  		nCont ++
		 MsProcTxt("Analisando registro " )		 
		//Cancelado pelo usuario
		If oRel:Cancel()
			Exit
		EndIf   		
  		oRel:IncMeter(10)   

  		oDados:PrintLine()
        oDados:SetHeaderSection(.F.)   	
	QRY->(dbSkip())						
	Enddo	
Else		
	MsgInfo("Nao foram encontrados registros para os parametros informados!")
    Return .F.
Endif
		
Return

/*__________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  GeraPerg     - Autor - Tiago Santos      - Data -18.09.19 ---
--+----------+---------------------------------------------------------------
---Descri--o -  Atualiza SX1                                		      ---
--+-----------------------------------------------------------------------+--
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/

Static Function GeraPerg(cPerg) 
Local aRegs:= {}

aAdd(aRegs,{cPerg,"01","Filial"         ,"Filial De"        ,"Filial De"       ,"mv_ch1","C",04,0,0,"G"," "           ,"mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"02","Filial Ate"     ,"Filial Ate"       ,"Filial Ate"      ,"mv_ch2","C",04,0,0,"G","naovazio()"  ,"mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"03","Doc"            ,"Doc"              ,"Doc"             ,"mv_ch5","C",09,0,0,"G"," "           ,"mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"04","Doc ate"        ,"Doc ate"          ,"Doc ate"         ,"mv_ch6","C",09,0,0,"G","naovazio()"  ,"mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"05","Cliente"        ,"Item De"          ,"Item De"         ,"mv_ch5","C",06,0,0,"G"," "           ,"mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTD","",""})
aAdd(aRegs,{cPerg,"06","Cliente Ate"    ,"Item Ate"         ,"Item Ate"        ,"mv_ch6","C",06,0,0,"G" ,"naovazio()" ,"mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTD","",""})
aAdd(aRegs,{cPerg,"07","Loja Cli"       ,"Loja Cli"         ,"Loja Cli"        ,"mv_ch7","C",04,0,0,"G"," "           ,"mv_par07","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"08","Loja Cli Ate"   ,"Loja Cli Ate"     ,"Loja Cli Ate"    ,"mv_ch8","C",04,0,0,"G","naovazio()"  ,"mv_par08","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"09","Vendedor"       ,"Vendedor"         ,"Competencia"     ,"mv_ch9","C",06,0,0,"G","naovazio()"  ,"mv_par09","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","Vendedor Ate"   ,"Competencia"      ,"Competencia"     ,"mv_chA","C",06,0,0,"G","naovazio()"  ,"mv_par10","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})

U_BuscaPerg(aRegs)

Return

// fun--o para retornar a query conforme tipo do relat-rio selecionado
static Function MontaQry ()                                   
Local cQuery := " " 

cQuery += " with NFE as (select  "    + cLFRC
cQuery += " F2_FILIAL, F2_DOC, F2_CF, F2_CLIENTE,  F2_LOJA, A1_NOME , "    + cLFRC
cQuery += " A1_CODINTE, A1_LOJINT,  A1_NOMEINT, "    + cLFRC
cQuery += " F2_COND, E4_DESCRI,  F2_EMISSAO, F2_VEND1, A3_NOME,F2_VEND2, F2_VEND3, F2_VEND4, F2_VEND5, "    + cLFRC
cQuery += " D2_COD, B1_DESC, D2_QUANT, D2_TOTAL, D2_UM,  B1_XPOTENC , B1_XVLPOTE, "    + cLFRC
cQuery += " case"  + cLFRC
cQuery += " when D2_AXPLICA ='1' then 'Residencial'"  + cLFRC
cQuery += "	when D2_AXPLICA ='2' then 'Comercial'"  + cLFRC
cQuery += " when D2_AXPLICA ='3' then 'Rural'"  + cLFRC
cQuery += " when D2_AXPLICA ='4' then 'Industrial'"  + cLFRC
cQuery += " when D2_AXPLICA ='5' then 'Servico Publico'"  + cLFRC
cQuery += " when D2_AXPLICA ='6' then 'Ger Compartilhada'"  + cLFRC
cQuery += " else ' '"  + cLFRC
cQuery += " end D2_AXPLICA "  + cLFRC

cQuery += " from " + RetSqlName("SF2") +" SF2 "    + cLFRC
cQuery += " inner join " + RetSqlName("SD2")+" SD2 on F2_FILIAL = D2_FILIAL and F2_DOC = D2_DOC and SD2.D_E_L_E_T_ =' ' "    + cLFRC
cQuery += " inner join " + RetSqlName("SA1")+" SA1 on F2_CLIENTE = A1_COD and F2_LOJA = A1_LOJA and SA1.D_E_L_E_T_ =' ' "    + cLFRC
cQuery += " inner join " + RetSqlName("SA3")+" SA3 on SubString(F2_FILIAL,1,4) = A3_FILIAL and F2_VEND1 = A3_COD and SA3.D_E_L_E_T_ =' ' "    + cLFRC
cQuery += " inner join " + RetSqlName("SB1")+" SB1 on D2_COD = B1_COD and SB1.D_E_L_E_T_ =' ' "    + cLFRC
cQuery += " inner join " + RetSqlName("SE4")+" SE4 on F2_COND = E4_CODIGO and SE4.D_E_L_E_T_ =' ' "    + cLFRC
cQuery += " Where SF2.D_E_L_E_T_ =' ' "    + cLFRC
cQuery += " )
cQuery += " select * from NFE "    + cLFRC

cQuery += " Where F2_FILIAL >='"+MV_PAR01+"' and F2_FILIAL <= '"+MV_PAR02+"'"
cQuery += " And F2_EMISSAO >='"+ DtoS(MV_PAR03)+"' and F2_EMISSAO <= '"+DtoS(MV_PAR04)+"'"
cQuery += " and F2_CLIENTE >='"+MV_PAR05+"' and F2_CLIENTE <= '"+MV_PAR06+"'"
cQuery += " and F2_LOJA >='"+MV_PAR07+"' and F2_LOJA <= '"+MV_PAR08+"'"
cQuery += " and F2_VEND1 >='"+MV_PAR09+"' and F2_VEND1 <= '"+MV_PAR10+"'"
cQuery += " and F2_DOC not in  (" + cLFRC
cQuery += " select D1_NFORI from " +RetSqlName("SD1")+ " Where  D_E_L_E_T_ =' '"+ cLFRC
cquery += " and D1_NFORI <> ' '"+ cLFRC
cQuery += ")"

return cQuery                   

User Function BuscaPerg(aRegsOri)

Local cGrupo	:= ''
Local cOrdem	:= ''
Local aRegAux   := {}
Local aEstrut   := {}
Local nCount    := 0
Local nLenGrupo := 0
Local nLenOrdem := 0
Local nX	 	:= 0
Local nY		:= 0
Local aRegs		:= aClone(aRegsOri)

If ValType('aRegs') <> 'C'
	Return
Endif

If Len(aRegs) <= 0
	Return
Endif

// Buscar Estrutura da tabela SX1
dbSelectArea('SX1');dbSetOrder(1)
aEstrut   := SX1->(dbStruct())
nCount	  := Len(aEstrut)

// Definir o Tamanho dos Campos de Pesquisa
nLenGrupo := aEstrut[1][3] // Tamanho do campo X1_GRUPO
nLenOrdem := aEstrut[2][3] // Tamanho do campo X1_ORDEM

// Compatibilizando o Array de Perguntas
For nX := 1 To Len(aRegs)
	aAdd(aRegAux,Array(nCount))
	For nY := 1 To nCount
		aRegAux[Len(aRegAux)][nY]:=Space(aEstrut[nY][3])
	Next nY
	For nY := 1 To nCount
		If nY <= Len(aRegs[nX])
			aRegAux[Len(aRegAux)][nY]:= aRegs[nX,nY]
		Endif
	Next nY
Next nX

// Recarregando o Array de Peguntas compatibilizado
aRegs := {}
aRegs := aClone(aRegAux)

// Testando se ele nao ficou vazio
If Len(aRegs) <= 0
	Return
Endif

// Buscando no SX1 e incluindo caso nao exista
dbSelectArea('SX1')
For nX := 1 to Len(aRegs)
	cGrupo := Padr(aRegs[nX,1],nLenGrupo)
	cOrdem := Padr(aRegs[nX,2],nLenOrdem)
	If !dbSeek(cGrupo+cOrdem,.F.)
		RecLock('SX1',.T.)
		For nY := 1 to nCount
			If nY <= Len(aRegs[nX])
				FieldPut(nY,aRegs[nX,nY])
			Endif
		Next nY
		MsUnlock()
	Endif
Next nX

Return 
