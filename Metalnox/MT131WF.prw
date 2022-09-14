#Include 'Protheus.ch'

User Function MT131WF()
	Local aParam := Paramixb
	Local cFrom := ""
	Local cTo := ""
	Local cMsg := ""
	Local cSubject := ""
	Local cCC := ""
	Local cAttach := ""
	Local cMD5 := ""
	LOCAL cFileini := GetSrvProfString ("ROOTPATH","")+GetSrvProfString ("STARTPATH","")+"TEXTOSCOTACAOOLINE.INI"
	local serverhttp := GetPvProfString("CONFHTTP", "SERVERHTTP","",cFileini,,)
	local portahttp := GetPvProfString("CONFHTTP", "PORTAHTTP","",cFileini,,)
	
	conout("Tamanho aParam: "+Strzero(Len(aParam),6))
	dbSelectArea("SC8")
	dbSetOrder(1)
	dbSeek(xFilial("SC8")+aParam[1],.T.)
	While !Eof().and.(SC8->C8_FILIAL == xFilial("SC8")).and.(SC8->C8_NUM == ParamIxb[1])
	
			
		cNum     := SC8->C8_num
		cFornece := SC8->C8_fornece+SC8->C8_loja
		
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2")+cFornece,.T.)
		
		cMD5 := MD5(SC8->C8_num+SA2->A2_CGC,2)
		
		While !Eof().and.(SC8->C8_filial == xFilial("SC8")).and.(cNum == SC8->C8_num).and.;
				(cFornece == SC8->C8_fornece+SC8->C8_loja)
					
				Reclock("SC8",.F.)
					SC8->C8_MD5 := cMD5
					SC8->C8_CODUSR := RetCodUsr()
				MsUnlock()
				
			dbSelectArea("SC8")
			dbSkip()
		Enddo
		
		cFrom := GetMV("MV_RELACNT")
		cTo := ALLTRIM(SA2->A2_EMAILC)
		IF EMPTY(cTo)
			ALERT("Atenção! Campo A2_EMAILC(E-mail Cotação) NAO PREENCHIDO! Fornecedor " + SA2->A2_COD+"/"+SA2->A2_LOJA + " - " + SA2->A2_NOME + " "  )
			RETURN
		ENDIF
		cSubject := "Cotação de Compras nr. : "+ cNum
		cMsg := ""
		cMsg += " <html>                                                                                                                    "
		cMsg += " <head>                                                                                                                              "
		//cMsg += " <meta charset='utf-8'>                                                                                                              "
		//cMsg += " <meta http-equiv='X-UA-Compatible' content='IE=edge'>                                                                               "
		cMsg += "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
		cMsg += "<meta name='viewport' content='width=device-width, initial-scale=1.0'> "                                                           "
		cMsg += " <title>Cotação De Compras</title>                                                                                                   "
		cMsg += " <link rel='stylesheet' href='css/bootstrap.min.css'>                                "
		cMsg += " <script src='js/jquery.min.js'></script>                                            "
		cMsg += " <script src='js/bootstrap-datepicker.js'></script>                "
		cMsg += " <script src='js/jquery.maskMoney.min.js' type='text/javascript'></script> "
		cMsg += " <script src='js/bootstrap.min.js'></script>                                         "
		cMsg += " <script src='js/funcoes.js' type='text/javascript'></script> "
		cMsg += " </head>                                                                                         "
	
		cMsg += "<header>
		cMsg += "<div class='top1'>"
		cMsg += "<div class='main'>"
		cMsg += "<center><a href='" + GetPvProfString("LINKIMAGEMEMAIL", "CLICKIMAGEM","",cFileini,,) + "'><img src='" + GetPvProfString("LINKIMAGEMEMAIL", "IMAGEM","",cFileini,,) + "'  height='100' border='0'></a></center>"
		cMsg += "</div>"
		cMsg += "</header>"
		cMsg += "</div>"
		cMsg += "  <body>"
		cMsg += "  <p></p>"
		cMsg += "  <p></p>"
		
		cMsg += "  <p>" + GetPvProfString("ENVEMAILCOTACAO", "LINHA1","",cFileini,,) + "</p>"
		cMsg += "  <p>" + GetPvProfString("ENVEMAILCOTACAO", "LINHA2","",cFileini,,) + "</p>"
		cMsg += "  <p>" + GetPvProfString("ENVEMAILCOTACAO", "LINHA3","",cFileini,,) + "</p>"
		cMsg += "  <p>" + GetPvProfString("ENVEMAILCOTACAO", "LINHA4","",cFileini,,) + "</p>"
		cMsg += "  <p>" + GetPvProfString("ENVEMAILCOTACAO", "LINHA5","",cFileini,,) + "</p>"
		cMsg += "  <p>" + GetPvProfString("ENVEMAILCOTACAO", "LINHA6","",cFileini,,) + "</p>"
		cMsg += "  <p>" + GetPvProfString("ENVEMAILCOTACAO", "LINHA7","",cFileini,,) + "</p>"
		cMsg += "  <p>" + GetPvProfString("ENVEMAILCOTACAO", "LINHA8","",cFileini,,) + "</p>"
		cMsg += "  <p>" + GetPvProfString("ENVEMAILCOTACAO", "LINHA9","",cFileini,,) + "</p>"
		cMsg += "  <p>" + GetPvProfString("ENVEMAILCOTACAO", "LINHA10","",cFileini,,) + "</p>"
		
		
		cMsg += " <a href='http://" + serverhttp + ":" + portahttp + "/u_msh01.apw?id="+cMD5+"&cf="+cfilant+"'>Processo de Cotação Número: "+cNum+"</a>"
		cMsg += "  <p></p>"
		cMsg += "  <p></p>"
		cMsg += "<br> "
		cMsg += "<br> "
		cMsg += "<footer>"
		cMsg += "<div class='main'>"
		cMsg += "<div class=inside'>"
		cMsg += "<div class='container'>"
		cMsg += "<div class='fright'><!--{%FOOTER_LINK}--></div>"
		cMsg += "<div class='fleft'>"
		cMsg += "<span>" + GetPvProfString("RODAPEEMAIL", "TEXTO","",cFileini,,) + "</span> &copy; " + GetPvProfString("RODAPEEMAIL", "ANO","",cFileini,,) + " &bull;"
		cMsg += "</div>"
		cMsg += "</div>"
		cMsg += "</div>"
		cMsg += "</div>"
		cMsg += "</footer>"			
		
		cMsg += "  </body>"
		cMsg += "</html>"
		
		U_OpenSendMail(cFrom, cTo, cCC, cSubject, cMsg, cAttach)

	Enddo
	

	Conout("Total de Linhas ==> "+Strzero(Len(ParamIxb),4))
Return()
