CREATE OR REPLACE VIEW implantacao.vwp_cadan_ecommercenffaturadas AS
-- Criado por...........: HILSON SANTOS
-- Data da criação......:	16/10/2024
-- Objetivo.............:	PEGA TODOS OS PEDIDOS FATURADOS COM SUAS REPECTIVAS
--                        NOTAS FISCAIS COM STATUSNFE 4
SELECT 
   DISTINCT
   a.nropedidoafv id,
   a.nropedvenda codigo,
   '1' faturado,
   (
	 SELECT SUM(mfl_dfitem.vlritem + mfl_dfitem.vlricmsst)
   FROM implantacao.mad_pedvenda
   JOIN implantacao.mfl_doctofiscal
   ON mfl_doctofiscal.nropedidovenda = mad_pedvenda.nropedvenda
   JOIN implantacao.mfl_dfitem 
   ON mfl_dfitem.nroempresa = mfl_doctofiscal.nroempresa 
   AND mfl_dfitem.numerodf = mfl_doctofiscal.numerodf 
   AND mfl_dfitem.seriedf = mfl_doctofiscal.seriedf 
   WHERE mad_pedvenda.usuinclusao = 'ECOMMERCE'
   AND mad_pedvenda.dtainclusao >= (SYSDATE - 60)
   AND mad_pedvenda.situacaoped = 'F'
   AND 1 = 1 
   AND mfl_doctofiscal.nropedidovenda = a.nropedvenda
   ) valor_total_atendido
FROM implantacao.mad_pedvenda a 
JOIN implantacao.mfl_doctofiscal b
ON b.nropedidovenda = a.nropedvenda
WHERE a.usuinclusao = 'ECOMMERCE'
AND a.dtainclusao >= (SYSDATE - 60)
AND a.situacaoped = 'F'
AND 1 = 1 
GROUP BY a.nropedidoafv, a.nropedvenda
HAVING COUNT(DISTINCT b.statusnfe) = 1
ORDER BY 1 ASC
