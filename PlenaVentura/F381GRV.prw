#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
/*/{Protheus.doc} F381GRV
Ponto de entrada que permite a manipulação do título aglutinador. É chamado logo na geração da SE2 do título de aglutinação, estando posicionado no mesmo.


@author Tiago Santos
@since 18/04/2023
@version 1.0
@return aBotoes, array, Lista com os botoes
https://tdn.totvs.com.br/pages/releaseview.action?pageId=645692043
/*/

user function F381GRV
Local aArea := GetArea()

SE2->E2_VENCTO := MV_PAR02
SE2->E2_VENCREA := MV_PAR02
SE2->E2_VENCORI := MV_PAR02

RestArea(aArea)
return
