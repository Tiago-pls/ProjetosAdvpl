user function ffaaff

cTst := "Os produtos descritos na presente nota fiscal estao sob egide de legislacao tributaria com beneficios fiscais atinentes a instalacao no consumidor final e utilizacao exclusiva em sistema de geracao de energia fotovoltaica, pelo que fica vedada sua circulacao e/ou venda de pecas ou componentes separadamente, bem como a utilizacao para finalidade diversa. Isento de ICMS conforme convenio 101/97, prorrogado pelo convenio10/14 ate 31/12/2021. DADOS PARA DEPOSITO: BANCO SANTANDER (33) - AG: 3945 - C/C: 13-003406-6. Alienação Fiduciária ao Banco Santander (Brasil) S.A. - Av. Pres. J. Kubitsshek 2041/2235A São Paulo CNPJ/MF 090.400.888/0001-02."
nCont := 1
Ctst2 := ""
nLimCor := 125 // limite de caracteres para impressão do conteudo da tag xCorrecao
If ! Empty(cTst)
    While nCont < Len(cTst)
   
        cAtual :=SubStr(cTst, nCont, nLimCor )
        nUlt:= Rat( " ", cAtual)
        Ctst2+= SubStr(cTst, nCont, nUlt ) + Chr(13) + Chr(10)
        if nUlt == 0 // não encontrou o espaço em branco
            nCont += Len(cAtual)
        Else
            nCont += nUlt
        Endif
        
    Enddo

Endif

return
