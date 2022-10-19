#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  GeraDep     ¦ Autor ¦ Tiago Santos      ¦ Data ¦04.10.22  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Geração dos valores de dependentes            		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function GeraDep
                      
Private cPerg 	:= "" 
dbSelectArea("SX1")  
dbSetOrder(1)
cPerg := "GERADEP" +Replicate(" ",Len(X1_GRUPO)- Len("GERADEP"))

//Carrega os Parï¿½metros
//********************************************************************************
GeraPerg(cPerg)
  
If !Pergunte(cPerg,.T.)
   Return
Endif  

MsAguarde({|| GeraRel()}, "Aguarde...", "Gerando Registros...")
Return

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  GeraRel     ¦ Autor ¦ Tiago Santos      ¦ Data ¦04.10.22  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Geração dos valores de dependentes            		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

static function GeraRel()
Local cTitle    := OemToAnsi("Relatï¿½rio Dependentes")
Local cHelp     := OemToAnsi("Relatï¿½rio Dependentes")   
Local aOrdem 	:= {}                
Local oRel
Local oDados             

//Tï¿½tulo do relatï¿½rio no cabeï¿½alho
cTitle := OemToAnsi("Relatorio Dependentes")

//Criacao do componente de impressï¿½o
oRel := tReport():New("Dependentes",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)

//Seta a orientaï¿½ï¿½o do papel
oRel:SetLandscape()

//Seta impressï¿½o em planilha                      
oRel:SetDevice(4)    

//Inicia a Sessï¿½o
oDados := trSection():New(oRel,cTitle,{"SRA","SRJ","SQB"},aOrdem)
//oDados:SetHeaderSection(.F.)    
//oDados:HeaderBreak()     
oDados:SetHeaderBreak() 

// Definiï¿½ï¿½o das colunas a serem impressas no relatï¿½rio


trCell():New(oDados,"RA_FILIAL"           ,"QRY" ,"Cod Filial"   	     ,"@!",02)
trCell():New(oDados,"FILIAL" 	          ,"QRY" ,"Nome Filial"  	     ,"@!",20)

trCell():New(oDados,"RA_MAT"              ,"QRY" ,"Matricula"     	     ,"@!",06)
trCell():New(oDados,"RA_NOME"             ,"QRY" ,"Nome"     	         ,"@!",30)
trCell():New(oDados,"RA_CC"               ,"QRY" ,"Centro Custo"         ,"@!",20) 
trCell():New(oDados,"RA_ADMISSA"          ,"QRY" ,"Admissao"     	     ,"@!",15)

//Executa o relatorio
oRel:PrintDialog()

Return

/*-----------------+---------------------------------------------------------+
!Nome              ! ReportPrint                                             !
+------------------+---------------------------------------------------------+
!Descriï¿½ï¿½o         ! Processamento dos dados e impressao do relatï¿½rio        !
+------------------+---------------------------------------------------------+
!Autor             ! Lucilene Mendes	                                     !
+------------------+--------------------------------------------------------*/
Static Function ReportPrint(oRel)

Local oDados  	:= oRel:Section(1)
Local nOrdem  	:= oDados:GetOrder()
Local dDataDe	:= ""
Local dDataAte	:= ""
Local cTes		:= ""
Local cNotIn	:= "" 

oDados:Init()

//Seleciona os registros
//********************************************************************************
If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif

cQry := MontaQry()

TcQuery cQry New Alias "QRY"                          
                                         
// Set as colunas do tipo Data
TCSetField("QRY","RA_ADMISSA","D",8,0)  

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
  		
		// Nome Filial   		
		SM0->(dbSetOrder(1))
		nRecnoSM0 := SM0->(Recno())
		SM0->(dbSeek(SUBS(cNumEmp,1,2)+QRY->RA_FILIAL))
		oDados:Cell("FILIAL"	):SetValue(Alltrim(SM0->M0_FILIAL))	
		SM0->(dbGoto(nRecnoSM0))			  
		
	
		//oDados:Cell("Z03_SUPERI"):SetValue( cSup)
		//oDados:Cell("NOME_SUP"):SetValue(alltrim(  POSICIONE("SRA",1,QRY->RA_FILIAL + cSup ,"RA_NOME")))  
		
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
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  GeraPerg    ¦ Autor ¦ Tiago Santos      ¦ Data ¦04.10.22  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Geração dos valores de dependentes            		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

Static Function GeraPerg(cPerg) 
Local aRegs:= {}

aAdd(aRegs,{cPerg,"01","Filial"         ,"Filial De"        ,"Filial De"       ,"mv_ch1","C",02,0,0,"G"," ","mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"02","Filial Ate"     ,"Filial Ate"       ,"Filial Ate"      ,"mv_ch2","C",02,0,0,"G","naovazio()","mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"03","Tipo dep"       ,"Tipo dep"         ,"Tipo dep"        ,"mv_ch3","C",01,0,0,"G","naovazio()","mv_par03","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Aux Creche"     ,"Aux Creche"       ,"Aux Creche"      ,"mv_ch4","C",01,0,0,"G","naovazio()","mv_par04","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})

U_BuscaPerg(aRegs)

Return

// funï¿½ï¿½o para retornar a query conforme tipo do relatï¿½rio selecionado
static Function MontaQry ()                                   
Local cQuery := " " 

cQuery := "Select  RA_FILIAL, RA_NOME, RA_CIC, RA_CC from " + RetSqlName("SRA")+" SRA "
cQuery += " inner join "+  RetSqlName("SRB") + "SRB on RA_FILIAL = RB_FILIAL and RA_MAT = RB_MAT"
cQuery += " where SRA.D_E_L_E_T_=' ' and SRB.D_E_L_E_T_ =' ' "
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
