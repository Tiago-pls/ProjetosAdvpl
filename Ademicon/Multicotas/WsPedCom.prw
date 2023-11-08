#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#Include "TBICONN.ch"
#include "Fileio.ch"

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+------------------+---------------------------------------------------------+
!Tipo              ! Web Service	                               			 !
!Módulo            ! Protheus x Fluig			       	                     !
!Cliente	       ! Ademicon    										     !
!Data de Criacao   ! 07/12/2020												 !
!Autor             ! Anderson José Zelenski - SMSTI		                     !
+------------------+---------------------------------------------------------+
!   						   MANUTENCAO        						     !
+---------+-----------------+------------------------------------------------+
!Data     ! Consultor		! Descricao                                      !
+---------+-----------------+------------------------------------------------+
!         !          		! 											     !
+---------+-----------------+-----------------------------------------------*/

// WebService FluigProtheus
WSSERVICE FluigProtheus DESCRIPTION 'Fluig x Protheus - Workflow'
	WSDATA oAprovacao				AS oAprovacao
    WSDATA aCentrosCustos 			AS oCentrosCustos
	WSDATA aProdutos 				AS oProdutos
	WSDATA aProdutosEstoque  		AS oProdutosEstoque
	WSDATA aMateriais 				AS oMateriais
	WSDATA oSolicitacao				AS oSolicitacao
	WSDATA oSolicitacaoArmazem		AS oSolicitacaoArmazem
	WSDATA aRelSolicitacaoArmazem	AS oRelSolicitacaoArmazem
	WSDATA aFornecedores			AS oFornecedores
	WSDATA aCadastros    			AS oCadastros									  
	
	WSDATA aConsultas				AS oConsultas
	WSDATA oDocEntr				    AS oDocEntr
	WSDATA oTitPg				    AS oTitPg
	WSDATA oTitPr				    AS oTitPr
	WSDATA oCliente				    AS oCliente
	WSDATA oPedVenda			    AS oPedVenda
	WSDATA oTitulo				    AS oTitulo

	WSDATA cCodigo					AS String
	WSDATA cStatus					AS String
	WSDATA SCRRecno					AS String
	WSDATA cSegmento				AS String
	WSDATA cLoginFluig				AS String
	WSDATA cDataInicial				AS String
	WSDATA cDataFinal				AS String
	WSDATA cCnpj					AS String
	WSDATA cFilBusca				AS String
	WSDATA cProd     				AS String
	WSDATA cFornece					AS String
	WSDATA cWhere					AS String
	WSDATA cTabela					AS String
	WSDATA cCampos					AS String							 
	WSDATA IDFLUIG					AS String	
	WSDATA cLoja					AS String
	WSDATA cValor					AS String	
	WSDATA cCodProduto				AS String	
	WSDATA cRateio					AS String	
	WSDATA cNotaFiscal				AS String
	WSDATA cEmissao					AS String
	WSDATA cOpc					    AS String

	WSDATA oMultiCotas              AS TMultiCotas
	WSDATA oIncForn					as TIncForn

	WSMETHOD AprovWFPC					DESCRIPTION 'Aprovar Workflow de Pedido de Compras'
	WSMETHOD LiberarPC					DESCRIPTION 'Liberar Pedido de Compras'
    WSMETHOD CentrosCustos				DESCRIPTION 'Listas todos os Centros de Custos'
	WSMETHOD Produtos					DESCRIPTION 'Listas todos os Produtos'
	WSMETHOD GerarSC					DESCRIPTION 'Gera a Solicitação de Compras'
	WSMETHOD GerarSA					DESCRIPTION 'Gera a Solicitação ao Armazém'
	WSMETHOD BuscarSA					DESCRIPTION 'Buscar a Solicitação ao Armazém'
	WSMETHOD AtualizaSA					DESCRIPTION 'Buscar a Solicitação ao Armazém'
	WSMETHOD BuscarFornecedor			DESCRIPTION 'Buscar fornecedor'
	WSMETHOD BuscarClientes				DESCRIPTION 'Buscar Clientes'
	WSMETHOD BuscarPR					DESCRIPTION 'Buscar PR do fornecedor'
	WSMETHOD BaixarSA					DESCRIPTION 'Baixa a Solicitação ao Armazém'
	WSMETHOD CancelarSA					DESCRIPTION 'Cancela a Solicitação ao Armazém'
	WSMETHOD Materiais					DESCRIPTION 'Listas todos os Materiais'
	WSMETHOD RelatorioSolicitacaoArmazem DESCRIPTION 'Retorna o relatório das Solicitações ao Armazém'
	WSMETHOD BuscarNF					DESCRIPTION 'Buscar Nota Fiscal do fornecedor'
	WSMETHOD BuscarNFEmissao			DESCRIPTION 'Buscar Nota Fiscal do fornecedor Emissão'
	WSMETHOD GerarNF					DESCRIPTION 'Gera a Solicitação de Compras'
	WSMETHOD GerarPg					DESCRIPTION 'Gera a Titulo a Pagar'
	WSMETHOD GerarPr					DESCRIPTION 'Gera a Titulo a Receber'
	WSMETHOD GerarCli					DESCRIPTION 'Cadastro de Cliente'
	WSMETHOD GerarCliPV					DESCRIPTION 'Cadastro de Cliente para Pedido de Venda'
	WSMETHOD ListaCadastro				DESCRIPTION 'Retorna uma lista de cadastro generico'
   	WSMETHOD GerarPV				    DESCRIPTION 'Cadastrar Pedido de Venda'
	WSMETHOD FaturarPV				    DESCRIPTION 'Faturar Pedido de Venda'
	WSMETHOD ProdutosEstoque    		DESCRIPTION 'Dados Produtos com Estoque'																		   	  
	WSMETHOD AtualizarTitulos			DESCRIPTION 'Atualizar Titulos'
	WSMETHOD OperarMultiCotas			DESCRIPTION 'Cria Estoque Cota Contemplada'
	WSMETHOD GerarFornecedor			DESCRIPTION 'Cadastro de Fornecedor'
ENDWSSERVICE

// Estrutura de Aprovação
WSSTRUCT oAprovacao
	WSDATA Filial			AS String
	WSDATA Pedido			AS String
	WSDATA Nivel			AS String
	WSDATA Acao				AS String 
	WSDATA Grupo			AS String
	WSDATA ItemGrupo		AS String
	WSDATA Login			AS String optional
	WSDATA SCRRecno			AS String
	WSDATA Comentario		AS String optional 
ENDWSSTRUCT

// Estrutura do Centro de Custo
WSSTRUCT oCentroCusto
	WSDATA Filial			AS String
    WSDATA Codigo			AS String
	WSDATA Descricao		AS String
    WSDATA DescWeb			AS String
ENDWSSTRUCT

// Estrutura dos Centros de Custos
WSSTRUCT oCentrosCustos
	WSDATA Itens AS ARRAY OF oCentroCusto
ENDWSSTRUCT


// Estrutura do Fornecedor
WSSTRUCT oFornecedor
 	WSDATA Codigo			AS String
	WSDATA Filial			AS String
	WSDATA Descricao		AS String
    WSDATA Situacao			AS String
	WSDATA Tipo				AS String
	WSDATA Banco			AS String
	WSDATA Agencia			AS String
	WSDATA Conta			AS String
ENDWSSTRUCT

// Estrutura do array dos Fornecedor
WSSTRUCT oFornecedores
	WSDATA Itens AS ARRAY OF oFornecedor OPTIONAL
ENDWSSTRUCT



// Estrutura de consultar
WSSTRUCT oConsulta

    WSDATA Codigo			AS String
	WSDATA Filial			AS String
	WSDATA Descricao		AS String
    WSDATA Situacao			AS String
    WSDATA Endereco			AS String	
    WSDATA Complemento		AS String	
    WSDATA Est			    AS String	
    WSDATA Municipio        AS String	
    WSDATA Bairro           AS String	
    WSDATA CEP              AS String	
    WSDATA InscricaoEst     AS String	
    WSDATA DDD              AS String	
    WSDATA Telefone         AS String	
    WSDATA Email         AS String	optional
ENDWSSTRUCT

// Estrutura de consultar
WSSTRUCT oConsultas
	WSDATA Itens AS ARRAY OF oConsulta
ENDWSSTRUCT

// Estrutura de cadastros de consulta
WSSTRUCT oCadastro
    WSDATA Indice			AS Integer
	WSDATA Campo			AS String
	WSDATA Valor		    AS String
ENDWSSTRUCT

// Estrutura de array de consulta de cadastro
WSSTRUCT oCadastros
	WSDATA Itens AS ARRAY OF oCadastro
ENDWSSTRUCT

// Estrutura do Produto
WSSTRUCT oProduto
	WSDATA Filial			AS String
    WSDATA Codigo			AS String
	WSDATA Descricao		AS String
    WSDATA DescWeb			AS String
	WSDATA Tipo				AS String
	WSDATA UM				AS String
ENDWSSTRUCT

// Estrutura dos Produtos 
WSSTRUCT oProdutos
	WSDATA Itens AS ARRAY OF oProduto
ENDWSSTRUCT

// Estrutura da Solicitação
WSSTRUCT oSolicitacao
	WSDATA Filial			AS String
	WSDATA Usuario			AS String
	WSDATA CentroCusto		AS String
	WSDATA IdFluig			AS String

	WSDATA Itens			AS Array Of oItemSC
ENDWSSTRUCT

// Estrutura dos Itens da Solicitação
WSSTRUCT oItemSC
	WSDATA Codigo			AS String
	WSDATA Necessidade		As Date
	WSDATA Quantidade		AS Float
	WSDATA Observacao		AS String optional
ENDWSSTRUCT

// Estrutura do Material
WSSTRUCT oMaterial
	WSDATA Filial			AS String
    WSDATA Codigo			AS String
	WSDATA Descricao		AS String
    WSDATA DescWeb			AS String
	WSDATA Armazem			AS String
	WSDATA UM				AS String
	WSDATA Valor			AS Float
	WSDATA SaldoAtual		AS Float
	WSDATA SaldoReserva		AS Float
	WSDATA SaldoDisponivel	AS Float
	WSDATA EstMinimo		AS Float	
ENDWSSTRUCT

// Estrutura dos Materiais 
WSSTRUCT oMateriais
	WSDATA Itens AS ARRAY OF oMaterial
ENDWSSTRUCT

// Estrutura da Solicitação ao Armazem
WSSTRUCT oSolicitacaoArmazem
	WSDATA Usuario			AS String
	WSDATA IdFluig			AS String
	WSDATA LoginFluig		AS String
	WSDATA Comissionado		AS String optional
	WSDATA Razao			AS String optional
	
	WSDATA Itens			AS Array Of oItemSA
ENDWSSTRUCT

// Estrutura dos Itens da Solicitação ao Armazem
WSSTRUCT oItemSA
	WSDATA Produto			AS String
	WSDATA Necessidade		As Date
	WSDATA Quantidade		AS Float
	WSDATA Unitario			AS Float
	WSDATA Observacao		AS String optional
ENDWSSTRUCT

// Estrutura do Item para o Relatorio de Solicitação ao Armazem
WSSTRUCT oItemSolicitacaoArmazem
	WSDATA IdFluig     as String
	WSDATA MATRICULA   as String
	WSDATA RAZAO       as String
	WSDATA LoginFluig  as String
	WSDATA Codigo      as String
	WSDATA Produto     as String
	WSDATA Descricao   as String
	WSDATA Emissao     as Date
	WSDATA Necessidade as Date
	WSDATA UM          as String
	WSDATA Quantidade  as Float
	WSDATA Unitario    as Float
	WSDATA Total       as Float
	WSDATA Rateio      as String
ENDWSSTRUCT

// Estrutura do Relatorio de Solicitação ao Armazem
WSSTRUCT oRelSolicitacaoArmazem
	WSDATA Itens AS ARRAY OF oItemSolicitacaoArmazem
ENDWSSTRUCT


// Estrutura do Cabeçalho NF
WSSTRUCT oDocEntr

	WSDATA Numero			AS String
	WSDATA Serie			AS String
	WSDATA Emissao			As String
	WSDATA IdFluig			AS String
	WSDATA Itens			AS Array Of oItemNF 
	WSDATA Filial			AS String
	WSDATA Fornece			As String
	WSDATA Loja				As String
	WSDATA Vencimento		As String

ENDWSSTRUCT

// Estrutura dos Itens da NF
WSSTRUCT oItemNF
	WSDATA Codigo			AS String
	WSDATA Quantidade		AS Float
	WSDATA Unitario			AS String
	WSDATA Total			AS String
	WSDATA CentroCusto		AS String

ENDWSSTRUCT

// Estrutura de contas a pagar
WSSTRUCT oTitPg

        WSDATA E2_FILIAL  as String
        WSDATA E2_NUM     as String
        WSDATA E2_PREFIXO as String
        WSDATA E2_PARCELA as String
        WSDATA E2_TIPO    as String
        WSDATA E2_CGC     as String
        WSDATA E2_EMISSAO as String
        WSDATA E2_VENCTO  as String
        WSDATA E2_VENCREA as String
        WSDATA E2_VALOR   as Float
        WSDATA E2_HIST    as String
		WSDATA E2_CCD     as String optional
		WSDATA E2_ITEMD   as String optional
		WSDATA E2_CLVLDB  as String optional
		WSDATA E2_IDFLUIG  as String
		WSDATA E2_XPROCES  as String optional

ENDWSSTRUCT


// Estrutura de contas a receber
WSSTRUCT oTitPr

        WSDATA E1_FILIAL  as String
        WSDATA E1_NUM     as String
        WSDATA E1_PREFIXO as String
        WSDATA E1_PARCELA as String
        WSDATA E1_TIPO    as String
        WSDATA E1_CGC     as String
        WSDATA E1_EMISSAO as String
        WSDATA E1_VENCTO  as String
        WSDATA E1_VENCREA as String
        WSDATA E1_VALOR   as Float
    	WSDATA E1_CCC     as String optional
		WSDATA E1_ITEMC   as String optional
		WSDATA E1_CLVLDB  as String optional
		WSDATA E1_CLVLCR  as String optional
		WSDATA E1_IDFLUIG  as String
		WSDATA E1_XPROCES  as String optional
		
ENDWSSTRUCT

// Estrutura de clientes
WSSTRUCT oCliente

        WSDATA A1_FILIAL  as String optional
        WSDATA A1_TIPO    as String
        WSDATA A1_COD     as String optional
        WSDATA A1_NOME    as String
        WSDATA A1_NREDUZ  as String
        WSDATA A1_LOJA    as String optional
        WSDATA A1_CGC     as String
		WSDATA A1_INSCR   as String
        WSDATA A1_END     as String
        WSDATA A1_COMPLEM as String
		WSDATA A1_BAIRRO  as String
        WSDATA A1_COD_MUN as String optional
        WSDATA A1_MUN     as String
        WSDATA A1_CEP     as String
        WSDATA A1_EST     as String
        WSDATA A1_DDD     as String
        WSDATA A1_TEL     as String
		WSDATA A1_PAIS    as String optional
		WSDATA A1_CODPAIS as String optional
		WSDATA A1_CBAIRRE as String
		WSDATA A1_NATUREZ as String optional
		WSDATA A1_EMAIL   as String optional

ENDWSSTRUCT

// Estrutura Cabeçalho Pedido de Vendas
WSSTRUCT oPedVenda
		WSDATA C5_FILIAL   as String	
		WSDATA nOpc        as String	
		WSDATA C5_IDFLUIG  as String  optional
        WSDATA C5_TIPO     as String 
		WSDATA C5_CLIENTE  as String 
		WSDATA C5_LOJACLI  as String 
		WSDATA C5_CLIENT   as String  optional
		WSDATA C5_LOJAENT  as String  optional
		WSDATA C5_CONDPAG  as String 
		WSDATA C5_TPFRETE  as String  optional
		WSDATA C5_FRETE    as Float  optional
		WSDATA C5_ESPECI1  as String  optional
		WSDATA C5_VOLUME1  as String  optional
		WSDATA C5_PESOL    as String  optional
		WSDATA C5_VEND1    as String  optional
		WSDATA C5_EMISSAO  as String  optional
		WSDATA C5_PBRUTO  as String  optional
		WSDATA Itens	   AS Array Of oItemPV
ENDWSSTRUCT
// Estruta dos Itens da Solicitação
WSSTRUCT oItemPV
		WSDATA C6_FIIAL    as String
        WSDATA C6_PRODUTO  as String
		WSDATA C6_QTDVEN   as String
		WSDATA C6_PRUNIT   as String optional
		WSDATA C6_PRCVEN   as Float
		WSDATA C6_VALOR    as Float optional
		WSDATA C6_TES      as String optional
		WSDATA C6_ITEM     as String 
		WSDATA C6_VALDESC  as String optional
ENDWSSTRUCT

// Estrutura dos Produtos 
WSSTRUCT oProdutosEstoque
	WSDATA Itens AS ARRAY OF oProdutoEstoque
ENDWSSTRUCT

// Estrutura do Produto
WSSTRUCT oProdutoEstoque
	WSDATA B1_FILIAL        AS String
    WSDATA B1_COD			AS String
	WSDATA B1_DESC		    AS String
    WSDATA B2_QATU			AS String
	WSDATA B1_UM			AS String
	WSDATA B1_PESO			AS string
	WSDATA B1_PRV1      	AS String
	WSDATA B5_ALTURA      	AS String
	WSDATA B5_COMPR     	AS String
	WSDATA B5_LARG     	AS String
ENDWSSTRUCT

WSSTRUCT oTitulo

    WSDATA Processo   as String
    WSDATA Taxa       as Float
    WSDATA AnoMes     as String

ENDWSSTRUCT

// Estrutura do  MultiCotas
WSSTRUCT TMultiCotas
	WSDATA Z11_IDCOTA as String                              //  ID Cota                   
	WSDATA Z11_GRUPO  as String                              //  Grupo                     
	WSDATA Z11_COTA   as String                              //  Cota                      
	WSDATA Z11_VERSAO as String                              //  Versao                    
	WSDATA Z11_TIPOPE as String                              //  Tipo Operacao
	WSDATA Z11_DOCTIT as String optional                     //  Doc Titular da Cota       
	WSDATA Z11_NOMTIT as String optional                     //  Nome Titular da Conta     
	WSDATA Z11_VALCRE as Float optional                      //  Valor do Credito          
	WSDATA Z11_VALFUN as Float optional                      //  Valor Fundo ate a contemp 
	WSDATA Z11_NUMPAR as Float optional                      //  Numero de Parcelas Pagas  
	WSDATA Z11_PRZGRP as Float optional                      //  Prazo do Grupo            
	WSDATA Z11_DTINGP as String optional                     //  Data Inicio Grupo         
	WSDATA Z11_DTAQUI as String optional                     //  Data Aquisicao            
	WSDATA Z11_DTCANC as String optional                     //  Dt Cancelamento Cota      
	WSDATA Z11_VLVNDC as Float optional                      //  Vl Venda Cota             
	WSDATA Z11_IDPROC as String optional                     //  Numero do Processo        
	WSDATA Z11_VBRCOM as Float optional                      //  Valor Bruto Compra        
	WSDATA Z11_VLICOM as Float optional                      //  Valor Liquido Compra      
	WSDATA Z11_VCCCAU as Float optional                      //  Comissao Compra Autorizad 
	WSDATA Z11_VCCCGE as Float optional                      //  Comissao Compra Gerente   
	WSDATA Z11_VCCCLI as Float optional                      //  Comissao Compra Licenciad 
	WSDATA Z11_VCCCRE as Float optional                      //  Comissao Compra Regional  
	WSDATA Z11_IDCCAU as String optional                     //  Id.do Com. Compra Autoriz 
	WSDATA Z11_IDCCGE as String optional                     //  Id.do Com. Compra Gerente 
	WSDATA Z11_IDCCLI as String optional                     //  Id do Com. Compra Licenci 
	WSDATA Z11_IDCCRE as String optional                     //  Id do Com. Compra Regiona 
	WSDATA Z11_DTCOMP as String optional                     //  Data da compra            
	// WSDATA Z11_STCOMP as String optional                     //  Status da compra          
	WSDATA Z11_DTVCCO as String optional                     //  Data Vencimento Compra    
	WSDATA Z11_DTVCCM as String optional                     //  Data Venc. Com. Compra    
	WSDATA Z11_DOCDES as String optional                     //  Doc. Comprador            
	WSDATA Z11_VBRVEN as Float optional                      //  Valor Bruto Venda         
	WSDATA Z11_VLIVEN as Float optional                      //  Valor Liquido Venda       
	WSDATA Z11_VCVCAU as Float optional                      //  Comissao Venda Autorizad  
	WSDATA Z11_VCVCGE as Float optional                      //  Comissao Venda Gerente    
	WSDATA Z11_VCVCLI as Float optional                      //  Comissao Venda Licenciad  
	WSDATA Z11_VCVCRE as Float optional                      //  Comissao Venda Regional   
	WSDATA Z11_IDVCAU as String optional                     //  Id.do Com. Venda Autoriz  
	WSDATA Z11_IDVCGE as String optional                     //  Id.do Com. Venda Gerente  
	WSDATA Z11_IDVCLI as String optional                     //  Id do Com. Venda Licenci  
	WSDATA Z11_IDVCRE as String optional                     //  Id do Com. Venda Regiona  
	WSDATA Z11_DTVEND as String optional                     //  Data da Venda             
	// WSDATA Z11_STVEND as String optional                     //  Status da Venda           
	WSDATA Z11_DTVCVE as String optional                     //  Data Vencimento Venda     
	WSDATA Z11_DTVCCV as String optional                     //  Data Venc. Com. Venda     
	WSDATA Z11_VALLPR as Float optional                      //  Valor Serv. L.Premium     
	WSDATA Z11_VALTXU as Float optional                      //  Valor Taxa Intermediacao  
	// WSDATA Z11_PARBOL as String optional                     //  Parc. Boleto Gerado       
	WSDATA Z11_PRZC   as Float optional                    //  Prazo (dias) para pagamento compra
	WSDATA Z11_PV	  as String optional                     //  Ponto de venda
	WSDATA Z11_TXLEIS as Float optional                      //  Valor Taxa de Leilao standard
	WSDATA Z11_ATRAS  as Float optional                      //  Valor de Parcelas Atrasadas
	WSDATA Z11_VADPRZ as Float optional                      //  Adicional de comissao prazo
	WSDATA Z11_VCPCAU as Float optional                      //  Valor de Pontos Compra Autorizado
	WSDATA Z11_VCPCGE as Float optional                      //  Valor de Pontos Compra Gestor
	WSDATA Z11_VCPCLI as Float optional                      //  Valor de Pontos Compra Licenciado
	WSDATA Z11_VCPCRE as Float optional                      //  Valor de Pontos Compra Regional
	WSDATA Z11_VCPVAU as Float optional                      //  Valor de Pontos Venda Autorizado
	WSDATA Z11_VCPVGE as Float optional                      //  Valor de Pontos Venda Gestor
	WSDATA Z11_VCPVLI as Float optional                      //  Valor de Pontos Venda Licenciado
	WSDATA Z11_VCPVRE as Float optional                      //  Valor de Pontos Venda Regional
ENDWSSTRUCT


// Estrutura do array dos Fornecedor
WSSTRUCT TIncForn

	WSDATA A2_TIPO		AS String
	WSDATA A2_CGC		AS String
	WSDATA A2_LOJA		AS String
    WSDATA A2_NOME		AS String
	WSDATA A2_NREDUZ	AS String
	WSDATA A2_END		AS String
	WSDATA A2_NR_END	AS String
	WSDATA A2_BAIRRO	AS String
	WSDATA A2_EST		AS String
	WSDATA A2_COD_MUN	AS String optional
	WSDATA A2_MUN		AS String
	WSDATA A2_CEP		AS String
	WSDATA A2_INSCR		AS String
	WSDATA A2_PAIS		AS String optional
	WSDATA A2_XTIPCON	AS String
	WSDATA A2_XCCD		AS String optional
	WSDATA A2_CONTA		AS String optional
	WSDATA A2_CODPAIS	AS String optional

ENDWSSTRUCT


//FIM

/*
{Protheus.doc} AprovWFPC
Aprova o item da alçada do Peido de Compras
@author Anderson José Zelenski
@since 07/12/2020
*/

WSMETHOD AprovWFPC WSRECEIVE oAprovacao WSSEND cStatus WSSERVICE FluigProtheus
	Local lError 	:= .T.
	Local nAcao 	:= 4
	Local cAprovador:= ""
	//Local cUsuario	:= ""
	
	conout("Aprovar Pedido")
	
	BEGIN TRANSACTION
		
		SCR->(DbGoTo(Val(oAprovacao['SCRRecno'])))
		cFilAnt 	:= SCR->CR_FILIAL
		cTipo		:= SCR->CR_TIPO
		cPedido 	:= SCR->CR_NUM
		cAprovador	:= SCR->CR_APROV
		cMyUsuario	:= SCR->CR_USER
		cMyNivel	:= SCR->CR_NIVEL
		
		conout("Ação: "+oAprovacao['Acao'])
		
		If oAprovacao['Acao'] == "A"
			MaAlcDoc({SCR->CR_NUM, SCR->CR_TIPO, SCR->CR_TOTAL, cAprovador, cMyUsuario, SCR->CR_GRUPO,,,,,oAprovacao['Comentario']},dDataBase,nAcao,,,SCR->CR_ITGRP)
		ElseIf oAprovacao['Acao'] == "R"
			nAcao 	:= 6
			conout(SCR->CR_NUM, SCR->CR_TIPO, SCR->CR_TOTAL, cMyUsuario, cAprovador, SCR->CR_GRUPO, oAprovacao['Comentario'],SCR->CR_ITGRP)
			
			MaAlcDoc({SCR->CR_NUM, SCR->CR_TIPO, SCR->CR_TOTAL, cAprovador, cMyUsuario, SCR->CR_GRUPO,,,,,oAprovacao['Comentario']},dDataBase,nAcao,,,SCR->CR_ITGRP)
			
			/*
			RecLock("SCR", .F.)
				SCR->CR_STATUS 	:= "4"
				SCR->CR_OBS 	:= oAprovacao['Comentario']
			SCR->(MsUnlock())
			*/
EndIf

conout("Login Aprovador: "+oAprovacao['Login'])

// Valida se foi aprovado por um usuario alternativo
SAK->(DbSetOrder(4)) //AK_FILIAL+AK_Login
If SAK->(DbSeek(xFilial("SAK")+oAprovacao['Login']))
	If cMyUsuario != SAK->AK_USER
		SCR->(DbSetOrder(1)) //CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
		SCR->(DbGoTop())
		SCR->(DbSeek(cFilAnt+cTipo+cPedido+cMyNivel))

		While !SCR->(EoF()) .And. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM+SCR->CR_NIVEL == cFilAnt+cTipo+cPedido+cMyNivel
			RecLock("SCR", .F.)
			SCR->CR_LIBAPRO := SAK->AK_COD
			SCR->CR_USERLIB := SAK->AK_USER
			SCR->(MsUnlock())

			SCR->(DbSkip())
		EndDo

	EndIf
EndIf

lError := .F.

::cStatus := "OK"

END TRANSACTION

If lError
	cMens := "Erro ao aprovaro alçada SCR"
	conout('[' + DToC(Date()) + " " + Time() + "] Aprovar SCR > " + cMens)
	SetSoapFault("Erro", cMens)
Return .F.
EndIf

Return .T.

/*/{Protheus.doc} LiberarPC
Libera Pedido de Compras
@author Anderson José Zelenski
@since 07/12/2020
/*/

WSMETHOD LiberarPC WSRECEIVE SCRRecno WSSEND cStatus WSSERVICE FluigProtheus
	Local lError 	:= .T.

	conout("Liberar Pedido")

	BEGIN TRANSACTION

		// Posiciona na Alçada
		SCR->(DbGoTo(Val(::SCRRecno)))
		cFilAnt := SCR->CR_FILIAL

		conout(SCR->CR_NUM, SCR->CR_TIPO, SCR->CR_TOTAL, SCR->CR_APROV, SCR->CR_USER, SCR->CR_GRUPO, SCR->CR_ITGRP)

		// Busca o Centro de Custo
		If Empty(SCR->CR_ITGRP)
			DBL->(DbSetOrder(1))
			DBL->(DbSeek(xFilial('DBL')+SCR->CR_GRUPO))
		Else
			DBL->(DbSetOrder(1))
			DBL->(DbSeek(xFilial('DBL')+SCR->CR_GRUPO+SCR->CR_ITGRP))
		EndIf

		conout("CC "+AllTrim(DBL->DBL_CC))

		// Posiciona no Pedido de Compras
		SC7->(DbSetOrder(1))
		SC7->(DbSeek(xFilial("SC7")+AllTrim(SCR->CR_NUM)))

		// Percorre os Itens do Pedido de Compras
		While !SC7->(EoF()) .And. SC7->C7_FILIAL+AllTrim(SC7->C7_NUM) == xFilial("SC7")+AllTrim(SCR->CR_NUM)

			conout(AllTrim(SC7->C7_CC)+" == "+AllTrim(DBL->DBL_CC))

			If AllTrim(SC7->C7_CC) == AllTrim(DBL->DBL_CC)
				// Libera o Item de acordo com o Centro de Custo da alçada aprovada
				RecLock("SC7", .F.)
				SC7->C7_CONAPRO := "L"
				SC7->(MsUnlock())
			EndIf

			SC7->(DbSkip())
		EndDo

		lError := .F.

		::cStatus := "OK"

	END TRANSACTION

	If lError
		cMens := "Erro ao liberar pedido de compras"
		conout('[' + DToC(Date()) + " " + Time() + "] Liberar PC > " + cMens)
		SetSoapFault("Erro", cMens)
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} CentrosCustos
Retorna os Centros de Custos
@author Anderson José Zelenski
@since 07/12/2020
/*/
WSMETHOD CentrosCustos WSRECEIVE NULLPARAM WSSEND aCentrosCustos WSSERVICE FluigProtheus
	Local oCentroCusto
	Local cAlias	:= GetNextAlias()
	Local cQuery	:= ''

	::aCentrosCustos := WSClassNew("oCentrosCustos")
	::aCentrosCustos:Itens := {}

	cQuery := " SELECT CTT_FILIAL, CTT_CUSTO, CTT_DESC01 "
	cQuery += " FROM "+RetSqlName('CTT')+" CTT"
	cQuery += " WHERE CTT.CTT_BLOQ <> '1'"
	cQuery += " 	AND CTT.CTT_CLASSE = '2' "
	cQuery += " 	AND CTT.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY CTT_FILIAL, CTT_CUSTO "

	cQuery := ChangeQuery(cQuery)

	TcQuery cQuery New Alias (cAlias)

	dbSelectArea(cAlias)

	While (cAlias)->(!Eof())

		oCentroCusto := WSClassNew("oCentroCusto")

		oCentroCusto:Filial 	:= (cAlias)->CTT_FILIAL
		oCentroCusto:Codigo 	:= (cAlias)->CTT_CUSTO
		oCentroCusto:Descricao	:= (cAlias)->CTT_DESC01
		oCentroCusto:DescWeb	:= AllTrim((cAlias)->CTT_CUSTO)+" - "+AllTrim((cAlias)->CTT_DESC01)

		aAdd(::aCentrosCustos:Itens, oCentroCusto)

		(cAlias)->(dbSkip())
	EndDo

	(cAlias)->(dbCloseArea())

Return .T.

/*/{Protheus.doc} Produtos
Retorna os Produtos
@author Anderson José Zelenski
@since 09/12/2020
/*/
WSMETHOD Produtos WSRECEIVE NULLPARAM WSSEND aProdutos WSSERVICE FluigProtheus
	Local oProduto
	Local cAlias	:= GetNextAlias()
	Local cQuery	:= ''

	::aProdutos := WSClassNew("oProdutos")
	::aProdutos:Itens := {}

	cQuery := " SELECT B1_FILIAL, B1_COD, B1_DESC, B1_TIPO, B1_UM "
	cQuery += " FROM "+RetSqlName('SB1')+" SB1"
	cQuery += " WHERE SB1.B1_MSBLQL <> '1'"
	cQuery += " 	AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " 	AND B1_FILIAL = '010101' "
	cQuery += " ORDER BY B1_FILIAL, B1_COD "

	cQuery := ChangeQuery(cQuery)

	TcQuery cQuery New Alias (cAlias)

	dbSelectArea(cAlias)

	While (cAlias)->(!Eof())

		oProduto := WSClassNew("oProduto")

		oProduto:Filial 	:= (cAlias)->B1_FILIAL
		oProduto:Codigo 	:= Alltrim((cAlias)->B1_COD)
		oProduto:Descricao	:= Alltrim((cAlias)->B1_DESC)
		oProduto:DescWeb	:= Alltrim((cAlias)->B1_COD)+" - "+Alltrim((cAlias)->B1_DESC)
		oProduto:Tipo		:= (cAlias)->B1_TIPO
		oProduto:UM			:= (cAlias)->B1_UM

		aAdd(::aProdutos:Itens, oProduto)

		(cAlias)->(dbSkip())
	EndDo

	(cAlias)->(dbCloseArea())

Return .T.

/*/{Protheus.doc} GerarSC
Gera a Solicitação de Compras no Protheus
@author Anderson José Zelenski
@since 11/12/2020
/*/

WSMETHOD GerarSC WSRECEIVE oSolicitacao WSSEND cCodigo WSSERVICE FluigProtheus
	Local lError 	:= .T.
	Local aCab		:= {}
	Local aItem		:= {}
	Local nI		:= 1
	Local cNum 		:= ''
	Local cCentroCusto := ''
	Local cIdFluig	:= ''
	Local cSolicitante := ''
	Local aItemSC 	:= {}

	PRIVATE lMsErroAuto := .F.

	conout("Gera Solicitação de Compras")

	BEGIN TRANSACTION

		cFilAnt 		:= oSolicitacao['Filial']
		cSolicitante	:= oSolicitacao['Usuario']
		cCentroCusto 	:= oSolicitacao['CentroCusto']
		cIdFluig 		:= oSolicitacao['IdFluig']

		cNum := GetNumSC1()

		aCab:= {;
			{"C1_FILIAL",	oSolicitacao['Filial'],		NIL},;
			{"C1_NUM",		cNum,						NIL},;
			{"C1_SOLICIT",	oSolicitacao['Usuario'],	NIL},;
			{"C1_EMISSAO",	dDatabase,					NIL},;
			{"C1_USER",		'000000',					NIL};
			;
			}

		SB1->(DbSetOrder(1))

		For nI := 1 To Len(oSolicitacao['Itens'])
			oItemSC := WSClassNew("oItemSC")

			aItemSC := {}
			aItemSC := oSolicitacao['Itens']
			oItemSC := aItemSC[nI]

			SB1->(DbSeek(xFilial("SB1")+oItemSC:Codigo))
			//Adiciona os Itens da SC
			Aadd(aItem, {;
				{"C1_ITEM",		StrZero(nI, 4),				NIL},;
				{"C1_ITEMGRD",	space(2),					NIL},;
				{"C1_PRODUTO", 	SB1->B1_COD, 				NIL},;
				{"C1_DESCRI",	SB1->B1_DESC,				NIL},;
				{"C1_LOCAL",	SB1->B1_LOCPAD, 			NIL},;
				{"C1_UM", 		SB1->B1_UM, 				NIL},;
				{"C1_DATPRF",	oItemSC:Necessidade,		NIL},;
				{"C1_QUANT",	oItemSC:Quantidade,			NIL},;
				{"C1_VUNIT", 	0.00, 						NIL},;
				{"C1_CONTA", 	SB1->B1_CONTA, 				NIL},;
				{"C1_CC", 		cCentroCusto, 				NIL},;
				{"C1_OBS", 		oItemSC:Observacao,			NIL},;
				{"C1_IDFLUIG",	cIdFluig,					NIL};
				})
		Next nI

		MSExecAuto({|x,y,z| Mata110(x,y,z)},aCab,aItem,3) //Inclusao

		IF lMsErroAuto
			rollbacksx8()

			If (!IsBlind()) // COM INTERFACE GRÁFICA
				MostraErro()
			Else // EM ESTADO DE JOB
				cError := MostraErro("/dirdoc", "GerarSC_error_ws"+dtos(date())+"_"+strtran(time(),":","")+".log") // ARMAZENA A MENSAGEM DE ERRO

				ConOut(PadC("Automatic routine ended with error", 80))
				ConOut("Error: "+ cError)
			EndIf

			lError := .T.
		ELSE
			Confirmsx8()
			lError := .F.
		ENDIF

	END TRANSACTION

	::cCodigo := cNum

	If lError
		cMens := "Erro ao gravar a Solicitação de Compras"
		conout('[' + DToC(Date()) + " " + Time() + "] GravarSolicitacaoCompras > " + cMens)
		SetSoapFault("Erro", cMens)
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} Materiais
Retorna os Materiais
@author Anderson José Zelenski
@since 29/06/2022
/*/
WSMETHOD Materiais WSRECEIVE cSegmento WSSEND aMateriais WSSERVICE FluigProtheus
	Local oMaterial
	Local cAlias	:= GetNextAlias()
	Local cQuery	:= ''

	::aMateriais := WSClassNew("oMateriais")
	::aMateriais:Itens := {}

	cQuery := " SELECT B1_FILIAL AS FILIAL, B1_COD AS CODIGO, B1_EMIN as MINIMO, B1_DESC AS DESCRICAO, B1_LOCPAD AS ARMAZEM, B1_UM AS UM, DA1_PRCVEN AS VALOR, COALESCE(B2_QATU,0) AS ATUAL, COALESCE(B2_QEMPSA,0) AS RESERVA "
	cQuery += " FROM "+RetSqlName('DA0')+" DA0"
	cQuery += 	" INNER JOIN "+RetSqlName('DA1')+" DA1 ON DA1.DA1_FILIAL = '"+xFilial("DA1")+"' AND DA1.DA1_CODTAB = DA0.DA0_CODTAB AND DA1.DA1_ATIVO = '1' AND DA1.D_E_L_E_T_ = ' ' "
	cQuery += 	" INNER JOIN "+RetSqlName('SB1')+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = DA1.DA1_CODPRO AND SB1.B1_MSBLQL <> '1' AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += 	" LEFT JOIN "+RetSqlName('SB2')+" SB2 ON SB2.B2_FILIAL = '"+xFilial("SB2")+"' AND SB2.B2_COD = DA1.DA1_CODPRO AND SB2.B2_LOCAL = SB1.B1_LOCPAD AND SB2.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE DA0_FILIAL = '"+xFilial("DA0")+"' "
	cQuery += " 	AND DA0_CODTAB = '"+GetMV("MV_TABMATE")+"' "
	If !Empty(::cSegmento)
		cQuery += " AND SB1.B1_ITEMCC in ("+::cSegmento+") "
		//cQuery += " AND SB1.B1_ITEMCC = '"+::cSegmento+"' "
	EndIf
	cQuery += " 	AND DA0.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY B1_DESC "

	cQuery := ChangeQuery(cQuery)

	TcQuery cQuery New Alias (cAlias)

	dbSelectArea(cAlias)

	While (cAlias)->(!Eof())

		oMaterial := WSClassNew("oMaterial")

		oMaterial:Filial 			:= (cAlias)->FILIAL
		oMaterial:Codigo 			:= Alltrim((cAlias)->CODIGO)
		oMaterial:Descricao			:= Alltrim((cAlias)->DESCRICAO)
		oMaterial:DescWeb			:= Alltrim((cAlias)->CODIGO)+" - "+Alltrim((cAlias)->DESCRICAO)
		oMaterial:Armazem			:= (cAlias)->ARMAZEM
		oMaterial:UM				:= (cAlias)->UM
		oMaterial:Valor				:= (cAlias)->VALOR
		oMaterial:SaldoAtual		:= (cAlias)->ATUAL
		oMaterial:SaldoReserva		:= (cAlias)->RESERVA
		oMaterial:SaldoDisponivel	:= (cAlias)->ATUAL-(cAlias)->RESERVA
		oMaterial:EstMinimo			:= (cAlias)->MINIMO

		aAdd(::aMateriais:Itens, oMaterial)

		(cAlias)->(dbSkip())
	EndDo

	(cAlias)->(dbCloseArea())

Return .T.

/*/{Protheus.doc} GerarSA
Gera a Solicitação ao Armazem no Protheus
@author Anderson José Zelenski
@since 01/07/2022
/*/

WSMETHOD GerarSA WSRECEIVE oSolicitacaoArmazem WSSEND cCodigo WSSERVICE FluigProtheus
	Local lError 	:= .T.
	Local aCab		:= {}
	Local aItem		:= {}
	Local nI		:= 1
	Local cNum 		:= ''
	Local cIdFluig	:= ''
	Local cUsuario 	:= ''
	Local cComissionado := ''
	Local cRazao 	:= ''
	Local aItemSA 	:= {}

	Local lMarkB 	:= .F.
	Local lDtNec	:= .F.
	Local BFiltro	:= {|| .T.}
	Local lConsSPed := .F.
	Local lGeraDoc	:= .T.
	Local lAmzSA	:= .F.
	Local cSldAmzIni:= ""
	Local cSldAmzFim:= "ZZ"
	Local lLtEco	:= .F.
	Local lConsEmp	:= .F.
	Local nAglutDoc	:= 2
	Local lAuto		:= .F.
	Local lEstSeg	:= .F.
	Local aRecSCP	:= {}
	Local lRateio	:= .F.
	Local cFiltraSCP := ""

	PRIVATE lMsErroAuto := .F.

	conout("Gera Solicitação ao Armazém")

	BEGIN TRANSACTION

		cMyUsuario	:= oSolicitacaoArmazem['Usuario']
		cIdFluig 	:= oSolicitacaoArmazem['IdFluig']
		cLoginFluig := oSolicitacaoArmazem['LoginFluig']
		cComissionado := oSolicitacaoArmazem['Comissionado']
		cRazao := oSolicitacaoArmazem['Razao']

		conout("cLoginFluig -> "+cLoginFluig)

		// Apaga as
		ApagarSA(cIdFluig)

		cNum := GetSXENum("SCP","CP_NUM")

		aCab:= {;
			{"CP_FILIAL",	xFilial("SCP"),	NIL},;
			{"CP_NUM",		cNum,			NIL},;
			{"CP_SOLICIT",	cMyUsuario,		NIL},;
			{"CP_EMISSAO",	dDatabase,		NIL},;
			{"CP_CODSOLI",	'000000',		NIL};
			;
			}

		SB1->(DbSetOrder(1))

		For nI := 1 To Len(oSolicitacaoArmazem['Itens'])
			oItemSC := WSClassNew("oItemSC")

			aItemSA := {}
			aItemSA := oSolicitacaoArmazem['Itens']
			oItemSA := aItemSA[nI]

			SB1->(DbSeek(xFilial("SB1")+oItemSA:Produto))

			//{"CP_RAZNEWC",	cRazao,						NIL},;

			//Adiciona os Itens da SC
			Aadd(aItem, {;
				{"CP_NUM",		cNum,						NIL},;
				{"CP_ITEM",		StrZero(nI, 2),				NIL},;
				{"CP_PRODUTO", 	SB1->B1_COD, 				NIL},;
				{"CP_DESCRI",	SB1->B1_DESC,				NIL},;
				{"CP_LOCAL",	SB1->B1_LOCPAD, 			NIL},;
				{"CP_UM", 		SB1->B1_UM, 				NIL},;
				{"CP_DATPRF",	dDatabase,					NIL},;
				{"CP_QUANT",	oItemSA:Quantidade,			NIL},;
				{"CP_VUNIT", 	oItemSA:Unitario, 			NIL},;
				{"CP_OBS", 		oItemSA:Observacao,			NIL},;
				{"CP_IDFLUIG",	cIdFluig,					NIL},;
				{"CP_MATNEWC",	cComissionado,				NIL},;
				{"CP_RAZNEWC",	cRazao,						NIL},;
				{"CP_LGFLUIG",	cLoginFluig,				NIL};
				})

		Next nI

		MSExecAuto({|x,y,w,z| Mata105(x,y,w)}, aCab, aItem, 3) //Inclusao

		IF lMsErroAuto
			rollbacksx8()

			If (!IsBlind()) // COM INTERFACE GRÁFICA
				MostraErro()
			Else // EM ESTADO DE JOB
				cError := MostraErro("/dirdoc", "GerarSA_error_ws"+dtos(date())+"_"+strtran(time(),":","")+".log") // ARMAZENA A MENSAGEM DE ERRO

				ConOut(PadC("Automatic routine ended with error", 80))
				ConOut("Error: "+ cError)
			EndIf

			lError := .T.

		ELSE
			Confirmsx8()
			lError := .F.

			cFiltraSCP := "(CP_NUM = '"+cNum+"') "
			BFiltro := {|| &cFiltraSCP}

			// Executa a Pré Requisição
			MaSAPreReq(lMarkB,lDtNec,BFiltro,lConsSPed,lGeraDoc,lAmzSA,cSldAmzIni,cSldAmzFim,lLtEco,lConsEmp,nAglutDoc,lAuto,lEstSeg,aRecSCP,lRateio)

		ENDIF

	END TRANSACTION

	::cCodigo := cNum

	If lError
		cMens := "Erro ao gravar a Solicitação ao Armazém"
		conout('[' + DToC(Date()) + " " + Time() + "] GravarSolicitacaoArmazem > " + cMens)
		SetSoapFault("Erro", cMens)
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} BaixarSA
Rotina para Baixar a Solicitação ao Armazem
@author Anderson José Zelenski
@since 01/07/2022
/*/

WSMETHOD BaixarSA WSRECEIVE cCodigo WSSEND cStatus WSSERVICE FluigProtheus
	Local lError 	:= .T.
	Local aSCP		:= {}
	Local aSD3		:= {}

	Private lMSHelpAuto := .F.
	Private lMsErroAuto := .F.

	::cStatus := "NOK"

	conout("Baixar a Solicitação ao Armazém")

	BEGIN TRANSACTION

		SCP->(dbSetOrder(1))
		SCP->(dbSeek(xFilial("SCP")+::cCodigo))

		While !SCP->(EoF()) .And. SCP->CP_FILIAL+SCP->CP_NUM == xFilial("SCP")+::cCodigo

			aSCP := { ;
				{"CP_NUM",		SCP->CP_NUM,	Nil },;
				{"CP_ITEM",		SCP->CP_ITEM,	Nil },;
				{"CP_QUANT",	SCP->CP_QUANT,	Nil };
				}

			aSD3 := {;
				{"D3_TM",		GetMV("MV_TMSAFLG"),	Nil },; // Tipo do Mov.
			{"D3_COD",		SCP->CP_PRODUTO,		Nil },;
				{"D3_LOCAL",	SCP->CP_LOCAL,			Nil },;
				{"D3_DOC",		SCP->CP_IDFLUIG,		Nil },; // No.do Docto.
			{"D3_EMISSAO",	DDATABASE,				Nil };
				}

			lMSHelpAuto := .F.
			lMsErroAuto := .F.

			MSExecAuto({|v,x,y,z| mata185(v,x,y,z)}, aSCP, aSD3 ,1,)   // 1 = BAIXA (ROT.AUT)

			If lMsErroAuto

				cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

				ConOut(PadC("Automatic routine ended with error", 80))
				ConOut("Error: "+ cError)

				::cStatus := "NOK"
				DisarmTransaction()
				lError := .T.
			ELSE
				lError := .F.
				::cStatus := "OK"
			ENDIF

			SCP->(DbSkip())
		EndDo

	END TRANSACTION

	If lError
		cMens := "Erro ao Baixar a Solicitação ao Armazém"
		conout('[' + DToC(Date()) + " " + Time() + "] BaixarSolicitacaoArmazem > " + cMens)
		SetSoapFault("Erro", cMens)
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} CancelarSA
Rotina para Cancelar a Solicitação ao Armazem
@author Anderson José Zelenski
@since 01/07/2022
/*/

WSMETHOD CancelarSA WSRECEIVE cCodigo WSSEND cStatus WSSERVICE FluigProtheus
	conout("Cancelar a Solicitação ao Armazém")

	SCP->(dbSetOrder(1))
	If SCP->(dbSeek(xFilial("SCP")+::cCodigo))

		::cStatus := ApagarSA(SCP->CP_IDFLUIG)
	else
		::cStatus := "NOK"
	EndIf

Return .T.

/*/{Protheus.doc} ApagarSA
Apaga a
@author Anderson José Zelenski
@since 11/12/2020
/*/

Static Function ApagarSA(idFluig)
	Local cQuery	:= ''
	Local cAlias	:= GetNextAlias()
	Local aSCP		:= {}
	Local aSD3		:= {}
	Local aItem		:= {}
	Local lError 	:= .F.
	Local cError	:= ""
	Local cStatus	:= ""

	Private lMSHelpAuto := .F.
	Private lMsErroAuto := .F.

	cQuery := " SELECT R_E_C_N_O_ AS RECNO "
	cQuery += " FROM "+RetSqlName('SCP')+" SCP"
	cQuery += " WHERE CP_IDFLUIG = '"+AllTrim(idFluig)+"' "
	cQuery += " 	AND SCP.CP_PREREQU = 'S' "
	cQuery += " 	AND SCP.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	conout(cQuery)

	TcQuery cQuery New Alias (cAlias)

	dbSelectArea(cAlias)

	While (cAlias)->(!Eof())

		// Apaga a Solicitação ao Armazem
		SCP->(DbGoTo((cAlias)->RECNO))

		conout("CP_NUM: "+SCP->CP_NUM)

		aSCP := { ;
			{"CP_NUM",		SCP->CP_NUM,	Nil },;
			{"CP_ITEM",		SCP->CP_ITEM,	Nil },;
			{"CP_QUANT",	SCP->CP_QUANT,	Nil };
			}

		aSD3 := {;
			{"D3_TM",		GetMV("MV_TMSAFLG"),	Nil },; // Tipo do Mov.
		{"D3_COD",		SCP->CP_PRODUTO,		Nil },;
			{"D3_LOCAL",	SCP->CP_LOCAL,			Nil },;
			{"D3_DOC",		SCP->CP_IDFLUIG,		Nil },; // No.do Docto.
		{"D3_EMISSAO",	DDATABASE,				Nil };
			}

		lMSHelpAuto := .F.
		lMsErroAuto := .F.

		MSExecAuto({|v,x,y,z| mata185(v,x,y,z)}, aSCP, aSD3 ,5,)   // 1 = Excluir

		If lMsErroAuto

			cError := MostraErro("/dirdoc", "ApagarSA_error"+dtos(date())+"_"+strtran(time(),":","")+".log") // ARMAZENA A MENSAGEM DE ERRO

			ConOut(PadC("Automatic routine ended with error", 80))
			ConOut("Error: "+ cError)

			cStatus := "NOK"
			lError := .T.
		ELSE
			cStatus := "OK"
			lError := .F.
		ENDIF

		MSExecAuto({|x,y,w,z| Mata105(x,y,w)}, aSCP, aItem, 5) // Exclui

		(cAlias)->(dbSkip())
	EndDo

	(cAlias)->(dbCloseArea())

Return cStatus

/*/{Protheus.doc} CentrosCustos
Retorna os Centros de Custos
@author Anderson José Zelenski
@since 07/12/2020
/*/
WSMETHOD RelatorioSolicitacaoArmazem WSRECEIVE cLoginFluig, cDataInicial, cDataFinal WSSEND aRelSolicitacaoArmazem WSSERVICE FluigProtheus
	Local oItemSolicitacaoArmazem
	Local cAlias	:= GetNextAlias()
	Local cQuery	:= ''

	::aRelSolicitacaoArmazem := WSClassNew("oRelSolicitacaoArmazem")
	::aRelSolicitacaoArmazem:Itens := {}

	cQuery := " SELECT distinct CP_IDFLUIG AS IDFLUIG, CP_MATNEWC as MATRICULA, CP_RAZNEWC as RAZAO, CP_LGFLUIG AS LGFLUIG, CP_TIPRAT AS RATEIO, CP_NUM AS CODIGO, CP_PRODUTO AS PRODUTO, B1_DESC AS DESCRICAO, CP_EMISSAO AS EMISSAO, CP_DATPRF AS NECESSIDADE, B1_UM AS UM, CP_QUANT AS QTD, CP_VUNIT AS UNITARIO, CP_QUANT*CP_VUNIT AS TOTAL "
	cQuery += " FROM "+RetSqlName('SCP')+" SCP"
	cQuery += " 	INNER JOIN "+RetSqlName('SB1')+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SCP.CP_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SCP.CP_FILIAL = '"+xFilial("SCP")+"' "
	If !Empty(::cLoginFluig)
		cQuery += " AND SCP.CP_LGFLUIG = '"+::cLoginFluig+"' "
	EndIf
	If !Empty(::cDataInicial)
		cQuery += " AND SCP.CP_EMISSAO >= '"+DtoS(CtoD(::cDataInicial))+"' "
	EndIf
	If !Empty(::cDataFinal)
		cQuery += " AND SCP.CP_EMISSAO <= '"+DtoS(CtoD(::cDataFinal))+"' "
	EndIf
	
	cQuery += " 	AND SCP.CP_STATUS = 'E' "
	cQuery += " 	AND SCP.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY CP_IDFLUIG "

	cQuery := ChangeQuery(cQuery)

	TcQuery cQuery New Alias (cAlias)

	dbSelectArea(cAlias)

	While (cAlias)->(!Eof())

		conout((cAlias)->NECESSIDADE)

		oItemSolicitacaoArmazem := WSClassNew("oItemSolicitacaoArmazem")

		oItemSolicitacaoArmazem:IdFluig			:= (cAlias)->IDFLUIG
		oItemSolicitacaoArmazem:MATRICULA		:= (cAlias)->MATRICULA
		oItemSolicitacaoArmazem:RAZAO			:= (cAlias)->RAZAO
		oItemSolicitacaoArmazem:LoginFluig		:= (cAlias)->LGFLUIG
		oItemSolicitacaoArmazem:Codigo			:= (cAlias)->CODIGO
		oItemSolicitacaoArmazem:Produto			:= (cAlias)->PRODUTO
		oItemSolicitacaoArmazem:Descricao		:= (cAlias)->DESCRICAO
		oItemSolicitacaoArmazem:Emissao			:= StoD((cAlias)->EMISSAO)
		oItemSolicitacaoArmazem:Necessidade		:= StoD((cAlias)->NECESSIDADE)
		oItemSolicitacaoArmazem:UM				:= (cAlias)->UM
		oItemSolicitacaoArmazem:Quantidade		:= (cAlias)->QTD
		oItemSolicitacaoArmazem:Unitario		:= (cAlias)->UNITARIO
		oItemSolicitacaoArmazem:Total			:= (cAlias)->TOTAL
		oItemSolicitacaoArmazem:Rateio			:= (cAlias)->RATEIO

		aAdd(::aRelSolicitacaoArmazem:Itens, oItemSolicitacaoArmazem)

		(cAlias)->(dbSkip())
	EndDo

	If Empty(::aRelSolicitacaoArmazem:Itens)
		oItemSolicitacaoArmazem := WSClassNew("oItemSolicitacaoArmazem")

		oItemSolicitacaoArmazem:IdFluig			:= "ERRO"
		oItemSolicitacaoArmazem:LoginFluig		:= "Sem registros"
		oItemSolicitacaoArmazem:Codigo			:= "000000"
		oItemSolicitacaoArmazem:Produto			:= "000000"
		oItemSolicitacaoArmazem:Descricao		:= "Sem registros"
		oItemSolicitacaoArmazem:Necessidade		:= Date()
		oItemSolicitacaoArmazem:UM				:= ""
		oItemSolicitacaoArmazem:Quantidade		:= 0
		oItemSolicitacaoArmazem:Unitario		:= 0
		oItemSolicitacaoArmazem:Total			:= 0

		aAdd(::aRelSolicitacaoArmazem:Itens, oItemSolicitacaoArmazem)
	EndIf

	(cAlias)->(dbCloseArea())

Return .T.

/*/{Protheus.doc} BuscarSA
Busca a Solicitação ao Armazem no Protheus
@author Anderson José Zelenski
@since 03/07/2022
/*/

WSMETHOD BuscarSA WSRECEIVE cCodigo WSSEND oSolicitacaoArmazem WSSERVICE FluigProtheus
	Local oItemSA

	SCP->(DbSetOrder(1))
	SCP->(DbSeek(xFilial("SCP")+::cCodigo))

	::oSolicitacaoArmazem := WSClassNew("oSolicitacaoArmazem")
	::oSolicitacaoArmazem:Usuario		:= SCP->CP_SOLICIT
	::oSolicitacaoArmazem:IdFluig		:= SCP->CP_IDFLUIG
	::oSolicitacaoArmazem:LoginFluig	:= SCP->CP_LGFLUIG
	::oSolicitacaoArmazem:Itens := {}

	While !SCP->(Eof()) .And. SCP->CP_FILIAL+SCP->CP_NUM == xFilial("SCP")+::cCodigo

		oItemSA := WSClassNew("oItemSA")

		oItemSA:Produto 		:= SCP->CP_PRODUTO
		oItemSA:Necessidade 	:= SCP->CP_DATPRF
		oItemSA:Quantidade		:= SCP->CP_QUANT
		oItemSA:Unitario		:= SCP->CP_VUNIT
		oItemSA:Observacao		:= SCP->CP_OBS

		aAdd(::oSolicitacaoArmazem:Itens, oItemSA)

		SCP->(dbSkip())
	EndDo

	SCP->(dbCloseArea())

Return .T.

/*/{Protheus.doc} CentrosCustos
Retorna os Centros de Custos
@author Sandro Antonio Nascimento
@since 01/08/2022
/*/
WSMETHOD AtualizaSA WSRECEIVE cCodigo, cRateio WSSEND cStatus WSSERVICE FluigProtheus
	/*SCP->(DbSetOrder(1))
	::cStatus := "nOK"
	if SCP->(DbSeek(xFilial("SCP")+::cCodigo))

		RecLock("SCP", .F.)
		SCP->CP_TIPRAT := cRateio
		SCP->(MsUnlock())
		::cStatus := "OK"
	endif

	SCP->(dbCloseArea())*/

	SCP->(DbSetOrder(1)) 
	::cStatus := "nOK"
	// procura o cCodigo na SCP, se achar, retonar .T.
	if SCP->(DbSeek(xFilial("SCP")+::cCodigo))
		// enqunto não for fim da tabela e a chave Filial + Num = chave de busca
		While SCP->(!EOF()) .and. SCP->(CP_FILIAL + CP_NUM) == xFilial("SCP")+::cCodigo
			RecLock("SCP", .F.)
			SCP->CP_TIPRAT := cRateio
			SCP->(MsUnlock()) 
			::cStatus := "OK"
			
			SCP->( DbSkip()) // avança um registro da SCP
		Enddo
	endif
	SCP->(dbCloseArea())
	
Return .T.





/*/{Protheus.doc} CentrosCustos
Retorna os Centros de Custos
@author Sandro Antonio Nascimento
@since 01/08/2022
/*/
WSMETHOD BuscarFornecedor WSRECEIVE cCnpj WSSEND aFornecedores WSSERVICE FluigProtheus
	Local oFornecedor
	Local cAlias	:= GetNextAlias()
	Local cQuery	:= ''

	::aFornecedores := WSClassNew("oFornecedores")
	::aFornecedores:Itens := {}

	cQuery := "Select A2_COD, A2_LOJA, A2_NOME, A2_MSBLQL, A2_CALCIRF, A2_BANCO, A2_AGENCIA, A2_NUMCON "
	cQuery += "from "+RetSqlName('SA2')+" A2 "
	cQuery += "where A2_MSBLQL<>'1'  "
	If !Empty(::cCnpj)
		cQuery += " AND A2_CGC = '"+::cCnpj+"' "
	ENDIF
	
	cQuery += "		AND A2.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)

	TcQuery cQuery New Alias (cAlias)

	dbSelectArea(cAlias)

	While (cAlias)->(!Eof())

		oFornecedor := WSClassNew("oFornecedor")

		oFornecedor:Codigo 		:= (cAlias)->A2_COD
		oFornecedor:Filial 		:= (cAlias)->A2_LOJA
		oFornecedor:Descricao	:= (cAlias)->A2_NOME
		oFornecedor:Situacao	:= (cAlias)->A2_MSBLQL
		oFornecedor:Tipo 		:= (cAlias)->A2_CALCIRF
		oFornecedor:Banco 		:= (cAlias)->A2_BANCO
		oFornecedor:Agencia		:= (cAlias)->A2_AGENCIA
		oFornecedor:Conta		:= (cAlias)->A2_NUMCON

		aAdd(::aFornecedores:Itens, oFornecedor)

		(cAlias)->(dbSkip())
	EndDo

	(cAlias)->(dbCloseArea())

Return .T.




/*/{Protheus.doc} CentrosCustos
Retorna os Centros de Custos
@author Sandro Antonio Nascimento
@since 02/08/2022
/*/
WSMETHOD BuscarNF WSRECEIVE cFornece, cLoja, cNotaFiscal WSSEND cStatus WSSERVICE FluigProtheus
	Local cAlias	:= GetNextAlias()
	Local cQuery	:= ''

	Conout("BuscarNF")

	::cStatus := "nOK"

	cQuery := "Select E2_SALDO "
	cQuery += "from  "+RetSqlName('SE2')+" E2 "
	cQuery += "where E2_TIPO = 'NF' "
	cQuery += "AND E2_LOJA = '"+::cLoja+"' "
	cQuery += "AND E2_FORNECE = '"+::cFornece+"' "
	cQuery += "AND E2_NUM = '"+::cNotaFiscal+"' "
	cQuery += "AND E2.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)

	Conout(cQuery)

	TcQuery cQuery New Alias (cAlias)

	dbSelectArea(cAlias)

	While (cAlias)->(!Eof())

		::cStatus := "OK"

		(cAlias)->(dbSkip())
	EndDo

	(cAlias)->(dbCloseArea())


Return .T.

/*/{Protheus.doc} CentrosCustos
Retorna os Centros de Custos
@author Sandro Antonio Nascimento
@since 13/03/2022
/*/
WSMETHOD BuscarNFEmissao WSRECEIVE cFornece, cLoja, cNotaFiscal, cEmissao WSSEND cStatus WSSERVICE FluigProtheus
	Local cAlias	:= GetNextAlias()
	Local cQuery	:= ''

	Conout("BuscarNFEmissao")

	::cStatus := "nOK"

	cQuery := "Select E2_SALDO "
	cQuery += "from  "+RetSqlName('SE2')+" E2 "
	cQuery += "where E2_TIPO = 'NF' "
	cQuery += "AND E2_LOJA = '"+::cLoja+"' "
	cQuery += "AND E2_FORNECE = '"+::cFornece+"' "
	cQuery += "AND E2_NUM = '"+::cNotaFiscal+"' "
	cQuery += "AND YEAR (E2_EMISSAO) = '"+::cEmissao+"' "
	cQuery += "AND E2.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)

	Conout(cQuery)

	TcQuery cQuery New Alias (cAlias)

	dbSelectArea(cAlias)

	While (cAlias)->(!Eof())

		::cStatus := "OK"

		(cAlias)->(dbSkip())
	EndDo

	(cAlias)->(dbCloseArea())


Return .T.

/*/{Protheus.doc} CentrosCustos
Retorna os Centros de Custos
@author Sandro Antonio Nascimento
@since 02/08/2022
/*/
WSMETHOD BuscarPR WSRECEIVE cFornece, cLoja, cValor WSSEND cStatus WSSERVICE FluigProtheus
	Local cAlias	:= GetNextAlias()
	Local cQuery	:= ''

	Conout("BuscarPR")

	::cStatus := "nOK"

	cQuery := "Select E2_SALDO "
	cQuery += "from  "+RetSqlName('SE2')+" E2 "
	cQuery += "where E2_TIPO = 'PR' "
	cQuery += "AND E2_LOJA = '"+::cLoja+"' "
	cQuery += "AND E2_FORNECE = '"+::cFornece+"' "
	cQuery += "AND E2_VALOR = '"+::cValor+"' "
	cQuery += "AND E2_BAIXA = '' "
	cQuery += "AND E2_SALDO > 0 "
	cQuery += "AND E2.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)

	Conout(cQuery)

	TcQuery cQuery New Alias (cAlias)

	dbSelectArea(cAlias)

	While (cAlias)->(!Eof())

		::cStatus := "OK"

		(cAlias)->(dbSkip())
	EndDo

	(cAlias)->(dbCloseArea())

	if ::cStatus == "nOK"
		cQuery := "Select E2_SALDO "
		cQuery += "from  "+RetSqlName('SE2')+" E2 "
		cQuery += "where E2_TIPO = 'PR' "
		cQuery += "AND E2_LOJA = '"+::cLoja+"' "
		cQuery += "AND E2_FORNECE = '"+::cFornece+"' "
		cQuery += "AND E2_VALOR = '"+::cValor+"' "
		cQuery += "AND E2_BAIXA <> '' "
		cQuery += "AND E2_SALDO = '' "
		cQuery += "AND E2.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		Conout(cQuery)
		TcQuery cQuery New Alias (cAlias)

		dbSelectArea(cAlias)

		While (cAlias)->(!Eof())

			::cStatus := "OKB"

			(cAlias)->(dbSkip())
		EndDo

		(cAlias)->(dbCloseArea())
	endif

Return .T.

//Gera a NF no Protheus

WSMETHOD GerarNF WSRECEIVE oDocEntr WSSEND cCodigo WSSERVICE FluigProtheus
	Local lError 	:= .T.
	Local aSF1		:= {}
	Local aSD1     := {}
	Local nI		:= 1
	Local cNum 		:= ''
	Local cSerie 		:= ''
	Local cCentroCusto := ''
	Local cIdFluig	:= ''
	Local cCond		:= SuperGetMV("MV_XCONDWS",.F.,"001")
	Local cTes		:= SuperGetMV("MV_XTESWS",.F.,"001")
	Local aItemD1 	:= {}
	Local lBaixa	:= .F.
	Local nTotal 	:= 0

	PRIVATE lMsErroAuto := .F.
	Conout("GERARNF - Gerar Nota Fiscal de Entrada...")

	Conout("GERARNF - Gerar Nota Fiscal de Entrada..."+varInfo("oDocEntr",oDocEntr, , .f., .f.))


	BEGIN TRANSACTION

		cFilAnt 		:= "010101"//oDocEntr['Filial']
		cNum 			:= oDocEntr['Numero']
		cSerie 			:= oDocEntr['Serie']
		cForn 			:= oDocEntr['Fornece']
		cLoja 			:= oDocEntr['Loja']
		cIdFluig 		:= oDocEntr['IdFluig']
		dEmissao 		:= cTod(SubStr(oDocEntr['Emissao'],9,2)+"/"+SubStr(oDocEntr['Emissao'],6,2)+"/"+SubStr(oDocEntr['Emissao'],1,4))
		dVencto			:= cTod(SubStr(oDocEntr['Vencimento'],9,2)+"/"+SubStr(oDocEntr['Vencimento'],6,2)+"/"+SubStr(oDocEntr['Vencimento'],1,4))

		//Força atualização do fornecedor
		//Produto 500228 já parametrizado
		//Natureza 200201002 ja parametrizada
		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))//A2_FILIAL+A2_COD+A2_LOJA

		if SA2->(DbSeek(xFilial("SA2")+cForn+cLoja))
			
			if SA2->A2_TIPO == 'F'
				cSql := " UPDATE "+RetSqlName("SA2")+" SET A2_NATUREZ = '200201002', A2_MINIRF = '2', A2_CALCIRF = '1'  "
				cSql += " WHERE A2_FILIAL = '"+xFilial("SA2")+"' AND A2_COD = '"+cForn+"' AND A2_LOJA = '"+cLoja+"' "
				
				TCSQLExec(cSql)
	
			else
				cSql := " UPDATE "+RetSqlName("SA2")+" SET A2_NATUREZ = '200201002', A2_MINIRF = '2' "
				cSql += " WHERE A2_FILIAL = '"+xFilial("SA2")+"' AND A2_COD = '"+cForn+"' AND A2_LOJA = '"+cLoja+"' "
				
				TCSQLExec(cSql)
			endif
			
		endif

		aAdd(aSF1, {"F1_FILIAL" , cFilAnt           	, Nil})//
		aAdd(aSF1, {"F1_TIPO"   , "N"                 	, Nil})
		aAdd(aSF1, {"F1_FORMUL" , "N"                 	, Nil})
		aAdd(aSF1, {"F1_DOC"    , cNum                	, Nil})
		aAdd(aSF1, {"F1_SERIE"  , "CJ1"              	, Nil})
		aAdd(aSF1, {"F1_EMISSAO", dEmissao           	, Nil})
		aAdd(aSF1, {"F1_FORNECE", cForn         		, Nil})
		aAdd(aSF1, {"F1_LOJA"   , cLoja        			, Nil})
		aAdd(aSF1, {"F1_COND"   , cCond               	, Nil})
		aAdd(aSF1, {"F1_ESPECIE", "NFS"              	, Nil})
		aAdd(aSF1, {"F1_PBRUTO" , 0 					, Nil})
		aAdd(aSF1, {"F1_ESPECI1", "0"					, Nil})
		aAdd(aSF1, {"F1_VOLUME1", 0						, Nil})
		aAdd(aSF1, {"F1_IDFLUIG", cIdFluig				, Nil})

		SB1->(DbSetOrder(1))

		For nI := 1 To Len(oDocEntr:ITENS)//Len(oDocEntr['Itens'])

			oItemNF := WSClassNew("oItemNF")

			Conout("GERARNF - Gerar itens ..."+varInfo("oItemNF",oItemNF, , .f., .f.))

			aItemD1 := {}
			aItemD1 := oDocEntr['Itens']
			oItemNF := aItemD1[nI]
			cCentroCusto 	:= oItemNF:CentroCusto

			if SB1->(DbSeek(xFilial("SB1")+oItemNF:Codigo))
				//Adiciona os Itens da NF
				aLin := {}
				aAdd(aLin, {"D1_FILIAL" , cFilAnt             , Nil})
				aAdd(aLin, {"D1_ITEM"   , StrZero(nI, 4)	  , Nil})
				aAdd(aLin, {"D1_COD"    , Alltrim(oItemNF:Codigo)     , Nil})
				aAdd(aLin, {"D1_QUANT"  , oItemNF:Quantidade  , Nil})
				aAdd(aLin, {"D1_VUNIT"  , val(oItemNF:Unitario)					  , Nil})//oItemNF:Unitario
				aAdd(aLin, {"D1_TOTAL"  , val(oItemNF:Total)				       , Nil}) //oItemNF:Total
				aAdd(aLin, {"D1_TES"    , cTes    			  , Nil})
				aAdd(aLin, {"D1_CC"		, cCentroCusto        , Nil})
				aAdd(aLin, {"D1_ITEMCTA", "0040"        , Nil})//@Todo Validar com usuarios

				aAdd(aSD1, aClone(aLin))
				nTotal := nTotal + val(oItemNF:Total)
			else
				Conout("Produto não escontrado: "+oItemNF:Codigo)
			endif

		Next nI

		if !Empty(aSF1) .or. !Empty(aSD1)

			MSExecAuto({|x,y,z| Mata103(x,y,z)},aSF1,aSD1,3) //Inclusao
			IF lMsErroAuto
				rollbacksx8()
				If (!IsBlind()) // COM INTERFACE GRÁFICA
					MostraErro()
				Else // EM ESTADO DE JOB
					cError := MostraErro("/dirdoc", "GerarNF_error_ws"+dtos(date())+"_"+strtran(time(),":","")+".log") // ARMAZENA A MENSAGEM DE ERRO
					ConOut(PadC("Automatic routine ended with error", 80))
					ConOut("Error: "+ cError)
				EndIf
				lError := .T.
			ELSE
				lError := .F.
				RecLock("SE2", .F.)
				SE2->E2_VENCTO := dVencto
				SE2->E2_VENCREA := dVencto
				SE2->E2_IDFLUIG := cIdFluig				
				//SE2->E2_VENCORI := dVencto Manter padrao

				MsUnlock()

			ENDIF

		endif

	END TRANSACTION

	If lError
		::cCodigo := "NOK"
		cMens := "Erro ao gravar o documento de entrada."
		conout('[' + DToC(Date()) + " " + Time() + "] GravarDocumentoEntrada > " + cMens)
		SetSoapFault("Erro", cMens)
		Return .F.

	else
		::cCodigo := cNum
		lBaixa := BaixaPR(cForn,cLoja,nTotal,cIdFluig)

		if !lBaixa
			Conout("Erro na baixa do provisorio...")
		endif
	EndIf

Return .T.

Static Function BaixaPR(cForn,cLoja,nValor,cIdFlg)

	Local aArea:=GetArea()
	Local lRet := .T.
	Local cQuery	:= ''

	lMsErroAuto := .F.

	cQuery := "SELECT E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,E2_IDFLUIG"
	cQuery += " FROM  "+RetSqlName('SE2')+" E2 "
	cQuery += " WHERE E2_TIPO = 'PR' "
	cQuery += " AND E2_LOJA = '"+cLoja+"' "
	cQuery += " AND E2_FORNECE = '"+cForn+"' "
	cQuery += " AND Round(E2_VALOR,2) = round("+cValtoChar(nValor)+",2) "
	//cQuery += " AND E2_NUM = '999999999'
	cQuery += " AND E2_BAIXA = '' "
	cQuery += " AND E2_SALDO > 0 "
	cQuery += " AND E2.D_E_L_E_T_ = '' "
	
	Conout("Buscando PR no valor de "+cValtoChar(nValor))
	Conout("Query " + cQuery)
	If SELECT("cAlias") > 0
		cAlias->(dbCloseArea())
	EndIf

	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias ("cAlias")

	cAlias->(dbGoTop())
	if cAlias->(!Eof())

		DbSelectArea("SE2")
		SE2->(DbGoTop())
		SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

		if SE2->(DbSeek(xFilial("SE2")+Padr(cAlias->E2_PREFIXO,3)+StrZero(Val(cAlias->E2_NUM),9)+Space(3)+"PR "+cAlias->E2_FORNECE+cAlias->E2_LOJA))

			RecLock("SE2",.F.)
			SE2->E2_SALDO := 0
			SE2->E2_BAIXA := dDataBase
			SE2->E2_IDFLUIG := cIdFlg
			MsUnlock()

		endif
		cAlias->(dbCloseArea())

	else
		Conout("Chave de titulo nao encontrada...")//Não interfere na gravação da NF
		lRet := .F.
	endif

	RestArea(aArea)

Return lRet





/*/{Protheus.doc} Materiais
Retorna os Materiais
@author Rubens Simi
@since 29/09/2022
/*/
WSMETHOD BuscarClienteS WSRECEIVE cCnpj WSSEND aConsultas WSSERVICE FluigProtheus
	Local oConsulta
	Local cAlias	:= GetNextAlias()
	Local cQuery	:= ''
	// Local aLinha  :={}
	// LOCAL Y
	Local lAchou:=.f.
	::aConsultas := WSClassNew("oConsultas")
	::aConsultas:Itens := {}

	cQuery := "Select A1_COD, A1_LOJA, A1_NOME, A1_MSBLQL, A1_DDD, A1_TEL, A1_EMAIL, A1_CEP, A1_END, A1_MUN, A1_BAIRRO, A1_COMPLEM, A1_EST , A1_INSCR, A1_EMAIL "
	//cQuery := "Select * "
	cQuery += "from "+RetSqlName('SA1')+" A1 "
	cQuery += "where A1_MSBLQL<>'1'  "
	If !Empty(::cCnpj)
		cQuery += " AND A1_CGC = '"+::cCnpj+"' "
	ENDIF

	cQuery += "		AND A1.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)

	TcQuery cQuery New Alias (cAlias)

	dbSelectArea(cAlias)

	While (cAlias)->(!Eof())

		lAchou:=.t.
		oConsulta := WSClassNew("oConsulta")
		
		oConsulta:Codigo 		:= (cAlias)->A1_COD
		oConsulta:Filial 		:= (cAlias)->A1_LOJA
		oConsulta:Descricao		:= (cAlias)->A1_NOME
		oConsulta:Endereco		:= (cAlias)->A1_END
		oConsulta:Complemento	:= (cAlias)->A1_COMPLEM
		oConsulta:Est		    := (cAlias)->A1_EST
		oConsulta:Municipio		:= (cAlias)->A1_MUN
		oConsulta:Bairro		:= (cAlias)->A1_BAIRRO
		oConsulta:CEP   		:= (cAlias)->A1_CEP
		oConsulta:InscricaoEst	:= (cAlias)->A1_INSCR
		oConsulta:Situacao	:= (cAlias)->A1_MSBLQL
		oConsulta:DDD	        := (cAlias)->A1_DDD
		oConsulta:Telefone	    := (cAlias)->A1_TEL	
		oConsulta:Email	    := (cAlias)->A1_EMAIL	

		aAdd(::aConsultas:Itens, oConsulta)

		(cAlias)->(dbSkip())
	EndDo

	(cAlias)->(dbCloseArea())

	if !lAchou

		cMens := "Registrro nao localizado"
		conout('[' + DToC(Date()) + " " + Time() + "] ConsultatGenreica > " + cMens)
		SetSoapFault("Erro", cMens)
		Return .F.
	ENDIF
Return .T.




/*/{Protheus.doc} GerarPr
Inclusao de titulo a receber 
@author Rubens Simi
@since 17/09/2022
/*/

WSMETHOD GerarPr WSRECEIVE oTitPr WSSEND cCodigo WSSERVICE FluigProtheus
	Local lError 	:= .T.
	Local aVetSE1
	Local cMens  := ""
	Local cError := ""
	Local cE1_CCC
	Local cE1_ITEMC
	Local cE1_CLVLCR
	Local cE1_CLVLDB
	Local cFilSave := cFilAnt
	Local aLog
	Local aEmprs
	Local nPosFil := 1
	Local cFileErr := "/dirdoc/errows_"+procname()+"_"+dtos(date())+"_"+strtran(time(),":","")+".txt"
	Local cNaturez := ""
	private cFilTit  := cFilAnt
	private lAutoErrNoFile := .T.
	PRIVATE lMsErroAuto := .F.
	Conout("GerarPr - Gerar titulo a receber...")
    BEGIN SEQUENCE
		if !empty(oTitPr:E1_FILIAL)
			cFilTit := oTitPr:E1_FILIAL
			aEmprs:= FWLoadSM0()
			if !empty(nPosFil := ascan(aEmprs, {|it| it[1]=cEmpAnt .and. it[2]=cFilTit}))
				cFilAnt := cFilTit
			endif
		endif
		dEmissao 		:= STOD(oTitPr:E1_EMISSAO)
		dVencto			:= STOD(oTitPr:E1_VENCTO)
		cE1_CCC         := oTitPr:E1_CCC   
		cE1_ITEMC		:= oTitPr:E1_ITEMC 
		cE1_CLVLCR		:= oTitPr:E1_CLVLCR
		cE1_CLVLDB		:= oTitPr:E1_CLVLDB
		if empty(cE1_CCC)
			cE1_CCC := GetMv("AD_ANTCCUC",,"")
		endif
		if empty(cE1_ITEMC)
			cE1_ITEMC := GetMv("AD_ANTITEC",,"")
		endif
		// cFilant:=oTitPr:E1_FILIAL
		DbSelectArea('CTT')
		if empty(nPosFil)
			cError:="Error: Filial "+cFilTit+" nao localizado."
			memowrite(cFileErr, ;
					varInfo("oTitPr",oTitPr, , .f., .f.) + CRLF + cError )  
		elseif !empty(oTitPr:E1_CGC )

			DbSelectArea('SA1')
			SA1->(dbSetOrder(3))  // A1_FILIAL+A1_CGC
			If SA1->(DbSeek(xFilial('SA2')+oTitPr:E1_CGC))
				cNaturez := SA1->A1_NATUREZ
				if empty(cNaturez)
					cNaturez := GetMv("AD_ANTNATU",,"")
				endif
                if empty(cE1_CLVLCR)
                    //cE1_CLVLCR := GetMv("AD_ANTCLVC",,"")
                    cE1_CLVLCR := "C"+SA1->A1_COD+SA1->A1_LOJA
                endif
                if empty(cE1_CLVLDB)
                    //cE1_CLVLDB := GetMv("AD_ANTCLVD",,"")
                    cE1_CLVLDB := "C"+SA1->A1_COD+SA1->A1_LOJA
                endif

				//Prepara o array para o execauto
				aVetSE1 := {}
				cProc := Iif (Type("oTitPr:E1_XPROCES")<> "U",oTitPr:E1_XPROCES,"")
				// aadd(aVetSE1, {"E1_FILIAL" , oTitPr:E1_FILIAL       , Nil})
				aadd(aVetSE1, {"E1_NUM"    , oTitPr:E1_NUM          , Nil})
				aadd(aVetSE1, {"E1_PREFIXO", oTitPr:E1_PREFIXO      , Nil})
				aadd(aVetSE1, {"E1_PARCELA", oTitPr:E1_PARCELA      , Nil})
				aadd(aVetSE1, {"E1_TIPO"   , oTitPr:E1_TIPO         , Nil})
				aadd(aVetSE1, {"E1_NATUREZ", cNaturez               , Nil})
				aadd(aVetSE1, {"E1_CLIENTE", SA1->A1_COD            , Nil})
				aadd(aVetSE1, {"E1_LOJA"   , SA1->A1_LOJA           , Nil})
				aadd(aVetSE1, {"E1_NOMCLI" , SA1->A1_NREDUZ         , Nil})
				aadd(aVetSE1, {"E1_EMISSAO", dEmissao               , Nil})
				aadd(aVetSE1, {"E1_VENCTO" , dVencto                , Nil})
				aadd(aVetSE1, {"E1_VENCREA", DataValida(dVencto,.T.), Nil})
				aadd(aVetSE1, {"E1_VALOR"  , oTitPr:E1_VALOR        , Nil})
				aadd(aVetSE1, {"E1_MOEDA"  , 1                      , Nil})
				aadd(aVetSE1, {"E1_CCC"    , cE1_CCC          , Nil})
				aadd(aVetSE1, {"E1_ITEMC"  , cE1_ITEMC        , Nil})
				aadd(aVetSE1, {"E1_CLVLDB" , cE1_CLVLDB       , Nil})
				aadd(aVetSE1, {"E1_CLVLCR" , cE1_CLVLCR       , Nil})
				aadd(aVetSE1, {"E1_IDFLUIG" , oTitPr:E1_IDFLUIG       , Nil})
				aadd(aVetSE1, {"E1_XPROCES" , cProc       , Nil})
				//Chama a rotina automática
				lMsErroAuto := .F.
				lAutoErrNoFile := .T.
				BEGIN TRANSACTION
						// 	cError := MostraErro("/dirdoc", "error_ws.log") // ARMAZENA A MENSAGEM DE ERROON
					MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 3)

					//Se houve erro, mostra o erro ao usuário e desarma a transação
					If lMsErroAuto
						// If (!IsBlind()) // COM INTERFACE GRÁFICA
						// 	MostraErro()
						// Else // EM 
						// 	ConOut(PadC("Automatic routine ended with error", 80))
						// 	ConOut("Error: "+ cError)
						// EndIf
						// lError := .T.
						cError := "Error: "
						aLog  := GetAutoGRLog() 
						aeval(aLog, {|x| cError += x+CRLF})
						memowrite(cFileErr, ;
								varInfo("oTitPr",oTitPr, , .f., .f.) + CRLF  ;
								+ varInfo("aVetSE1",aVetSE1, , .f., .f.) + CRLF  ;
								+ cError )  
						ConOut(Procname()+" -> "+cError)
					else
						lError := .F.
					EndIf
				END TRANSACTION
			else
				cError:="Error: CPF/CNPJ " + oTitPr:E1_CGC + " nao localizado"
				memowrite(cFileErr, ;
						varInfo("oTitPr",oTitPr, , .f., .f.) + CRLF + cError )  
			endif
		ELSE
			cError:="Error: CPF/CNPJ nao recebido."
			memowrite(cFileErr, ;
					varInfo("oTitPr",oTitPr, , .f., .f.) + CRLF + cError )  
		ENDIF
    RECOVER
//
    END SEQUENCE
	// Restaura a filial
	cFilAnt := cFilSave

	If lError
		::cCodigo := "NOK"
		cMens := "Erro ao gravar o Titulo a Receber"
		conout('[' + DToC(Date()) + " " + Time() +  "] " + procname() + " > " + cMens+ ". " + cError)
		SetSoapFault("Erro", cError)
	else
		::cCodigo := "YOK"
	EndIf

Return !lError



/*/{Protheus.doc} GerarPG
Inclusao de titulo a pagar 
@author Rubens Simi
@since 17/09/2022
/*/

WSMETHOD GerarPG WSRECEIVE oTitPg WSSEND cCodigo WSSERVICE FluigProtheus
	Local lError 	:= .T.
	Local dEmissao
	Local dVencto
	Local aVetSE2
	Local cMens  := ""
	Local cError := ""
	Local cE2_CCD
	Local cE2_ITEMD
	Local cE2_CLVLDB
	Local cFilSave := cFilAnt
	Local aLog
	Local aEmprs
	Local nPosFil := 1
	Local cFileErr := "/dirdoc/errows_"+procname()+"_"+dtos(date())+"_"+strtran(time(),":","")+".txt"
	Local cNaturez := ""
	private cFilTit  := cFilAnt
	private lAutoErrNoFile := .T.
	private lMsErroAuto := .F.
	Conout("GerarPG - Gerar titulo a pagar..."+varInfo("oTitPg",oTitPg, , .f., .f.))
    BEGIN SEQUENCE
		if !empty(oTitPg:E2_FILIAL)
			cFilTit := oTitPg:E2_FILIAL
			aEmprs:= FWLoadSM0()
			if !empty(nPosFil := ascan(aEmprs, {|it| it[1]=cEmpAnt .and. it[2]=cFilTit}))
				cFilAnt := cFilTit
			endif
		endif
		dEmissao 		:= STOD(oTitPg:E2_EMISSAO)
		dVencto			:= STOD(oTitPg:E2_VENCTO)
		cE2_CCD         := oTitPg:E2_CCD   
		cE2_ITEMD		:= oTitPg:E2_ITEMD 
		cE2_CLVLDB		:= oTitPg:E2_CLVLDB
		if empty(cE2_CCD)
			cE2_CCD := GetMv("AD_ANTCCUD",,"")
		endif
		if empty(cE2_ITEMD)
			cE2_ITEMD := GetMv("AD_ANTITED",,"")
		endif
		dbSelectArea('CTH')
		dbSelectArea('CTD')
		dbSelectArea('CTT')
		dbSelectArea('CT1')
		if empty(nPosFil)
			cError:="Error: Filial "+cFilTit+" nao localizado."
			memowrite(cFileErr, ;
					varInfo("oTitPg",oTitPg, , .f., .f.) + CRLF + cError )  
		elseif !empty(oTitPg:E2_CGC )

			DbSelectArea('SA2')
			SA2->(dbSetOrder(3))  // A2_FILIAL+A2_CGC

			If SA2->(DbSeek(xFilial('SA2')+oTitPg:E2_CGC))
				cNaturez := SA2->A2_NATUREZ
				if empty(cNaturez)
					cNaturez := GetMv("AD_ANTNATC",,"")
				endif
                if empty(cE2_CLVLDB)
//                    cE2_CLVLDB := GetMv("AD_ANTCLVD",,"")
                    cE2_CLVLDB := "F"+SA2->A2_COD+SA2->A2_LOJA
                endif

		//		Conout(cNaturez)

				//Prepara o array para o execauto
				aVetSE2 := {}
				cProc := Iif (Type("oTitPg:E2_XPROCES")<> "U",oTitPg:E2_XPROCES,"")
				conOut(oTitPg:E2_XPROCES)
				// aadd(aVetSE2, {"E2_FILIAL" , cFilTit                , Nil})
				aadd(aVetSE2, {"E2_NUM"    , oTitPg:E2_NUM          , Nil})
				aadd(aVetSE2, {"E2_PREFIXO", oTitPg:E2_PREFIXO      , Nil})
				aadd(aVetSE2, {"E2_PARCELA", oTitPg:E2_PARCELA      , Nil})
				aadd(aVetSE2, {"E2_TIPO"   , oTitPg:E2_TIPO         , Nil})
				aadd(aVetSE2, {"E2_NATUREZ", cNaturez               , Nil})
				aadd(aVetSE2, {"E2_FORNECE", SA2->A2_COD            , Nil})
				aadd(aVetSE2, {"E2_LOJA"   , SA2->A2_LOJA           , Nil})
				aadd(aVetSE2, {"E2_NOMFOR" , SA2->A2_NREDUZ         , Nil})
				aadd(aVetSE2, {"E2_EMISSAO", dEmissao               , Nil})
				aadd(aVetSE2, {"E2_VENCTO" , dVencto                , Nil})
				aadd(aVetSE2, {"E2_VENCREA", DataValida(dVencto,.T.), Nil})
				aadd(aVetSE2, {"E2_VALOR"  , oTitPg:E2_VALOR        , Nil})
				aadd(aVetSE2, {"E2_HIST"   , oTitPg:E2_HIST         , Nil})
				aadd(aVetSE2, {"E2_MOEDA"  , 1                      , Nil})
				aadd(aVetSE2, {"E2_CCD"    , cE2_CCD          , Nil})
				aadd(aVetSE2, {"E2_ITEMD"  , cE2_ITEMD        , Nil})
				aadd(aVetSE2, {"E2_CLVLDB" , cE2_CLVLDB       , Nil})
				aadd(aVetSE2, {"E2_IDFLUIG" , oTitPg:E2_IDFLUIG       , Nil})
				aadd(aVetSE2, {"E2_XPROCES" , cProc      , Nil})
				//Chama a rotina automática
				lMsErroAuto := .F.
				lAutoErrNoFile := .T.
				BEGIN TRANSACTION
					MSExecAuto({|x,y| FINA050(x,y)}, aVetSE2, 3)

					//Se houve erro, mostra o erro ao usuário e desarma a transação
					If lMsErroAuto
						// If (!IsBlind()) // COM INTERFACE GRÁFICA
						// 	MostraErro()
						// Else // EM ESTADO DE JOB
						// 	cError := MostraErro("/dirdoc", "error_ws.log") // ARMAZENA A MENSAGEM DE ERRO
						// 	ConOut(PadC("Automatic routine ended with error", 80))
						// 	ConOut("Error: "+ cError)
						// EndIf
						cError := "Error: "
						aLog  := GetAutoGRLog() 
						aeval(aLog, {|x| cError += x+CRLF})
						memowrite(cFileErr, ;
								varInfo("oTitPg",oTitPg, , .f., .f.) + CRLF  ;
								+ varInfo("aVetSE2",aVetSE2, , .f., .f.) + CRLF  ;
								+ cError )  
						ConOut(Procname()+" -> "+cError)
					else
						lError := .F.
					EndIf
				END TRANSACTION
			else
				cError:="Error: CNPJ "+oTitPg:E2_CGC+" nao localizado."
				memowrite(cFileErr, ;
						varInfo("oTitPg",oTitPg, , .f., .f.) + CRLF + cError )  
			endif
		ELSE
			cError:="Error: CNPJ nao recebido."
			memowrite(cFileErr, ;
					varInfo("oTitPg",oTitPg, , .f., .f.) + CRLF + cError )  
		ENDIF

    RECOVER
//
    END SEQUENCE
	// Restaura a filial
	cFilAnt := cFilSave
	If lError
		::cCodigo := "NOK"
		cMens := "Erro ao gravar o Titulo a Pagar"
		conout('[' + DToC(Date()) + " " + Time() + "] " + procname() + " > " + cMens + ". " + cError)
		SetSoapFault("Erro", cError)
	else
		::cCodigo := "YOK"
	EndIf

Return !lError



/*/{Protheus.doc} GerarCli
Inclusao Clientes
@author Rubens Simi
@since 06/10/2022
/*/

WSMETHOD GerarCli WSRECEIVE oCliente WSSEND cCodigo WSSERVICE FluigProtheus
	Local lError 	:= .T.
	Local aVetSA1
	Local cCodMun   := ""
	Local aLog
	Local aEmprs
	Local nPosFil := 1
	Local cFileErr := "/dirdoc/errows_"+procname()+"_"+dtos(date())+"_"+strtran(time(),":","")+".txt"
	private cFilCli  := cFilAnt
	private lAutoErrNoFile := .T.
	private lMsErroAuto := .F.
	Conout("GerarCli - Cadastrar cliente..."+varInfo("ocliente",ocliente, , .f., .f.))
    BEGIN SEQUENCE
		if !empty(ocliente:A1_FILIAL)
			cFilCli := ocliente:A1_FILIAL
			aEmprs:= FWLoadSM0()
			if !empty(nPosFil := ascan(aEmprs, {|it| it[1]=cEmpAnt .and. it[2]=cFilCli}))
				cFilAnt := cFilCli
			endif
		endif

		if empty(nPosFil)
			cError:="Error: Filial "+cFilCli+" nao localizada."
			memowrite(cFileErr, ;
					varInfo("ocliente",ocliente, , .f., .f.) + CRLF + cError )  
		elseif !empty(ocliente:A1_CGC )
			DbSelectArea('SA1')
			SA1->(dbSetOrder(3))  // A1_FILIAL+A1_CGC
			If SA1->(DbSeek(xFilial('SA2')+ocliente:A1_CGC))
				cError:="Error: cliente com CNPJ/CPF "+ocliente:A1_CGC+" ja cadastrado."
				memowrite(cFileErr, ;
						varInfo("oCliente",oCliente, , .f., .f.) + CRLF + cError )  
				lError := .F.
				cError := ""
			else
				cCodMun := fCEPIBGE(oCliente:A1_CEP)
				if empty(cCodMun)
					cError:="Error: codigo do municipio do CEP "+ocliente:A1_CEP+" nao encontrado."
					memowrite(cFileErr, ;
							varInfo("oCliente",oCliente, , .f., .f.) + CRLF + cError )  
					lError := .F.
				else
					aVetSA1 := {}
					aadd(aVetSA1, {"A1_TIPO"   , oCliente:A1_TIPO   , Nil})
					aadd(aVetSA1, {"A1_CGC"    , oCliente:A1_CGC    , Nil})
					aadd(aVetSA1, {"A1_INSCR"  , oCliente:A1_INSCR  , Nil})
					aadd(aVetSA1, {"A1_NOME"   , oCliente:A1_NOME   , Nil})
					aadd(aVetSA1, {"A1_NREDUZ" , oCliente:A1_NREDUZ , Nil})
					aadd(aVetSA1, {"A1_END"    , oCliente:A1_END    , Nil})
					aadd(aVetSA1, {"A1_BAIRRO" , oCliente:A1_BAIRRO , Nil})
					aadd(aVetSA1, {"A1_COMPLEM", oCliente:A1_COMPLEM, Nil})
					aadd(aVetSA1, {"A1_MUN"    , oCliente:A1_MUN    , Nil})
					aadd(aVetSA1, {"A1_EST"    , oCliente:A1_EST    , Nil})
					aadd(aVetSA1, {"A1_CEP"    , oCliente:A1_CEP    , Nil})
					aadd(aVetSA1, {"A1_DDD"    , oCliente:A1_DDD    , Nil})
					aadd(aVetSA1, {"A1_TEL"    , oCliente:A1_TEL    , Nil})
					SA1->(dbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA
					if SA1->(dbSeek(xFilial("SA1")+"XXXXXX", .t.))
						SA1->(dbSkip(-1))
					else
						SA1->(dbSkip(-1))
					endif
					aadd(aVetSA1, {"A1_COD_MUN"    , cCodMun   , Nil})
					
					aadd(aVetSA1, {"A1_COD"    , SOMA1(SA1->A1_COD)    , Nil})  // Campo automatico
					aadd(aVetSA1, {"A1_LOJA"   , "01"   , Nil})
					// aadd(aVetSA1, {"A1_PAIS"   , "105"              , Nil})  // Campo automatico
					// aadd(aVetSA1, {"A1_CODPAIS", "01058"			   , Nil})  // Campo automatico
					// aadd(aVetSA1, {"A1_CBAIRRE", oCliente:A1_CBAIRRE, Nil})

					//Chama a rotina automática
					lMsErroAuto := .F.
					lAutoErrNoFile := .T.
					MSExecAuto({|x,y| mata030(x,y)}, aVetSA1, 3)

					//Se houve erro, mostra o erro ao usuário e desarma a transação
					If lMsErroAuto
						cError := "Error: "
						aLog  := GetAutoGRLog() 
						aeval(aLog, {|x| cError += x+CRLF})
						memowrite(cFileErr, ;
								varInfo("oCliente",oCliente, , .f., .f.) + CRLF ;
								+ varInfo("aVetSA1",aVetSA1, , .f., .f.) + CRLF ;
                                + cError )  
						ConOut(Procname()+" -> "+cError)
					else
						lError := .F.
					EndIf
				EndIf
			Endif
		ELSE
			cError:="Error: CPF/CNPJ nao recebido."
			memowrite(cFileErr, ;
					varInfo("oCliente",oCliente, , .f., .f.) + CRLF + cError )  
		ENDIF

    RECOVER
//
    END SEQUENCE

	If lError
		::cCodigo := "NOK"
		cMens := "Erro ao gravar o Cliente"
		conout('[' + DToC(Date()) + " " + Time() +  "] " + procname() + " > " + cMens+ ". " + cError)
		SetSoapFault("Erro", cError)
	else
		::cCodigo := "YOK"
	EndIf

Return !lError


/*/{Protheus.doc} ListaCadastro
Retorna uma lista de cadastro basico
@author Sandro Antonio Nascimento
@since 01/11/2022
/*/
WSMETHOD ListaCadastro WSRECEIVE cTabela, cCampos, cWhere WSSEND aCadastros WSSERVICE FluigProtheus
	Local oCadastro
	Local cAlias
	Local cQuery	:= ''
	Local nIndReg   := 0
	Local nIndCampo := 0
	Local aCampos   := {}

	::aCadastros := WSClassNew("oCadastros")
	::aCadastros:Itens := {}
	aCampos := strTokArr(::cCampos, ",")
	cQuery := "SELECT "+::cCampos
	cQuery += " FROM "+RetSqlName(::cTabela)+" TAB "
	cQuery += " WHERE TAB.D_E_L_E_T_ = ' ' "
	cQuery += "	AND "+::cWhere
	cQuery := ChangeQuery(cQuery)
	memowrite("\temp\listacadastro_"+dtos(date())+"_"+strtran(time(),":","")+".txt", cQuery)

	cAlias := MPSysOpenQuery(cQuery,,,,)

	While (cAlias)->(!Eof())
		nIndReg++
		for nIndCampo := 1 to len(aCampos)
			oCadastro := WSClassNew("oCadastro")

			oCadastro:Indice 		:= nIndReg
			oCadastro:Campo 		:= alltrim(aCampos[nIndCampo])
			oCadastro:Valor      	:= cValToChar((cAlias)->(fieldget(fieldpos(trim(aCampos[nIndCampo])))))

			aAdd(::aCadastros:Itens, oCadastro)
		next
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

Return .T.

/*/{Protheus.doc} GerarPV
Inclusao Pedido de Vendas
@author Tiago Santos
@since 13/05/2023
/*/

WSMETHOD GerarPV WSRECEIVE oPedVenda WSSEND cCodigo WSSERVICE FluigProtheus
	Local lError 	:= .T.
	Local aVetSE1
	Local cMens  := ""
	Local cError := ""
	Local nI
	Local cFilSave := cFilAnt
	Local aLog
	Local aEmprs
	Local nPosFil := 1
	Local cFileErr := "/dirdoc/errows_"+procname()+"_"+dtos(date())+"_"+strtran(time(),":","")+".txt"
	Local cNaturez := ""
	private cFilTit  := cFilAnt
	private lAutoErrNoFile := .T.
	PRIVATE lMsErroAuto := .F.
	
	Conout("GerarPV - Cadastrar Pedido..."+varInfo("oPedVenda",oPedVenda, , .f., .f.))
	
    BEGIN SEQUENCE
		if !empty(oPedVenda:C5_FILIAL)
			conout("Filial: "+ oPedVenda:C5_FILIAL)
			cFilTit := oPedVenda:C5_FILIAL
			aEmprs:= FWLoadSM0()
			if !empty(nPosFil := ascan(aEmprs, {|it| it[1]=cEmpAnt .and. it[2]=cFilTit}))
				cFilAnt := cFilTit
			endif
		endif
		//SC5->( DbOrderNickName('IDFLUIG'))
		
		if empty(nPosFil)
			cError:="Error: Filial "+cFilTit+" nao localizado."
			memowrite(cFileErr, ;
					varInfo("oPedVenda",oPedVenda, , .f., .f.) + CRLF + cError )  
		elseif !empty(oPedVenda:C5_CLIENTE )

			DbSelectArea('SA1')
			SA1->(dbSetOrder(1))
			oItemPV := WSClassNew("oItemPV")
			If SA1->(DbSeek(xFilial('SA1')+oPedVenda:C5_CLIENTE + oPedVenda:C5_LOJACLI))

				aCabec := {}
				aItens := {}
				if oPedVenda:nOpc =='5' // exclusao
					conout(" Exclusao Pedido de venda.....")
					SC5->( DbOrderNickName('IDFLUIGSC5'))
					SC5->( DbSeek(xFilial("SC5") + oPedVenda:C5_IDFLUIG))
					conout("Pedido a ser excluido: "+ SC5->C5_NUM)
					ConOut("FunName()" + FunName())
					aadd(aCabec,{"C5_NUM"    ,SC5->C5_NUM ,Nil})
				Endif
				if select("SE4")==0
					DBSELECTAREA( "SE4" )
				Endif
				SE4->(DBOrderNickname("IDFLUIG"))
				SE4->(dbGotop())
				cCondPgt :=""
				If SE4->( DbSeek(xFilial("SE4") + oPedVenda:C5_CONDPAG))
					cCondPgt := SE4->E4_CODIGO
					conout("achou SE4")
				Endif
				aadd(aCabec,{"C5_TIPO"   ,"N",Nil})
				aadd(aCabec,{"C5_CLIENTE",oPedVenda:C5_CLIENTE,Nil})
				aadd(aCabec,{"C5_LOJACLI",oPedVenda:C5_LOJACLI,Nil})
				aadd(aCabec,{"C5_CLIENT" ,oPedVenda:C5_CLIENTE,Nil})
				aadd(aCabec,{"C5_LOJAENT",oPedVenda:C5_LOJAENT,Nil})
				aadd(aCabec,{"C5_CONDPAG", cCondPgt ,Nil})
				aadd(aCabec,{"C5_TPFRETE",oPedVenda:C5_TPFRETE,Nil})
				aadd(aCabec,{"C5_FRETE",oPedVenda:C5_FRETE,Nil})
				aadd(aCabec,{"C5_IDFLUIG",oPedVenda:C5_IDFLUIG,Nil})
								
				For nI := 1 To Len(oPedVenda['Itens'])
					oItemPV := WSClassNew("oItemPV")
					aItemSA := {}
					aItemSA := oPedVenda['Itens']
					oItemSA := aItemSA[nI] 
					nQtdLib := iif(oPedVenda:nOpc =='5',0,val(oItemSA:C6_QTDVEN))
					cEst := posicione('SA1',1,xFilial('SA1') + oPedVenda:C5_CLIENTE + oPedVenda:C5_LOJACLI,'A1_EST')   
					cTes := iif (cEst=='PR','501','502')
					Aadd(aItens, {;						
						{"C6_ITEM",		StrZero(nI,TamSx3("C6_ITEM")[1]),NIL},;
						{"C6_PRODUTO", oItemSA:C6_PRODUTO, 				NIL},;
						{"C6_QTDVEN",	Val(oItemSA:C6_QTDVEN),  		NIL},;
						{"C6_PRCVEN",	oItemSA:C6_PRCVEN,			NIL},;
						{"C6_VALOR",	oItemSA:C6_PRCVEN * Val(oItemSA:C6_QTDVEN),			NIL},;
						{"C6_TES",	    cTes,			                NIL},;
						{"C6_QTDLIB",	nQtdLib,			            NIL};
						})
				Next nI
				BEGIN TRANSACTION
					//****************************************************************
					//* Teste de Inclusao              
					//****************************************************************
					if oPedVenda:nOpc =='5'
						// primeiro altera o pedido estornando o pedido
						MSExecAuto({|x,y,z|mata410(x,y,z)},aCabec,aItens, 4) // primeiro altera o pedido
					Endif

					MSExecAuto({|x,y,z|mata410(x,y,z)},aCabec,aItens,val(oPedVenda:nOpc))
					If !lMsErroAuto
						ConOut("Incluido com sucesso! "+C5_NUM)
						lError := .F.
					Else
						ConOut("Erro no processamento!")
						cError := "Error: "
						aLog  := GetAutoGRLog() 
						aeval(aLog, {|x| cError += x+CRLF})
						ConOut(Procname()+" -> "+cError)
						lError := .T.
					EndIf

				END TRANSACTION
				


			else
				cError:="Error: Cliente + Loja " + oPedVenda:C5_CLIENTE+ oPedVenda:C5_LOJACLI + " nao localizado"
				memowrite(cFileErr, ;
					varInfo("oPedVenda",oPedVenda, , .f., .f.) + CRLF + cError )  
			endif
		ELSE
			cError:="Error: Cliente + Loja nao recebido."
			memowrite(cFileErr, ;
				varInfo("oPedVenda",oPedVenda, , .f., .f.) + CRLF + cError )  
		ENDIF
    RECOVER
//
    END SEQUENCE
	// Restaura a filial
	cFilAnt := cFilSave

	If lError
		::cCodigo := "NOK"
		cMens := "Erro ao gravar o Pedido de Venda"
		conout('[' + DToC(Date()) + " " + Time() +  "] " + procname() + " > " + cMens+ ". " + cError)
		SetSoapFault("Erro", cError)
	else
		::cCodigo := "YOK"
	EndIf

Return !lError

WSMETHOD FaturarPV WSRECEIVE IDFLUIG WSSEND cCodigo WSSERVICE FluigProtheus

if select("ZAL") ==0  // tabela que guarda as solicitações de faturamento de pedido
	DBSELECTAREA( "ZAL" )
Endif
ZAL->( DbSetOrder(1))
if SELECT('SC5') == 0
	DBSELECTAREA( "SC5" )
Endif
conout(procname()+" --> Recebeu "+cEmpAnt+" na filial "+cFilAnt)
// Forca filial 040101
cFilAnt := "040101"
dbSelectArea("SM0")
SM0->(dbSetOrder(1))
SM0->(dbSeek("05040101"))
// FWSM0Util():setSM0PositionBycFilAnt()

conout(procname()+" --> Recebeu "+cValToChar(::IDFLUIG)+" na filial "+xFilial("SC5"))
SC5->( DbOrderNickName('IDFLUIGSC5'))
if SC5->( DbSeek(xFilial("SC5") + ::IDFLUIG))
	if !ZAL->( DbSeek(xFilial("ZAL") + ::IDFLUIG))
		conout('Gravando ID FLUIG: ' + ::IDFLUIG)
		//cNota := pedToNf(xFilial("SC5"), SC5->C5_NUM, cSerieNF)

		RECLOCK( "ZAL", .T. )
			ZAL->ZAL_FILIAL := xFilial("ZAL")
			ZAL->ZAL_IDFLUI := ::IDFLUIG
			ZAL->ZAL_DATA   := dDatabase
			ZAL->ZAL_HORA   := Time()
			ZAL->ZAL_STATUS := '0'
		ZAL->(MSUNLOCK())
		lError := .F.
		::cCodigo := "YOK"
	else
		::cCodigo := "NOK"
		cMens := "Erro ao gravar o IDFLUIG "+cValToChar(::IDFLUIG)
		conout('[' + DToC(Date()) + " " + Time() +  "] " + procname() + "("+cValToChar(procline()) +") > " + cMens+ ". " )
		lError := .T.
	Endif
else
	::cCodigo := "NOK"
	cMens := " IDFLUIG invalido "+cValToChar(::IDFLUIG)
	conout('[' + DToC(Date()) + " " + Time() +  "] " + procname() + "("+cValToChar(procline()) +") > " + cMens+ ". " )
	lError := .T.
Endif

Return !lError
 /*
Local cSerieNF :="1"
Local lError 	:= .T.

if SELECT('SC5') == 0
	DBSELECTAREA( "SC5" )
Endif
SC5->( DbOrderNickName('IDFLUIG'))
if SC5->( DbSeek(xFilial("SC5") + IDFLUIG))
	conout('Faturando o pedido: ' + SC5->C5_NUM)
	cNota := pedToNf(xFilial("SC5"), SC5->C5_NUM, cSerieNF)
	if Empty(cNota)
		::cCodigo := "NOK"		
	Else
		::cCodigo := "YOK"	
	Endif
	ConOut( ::cCodigo )

else
	::cCodigo := "NOK"
	cMens := "Erro ao gravar o Pedido de Venda"
	conout('[' + DToC(Date()) + " " + Time() +  "] " + procname() + " > " + cMens+ ". " )

Endif
Return !lError


{Protheus.doc} Produtos
Retorna os Produtos
@author Anderson José Zelenski
@since 09/12/2020
/*/
WSMETHOD ProdutosEstoque WSRECEIVE cFilBusca,cProd WSSEND aProdutosEstoque WSSERVICE FluigProtheus
	Local oProdutoEstoque
	Local cAlias	:= GetNextAlias()
	Local cQuery	:= ''

	::aProdutosEstoque := WSClassNew("oProdutosEstoque")
	::aProdutosEstoque:Itens := {}
	cQuery := " select 	B1_FILIAL, B1_COD, B1_DESC, B1_UM, B1_PESO, B1_PRV1, B2_QATU - B2_RESERVA as B2_QATU , B5_ALTURA, B5_COMPR, B5_LARG "
	cQuery += "from "+RetSqlName('SB1')+" SB1"
	cQuery += " inner join "+RetSqlName('SB2')+" SB2 on B1_FILIAL = B2_FILIAL and B1_COD = B2_COD"
	cQuery += " inner join "+RetSqlName('SB5')+" SB5 on B1_FILIAL = B5_FILIAL and B1_COD = B5_COD"
	cQuery += "Where 	SB1.D_E_L_E_T_ =' ' and	SB2.D_E_L_E_T_ =' ' and	SB5.D_E_L_E_T_ =' '  and B1_MSBLQL <> '1' and ( B2_QATU - B2_RESERVA )>0"
	If !Empty(::cFilBusca)
		cQuery += " AND B1_FILIAL = '"+::cFilBusca+"' "
	ENDIF
	If !Empty(::cProd)
		cQuery += " AND B1_COD in( "+::cProd+" )"
	ENDIF
	cQuery += " ORDER BY B1_FILIAL, B1_COD "
	Conout("cQuery "+ cQuery)
	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias (cAlias)
	dbSelectArea(cAlias)

	While (cAlias)->(!Eof())

		oProdutoEstoque := WSClassNew("oProdutoEstoque")
		oProdutoEstoque:B1_FILIAL 	:= (cAlias)->B1_FILIAL
		oProdutoEstoque:B1_COD 	    := Alltrim((cAlias)->B1_COD)
		oProdutoEstoque:B1_DESC	    := Alltrim((cAlias)->B1_DESC)		
		oProdutoEstoque:B1_UM		:= (cAlias)->B1_UM		
		oProdutoEstoque:B1_PESO		:= TRANSFORM((cAlias)->B1_PESO, '@E 999,999,999.9999') 
		oProdutoEstoque:B1_PRV1		:= TRANSFORM((cAlias)->B1_PRV1, '@E 999,999,999.99') 
		oProdutoEstoque:B2_QATU		:= TRANSFORM((cAlias)->B2_QATU, '@E 999,999,999.99') 
		oProdutoEstoque:B5_ALTURA	:= TRANSFORM((cAlias)->B5_ALTURA, '@E 999,999,999.99') 
		oProdutoEstoque:B5_COMPR	:= TRANSFORM((cAlias)->B5_COMPR, '@E 999,999,999.99') 
		oProdutoEstoque:B5_LARG		:= TRANSFORM((cAlias)->B5_LARG, '@E 999,999,999.99') 

		aAdd(::aProdutosEstoque:Itens, oProdutoEstoque)
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

Return .T.

WSMETHOD GerarCliPV WSRECEIVE oCliente WSSEND cCodigo WSSERVICE FluigProtheus
	Local lError 	:= .T.
	Local aVetSA1
	Local cCodMun   := ""
	Local aLog
	Local aEmprs
	Local nPosFil := 1
	Local lContinua := .T.
	Local nOpc := 3 // Pre - opçao de inclusao
	Local cFileErr := "/dirdoc/errows_"+procname()+"_"+dtos(date())+"_"+strtran(time(),":","")+".txt"
	private cFilCli  := cFilAnt
	private lAutoErrNoFile := .T.
	private lMsErroAuto := .F.

	Conout("GerarCliPV - Cadastrar Clientes..."+varInfo("oCliente",oCliente, , .f., .f.))


	BEGIN SEQUENCE
		if !empty(ocliente:A1_FILIAL)
			cFilCli := ocliente:A1_FILIAL
			aEmprs:= FWLoadSM0()
			if !empty(nPosFil := ascan(aEmprs, {|it| it[1]=cEmpAnt .and. it[2]=cFilCli}))
				cFilAnt := cFilCli
			endif
		endif
		if empty(nPosFil)
			cError:="Error: Filial "+cFilCli+" nao localizada."
			memowrite(cFileErr, ;
				varInfo("ocliente",ocliente, , .f., .f.) + CRLF + cError )  
		
		elseif !empty(ocliente:A1_CGC )
			Conout("A1_CGC " + ocliente:A1_CGC  )
			DbSelectArea('SA1')
			SA1->(dbSetOrder(3))  // A1_FILIAL+A1_CGC	
			If SA1->(DbSeek(xFilial('SA2')+ocliente:A1_CGC))
				if ocliente:A1_LOJA <>'EE'
					ConOut("Error: cliente com CNPJ "+ocliente:A1_CGC+" ja cadastrado.")
					cError:="Error: cliente com CNPJ "+ocliente:A1_CGC+" ja cadastrado."
					memowrite(cFileErr, ;
						varInfo("oCliente",oCliente, , .f., .f.) + CRLF + cError )  
					lError := .T.
					lContinua := .F.
				else
					// procutar por codigo e loja 
					//A1_FILIAL+A1_COD+A1_LOJA
					cCod := SA1->A1_COD
					cLoja := 'EE'
					aAreaSA1 := SA1->(GetArea())					
					SA1->( DbSetOrder(1))//
					SA1->( DbGotop())
					if !SA1->(dbSeek(xFilial("SA1") + cCod + 'EE'))
						conout("!SA1->(dbSeek(xFilial('SA1') + cCod + 'EE'))    NAO ACHOU"  + cValtoChar(nOpc))
						nOpc :=3 // inclusao de novo registro com código EE
					Else
						nOpc := 4 // Alteração do registro com os dados do Fluig
						conout("!SA1->(dbSeek(xFilial('SA1') + cCod + 'EE'))    ACHOU"  + cValtoChar(nOpc))
					Endif							
					SA1->(RestArea(aAreaSA1))
				Endif
			else
				cCod := GetSXENum("SA1","A1_COD")
				cLoja   := "01" 
			endif
			if len(oCliente:A1_CEP) <> 8			
				cError:="Error: tamanho do CEP "+ocliente:A1_CEP+" nao encontrado."
				memowrite(cFileErr, ;
					varInfo("oCliente",oCliente, , .f., .f.) + CRLF + cError )  
				lError := .T.			
			elseif lContinua
				cCodMun := fCEPIBGE(oCliente:A1_CEP)
				aVetSA1 := {}
				aadd(aVetSA1, {"A1_TIPO"   , 'F'   , Nil})
				aadd(aVetSA1, {"A1_CGC"    , oCliente:A1_CGC    , Nil})
				aadd(aVetSA1, {"A1_EST"    , oCliente:A1_EST    , Nil})
				aadd(aVetSA1, {"A1_INSCR"  , oCliente:A1_INSCR  , Nil})
				aadd(aVetSA1, {"A1_NOME"   , UPPER(oCliente:A1_NOME)   , Nil})
				aadd(aVetSA1, {"A1_NREDUZ" , UPPER(oCliente:A1_NREDUZ) , Nil})
				aadd(aVetSA1, {"A1_END"    , UPPER(oCliente:A1_END)    , Nil})
				aadd(aVetSA1, {"A1_BAIRRO" , UPPER(oCliente:A1_BAIRRO) , Nil})
				aadd(aVetSA1, {"A1_COMPLEM", UPPER(oCliente:A1_COMPLEM), Nil})
				aadd(aVetSA1, {"A1_MUN"    , oCliente:A1_MUN    , Nil})					
				aadd(aVetSA1, {"A1_CEP"    , oCliente:A1_CEP    , Nil})
				aadd(aVetSA1, {"A1_DDD"    , oCliente:A1_DDD    , Nil})
				aadd(aVetSA1, {"A1_TEL"    , oCliente:A1_TEL    , Nil})
				aadd(aVetSA1, {"A1_EMAIL"  , alltrim(oCliente:A1_EMAIL)    , Nil})
				aadd(aVetSA1, {"A1_NATUREZ",     "OUTROS"       , Nil})
				aadd(aVetSA1, {"A1_PESSOA" ,   IIF(LEN(oCliente:A1_CGC)=14,'J','F')      , Nil})

				SA1->(dbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA
				if SA1->(dbSeek(xFilial("SA1")+"XXXXXX", .t.))
					SA1->(dbSkip(-1))
				else
					SA1->(dbSkip(-1))
				endif
				aadd(aVetSA1, {"A1_COD_MUN"    , cCodMun   , Nil})					
				aadd(aVetSA1, {"A1_COD"    , cCod   , Nil})  // Campo automatico				
				aadd(aVetSA1, {"A1_LOJA"   , cLoja   , Nil})					
				//Chama a rotina automática
				lMsErroAuto := .F.
				lAutoErrNoFile := .T.
				MSExecAuto({|x,y| mata030(x,y)}, aVetSA1, nOpc)
				//Se houve erro, mostra o erro ao usuário e desarma a transação
				If lMsErroAuto					
					cError := "Error: "
					aLog  := GetAutoGRLog() 
					aeval(aLog, {|x| cError += x+CRLF})
					memowrite(cFileErr, ;
						varInfo("oCliente",oCliente, , .f., .f.) + CRLF ;
						+ varInfo("aVetSA1",aVetSA1, , .f., .f.) + CRLF ;
                        + cError )  
					ConOut(Procname()+" -> "+cError)
					lError := .T.
					RollBackSX8()
				else
					ConfirmSX8()
					lError := .F.
				EndIf
			EndIf
		else	
			cError:="Error: CPF/CNPJ nao recebido."
			memowrite(cFileErr, ;
			varInfo("oCliente",oCliente, , .f., .f.) + CRLF + cError )  
		endif
	END SEQUENCE
	If lError
		::cCodigo := "NOK"
		cMens := "Erro ao gravar o Cliente"
		conout('[' + DToC(Date()) + " " + Time() +  "] " + procname() + " > " + cMens+ ". " + 'cError')
		SetSoapFault("Erro", cError)
	else
		::cCodigo := cCod +',' + cLoja
	EndIf
Return !lError


WSMETHOD AtualizarTitulos WSRECEIVE oTitulo WSSEND cCodigo WSSERVICE FluigProtheus
Local lError 	:= .T.
Local cMens     := ""
Local cError    := ""
Local cFileErr  := "/dirdoc/errows_"+procname()+"_"+dtos(date())+"_"+strtran(time(),":","")+".txt"
Local cAlias	:= GetNextAlias()
Local cQuery	:= ''
LOCAL aSE1      := {}
Local nCont
PRIVATE lMsErroAuto := .F.
Conout("AtualizarTitulos - "+varInfo("oTitulo",oTitulo, , .f., .f.))

cQuery := " SELECT E1_FILIAL, E1_PREFIXO , E1_NUM , E1_PARCELA , E1_TIPO ,  E1_VALOR"
cQuery += " FROM "+RetSqlName('SE1')+" SE1"
cQuery += " WHERE SubString( E1_VENCREA, 1,6) = '" + oTitulo:AnoMes+"'"
cQuery += " 	AND E1_SALDO <> 0 "
cQuery += " 	AND E1_XPROCES ='"+ oTitulo:Processo+"'  "
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY E1_FILIAL, E1_NUM "

conout(cQuery)
cQuery := ChangeQuery(cQuery)
TcQuery cQuery New Alias (cAlias)
dbSelectArea(cAlias)

While (cAlias)->(!Eof())

	aArray := {(cAlias)->E1_FILIAL ,;// CAMPO POSICIONADO
           (cAlias)->E1_PREFIXO     ,;
           (cAlias)->E1_NUM         ,;
           (cAlias)->E1_PARCELA     ,;
           (cAlias)->E1_TIPO        ,;
           (cAlias)->E1_VALOR       } // campo que vai ser alterado

	AADD( aSE1, aArray )
	(cAlias)->(dbSkip())
EndDo

if len(aSE1) <> 0
		// Posiciona no Pedido de Compras
	SE1->(DbSetOrder(1))
	//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA                                                                                               
	SE1->(DbGotop())
	for nCont :=1 to len (aSE1)
		conout(varInfo("aSE2",aSE1, , .f., .f.))
		cChave := aSE1[nCont,1]+aSE1[nCont,2]+aSE1[nCont,3] +aSE1[nCont,4]+aSE1[nCont,5]
		if SE1->( DbSeek( cChave  ))
			conout("Achou "+ cChave)
			BEGIN TRANSACTION
			nValorOri := SE1->E1_VALOR
			RecLock("SE1", .F.)
				SE1->E1_VALOR := SE1->E1_VALOR * oTitulo:Taxa
			SE1->(MsUnlock())

			// Gravar Histórico de Alteração de títulos
			RecLock("ZAR", .T.)
				ZAR_FILIAL := SE1->E1_FILIAL
				ZAR_ANOMES := oTitulo:AnoMes
				ZAR_TITULO := SE1->E1_NUM
				ZAR_IDFLUI := SE1->E1_IDFLUIG
				ZAR_CLIENT := SE1->E1_CLIENTE
				ZAR_LOJA   := SE1->E1_LOJA
				ZAR_NOMECL := SE1->E1_NOMCLI
				ZAR_VLRORI := nValorOri
				ZAR_VLRATU := SE1->E1_VALOR
				ZAR_TAXA   :=  (oTitulo:Taxa - 1) * 100
			ZAR->(MsUnlock())

			END TRANSACTION
			aTit :={}
			aadd(aTit, SE1->E1_NUM)

		else
			conout("Nao Achou "+ cChave)
		endif
	Next nCont
	u_PVAUTOBOL()

	SE1->(DbSeek(xFilial("SC7")+AllTrim(SCR->CR_NUM)))
Endif
(cAlias)->(dbCloseArea())
If lError
	::cCodigo := "NOK"
	cMens := "Erro ao atualizar o Titulo"
	conout('[' + DToC(Date()) + " " + Time() + "] " + procname() + " > " + cMens + ". " + cError)
	SetSoapFault("Erro", cError)
else
	::cCodigo := "YOK"
EndIf
Return !lError

/*
+----------------------------------------------------------------------------------+
! Função    ! fCEPIBGE     ! Autor ! Pedro A. de Souza        ! Data !  10/10/2022 !
+-----------+--------------+-------+--------------------------+------+-------------+
! Parâmetros! cCEP                                                                 !
+-----------+----------------------------------------------------------------------+
! Retorno   ! N/A                                                                  !
+-----------+----------------------------------------------------------------------+
! Descricao ! Retorna o codigo IBGE de um CEP                                      !
+-----------+----------------------------------------------------------------------+
*/
static function fCEPIBGE(cCEP)
	Local cUrl              := "http://viacep.com.br/ws/"
	Local cGetParams        := ""
	Local nTimeOut          := 200
	Local aHeadStr          := {"Content-Type: application/json"}
	Local cHeaderGet        := ""
	Local cRetWs            := ""
	Local oJsonCEP          := Nil
	Local cParsePJ          := ""
	Local cStrResul         := ""

	cUrl += cCEP+"/json/"
    cRetWs  := HttpGet(cUrl, cGetParams, nTimeOut, aHeadStr, @cHeaderGet)
	oJsonCEP:= JsonObject():New()
	cParsePJ := oJsonCEP:FromJson(cValToChar(cRetWs))
	if ValType(cParsePJ) <> "C" .and. valtype(oJsonCEP["ibge"]) = "C"
		cStrResul := substr(oJsonCEP["ibge"], 3)
	endif
return cStrResul



WSMETHOD OperarMultiCotas WSRECEIVE oMultiCotas WSSEND cCodigo WSSERVICE FluigProtheus
	Local lError 	:= .f.
	Local cMens     := ""
	Local cError    := ""
	Local lInclui   := .f.
	Local cIdentif
	local oObjLog   := LogSMS():new()

	oObjLog:setFileName("\temp\MC_"+dtos(date())+".txt")
	oObjLog:saveMsg("================")
	oObjLog:saveMsg(varinfo("oMultiCotas", oMultiCotas, , .f., .f. ))
	if empty(oMultiCotas:Z11_TIPOPE) 
		lError := .t.
		oObjLog:saveMsg("Requisicao sem operacao.")
	elseif !chkCamp(oMultiCotas, oObjLog)
		lError := .t.
		oObjLog:saveMsg("Esta faltando algum campo na requisicao.")
	elseif lower(oMultiCotas:Z11_TIPOPE) = "compra"
		// TODO checar se os campos necessarios estao preenchidos
		// Inserir/Atualizar (dbseek)
		cIdentif := oMultiCotas:Z11_DOCTIT
		cIdentif := strtran(strtran(strtran(cIdentif, "/", ""),".",""),"-","")
		oObjLog:saveMsg("Compra.")
		lInclui := !Z11->(dbSeek(xFilial("Z11")+oMultiCotas:Z11_IDCOTA))
		RecLock("Z11", lInclui)
		Z11->Z11_FILIAL  := xFilial("Z11")
		Z11->Z11_IDCOTA  := oMultiCotas:Z11_IDCOTA
		Z11->Z11_GRUPO   := oMultiCotas:Z11_GRUPO
		Z11->Z11_COTA    := oMultiCotas:Z11_COTA
		Z11->Z11_VERSAO  := oMultiCotas:Z11_VERSAO
		Z11->Z11_TIPOPE  := oMultiCotas:Z11_TIPOPE
		Z11->Z11_DOCTIT  := cIdentif
		Z11->Z11_NOMTIT  := oMultiCotas:Z11_NOMTIT
		if valtype(oMultiCotas:Z11_VALCRE) = "N"
			Z11->Z11_VALCRE  := oMultiCotas:Z11_VALCRE
		endif
		if valtype(oMultiCotas:Z11_VALFUN) = "N"
			Z11->Z11_VALFUN  := oMultiCotas:Z11_VALFUN
		endif
		if valtype(oMultiCotas:Z11_NUMPAR) = "N"
			Z11->Z11_NUMPAR  := oMultiCotas:Z11_NUMPAR
		endif
		if valtype(oMultiCotas:Z11_PRZGRP) = "N"
			Z11->Z11_PRZGRP  := oMultiCotas:Z11_PRZGRP
		endif
		if valtype(oMultiCotas:Z11_DTINGP) = "C"
			Z11->Z11_DTINGP  := ctod(oMultiCotas:Z11_DTINGP)
		endif
		if valtype(oMultiCotas:Z11_DTAQUI) = "C"
			Z11->Z11_DTAQUI  := ctod(oMultiCotas:Z11_DTAQUI)
		endif
		// Z11->Z11_DTCANC  := oMultiCotas:Z11_DTCANC
		if valtype(oMultiCotas:Z11_VLVNDC) = "N"
			Z11->Z11_VLVNDC  := oMultiCotas:Z11_VLVNDC
		endif
		if valtype(oMultiCotas:Z11_IDPROC) = "C"
			Z11->Z11_IDPROC  := oMultiCotas:Z11_IDPROC
		endif
		if valtype(oMultiCotas:Z11_VBRCOM) = "N"
			Z11->Z11_VBRCOM  := oMultiCotas:Z11_VBRCOM
		endif
		if valtype(oMultiCotas:Z11_VLICOM) = "N"
			Z11->Z11_VLICOM  := oMultiCotas:Z11_VLICOM
		endif
		if valtype(oMultiCotas:Z11_VCCCAU) = "N"
			Z11->Z11_VCCCAU  := oMultiCotas:Z11_VCCCAU
		endif
		if valtype(oMultiCotas:Z11_VCCCGE) = "N"
			Z11->Z11_VCCCGE  := oMultiCotas:Z11_VCCCGE
		endif
		if valtype(oMultiCotas:Z11_VCCCLI) = "N"
			Z11->Z11_VCCCLI  := oMultiCotas:Z11_VCCCLI
		endif
		if valtype(oMultiCotas:Z11_VCCCRE) = "N"
			Z11->Z11_VCCCRE  := oMultiCotas:Z11_VCCCRE
		endif
		if valtype(oMultiCotas:Z11_IDCCAU) = "C"
			Z11->Z11_IDCCAU  := oMultiCotas:Z11_IDCCAU
		endif
		if valtype(oMultiCotas:Z11_IDCCGE) = "C"
			Z11->Z11_IDCCGE  := oMultiCotas:Z11_IDCCGE
		endif
		if valtype(oMultiCotas:Z11_IDCCLI) = "C"
			Z11->Z11_IDCCLI  := oMultiCotas:Z11_IDCCLI
		endif
		if valtype(oMultiCotas:Z11_IDCCRE) = "C"
			Z11->Z11_IDCCRE  := oMultiCotas:Z11_IDCCRE
		endif
		if valtype(oMultiCotas:Z11_DTCOMP) = "C"
			Z11->Z11_DTCOMP  := ctod(oMultiCotas:Z11_DTCOMP)
		endif
		// if valtype(oMultiCotas:Z11_STCOMP) = "C"
		// 	Z11->Z11_STCOMP  := oMultiCotas:Z11_STCOMP
		// endif
		if valtype(oMultiCotas:Z11_DTVCCO) = "C"
			Z11->Z11_DTVCCO  := ctod(oMultiCotas:Z11_DTVCCO)
		endif
		if valtype(oMultiCotas:Z11_DTVCCM) = "C"
			Z11->Z11_DTVCCM  := ctod(oMultiCotas:Z11_DTVCCM)
		endif
		if !empty(Z11->(fieldPos("Z11_PV"))) .and. valtype(oMultiCotas:Z11_PV) = "C"
			Z11->Z11_PV  := oMultiCotas:Z11_PV
		endif
		if !empty(Z11->(fieldPos("Z11_PRZC"))) .and. valtype(oMultiCotas:Z11_PRZC) = "N"
			Z11->Z11_PRZC  := oMultiCotas:Z11_PRZC
		endif
		if valtype(oMultiCotas:Z11_ATRAS) = "N"
			Z11->Z11_ATRAS  := oMultiCotas:Z11_ATRAS
		endif
		Z11->Z11_VADPRZ := 0.00
		if valtype(oMultiCotas:Z11_VADPRZ) = "N"
			Z11->Z11_VADPRZ  := oMultiCotas:Z11_VADPRZ
		endif
		Z11->Z11_VCPCAU := 0.00
		Z11->Z11_VCPCGE := 0.00
		Z11->Z11_VCPCLI := 0.00
		Z11->Z11_VCPCRE := 0.00
		if valtype(oMultiCotas:Z11_VCPCAU) = "N"
			Z11->Z11_VCPCAU  := oMultiCotas:Z11_VCPCAU
		endif
		if valtype(oMultiCotas:Z11_VCPCGE) = "N"
			Z11->Z11_VCPCGE  := oMultiCotas:Z11_VCPCGE
		endif
		if valtype(oMultiCotas:Z11_VCPCLI) = "N"
			Z11->Z11_VCPCLI  := oMultiCotas:Z11_VCPCLI
		endif
		if valtype(oMultiCotas:Z11_VCPCRE) = "N"
			Z11->Z11_VCPCRE  := oMultiCotas:Z11_VCPCRE
		endif
		Z11->Z11_STCOMP := "00" // Status inicial de compra
		if (lInclui)
			Z11->Z11_JSONHI := dtos(date())+" - "+time()+" inclusao inicial compra."+CRLF
		else
			Z11->Z11_JSONHI := Z11->Z11_JSONHI+dtos(date())+" - "+time()+" atualizacao compra."+CRLF 
		endif
		Z11->(MsUnlock())
		// TODO geracao do contas a pagar e comissoes..
		conout("gerando Start Job - U_adMCcom")
		startJob("U_adMCcom", GetEnvServer(), .F., {cEmpAnt, "070101", Z11->(recno())})
	elseif lower(oMultiCotas:Z11_TIPOPE) = "autols"
		// TODO checar se os campos necessarios estao preenchidos
		// Inserir/Atualizar (dbseek)
		cIdentif := oMultiCotas:Z11_DOCTIT
		cIdentif := strtran(strtran(strtran(cIdentif, "/", ""),".",""),"-","")
		oObjLog:saveMsg("autols.")
		lInclui := !Z11->(dbSeek(xFilial("Z11")+oMultiCotas:Z11_IDCOTA))
		RecLock("Z11", lInclui)
		Z11->Z11_FILIAL  := xFilial("Z11")
		Z11->Z11_IDCOTA  := oMultiCotas:Z11_IDCOTA
		Z11->Z11_GRUPO   := oMultiCotas:Z11_GRUPO
		Z11->Z11_COTA    := oMultiCotas:Z11_COTA
		Z11->Z11_VERSAO  := oMultiCotas:Z11_VERSAO
		Z11->Z11_TIPOPE  := oMultiCotas:Z11_TIPOPE
		Z11->Z11_DOCTIT  := cIdentif
		Z11->Z11_NOMTIT  := oMultiCotas:Z11_NOMTIT
		if valtype(oMultiCotas:Z11_IDPROC) = "C"
			Z11->Z11_IDPROC  := oMultiCotas:Z11_IDPROC
		endif
		if valtype(oMultiCotas:Z11_TXLEIS) = "N"
			Z11->Z11_TXLEIS  := oMultiCotas:Z11_TXLEIS
		endif
		if !empty(Z11->(fieldPos("Z11_PV"))) .and. valtype(oMultiCotas:Z11_PV) = "C"
			Z11->Z11_PV  := oMultiCotas:Z11_PV
		endif
		if (lInclui)
			Z11->Z11_JSONHI := dtos(date())+" - "+time()+" inclusao inicial autorizacao ls."+CRLF
		else
			Z11->Z11_JSONHI := Z11->Z11_JSONHI+dtos(date())+" - "+time()+" autorizacao ls."+CRLF 
		endif
		Z11->(MsUnlock())
		// TODO contabilizar a autorizacao de comercializacao LS
		startJob("U_adMClei", GetEnvServer(), .F., {cEmpAnt, "070101", Z11->(recno())})
	elseif lower(oMultiCotas:Z11_TIPOPE) = "vendabc"
		// TODO checar se os campos necessarios estao preenchidos
		oObjLog:saveMsg("vendabc.")
		cIdentif := oMultiCotas:Z11_DOCDES
		cIdentif := strtran(strtran(strtran(cIdentif, "/", ""),".",""),"-","")
		if !Z11->(dbSeek(xFilial("Z11")+oMultiCotas:Z11_IDCOTA))
			lError := .t.
			oObjLog:saveMsg("Cota "+oMultiCotas:Z11_IDCOTA+" para vendabc nao encontrada.")
		else
			RecLock("Z11", .f.)
			Z11->Z11_TIPOPE  := oMultiCotas:Z11_TIPOPE
			Z11->Z11_DOCDES  := cIdentif

			Z11->Z11_VBRVEN  := oMultiCotas:Z11_VBRVEN
			Z11->Z11_VLIVEN  := oMultiCotas:Z11_VLIVEN
			Z11->Z11_DTVEND  := ctod(oMultiCotas:Z11_DTVEND)
			if !empty(Z11->(fieldPos("Z11_IDPROV"))) .and. valtype(oMultiCotas:Z11_IDPROC) = "C"
				Z11->Z11_IDPROV  := oMultiCotas:Z11_IDPROC
			endif

			if valtype(oMultiCotas:Z11_VCVCAU) = "N"
				Z11->Z11_VCVCAU  := oMultiCotas:Z11_VCVCAU
			endif
			if valtype(oMultiCotas:Z11_VCVCGE) = "N"
				Z11->Z11_VCVCGE  := oMultiCotas:Z11_VCVCGE
			endif
			if valtype(oMultiCotas:Z11_VCVCLI) = "N"
				Z11->Z11_VCVCLI  := oMultiCotas:Z11_VCVCLI
			endif
			if valtype(oMultiCotas:Z11_VCVCRE) = "N"
				Z11->Z11_VCVCRE  := oMultiCotas:Z11_VCVCRE
			endif
			if valtype(oMultiCotas:Z11_IDVCAU) = "C"
				Z11->Z11_IDVCAU  := oMultiCotas:Z11_IDVCAU
			endif
			if valtype(oMultiCotas:Z11_IDVCGE) = "C"
				Z11->Z11_IDVCGE  := oMultiCotas:Z11_IDVCGE
			endif
			if valtype(oMultiCotas:Z11_IDVCLI) = "C"
				Z11->Z11_IDVCLI  := oMultiCotas:Z11_IDVCLI
			endif
			if valtype(oMultiCotas:Z11_IDVCRE) = "C"
				Z11->Z11_IDVCRE  := oMultiCotas:Z11_IDVCRE
			endif
			if !empty(Z11->(fieldPos("Z11_PVVEN"))) .and. valtype(oMultiCotas:Z11_PV) = "C"
				Z11->Z11_PVVEN  := oMultiCotas:Z11_PV
			endif
			// Z11->Z11_VCPVAU := 0.00
			// Z11->Z11_VCPVGE := 0.00
			// Z11->Z11_VCPVLI := 0.00
			// Z11->Z11_VCPVRE := 0.00
			if valtype(oMultiCotas:Z11_VCPVAU) = "N"
				Z11->Z11_VCPVAU  := oMultiCotas:Z11_VCPVAU
			endif
			if valtype(oMultiCotas:Z11_VCPVGE) = "N"
				Z11->Z11_VCPVGE  := oMultiCotas:Z11_VCPVGE
			endif
			if valtype(oMultiCotas:Z11_VCPVLI) = "N"
				Z11->Z11_VCPVLI  := oMultiCotas:Z11_VCPVLI
			endif
			if valtype(oMultiCotas:Z11_VCPVRE) = "N"
				Z11->Z11_VCPVRE  := oMultiCotas:Z11_VCPVRE
			endif
			Z11->Z11_STVEND := "00" // Status inicial de venda
			Z11->Z11_JSONHI := Z11->Z11_JSONHI+dtos(date())+" - "+time()+" vendabc."+CRLF 
			Z11->(MsUnlock())
			// TODO gerar titulo a receber
			startJob("U_adMCven", GetEnvServer(), .F., {cEmpAnt, "070101", Z11->(recno())})
		endif
	elseif lower(oMultiCotas:Z11_TIPOPE) = "vendalp"
		// TODO checar se os campos necessarios estao preenchidos
		oObjLog:saveMsg("vendalp.")
		cIdentif := oMultiCotas:Z11_DOCDES
		cIdentif := strtran(strtran(strtran(cIdentif, "/", ""),".",""),"-","")
		if !Z11->(dbSeek(xFilial("Z11")+oMultiCotas:Z11_IDCOTA))
			lError := .t.
			oObjLog:saveMsg("Cota "+oMultiCotas:Z11_IDCOTA+" para vendalp nao encontrada.")
		else
			RecLock("Z11", .f.)
			Z11->Z11_TIPOPE  := oMultiCotas:Z11_TIPOPE
			Z11->Z11_DOCDES  := cIdentif

			Z11->Z11_VBRVEN  := oMultiCotas:Z11_VBRVEN
			Z11->Z11_VLIVEN  := oMultiCotas:Z11_VLIVEN
			Z11->Z11_DTVEND   := ctod(oMultiCotas:Z11_DTVEND)
			if !empty(Z11->(fieldPos("Z11_IDPROV"))) .and. valtype(oMultiCotas:Z11_IDPROC) = "C"
				Z11->Z11_IDPROV  := oMultiCotas:Z11_IDPROC
			endif

			if valtype(oMultiCotas:Z11_VCVCAU) = "N"
				Z11->Z11_VCVCAU  := oMultiCotas:Z11_VCVCAU
			endif
			if valtype(oMultiCotas:Z11_VCVCGE) = "N"
				Z11->Z11_VCVCGE  := oMultiCotas:Z11_VCVCGE
			endif
			if valtype(oMultiCotas:Z11_VCVCLI) = "N"
				Z11->Z11_VCVCLI  := oMultiCotas:Z11_VCVCLI
			endif
			if valtype(oMultiCotas:Z11_VCVCRE) = "N"
				Z11->Z11_VCVCRE  := oMultiCotas:Z11_VCVCRE
			endif
			if valtype(oMultiCotas:Z11_IDVCAU) = "C"
				Z11->Z11_IDVCAU  := oMultiCotas:Z11_IDVCAU
			endif
			if valtype(oMultiCotas:Z11_IDVCGE) = "C"
				Z11->Z11_IDVCGE  := oMultiCotas:Z11_IDVCGE
			endif
			if valtype(oMultiCotas:Z11_IDVCLI) = "C"
				Z11->Z11_IDVCLI  := oMultiCotas:Z11_IDVCLI
			endif
			if valtype(oMultiCotas:Z11_IDVCRE) = "C"
				Z11->Z11_IDVCRE  := oMultiCotas:Z11_IDVCRE
			endif
			if !empty(Z11->(fieldPos("Z11_PVVEN"))) .and. valtype(oMultiCotas:Z11_PV) = "C"
				Z11->Z11_PVVEN  := oMultiCotas:Z11_PV
			endif
			// Z11->Z11_VCPVAU := 0.00
			// Z11->Z11_VCPVGE := 0.00
			// Z11->Z11_VCPVLI := 0.00
			// Z11->Z11_VCPVRE := 0.00
			if valtype(oMultiCotas:Z11_VCPVAU) = "N"
				Z11->Z11_VCPVAU  := oMultiCotas:Z11_VCPVAU
			endif
			if valtype(oMultiCotas:Z11_VCPVGE) = "N"
				Z11->Z11_VCPVGE  := oMultiCotas:Z11_VCPVGE
			endif
			if valtype(oMultiCotas:Z11_VCPVLI) = "N"
				Z11->Z11_VCPVLI  := oMultiCotas:Z11_VCPVLI
			endif
			if valtype(oMultiCotas:Z11_VCPVRE) = "N"
				Z11->Z11_VCPVRE  := oMultiCotas:Z11_VCPVRE
			endif
			Z11->Z11_STVEND := "00" // Status inicial de venda
			Z11->Z11_JSONHI := Z11->Z11_JSONHI+dtos(date())+" - "+time()+" vendalp."+CRLF 
			Z11->(MsUnlock())
			// TODO gerar titulo a receber
			startJob("U_adMCven", GetEnvServer(), .F., {cEmpAnt, "070101", Z11->(recno())})
		endif
	elseif lower(oMultiCotas:Z11_TIPOPE) = "vendals"
		// TODO checar se os campos necessarios estao preenchidos
		oObjLog:saveMsg("vendals.")
		cIdentif := oMultiCotas:Z11_DOCDES
		cIdentif := strtran(strtran(strtran(cIdentif, "/", ""),".",""),"-","")
		if !Z11->(dbSeek(xFilial("Z11")+oMultiCotas:Z11_IDCOTA))
			lError := .t.
			oObjLog:saveMsg("Cota "+oMultiCotas:Z11_IDCOTA+" para vendals nao encontrada.")
		else
			RecLock("Z11", .f.)
			Z11->Z11_TIPOPE  := oMultiCotas:Z11_TIPOPE
			Z11->Z11_DOCDES  := cIdentif

			Z11->Z11_VBRVEN  := oMultiCotas:Z11_VBRVEN
			Z11->Z11_VLIVEN  := oMultiCotas:Z11_VLIVEN
			Z11->Z11_DTVEND   := ctod(oMultiCotas:Z11_DTVEND)
			if !empty(Z11->(fieldPos("Z11_IDPROV"))) .and. valtype(oMultiCotas:Z11_IDPROC) = "C"
				Z11->Z11_IDPROV  := oMultiCotas:Z11_IDPROC
			endif

			if valtype(oMultiCotas:Z11_VCVCAU) = "N"
				Z11->Z11_VCVCAU  := oMultiCotas:Z11_VCVCAU
			endif
			if valtype(oMultiCotas:Z11_VCVCGE) = "N"
				Z11->Z11_VCVCGE  := oMultiCotas:Z11_VCVCGE
			endif
			if valtype(oMultiCotas:Z11_VCVCLI) = "N"
				Z11->Z11_VCVCLI  := oMultiCotas:Z11_VCVCLI
			endif
			if valtype(oMultiCotas:Z11_VCVCRE) = "N"
				Z11->Z11_VCVCRE  := oMultiCotas:Z11_VCVCRE
			endif
			if valtype(oMultiCotas:Z11_IDVCAU) = "C"
				Z11->Z11_IDVCAU  := oMultiCotas:Z11_IDVCAU
			endif
			if valtype(oMultiCotas:Z11_IDVCGE) = "C"
				Z11->Z11_IDVCGE  := oMultiCotas:Z11_IDVCGE
			endif
			if valtype(oMultiCotas:Z11_IDVCLI) = "C"
				Z11->Z11_IDVCLI  := oMultiCotas:Z11_IDVCLI
			endif
			if valtype(oMultiCotas:Z11_IDVCRE) = "C"
				Z11->Z11_IDVCRE  := oMultiCotas:Z11_IDVCRE
			endif
			if !empty(Z11->(fieldPos("Z11_PVVEN"))) .and. valtype(oMultiCotas:Z11_PV) = "C"
				Z11->Z11_PVVEN  := oMultiCotas:Z11_PV
			endif
			if valtype(oMultiCotas:Z11_ATRAS) = "N"
				Z11->Z11_ATRAS  := oMultiCotas:Z11_ATRAS
			endif
			if valtype(oMultiCotas:Z11_VALTXU) = "N"
				Z11->Z11_VALTXU  := oMultiCotas:Z11_VALTXU
			endif
			// Z11->Z11_VCPCAU := 0.00
			// Z11->Z11_VCPCGE := 0.00
			// Z11->Z11_VCPCLI := 0.00
			// Z11->Z11_VCPCRE := 0.00
			if valtype(oMultiCotas:Z11_VCPCAU) = "N"
				Z11->Z11_VCPCAU  := oMultiCotas:Z11_VCPCAU
			endif
			if valtype(oMultiCotas:Z11_VCPCGE) = "N"
				Z11->Z11_VCPCGE  := oMultiCotas:Z11_VCPCGE
			endif
			if valtype(oMultiCotas:Z11_VCPCLI) = "N"
				Z11->Z11_VCPCLI  := oMultiCotas:Z11_VCPCLI
			endif
			if valtype(oMultiCotas:Z11_VCPCRE) = "N"
				Z11->Z11_VCPCRE  := oMultiCotas:Z11_VCPCRE
			endif
			// Z11->Z11_VCPVAU := 0.00
			// Z11->Z11_VCPVGE := 0.00
			// Z11->Z11_VCPVLI := 0.00
			// Z11->Z11_VCPVRE := 0.00
			if valtype(oMultiCotas:Z11_VCPVAU) = "N"
				Z11->Z11_VCPVAU  := oMultiCotas:Z11_VCPVAU
			endif
			if valtype(oMultiCotas:Z11_VCPVGE) = "N"
				Z11->Z11_VCPVGE  := oMultiCotas:Z11_VCPVGE
			endif
			if valtype(oMultiCotas:Z11_VCPVLI) = "N"
				Z11->Z11_VCPVLI  := oMultiCotas:Z11_VCPVLI
			endif
			if valtype(oMultiCotas:Z11_VCPVRE) = "N"
				Z11->Z11_VCPVRE  := oMultiCotas:Z11_VCPVRE
			endif
			Z11->Z11_STVEND := "00" // Status inicial de venda
			Z11->Z11_JSONHI := Z11->Z11_JSONHI+dtos(date())+" - "+time()+" vendals."+CRLF 
			Z11->(MsUnlock())
			// TODO gerar titulo a receber
			startJob("U_adMCven", GetEnvServer(), .F., {cEmpAnt, "070101", Z11->(recno())})
		endif
	else
		lError := .t.
		oObjLog:saveMsg("Cota "+oMultiCotas:Z11_IDCOTA+" sem operacao.")
	endif

	If lError
		::cCodigo := "NOK"
		cMens := "Erro ao atualizar o MultiCotas"
		conout('[' + DToC(Date()) + " " + Time() + "] " + procname() + " > " + cMens + ". " + cError)
		oObjLog:saveMsg("Resp "+::cCodigo+". "+cMens)
		SetSoapFault("Erro", cMens)
	else
		::cCodigo := "YOK"
		oObjLog:saveMsg("Resp "+::cCodigo)
	EndIf
Return !lError


/*/{Protheus.doc} chkCamp
Verificar se todos os campos necessarios vieram no webservice de estoque MultiCotas
@type function
@version 1.0
@author Pedro
@since 21/10/2023
@param oMultiCotas, object, objeto do webservice MultiCotas
@param oObjLog, object, objeto de log 
@return logical, .t. se todos os campos obrigatorios ok, .f. cc
/*/
static function chkCamp(oMultiCotas, oObjLog)
	local lRet := .t. as logical
	local nInd as numeric
	local nPos as numeric
	local aCamCheck as array
	local aPropObj as array
	local cCampo as character

	if lower(oMultiCotas:Z11_TIPOPE) = "compra"
		aCamCheck := {"Z11_IDCOTA","Z11_GRUPO","Z11_COTA","Z11_VERSAO","Z11_DOCTIT","Z11_NOMTIT",;
					"Z11_VALCRE","Z11_VALFUN","Z11_DTAQUI","Z11_IDPROC","Z11_VBRCOM",;
					"Z11_VLICOM","Z11_DTCOMP","Z11_DTVCCO","Z11_PV"}
	elseif lower(oMultiCotas:Z11_TIPOPE) = "autols"
		aCamCheck := {"Z11_IDCOTA","Z11_GRUPO","Z11_COTA","Z11_VERSAO","Z11_DOCTIT","Z11_NOMTIT",;
					"Z11_VALCRE","Z11_VALFUN","Z11_DTAQUI","Z11_IDPROC","Z11_TXLEIS",;
					"Z11_PV"}
	elseif lower(oMultiCotas:Z11_TIPOPE) = "vendabc" ;
			.or. lower(oMultiCotas:Z11_TIPOPE) = "vendalp" ;
			.or. lower(oMultiCotas:Z11_TIPOPE) = "vendals"
		aCamCheck := {"Z11_IDCOTA","Z11_DOCDES","Z11_VBRVEN",;
					"Z11_VLIVEN","Z11_DTVEND","Z11_IDPROC","Z11_PV"}
	endif

	aPropObj := ClassDataArr(oMultiCotas)
	//O vetor multi-dimensional aData retornado possui o seguinte formato:
	// [n][1] Nome da propriedade (Caractere)
	// [n][2] Conteúdo da propriedade ( Qualquer )
	// [n][3] Número ID da propriedade (*)
	// [n][4] Nome da classe de referência (**)

	for nInd := 1 to len(aCamCheck)
		cCampo := trim(upper(aCamCheck[nInd]))
		if empty(nPos := ascan(aPropObj, {|x| alltrim(upper(x[1])) == cCampo} ))
			lRet := .f.
			oObjLog:saveMsg("ParamWS, operacao "+oMultiCotas:Z11_TIPOPE+": falta o campo "+cCampo)
		else
			if empty(aPropObj[nPos, 2])
				lRet := .f.
				oObjLog:saveMsg("ParamWS, operacao "+oMultiCotas:Z11_TIPOPE+": campo "+cCampo+" vazio.")
			endif
		endif
	next
return lRet


/*/{Protheus.doc} GerarFornecedor
Gera a inclusão de fornecedor no Protheus
@author Alessandro Gois
@since 24/07/2023
/*/
WSMETHOD GerarFornecedor WSRECEIVE oIncForn WSSEND cCodigo WSSERVICE FluigProtheus
	Local lError 	:= .F.
	Local cCodMun   := ""
	local cPais     := "105"
	local cCodPais  := "01058"
	local cCCusto   := GetMv("AD_MCCCCO",,"")
	local cContaCont:= GetMv("AD_MCC1CO",,"")
	local cCEP
	local aErro
	local cMsgErro
    local cA2_NOME := oIncForn:A2_NOME
    local cA2_NREDUZ := oIncForn:A2_NREDUZ
    local cA2_END := oIncForn:A2_END
    local cA2_NR_END := oIncForn:A2_NR_END
    local cA2_BAIRRO := oIncForn:A2_BAIRRO
    local cA2_MUN := oIncForn:A2_MUN
	local cA2_INSCR := oIncForn:A2_INSCR
	local cA2_XTIPCON := oIncForn:A2_XTIPCON
	local cA2_EST := oIncForn:A2_EST
	local cFilOrig := cFilAnt
	local oObjLog   := LogSMS():new()
	private INCLUI := .t.
	private ALTERA := .f.

	oObjLog:setFileName("\temp\"+procname()+"_"+dtos(date())+".txt")
	oObjLog:saveMsg("================")
	oObjLog:saveMsg(varinfo("oIncForn", oIncForn, , .f., .f. ))

	conout("Gera Fornecedor")
	cFilAnt := "070101"
	FWSM0Util():setSM0PositionBycFilAnt()
	cCCusto   := GetMv("AD_MCCCCO",,"")
	cContaCont:= GetMv("AD_MCC1CO",,"")

    cA2_NOME	:= alltrim(left(cA2_NOME, GetSX3Cache("A2_NOME", "X3_TAMANHO")))
    cA2_NREDUZ	:= alltrim(left(cA2_NREDUZ, GetSX3Cache("A2_NREDUZ", "X3_TAMANHO")))
    cA2_END		:= alltrim(left(cA2_END, GetSX3Cache("A2_END", "X3_TAMANHO")))
    cA2_NR_END	:= alltrim(left(cA2_NR_END, GetSX3Cache("A2_NR_END", "X3_TAMANHO")))
    cA2_BAIRRO	:= alltrim(left(cA2_BAIRRO, GetSX3Cache("A2_BAIRRO", "X3_TAMANHO")))
    cA2_MUN		:= alltrim(left(cA2_MUN, GetSX3Cache("A2_MUN", "X3_TAMANHO")))

	//Pegando o modelo de dados, setando a operação de inclusão
	oModel := FWLoadModel("MATA020M")

	dbselectarea('SA2')
	SA2->(dbsetorder(3))  // A2_FILIAL+A2_CGC
	if !SA2->(dbseek(fwxfilial('SA2')+alltrim(oIncForn:A2_CGC)))

		oModel:SetOperation(3)
	else
		ALTERA := .t.
		INCLUI := .f.		
		oModel:SetOperation(4)
	endif

	oModel:Activate()

	//Pegando o model dos campos da SA2
	oSA2Mod:= oModel:getModel("SA2MASTER")
	oSA2Mod:setValue("A2_TIPO"		,	alltrim(oIncForn:A2_TIPO		)) 
	if inclui
		oSA2Mod:setValue("A2_CGC"		,	alltrim(oIncForn:A2_CGC			)) 
		oSA2Mod:setValue("A2_LOJA"		,	alltrim(oIncForn:A2_LOJA		)) 
	endif
	oSA2Mod:setValue("A2_NOME"		,	cA2_NOME )
	oSA2Mod:setValue("A2_NREDUZ"	,	cA2_NREDUZ)
	oSA2Mod:setValue("A2_END"		,	cA2_END )
	oSA2Mod:setValue("A2_NR_END"	,	cA2_NR_END)
	oSA2Mod:setValue("A2_BAIRRO"	,	cA2_BAIRRO)
	oSA2Mod:setValue("A2_MUN"		,	cA2_MUN )
	oSA2Mod:setValue("A2_EST"		,	alltrim(cA2_EST)) 
	cCodMun := oIncForn:A2_COD_MUN
	cCEP := oIncForn:A2_CEP
	cCEP := strtran(strtran(cCEP,".",""),"-","")

	if empty(cCodMun)
		cCodMun := fCEPIBGE(cCEP)
	endif
	if !empty(oIncForn:A2_PAIS)
		cPais := oIncForn:A2_PAIS
	endif
	if !empty(oIncForn:A2_XCCD)
		cCCusto := oIncForn:A2_XCCD
	endif
	if !empty(oIncForn:A2_CODPAIS)
		cCodPais := oIncForn:A2_CODPAIS
	endif
	if !empty(oIncForn:A2_CONTA)
		cContaCont:= oIncForn:A2_CONTA
	endif
	oSA2Mod:setValue("A2_COD_MUN"	,	alltrim(cCodMun)) 
	oSA2Mod:setValue("A2_CEP"		,	alltrim(cCEP			)) 
	oSA2Mod:setValue("A2_INSCR"		,	alltrim(cA2_INSCR)) 
	oSA2Mod:setValue("A2_PAIS"		,	alltrim(cPais		)) 
	oSA2Mod:setValue("A2_XTIPCON"	,	alltrim(cA2_XTIPCON		)) 
	oSA2Mod:setValue("A2_XCCD"		,	alltrim(cCCusto  	)) 
	oSA2Mod:setValue("A2_CONTA"		,	alltrim(cContaCont	)) 
	oSA2Mod:setValue("A2_CODPAIS"	,	alltrim(cCodPais	)) 

	//Se conseguir validar as informações
	If oModel:VldData()

		//Tenta realizar o Commit
		If oModel:CommitData()
			lError := .F.
			
		//Se não deu certo, altera a variável para false
		Else
			aErro   := oModel:GetErrorMessage()
			oObjLog:saveMsg(varinfo("aErro", aErro, , .f., .f. ))
			cMsgErro := ""
			// aeval(aErro, {|x| cMsgErro += x})
			conout("Erro na gravacao forn "+cMsgErro)

			lError := .t.
		EndIf
		
	//Se não conseguir validar as informações, altera a variável para false
	Else
		lError := .t.
		aErro   := oModel:GetErrorMessage()
		oObjLog:saveMsg(varinfo("aErro", aErro, , .f., .f. ))
		cMsgErro := ""
		// aeval(aErro, {|x| cMsgErro += x})
		conout("Erro na validacao forn "+cMsgErro)
		//lDeuCerto := .F.
	EndIf

	//Desativa o modelo de dados
	oModel:DeActivate()

	cFilAnt := cFilOrig
	FWSM0Util():setSM0PositionBycFilAnt()

	::cCodigo := 'YOK'

	If lError
		cMens := "Erro ao gravar Fornecedor"
		conout('[' + DToC(Date()) + " " + Time() + "] GerarFornecedor > " + cMens)
		SetSoapFault("Erro", cMens)
		Return .F.
	EndIf

Return .T.

static function convDate(xcPar)
	LcRet := ctod(substr(xcPar,9,2)+'/'+substr(xcPar,6,2)+'/'+left(xcPar,4))

return lcRet 

