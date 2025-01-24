SELECT
		a.nroempresa,																			
    SUM(NVL(ROUND(a.estqdeposito/b.qtdembalagem,0),0))
		AS estoquegeralqtd,	
		SUM(NVL(ROUND((a.estqdeposito/b.qtdembalagem)*b.precovenda,2),0))
		AS estoquegeralvlr,
		SUM(NVL(ROUND((a.estqdeposito-a.qtdreservadavda)/b.qtdembalagem,0),0))
		AS estoqueatualqtd,	
		SUM(NVL(ROUND(((a.estqdeposito-a.qtdreservadavda)/b.qtdembalagem)*b.precovenda,2),0))
		AS estoqueatualvlr,
		SUM(NVL(ROUND(a.qtdreservadavda/b.qtdembalagem,0),0))
		AS estoquereservadoqtd,	
		SUM(NVL(ROUND((a.qtdreservadavda/b.qtdembalagem)*b.precovenda,2),0))
		AS estoquereservadovlr
FROM implantacao.mrl_produtoempresa a
LEFT JOIN (SELECT
     					 DISTINCT
							 a.nroempresa,
    					 a.seqproduto,
							 ROUND(
							 CASE
							 WHEN a.precogerpromoc = 0
							 THEN a.precogernormal
							 ELSE a.precogerpromoc
							 END,2)
							 AS precovenda,
							 b.qtdembalagem
					 FROM implantacao.mrl_prodempseg a
					 INNER JOIN (SELECT
    			 			 			     DISTINCT 
    											 a.seqproduto,
													 ROUND(a.qtdembalagem,0) 
													 AS qtdembalagem 
												FROM implantacao.map_prodcodigo a 
												WHERE 1=1
												AND a.indutilvenda = 'S' 
												AND a.tipcodigo IN ('E','D')) b 
					 ON b.seqproduto = a.seqproduto
					 WHERE 1 = 1
					 AND a.nrosegmento IN (1, 3, 4, 5, 6, 7, 8, 9, 10)
					 AND a.statusvenda = 'A') b 
ON b.nroempresa = a.nroempresa AND b.seqproduto = a.seqproduto 
WHERE 1=1
AND a.statuscompra = 'A'
AND (a.estqdeposito+a.qtdreservadavda) != 0
GROUP BY a.nroempresa	
ORDER BY 1 ASC