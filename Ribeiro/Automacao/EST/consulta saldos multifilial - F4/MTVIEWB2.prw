/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTVIEWB2  �Autor  �Joao Edenilson Lopes� Data �  02/07/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Ponto de entrada que chama a Tela de consulta de saldos   ���
���          �  em estoque                                                ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MTVIEWB2

If type("acols[n][2]")<>"U"
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+acols[n][2])
Endif

If FunName()=="MATA415"               
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+TMP1->CK_PRODUTO)
Endif

U_TLEST001()

Return .F.

//User Function BVIEWSB2

//	U_TLEST001()

//return
