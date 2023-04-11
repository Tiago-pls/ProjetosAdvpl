#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

user function ImpSA2()
Local cTitulo   := "Selecione o Diretorio para Importar Banco de Horas..."
Local nMascpad  := 0                        
Local cDirini   := "\"
Local nOpcoes   := GETF_LOCALHARD
Local lArvore   := .F. /*.T. = apresenta o ?rvore do servidor || .F. = n?o apresenta*/   
Local lSalvar   := .F. /*.T. = Salva || .F. = Abre*/
                                                                            
cArq := cGetFile( '*.csv|*.csv' , cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)

If !File(cArq)
	MsgStop("O arquivo  nao foi encontrado. A importacao sera abortada!","[AEST901] - ATENCAO")
	Return
EndIf       
   
MsAguarde({|| lRet := ProcArq(cArq)}, "Aguarde...", "Processando Registros...")

Return

static function  ProcArq(cArq)
FT_FUSE(cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()        

aDados := {}     

lPrim := .T.
nQtd := 0
if select("SA2")==0
    DBSELECTAREA( "SA2" )
Endif
SA2->( dbSetOrder(1))
While !FT_FEOF()
    IncProc("Lendo arquivo texto..." + cValToChar(nQtd))
    cLinha := FT_FREADLN()
    If lPrim
		lPrim := .F.
	Else  		  
		nQtd += gravaReg( Separa( cLinha,";",.T.))                                                  
	EndIf
    FT_FSKIP()
EndDo
MSGALERT( "Foram importados " + cValtoChar(nQtd) + " registros", "Importacao" ) 
Return 

static function gravaReg(aDados)
Local nRet := 0
SA2->( Dbgotop())

cCod :=  adados[1] + space(TamSx3("A2_COD")[1] - len(adados[1]))
cLoja :=  adados[2] + space(TamSx3("A2_LOJA")[1] - len(adados[2]))
if ! SA2->(  DbSeek( xFilial("SA2") + cCod + cLoja))
    //MsgAlert("Nao achou")
    lDeuCerto := .F.
    
    //Pegando o modelo de dados, setando a operação de inclusão
    oModel := FWLoadModel("MATA020M")
    oModel:SetOperation(3)
    oModel:Activate()
    cCGC := Strtran( STRTRAN(adados[15], ".", ""),"-","")
    cTipo := iif(len(cCGC) == 11, 'F',"J")
    cCEP := Strtran( adados[11],"-","")
    //Pegando o model dos campos da SA2
    oSA2Mod:= oModel:getModel("SA2MASTER")
    oSA2Mod:setValue("A2_COD",       cCod        ) // Codigo 
    oSA2Mod:setValue("A2_LOJA",      cLoja       ) // Loja
    oSA2Mod:setValue("A2_NOME",      left(Alltrim(adados[3]), TamSx3("A2_NOME")[1]  )) // Nome             3
    oSA2Mod:setValue("A2_NREDUZ",    left(Alltrim(adados[4]), TamSx3("A2_NREDUZ")[1]  )) // Nome reduz. 
    oSA2Mod:setValue("A2_XFUNC",    left(adados[5],1)   ) // Nome reduz. 
    oSA2Mod:setValue("A2_END",       left(adados[6], TamSx3("A2_END")[1]  )) // Endereco
    oSA2Mod:setValue("A2_BAIRRO",    adados[7]     ) // Bairro
    oSA2Mod:setValue("A2_TIPO",      cTipo         ) // Tipo 
    oSA2Mod:setValue("A2_EST",       adados[8]        ) // Estado
    oSA2Mod:setValue("A2_COD_MUN",   adados[9]    ) // Codigo Municipio                
    oSA2Mod:setValue("A2_MUN",       adados[10]    ) // Municipio
    oSA2Mod:setValue("A2_CEP",       cCEP        ) // CEP
    oSA2Mod:setValue("A2_INSCR",     aDados[18]         ) // Inscricao Estadual
    oSA2Mod:setValue("A2_CGC",       cCGC       ) // CNPJ/CPF            
    oSA2Mod:setValue("A2_PAIS",      '105'    ) // Pais            
    oSA2Mod:setValue("A2_EMAIL",     aDados[18]     ) // E-Mail
    oSA2Mod:setValue("A2_DDD",       ''        ) // DDD            
    oSA2Mod:setValue("A2_TEL",'') // Fone 
    oSA2Mod:setValue("A2_FAX",'') // FAX                        
  //  oSA2Mod:setValue("A2_TPESSOA",   cTipo  ) // Tipo Pessoa
    oSA2Mod:setValue("A2_CODPAIS",   '01058'    ) // Pais Bacen
  //  oSA2Mod:setValue("A2_MSBLQL",    ' '      ) // Bloqueado
    
    //Se conseguir validar as informações
    If oModel:VldData()
        
        //Tenta realizar o Commit
        If oModel:CommitData()
            lDeuCerto := .T.
            
        //Se não deu certo, altera a variável para false
        Else
            lDeuCerto := .F.
        EndIf
        
    //Se não conseguir validar as informações, altera a variável para false
    Else
        lDeuCerto := .F.
    EndIf
    
    //Se não deu certo a inclusão, mostra a mensagem de erro
    If ! lDeuCerto
        //Busca o Erro do Modelo de Dados
        aErro := oModel:GetErrorMessage()
        
        //Monta o Texto que será mostrado na tela
        AutoGrLog("Id do formulário de origem:"  + ' [' + AllToChar(aErro[01]) + ']')
        AutoGrLog("Id do campo de origem: "      + ' [' + AllToChar(aErro[02]) + ']')
        AutoGrLog("Id do formulário de erro: "   + ' [' + AllToChar(aErro[03]) + ']')
        AutoGrLog("Id do campo de erro: "        + ' [' + AllToChar(aErro[04]) + ']')
        AutoGrLog("Id do erro: "                 + ' [' + AllToChar(aErro[05]) + ']')
        AutoGrLog("Mensagem do erro: "           + ' [' + AllToChar(aErro[06]) + ']')
        AutoGrLog("Mensagem da solução: "        + ' [' + AllToChar(aErro[07]) + ']')
        AutoGrLog("Valor atribuído: "            + ' [' + AllToChar(aErro[08]) + ']')
        AutoGrLog("Valor anterior: "             + ' [' + AllToChar(aErro[09]) + ']')
        
        //Mostra a mensagem de Erro
        MostraErro()
    EndIf
    
    //Desativa o modelo de dados
    oModel:DeActivate()



Endif
/*
*/
return nRet
