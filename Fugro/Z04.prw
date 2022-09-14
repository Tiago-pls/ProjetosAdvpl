User Function Z04()
	Local cAlias := "Z04"
	Private cCadastro := "Hist Superiores Imedia"
	Private aRotina := {}
	AADD(aRotina,{"Pesquisar" ,"AxPesqui",0, 1})
	AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})
	AADD(aRotina,{"Incluir" ,"AxInclui",0,3})
	AADD(aRotina,{"Alterar" ,"AxAltera",0,4})
	AADD(aRotina,{"Excluir" ,"AxDeleta",0,5})

//		AxCadastro(cAlias, cCadastro)
	mBrowse(6,1,22,75,cAlias)
	
Return