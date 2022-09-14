#Include "AP5MAIL.CH"


User Function OpenSendMail(cFrom, cTo, cCC, cSubject, cMsg, cAttach)
********************************************************************
lEmOk:= U_SendMail(cTo, cCC, cSubject, cMsg,.T., cAttach, cFrom)

/*
Local cServer    := GetMV("MV_RELSERV"),;
cAccount   := GetMV("MV_RELACNT"),;
cPassword  := GetMV("MV_RELPSW"),;
lAutentica := GetMv("MV_RELAUTH")
Local lEmOk, cError
Begin Sequence
If !Empty(cServer) .and. !Empty(cAccount)
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lEmOk
	If lEmOk
		If lAutentica
			If !MailAuth(cAccount, cPassword)
				DISCONNECT SMTP SERVER
				MsgInfo("Falha na Autenticacao do Usuario","Alerta")
				lEmOk := .F.
				Break
			EndIf
		EndIf
		
		If cAttach <> Nil
			SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cMsg ATTACHMENT cAttach Result lEmOk
		Else
			SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cMsg Result lEmOk
		Endif
		If !lEmOk
			GET MAIL ERROR cError
			MsgInfo("Erro no envio de Email - "+cError+" O e-mail '"+cSubject+"' n�o p�de ser enviado.", "Alerta")
		Else
			Conout("E-mail de notifica��o enviado com sucesso.")
		EndIf
		DISCONNECT SMTP SERVER
	Else
		GET MAIL ERROR cError
		DISCONNECT SMTP SERVER
		MsgInfo("Erro na conex�o com o servidor de Email - "+cError+"O e-mail '"+cSubject+"' n�o p�de ser enviado.","Alerta")
	EndIf
Else
	MsgInfo("N�o foi poss�vel enviar o e-mail porque o as informa��es de servidor e conta de envio n�o est�o configuradas corretamente.", "Alerta")
EndIf
End Sequence
*/
Return lEmOk
