CREATE OR REPLACE VIEW implantacao.Tradepro_View_SubGruposProdutos AS
SELECT
    TO_CHAR(b.seqcategoria) AS cod_grupo,
    TO_CHAR(c.seqcategoria) AS codigo,
		c.categoria AS descricao
FROM implantacao.map_categoria a
INNER JOIN implantacao.map_categoria b ON b.seqcategoriapai = a.seqcategoria AND b.nivelhierarquia = 2 AND b.statuscategor = 'A'
INNER JOIN implantacao.map_categoria c ON c.seqcategoriapai = b.seqcategoria AND c.nivelhierarquia = 3 AND c.statuscategor = 'A'
WHERE 1 = 1
AND a.nivelhierarquia = 1
AND a.statuscategor = 'A'
ORDER BY 1 ASC		 

/*********************************************************************************************************************************************/
/* CRIADO POR HILSON SANTOS EM 19/12/2024																																																		 */
/* LOCAL: P:\EmOracle\IntegracaoTradePro-VIEW																																																 */
/* NOME DO ARQUIVO: Tradepro_View_SubGruposProdutos.sql																																											 */																																																		 
/*********************************************************************************************************************************************/

