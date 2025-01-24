SELECT
    DISTINCT 
    a.seqproduto,
		a.qtdembalagem 
FROM implantacao.map_prodcodigo a 
WHERE 1=1
AND a.indutilvenda = 'S' 
AND a.tipcodigo IN ('E','D')
ORDER BY 1 ASC