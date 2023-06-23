#include "protheus.ch"
#include "msole.ch"

user function Sign(cArquivo, cArqDig, cPassword)
	Local nVezes := 0
	Local cRemoteLocation := GetClientDir()

	Local cBatFile := "sign-"+cValToChar(ThreadID())+".bat"
	Local cLogFile := "log-"+cValToChar(ThreadID())+".txt"
	Local cSignedFile := StrTran(SubStr(cArquivo,rAt("\",cArquivo)+1),".pdf","_signed.pdf")
	Local cFileLocation := SubStr(cArquivo,1,rAt("\",cArquivo))

	//Local cPassword := alltrim(mv_par08)

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

	//se passou 15 segundos e não gerou o PDF, deu algo errado
	IF nVezes > 15
		Aviso("Atenção", "Arquivo PDF não encontrado para assinatura. Tente novamente", {"Sair"}, 1)
		Return
	EndIF

	//nunca vai acontecer, mas se tentar assinar um arquivo já assinado (mesmo nome)
	IF File(cFileLocation + cSignedFile)
		//exclui
		fErase(cFileLocation + cSignedFile)
	EndIF

	//gera o .BAT com instrução de assinatura
	//foi feito isso para poder capturar o resultado da assinatura
	MemoWrite(cRemoteLocation+cBatFile,'java -jar JSignPdf.jar -kst PKCS12  -ksf "'+cArqDig+'" -ksp '+cPassword+' -V "'+cArquivo+'" -llx 490 -lly 11 -urx 805 -ury 90 -pg 2  -d '+cFileLocation)


	//se não encontrar o BAT, alguma coisa deu errado
	IF ! File( cRemoteLocation + cBatFile)
		Aviso("Atenção", "Não foi possivel gerar o arquivo BAT para assinatura. Tente novamente", {"Sair"}, 1)
		Return
	EndIF

	//assina
	//WinExec abriu o DOS, shellExecute não
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
	//fErase( cRemoteLocation + cBatFile )

	//se passou 15 segundos e não gerou o PDF, deu algo errado
	IF nVezes > 15
		Aviso("Atenção", "Arquivo PDF assinatura não encontrado. Tente novamente ou assine manualmente." +CRLF+CRLF+StrTran(MemoRead(cRemoteLocation+cLogFile),"-ksp "+cPassword,"-ksp "+replicate("*",len(cPassword))), {"Sair"}, 3)
		fErase(cRemoteLocation + cLogFile)
		Return
	EndIF

	//exclui o arquivo original
	fErase( cArquivo)

	//gerou o arquivo assinado
	IF Aviso("Resultado", "Arquivo PDF assinado com sucesso." + CRLF+CRLF+ StrTran(MemoRead(cRemoteLocation+cLogFile),"-ksp "+cPassword,"-ksp "+replicate("*",len(cPassword))), {"Abrir","Sair"}, 3) == 1
		ShellExecute("open", cFileLocation + cSignedFile, "", "", 1)
	EndIF
Return

Static Function SyncJSignPDF()
	Local n1
	Local cRemoteLocation := GetClientDir()
	Local cServerLocation := "\SignPDF\"
	Local aFiles := {;
		"conf\conf.properties",;
		"conf\pkcs11.cfg",;
		"lib\bcprov-jdk15-146.jar",;
		"lib\commons-cli-1.2.jar",;
		"lib\commons-io-2.1.jar",;
		"lib\commons-lang3-3.1.jar",;
		"lib\jsignpdf-itxt-1.6.1.jar",;
		"lib\log4j-1.2.16.jar",;
		"JSignPdf.jar"}

	//pasta Sync
	cRemoteLocation += IIF( Right(cRemoteLocation,1) == "\","","\") + "SignPDF\"

	//cria as pastas dentro do remote
	MakeDir(cRemoteLocation)
	MakeDir(cRemoteLocation+"conf")
	MakeDir(cRemoteLocation+"lib")

	ProcRegua(len(aFiles))

	For n1 := 1 to len(aFiles)
		IncProc(aFiles[n1])
		IF ! File(cRemoteLocation + aFiles[n1])
			__CopyFile( cServerLocation + aFiles[n1], cRemoteLocation + aFiles[n1] )
		EndIF
	Next n1

Return
