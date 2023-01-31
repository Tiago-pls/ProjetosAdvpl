User Function MT089CD()

//As variaveis foram carregada com paramixb somente para verificar o condeudo original.
Local bCond     :=     PARAMIXB[1] //Condicao que avalia os campos do SFM
Local bSort     :=     PARAMIXB[2] //Forma de ordenacao do array onde o 1o elemento sera utilizado. Esse array inicialmente possui 9 posicoes
Local bIRWhile     :=     PARAMIXB[3] //Regra de selecao dos registros do SFM
Local bAddTes   :=     PARAMIXB[4] //Conteudo a ser acrescentado no array
Local cTabela     :=     PARAMIXB[5] //Tabela que esta sendo tratada
Local _cCampo
Local _nPosLocal

If cTabela == "SC7"
     /* ------------- C.Custo ------------- */
    _nPosLocal := aScan(aHeader, {|x| AllTrim(x[2])=="C7_CC"})
    _cCampo := acols[n][_nPosLocal]
    if !Empty(_cCampo)
          bCond     := {|| ( _cCampo == (cAliasSFM)->FM_CC.Or. Empty((cAliasSFM)->FM_CC) ) }
     else
          bCond     := {|| ( Empty((cAliasSFM)->FM_CC)) }
     Endif
     bSort     := {|x,y| x[11] > y[11]}
     bIRWhile:= {||.T.}
     bAddTes     := {||aAdd(aTes[Len(aTes)],(cAliasSFM)->FM_CC ) }
    
    /* ------------- ESTOQUE ------------- */
    
   _nPosLocal := aScan(aHeader, {|x| AllTrim(x[2])=="C7_TESEST"})
    _cCampo := acols[n][_nPosLocal]
    if !Empty(_cCampo)
          bCond     := {|| ( _cCampo == (cAliasSFM)->FM_ESTOQUE .Or. Empty((cAliasSFM)->FM_ESTOQUE) ) }
     else
          bCond     := {|| ( Empty((cAliasSFM)->FM_ESTOQUE)) }
     Endif
     bSort     := {|x,y| x[11] > y[11]}
     bIRWhile:= {||.T.}
     bAddTes     := {||aAdd(aTes[Len(aTes)],(cAliasSFM)->FM_ESTOQUE ) }

    /* ------------- Grupo Produto -------------   */
   _nPosLocal := aScan(aHeader, {|x| AllTrim(x[2])=="C7_PRODUTO"})
    _cCampo := acols[n][_nPosLocal]
    _cCampo := Posicione("SB1", 1, xFilial(cTabela) + _cCampo , "B1_TIPO")

    if !Empty(_cCampo)
          bCond     := {|| ( _cCampo == (cAliasSFM)->FM_TIPOPRO .Or. Empty((cAliasSFM)->FM_TIPOPRO) ) }
     else
          bCond     := {|| ( Empty((cAliasSFM)->FM_TIPOPRO)) }
     Endif
     bSort     := {|x,y| x[11] > y[11]}
     bIRWhile:= {||.T.}
     bAddTes     := {||aAdd(aTes[Len(aTes)],(cAliasSFM)->FM_TIPOPRO ) }

    /* ------------- Conta Contabil  -------------   */
   _nPosLocal := aScan(aHeader, {|x| AllTrim(x[2])=="C7_CONTA"})
    _cCampo := acols[n][_nPosLocal]

    if !Empty(_cCampo)
          bCond     := {|| ( _cCampo == (cAliasSFM)->FM_CONTA .Or. Empty((cAliasSFM)->FM_CONTA) ) }
     else
          bCond     := {|| ( Empty((cAliasSFM)->FM_CONTA)) }
     Endif
     bSort     := {|x,y| x[11] > y[11]}
     bIRWhile:= {||.T.}
     bAddTes     := {||aAdd(aTes[Len(aTes)],(cAliasSFM)->FM_CONTA ) }     
   
Else
     bCond     := {||.T.}
     bSort     := bSort
     bIRWhile:= {||.T.}
     bAddTes     := {||.T.}
EndIf

Return({bCond,bSort,bIRWhile,bAddTes})
