CREATE OR REPLACE VIEW implantacao.Tradepro_View_ClientesHistoricos AS
SELECT
		TO_CHAR(a.seqpessoa) AS cod_cliente,
		TO_CHAR(b.seqproduto) AS cod_produto,
    a.dtaultcompra AS data_ultima_compra,
		b.qtditem AS qtd_ultima_compra,
		b.valor AS valor_ultima_compra
FROM implantacao.mrl_cliente a
INNER JOIN (SELECT
    			 		 DISTINCT
							 a.nroempresa,
							 a.seqpessoa,
							 a.numerodf,
							 b.seqproduto,
							 SUM(b.vlritem - b.vlricmsst - b.vlrdesconto) AS valor,
							 COUNT(b.numerodf) AS qtditem
					  FROM implantacao.mfl_doctofiscal a
						INNER JOIN implantacao.mfl_dfitem b 
						ON b.nroempresa = a.nroempresa 
						AND b.numerodf = a.numerodf 
						AND b.seriedf = a.seriedf 
						AND b.nroserieecf = a.nroserieecf
						WHERE 1=1
						AND a.numerodf = (SELECT MIN(numerodf) FROM implantacao.mfl_doctofiscal WHERE seqpessoa = a.seqpessoa)
						GROUP BY a.nroempresa, a.seqpessoa, a.numerodf, b.seqproduto
						ORDER BY 1 ASC) b 
ON b.nroempresa = a.nroempresa AND b.seqpessoa = a.seqpessoa
WHERE 1=1
AND a.seqpessoa NOT IN (1, 22401)
AND a.statuscliente = 'A'
ORDER BY 1 ASC

/*********************************************************************************************************************************************/
/* CRIADO POR HILSON SANTOS EM 20/12/2024																																																		 */
/* LOCAL: P:\EmOracle\IntegracaoTradePro-VIEW																																																 */
/* NOME DO ARQUIVO: Tradepro_View_ClientesHistoricos.sql																																										 */																																																		 
/*********************************************************************************************************************************************/
