CREATE TABLE IMPLANTACAO.CADAN_CLIENTEFOCOFAIXA
(
  SEQPESSOA    NUMBER NOT NULL,
  JSONDATA     VARCHAR2(255) NOT NULL,
  DTAINCLUSAO  DATE NOT NULL,
  DTAALTERACAO DATE NOT NULL,
  STATUS       VARCHAR2(1) DEFAULT 'A' NOT NULL,
	CONSTRAINT CADAN_CLIENTEFOCOFAIXA PRIMARY KEY (SEQPESSOA)
)