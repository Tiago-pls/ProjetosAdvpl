#include "protheus.ch"
#include "topconn.ch"
#Include "Xmlxfun.ch"
#include "rwmake.ch" 
#INCLUDE "TOTVS.CH"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GP010FIMPE  ¦ Autor ¦  Lucilene Mendes   ¦ Data ¦26.02.17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Ponto de entrada para envio das informações cadastrais do  ¦¦¦
¦¦¦          ¦ funcionário para o SOC - Projeto Saúde Ocupacional (SOU).  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
//26.11.2017 - Ajustes para P12 - Lucilene SMSTI.

User function GP010FIMPE()
Local lIntSOC := GetNewPar("MV_INTGSOC",.T.) //Parametro que controla a integração com o SOC.

IF(ALTERA .OR. INCLUI) .and. lIntSOC
	envXmlSoc()
ENDIF

Return

Static function envXmlSoc()
Local cUrl		:= "https://www.soc.com.br/WSSoc/FuncionarioModelo2Ws" 
Local cXml		:= ""
Local cXmlAux	:= ""
Local cDir		:= '\log_ws\'  
Local cDtIni	:= ''  	
Local _cHrIni   := '' 
Local cCorpoXml := ''
Local oScript	:= ''
Local cError	:= ''
Local cWarning	:= ''
Local aHeadOut 	:= {}
Local nTimeOut  := 120
Local cHeadRet 	:= ""
Local cPostRet 	:= "" 
Local oScript

Private cPswrd	:= '8a73d22a3dc85f4'    
Private cDirSrv := '\sou\'
Private cDirRoot:= GetSrvProfString("ROOTPATH","")
Private cArqExe	:= 'fciv.exe'
Private cExePost:= 'wget64.exe'

//Monta a estrutura para chamada do WebService 
cXml:= '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://services.soc.age.com/">'
cXml+= getHeader()
cXml+= '<soapenv:Body>'
cXml+= '<ser:importacaoFuncionario>'
cXml+= '<Funcionario>'
cXml+= getCorpo()
cXml+= '</Funcionario>'
cXml+= '</ser:importacaoFuncionario>'
cXml+= '</soapenv:Body>'
cXml+= '</soapenv:Envelope>'
 
 
 //Cria o diretório para salvar o retorno
If !ExistDir(cDir)
	If MakeDir(cDir) <> 0
		cMsg+= " Falha ao salvar o xml!"
	EndIf
Endif

cDir += 'SOC\'
If !ExistDir(cDir)
	If MakeDir(cDir) <> 0
		cMsg+= " Falha ao salvar o xml!"
	EndIf
Endif

cDir += DTOS(date())+'\'
If !ExistDir(cDir)
	If MakeDir(cDir) <> 0
		cMsg+= " Falha ao salvar o xml!"
	EndIf
Endif

cDir += 'FUNCIONARIO\'
If !ExistDir(cDir)
	If MakeDir(cDir) <> 0
		cMsg+= " Falha ao salvar o xml!"
	EndIf
Endif

cDirErro:= cDir+'Erro\'
If !ExistDir(cDirErro)
	If MakeDir(cDirErro) <> 0
		cMsg+= " Falha ao criar pasta de erro!"
	EndIf
Endif

_cHrIni	:= IntToHora(SomaHoras(Time(),'01:00'))
_cHrIni 	:= Substr(_cHrIni,1,2) + Substr(_cHrIni,4,2) + Substr(_cHrIni,7,2)

cArqXml := cDir+dtos(date())+'_'+_cHrIni+'.xml'

_nHandle := FCreate(cArqXml)
FWrite(_nHandle, cXml)
                             
fClose(_nHandle) 

If File(cDirSrv+'retorno.xml')
	fErase(cDirSrv+'retorno.xml')
Endif

_nHandle1 := FCreate(cDirSrv+'xmlenvio.txt')
FWrite(_nHandle1, cXml)
fClose(_nHandle1)

cParam:= '--ignore-length --content-on-error -O retorno.xml --header="User-Agent: Apache-HttpClient/4.1.1 (java 1.5)" '
cParam+= '--header="Host: www.soc.com.br" --header="SOAPAction: " --header="Content-Type: text/xml;charset=UTF-8" -v --post-file=xmlenvio.txt'
cParam+= ' --no-check-certificate https://www.soc.com.br/WSSoc/FuncionarioModelo2Ws'

//Executa no servidor o Post da requisição
If !WaitRunSrv(cDirRoot+Substr(cDirSrv,2)+cExePost+space(1)+cParam, .T., cDirRoot+Substr(cDirSrv,2)) //Diretorio+Executável+comandos;Espera execução; Diretório onde irá executar no server 
	MsgAlert("Falha ao enviar os dados para o SOC! [POST]","Atenção - Integração SOC")
	Return
Endif
                                                                                                 
cRetXml:= cDirSrv+'retorno.xml'
If File(cRetXml)
	oXml := XmlParserFile(cRetXml, "_", @cError, @cWarning)
    If Type("oXmL:_Soap_Envelope:_Soap_Body:_Soap_Fault:_FaultString:text") == "C"
    	cMsg:= oXmL:_Soap_Envelope:_Soap_Body:_Soap_Fault:_FaultString:text
    	MsgAlert("Falha ao enviar os dados para o SOC! ["+cMsg+"]","Atenção - Integração SOC")
    	Return
    Endif
    oRet:= oXmL:_Soap_Envelope:_Soap_Body:_NS2_ImportacaoFuncionarioResponse:_FuncionarioRetorno
    If !Empty(oRet:_DescricaoErro:text)
    	cMsg:= oRet:_DescricaoErro:text
    	MsgAlert("Falha ao atualizar o funcionário no SOC! ["+cMsg+"]","Atenção - Integração SOC")
    	Return
    Endif	 	
Endif



                                                                             

//Cria objeto com XML de retorno
CREATE oScript XMLSTRING cPostRet

//Testa se nao deu erro no parse do XML
nXmlStatus := XMLError()
If ( nXmlStatus == XERROR_SUCCESS )
        
Endif

Return

static function getHeader()
Local _cHead := ''  
Local cHoraAtu	:= Time()
Local _cHrIni	:= ''
Local _cHrFim   := ''
Local cDtIni    := ''
Local cDtFim    := ''
Local cRand     := ''                                                   
Local cSituacao	:= ''
Local cAux		:= ''
Local cSha1		:= ''
Local cArqOrg	:= 'pswdigest.txt'
Local cArqDest	:= 'sha1psw.xml'
Local cParam	:= '-add '+cArqOrg+' -sha1 -xml '+cArqDest
Local lVerao	:= .F. 

If GetMv("MV_HORVER")
	lVerao := .T.
Endif

//Padrão horário GMT
cHoraAtu:= IncTime(Time(),Iif(lVerao,2,3))
_cHrIni:= cHoraAtu

//Soma 1 minuto -> horário que irá expirar a requisição           
_cHrFim:= IncTime(_cHrIni,0,1,0)

cRand := dtos(date())+Left(StrTran(_cHrIni,":",""),4)

cDtIni := SUBSTR(dtos(date()),1,4)+'-'+SUBSTR(dtos(date()),5,2)+'-'+SUBSTR(dtos(date()),7,2)+'T'+Substr(_cHrIni,1,2) +':'+ Substr(_cHrIni,4,2) +':'+ Substr(_cHrIni,7,2)+'.705Z'	
cDtFim := SUBSTR(dtos(date()),1,4)+'-'+SUBSTR(dtos(date()),5,2)+'-'+SUBSTR(dtos(date()),7,2)+'T'+Substr(_cHrFim,1,2) +':'+ Substr(_cHrFim,4,2) +':'+ Substr(_cHrFim,7,2)+'.705Z'	

_cHead+= '<soapenv:Header>'
_cHead+= '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
_cHead+= '<wsu:Timestamp wsu:Id="TS-'+SHA1(dtoc(Date())+Time())+'">'
_cHead+= '<wsu:Created>'+cDtIni+'</wsu:Created>'
_cHead+= '<wsu:Expires>'+cDtFim+'</wsu:Expires>'
_cHead+= '</wsu:Timestamp>' 
/*
//Gera sha1     fciv -add arquivo -sha1 -xml arquivo_xml_saida

//Gera arquivo com os dados a encriptografar

If File(cDirSrv+cArqOrg)
	fErase(cDirSrv+cArqOrg)
Endif
If File(cDirSrv+cArqDest)
	fErase(cDirSrv+cArqDest)
Endif	
nH := fCreate(cDirSrv+cArqOrg) 
FWrite(nH, cRand+cDtIni+cPswrd)                            
fClose(nH)

//Executa no servidor a geração do Encode64(SHA1())
If !WaitRunSrv(cDirRoot+Substr(cDirSrv,2)+cArqExe+space(1)+cParam , .T., cDirRoot+Substr(cDirSrv,2)) //Diretorio+Executável+comandos;Espera execução; Diretório onde irá executar no server 
	MsgAlert("Falha ao enviar os dados para o SOC! [RUN-SHA1]","Atenção - Integração SOC")
	Return
Else
 	cSha1:= LerXmlRet(cDirSrv+cArqDest) 
	If Empty(cSha1)
		MsgAlert("Falha ao enviar os dados para o SOC! [SHA1]","Atenção - Integração SOC")
		Return
	Endif
Endif	
*/

cSha1:= Encode64(sha1(cRand+cDtIni+cPswrd,1))

_cHead+= '<wsse:UsernameToken wsu:Id="UsernameToken-'+Upper(SHA1(dtoc(Date())+Time()))+'">'
_cHead+= '<wsse:Username>362483</wsse:Username>'
_cHead+= '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest">'+cSha1+'</wsse:Password>'//9dac34371ba1504  --> kdMAsN/MJtsDFaPWjeqh3lcy5sc=
_cHead+= '<wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">'+Encode64(cRand)+'</wsse:Nonce>'
//_cHead+= '<wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">'+Encode64(sha1(cRand,2))+'</wsse:Nonce>'
_cHead+= '<wsu:Created>'+cDtIni+'</wsu:Created>'       
_cHead+= '</wsse:UsernameToken>'
_cHead+= '</wsse:Security>'
_cHead+= '</soapenv:Header>'


return _cHead   

static function getCorpo()
Local cCorpoXml := ''
cCorpoXml += '<atualizarCargo>false</atualizarCargo>'
cCorpoXml += '<atualizarCentroCusto>false</atualizarCentroCusto>'
cCorpoXml += '<atualizarFuncionario>'+IF(ALTERA,'true','false')+'</atualizarFuncionario>'
cCorpoXml += '<atualizarMotivoLicenca>false</atualizarMotivoLicenca>'
cCorpoXml += '<atualizarSetor>false</atualizarSetor>'
cCorpoXml += '<atualizarTurno>false</atualizarTurno>'
cCorpoXml += '<atualizarUnidade>false</atualizarUnidade>'
/*
cCorpoXml += '<cargoWsVo>'
cCorpoXml += '<nome>'+Alltrim(Posicione("CTT",1,xFilial("CTT")+SRA->RA_CC,"CTT_DESC01"))+'</nome>'

cCorpoXml += '<tipoBusca>NOME</tipoBusca>'
cCorpoXml += '</cargoWsVo>'
 
cCorpoXml += '<centroCustoWsVo>'
cCorpoXml += '<nome>'+Alltrim(CTT->CTT_DESC01)+'</nome>'
cCorpoXml += '<tipoBusca>NOME</tipoBusca>'
cCorpoXml += '</centroCustoWsVo>'
 */ 
cCorpoXml += '<criarCargo>false</criarCargo>'
cCorpoXml += '<criarCentroCusto>false</criarCentroCusto>'
cCorpoXml += '<criarFuncionario>'+IF(INCLUI,'true','false')+'</criarFuncionario>'
cCorpoXml += '<criarHistorico>false</criarHistorico>'
cCorpoXml += '<criarMotivoLicenca>false</criarMotivoLicenca>'
cCorpoXml += '<criarSetor>false</criarSetor>'
cCorpoXml += '<criarTurno>false</criarTurno>'
cCorpoXml += '<criarUnidade>false</criarUnidade>'
cCorpoXml += '<criarUnidadeContratante>false</criarUnidadeContratante>'
cCorpoXml += '<destravarFuncionarioBloqueado>false</destravarFuncionarioBloqueado>'

cCorpoXml += '<funcionarioWsVo>'
cCorpoXml += '<bairro>'+Alltrim(SRA->RA_BAIRRO)+'</bairro>'
cCorpoXml += '<cep>'+SRA->RA_CEP+'</cep>'
cCorpoXml += '<chaveProcuraFuncionario>CPF</chaveProcuraFuncionario>'
cCorpoXml += '<cidade>'+Alltrim(SRA->RA_MUNICIP)+'</cidade>'
cCorpoXml += '<cnpjEmpresaFuncionario>'+SM0->M0_CGC+'</cnpjEmpresaFuncionario>'
cCorpoXml += '<codigoEmpresa>'+GetNewPar("MV_ESOC"+cEmpAnt)+'</codigoEmpresa>' //Código da empresa no SOC de acordo com a empresa
cCorpoXml += '<codigoMunicipio>'+SRA->RA_CODMUN+'</codigoMunicipio>'
If !Empty(SRA->RA_COMPLEM)
	cCorpoXml += '<complementoEndereco>'+ALLTRIM(SRA->RA_COMPLEM)+'</complementoEndereco>'
Endif
If !Empty(SRA->RA_RACACOR)
	cCorpoXml += '<cor>'+IF(SRA->RA_RACACOR=="1","INDIGENA",IF(SRA->RA_RACACOR=="2","BRANCO",IF(SRA->RA_RACACOR=="4","NEGRO",IF(SRA->RA_RACACOR=="6","AMARELO",IF(SRA->RA_RACACOR=="8","PARDO","EM_BRANCO")))))+'</cor>'
Endif
cCorpoXml += '<cpf>'+SRA->RA_CIC+'</cpf>'
cCorpoXml += '<dataAdmissao>'+trataData(SRA->RA_ADMISSA)+'</dataAdmissao>'
/*
If !Empty(SRA->RA_DEMISSA)
	cCorpoXml += '<dataDemissao>'+trataData(SRA->RA_DEMISSA)+'</dataDemissao>'
Endif
*/
If !Empty(SRA->RA_DTCPEXP)
	cCorpoXml += '<dataEmissaoCtps>'+trataData(SRA->RA_DTCPEXP)+'</dataEmissaoCtps>'
Endif
cCorpoXml += '<dataNascimento>'+trataData(SRA->RA_NASC)+'</dataNascimento>'
cCorpoXml += '<dataUltimaMovimentacao>'+trataData(dDatabase)+'</dataUltimaMovimentacao>'
cCorpoXml += '<desabilitarRisco>false</desabilitarRisco>'
If !Empty(SRA->RA_EMAIL)
	cCorpoXml += '<email>'+ALLTRIM(SRA->RA_EMAIL)+'</email>'
Endif
cCorpoXml += '<endereco>'+ALLTRIM(SRA->RA_ENDEREC)+'</endereco>'
cCorpoXml += '<estado>'+SRA->RA_ESTADO+'</estado>' 
cCorpoXml += '<estadoCivil>'+SRA->RA_ESTCIVI+'</estadoCivil>' 
cCorpoXml += '<matricula>'+SRA->RA_MAT+'</matricula>'

cCorpoXml += '<naoPossuiCpf>false</naoPossuiCpf>'	
cCorpoXml += '<naoPossuiCtps>false</naoPossuiCtps>'	
cCorpoXml += '<naoPossuiMatricula>false</naoPossuiMatricula>'	
cCorpoXml += '<naoPossuiPis>false</naoPossuiPis>'
 
If !Empty(SRA->RA_MUNNASC)
	cCorpoXml += '<naturalidade>'+Alltrim(SRA->RA_MUNNASC)+'</naturalidade>'
Endif	
cCorpoXml += '<nomeFuncionario>'+Alltrim(SRA->RA_NOME)+'</nomeFuncionario>'
cCorpoXml += '<nomeMae>'+Alltrim(SRA->RA_MAE)+'</nomeMae>'
cCorpoXml += '<nrCtps>'+Alltrim(SRA->RA_NUMCP)+'</nrCtps>'
cCorpoXml += '<numeroEndereco>'+Alltrim(SRA->RA_NUMENDE)+'</numeroEndereco>'
cCorpoXml += '<pis>'+Alltrim(SRA->RA_PIS)+'</pis>'
cCorpoXml += '<razaoSocialEmpresaFuncionario>'+Alltrim(SM0->M0_NOMECOM)+'</razaoSocialEmpresaFuncionario>'
cCorpoXml += '<rg>'+Alltrim(SRA->RA_RG)+'</rg>'
If !Empty(SRA->RA_DTRGEXP)
	cCorpoXml += '<rgDataEmissao>'+tratadata(SRA->RA_DTRGEXP)+'</rgDataEmissao>'
Endif
If !Empty(SRA->RA_RGORG)
	cCorpoXml += '<rgOrgaoEmissor>'+Alltrim(SRA->RA_RGORG)+'</rgOrgaoEmissor>'
Endif
If !Empty(SRA->RA_RGUF)
	cCorpoXml += '<rgUf>'+SRA->RA_RGUF+'</rgUf>'
Endif
cCorpoXml += '<serieCtps>'+SRA->RA_SERCP+'</serieCtps>'
cCorpoXml += '<sexo>'+SRA->RA_SEXO+'</sexo>'

//cSituacao:= 'ATIVO'
/*         
Do Case
	Case RA_SITFOLH == ' '
		cSituacao:= 'ATIVO' 
	Case RA_SITFOLH == 'A'
		cSituacao:= 'AFASTADO'	 
		
	Case RA_SITFOLH == 'D'	
		cSituacao:= 'INATIVO'
	Case RA_SITFOLH == 'F'
		cSituacao:= 'FERIAS'

EndCase			

cCorpoXml += '<situacao>'+cSituacao+'</situacao>'	
*/
cCorpoXml += '<telefoneCelular>'+Alltrim(SRA->RA_DDDFONE)+Alltrim(SRA->RA_TELEFON)+'</telefoneCelular>'
cCorpoXml += '<telefoneResidencial>'+Alltrim(SRA->RA_DDDCELU)+Alltrim(SRA->RA_NUMCELU)+'</telefoneResidencial>'	
cCorpoXml += '<tipoBuscaEmpresa>CODIGO_SOC</tipoBuscaEmpresa>'
cCorpoXml += '<ufCtps>'+SRA->RA_UFCP+'</ufCtps>'
cCorpoXml += '<utilizarDescricaoRequisitoCargo>false</utilizarDescricaoRequisitoCargo>'	
cCorpoXml += '</funcionarioWsVo>'
            
cCorpoXml += '<identificacaoWsVo>'
cCorpoXml += '<chaveAcesso>'+cPswrd+'</chaveAcesso>'
cCorpoXml += '<codigoEmpresaPrincipal>362483</codigoEmpresaPrincipal>'
cCorpoXml += '<codigoResponsavel>164802</codigoResponsavel>'
cCorpoXml += '<homologacao>false</homologacao>'
cCorpoXml += '<codigoUsuario>'+GetNewPar("MV_FUNCSOC",'217592')+'</codigoUsuario>'
cCorpoXml += '</identificacaoWsVo>'
cCorpoXml += '<naoImportarFuncionarioSemHierarquia>false</naoImportarFuncionarioSemHierarquia>'
/*
cCorpoXml += '<setorWsVo>'
cCorpoXml += '<nome>'+Alltrim(CTT->CTT_DESC01)+'</nome>'
cCorpoXml += '<tipoBusca>NOME</tipoBusca>'
cCorpoXml += '</setorWsVo>'
cCorpoXml += '<unidadeContratanteWsVo>'
cCorpoXml += '<cnpj_cei>'+SM0->M0_CGC+'</cnpj_cei>'
cCorpoXml += '<codigo>362483</codigo>'  &&
cCorpoXml += '<dataAssinaturaContrato>'+tratadata(SRA->RA_ADMISSA)+'</dataAssinaturaContrato>'
cCorpoXml += '<tipoBusca>CODIGO</tipoBusca>'
cCorpoXml += '<unidadeContratante>'+Iif(cEmpAnt = '01','1','001')+'</unidadeContratante>'
cCorpoXml += '</unidadeContratanteWsVo>'

cCorpoXml += '<unidadeWsVo>'
cCorpoXml += '<cnpj_cei>'+SM0->M0_CGC+'</cnpj_cei>'
cCorpoXml += '<codigo>362483</codigo>' &&
cCorpoXml += '<tipoBusca>CODIGO</tipoBusca>'
cCorpoXml += '<unidadeContratante>'+Iif(cEmpAnt = '01','1','001')+'</unidadeContratante>'
cCorpoXml += '</unidadeWsVo>'
*/
return cCorpoXml

//Converte dd/mm/aa para dd/mm/aaaa
static function trataData(_dData)

If ValType(_dData) <> 'U' .and. !Empty(_dData)
	_dData := dtos(_dData)
	_dData := SUBSTR(_dData,7,2)+'/'+SUBSTR(_dData,5,2)+'/'+SUBSTR(_dData,1,4)
Else
	_dData:= ' '
Endif

return _dData



Static Function LerXmlRet(cArqXml)
Local cRet:= ''
Local cError:= ''
Local cWarning:= ''

oXml := XmlParserFile( cArqXml, "_", @cError, @cWarning )
nXmlStatus := XMLError()
If nXmlStatus == XERROR_SUCCESS
	SAVE oXml XMLSTRING cXML          
Endif

cRet:=  oXml:_FCIV:_FILE_ENTRY:_sha1:text

Return cRet