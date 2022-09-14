#include 'totvs.ch'
#include 'topconn.ch'
#include "SHELL.CH"

/*/
 Geração CNAB para roteiros VTR e VAL.
@author Tiago Santos - SMS
@since 06/02/2020
@version P12
/*/

user FUNCTION CNABBEN

// Verificar se a execução do CNAB é para os benefícios
lCnabBen := MSGYESNO( "CNAB para geração dos Benefícios", "Atenção" )
private cNomRel   := "CNABBEN"

if !lCnabben

    GPEM080()// Função Padrão para geração do arquivo CNAB

else
    fCriaSx1(cNomRel)
	if !pergunte(cNomRel, .T.)
        return nil
    endif
	

    Processa({|| ProcVALBEN() }, "Processando dados", "Aguarde... Calculando tempo necessário para listagem dos dados.")
	GPEM080() // Função Padrão para geração do arquivo CNAB
       
Endif
return

/*/
 Cópia dos valores dos Benefícios para geração do líquido na Folha em tempo de execução do CNAB
 para posterior exclusão
@author Tiago Santos - SMS
@since 06/02/2020
@version P12
/*/

Static function ProcVALBEN

// Pesquisar os valores calculados na tabela SR0, com o campo R0_TPVALE = 0

cQuery := "Select * from "+ RetSqlName("SR0") + " SR0"
cQuery += " Where R0_TPVALE ='0' and R0_VALCAL <> 0 and SR0.D_E_L_E_T_ =' '"

TCQuery cQuery Alias QRY NEW

dbselectArea('QRY')
QRY->( dbgotop())

cVerba := posicione("SRV",2,xFilial("SRV")+"0047","RV_COD") 
cPeriodo := AnoMes( mv_par01)

if select("SRC")==0
	DbSelectArea("SRC")
Endif

SRC->(DbSetorder(4)) //RC_FILIAL+RC_MAT+RC_PERIODO+RC_ROTEIR+RC_SEMANA+RC_PD 

While QRY->( ! EOF())

	// verificar se existe o valor gravado na tabela SRC para gerar o líquido dos benefícios

	cChave := SR0->( R0_FILIAL + R0_MAT)+ cPeriodo + 'FOL01'+cVerba

	SRC->( DbGotop())
	
	if SRC->( DbSeek( cChave)) // achou, então atulizar os valores
		GravaSRC(.F.) // alteração	
	else
		GravaSRC(.T.) // Inclusão
	Endif
	QRY->( DBSKIP(  ))
enddo
RETURN
/*/
 Grava Valores dos Benefícios na SRC para posteriormente excluílos
@author Tiago Santos - SMS
@since 06/02/2020
@version P12
/*/

static Function GravaSRC(linclusao)


if linclusao
	RecLock("SRC", .T.)	
		SRC->RC_FILIAL  := QRY->R0_FILIAL	
		SRC->RC_MAT     := QRY->R0_MAT
		SRC->RC_PD      := cVerba	
		SRC->RC_VALOR   := QRY->R0_VALCAL	
		SRC->RC_SEMANA  := '01'
		SRC->RC_TIPO1   := 'V'
		SRC->RC_DATA    := mv_par01	
		SRC->RC_DTREF   := mv_par01	
		SRC->RC_CC      := QRY->R0_CC
		SRC->RC_TIPO2   := "I"
		SRC->RC_PROCES  := "00001"
		SRC->RC_PERIODO := ""
		SRC->RC_ROTEIR  := "FOL"
	MsUnLock() // Confirma e finaliza a operação

else
	RecLock("SRC", .F.)	
		SRC->RC_VALOR   := QRY->R0_VALCAL	
	MsUnLock() // Confirma e finaliza a operação
endif



Return

/*/
Funcao para criar o pergunte necessários para o funcionamento do relatório
@author Tiago Santos - SMS
@since 06/02/2020
@version P12
/*/
static function fCriaSx1(cPerg)
	local aPerg := {}
	local i, j

	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	
	cPerg := padR(cPerg, Len(SX1->X1_GRUPO))

	if !SX1->(msSeek(cPerg, .F.)) // Caso seja necessario recriar todos os registros deverão ser excluídos
		aAdd(aPerg, {cPerg, "01", "Data Ref"   , "", "", "mv_ch1", "D", 08, 0, 1, "G", "", "mv_par01"})
		
		For i := 1 to Len(aPerg)
			RecLock("SX1", .T.)
			For j := 1 to SX1->(FCount())
				If j <= Len(aPerg[i])
					FieldPut(j, aPerg[i,j])
				Endif
			Next j
			SX1->(MsUnlock())
		Next i

		SX1->(msUnlock())
	EndIf
return nil