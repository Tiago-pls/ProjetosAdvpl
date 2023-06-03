#include "protheus.ch"
#include "msole.ch"

user function Sign(aArquivo)
	Local nVezes := 0
	Local cRemoteLocation := GetClientDir()

	Local cBatFile := "sign-"+cValToChar(ThreadID())+".bat"
	Local cLogFile := "log-"+cValToChar(ThreadID())+".txt"
	Local cSignedFile := StrTran(SubStr(cArquivo,rAt("\",cArquivo)+1),".pdf","_signed.pdf")
	Local cFileLocation := SubStr(cArquivo,1,rAt("\",cArquivo))

	Local cPassword := alltrim(mv_par03)

	//pasta Sync
	cRemoteLocation += IIF( Right(cRemoteLocation,1) == "\","","\") + "SignPDF\"

	//copia o programa do server para o remote
	Processa({||SyncJSignPDF()})

	//espera terminar de gerar o PDF
	sleep(5000)
	While ! File(cArquivo) .And. nVezes <= 15
		Sleep(1000)
		nVezes++
	EndDO

	//se passou 15 segundos e n�o gerou o PDF, deu algo errado
	IF nVezes > 15
		Aviso("Aten��o", "Arquivo PDF n�o encontrado para assinatura. Tente novamente", {"Sair"}, 1)
		Return
	EndIF

	//nunca vai acontecer, mas se tentar assinar um arquivo j� assinado (mesmo nome)
	IF File(cFileLocation + cSignedFile)
		//exclui
		fErase(cFileLocation + cSignedFile)
	EndIF

	//gera o .BAT com instru��o de assinatura
	//foi feito isso para poder capturar o resultado da assinatura
	MemoWrite(cRemoteLocation+cBatFile,'java -jar JSignPdf.jar -kst PKCS12  -ksf "'+alltrim(mv_par02)+'" -ksp '+cPassword+' -V "'+cArquivo+'" -llx 281 -lly 185 -urx 575 -ury 125 -d "'+cFileLocation+'"')

	//se n�o encontrar o BAT, alguma coisa deu errado
	IF ! File( cRemoteLocation + cBatFile)
		Aviso("Aten��o", "N�o foi possivel gerar o arquivo BAT para assinatura. Tente novamente", {"Sair"}, 1)
		Return
	EndIF

	//assina
	//WinExec abriu o DOS, shellExecute n�o
	//WinExec( cRemoteLocation + cBatFile + " > " + cRemoteLocation + cLogFile )
	shellExecute("Open", cRemoteLocation + cBatFile, " > " + cRemoteLocation + cLogFile, cRemoteLocation, 0)

	nVezes := 0
	//espera terminar de gerar o PDF
	sleep(5000)
	While ! File(cFileLocation + cSignedFile) .And. nVezes <= 15
		Sleep(1000)
		nVezes++
	EndDO

	//exclui o BAT
	fErase( cRemoteLocation + cBatFile )

	//se passou 15 segundos e n�o gerou o PDF, deu algo errado
	IF nVezes > 15
		Aviso("Aten��o", "Arquivo PDF assinatura n�o encontrado. Tente novamente ou assine manualmente." +CRLF+CRLF+StrTran(MemoRead(cRemoteLocation+cLogFile),"-ksp "+cPassword,"-ksp "+replicate("*",len(cPassword))), {"Sair"}, 3)
		fErase(cRemoteLocation + cLogFile)
		Return
	EndIF

	//exclui o arquivo original
	fErase( cArquivo)

	//gerou o arquivo assinado
	IF Aviso("Resultado", "Arquivo PDF assinado com sucesso." + CRLF+CRLF+ StrTran(MemoRead(cRemoteLocation+cLogFile),"-ksp "+cPassword,"-ksp "+replicate("*",len(cPassword))), {"Abrir","Sair"}, 3) == 1
		ShellExecute("open", cFileLocation + cSignedFile, "", "", 1)
	EndIF
	//exclui o log

	enviaPDF(cFileLocation, cSignedFile)

	fErase(cRemoteLocation + cLogFile)

Return
