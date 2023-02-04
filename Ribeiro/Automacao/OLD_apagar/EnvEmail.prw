#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#INCLUDE "TOTVS.CH"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  ENVEMAIL     ¦ Autor ¦ Tiago Santos      ¦ Data ¦11.03.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Envio de email com texto padrão                           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User function Gerpdf()

local oFont1  := TFont():New("Courier New", 9, 16, .T., .T.)
    local oFont2 := TFont():New("Courier New", 9, 13, .T., .F.)
    local nLargTxt := 870 // largura em pixel para alinhamento da funcao sayalign
   local nLin := 0
    local oPrint
    local lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter
    
    cLogo := "C:\sms\sms\ribeiro\cabecalho.png"
    cPath := "c:\temp\"
    cFileName := "tst" + "_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-")
    //cFileName := Alltrim( QRYF->(RA_FILIAL + RA_MAT + RA_NOME))
	lServer :=.T.
	lViewPDF     := .F.
	default PL := Chr(13) + Chr(10) 
	//oPrint:= FWMSPrinter():New(alltrim(aDadosTit[1]), IMP_SPOOL, lAdjustToLegacy, cCaminho,lDisableSetup,NIL, NIL, "PDF", lServer, NIL, NIL, lViewPDF)

    //oPrint := FWMsPrinter():New( cFileName , IMP_PDF, lAdjustToLegacy,cPath, .T., , , "PDF" ,lServer ,NIL, NIL, lViewPDF) 
	oPrint := FWMsPrinter():New( cFileName, IMP_PDF, lAdjustToLegacy,cPath, .T.,,, "PDF" ) 
    oPrint:cPathpdf:=  "c:\temp\"
    oPrint:SetResolution(78) // Tamanho estipulado
    oPrint:SetPortrait()
        //oPrint:SetPaperSize(0, 210, 297 ) // Tamanho da folha 
    oPrint:SetPaperSize( DMPAPER_A4 ) // Tamanho da folha 
    oPrint:SetMargin(10,10,10,10)
	oPrint:StartPage() // Inicia uma nova página  
            
    nLin += 02
    oPrint:SayBitmap( nLin, 010, cLogo , 600, 70) // imagem	

	nLin += 70
	cCabec := space(20)+"TERMO DE ACEITE PARA FATURAMENTO"
    oPrint:SayAlign(nLin, 035, cCabec, oFont1, 575, 20, CLR_BLACK, 3, 2) 	

	cTexto := "O cliente XXXXXXXXXXXX, inscrito no CPF 000.000.000-00 autoriza a empresa "
	cTexto += "RIBEIRO INDÚSTRIA E COMÉRCIO DE PRODUTOS ELÉTRICOS LTDA, inscrita no CNPJ: 75.621.672/0001-13 "
	cTexto += " a realizar o faturamento do gerador fotovoltaico de potência XX,XXkWp composto de:"
    nLin += 40
	oPrint:SayAlign(nLin, 035, cTexto, oFont2, 575, 100, CLR_BLACK, 3, 2) 

	nLin += 100
	cTab := "   Item    |     Gerador Fotovoltaico de KWp      |    Qtd     " 
	cTab += "________________|_______________________________________________________|____________" + PL
	cTab += "________________|_______________________________________________________|____________" + PL
	cTab += "________________|_______________________________________________________|____________" + PL
	cTab += "________________|_______________________________________________________|____________" + PL
	cTab += "________________|_______________________________________________________|____________" + PL
	cTab += "________________|_______________________________________________________|____________" + PL
	cTab += "________________|_______________________________________________________|____________" + PL
	cTab += "________________|_______________________________________________________|____________" + PL
	cTab += "________________|_______________________________________________________|____________" + PL
	cTab += "________________|_______________________________________________________|____________" + PL

	
	oPrint:SayAlign(nLin, 035, cTab, oFont2, 575, 300, CLR_BLACK, 3, 2) 
	

	cPar1 := "	A FST SOLUCOES EM TECNOLOGIA EIRELI, inscrita no CNPJ sob número 11.788.363/0001-50, "
	cPar1 += "com endereço na R PROJETADA, Nº N/S, SAO JOAO DA BARRA RJ, informa a quem interessar possa que tem total"
	cPar1 += " responsabilidade técnica pelo projeto, performance e montagem do sistema fotovoltaico acima" + PL
	cPar1 += "	A Ribeiro não se responsabiliza pelos resultados de performance do gerador instalado, entendemos "
	cPar1 += " que os integradores têm condições técnicas necessárias para dimensionar, aprovar e instalar o gerador "
	cPar1 += "no cliente final, estando estes quesitos a cargo do integrador/instalador."

	nLin += 400
	oPrint:SayAlign(nLin, 035, cPar1, oFont2, 575, 900, CLR_BLACK, 3, 2) 
	oPrint:EndPage()

	oPrint:Preview()		


Return
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  ENVEMAIL     ¦ Autor ¦ Tiago Santos      ¦ Data ¦11.03.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Envio de email com texto padrão                           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/



user function ENVEMAIL()

	Local cCodgHtml := ""
	Local lResultad := .F.
	Local cDestinad := 'tiago.santos@smsti.com.br'
	Local cTitulHtm := "Boleto On-Line RIbeiro"
	Local cNFEletronica := 'cNFEletronica'
	Local cProtocolo    := 'SF2->F2_CODNFE'
    
	Local nVezes := 0
	Local nLin := 0



	
/*
	cCodgHtml := '<html>'+CRLF
	cCodgHtml += '<head>'+CRLF
	cCodgHtml += '<title>BOLETO ON-LINE</title>'+CRLF
	cCodgHtml += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'+CRLF
	cCodgHtml += '</head>                '+CRLF
	cCodgHtml += '<body>'+CRLF
	cCodgHtml += '<p>Obrigado por comprar na Ribeiro<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF
	cCodgHtml += '<p>segue seu boleto que vencerá nos próximos dias.<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF

	cCodgHtml += '<p>Em caso de dúvidas, entrar em contato via financeiro@ribeiro.ind.br <em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF

	cCodgHtml += '</body>'+CRLF
	cCodgHtml += '</html>'+CRLF
	//tira os ENTER, pois a função de envio substitui por <BR> <BR>
	cCodgHtml := StrTran(cCodgHtml,CRLF,'')
	 
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
	   
	//Desconecta do servidor
	If oServer:SmtpDisconnect() != 0
	    Alert( "Erro ao disconectar do servidor SMTP" )
	    Return .F.
	EndIf
    */
Return

