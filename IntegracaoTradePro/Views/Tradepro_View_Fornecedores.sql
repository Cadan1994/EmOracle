CREATE OR REPLACE VIEW implantacao.Tradepro_View_Fornecedores AS
SELECT
    DISTINCT
    TO_CHAR(a.seqfornecedor) AS codigo,
    NVL(REGEXP_REPLACE(c.nomerazao, '''', ''),'NAO INFORMADO') AS descricao
FROM implantacao.maf_fornecedor a
INNER JOIN implantacao.map_famfornec b 
ON b.seqfornecedor = a.seqfornecedor 
AND b.principal = 'S'
INNER JOIN implantacao.ge_pessoa c 
ON c.seqpessoa = a.seqfornecedor
WHERE 1=1
ORDER BY a.seqfornecedor ASC		

/*********************************************************************************************************************************************/
/* CRIADO POR HILSON SANTOS EM 19/12/2024																																																		 */
/* LOCAL: P:\EmOracle\IntegracaoTradePro-VIEW																																																 */
/* NOME DO ARQUIVO: Tradepro_View_Fornecedores.sql																																													 */																																																		 
/*********************************************************************************************************************************************/
