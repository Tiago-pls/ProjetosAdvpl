#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! CadZ50                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Valor Compra                                            !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                            !
+------------------+---------------------------------------------------------!
!Data              ! 21/09/2022                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/
User Function CadZ50
Local cAlias := "Z50"
Private cCadastro := "Simulação Custo Produto"
Private aRotina := {}

AADD(aRotina,{"Pesquisar" ,"AxPesqui",0, 1})
AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})
AADD(aRotina,{"Incluir" ,"AxInclui",0,3})
AADD(aRotina,{"Alterar" ,"AxAltera",0,4})
AADD(aRotina,{"Excluir" ,"AxDeleta",0,5})
mBrowse(6,1,22,75,cAlias)	
Return


user function CalcST(cTipo)
nRet :=0
if M->Z50_CALCST=='1'
    nRet :=  (M->Z50_TOTAL/M->Z50_QUANTI)*(1+35/100)*u_PEst(M->Z50_ESTADO)
    if cTipo =='1'
       nRet +=  M->Z50_CUSTO
    Endif
else
    nRet := M->Z50_CUSTO
Endif
Return nRet


user function PEst(cEst)
nRet:=0
if (cEst $ 'RS|SP|PR|SC|RJ')
    nRet := 0.0385
Elseif cEst $ 'PE|ES'
    nRet := 0.0288
Endif

//iif(M->Z50_CALCST =='1',((M->Z50_CUSTO*(1+35/100))*0.0288)+(M->Z50_CUSTO*(1-9.25/100)),M->Z50_CUSTO)
return nRet

user function CredICMS
Return (round(M->Z50_TOTAL/ M->Z50_QUANTI ,2)  *(1-9.25/100))

user function RetST
nPercEst := u_RetPEst(M->Z50_ESTADO)
Return ((M->Z50_CUSTO*(1+35/100)) * nPercEst)
