#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'
user function testasre()

Return
local aTransf , uData , lEmp , lFil , lCct , lMat , lNoRept , lOrigem, lProc, lDepto, lPosto, lItmClvl, cFil, cMat 

user Function FTfTransf( aTransf , uData , lEmp , lFil , lCct , lMat , lNoRept , lOrigem, lProc, lDepto, lPosto, lItmClvl, cFil, cMat )

Local aLastTrf 		:= If( ( ValType( aTransf ) == "A" ) , aClone( aTransf ) , {} )
Local aRecTrf		:= {}
Local aArea			:= {}

Local cChave    	:= ""
Local cChaveAux 	:= ""
Local cEmp			:= cEmpAnt

Local nSreSvOrder   := SRE->( IndexOrd() )
Local nMaxRecTrf	:= 0

Local nRecTrf
Local nRecsTrf
Local nSreOrder

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Bloco Para Verificar Item ja Adicionado                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local bIgual  := { || aScan( aTransf, { |x|	x[1]; 			   // Empresa De
											+;
	  							            x[2]; 			// Filial + Matricula De
                                           	+;
                                           	x[3]; 			// Centro de Custo De
                                           	+;
                                           	x[4]; 			// Empresa Para
                                           	+;
                                           	x[5]; 			// Filial + Matricula Para
                                           	+;
                                           	x[6]; 			// Centro ce Custo Para
                                           	+;
                                           	Dtos(x[7]);	// Data da Transferencia
                                           	+;
                                           	x[14];			// Processo De
                                           	+;
                                           	x[15];			// Processo Para
                                           	+;
                                           	x[16];			// Depto De 
                                           	+;
                                           	x[17];			// Depto para
                                           	+;
                                           	x[18];			// Posto De
                                           	+;
                                           	x[19];			// Posto Para
                                           	+;
                                           	If(lItemClvl,;
           									   x[20]+;    //Item De
           										x[21]+;    //Item Para
           										x[22]+;    //Classe de Valor De
           										x[23],;    //Classe de Valor Para
           										"");
                                            ==;
                                            RE_EMPD;		// Empresa De
                                           	+;
                                           	Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) ;	// Filial
                                           	+;
                                           	RE_MATD; 		// Matricula De
                                           	+;
                                           	RE_CCD; 		// Centro de Custo De
                                           	+;
                                           	RE_EMPP; 		// Empresa Para
                                           	+;
                                           	Substr(RE_FILIALP,1,FWSizeFilial(RE_EMPP)); 	// Filial
                                           	+;
                                           	RE_MATP; 		// Matricula Para
                                           	+;
                                           	RE_CCP; 		// Centro ce Custo Para
                                           	+;
                                           	Dtos(RE_DATA);	// Data da Transferencia
                                           	+;
                                           	RE_PROCESD;		// Processo De
                                           	+;
                                           	RE_PROCESP;		// Processo Para
                                           	+;
                                           	RE_DEPTOD;		// Depto De
                                           	+;
                                           	RE_DEPTOP;		// Depto Para
                                           	+;
                                           	RE_POSTOD;		// Posto De
                                           	+;
                                           	RE_POSTOP;      // Posto Para
                                           	+;		
                                           	If(lItemClvl,;
                                           				 RE_ITEMD+;	//Item De
                                           				 RE_ITEMP+; //Item Para
                                           				 RE_CLVLD+; //Classe de Valor De
                                           				 RE_CLVLP,;  //Classe de Valor Para
                                           				 "");		
                                          };
                              ) == 0;
                  }
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Bloco Para Verificar Data                                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local bData   := { ||	If(ValType(uData) == "L"								, .T. ,	; // Todas as Transferencias Independente da Data
                      	If(ValType(uData) == "C" .and. MesAno(RE_DATA) == uData	, .T. ,	; // Todas as Transferencias Em Determinado Mes/Ano
                      	If(ValType(uData) == "D" .and. RE_DATA == uData        	, .T. ,	; // Todas as Transferencias Em Determinada Data
                      	.F.) ) ) }

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Bloco Para Verificar Itens Iguais                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local bE      := { || If(lNoRept, aScan( aTransf, { |x| x[1]                          							== RE_EMPD                                    									} ) == 0 , .T. ) }

Local bF      := { || If(lNoRept, aScan( aTransf, { |x| SubStr(x[2],1,FWSizeFilial(RE_EMPD))         			== Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD))                             		} ) == 0 , .T. ) } 
Local bEF     := { || If(lNoRept, aScan( aTransf, { |x| x[1] + SubStr(x[2],1,FWSizeFilial(RE_EMPD))        	== RE_EMPD    + Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD))        				} ) == 0 , .T. ) }

Local bP      := { || If(lNoRept, aScan( aTransf, { |x| x[14]                          						== RE_PROCESD                                     								} ) == 0 , .T. ) }
Local bEP     := { || If(lNoRept, aScan( aTransf, { |x| x[1] + x[14]                   						== RE_EMPD    + RE_PROCESD                        								} ) == 0 , .T. ) }

Local bFP     := { || If(lNoRept, aScan( aTransf, { |x| SubStr(x[2],1,FWSizeFilial(RE_EMPD)) + x[14]       	== Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) + RE_PROCESD                 	} ) == 0 , .T. ) }
Local bEFP    := { || If(lNoRept, aScan( aTransf, { |x| x[1] + SubStr(x[2],1,FWSizeFilial(RE_EMPD)) + x[14]  == RE_EMPD    + Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) + RE_MATD + RE_PROCESD} ) == 0 , .T. ) }
Local bEFDP   := { || If(lNoRept, aScan( aTransf, { |x| x[1] + SubStr(x[2],1,FWSizeFilial(RE_EMPD)) + x[16]+x[14]==RE_EMPD  + Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) + RE_DEPTOD	+ RE_PROCESD} ) == 0 , .T. ) }

Local bD      := { || If(lNoRept, aScan( aTransf, { |x| x[16]                          						== RE_DEPTOD                                     								} ) == 0 , .T. ) }
Local bED     := { || If(lNoRept, aScan( aTransf, { |x| x[1] + x[16]                   						== RE_EMPD    + RE_DEPTOD                            							} ) == 0 , .T. ) }
Local bFD     := { || If(lNoRept, aScan( aTransf, { |x| SubStr(x[2],1,FWSizeFilial(RE_EMPD)) + x[16]        	== Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) + RE_DEPTOD                      } ) == 0 , .T. ) }
Local bEFD    := { || If(lNoRept, aScan( aTransf, { |x| x[1] + SubStr(x[2],1,FWSizeFilial(RE_EMPD))+ x[16]   == RE_EMPD + Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) + RE_DEPTOD			} ) == 0 , .T. ) }
Local bEFCD   := { || If(lNoRept, aScan( aTransf, { |x| x[1] + SubStr(x[2],1,FWSizeFilial(RE_EMPD))+ x[3]+ x[16]	== RE_EMPD + Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) + RE_CCD 	+ RE_DEPTOD} ) == 0 , .T. ) }

Local bC      := { || If(lNoRept, aScan( aTransf, { |x| x[3]                          							== RE_CCD                                     									} ) == 0 , .T. ) }
Local bEC     := { || If(lNoRept, aScan( aTransf, { |x| x[1] + x[3]                   							== RE_EMPD + RE_CCD                        										} ) == 0 , .T. ) }
Local bFC     := { || If(lNoRept, aScan( aTransf, { |x| SubStr(x[2],1,FWSizeFilial(RE_EMPD)) + x[3]        	== Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) + RE_CCD                      	} ) == 0 , .T. ) }
Local bEFC    := { || If(lNoRept, aScan( aTransf, { |x| x[1] + SubStr(x[2],1,FWSizeFilial(RE_EMPD)) + x[3]	== RE_EMPD + Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) + RE_CCD  				} ) == 0 , .T. ) }

Local bT      := { || If(lNoRept, aScan( aTransf, { |x| x[18]                          						== RE_POSTOD                                     								} ) == 0 , .T. ) }
Local bET     := { || If(lNoRept, aScan( aTransf, { |x| x[1] + x[18]                   						== RE_EMPD     + RE_POSTOD                        								} ) == 0 , .T. ) }
Local bFT     := { || If(lNoRept, aScan( aTransf, { |x| SubStr(x[2],1,FWSizeFilial(RE_EMPD))+ x[18]         == Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) + RE_POSTOD                     } ) == 0 , .T. ) }
Local bEFT    := { || If(lNoRept, aScan( aTransf, { |x| x[1] + SubStr(x[2],1,FWSizeFilial(RE_EMPD)) + x[18] == RE_EMPD + Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) +  RE_POSTOD		    } ) == 0 , .T. ) }

Local bECM    := { || If(lNoRept, aScan( aTransf, { |x| x[1] + SubStr(x[2],FWSizeFilial(RE_EMPD)+1) + x[3] 	== RE_EMPD    + RE_MATD    + RE_CCD           									} ) == 0 , .T. ) }
Local bEPM    := { || If(lNoRept, aScan( aTransf, { |x| x[1] + SubStr(x[2],FWSizeFilial(RE_EMPD)+1) + x[14]	== RE_EMPD    + RE_MATD    + RE_PROCESD        									} ) == 0 , .T. ) }
Local bEM     := { || If(lNoRept, aScan( aTransf, { |x| x[1] + SubStr(x[2],FWSizeFilial(RE_EMPD)+1)        	== RE_EMPD    + RE_MATD                       									} ) == 0 , .T. ) } 
Local bFCM    := { || If(lNoRept, aScan( aTransf, { |x| x[2] + x[3]                   						== Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) + RE_MATD    + RE_CCD 			} ) == 0 , .T. ) }
Local bFPM    := { || If(lNoRept, aScan( aTransf, { |x| x[2] + x[14]                   						== Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) + RE_MATD    + RE_PROCESD       	} ) == 0 , .T. ) }
Local bFM     := { || If(lNoRept, aScan( aTransf, { |x| x[2]                          						== Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) + RE_MATD               			} ) == 0 , .T. ) }
Local bEFCM   := { || If(lNoRept, aScan( aTransf, { |x| x[1] + x[2] + x[3]             						== RE_EMPD + Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) + RE_MATD + RE_CCD 	} ) == 0 , .T. ) }
Local bEFDM   := { || If(lNoRept, aScan( aTransf, { |x| x[1] + x[2] + x[16]        							== RE_EMPD + Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) + RE_MATD + RE_DEPTOD 	} ) == 0 , .T. ) }
Local bCM     := { || If(lNoRept, aScan( aTransf, { |x| SubStr(x[2],FWSizeFilial(RE_EMPD)+1) + x[3]         == RE_MATD    + RE_CCD                        									} ) == 0 , .T. ) } 
Local bPM     := { || If(lNoRept, aScan( aTransf, { |x| SubStr(x[2],FWSizeFilial(RE_EMPD)+1) + x[14]        == RE_MATD    + RE_PROCESD                        								} ) == 0 , .T. ) } 
Local bM      := { || If(lNoRept, aScan( aTransf, { |x| SubStr(x[2],FWSizeFilial(RE_EMPD)+1)               	== RE_MATD                                    									} ) == 0 , .T. ) }
lOCAL bIV
lOCAL bEFIV
lOCAL bFIV 
Local cFilTrf,cMatTrf,cEmpTrf,dDtTrf
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Bloco Para Adicionar itens em aTransf                        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local bAddTrf := { || aAdd( aTransf,; 
										{;
											RE_EMPD              									,; // 01 - Empresa De
                                     		Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) + RE_MATD 	,; // 02 - Filial  De + Matricula De
                                    		RE_CCD               									,; // 03 - Centro de Custo De
		                               		RE_EMPP              									,; // 04 - Empresa Para
        		                       		Substr(RE_FILIALP,1,FWSizeFilial(RE_EMPP)) + RE_MATP	,; // 05 - Filial  Para + Matricula Para
                		               		RE_CCP               									,; // 06 - Centro de Custo Para
                        		            RE_DATA				 									,; // 07 - Data da Transferencia
                                		    Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD))				,; // 08 - Filial de Origem
                                     		RE_MATD				 									,; // 09 - Matricula de Origem
		                                    Substr(RE_FILIALP,1,FWSizeFilial(RE_EMPP))			 	,; // 10 - Filial de Destino
        		                            RE_MATP				 									,; // 11 - Matricula de Destino
        		                            MesAno( RE_DATA )	 									,; // 12 - Mes/Ano ( Ano/Mes ) da Transferencia 	
        		                            Recno()				 									,; // 13 - Recno() da Transferencia
        		                            RE_PROCESD			 									,; // 14 - Processo De
        		                            RE_PROCESP			 									,; // 15 - Processo Para
        		                            RE_DEPTOD			 									,; // 16 - Depto de
        		                            RE_DEPTOP			 									,; // 17 - Depto Para
        		                            RE_POSTOD			 									,; // 18 - Posto De
        		                            RE_POSTOP			 ,; // 19 - Posto Para
        		                            If (lItemclvl, RE_ITEMD,""),;// 20 - Item De
                                     		If (lItemClvl, RE_ITEMP,""),;// 21 - Item Para
                                     		If (lItemClvl, RE_CLVLD,""),;// 22 - Classe de Valor De
                                     		If (lItemClvl, RE_CLVLP,""),; // 23 - Classe de Valor Para
                                     		If (SRE->(FieldPos("RE_TRFUNID"))>0, RE_TRFUNID,""),; // 24 - ID de Transferencia
                                     		If (SRE->(FieldPos("RE_TRFOBS"))>0, RE_TRFOBS,""); // 25 - Observacao da Transferencia
                		                 };
                           			);
                   }

DEFAULT cFil := SRA->RA_FILIAL
DEFAULT cMat := SRA->RA_MAT

Static nSreOrder1
Static nSreOrder2
Static lItemClVl

DEFAULT nSreOrder1 := RetOrdem( "SRE" , "RE_EMPP+RE_FILIALP+RE_MATP" )
DEFAULT nSreOrder2 := RetOrdem( "SRE" , "RE_EMPD+RE_FILIALD+RE_MATD+DTOS(RE_DATA)" , .T. )
DEFAULT lItemClVl  := GetMvRH("MV_ITMCLVL ",NIL,"2") $ "1*3"

If nSreOrder2 == 0
	nSreOrder2 := RetOrdem( "SRE" , "RE_EMPD+RE_FILIALD+RE_MATD" )
EndIf

If lItemClvl
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Bloco Para Verificar Itens Iguais do Item e classe de valor  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/	
	bIV     := { || If(lNoRept, aScan( aTransf, { |x| x[20]+ x[22]                    	 								== RE_ITEMD+RE_CLVLD                               			} ) == 0 , .T. ) }
	bEIV    := { || If(lNoRept, aScan( aTransf, { |x| x[1] + x[20]+x[22]             									== RE_EMPD    + RE_ITEMD   +RE_CLVLD                      	} ) == 0 , .T. ) }
	bFIV    := { || If(lNoRept, aScan( aTransf, { |x| SubStr(x[2],1,FWSizeFilial(RE_EMPD)) + x[20]+x[22]   				== RE_FILIALD + RE_ITEMD   +RE_CLVLD                       	} ) == 0 , .T. ) }
	bEFIV   := { || If(lNoRept, aScan( aTransf, { |x| x[1]+SubStr(x[2],1,FWSizeFilial(RE_EMPD))+x[20]+x[22] 			== RE_EMPD    + RE_FILIALD + RE_ITEMD+RE_CLVLD  			} ) == 0 , .T. ) }
	bCIV	:= { || If(lNoRept, aScan( aTransf, { |x| x[3] + x[20]+x[22]             									== RE_CCD     + RE_ITEMD   +RE_CLVLD  		             	} ) == 0 , .T. ) }
	bECIV   := { || If(lNoRept, aScan( aTransf, { |x| x[1] + x[3]+ x[20]+x[22]       									== RE_EMPD    + RE_CCD     + RE_ITEMD+RE_CLVLD            	} ) == 0 , .T. ) }
	bFCIV   := { || If(lNoRept, aScan( aTransf, { |x| SubStr(x[2],1,FWSizeFilial(RE_EMPD))+X[3]+ x[20]+x[22]			== RE_FILIALD + RE_CCD     + RE_ITEMD+RE_CLVLD            	} ) == 0 , .T. ) }
	bEFCIV  := { || If(lNoRept, aScan( aTransf, { |x| x[1]+SubStr(x[2],1,FWSizeFilial(RE_EMPD))+X[3]+x[20]+x[22]		== RE_EMPD    + RE_FILIALD + RE_CCD  + RE_ITEMD+RE_CLVLD  	} ) == 0 , .T. ) }
	bMIV	:= { || If(lNoRept, aScan( aTransf, { |x| SubStr(x[2],FWSizeFilial(RE_EMPD)+1)+x[20]+x[22]					== RE_MATD    + RE_ITEMD   +RE_CLVLD  		             	} ) == 0 , .T. ) }
	bEMIV	:= { || If(lNoRept, aScan( aTransf, { |x| x[1]+x[22]+SubStr(x[2],FWSizeFilial(RE_EMPD)+1)+x[20]+x[22]		== RE_EMPD    + RE_MATD    + RE_ITEMD+RE_CLVLD          	} ) == 0 , .T. ) }
	bFMIV	:= { || If(lNoRept, aScan( aTransf, { |x| x[2]+x[20]+x[22]													== Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD))+ RE_MATD    + RE_ITEMD+RE_CLVLD          	} ) == 0 , .T. ) }
	bEFMIV	:= { || If(lNoRept, aScan( aTransf, { |x| x[1]+x[2]+x[20]+x[22]												== RE_EMPD    +Substr(RE_FILIALD,1,FWSizeFilial(RE_EMPD)) + RE_MATD +RE_ITEMD+RE_CLVLD	} ) == 0 , .T. ) }
EndIf
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Inicializa os Parametros com os valores DEFAULT              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aTransf := {}
uData   := If( ( uData		== NIL ) .or. !( ValType(uData ) $ "C_D" )	, .F. , uData	)
lEmp    := If( ( lEmp 		== NIL ) .or. ValType(lEmp) 		!= "L"  , .F. , lEmp	)
lFil    := If( ( lFil		== NIL ) .or. ValType(lFil) 		!= "L"  , .F. , lFil	)
lCct    := If( ( lCct		== NIL ) .or. ValType(lCct) 		!= "L"  , .F. , lCct	)
lMat    := If( ( lMat		== NIL ) .or. ValType(lMat) 		!= "L"  , .F. , lMat	)
lNoRept := If( ( lNoRept	== NIL ) .or. ValType(lNoRept)		!= "L"  , .F. , lNoRept	)
lOrigem := If( ( lOrigem	== NIL ) .or. ValType(lOrigem)		!= "L"  , .F. , lOrigem	)
lProc	:= If( ( lProc		== NIL ) .or. ValType(lProc) 		!= "L"  , .F. , lProc	)
lDepto	:= If( ( lDepto		== NIL ) .or. ValType(lDepto) 		!= "L"  , .F. , lDepto	)
lPosto	:= If( ( lPosto		== NIL ) .or. ValType(lPosto) 		!= "L"  , .F. , lPosto	)
lItmClvl:= If( ( lItmClvl	== NIL ) .or. ValType(lItmClvl)		!= "L"  , .F. , lItmClvl)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta Chave com a Situacao Atual do Funcionario              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cChave	:=	( cEmp + Substr(cFil+Space(12),1,12) + cMat )
//cChave	:=	( cEmp + cFil + cMat )

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Seleciona o Arquivo de Transferencias, Ordem (2) Para que   a³
³ Procura seja Feita a Partir da Transferencia "Para".         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nSreOrder := nSreOrder1
SRE->( dbSetOrder( nSreOrder ) )

cFilTrf := cFil
cMatTrf := cMat
cEmpTrf := cEmp

aArea := GetArea()

While fTrfAnt(cFilTrf,cMatTrf,cEmpTrf,dDtTrf,@aRecTrf)
	cFilTrf := SRE->RE_FILIALD
	cMatTrf := SRE->RE_MATD
	cEmpTrf := SRE->RE_EMPD
	dDtTrf	:= SRE->RE_DATA
EndDo

RestArea(aArea)
