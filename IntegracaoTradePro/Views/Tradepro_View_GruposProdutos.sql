CREATE OR REPLACE VIEW implantacao.Tradepro_View_GruposProdutos AS
SELECT 
    DISTINCT
    TO_CHAR(a.seqcategoria) AS	codigo,
		a.categoria AS descricao,
		c.seqfornecedor AS cod_fornecedor
FROM implantacao.map_categoria a
LEFT JOIN implantacao.map_famdivcateg b ON b.seqcategoria = a.seqcategoria
INNER JOIN implantacao.map_famfornec c ON c.seqfamilia = b.seqfamilia AND c.principal = 'S'
WHERE 1 = 1
AND a.statuscategor = 'A'
AND a.nivelhierarquia = 2
ORDER BY 1 ASC

/*********************************************************************************************************************************************/
/* CRIADO POR HILSON SANTOS EM 19/12/2024																																																		 */
/* LOCAL: P:\EmOracle\IntegracaoTradePro-VIEW																																																 */
/* NOME DO ARQUIVO: Tradepro_View_GruposProdutos.sql																																												 */																																																		 
/*********************************************************************************************************************************************/
