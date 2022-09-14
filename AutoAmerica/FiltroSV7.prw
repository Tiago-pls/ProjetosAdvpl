user Function F3SV7Filtro()


	Local cFiltro := ""

	If Type("cDataIni")  == "U"
		Private cDataIni := RCH->RCH_DTINI
		Private cDataFim := RCH->mRCH_DTFIM
	Endif
	
	cFiltro := "SV7->V7_FILIAL == SRA->RA_FILIAL "
	cFiltro += ".And. SV7->V7_MAT == SRA->RA_MAT"
	cFiltro += ".And. SV7->V7_STAT == '1' "
	cFiltro += " and. (" + AnoMes(SV7->V7_DTINI) + "<= " +  AnoMes(dDataBase)
	cFiltro += ".And. " + AnoMes(SV7->V7_DTFIM) >= " + "+ Anomes(dDataBase) + ") "
	
	cFiltro := "@#" + cFiltro + "@#"

Return cFiltro
