#include "totvs.ch"

/*/{Protheus.doc} FA070TIT
O ponto de entrada FA070TIT sera executado apos a confirmacao da baixa do contas a receber.

Programa Fonte
FINA070.PRW
Sintaxe
FA070TIT - Confirma baixa a receber ( < nParciais> ) --> URET

Parâmetros:
Nome			Tipo			Descrição			Default			Obrigatório			Referência	
nParciais			Numérico									X				
Retorno
URET(logico)
.T./.F. - Se retornar .F. a baixa não será efetuada.

@type function
@version 1.0
@author Pedro
@since 21/10/2023
@return logical, .t. se a baixa deve ser efetuada, .f. cc
/*/
user function FA070TIT
    local lRet := .t.
    if cFilAnt == "070101" .and. SE1->E1_PREFIXO == "MCV"
        // TODO - verificar se gera comissao 
		startJob("U_adMCti", GetEnvServer(), .F., {cEmpAnt, "070101", SE1->(recno())})
    endif
return lRet
