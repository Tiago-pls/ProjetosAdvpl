#Include 'Protheus.ch'
 
User Function CNT121BT()
 
    If Type('aRotina') == 'A'
    //Adicionando no array aRotina o bot�o   
        aAdd(aRotina,{"Bot�o Ponto de Entrada","U_BtnPonto()",0,1,0,NIL,NIL,NIL})
    Endif
Return
 
User Function BtnPonto()
    Alert( 'Ac�o adicionada via ponto de entrada CNT121BT.' )
Return
