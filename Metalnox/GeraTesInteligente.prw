//#INCLUDE "RWMAKE.CH"
#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! AtuSB1                                                  !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o       ! Rotina para cadastro de Tipos de Alteções Salariais   !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                      !
+------------------+---------------------------------------------------------!
!Data              ! 14/09/2022                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/

user function AtuFSM

Local cTitulo   := "Selecione o Diretorio para Importar Banco de Horas..."
Local nMascpad  := 0                        
Local cDirini   := "\"
Local nOpcoes   := GETF_LOCALHARD
Local lArvore   := .F. /*.T. = apresenta o ?rvore do servidor || .F. = n?o apresenta*/   
Local lSalvar   := .F. /*.T. = Salva || .F. = Abre*/
                                                                            
cArq := cGetFile( '*.csv|*.csv' , cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)
If !File(cArq)
	MsgStop("O arquivo  nao foi encontrado. A importacao sera abortada!","[AEST901] - ATENCAO")
	Return
EndIf       
MsAguarde({|| ProcArq(cArq)}, "Aguarde...", "Processando Registros...")
return

static function ProcArq(cArq)  
FT_FUSE(cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()        
aDados := {}     
lPrim := .T.
nQtd := 0
While !FT_FEOF()
	IncProc("Lendo arquivo texto..." + cValToChar(nQtd))
	cLinha := FT_FREADLN()
    If lPrim
		lPrim := .F.
	Else  		  
		nQtd += gravaSFM( Separa( cLinha,";",.T.))                                                  
	EndIf
	FT_FSKIP()
EndDo
return

static function gravaSFM( aDados)
Local nImp := 1
Local nCont :=1
/*
1 - Centro de Custos - aba Ativos OK 558 registros
2 -
    Conta contabil - MC tipo de produto 12 + 39 = 51
    Conta contabil - EM tipo de produto 12 + 39 = 51
    total 660 registros

3 - 
    alltrim(aDados[9]) <>'aba ativos' .and. 
    empty(Alltrim(aDados[10])) .and. 
    empty(Alltrim(aDados[5]))

    218 registros
    total 878 registros


trocou o campo TIPOPRODUTO de MC/EM para 1


Local nImp := 1
Local nCont :=1

if alltrim(aDados[9]) <>'aba ativos' .and. empty(Alltrim(aDados[10]))  .and. empty(Alltrim(aDados[5]))// Centro Custo    
       // msgalert(aCC[nCont])
        // gravar um registro da aDados para cada CC     
        if RecLock("SFM",.T.)
            SFM->FM_FILIAL    := alltrim( aDados[3])
            SFM->FM_ID        := soma1(cValtoChar(nImp))
            SFM->FM_DESCR     := Left(alltrim( aDados[2]), 50)
            SFM->FM_TIPO      := alltrim( aDados[4])
            SFM->FM_GRTRIB    := alltrim( aDados[6])
            SFM->FM_TE        := alltrim( aDados[7])            
            SFM->FM_ESTOQUE   := alltrim( aDados[8])
            SFM->FM_PRODUTO   := alltrim( aDados[11])
            SFM->FM_TIPOPRO   := alltrim( aDados[12])
           // SFM->FM_POSIPI    := alltrim( aDados[14])
            MsUnLock("SFM")
        endif  
            nImp +=1     
    
endif


if alltrim(aDados[9]) ='aba ativos'// Centro Custo
    aCC := RetCC()
    For nCont :=1 to len(aCC)
       // msgalert(aCC[nCont])
        // gravar um registro da aDados para cada CC
     
        if RecLock("SFM",.T.)
            SFM->FM_FILIAL    := alltrim( aDados[3])
            SFM->FM_ID        := soma1(cValtoChar(nImp))
            SFM->FM_DESCR     := Left(alltrim( aDados[2]), 50)
            SFM->FM_TIPO      := alltrim( aDados[4])
            //SFM->FM_GRTRIB    := alltrim( aDados[6])
            SFM->FM_PRODUTO   := alltrim( aDados[11])
            SFM->FM_TE        := alltrim( aDados[7])
            SFM->FM_ESTOQUE   := alltrim( aDados[8])
            SFM->FM_CC        := alltrim( aCC[nCont])
            SFM->FM_TIPOPRO   := alltrim( aDados[12])
           // SFM->FM_POSIPI    := alltrim( aDados[14])
            MsUnLock("SFM")
        endif  
            nImp +=1
    Next nCont
endif


if  '/' $ alltrim(aDados[10])// Conta Contabil
    aConta := Separa( alltrim(aDados[10]),"/",.T.)
    For nCont :=1 to len(aConta)
  
        if RecLock("SFM",.T.)
            SFM->FM_FILIAL    := alltrim( aDados[3])
            SFM->FM_ID        := '000001'
            SFM->FM_DESCR     := Left(alltrim( aDados[2]), 50)
            SFM->FM_TIPO      := alltrim( aDados[4])
            SFM->FM_EST       := alltrim( aDados[13])
            SFM->FM_GRTRIB    := alltrim( aDados[6])
            //SFM->FM_PRODUTO   := alltrim( aDados[11])
            SFM->FM_TE        := alltrim( aDados[7])
            SFM->FM_ESTOQUE   := alltrim( aDados[8])
            SFM->FM_CONTA     := alltrim( aConta[nCont])
            SFM->FM_TIPOPRO   := alltrim( aDados[12])
            //SFM->FM_POSIPI    := alltrim( aDados[14])
            MsUnLock("SFM")
        endif          
    Next nCont
endif
*/
/*
if alltrim(aDados[12]) $'/' // grupo Produto
    aGrupoSB1 := Separa( alltrim(aDados[12]),"/",.T.)
    For nCont :=1 to len(aGrupoSB1)
  
        if RecLock("SFM",.T.)
            SFM->FM_FILIAL    := alltrim( aDados[3])
            SFM->FM_ID        := '000001'
            SFM->FM_DESCR     := Left(alltrim( aDados[2]), 50)
            SFM->FM_TIPO      := alltrim( aDados[4])
            SFM->FM_EST       := alltrim( aDados[13])
            SFM->FM_GRTRIB    := alltrim( aDados[6])
            SFM->FM_PRODUTO   := alltrim( aDados[11])
            SFM->FM_TE        := alltrim( aDados[7])
            SFM->FM_ESTOQUE   := alltrim( aDados[8])
            SFM->FM_CONTA     := alltrim( aConta[nCont])
            SFM->FM_TIPOPRO   := alltrim( aGrupoSB1[ncont])
            SFM->FM_POSIPI    := alltrim( aDados[14])
            MsUnLock("SFM")
        endif  

    Next nCont    
endif
  
if alltrim(aDados[10]) =='aba uso.consumo.servicos'
endif
if len(alltrim(aDados[12])) =2 .and.  Empty(alltrim(aDados[9])).and.  Empty(alltrim(aDados[10]))// grupo Produto e CC em branco
       if RecLock("SFM",.T.)
            SFM->FM_FILIAL    := alltrim( aDados[3])
            SFM->FM_ID        := soma1(cValtoChar(nImp))
            SFM->FM_DESCR     := Left(alltrim( aDados[2]), 50)
            SFM->FM_TIPO      := alltrim( aDados[4])
            SFM->FM_EST       := alltrim( aDados[13])
            SFM->FM_GRTRIB    := alltrim( aDados[6])
            SFM->FM_PRODUTO   := alltrim( aDados[11])
            SFM->FM_TE        := alltrim( aDados[7])
            SFM->FM_ESTOQUE   := alltrim( aDados[8])
            SFM->FM_CC        := alltrim( aCC[nCont])
            SFM->FM_TIPOPRO   := alltrim( aDados[12])
            SFM->FM_POSIPI    := alltrim( aDados[14])
            MsUnLock("SFM")
        endif 
Endif

if  '/' $ alltrim(aDados[5])// Grupo trib Produto
    aGrupoSB1 := Separa( alltrim(aDados[5]),"/",.T.)
    For nCont :=1 to len(aGrupoSB1)
        cTeste:=""
       if RecLock("SFM",.T.)
            SFM->FM_FILIAL    := alltrim( aDados[3])
            SFM->FM_ID        := soma1(cValtoChar(nImp))
            SFM->FM_DESCR     := Left(alltrim( aDados[2]), 50)
            SFM->FM_TIPO      := alltrim( aDados[4])
            SFM->FM_GRPROD    := aGrupoSB1[nCont]
            SFM->FM_GRTRIB    := alltrim( aDados[6])
            SFM->FM_TE        := alltrim( aDados[7])
            SFM->FM_ESTOQUE   := alltrim( aDados[8])            
            SFM->FM_PRODUTO   := alltrim( aDados[11])
            SFM->FM_TIPOPRO   := alltrim( aDados[12])                    
            SFM->FM_EST       := alltrim( aDados[13])
            SFM->FM_POSIPI    := alltrim( aDados[14])
            MsUnLock("SFM")
        endif
       
    Next nCont
Endif
  */

if alltrim(aDados[4]) ='FV'
       if RecLock("SFM",.T.)
            SFM->FM_FILIAL    := alltrim( aDados[3])
            SFM->FM_ID        := soma1(cValtoChar(nImp))
            SFM->FM_DESCR     := Left(alltrim( aDados[2]), 50)
            SFM->FM_TIPO      := alltrim( aDados[4])
            SFM->FM_TE        := alltrim( aDados[7])
            SFM->FM_ESTOQUE   := alltrim( aDados[8])
            SFM->FM_GRTRIB    := alltrim( aDados[6])
            MsUnLock("SFM")
        endif 
Endif
return 1

static function RetCC ()
local aRet :={}

aadd( aRet, '2210001')
aadd( aRet, '2210002')
aadd( aRet, '2210003')
aadd( aRet, '2210004')
aadd( aRet, '2210005')
aadd( aRet, '2210006')
aadd( aRet, '2210007')
aadd( aRet, '2210008')
aadd( aRet, '2210009')
aadd( aRet, '2210010')
aadd( aRet, '2210011')
aadd( aRet, '2210012')
aadd( aRet, '2210013')
aadd( aRet, '2220001')
aadd( aRet, '2220006')
aadd( aRet, '2220009')
aadd( aRet, '2220010')
aadd( aRet, '2220012')
aadd( aRet, '2220013')
aadd( aRet, '2230001')
aadd( aRet, '2240001')
aadd( aRet, '2250001')
aadd( aRet, '23001')
aadd( aRet, '23002')
aadd( aRet, '23003')
aadd( aRet, '23005')
aadd( aRet, '23006')
aadd( aRet, '23007')
aadd( aRet, '23008')
aadd( aRet, '5110003')
aadd( aRet, '5120003')
aadd( aRet, '5130003')
aadd( aRet, '5140003')
aadd( aRet, '5210007')
aadd( aRet, '5220006')
aadd( aRet, '5220007')
aadd( aRet, '5220009')
aadd( aRet, '5220010')
aadd( aRet, '5230006')
aadd( aRet, '5230007')
aadd( aRet, '5230009')
aadd( aRet, '5240006')
aadd( aRet, '5240007')
aadd( aRet, '5240009')
aadd( aRet, '5240012')
aadd( aRet, '5240013')
aadd( aRet, '5240014')
aadd( aRet, '5240015')
aadd( aRet, '5240016')
aadd( aRet, '5240017')
aadd( aRet, '5240018')
aadd( aRet, '5240019')
aadd( aRet, '5240020')
aadd( aRet, '5240021')
aadd( aRet, '5240022')
aadd( aRet, '5240023')
aadd( aRet, '5240024')
aadd( aRet, '5240025')
aadd( aRet, '5240026')
aadd( aRet, '5240027')
aadd( aRet, '5240028')
aadd( aRet, '5240029')

return aRet
