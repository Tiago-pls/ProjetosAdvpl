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
¦¦¦Descrição ¦ Importação do SOC - S-2210 Parte 1							   ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function Imp22101(aEmpFil)
Local cHeadRet 	:= ""
Local cPostRet 	:= "" 
Local cString	:= "{'empresa':'752832','codigo':'138416','chave':'c4e3b8bcbe02b15726be','tipoSaida':'json','funcionarioInicio':'1','funcionarioFim':'999999999','pFuncionario':'0','funcionarios':'0','dataInicio':'"+dtoc(FirstDay(date()))+"','dataFim':'"+dtoc(LastDay(date()))+"','pDataAcidente':'0','esocial':true}"
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
oObjLog:setFileName('\log_ws\soc\'+dtos(dDatabase)+'\22101\log_'+dtos(date())+"_"+strtran(time(),":","")+'.txt')
oObjLog:eraseLog()
oObjLog:saveMsg("Importação 22101 SOC")


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

cDir += '22101\'
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
		   		

				//Cadastra o CAT
				CadCAT(i)
		   			
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
¦¦¦Funçäo    ¦  CadCAT   ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦15.07.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Cadastro do CAT											  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function CadCAT(i)
Local cQry := ""
Local cTpAcid := ""
Local cMensagem := ""
Local oModel := Nil
Local oModelCM0 := Nil
Local oModelCM1 := Nil
Local oModelCM2 := Nil
Local nOpc := 3 //inclusão
Local x:= 0

//Busca o tipo de acidente
cTpAcid:= oRecord[i]:TpAcid
// cTpAcid:= Posicione("LE5",2,xFilial("LE5")+oRecord[i]:TpAcid,"LE5_ID")
// If Empty(cTpAcid)
// 	oObjLog:saveMsg("Tipo de Acidente não encontrado. ID "+oRecord[i]:TpAcid+CRLF)
// 	Return
// Endif

//Verifica se o registro já existe
cQry:= "Select CM0.R_E_C_N_O_ RECNO From "+RetSqlName("CM0")+" CM0 "
cQry+= "Where CM0_FILIAL = '"+xFilial("CM0")+"' "
cQry+= "And CM0_TRABAL = '"+C9V->C9V_ID+"' "
cQry+= "And CM0_TIPACI = '"+cTpAcid+"' "
//cQry+= "And CM0_TPACID = '"+cTpAcid+"' "
cQry+= "And CM0_DTACID = '"+dtos(ctod(oRecord[i]:DtAcid))+"' "
cQry+= "And CM0_TPCAT = '"+oRecord[i]:TpCat+"' "
cQry+= "And CM0.D_E_L_E_T_ = ' ' "
If Select("QRY") > 0
	QRY->(dbCloseArea())
Endif	
TcQuery cQry New Alias "QRY"

If QRY->(!Eof())
	CM0->(dbGoto(QRY->RECNO))
	If !Empty(CM0->CM0_PROTUL)
		Return
	Else	
		nOpc := 4 //Alteração
	Endif
Endif	

oModel := FWLoadModel('TAFA257')
oModel:SetOperation(nOpc)  
oModel:Activate()

oModelCM0:= oModel:GetModel('MODEL_CM0')
oModelCM1:= oModel:GetModel('MODEL_CM1')
oModelCM2:= oModel:GetModel('MODEL_CM2')

//Cabeçalho
If nOpc = 3
	oModel:SetValue('MODEL_CM0','CM0_TRABAL',C9V->C9V_ID)
	oModel:SetValue('MODEL_CM0','CM0_DTACID',ctod(oRecord[i]:DtAcid))
	oModel:SetValue('MODEL_CM0','CM0_HRACID',StrTran(Left(oRecord[i]:HrAcid,5),":",""))
	oModel:SetValue('MODEL_CM0','CM0_HRTRAB',StrTran(Left(oRecord[i]:HrsTrabAntesAcid,5),":",""))
	oModel:SetValue('MODEL_CM0','CM0_TIPACI',cTpAcid)
	//oModel:SetValue('MODEL_CM0','CM0_TPACID',cTpAcid)
	oModel:SetValue('MODEL_CM0','CM0_TPCAT',oRecord[i]:TpCat)
	oModel:SetValue('MODEL_CM0','CM0_INDOBI',Iif(Upper(oRecord[i]:IndCATObito) = 'S','1','2'))
	oModel:SetValue('MODEL_CM0','CM0_COMPOL',Iif(Upper(oRecord[i]:IndComunPolicia) = 'S','1','2'))
	oModel:SetValue('MODEL_CM0','CM0_CODSIT',Posicione("C8L",2,xFilial("C8L")+oRecord[i]:CodSitGeradora,"C8L_ID") )
	oModel:SetValue('MODEL_CM0','CM0_INICAT',oRecord[i]:IniciatCAT)
	oModel:SetValue('MODEL_CM0','CM0_OBSCAT',oRecord[i]:ObsCAT)
	oModel:SetValue('MODEL_CM0','CM0_DTOBIT',ctod(oRecord[i]:DtObito))
	//oModel:SetValue('MODEL_CM0','CM0_CODCAT',Posicione("C87",2,xFilial("C87")+oRecord[i]:CodCateg,"C87_ID"))
	oModel:SetValue('MODEL_CM0','CM0_NATLES',Posicione("C8M",2,xFilial("C8M")+oRecord[i]:DscLesao,"C8M_ID"))
	oModel:SetValue('MODEL_CM0','CM0_NRCAT',oRecord[i]:NrCATOrig)
	oModel:SetValue('MODEL_CM0','CM0_TPLOC',oRecord[i]:TpLocal)
	oModel:SetValue('MODEL_CM0','CM0_DESLOG',Upper(oRecord[i]:DscLograd))
	oModel:SetValue('MODEL_CM0','CM0_NRLOG',oRecord[i]:NrLograd)
	oModel:SetValue('MODEL_CM0','CM0_COMLOG',oRecord[i]:Complemento)
	oModel:SetValue('MODEL_CM0','CM0_BAIRRO',oRecord[i]:Bairro)
	oModel:SetValue('MODEL_CM0','CM0_CEP',oRecord[i]:CEP)
	cUF:= Posicione("C09",1,xFilial("C09")+oRecord[i]:UF,"C09_ID")
	oModel:SetValue('MODEL_CM0','CM0_CODMUN',Posicione("C07",1,xFilial("C07")+cUF+Substr(oRecord[i]:CodMunic,3),"C07_ID"))
	oModel:SetValue('MODEL_CM0','CM0_INSACI',oRecord[i]:TpInscRegistrador)
	oModel:SetValue('MODEL_CM0','CM0_NRIACI',oRecord[i]:NrInscRegistrador)
	oModel:SetValue('MODEL_CM0','CM0_UF',cUF)
	oModel:SetValue('MODEL_CM0','CM0_CODCNE',oRecord[i]:CodCNES)
	oModel:SetValue('MODEL_CM0','CM0_DTATEN',ctod(oRecord[i]:DtAtendimento))
	oModel:SetValue('MODEL_CM0','CM0_HRATEN',StrTran(Left(oRecord[i]:HrAtendimento,5),":",""))
	oModel:SetValue('MODEL_CM0','CM0_INDINT',Iif(Upper(oRecord[i]:IndInternacao) = 'S','1','2'))
	oModel:SetValue('MODEL_CM0','CM0_DURTRA',oRecord[i]:DurTrat)
	oModel:SetValue('MODEL_CM0','CM0_INDAFA',Iif(Upper(oRecord[i]:IndAfast) = 'S','1','2'))
	oModel:SetValue('MODEL_CM0','CM0_DIAPRO',oRecord[i]:DiagProvavel)
	oModel:SetValue('MODEL_CM0','CM0_CODCID',Posicione("CMM",2,xFilial("CMM")+oRecord[i]:CodCid,"CMM_ID"))
	oModel:SetValue('MODEL_CM0','CM0_OBSERV',oRecord[i]:Observacao)
	oModel:SetValue('MODEL_CM0','CM0_IDPROF',GetMedico(i))
	oModel:SetValue('MODEL_CM0','CM0_CNPJLO',oRecord[i]:CNPJLocalAcid)
	oModel:SetValue('MODEL_CM0','CM0_CNPJLO',oRecord[i]:CNPJLocalAcid)
Else
	//Se alteração, inclui nova linha para exames
	If oModelCM1:Length()  > 0
		oModelCM1:AddLine(.T.)
	EndIf
	oModelCM1:GoLine(oModelCM1:Length())
Endif

//Parte atingida
oModel:SetValue('MODEL_CM1','CM1_CODPAR',Posicione("C8I",2,xFilial("C8I")+oRecord[i]:CodParteAting,"C8I_ID"))
oModel:SetValue('MODEL_CM1','CM1_LATERA',oRecord[i]:Lateralidade)

//Agente Causador
oModel:SetValue('MODEL_CM2','CM2_CODAGE',Posicione("C8J",2,xFilial("C8J")+oRecord[i]:CodAgntCausadorUnico,"C8J_ID"))


If oModel:VldData()
    oModel:CommitData()
	oObjLog:saveMsg("Registro gravado com sucesso. ID "+CM0->CM0_ID+CRLF)
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
If CM7->(dbSeek(xFilial("CM7")+oRecord[i]:NrOC))
	cRet:= CM7->CM7_ID
Else
	cRet:= GetSx8Num("CM7","CM7_ID")
	ConfirmSX8()
	
	Reclock("CM7",.T.)
		CM7_ID:= cRet
		CM7_CODIGO:= oRecord[i]:NrOC
		CM7_NOME:= Upper(oRecord[i]:NomeEmitente)
		CM7_NRIOC:= oRecord[i]:NrOC
		CM7_NRIUF:= Posicione("C09",1,xFilial("C09")+oRecord[i]:UFOC,"C09_ID")
		CM7_IDEOC:= '1' //CRM
	CM7->(MsUnlock())
Endif

Return cRet	

