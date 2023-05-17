*-------------------------------------------------------------------------------------------
user function Fa740Brw
* Ponto de entrada para inclusão de itens no aRotina de Fina740 (funções a receber)
* Ricardo Luiz da Rocha 24/11/2015 GNSJC
*-------------------------------------------------------------------------------------------
_vReturn:={{"Desconto RM","U____F055It",0,4}}

	//aAdd( _vReturn, { 'Boleto Vencido'  , "u_BolVencido()", 0 , 2})
	//aAdd( _vReturn, { 'Atu Valor TIN(RM)',"u_F0101001()",   0 , 2})
	//aAdd( _vReturn, { 'Renegociação',     "u_F0102001()",   0 , 2})
	//aAdd( _vReturn, { 'Gerar Titulo Parcial',"u_F0103001()",0 , 2})
	// solicitacao Lindamir
	if FwCodEmp()<>'10'
		aAdd( _vReturn, { '2º Via de Boleto',"u_PVBOLREN()",0 , 2})
	Endif
Return _vReturn
