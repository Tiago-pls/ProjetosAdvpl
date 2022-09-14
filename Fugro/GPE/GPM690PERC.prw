#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"

user function GPM690PERC 
Local aArea := GetArea()
Local nNovoSal := SRA->RA_SALARIO * (1 + (nPercDif /100))
Local nDif := Round(nNovoSal,2)  -  int(  Round(nNovoSal,2)) 

if SRA->RA_SALARIO < 8000
    if  nDif > 0.00
        nValAum := int(  Round(nNovoSal,2))  - SRA->RA_SALARIO
        If nDif >= 0.10
            nValAum +=1
        Endif
        nPercDif := 0
    Endif
endif
RestArea(aArea)
Return 
/*aFaixas  =  Armazena  as faixas salariais e percentuais informados nos parâmetros.
nPercDif  = Percentual do aumento que será aplicado ao salário.
nValAum = Valor do aumento que será aplicado ao salário
cDatArq   = Ano/Mês que está sendo processado o cálculo. 
*/
