CREATE OR REPLACE VIEW implantacao.Tradepro_View_Redes AS
SELECT
    TO_CHAR(seqrede) AS codigo,
		descricao AS descricao 
FROM implantacao.ge_rede
WHERE 1=1
ORDER BY 1 ASC

/*********************************************************************************************************************************************/
/* CRIADO POR HILSON SANTOS EM 20/12/2024																																																		 */
/* LOCAL: P:\EmOracle\IntegracaoTradePro-VIEW																																																 */
/* NOME DO ARQUIVO: Tradepro_View_Redes.sql																																																	 */																																																		 
/*********************************************************************************************************************************************/
