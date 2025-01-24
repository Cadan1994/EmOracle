CREATE OR REPLACE VIEW implantacao.Tradepro_View_Produtos AS
SELECT 
    DISTINCT
    TO_CHAR(a.seqproduto) AS codigo,
    a.desccompleta AS descricao,
    TO_CHAR(c.seqcategoria) AS cod_subgrupo,
    b.embalagem AS embalagem,
    NVL((SELECT t1.codacesso
         FROM (SELECT  t2.*
               FROM implantacao.map_prodcodigo t2
               WHERE t2.tipcodigo IN('E', 'D')
               AND t2.indutilvenda = 'S'
               ORDER BY t2.qtdembalagem) t1
         WHERE 1 = 1
         AND t1.seqproduto = a.seqproduto 
         AND ROWNUM = 1), a.seqproduto) AS  codigo_barras
FROM implantacao.map_produto a 
/* PEGA A EMBALAGEM DE VENDA */
INNER  JOIN (SELECT a.seqfamilia, a.embalagem
            FROM implantacao.map_famembalagem a
            WHERE a.status = 'A'
            AND a.qtdembalagem = (SELECT b.qtdembalagem
                                  FROM (SELECT c.*
                                        FROM implantacao.map_prodcodigo c
                                        WHERE c.indutilvenda = 'S'
                                        ORDER BY c.qtdembalagem) b
                                  WHERE 1 = 1 
                                  AND rownum = 1)) b
ON b.seqfamilia = a.seqfamilia
INNER JOIN (SELECT 
					 			DISTINCT
								a.seqproduto,
								c.seqcategoria 
						FROM implantacao.map_produto a
						INNER JOIN implantacao.map_famdivcateg b ON b.seqfamilia = a.seqfamilia
						INNER JOIN implantacao.map_categoria c ON c.seqcategoria = b.seqcategoria AND c.nrodivisao = b.nrodivisao AND c.nivelhierarquia = 3 AND c.statuscategor = 'A'
						WHERE 1=1
						AND desccompleta NOT LIKE 'ZZ%') c 
ON c.seqproduto = a.seqproduto	 
INNER JOIN implantacao.map_prodcodigo d 
ON d.seqproduto = a.seqproduto AND d.seqfamilia = a.seqfamilia AND d.indutilvenda = 'S'	
INNER JOIN implantacao.mrl_prodempseg e 
ON e.seqproduto = a.seqproduto AND e.statusvenda = 'A'
WHERE 1 = 1
AND (a.desccompleta NOT LIKE 'ZZ%' OR(a.desccompleta NOT LIKE '==%')) 
ORDER BY 1 ASC;

/*******************************************************************************************************************************/
/* CRIADO POR HILSON SANTOS 20/12/2024																																												 */
/* LOCAL: P:\EmOracle\IntegracaoTradePro-VIEW																																									 */
/* NOME DO ARQUIVO: Tradepro_View_Produtos.sql																																								 */
/*******************************************************************************************************************************/

