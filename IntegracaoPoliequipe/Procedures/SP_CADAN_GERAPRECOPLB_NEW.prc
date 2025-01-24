CREATE OR REPLACE PROCEDURE POLIBRAS.SP_CADAN_GERAPRECOPLB(DATAINSERT IN DATE) IS
BEGIN
  /** Limpa a tabela temporária "CADAN_TAB_PRECO_T" **/
  EXECUTE IMMEDIATE 'TRUNCATE TABLE polibras.CADAN_TAB_PRECO_T';
	
  /** Insere da view "VWP_TABELA_PRECO" para tabela temporária "CADAN_TAB_PRECO_T" **/
  INSERT INTO POLIBRAS.CADAN_TAB_PRECO_T
    (SELECT A.*, DATAINSERT
       FROM POLIBRAS.VWP_TABELA_PRECOPLB A);
  COMMIT;

  /** Limpa a tabela "CADAN_TAB_PRECO" **/
  EXECUTE IMMEDIATE 'TRUNCATE TABLE polibras.CADAN_TAB_PRECO';

  /** insere da tabela "CADAN_TAB_PRECO_T" para tabela "CADAN_TAB_PRECO" **/
  INSERT INTO POLIBRAS.CADAN_TAB_PRECO
    (SELECT B.* FROM CADAN_TAB_PRECO_T B);
  COMMIT;
	
  /** Limpa a tabela temporária "CADAN_TAB_PRECO_T" **/
  EXECUTE IMMEDIATE 'TRUNCATE TABLE polibras.CADAN_TAB_PRECO_T';

END SP_CADAN_GERAPRECOPLB;

---------------------------------------------------------------------------------------------------
-- Nome do objeto...........: SP_CADAN_GERAPRECOPLB																							 --
-- Alterado por.............: HILSON SANTOS																											 --
-- Data da alteração........: 21/01/2025																												 --
-- Observação...............: FOI ALTERADO A LINHA 9 MODIFICANDO A VIEW VWP_TABELA_PRECO_301117	 --
-- 														PARA VIEW VWP_TABELA_PRECO				 	 															 --																																																 
---------------------------------------------------------------------------------------------------
/
