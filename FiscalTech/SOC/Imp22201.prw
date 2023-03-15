#include "protheus.ch"
#Include "Xmlxfun.ch"
#INCLUDE "TBICONN.CH" 
#INCLUDE "TOPCONN.CH" 
#DEFINE  CRLF chr(13)+CHR(10)

/*________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+-------------+-------+-------------------------+------+----------+¦¦
¦¦¦Função    ¦ Imp22201    ¦ Autor ¦ Lucilene Mendes         ¦ Data ¦ 01/07/21 ¦¦¦
¦¦+----------+-------------+-------+-------------------------+------+----------+¦¦
¦¦¦Descrição ¦ Importação do SOC - S-2220 Parte 1 - Func. e ASO + Exame		   ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function Imp22201(aEmpFil)
Local cHeadRet 	:= ""
Local cPostRet 	:= "" 
Local cString	:= "{'empresa':'752832','codigo':'138411','chave':'e8b63a15b13c3bbbe95c','tipoSaida':'json','funcionarioInicio':'1','funcionarioFim':'999999999','pFuncionario':'0','funcionario':'0','dataInicio':'"+dtoc(FirstDay(date()))+"','dataFim':'"+dtoc(LastDay(date()))+"','pDataIncAso':'0','tpExame':'1,2,3,4,5,6'}"
Local cUrl		:= "https://ws1.soc.com.br/WSSoc/services/ExportaDadosWs"
Local cXml		:= ""
Local cDir		:= '\log_ws\'   
Local cTime		:= ''
Local nTimeOut 	:= 120 
Local nXmlStatus:= 0
Local i			:= 0
Local aHeadOut 	:= {}

Private oXml
Private oRecord
Private oRet
Private oObjLog := nil
Private cError	:= ''
Private cWarning:= ''    
Private cDestErro:= ''
Private lMsErroAuto:= .F.
Private aErros	:= {}


If Empty(aEmpFil)
	aEmpFil	:= {'01','01'} //1.Empresa - //2.Filial
Endif

//Loga na Empresa/Filial passada como parametro
PREPARE ENVIRONMENT EMPRESA aEmpFil[1] FILIAL aEmpFil[2] MODULO "FAT" TABLES "SA1"

//Grava log
cTime:= Time()

//Geração de log
oObjLog := LogSMS():new("log_ws")
oObjLog:setFileName('\log_ws\soc\'+dtos(dDatabase)+'\22201\log_'+dtos(date())+"_"+strtran(time(),":","")+'.txt')
oObjLog:eraseLog()
oObjLog:saveMsg("Importação 22201 SOC")


//Monta a estrutura para chamada do WebService 
cXml:= '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://services.soc.age.com/"> '
cXml+= '  <soapenv:Header/>'
cXml+= '  <soapenv:Body>'
cXml+= '     <ser:exportaDadosWs>'
cXml+= '        <arg0>'
cXml+= '           <parametros>'+cString+'</parametros>'
cXml+= '        </arg0>'
cXml+= '     </ser:exportaDadosWs>'
cXml+= '  </soapenv:Body>'
cXml+= '</soapenv:Envelope>'
 
AADD(aHeadOut,'Content-Type: text/xml;charset=UTF-8')
AADD(aHeadOut,'SOAPAction: ""')
AADD(aHeadOut,'Host: www.soc.com.br')
AADD(aHeadOut,'User-Agent: Apache-HttpClient/4.1.1 (java 1.5)')
 
//Efetua requisição para o webservice SOC
cPostRet := HttpSPost(cUrl,"","","","",cXml,nTimeOut,aHeadOut,@cHeadRet)

//Cria o diretório para salvar o retorno
If !ExistDir(cDir)
	If MakeDir(cDir) <> 0
		oObjLog:saveMsg("Falha ao criar o diretório "+cDir+"!")
	EndIf
Endif

cDir += 'SOC\'
If !ExistDir(cDir)
	If MakeDir(cDir) <> 0
		oObjLog:saveMsg("Falha ao criar o diretório "+cDir+"!")
	EndIf
Endif

cDir += DTOS(date())+'\'
If !ExistDir(cDir)
	If MakeDir(cDir) <> 0
		oObjLog:saveMsg("Falha ao criar o diretório "+cDir+"!")
	EndIf
Endif

cDir += '22201\'
If !ExistDir(cDir)
	If MakeDir(cDir) <> 0
		oObjLog:saveMsg("Falha ao criar o diretório "+cDir+"!")
	EndIf
Endif
cDirErro:= cDir+'Erro\'
cArquivo := cDir+dtos(date())+'.txt'

_nHandle := FCreate(cArquivo)
FWrite(_nHandle, cPostRet)
                             
fClose(_nHandle)
  
oXml := XmlParserFile( cArquivo, "_", @cError, @cWarning )
nXmlStatus := XMLError()
If nXmlStatus == XERROR_SUCCESS
	SAVE oXml XMLSTRING cXML
Endif

oRet:= oXml:_Soap_Envelope:_Soap_Body:_NS2_ExportaDadosWSResponse:_Return 

If oRet:_Erro:Text <> "false"

	//Retorno com erro
	oObjLog:saveMsg("Erro encontrado na integração: "+oRet:_MensagemErro:Text)
	Return .F.
Else
	cXmlRet:= oRet:_Retorno:text
	
	If FWJsonDeserialize(cXmlRet,@oRecord)  
		//Percorre todos os clientes
		For i:= 1 to Len(oRecord)            
			//Localiza o funcionário
		   	C9V->(dbSetOrder(3))
		   	If C9V->(dbSeek(xFilial("C9V")+oRecord[i]:CPFTrab+'1'))
		   		cCodMedico:= GetMedico(i)

				//Cadastra o exame
				CadExame(i)
		   			
		   	Endif
		Next
	Else
		oObjLog:saveMsg("Falha ao ler o retorno do SOC!")
	Endif 
	
	
Endif            
              
Return


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  GetMedico  ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦09.07.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Localiza ou cadastra o médico do exame					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function GetMedico(i)
Local cRet:= ""

CM7->(dbSetOrder(2))
If CM7->(dbSeek(xFilial("CM7")+oRecord[i]:CodigoMedico))
	cRet:= CM7->CM7_ID
Else
	cRet:= GetSx8Num("CM7","CM7_ID")
	ConfirmSX8()
	
	Reclock("CM7",.T.)
		CM7_ID:= cRet
		CM7_CODIGO:= oRecord[i]:CodigoMedico
		CM7_NOME:= Upper(oRecord[i]:NmMedFicha)
		CM7_NRIOC:= oRecord[i]:NrCRMMedFicha
		CM7_NRIUF:= Posicione("C09",1,xFilial("C09")+oRecord[i]:UFCRMMedFicha,"C09_ID")
		CM7_IDOC:= '1' //CRM
	CM7->(MsUnlock())
Endif

Return cRet	


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  CadExame   ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦09.07.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Cadastro do exame										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function CadExame(i)
Local cQry := ""
Local cMensagem := ""
Local oModel := Nil
Local oModelC9W := Nil
Local nOpc := 3 //inclusão
Local x:= 0

//Verifica se o registro já existe
cQry:= "Select C8B.R_E_C_N_O_ RECNO From "+RetSqlName("C8B")+" C8B "
cQry+= "Where C8B_FILIAL = '"+xFilial("C8B")+"' "
cQry+= "And C8B_FUNC = '"+C9V->C9V_ID+"' "
cQry+= "And C8B_TPEXAM = '"+oRecord[i]:TpExameOcup+"' "
cQry+= "And C8B_DTASO = '"+dtos(ctod(oRecord[i]:DtASO))+"' "
cQry+= "And C8B_RESULT = '"+oRecord[i]:ResASO+"' "
cQry+= "And C8B_CODMED = '"+cCodMedico+"' "
cQry+= "And C8B.D_E_L_E_T_ = ' ' "
If Select("QRY") > 0
	QRY->(dbCloseArea())
Endif	
TcQuery cQry New Alias "QRY"

If QRY->(!Eof())
	C8B->(dbGoto(QRY->RECNO))
	If !Empty(C8B->C8B_PROTUL)
		Return
	Else	
		nOpc := 4 //Alteração
	Endif
Endif	

oModel := FWLoadModel('TAFA258')
oModel:SetOperation(nOpc)  
oModel:Activate()

oModelC9W:= oModel:GetModel('MODEL_C9W')

//Cabeçalho
If nOpc = 3
	oModel:SetValue('MODEL_C8B','C8B_FUNC',C9V->C9V_ID)
	oModel:SetValue('MODEL_C8B','C8B_TPEXAM',oRecord[i]:TpExameOcup)
	oModel:SetValue('MODEL_C8B','C8B_DTASO',ctod(oRecord[i]:DtASO))
	oModel:SetValue('MODEL_C8B','C8B_RESULT',oRecord[i]:ResASO)
	oModel:SetValue('MODEL_C8B','C8B_CODMED',cCodMedico)
Else
	//Se alteração, inclui nova linha para exames
	If oModelC9W:Length()  > 0
		oModelC9W:AddLine(.T.)
	EndIf
	oModelC9W:GoLine(oModelC9W:Length())
Endif

oModel:SetValue('MODEL_C9W','C9W_CODPRO',oRecord[i]:ProcRealizado)
oModel:SetValue('MODEL_C9W','C9W_DTEXAM',ctod(oRecord[i]:DtExame))
oModel:SetValue('MODEL_C9W','C9W_ORDEXA',oRecord[i]:OrdemExame)
oModel:SetValue('MODEL_C9W','C9W_INDRES',oRecord[i]:IndResultadoAltNormal)
oModel:SetValue('MODEL_C9W','C9W_OBS',oRecord[i]:ObsProc)

If oModel:VldData()
    oModel:CommitData()
	oObjLog:saveMsg("Registro gravado com sucesso. ID "+C9W->C9W_ID+CRLF)
Else
	aErro := oModel:GetErrorMessage()
	For x := 1 to Len(aErro)
		if Valtype (cMensagem) =  Valtype (aErro[x])
			cMensagem +=  cMensagem + aErro[x] + CRLF
		endif
	Next
	oObjLog:saveMsg("Falha ao cadastrar o exame: ")
	oObjLog:saveMsg(cMensagem)
	oObjLog:saveMsg(""+CRLF)
Endif

oModel:DeActivate()
oModel:Destroy()

Return
