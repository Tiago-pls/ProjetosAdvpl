#include 'protheus.ch'
#include 'topconn.CH'
#INCLUDE "RWMAKE.CH"
#include 'ap5mail.ch'
#include 'RPTDEF.CH'
#include 'FWPrintSetup.ch'
#INCLUDE "tbiconn.ch"


user function ENVEMAIL(CODFIL,NUM,PREFIXO,CLIENTE, LOJA)

	Local cCodgHtml := ""
	Local lResultad := .F.
	Local cDestinad := "tiago.santos@smsti.com.br"
	Local cTitulHtm := "Boleto On-Line ESCRIBA"
	Local cNFEletronica := 'cNFEletronica'
	Local cProtocolo    := 'cProtocolo'
    
	Local nVezes := 0
    cPula := Chr(13) + Chr(10)
	cCodgHtml := '<html>'+cPula
	cCodgHtml += '<head>'+cPula
	cCodgHtml += '<title>BOLETO ON-LINE</title>'+cPula
	cCodgHtml += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'+cPula
	cCodgHtml += '</head>                '+cPula
	cCodgHtml += '<body>'+cPula
	cCodgHtml += '<p>Prezado(a):<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+cPula
	cCodgHtml += '<p>Em anexo boleto bancário, e link para impressão da NFSE da Prefeitura, referente a contrato de serviço da Escriba Informática Ltda.<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+cPula
	//If cFilAnt = "010101"

	cCodgHtml += '<p>****** Dados para impressao da NFSE ******<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+cPula
	cCodgHtml += '<p>Num RPS : Indicado no boleto<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+cPula
	cCodgHtml += '<p>Serie: E<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+cPula


	cCodgHtml += '</body>'+cPula
	cCodgHtml += '</html>'+cPula
	cCodgHtml += '<p>Qualquer dúvida, entrar em contato pelo fone: (041) 2106-1212. <em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+cPula
	cCodgHtml += '<p>Atenciosamente, <em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+cPula
	cCodgHtml += '<p>Dpto. Financeiro - Escriba Informática Ltda.<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+cPula

	//tira os ENTER, pois a função de envio substitui por <BR> <BR>
	cCodgHtml := StrTran(cCodgHtml,cPula,'')

	 
	cMailServer:= GetNewPar("ES_MAILSRV","smtp.office365.com") //smtp.escriba.com.br
	nMailPorta:= GetNewPar("ES_MAILPRT",587)
	cMailSenha:= GetNewPar("ES_MAILSPSW","Taq80052")    //nfescriba$1
	cMailConta:= GetNewPar("ES_MAILCNT","nfeclientes@escriba.com.br")  

	//Cria a conexão com o server STMP ( Envio de e-mail )
	oServer := TMailManager():New()
	
	//Protocolos
	If GetMV("MV_RELTLS ")
		oServer:SetUseTLS(.T.)
	Endif
	If GetMV("MV_RELSSL ")	 
		oServer:SetUseSSL(.T.)
	Endif
	
	oServer:Init( "", cMailServer, cMailConta, cMailSenha, 0, nMailPorta )
	   
	//seta um tempo de time out com servidor de 1min
	If oServer:SetSmtpTimeOut( 120 ) != 0
		Alert( "Falha ao setar o time out do e-mail" )
	EndIf
	   
	//realiza a conexão SMTP
	nErro:= oServer:SmtpConnect(cMailConta, cMailSenha)
	If nErro != 0
		Alert( "Falha ao conectar no servidor. Erro: "+oServer:Geterrorstring(nErro) )
	 	Return .F.
	EndIf	 
	 
	//Autenticação
	If GetMV("MV_RELAUTH") 
	  	oServer:smtpAuth(cMailConta, cMailSenha)
	Endif
	  
	//Apos a conexão, cria o objeto da mensagem
	oMessage := TMailMessage():New()
	   
	//Limpa o objeto
	oMessage:Clear()
	   
	//Popula com os dados de envio
	oMessage:cFrom              := cMailConta
	oMessage:cTo                := cDestinad
	//oMessage:cCc                := cCopia
	//oMessage:cBcc               := "microsiga@microsiga.com.br"
	oMessage:cSubject           := cTitulhtm
	oMessage:cBody              := cCodgHtml
    
	If oMessage:AttachFile("\boleto\"+AllTrim(aDadosTit[1])+"_.pdf") < 0
		Alert( "Erro ao anexar o arquivo: \boleto\"+AllTrim(aDadosTit[1])+".pdf" )
		Return .F.
    Endif
      
    
    //Envia o e-mail
	nRet:= oMessage:Send(oServer)
	If nRet <> 0
		cErro:= oServer:GetErrorString(nRet) 
	    Alert("Erro ao enviar o e-mail: "+cErro )
	    Return .F.
	EndIf
	   
	If oServer:SmtpDisconnect() != 0
	    Alert( "Erro ao disconectar do servidor SMTP" )
	    Return .F.
	EndIf
    
Return
