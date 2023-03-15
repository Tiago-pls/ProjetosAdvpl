#include "protheus.ch"
#Include "Xmlxfun.ch"
#INCLUDE "TBICONN.CH" 
#INCLUDE "TOPCONN.CH" 
#DEFINE  CRLF chr(13)+CHR(10)

/*________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+-------------+-------+-------------------------+------+----------+¦¦
¦¦¦Função    ¦ Imp22401    ¦ Autor ¦ Lucilene Mendes         ¦ Data ¦ 07/08/21 ¦¦¦
¦¦+----------+-------------+-------+-------------------------+------+----------+¦¦
¦¦¦Descrição ¦ Importação do SOC - S-2240 - Fator de Risco					   ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function Imp22401(aEmpFil)
Local cHeadRet 	:= ""
Local cPostRet 	:= "" 
Local cString	:= "{'empresa':'752832','codigo':'141561','chave':'58657d9b3af8cd4a22d1','tipoSaida':'json','dataInicio':'"+dtoc(FirstDay(date()))+"','dataFim':'"+dtoc(LastDay(date()))+"','funcionario':'','tipoBuscaFuncionario':'','tipoBuscaUnidade':'','unidade':'','codigoEmpresa':'','tipoFiltroData':'2','status':''}"       
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
oObjLog:setFileName('\log_ws\soc\'+dtos(dDatabase)+'\22401\log_'+dtos(date())+"_"+strtran(time(),":","")+'.txt')
oObjLog:eraseLog()
oObjLog:saveMsg("Importação 2240 SOC")


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

cDir += '22401\'
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
		//Percorre todos os registros
		For i:= 1 to Len(oRecord)            
			//Localiza o funcionário
		   	C9V->(dbSetOrder(3))
		   	If C9V->(dbSeek(xFilial("C9V")+oRecord[i]:CPFTrab+'1'))
		   		
				//Cadastra a condição do ambiente de trabalho
				CadAmbiente(i)
		   			
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
¦¦¦Funçäo    ¦ CadAmbiente ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦07.08.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Cadastro condição ambiente de trabalho					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function CadAmbiente(i)
Local cQry 		:= ""
Local cMensagem := ""
Local cDocAval	:= ""
Local oModel 	:= Nil
Local oModelCM9 := Nil
Local oModelT0Q := Nil
Local oModelCMA := Nil
Local oModelT3S := Nil
Local oAgente 	:= Nil
Local oAmbiente := Nil
Local oResp 	:= Nil
Local nOpc 		:= 3 //inclusão
Local nLinha	:= 0
Local x:= 0
Local z:= 0
Local a:= 0
Local r:= 0

//Verifica se o registro já existe
cQry:= "Select CM9.R_E_C_N_O_ RECNO From "+RetSqlName("CM9")+" CM9 "
cQry+= "Where CM9_FILIAL = '"+xFilial("CM9")+"' "
cQry+= "And CM9_FUNC = '"+C9V->C9V_ID+"' "
cQry+= "And CM9_DTINI = '"+dtos(ctod(oRecord[i]:dtIniCondicao))+"' "
cQry+= "And CM9.D_E_L_E_T_ = ' ' "
If Select("QRY") > 0
	QRY->(dbCloseArea())
Endif	
TcQuery cQry New Alias "QRY"

If QRY->(!Eof())
	CM9->(dbGoto(QRY->RECNO))
	If !Empty(CM9->CM9_PROTUL)
		Return
	Else	
		nOpc := 4 //Alteração
	Endif
Endif	

oModel := FWLoadModel('TAFA264')
oModel:SetOperation(nOpc)  
oModel:Activate()

oModelCM9:= oModel:GetModel('MODEL_CM9')
oModelT0Q:= oModel:GetModel('MODEL_T0Q')
oModelCMA:= oModel:GetModel('MODEL_CMA')
oModelCMB:= oModel:GetModel('MODEL_CMB')
oModelLEA:= oModel:GetModel('MODEL_LEA')
oModelT3S:= oModel:GetModel('MODEL_T3S')

//Cabeçalho
If nOpc = 3
	oModel:SetValue('MODEL_CM9','CM9_FUNC',C9V->C9V_ID)
	oModel:SetValue('MODEL_CM9','CM9_DTINI',ctod(oRecord[i]:dtIniCondicao))
	oModel:SetValue('MODEL_CM9','CM9_DATIVD',oRecord[i]:dscAtivDes)
	oModel:SetValue('MODEL_CM9','CM9_OBSCMP',oRecord[i]:obsCompl)
Endif


//Informações do ambiente de trabalho
oAmbiente:= oRecord[i]:infoAmb
nLinha:= oModelT0Q:Length()
For z= 1 to Len(oAmbiente)
	If z > nLinha
		oModelT0Q:AddLine(.T.)
		oModelT0Q:GoLine(oModelT0Q:Length())
	Else
		oModelT0Q:GoLine(z)
	EndIf
	oModel:SetValue('MODEL_T0Q','T0Q_LAMB',oAmbiente[z]:localAmb)
	oModel:SetValue('MODEL_T0Q','T0Q_DSETOR',oAmbiente[z]:dscSetor)
	oModel:SetValue('MODEL_T0Q','T0Q_TPINSC',oAmbiente[z]:tpInsc)
	oModel:SetValue('MODEL_T0Q','T0Q_NRINSC',oAmbiente[z]:nrInsc)
Next

//Fator de risco
oAgente:= oRecord[i]:agNoc
lLinha:= .F.
nLinha:= oModelCMA:Length()
For a:= 1 to Len(oAgente)
	cCodAgente:= GetAgent(oAgente[a]:AgNoc:codAgNoc)
	oAgen:= oAgente[a]:AgNoc
	If Type("oAgen:tpAval") <> "U" .and. !Empty(oAgente[a]:AgNoc:codAgNoc) .and. !Empty(cCodAgente)
		If a > nLinha
			oModelCMA:AddLine(.T.)
			oModelCMA:GoLine(oModelCMA:Length())
		Else
			oModelCMA:GoLine(a)	
		EndIf
		oModel:SetValue('MODEL_CMA','CMA_TPAVAL',oAgente[a]:AgNoc:tpAval)
		oModel:SetValue('MODEL_CMA','CMA_CODAG',cCodAgente)
		lLinha:= .T.
	
	
		// If a > 1
		// 	oModelLEA:AddLine(.T.)
		// 	oModelLEA:GoLine(oModelLEA:Length())
		// EndIf

		oModel:SetValue('MODEL_LEA','LEA_UTZEPI',oAgente[a]:AgNoc:EpcEpi:utilizEPI)
		oModel:SetValue('MODEL_LEA','LEA_UTZEPC',oAgente[a]:AgNoc:EpcEpi:utilizEPC)
		oEpiCompl:= oAgente[a]:AgNoc:EpcEpi
		If Type("oEpiCompl:epiCompl") <> "U"
			oEpiCompl:= oAgente[a]:AgNoc:EpcEpi:epiCompl
			
	
			oModel:SetValue('MODEL_LEA','LEA_MEDPRT',Iif(oEpiCompl:medProtecao = "S",'1',''))
			oModel:SetValue('MODEL_LEA','LEA_CNDFUN',Iif(oEpiCompl:condFuncto = "S",'1',''))
			oModel:SetValue('MODEL_LEA','LEA_PRZVLD',Iif(oEpiCompl:przValid = "S",'1',''))
			oModel:SetValue('MODEL_LEA','LEA_PERTRC',Iif(oEpiCompl:periodicTroca = "S",'1',''))
			oModel:SetValue('MODEL_LEA','LEA_HIGIEN',Iif(oEpiCompl:higienizacao = "S",'1',''))
			oModel:SetValue('MODEL_LEA','LEA_USOINI',Iif(oEpiCompl:usoInint = "S",'1',''))
		Endif
		
		If Type("oAgen:EpcEpi:epi") <> "U"
			oEpi:= oAgente[a]:AgNoc:EpcEpi:epi
			If Len(oEpi) > 0
				nLinha:= oModelCMB:Length()
				For b:= 1 to Len(oEpi)
					If b > 1
						oModelCMB:AddLine(.T.)
						oModelCMB:GoLine(oModelCMB:Length())
					Else
						oModelCMB:GoLine(b)
					Endif
					oModel:SetValue('MODEL_CMB','CMB_EFIEPI',Iif(oAgente[a]:AgNoc:EpcEpi:eficEpi = 'S','1','2'))
					oModel:SetValue('MODEL_LEA','LEA_EFIEPI',Iif(oAgente[a]:AgNoc:EpcEpi:eficEpi = 'S','1','2'))
					//oModel:SetValue('MODEL_CMB','CMB_EFIEPI',Iif(oEpi[b]:eficEpi = 'S','1','2'))
					If Type("oEpi[b]:docAval") <> "U"
						cDocAval:= GetDocAval(oEpi[b]:docAval)
						oModel:SetValue('MODEL_CMB','CMB_IDDESC',cdocAval)
						oModel:SetValue('MODEL_CMB','CMB_DVAL',cdocAval)
					Endif
				Next
			Else
				If oModelCMB:Length() > 1
					oModelCMB:AddLine(.T.)
					oModelCMB:GoLine(oModelCMB:Length())
				Endif	
				oModel:SetValue('MODEL_CMB','CMB_EFIEPI','2')	
				//oModel:SetValue('MODEL_CMB','CMB_CODAGE',cCodAgente)	
			Endif
		Endif
	Endif
Next

//Responsável
oResp:= oRecord[i]:respReg

For r:= 1 to Len(oResp)
	nLinha:= oModelT3S:Length()
	If r > 1
		oModelT3S:AddLine(.T.)
		oModelT3S:GoLine(oModelT3S:Length())
	Else
		oModelT3S:GoLine(r)	
	Endif
	oModel:SetValue('MODEL_T3S','T3S_NROC',oResp[r]:nrOC)
	oModel:SetValue('MODEL_T3S','T3S_UFOC',oResp[r]:ufOC)
	oModel:SetValue('MODEL_T3S','T3S_CPFRES',oResp[r]:cpfResp)
	oModel:SetValue('MODEL_T3S','T3S_IDEOC',oResp[r]:ideOC)
Next


If oModel:VldData()
    oModel:CommitData()
	oObjLog:saveMsg("Registro gravado com sucesso. ID "+CM9->CM9_ID+CRLF)
Else
	aErro := oModel:GetErrorMessage()
	For x := 1 to Len(aErro)
		if Valtype (cMensagem) =  Valtype (aErro[x])
			cMensagem +=  cMensagem + aErro[x] + CRLF
		endif
	Next
	oObjLog:saveMsg("Falha no cadastro: ")
	oObjLog:saveMsg(cMensagem)
	oObjLog:saveMsg(""+CRLF)
Endif

oModel:DeActivate()
oModel:Destroy()

Return

/************************/
/* Busca o ID do agente */
/************************/
Static Function GetAgent(cCodigo)
Local cRet:= ""

cQry:= "Select V5Y_ID "
cQry+= "From "+RetSqlName("V5Y")+" V5Y "
cQry+= "Where V5Y_FILIAL = '"+xFilial("V5Y")+"' "
cQry+= "And V5Y_CODIGO = '"+cCodigo+"' "
cQry+= "And V5Y.D_E_L_E_T_ = ' ' "
If Select("QRV") > 0
	QRV->(dbCloseArea())
Endif	
TcQuery cQry New Alias "QRV"

If QRV->(!Eof())
	cRet:= QRV->V5Y_ID
Endif

Return cRet

/**************************/
/* Busca o ID do dcumento */
/**************************/
Static Function GetDocAval(cCodigo)
Local cRet:= ""

cQry:= "Select V3D_ID "
cQry+= "From "+RetSqlName("V3D")+" V3D "
cQry+= "Where V3D_FILIAL = '"+xFilial("V3D")+"' "
cQry+= "And V3D_DSCEPI = '"+cCodigo+"' "
cQry+= "And V3D.D_E_L_E_T_ = ' ' "
If Select("QRD") > 0
	QRD->(dbCloseArea())
Endif	
TcQuery cQry New Alias "QRD"

If QRD->(!Eof())
	cRet:= QRD->V3D_ID
Else
	RecLock("V3D", .T.)
		V3D->V3D_FILIAL:= xFilial("V3D")	
		V3D->V3D_ID:= GetSX8Num( "V3D", "V3D_ID")	
		V3D->V3D_DSCEPI:= cCodigo	
	MsUnlock()	
	ConfirmSX8()
	cRet:= V3D->V3D_ID
Endif

Return cRet
