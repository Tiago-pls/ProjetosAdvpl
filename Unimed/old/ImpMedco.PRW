#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"

/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    �  IMPMEDCO     � Autor � Tiago Santos      � Data �26.12.19 ���
��+----------+------------------------------------------------------------���
���Descri��o �  Importa��o Cadastros de Medicos Cooperados TAF 		      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

user function IMPMEDCO()
                     
Local cTitulo   := "Selecione o Diret�rio para Importar Medicos Cooperados..."
Local nMascpad  := 0                        
Local cDirini   := "\"
Local nOpcoes   := GETF_LOCALHARD
Local lArvore   := .F. /*.T. = apresenta o �rvore do servidor || .F. = n�o apresenta*/   
Local lSalvar   := .F. /*.T. = Salva || .F. = Abre*/
                                                                            
cArq := cGetFile( '*.csv|*.csv' , cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)

If !File(cArq)
	MsgStop("O arquivo  n�o foi encontrado. A importa��o ser� abortada!","[AEST901] - ATENCAO")
	Return
EndIf       
   
MsAguarde({|| ProcArq(cArq)}, "Aguarde...", "Processando Registros...")


Return

/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    �  ProcArq    � Autor � Tiago Santos        � Data �18.09.19 ���
��+----------+------------------------------------------------------------���
���Descri��o �  Processa o arquivo selecionado                 		      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

static function ProcArq(cArq)  
              
Local cCPFs :=""
FT_FUSE(cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()        

aDados := {}     

lPrim := .T.
nCont := 0
While !FT_FEOF()
 
	IncProc("Lendo arquivo texto..." + cValToChar(nCont))
 
	cLinha := FT_FREADLN()
    
	If lPrim
		lPrim := .F.
	Else  
		nCont ++  		
		AADD(aDados,Separa(cLinha,";",.T.))	
		cCPFS += "'" + StrTran(StrTran(aDados[nCont,4], '.',''), '-','')+"',"
                                                    
	EndIf
		
	FT_FSKIP()
EndDo

cCPFS := SubStr(cCPFs, 1, len(cCPFs) -1)

cQRY := MontaQry(cCPFs)    

if Select("QRY1")<> 0
	DbCloseArea("QRY1")
Endif
                       
if select("SRA")== 0 
	DbSelectArea("SRA")
Endif                  

SRA->( dbSetOrder(5)) // RA_FILIAL + RA_CIC

TcQuery cQry New Alias "QRY1"   
 
lAtuTot := .F.    
nCont := 1          
nQtd := 0
If QRY1->(!Eof())
	While QRY1->(!Eof())  	    	
		MsProcTxt(Alltrim(QRY1->RA_NOMECMP))
		SRA->(dbGotop())
		lAchou := .F.		
		
		SRA->( DbSeek( QRY1->(RA_FILIAL + RA_CIC)))  
		
		While SRA->(RA_FILIAL + RA_CIC) == QRY1->(RA_FILIAL + RA_CIC)   
		
			If SRA->RA_PROCES='00003' .and. SRA->RA_SITFOLH<> 'D'  .and. Empty(SRA->RA_CATEFD)
				lAchou := .T.     
				nRecno:=  SRA->( Recno())
			
			Endif
		
			SRA->( DbSkip()) 
		Enddo	                                                               
		// Se achar registro do CPF pergunta se deseja sobrepor ou ignorar
		If lAchou
			SRA->( dbgoto(nRecno))
			
			if !lAtuTot
				lAtuReg := MSGYESNO( Alltrim(SRA->RA_NOMECMP) + "encontra-se na base, deseja sobrepor o registro ? ", "Aten��o"   )
			Endif
			
			if lAtuReg .and. !lAtuTot 
				lAtuTot := MSGYESNO( "Atualizar todos os Registros encontrados ? ","Aten��o" )
			endif

			if lAtuReg // usuario optou pela atualiza��o do cadastro
				GravaSRA(.F., aDados)
				nQtd ++
			Endif
        Else
            
			// chama a rotina de grava��o na SRA
			GravaSRA(.T.,aDados)
			nQtd ++
        Endif   

		QRY1->(dbSkip())
	Enddo
Else
	MsgInfo("Nao foram encontrados registros para os parametros informados!")
    Return .F.
Endif
                   

QRY1->( DbCloseArea())
                    
MSGALERT( "Foram importados " + cValtoChar(nQtd) + " registros", "Importacao" ) 
	
Return



/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    �  MontaQry     � Autor � Tiago Santos      � Data �26.12.19 ���
��+----------+------------------------------------------------------------���
���Descri��o �  Importa��o Cadastros de Medicos Cooperados TAF 		      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static function MontaQry(cCPFs) 

cRet := " select  DISTINCT                           "
cRet += " C9V_FILIAL RA_FILIAL                    ,  "
cRet += " C9V_CPF RA_CIC                          ,  "
cRet += " C9V_NIS RA_PIS                          ,  "
cRet += " C9V_NOME RA_NOMECMP                     ,  "
cRet += " C9V_SEXO RA_SEXO                        ,  "
cRet += " C9V_RCCOR RA_RACACOR                    ,  "
cRet += " C9V_ESTCIV RA_ESTCIVI                   ,  "
cRet += " C9V_GRINST RA_GRINRAI                   ,  "
cRet += " C9V_NOMSOC RA_NSOCIAL                   ,  "
cRet += " C9V_PRIEMP RA_TIPOADM                   ,  "
cRet += " C9V_DTNASC RA_NASC                      ,  "
cRet += " C9V_CODMUN RA_CODMUNN                   ,  "
cRet += " C9V_LOGRAD RA_LOGRDSC                   ,  "
cRet += " C9V_PAINAC RA_CPAISOR                   ,  "
cRet += " C9V_PAINAC RA_NACIONC                   ,  "
cRet += " C9V_NOMMAE RA_MAE                       ,  "
cRet += " C9V_NOMPAI RA_PAI                       ,  "
cRet += " C9V_NRCTPS RA_NUMCP                     ,  "
cRet += " C9V_SERCTP RA_SERCP                     ,  "
cRet += " C9V_UFCTPS RA_UFCP                      ,  "
cRet += " C9V_NRRIC RA_NUMRIC                     ,  "
cRet += " C9V_OREMRI RA_EMISRIC                   ,  "
cRet += " C9V_NRRG RA_RG                          ,  "
cRet += " C9V_OREMRG RA_RGEXP                     ,  "
cRet += " C9V_DTEMRG RA_DTRGEXP                   ,  "
cRet += " C9V_NRRNE RA_RNE                        ,  "
cRet += " C9V_DTEMRN RA_RNEORG                    ,  "
cRet += " C9V_OREMRN RA_RNEDEXP                   ,  "
cRet += " C9V_NUMOC RA_CODIGO                     ,  "
cRet += " C9V_OREMOC RA_OCEMIS                    ,  "
cRet += " C9V_DTEXOC RA_OCDTEXP                   ,  "
cRet += " C9V_DTVLOC RA_OCDTVAL                   ,  "
cRet += " C9V_NRCNH RA_HABILIT                    ,  "
cRet += " C9V_DTEXCN RA_DTEMCNH                   ,  "
cRet += " C9V_UFCNH RA_UFCNH                      ,  "
cRet += " C9V_DTVLCN RA_DTVCCNH                   ,  "
cRet += " C9V_DTPCNH RA_DTINCON                   ,  "
cRet += " C9V_CATCNH RA_CATCNH                    ,  "
cRet += " C9V_NRLOG RA_LOGRNUM                    ,  "
cRet += " C9V_COMLOG RA_COMPLEM                   ,  "
cRet += " C9V_BAIRRO RA_BAIRRO                    ,  "
cRet += " C9V_CEP RA_CEP                          ,  "
cRet += " C9V_MUN RA_CODMUN                       ,  "
cRet += " C9V_UF RA_ESTADO                        ,  "
cRet += " C9V_CODUF RA_ESTADO                        ,  "
cRet += " C9V_PAIS RA_PAISEXT                     ,  "
cRet += " C9V_NRLOG RA_LOGRNUM                    ,  "
cRet += " C9V_COMLOG RA_COMPLEM                   ,  "
cRet += " C9V_BAIRRO RA_BAIRRO                    ,  "
cRet += " C9V_MUN RA_MUNICIP                      ,  "
cRet += " C9V_DTCHEG RA_DATCHEG                   ,  "
cRet += " C9V_CCTRAE RA_CLASEST                   ,  "
cRet += " C9V_CASBRA RA_CASADBR                   ,  "
cRet += " C9V_FILBRA RA_FILHOBR                   ,  "
cRet += " C9V_DEFFIS RA_PORTDEF                   ,  "
cRet += " C9V_DEFAUD RA_PORTDEF                   ,  "
cRet += " C9V_DEFVIS RA_PORTDEF                   ,  "
cRet += " C9V_DEFMEN RA_PORTDEF                   ,  "
cRet += " C9V_DEFINT RA_PORTDEF                   ,  "
cRet += " C9V_REABIL RA_PORTDEF                   ,  "
cRet += " C9V_INFCOT RA_CTPCD                     ,  "
cRet += " C9V_APOSEN RA_EAPOSEN                   ,  "
cRet += " C9V_DDDFPR RA_DDDFONE                   ,  "
cRet += " C9V_FONPRC  RA_TELEFON                  ,  "
cRet += " C9V_DDDFAL RA_DDDCELU                   ,  "
cRet += " C9V_FONALT  RA_NUMCELU                  ,  "
cRet += " C9V_EMAILP RA_EMAIL                     ,  "
cRet += " C9V_EMAILA RA_EMAIL2                    ,  "
cRet += " C9V_MATRIC RA_CODUNIC                   ,  "
cRet += " C9V_GRINST RA_VIEMRAI                   ,  "  
cRet += " C9V_DTINIV RA_ADMISSA                   ,  "
cRet += " C9V_NRLOG RA_LOGRNUM                   ,  "
cRet += " C9V_COMLOG RA_COMPLEM                   ,  "

cRet += " C09_UF RA_NATURAL                         , "

cRet += " CUU_CARCI, C8V_CODIGO RA_CODFUNC           "
cRet += " from " + RetSqlName("C9V")+" C9V           "
cRet += " Left Join "+ RetSqlName("C09") + " C09 on C9V_CODUF = C09_ID "
cRet += " Left Join "+ RetSqlName("C07") + " C07 on C9V_CODUF = C09_ID " 

cRet += " inner join " +RetSqlName("CUU")+" CUU on CUU_FILIAL = C9V_FILIAL and CUU_ID = C9V_ID "

cRet += " inner join " + RetSqlName("C8V")+" C8V on CUU_CARCI = C8V_ID and C8V.D_E_L_E_T_ =' '


cRet += " where C9V.D_E_L_E_T_ =' '  and C9V_ATIVO ='1' "
cRet += " and C9V_CPF in (" + cCpfs + ")" 
cRet += " Order by 1,2 "
Return cRet
                                            


/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    �  GravaSRA     � Autor � Tiago Santos      � Data �26.12.19 ���
��+----------+------------------------------------------------------------���
���Descri��o �  Importa��o Cadastros de Medicos Cooperados TAF 		      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
                                                                             
static Function GravaSRA(lInclui, aDados)         
Local cMat := GETMV("MV_MATCOOP")
local aSRAArea := SRA->( GetArea())  
local nQtd  :=0
local aRet := RetDados( aDados)
BEGIN TRANSACTION       

	ProcRegua(Len(aDados))	
	
	if RecLock("SRA", lInclui)	
        
		if (lInclui)
			SRA->RA_FILIAL    :=     QRY1->RA_FILIAL   
			SRA->RA_MAT       :=     cMat
			SRA->RA_PROCES    :=     '00003'
			SRA->RA_CATFUNC   :=     'A' // Autonomo
			SRA->RA_CIC       :=     QRY1->RA_CIC 
		Endif			
			
		SRA->RA_ADMISSA   :=     StoD(QRY1->RA_ADMISSA)
		SRA->RA_PIS       :=     QRY1->RA_PIS      
		SRA->RA_NOMECMP   :=     QRY1->RA_NOMECMP  
   		SRA->RA_NOME      :=  SubStr(Alltrim(SRA->RA_NOMECMP),1,30)    		
   		SRA->RA_NASC      := Stod(QRY1->RA_NASC)                       		
   		SRA->RA_PAI       := Alltrim( QRY1->RA_PAI)
   		SRA->RA_MAE       := Alltrim( QRY1->RA_MAE)
   		SRA->RA_NUMRIC    := QRY1->RA_NUMRIC
   		SRA->RA_EMISRIC   := QRY1->RA_EMISRIC
   		SRA->RA_RG        := Alltrim(QRY1->RA_RG)
   		SRA->RA_RGEXP    := Alltrim(QRY1->RA_RGEXP)
   		SRA->RA_DTRGEXP  := Stod( QRY1->RA_DTRGEXP)   		
   		SRA->RA_RNE     := QRY1->RA_RNE
   		SRA->RA_RNEORG  := QRY1->RA_RNEORG    
   		SRA->RA_CODIGO := QRY1->RA_CODIGO
   		SRA->RA_OCEMIS := QRY1->RA_OCEMIS
   		SRA->RA_OCDTEXP:= Stod(QRY1->RA_OCDTEXP)
   		SRA->RA_SEXO   := QRY1->RA_SEXO
   		SRA->RA_NATURAL   := QRY1->RA_NATURAL // estado de nascimento
   		SRA->RA_CODMUNN  := QRY1->RA_CODMUNN
   		SRA->RA_GRINRAI   := QRY1->RA_GRINRAI
   		SRA->RA_TIPOPGT   :='M'   		
   		SRA->RA_LOGRDSC:= QRY1->RA_LOGRDSC   		
   		SRA->RA_LOGRNUM := QRY1->RA_LOGRNUM   		
   		SRA->RA_CEP    := QRY1->RA_CEP      
   		SRA->RA_COMPLEM := QRY1->RA_COMPLEM
   		SRA->RA_LOGRNUM  := QRY1->RA_LOGRNUM 
   		SRA->RA_NUMENDE  := QRY1->RA_LOGRNUM
   		SRA->RA_ESTADO   := QRY1->RA_NATURAL
   		SRA->RA_TIPOADM  := "9B"
   		SRA->RA_CODFUNC   := QRY1->RA_CODFUNC  
   		SRA->RA_NACIONA  := '10'
   		
   		SRA->RA_XMEDCOO ='S'
   		SRA->RA_CC := aRet [1,1]  
   		SRA->RA_DEPTO := aRet [1,1]  
		DO CASE
		         CASE QRY1->RA_ESTCIVI == '1' // Solteiro
		                    cEstCiv := 'S'		
		         CASE QRY1->RA_ESTCIVI == '2' // Casado
		                    cEstCiv := 'C'		
		         CASE QRY1->RA_ESTCIVI == '3' .or. QRY1->RA_ESTCIVI == '4' // Divorciado
		                    cEstCiv := 'Q' 		
		         CASE QRY1->RA_ESTCIVI == '5' 
		                    cEstCiv := 'V' 
		         OTHERWISE
		                    cEstCiv := 'O' 		                                  
		ENDCASE 
		SRA->RA_ESTCIVI := cEstCiv
   		            
   		if len( aRet[1,2])>2
   			SRA->RA_XESPECI := aRet[1,2]
   		Endif        
   		SRA->RA_HESMES  := '200'
   		nQtd ++
   		
   		if lInclui
			PUTMV("MV_MATCOOP", Soma1(cMat))	
		endif	
		MsUnLock() // Confirma e finaliza a opera��o
	Endif
	
END TRANSACTION                                              
Return

Static Function RetDados (aDados)
Local aRet := {}           
local nCont:=1

for nCont :=1 to len (aDados) 
	cCpf := StrTran(StrTran(aDados[nCont,4], '.',''), '-','')
	if QRY1->RA_CIC = cCPF
		Aadd(aRet, { aDados[nCont,5] , aDados[nCont,12]} )   
		exit
	endif

Next nCont
Return aRet
